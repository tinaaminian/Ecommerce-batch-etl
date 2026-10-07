create schema if not exists staging;

create table if not exists staging.customers (
    customer_id TEXT PRIMARY KEY,
    first_name TEXT ,
    last_name TEXT,
    email TEXT, 
    country TEXT,
    created_at DATE,
    source_batch_id UUID NOT NULL,
    source_file TEXT NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);



with cleaned_customers as(
select
	nullif(trim(customer_id),'') as customer_id,
	nullif(trim(first_name),'') as first_name,
	nullif(trim(last_name), '') as last_name,
	nullif(lower(trim(email)),'') as email,
	nullif(initcap(lower(trim(country))),'') as country,
	nullif(trim(created_at),'') as created_at,
	ingested_at,
	batch_id,
	source_file
from raw.customers c 	
),
date_conversion as (
select customer_id , first_name , last_name , email,country,
case 
	when created_at ~ '^\d{4}-\d{2}-\d{2}$' and 
		 created_at::DATE <= current_date then created_at::DATE 
	else null
end as created_at,
ingested_at,
batch_id,
source_file
from cleaned_customers
),
identify_duplicate_customers as (
select *, row_number() over(partition by customer_id order by ingested_at desc) as ranked_version
from date_conversion
where customer_id IS NOT NULL
),
deduplication_customers as (
select *
from identify_duplicate_customers
where ranked_version = 1
)
insert into staging.customers (
customer_id,
first_name,
last_name,
email,
country,
created_at,
source_batch_id,
source_file
)
select customer_id,first_name,last_name,email,country,created_at,batch_id,source_file
from deduplication_customers
on conflict (customer_id)
do update set
	first_name = excluded.first_name,
	last_name = excluded.last_name,
	email = excluded.email,
	country = excluded.country,
	created_at = excluded.created_at,
	source_batch_id = excluded.source_batch_id,
	source_file = excluded.source_file,
	processed_at = now();
	

