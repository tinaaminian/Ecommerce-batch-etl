from src.database import get_connection
from src.ingestion.utils import calculate_file_hash, log_started,log_failed,log_success,idempotency_check
from pathlib import Path
from uuid import uuid4

csv_file = Path(__file__).resolve().parents[2] / "data" / "incoming" / "customers.csv"
source_file = csv_file.name



def load_customers(batch_id):

    # Open connection
    with get_connection() as conn:
        with conn.cursor() as cur:
            
            # Creating a temp table 
            cur.execute("""
                create temp table if not exists temp_customers(
                    customer_id TEXT,
                    first_name TEXT,
                    last_name TEXT,
                    email TEXT, 
                    country TEXT,
                    created_at TEXT
                ) on commit drop;
            """)
            #Bulk load from source file to temp table
            with csv_file.open('r', encoding='utf-8') as f:
                with cur.copy("""
                    copy temp_customers(
                    customer_id,
                    first_name,
                    last_name,
                    email,
                    country,
                    created_at)
                    from stdin
                    with (format csv, header true)
                """) as copy:
                    while data:= f.read(8192):
                        copy.write(data)
            
            cur.execute("""
                select count(*)
                from temp_customers
            """)   
            temp_total_rows = cur.fetchone()[0]  

            # displaying total number of rows in temp table
            print(f"number of rows in temp table is: {temp_total_rows}")  

            #moving data from temp table to raw.customers table
            cur.execute("""
                INSERT INTO raw.customers(
                        customer_id,
                        first_name,
                        last_name,
                        email,
                        country,
                        created_at,

                        batch_id, 
                        source_file
                )
                select 
                        customer_id,
                        first_name,
                        last_name,
                        email,
                        country,
                        created_at,
                        %s, %s
                from temp_customers 
            """,(batch_id,source_file))

            cur.execute("""
                select count(*) 
                from raw.customers
                where batch_id = %s
            """,(batch_id,))

            customers_total_rows = cur.fetchone()[0]

            print(f"total number of rows in raw.customers is {customers_total_rows}")

            if temp_total_rows != customers_total_rows:
                 raise RuntimeError("number of rows are not match"
                    f"temp table contains:{temp_total_rows}"
                    f"raw.customer contains{customers_total_rows}"
                    )
    return customers_total_rows


def main_load():

    # Checking file existance
    if not csv_file.exists():
        raise FileNotFoundError(f"file does not exist: {csv_file}")

    # Calculating hash for this file
    hashed_file = calculate_file_hash(csv_file)
       

    idempotency_result = idempotency_check(hashed_file)
    if idempotency_result:
        print('this file has already been loaded in database...')
        return

    batch_id = uuid4()

    try:
        
        log_started(batch_id,source_file,hashed_file)
        rows_loaded = load_customers(batch_id)
    
    except Exception as e:
        log_failed(str(e),batch_id)
        print(e)
        raise

    else:
        log_success(batch_id,rows_loaded) 
        print("load completed successfully")





if __name__ == "__main__":
    main_load()
