
-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
 
with cte as (
select week_date, week_number,
sum(sales) as total_sales
from data_mart.clean_weekly_sales
where (week_number between 21 and 28)
and calender_year = 2020
group by week_date, week_number
),
cte2 as (
select 
sum(case when week_number between 21 and 24 then total_sales end) as before_change,
sum(case when week_number between 25 and 28 then total_sales end) as after_change
from cte
)
select before_change,
after_change,
after_change - before_change as change_diff,
round(100 * (after_change - before_change)/before_change, 2) as percentage	
from cte2;




-- 2. What about the entire 12 weeks before and after?
with cte as (
select week_date, week_number,
sum(sales) as total_sales
from data_mart.clean_weekly_sales
where (week_number between 13 and 37)
and calender_year = 2020
group by week_date, week_number
),
cte2 as (
select 
sum(case when week_number between 13 and 24 then total_sales end) as before_change,
sum(case when week_number between 25 and 37 then total_sales end) as after_change
from cte
)
select before_change,
after_change,
after_change - before_change as change_diff,
round(100 * (after_change - before_change)/before_change, 2) as percentage	
from cte2;




-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
with cte as (
select calender_year, week_number,
sum(sales) as total_sales
from data_mart.clean_weekly_sales
where (week_number between 21 and 28)
group by calender_year, week_number
),
cte2 as (
select calender_year,
sum(case when week_number between 21 and 24 then total_sales end) as before_change,
sum(case when week_number between 25 and 28 then total_sales end) as after_change
from cte
group by calender_year
)
select calender_year,
before_change,
after_change,
after_change - before_change as change_diff,
round(100 * (after_change - before_change)/before_change, 2) as percentage	
from cte2;
