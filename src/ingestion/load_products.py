from pathlib import Path
from src.ingestion.utils import calculate_file_hash, idempotency_check, log_failed, log_started, log_success
from uuid import uuid4
from src.database import get_connection


csv_file = Path(__file__).resolve().parents[2] / "data" / "incoming" / "products.csv"

def load_products(batch_id):

    with get_connection() as conn:
        with conn.cursor() as cur:

            cur.execute("""
            create temp table if not exists temp_products(
            product_id TEXT,
            product_name TEXT,
            category TEXT,
            unit_price TEXT,
            active TEXT
            ) on commit drop
            """)

            #Bulk load from source file to temp table
            with csv_file.open(mode='r', encoding='utf-8') as f:
                with cur.copy("""
                    copy temp_products(
                    product_id,
                    product_name,
                    category,
                    unit_price,
                    active
                    )
                    from stdin
                    with (format csv, header true)
                """) as copy:
                        while data := f.read(8192):
                            copy.write(data)
            
            cur.execute("""
                select count(*)
                from temp_products 
            """)
            temp_total_rows = cur.fetchone()[0]
            # Displaying total number of rows in temp table
            print(f"number of rows in temp table is: {temp_total_rows}")

            # Moving data from temp table to raw.prodcuts table
            cur.execute("""
                INSERT INTO raw.products(
                    product_id,
                    product_name,
                    category,
                    unit_price,
                    active,
                    batch_id,
                    source_file
                )
                select product_id,
                    product_name,
                    category,
                    unit_price,
                    active,
                    %s,
                    %s
                from temp_products
            """,(batch_id, csv_file.name))  

            cur.execute("""
            
                select count(*)
                from raw.products
                where batch_id = %s
            """,(batch_id,))

            product_total_rows = cur.fetchone()[0]
            print(f"total number of rows in raw.products is {product_total_rows}")

            if temp_total_rows != product_total_rows:
                 raise RuntimeError("number of rows are not match"
                    f"temp table contains:{temp_total_rows}"
                    f"raw.products contains{product_total_rows}"
                    )
    return product_total_rows



def main_load():

    # Checking whether the file exists in the path
    if not csv_file.exists():
        raise FileNotFoundError(f"source file in this path can not be found: {csv_file}")

    # Checking whether the same file has been loaded or not 
    hashed_file = calculate_file_hash(csv_file)
    if idempotency_check(hashed_file):
        print("This file has already been loaded in database...")
        return

    batch_id = uuid4()

    try:
        log_started(batch_id,csv_file.name,hashed_file)
        rows_loaded = load_products(batch_id)

    except Exception as e:
        log_failed(e,batch_id)
        raise
    
    else:
        log_success(batch_id,rows_loaded)
        print("Successfully loaded...")



if __name__ == "__main__":
    main_load()