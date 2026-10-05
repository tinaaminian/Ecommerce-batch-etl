import psycopg
from src.config import (
    db_host,
    db_port,
    db_name,
    db_user,
    db_password,
    db_connect_timeout,
)

def get_connection():
    return psycopg.connect(
        host = db_host,
        port = db_port,
        dbname = db_name,
        user = db_user,
        password = db_password,
        connect_timeout = db_connect_timeout
    )



