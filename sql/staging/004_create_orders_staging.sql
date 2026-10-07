create table if not exists staging.orders(
    order_id TEXT PRIMARY KEY,
    customer_id TEXT NOT NULL,
    product_id TEXT NOT NULL,
    order_date DATE NOT NULL,
    quantity INTEGER NOT NULL check(quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK(unit_price >= 0),
    order_status TEXT NOT NULL,
    source_batch_id UUID NOT NULL,
    source_file TEXT NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


with cleaned_orders as (
	select nullif(trim(order_id),'') as order_id,
	           nullif(trim(customer_id), '') as customer_id, 
	           nullif(trim(product_id), '' ) as product_id,
	           nullif(trim(order_date), '') as order_date,
	           nullif(trim(quantity), '' ) as quantity,
	           nullif(trim(unit_price), '') as unit_price,
	           nullif(lower(trim(order_status)), '' ) as order_status,
	           batch_id,
	           source_file, 
	           ingested_at 
	from raw.orders
),
type_casting as (
	select order_id,customer_id,product_id,
	case 
		when order_date ~ '^\d{4}-\d{2}-\d{2}$' then order_date::DATE 
		else null 
	end as order_date,
	
	case 
		when quantity ~ '^-?\d+$' then quantity::INTEGER
		else null
	end as quantity,
	
	case
		when unit_price ~ '^\d+(\.\d+)?$' then unit_price::NUMERIC(12,2)
		else null 
	end as unit_price,
	
	case 
		when order_status = 'complete' then 'completed'
		else order_status 
	end as order_status,
	batch_id,
	source_file,
	ingested_at
from cleaned_orders
),
deduplication as (
select *,
row_number() over(partition by order_id order by ingested_at desc) as ranked_orders
from type_casting
),
validated_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.product_id,
        o.order_date,
        o.quantity,
        o.unit_price,
        o.order_status,
        o.batch_id,
        o.source_file,
        o.ingested_at
    FROM deduplication o

    INNER JOIN staging.customers c
        ON o.customer_id = c.customer_id

    INNER JOIN staging.products p
        ON o.product_id = p.product_id

    WHERE o.ranked_orders = 1
      AND o.order_id IS NOT NULL
      AND o.customer_id IS NOT NULL
      AND o.product_id IS NOT NULL
      AND o.order_date IS NOT NULL
      AND o.quantity IS NOT NULL
      AND o.quantity > 0
      AND o.unit_price IS NOT NULL
      AND o.unit_price >= 0
      AND o.order_status IN (
          'completed',
          'shipped',
          'cancelled',
          'pending',
          'refunded'
      )
)
insert into staging.orders(
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    unit_price,
    order_status,
    source_batch_id,
    source_file
)
select order_id,
        customer_id,
        product_id,
        order_date,
        quantity,
        unit_price,
        order_status,
        batch_id,
        source_file
from validated_orders
on conflict(order_id)
do update set 
    customer_id = excluded.customer_id,
    product_id = excluded.product_id,
    order_date = excluded.order_date,
    quantity = excluded.quantity,
    unit_price = excluded.unit_price,
    order_status = excluded.order_status,
    source_batch_id = EXCLUDED.source_batch_id,
    source_file = excluded.source_file,
    processed_at = now();


