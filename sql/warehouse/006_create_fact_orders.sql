create table if not exists warehouse.fact_orders(
    order_id TEXT PRIMARY KEY,
    customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    date_key INTEGER NOT NULL,
    quantity INTEGER NOT NULL, 
    unit_price NUMERIC(12,2) NOT NULL,
    order_amount NUMERIC(12,2) NOT NULL,
    order_status TEXT NOT NULL,

    FOREIGN KEY(customer_key) REFERENCES warehouse.dim_customer(customer_key),
    FOREIGN KEY(product_key)  REFERENCES warehouse.dim_product(product_key),
    FOREIGN KEY(date_key)     REFERENCES warehouse.dim_date(date_key)
);

insert into warehouse.fact_orders(
    order_id,
    customer_key,
    product_key,
    date_key,
    quantity,
    unit_price,
    order_amount,
    order_status
)
select o.order_id,
	dc.customer_key,
	dp.product_key,
	dd.date_key,
	o.quantity,
	o.unit_price,
    (o.quantity  * o.unit_price ) as order_amount,
	o.order_status 
from staging.orders o 
join warehouse.dim_customer dc 
on o.customer_id = dc.customer_id 
join warehouse.dim_product dp 
on o.product_id = dp.product_id 
join warehouse.dim_date dd 
on o.order_date  = dd.full_date 

on conflict (order_id)
DO UPDATE SET 
    customer_key = EXCLUDED.customer_key,
    product_key = EXCLUDED.product_key,
    date_key = EXCLUDED.date_key,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    order_status = EXCLUDED.order_status;


