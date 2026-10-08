from pathlib import Path
from src.ingestion.load_customers import main_load as load_customers
from src.ingestion.load_products import main_load as load_products
from src.ingestion.load_orders import main_load as load_orders
from src.pipeline_utils import execute_sql_file

# --------------------------------------------
# CONFIGURATION
#---------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parents[1] 
RWQ_SQL_DIR = PROJECT_ROOT /"sql"/ "raw"
STAGING_SQL_DIR = PROJECT_ROOT /"sql"/ "staging"
WAREHOUSE_SQL_DIR = PROJECT_ROOT /"sql"/ "warehouse"

#---------------------------------------------
# SQL execution order
#---------------------------------------------
STAGING_SQL_FILES=[
    "002_create_staging_schema.sql",
    "003_create_products_staging.sql",
    "004_create_orders_staging.sql",
    "005_rejected_orders_records.sql",
]

WAREHOUSE_SQL_FILES = [
    "001_create_warehouse_schema.sql",
    "002_create_dim_tables.sql",
    "003_load_dim_date.sql",
    "004_load_dim_customer.sql",
    "005_load_dim_product.sql",
    "006_create_fact_orders.sql",
]

#---------------------------------------------
# Pipeline stages
#---------------------------------------------
def run_pipeline():

    print("Initializing RAW layer...")
    # Initialize database object
    execute_sql_file(RWQ_SQL_DIR/ "001_create_raw_schema.sql")
    print("RAW layer initialized.")

    # Raw ingestion
    print("Starting RAW ingestion")

    print("Loading customers...")
    load_customers()

    print("Loading products...")
    load_products()

    print("Loading orders...")
    load_orders()

    print("RAW ingestion completed")

    # Staging layer
    print("starting STAGING layer...")
    for sql_file in STAGING_SQL_FILES:
        execute_sql_file(STAGING_SQL_DIR/sql_file)

    print("Staging layer completed.")

    # Warehouse layer 
    print("Stating warehouse...")
    for sql_file in WAREHOUSE_SQL_FILES:
        execute_sql_file(WAREHOUSE_SQL_DIR/sql_file)

    print("Warehouse layer completed.")
    

if __name__ == "__main__":
    run_pipeline()