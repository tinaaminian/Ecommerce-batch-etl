create table if not exists staging.products(
product_id TEXT PRIMARY KEY,
product_name TEXT NOT NULL,
category TEXT NOT NULL,
unit_price NUMERIC(12,2),
active BOOLEAN ,
source_batch_id UUID NOT NULL,
source_file TEXT NOT NULL,
processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


with cleaned_products as (
select nullif(trim(product_id),'') as product_id,
       nullif(trim(product_name),'') as product_name,
       nullif(lower(trim(category)),'') as category,
       nullif(trim(unit_price),'') as unit_price,
       nullif(lower(trim(active)),'') as active,
       ingested_at,
       batch_id,
       source_file
from raw.products
),
cleaned_products_price as (
select product_id,product_name,category,
	case 
		when unit_price ~ '^\d+(\.\d+)?$' then unit_price::numeric(12,2)
		else null
	end as unit_price,
	case 
		when active in ('true', 'false') then active::Boolean
		else null
	end as active,
	
	 ingested_at,
	 batch_id,
	 source_file
from cleaned_products
),
cleaned_duplicate_detection as (
select product_id,product_name,category,unit_price,active,ingested_at,
	 batch_id,
	 source_file,
	 row_number() over(partition by product_id order by ingested_at desc) as ranked_product
from cleaned_products_price
where product_id  is not null
)
insert into staging.products(
product_id,
product_name,
category,
unit_price,
active,
source_batch_id ,
source_file 
)
select product_id,
product_name,
category,
unit_price,
active, batch_id,
source_file
from cleaned_duplicate_detection
where ranked_product = 1

on conflict (product_id)
do update set 
	product_name = excluded.product_name,
	category= excluded.category,
	unit_price = excluded.unit_price,
	active = excluded.active,
	source_batch_id = EXCLUDED.source_batch_id,
	source_file = EXCLUDED.source_file,
	processed_at = now();

 