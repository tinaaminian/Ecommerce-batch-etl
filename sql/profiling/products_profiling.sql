select * 
from raw.products

---------------- NULL:1 DUPLICATE:1 -------------------
-- product_id summary
select count(*) as total_rows,
count(*) filter(where product_id is null) as null_count,
count(*) filter(where trim(product_id) = '') as blank_count,
count(*) filter(where trim(product_id) <> product_id) as h_t_spaces,
count(distinct product_id) as distinct_count
from raw.products;

-- product_id duplicate_detection
select count(*), trim(product_id)
from raw.products p 
where p.product_id is not null
group by trim(p.product_id) 
having count(*) > 1;

select * 
from raw.products p 
where product_id = 'P005';

-- ****************************************************** --

---------------- HEADING/TRAILING SPACE : 1  -------------------
-- product_name summary
select count(*) as total_rows,
count(*) filter(where product_name is null) as null_count,
count(*) filter(where trim(product_name) = '') as blank_count,
count(*) filter(where trim(product_name) <> product_name) as h_t_spaces
from raw.products;

-- ****************************************************** --

---------------- HEADING/TRAILING SPACE : 1  -------------------
-- category summary
select count(*) as total_rows,
count(*) filter(where category is null) as null_count,
count(*) filter(where trim(category) = '') as blank_count,
count(*) filter(where trim(category) <> category) as h_t_spaces
from raw.products;

select count(*), lower(trim(category))
from raw.products p 
group by lower(trim(category));

-- ****************************************************** --

---------------- INVALIDE_PRICE_FORMAT : 1  -------------------
-- unit_price summary
select count(*) as total_rows,
count(*) filter(where unit_price is null) as null_count,
count(*) filter(where trim(unit_price) = '') as blank_count,
count(*) filter(where trim(unit_price) <> unit_price) as h_t_spaces,
count(*) filter(where trim(unit_price) !~ '^\d+(\.\d+)?$') as invalid_price_format
from raw.products

-- ****************************************************** --
---------------- NULL : 1, false,True,true  -------------------
-- active summary--
select count(*) as total_rows,
count(*) filter(where active is null) as null_count,
count(*) filter(where trim(active) = '') as blank_count,
count(*) filter(where trim(active) <> active) as h_t_spaces
from raw.products

select count(*), lower(trim(active))
from raw.products p 
group by lower(trim(active))