
-- relationship-level quality checks.
---------------- NULL:1 DUPLICATE:1 -------------------
-- raw.orders summary
select count(*) as total_rows,
count(*) filter(where order_id is null) as null_count,
count(*) filter(where trim(order_id) = '') as blank_count,
count(*) filter(where trim(order_id) <> order_id) as h_t_spaces,
count(distinct order_id) as distinct_count
from raw.orders;

-- product_id duplicate_detection
select count(*), trim(order_id)
from raw.orders 
where order_id is not null
group by trim(order_id) 
having count(*) > 1;

select * 
from raw.orders  
where order_id = 'O020';

-- ****************************************************** --

----------------NULL : 1  -------------------
-- customer_id summary
select count(*) as total_rows,
count(*) filter(where customer_id is null) as null_count,
count(*) filter(where trim(customer_id) = '') as blank_count,
count(*) filter(where trim(customer_id) <> customer_id) as h_t_spaces
from raw.orders;

-- which non-null customer-ids in orders do not exist in staging.customers?
select o.order_id,o.customer_id as order_customer, o.product_id,
c.customer_id as customer_customer, c.first_name, c.last_name
from raw.orders o 
left join staging.customers c 
on o.customer_id = c.customer_id 
where c.customer_id is null  and o.customer_id is not null
-- ****************************************************** --
---------------- NULL : 1  -------------------
-- product_id summary
select count(*) as total_rows,
count(*) filter(where product_id is null) as null_count,
count(*) filter(where trim(product_id) = '') as blank_count,
count(*) filter(where trim(product_id) <> product_id) as h_t_spaces
from raw.orders;

select o.order_id, o.customer_id,o.product_id as order_productid 
from raw.orders as o
left join staging.products as p
on o.product_id  = p.product_id 
where p.product_id is null and o.product_id is not null  
-- ****************************************************** --
---------------- INVALIDE_FORMAT : 1  -------------------
-- order_date summary
select count(*) as total_count,
count(*) filter(where order_date is null) as null_count,
count(*) filter(where trim(order_date) = '') as blank_count,
count(*) filter(where trim(order_date) !~ '^\d{4}-\d{2}-\d{2}$') as invalid_format
from raw.orders

-- ****************************************************** --
---------------- Having N/A and negative values  -------------------
-- quantity
select count(*) as total_rows,
count(*) filter(where quantity is null) as null_count,
count(*) filter(where trim(quantity) = '') as blank_count,
count(*) filter(where trim(quantity) <> quantity) as h_t_spaces,
count(*) filter(where trim(quantity) !~ '^-?\d+$') as invalid_format
from raw.orders

select trim(quantity) as quantity, count(*) as count 
from raw.orders 
group by trim(quantity)

--violating business rule
select trim(quantity)
from raw.orders 
where trim(quantity) ~ '^-?\d+$' and trim(quantity)::Integer <=0
-- ****************************************************** --
---------------- NULL : 1, INVALID_FORMAT:1  -------------------
-- unit_price summary--
select count(*) as total_rows,
count(*) filter(where unit_price is null) as null_count,
count(*) filter(where trim(unit_price) = '') as blank_count,
count(*) filter(where trim(unit_price) <> unit_price) as h_t_spaces,
count(*) filter(where trim(unit_price) !~ '^\d+(\.\d+)?$') as invalid_format
from raw.orders

-- ****************************************************** --
---------------- NULL : 1, INVALID_FORMAT:1  -------------------
-- order_status summary--
select count(*) as total_rows,
count(*) filter(where order_status is null) as null_count,
count(*) filter(where trim(order_status) = '') as blank_count,
count(*) filter(where trim(order_status) <> order_status) as h_t_spaces
from raw.orders

select count(*), lower(trim(order_status))
from raw.orders 
group by lower(trim(order_status))
