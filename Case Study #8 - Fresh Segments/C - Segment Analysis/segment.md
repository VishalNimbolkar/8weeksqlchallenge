                                                              * Segment Analysis *



-- 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, 
-- which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
-- Only use the maximum composition value for each interest but you must keep the corresponding month_year.
```
with cte as
(
select interest_id, 
count(distinct month_year) as month_count
select * from fresh_segments.interest_metrics
group by interest_id
having count(distinct month_year) >= 6 
)
select * into fresh_segments.filtered_table
from fresh_segments.interest_metrics
where interest_id in (select interest_id from cte);

select * from fresh_segments.filtered_table;

--For top 10 
select  
month_year,interest_id,interest_name, max(composition) as max_composition
from fresh_segments.filtered_table f 
inner join fresh_segments.interest_map ma 
on f.interest_id::int = ma.id
group by month_year,interest_id,interest_name
order by 4 desc
limit 10;

--For bottom 10 
select  
month_year,interest_id,interest_name, max(composition) as max_composition
from fresh_segments.filtered_table f 
inner join fresh_segments.interest_map ma 
on f.interest_id::int = ma.id
group by month_year,interest_id,interest_name
order by 4 asc
limit 10;
```
Output := 

-- A . Top 10 interests
![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/a670acdd-01cb-4e17-830a-e2a69fbac242)

-- B . Bottom 10 interests
![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/b4f961d2-436b-40ca-832b-8536e1ccd53f)



-- 2. Which 5 interests had the lowest average ranking value?
```
select interest_id, interest_name, 
avg(ranking) as avg_ranking
from fresh_segments.filtered_table f
inner join fresh_segments.interest_map im
on f.interest_id::int = im.id
group by interest_id, interest_name
order by avg_ranking
limit 5;
```
Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/c99de09c-9819-4cf2-b063-37d87cfa4c1d)


-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
```
select interest_id, interest_name, 
round(STDDEV_POP(percentile_ranking::int),2) as deviation_ranking
from fresh_segments.filtered_table f
inner join fresh_segments.interest_map im
on f.interest_id::int = im.id
group by interest_id, interest_name
order by deviation_ranking desc
limit 5;
```
Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/22736b5b-579f-46b9-8c66-bd6e4423ca5a)



-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? 
-- Can you describe what is happening for these 5 interests?
```
with interests as (
select interest_id, interest_name, 
round(STDDEV_POP(percentile_ranking::int),2) as deviation_ranking
from fresh_segments.filtered_table f
inner join fresh_segments.interest_map im
on f.interest_id::int = im.id
group by interest_id, interest_name
order by deviation_ranking desc
limit 5
),
percentile as (
select i.interest_id, i.interest_name, 
max(percentile_ranking) as max_percentile,
min(percentile_ranking) as min_percentile
from fresh_segments.filtered_table f
inner join interests i
on f.interest_id = i.interest_id
group by i.interest_id, i.interest_name
),
max_percentile as (
select p.interest_id, p.interest_name, 
month_year as max_year, max_percentile
from fresh_segments.filtered_table f
inner join percentile p 
on f.interest_id = p.interest_id
where p.max_percentile = f.percentile_ranking
),
min_percentile as (
select p.interest_id, p.interest_name,
month_year as min_year, min_percentile
from fresh_segments.filtered_table f
inner join percentile p 
on f.interest_id = p.interest_id
where p.min_percentile = f.percentile_ranking
)
select mini.interest_id, mini.interest_name,
mini.min_year, mini.min_percentile, 
maxi.max_year, maxi.max_percentile
from max_percentile maxi 
inner join min_percentile mini 
on maxi.interest_id= mini.interest_id
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/4420bda1-b953-4971-9609-26e773d55b87)




