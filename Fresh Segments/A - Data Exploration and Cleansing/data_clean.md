                                                      * Data Exploration and Cleansing *

-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be 
-- a date data type with the start of the month.
```
ALTER TABLE 
  fresh_segments.interest_metrics 
ALTER column 
  month_year type varchar(15);
  
  UPDATE 
  fresh_segments.interest_metrics
SET 
  month_year = TO_DATE(month_year, 'MM-YYYY');
  
  
 ALTER TABLE 
  fresh_segments.interest_metrics
ALTER 
  month_year TYPE DATE
USING 
  month_year::DATE;
    
 
SELECT * 
FROM 
  fresh_segments.interest_metrics 
ORDER BY 
  ranking 
LIMIT 5;
```
Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/c9d716a5-0268-49d8-a73b-3e4026a4018b)


-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
```
select month_year, count(*) as count_of_records 
from fresh_segments.interest_metrics
group by month_year
order by month_year nulls first;
```
Output := 
![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/3bdcf8e4-ce2e-4e49-9a67-1fa88659c044)


-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics

 -- > * we can delete records with null values *
 ```
select count(*) as aa 
from fresh_segments.interest_metrics 
where month_year is null;

delete from fresh_segments.interest_metrics 
where month_year is null;


select count(*) as aa 
from fresh_segments.interest_metrics 
where month_year is null;

select * from fresh_segments.interest_metrics;
```
Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/e3532bae-8d06-489b-91d6-d3bc43a0b358)


-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
```
select (
select 
count(interest_id) as metrics_id
from fresh_segments.interest_metrics
where interest_id::int not in (
select im.id
from fresh_segments.interest_metrics i inner join fresh_segments.interest_map im
on i.interest_id::int = im.id)
) as not_in_map,
(
select
count(id) as map_id
from fresh_segments.interest_map
where id not in (
select i.interest_id::int
from fresh_segments.interest_metrics i inner join fresh_segments.interest_map im
on i.interest_id::int = im.id)
) as not_in_matrics;
```
Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/226665f3-d50c-4bb6-b903-a9bfc0d0aaa0)


-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
```
with cte as (
select id, count(*) as count_check 
from fresh_segments.interest_map
group by id
)
select count_check,
count(*) as total_count
from cte
group by count_check;
```

Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/eacd203f-59a4-4ef3-a5cb-8124057e4173)


-- 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output 
-- and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

-- > * We perform inner join, to make sure interest ids present in both table are only used, as in maps table there are 7 more interests which are not present in metrics table. *
```
select _month, _year, interest_id, composition, index_value, ranking, percentile_ranking,
month_year, interest_name, interest_summary, created_at, last_modified
from fresh_segments.interest_metrics me 
inner join fresh_segments.interest_map m
on me.interest_id::int = m.id
where interest_id::int = 21246
and interest_id is not null;
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/60e29032-814d-46a3-ae9f-02a5b84d53f1)


-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

-- > * Yes these records are valid because both the dates have the same month and we set the date for the month_year column to be the first day of the month. *
```
select *
from fresh_segments.interest_metrics me 
inner join fresh_segments.interest_map m
on me.interest_id::int = m.id
where month_year < created_at and interest_id is not null
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/a1403901-91ac-4a0f-b2c3-ac462f8f54d2)



