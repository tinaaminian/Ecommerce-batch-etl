import hashlib
from src.database import get_connection

# Calculating hash of the file content
def calculate_file_hash(file_path):
    sha256 = hashlib.sha256()

    with file_path.open(mode='rb') as f:
        while chunk := f.read(8192):
            sha256.update(chunk)
    return sha256.hexdigest()


# log STARTED
def log_started(batch_id,source_file,hashed_file):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                        """
                            INSERT INTO raw.ingestion_log(
                                batch_id,
                                source_file,
                                file_hash,
                                status,
                                rows_loaded
                            )
                            VALUES(%s,%s, %s,'STARTED',0)
                        """,(batch_id,source_file,hashed_file)
                        )


# log FAILED
def log_failed(error_message,batch_id):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE raw.ingestion_log
                SET completed_at = now(),
                status = 'FAILED',
                rows_loaded = 0 ,
                error_message = %s
                WHERE batch_id = %s
                """,(error_message,batch_id))

# log SUCCESS
def log_success(batch_id, rows_loaded):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                    UPDATE raw.ingestion_log
                    SET completed_at = now(),
                    status = 'SUCCESS',
                    rows_loaded = %s
                    WHERE batch_id = %s
                """,(rows_loaded,batch_id))

# Idempotency Check
def idempotency_check(file_hash):
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                select exists(
                    select 1
                    from raw.ingestion_log
                    where file_hash = %s   AND status = 'SUCCESS')
            """,(file_hash,))
            return cur.fetchone()[0]