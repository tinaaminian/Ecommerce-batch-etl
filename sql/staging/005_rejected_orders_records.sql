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
rejected_orders AS (
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

        CASE
            WHEN o.order_id IS NULL
                THEN 'MISSING_ORDER_ID'

            WHEN o.customer_id IS NULL
                THEN 'MISSING_CUSTOMER_ID'

            WHEN o.product_id IS NULL
                THEN 'MISSING_PRODUCT_ID'

            WHEN o.order_date IS NULL
                THEN 'MISSING_ORDER_DATE'

            WHEN o.order_date !~ '^\d{4}-\d{2}-\d{2}$'
                THEN 'INVALID_ORDER_DATE'

            WHEN o.quantity IS NULL
                THEN 'MISSING_QUANTITY'

            WHEN o.quantity !~ '^-?\d+$'
                THEN 'INVALID_QUANTITY_FORMAT'

            WHEN o.quantity::INTEGER <= 0
                THEN 'QUANTITY_NOT_POSITIVE'

            WHEN o.unit_price IS NULL
                THEN 'MISSING_UNIT_PRICE'

            WHEN o.unit_price !~ '^\d+(\.\d+)?$'
                THEN 'INVALID_UNIT_PRICE'

            WHEN o.unit_price::NUMERIC(12,2) < 0
                THEN 'NEGATIVE_UNIT_PRICE'

            WHEN o.order_status IS NULL
                THEN 'MISSING_ORDER_STATUS'

            WHEN o.order_status NOT IN (
                'completed',
                'complete',
                'shipped',
                'cancelled',
                'pending',
                'refunded'
            )
                THEN 'INVALID_ORDER_STATUS'

            WHEN c.customer_id IS NULL
                THEN 'CUSTOMER_NOT_FOUND'

            WHEN p.product_id IS NULL
                THEN 'PRODUCT_NOT_FOUND'

        END AS rejection_reason

    FROM cleaned_orders o

    LEFT JOIN staging.customers c
        ON o.customer_id = c.customer_id

    LEFT JOIN staging.products p
        ON o.product_id = p.product_id
)
select * 
from rejected_orders