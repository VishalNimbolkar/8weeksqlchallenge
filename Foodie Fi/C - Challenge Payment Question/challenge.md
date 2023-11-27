The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

--> monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
--> upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
--> upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
--> once a customer churns they will no longer make payments

Solution -->

'''
CREATE TABLE payments_2020 AS
with cte as (
select s.customer_id, s.plan_id, p.plan_name, s.start_date, 
coalesce(lead(s.start_date, 1) over(partition by s.customer_id order by s.start_date, s.plan_id),'2020-12-31') as extracted_date,
p.price as amount
from subscriptions s inner join plans p
on p.plan_id = s.plan_id
where start_date <= '2020-12-31'
and p.plan_name not in ('trial', 'churn')
),
cte2 as (
select customer_id, plan_id, plan_name, start_date, extracted_date, amount from cte
union all 
select customer_id, plan_id, plan_name, 
date(start_date + INTERVAL '1 MONTH') as start_date,
extracted_date, amount from cte
where extracted_date > date(start_date + INTERVAL '1 MONTH') 
and plan_name <> 'pro annual'
),
cte3 as(
select *,
lag(plan_id, 1) over(partition by customer_id order by start_date) as last_payment_plan,
lag(amount, 1) over(partition by customer_id order by start_date) as last_amount_paid,
rank() over(partition by customer_id order by start_date) as payment_order
from cte2
order by customer_id, start_date
)
select customer_id, plan_id, plan_name, start_date as payment_date,
case when plan_id in (2,3) and last_payment_plan = 1 then amount - last_amount_paid
else amount
end as amount,
payment_order
from cte3;


select * from payments_2020;
'''

output -->

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/b9558320-04c4-4206-becc-d8baaf864543)

