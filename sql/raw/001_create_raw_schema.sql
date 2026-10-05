-- Creating raw schema
create schema if not exists raw;

-- Creating raw.customers
create table if not exists raw.customers(
    customer_id TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    country TEXT,
    created_at TEXT,

    ingested_at TIMESTAMPTZ NOT NULL default now(),
    batch_id UUID NOT NULL, 
    source_file TEXT NOT NULL
);

-- Creating raw.products 
create table if not exists raw.products(
    product_id TEXT,
    product_name TEXT,
    category TEXT,
    unit_price TEXT,
    active TEXT ,

    ingested_at TIMESTAMPTZ NOT NULL default NOW(),
    batch_id UUID NOT NULL, 
    source_file TEXT NOT NULL
);

-- Creating raw.orders
create table if not exists raw.orders(
    order_id TEXT,
    customer_id TEXT, 
    product_id TEXT,
    order_date TEXT,
    quantity TEXT,
    unit_price TEXT,
    order_status TEXT,

    ingested_at TIMESTAMPTZ NOT NULL default NOW(),
    batch_id UUID NOT NULL,
    source_file TEXT NOT NULL

);

--Creating raw.ingestion_log
create table if not exists raw.ingestion_log(
    batch_id UUID PRIMARY KEY,
    source_file TEXT NOT NULL, 
    file_hash TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ , 
    status  TEXT NOT NULL check(status IN ('STARTED','SUCCESS','FAILED')),
    rows_loaded INTEGER,
    error_message TEXT
);