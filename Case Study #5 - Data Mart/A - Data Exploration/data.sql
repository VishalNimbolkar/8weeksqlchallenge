																				-- A - Data Exploration
																				
																				
-- 1. What day of the week is used for each week_date value?
select to_char(week_date, 'day') 
from data_mart.clean_weekly_sales;



-- 2. What range of week numbers are missing from the dataset?
with cte as (
select *, 
dense_rank() over(order by week_number) as week_num
from data_mart.clean_weekly_sales
)
select 52 - count(distinct week_num) missing_week_count
from cte;



-- 3. How many total transactions were there for each year in the dataset?
select 
calender_year,
sum(transactions) as sum_occured
from data_mart.clean_weekly_sales
group by calender_year
order by calender_year;



-- 4. What is the total sales for each region for each month?
select month_number, region,
sum(sales)
from data_mart.clean_weekly_sales
group by month_number,region
order by month_number,region;



-- 5. What is the total count of transactions for each platform
select platform,
count(transactions)
from data_mart.clean_weekly_sales
group by platform
order by platform;



-- 6. What is the percentage of sales for Retail vs Shopify for each month?
with cte as (
select calender_year, month_number,
sum(case when platform='Retail' then cast(sales as bigint) end) as Retail,
sum(case when platform='Shopify' then cast(sales as bigint) end) as Shopify,
sum(cast(sales as bigint))as total_sale
from data_mart.clean_weekly_sales
group by calender_year,month_number
)
select calender_year,month_number,
round((Retail * 100.0 / total_sale)::numeric, 2) AS retail_percent,
round((Shopify * 100.0 / total_sale)::numeric, 2) AS shopify_percent
from cte
order by 1,2



-- 7. What is the percentage of sales by demographic for each year in the dataset?
with cte as (
select calender_year, 
sum(case when demographic='Families' then cast(sales as bigint) end) as family_demo,
sum(case when demographic='Couples' then cast(sales as bigint) end) as couples_demo,
sum(case when demographic='Unknown' then cast(sales as bigint) end) as unknown_demo,
sum(cast(sales as bigint))as total_sale
from data_mart.clean_weekly_sales
group by calender_year
)
select calender_year,
round((family_demo * 100.0 / total_sale)::numeric, 2) AS family_demo_sales,
round((couples_demo * 100.0 / total_sale)::numeric, 2) AS couples_demo_sales,
round((unknown_demo * 100.0 / total_sale)::numeric, 2) AS unknown_demo_sales
from cte
order by 1;



-- 8. Which age_band and demographic values contribute the most to Retail sales?
select age_band, demographic,sum(sales),
ROUND(
  (SUM(sales) * 100.0) /
  (SELECT SUM(sales) FROM data_mart.clean_weekly_sales WHERE platform='Retail'),
  2
) as percent_sales
from data_mart.clean_weekly_sales
where platform='Retail'
group by age_band, demographic
order by 3 desc;


-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
-- If not - how would you calculate it instead?
with tranx as(
select calender_year,
sum(case when platform='Retail' then transactions end) as retail_tranx_sum,
sum(case when platform='Shopify' then transactions end) as shopify_tranx_sum,
sum(case when platform='Retail' then  cast(sales as bigint) end) as retail_sales_sum,
sum(case when platform='Shopify' then cast(sales as bigint) end) as shopify_sales_sum
from data_mart.clean_weekly_sales
group by calender_year)
select calender_year,
round(cast(avg(retail_sales_sum * 100.0 / retail_tranx_sum) as numeric),2) as retail_avg,
round(cast(avg(shopify_sales_sum * 100.0 / shopify_tranx_sum) as numeric),2) as shopify_avg
from tranx
group by calender_year
order by 1



