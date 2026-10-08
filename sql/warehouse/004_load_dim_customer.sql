insert into warehouse.dim_customer(
    customer_id,
    first_name,
    last_name,
    email,
    country,
    created_at 
)
select customer_id,
    first_name,
    last_name,
    email,
    country,
    created_at 
from staging.customers
on conflict (customer_id)
DO UPDATE SET 
    first_name = excluded.first_name,
    last_name = excluded.last_name,
    email = excluded.email,
    country = excluded.country,
    created_at = excluded.created_at;
    