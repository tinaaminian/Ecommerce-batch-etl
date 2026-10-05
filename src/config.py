import os 
from dotenv import load_dotenv

load_dotenv()

db_host = os.getenv("POSTGRES_HOST")
db_port = int(os.getenv("POSTGRES_PORT"))
db_name = os.getenv("POSTGRES_DB")
db_user = os.getenv("POSTGRES_USER")
db_password = os.getenv("POSTGRES_PASSWORD")
db_connect_timeout = 5