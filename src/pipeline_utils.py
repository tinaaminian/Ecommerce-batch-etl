from src.database import get_connection
from pathlib import Path

def execute_sql_file(file_path):

    file_path = Path(file_path)
    if not file_path.exists():
        raise FileNotFoundError(f"SQL file not found {file_path}")

    print(f"Executing SQL file {file_path.name}")
    with get_connection() as conn:
        with conn.cursor() as cur:
            sql = file_path.read_text()
            cur.execute(sql)
    print(f"Completed SQL file: {file_path.name}")
