																		                      	-- B -  Data Analysis Questions
																			
																			
																			
-- 1. how many customers has Foodie-Fi ever had?

select count(distinct customer_id) total_customers 
from subscriptions;



-- 2. What is the monthly distribution of trial plan start_date values for our dataset - 
-- use the start of the month as the group by value

select start_date, extract(month from start_date) as months,
count(*) total_customers
from subscriptions
where plan_id = 0
group by start_date
order by start_date



-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name

select p.plan_name, p.plan_id, count(s.customer_id) from plans p
inner join subscriptions s
on p.plan_id = s.plan_id
where s.start_date > '2020-12-31'
group by p.plan_name, p.plan_id
order by p.plan_id;


-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select count(distinct customer_id), 
round(count(*)*100 / (select count(distinct customer_id)from subscriptions),1)
from subscriptions
where plan_id = 4;


-- 5. How many customers have churned straight after their initial free trial - 
-- what percentage is this rounded to the nearest whole number?

WITH cte_churn AS (
	SELECT
		*,
		LAG(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS prev_plan
	FROM subscriptions)
SELECT
	COUNT(prev_plan) AS cnt_churn,
    	ROUND(COUNT(*) * 100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),0) AS perc_churn
FROM cte_churn
WHERE plan_id = 4 and prev_plan = 0;



-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH next_plan AS (
	SELECT
		*,
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
	FROM subscriptions)
SELECT
	COUNT(next_plan) AS cnt_churn,
    	ROUND(COUNT(*) * 100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_next_plan
FROM next_plan
WHERE plan_id = 0 and plan_id is not null
GROUP BY next_plan
ORDER BY next_plan;



-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH cte_next_date AS (
	SELECT
		*,
		LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_date
	FROM subscriptions
	where start_date = '2020-12-31')
SELECT
	plan_id,
	count(*) as num_customer,
    ROUND(count(*) * 100/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_customer
FROM cte_next_date
GROUP BY plan_id
ORDER BY plan_id;



-- 8. How many customers have upgraded to an annual plan in 2020?
select count(*) as total_customers
from subscriptions
where plan_id = 3
and start_date <= '2020-12-31';



-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with initial_plan as ( 
select distinct customer_id, start_date from subscriptions where plan_id = 0
),
annual_plan as ( 
select distinct customer_id, start_date from subscriptions where plan_id = 3
)
select initial_plan.customer_id,
ROUND(AVG(annual_plan.start_date::date - initial_plan.start_date::date),0) AS avg_upgrade
from initial_plan inner join annual_plan
on initial_plan.customer_id = annual_plan.customer_id
group by initial_plan.customer_id
order by initial_plan.customer_id;



-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with initial_plan as ( 
select distinct customer_id, start_date from subscriptions where plan_id = 0
),
annual_plan as ( 
select distinct customer_id, start_date from subscriptions where plan_id = 3
),
day_period as (
select annual_plan.start_date::date - initial_plan.start_date::date AS avg_upgrade
from initial_plan left join annual_plan
on initial_plan.customer_id = annual_plan.customer_id
where annual_plan.start_date is not null
),
date_breakdown as (
select *, floor(avg_upgrade/30) as breakdown_part
from day_period
)
select concat((breakdown_part * 30) + 1, ' - ', (breakdown_part + 1) * 30, ' days ') AS days,
count(avg_upgrade) as total
from date_breakdown
group by breakdown_part;



-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH next_plan AS (
	SELECT 
		*,
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) AS plan
	FROM subscriptions)
SELECT
	COUNT(DISTINCT customer_id) AS num_downgrade
FROM next_plan np
LEFT JOIN plans p ON p.plan_id = np.plan_id
WHERE p.plan_name = 'pro monthly' AND np.plan = 1 AND start_date <= '2020-12-31';


