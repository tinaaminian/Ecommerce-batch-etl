-- customer_id summary
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_count,
    COUNT(*) FILTER (WHERE TRIM(customer_id) = '') AS blank_count,
    COUNT(DISTINCT customer_id) AS distinct_customer_ids
FROM raw.customers;

-- Duplicate business keys after normalization
SELECT
    TRIM(customer_id) AS customer_id,
    COUNT(*) AS occurrence_count
FROM raw.customers
WHERE customer_id IS NOT NULL
GROUP BY TRIM(customer_id)
HAVING COUNT(*) > 1;

-- Leading/trailing whitespace
SELECT customer_id
FROM raw.customers
WHERE customer_id <> TRIM(customer_id);

-- first_name summary
SELECT count(*) as total_rows,
count(*) filter(where first_name is null) as null_count,
count(*) filter(where trim(first_name) = '') as blank_count,
count(*) filter(where trim(first_name) <> first_name) as space_count,
count(distinct trim(first_name)) as distinct_first_name
FROM raw.customers

-- last_name summary
SELECT count(*) as total_rows,
count(*) filter(where last_name is null) as null_count,
count(*) filter(where trim(last_name) = '') as blank_count,
count(*) filter(where trim(last_name) <> last_name) as space_count,
count(distinct trim(last_name)) as distinct_last_name
FROM raw.customers

-- email summary
SELECT count(*) as total_rows,
count(*) filter(where email is null) as null_count,
count(*) filter(where trim(email) = '') as blank_count,
count(*) filter(where trim(email) <> email) as space_count,
count(distinct lower(trim(email))) as distinct_last_name
FROM raw.customers

-- Duplicate email 
SELECT
    lower(TRIM(email)) AS email,
    COUNT(*) AS occurrence_count
FROM raw.customers
WHERE email IS NOT NULL
GROUP BY lower(TRIM(email))
HAVING COUNT(*) > 1;

-- country summary
SELECT count(*) as total_rows,
count(*) filter(where country is null) as null_count,
count(*) filter(where trim(country) = '') as blank_count,
count(*) filter(where lower(trim(country)) <> lower(country)) as space_count,
count(distinct lower(trim(country))) as distinct_county
FROM raw.customers

select lower(trim(country)), count(*)
from raw.customers 
group by lower(trim(country))


-- created_at summary
SELECT count(*) as total_rows,
count(*) filter(where created_at is null) as null_count,
count(*) filter(where trim(created_at) = '') as blank_count,
count(*) filter(where trim(created_at) <> created_at) as space_count
from raw.customers

-- checking invalid dates
select count(*)
from raw.customers 
where created_at is not null and
created_at ~ '^\d{4}-\d{2}-\d{2}$' and 
created_at::DATE > now()

-- checking validity
select created_at 
from raw.customers 
where created_at !~ '^\d{4}-\d{2}-\d{2}$'

