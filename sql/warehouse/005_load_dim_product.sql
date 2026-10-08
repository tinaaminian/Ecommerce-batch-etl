insert into warehouse.dim_product(
    product_id,
    product_name,
    category,
    unit_price,
    active
)
select  product_id,
        product_name,
        category,
        unit_price,
        active
from staging.products
on conflict (product_id)
DO UPDATE SET 
    product_name = excluded.product_name,
    category = excluded.category,
    unit_price = excluded.unit_price,
    active = excluded.active;