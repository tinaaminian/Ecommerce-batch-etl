# Ecommerce Batch ETL Pipeline

A production-style batch ETL pipeline that processes e-commerce data from CSV files into a PostgreSQL data warehouse using Python and SQL.

## Overview

The project follows a layered data architecture:

**CSV Files → Raw → Staging → Data Warehouse**

- **Raw Layer:** Ingests source CSV files while preserving the original data and capturing ingestion metadata.
- **Staging Layer:** Cleans, validates, standardizes, deduplicates, and rejects invalid records.
- **Warehouse Layer:** Transforms validated data into a dimensional star schema optimized for analytics.
- **Pipeline Orchestration:** Python coordinates ingestion, transformations, and warehouse loading in dependency order.

## Key Features

- Python-based ETL pipeline orchestration
- PostgreSQL bulk data ingestion
- Raw, Staging, and Warehouse architecture
- File-hash based idempotency
- Batch and ingestion metadata tracking
- Transaction and error handling
- Data cleaning and type validation
- Duplicate detection and rejected-record handling
- Data quality checks and reconciliation
- Dimensional modeling with a star schema
- Surrogate keys and foreign-key relationships
- SCD Type 1 dimension loading
- Rerunnable ETL processes

## Data Warehouse Model

The warehouse uses a star schema consisting of:

- `dim_customer`
- `dim_product`
- `dim_date`
- `fact_orders`

The fact table stores order transactions and references the dimensions using warehouse surrogate keys.

## Technologies

- Python
- PostgreSQL
- SQL
- psycopg
- Docker
- Git / GitHub
