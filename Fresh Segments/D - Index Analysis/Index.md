                                                                    * Index Analysis *

**The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.**

drop table if exists fresh_segments.index_table
with cte as (
select *
round((composition/index_value)::numeric, 2) as avg_composition
from fresh_segments.interest_metrics 
)
select * into fresh_segments.index_table from cte;



-- 1. What is the top 10 interests by the average composition for each month?
```
with cte as (
select i.interest_id, im.interest_name, i.month_year, i.avg_composition,
rank() over(partition by i.month_year order by i.avg_composition desc) as rnk
from fresh_segments.index_table i
inner join fresh_segments.interest_map im
on i.interest_id::int = im.id
)
select * from cte where rnk <= 10;
```

Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/db0d76da-a1be-46f1-8c10-648ed3a3015b)


-- 2. For all of these top 10 interests - which interest appears the most often?
```
with cte as (
select i.interest_id, im.interest_name, i.month_year, i.avg_composition,
rank() over(partition by i.month_year order by i.avg_composition desc) as rnk
from fresh_segments.index_table i
inner join fresh_segments.interest_map im
on i.interest_id::int = im.id
)
select interest_id, interest_name, 
count(*) over(partition by interest_name) as counts
from cte where rnk <= 10
order by counts desc;
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/f9b5d973-74a4-4070-be85-c94b8938bb9e)


-- 3. What is the average of the average composition for the top 10 interests for each month?
```
with cte as (
select i.interest_id, im.interest_name, i.month_year, i.avg_composition,
rank() over(partition by i.month_year order by i.avg_composition desc) as rnk
from fresh_segments.index_table i
inner join fresh_segments.interest_map im
on i.interest_id::int = im.id
)
select month_year,
round(avg(avg_composition),2) as avg_monthly_comp 
from cte where rnk <= 10
group by month_year;
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/fe9f16e3-1ee9-4d59-9451-f69c30860b91)


-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
```
select * from ( 
with ranking as (
select month_year, id, interest_name, avg_composition,
rank() over(partition by month_year order by avg_composition desc) as max_rank
from fresh_segments.interest_metrics as im
inner join fresh_segments.interest_map as m 
on m.id = im.interest_id::int,
LATERAL(select (composition / index_value)::numeric(10, 2) as avg_composition) ac
where month_year is not NULL 
and interest_id :: int in (
  select interest_id :: int
  from fresh_segments.interest_metrics
  group by 1
  having count(interest_id) > 5)
  group by 1,2,3,4)
select month_year, interest_name, avg_composition as max_index_composition,
(avg(avg_composition) over(order by month_year rows between 2 preceding and current row))::numeric(10, 2) as _3_month_moving_avg,
CONCAT(lag(interest_name) over(order by month_year),': ', lag(avg_composition) over(order by month_year)) as _1_month_ago,
CONCAT(lag(interest_name, 2) over(order by month_year),': ', lag(avg_composition, 2) over(order by month_year)) as _2_month_ago
from ranking
where max_rank = 1
) v
where month_year > '2018-08-01'
order by 1;
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/38fae3d8-f02e-4ec1-b354-cfae0ca41811)


-- 5. Provide a possible reason why the max average composition might change from month to month? 
-- Could it signal something is not quite right with the overall business model for Fresh Segments?

**I think that the users interests may have changed, and the users are less interested in some topics now if at all. Users "burnt out", and the index composition value has decreased. Maybe some users (or interests) need to be transferred to another segment. However, some interests keep high index_composition value, it possibly means that these topics are always in the users interest area. Another possible reason is seasonality.

To make the long story short, the company can ask themselves: are the fresh segments really fresh?**

