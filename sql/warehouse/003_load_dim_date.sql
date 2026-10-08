with generate_date as (
select calendar_date
from generate_series(
'2020-01-01'::DATE,
'2030-12-31'::DATE,
interval '1 day'
) as calendar(calendar_date)
)
insert into warehouse.dim_date(
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    day_of_week,
    day_name,
    is_weekend
)
select TO_CHAR(calendar_date,'YYYYMMDD' )::INTEGER as date_key,
		calendar_date::DATE as full_date,
		extract(YEAR from calendar_date)::INTEGER as year,
		extract(QUARTER from calendar_date)::INTEGER as quarter,
		extract(MONTH from calendar_date)::INTEGER as month,
		trim(TO_CHAR(calendar_date, 'Month')) as month_name,
		extract(day from calendar_date)::INTEGER as day,
		extract(ISODOW from calendar_date)::INTEGER as day_of_week,
		trim(TO_CHAR(calendar_date , 'day')) as day_name,
		extract(ISODOW from calendar_date) in (6,7) as is_weekend
from generate_date
on conflict 
Do nothing ;

