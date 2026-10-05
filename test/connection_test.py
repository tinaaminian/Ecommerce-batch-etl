from src.database import get_connection

with get_connection() as conn:
    with conn.cursor() as cur:
        cur.execute("""
            select current_database(), current_user
        """)
        result = cur.fetchone()
        print(result)