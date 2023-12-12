                                                          --Pizza_Runner - A. Pizza_Matrics



-- 1. How many pizzas were ordered?
select count(order_id) as pizza_counts from pizza_runner.customer_orders;


-- 2. How many unique customer orders were made?
select count(distinct order_id) as orders from pizza_runner.customer_orders;


-- 3. How many successful orders were delivered by each runner?
select runner_id, count(order_id) as successful_orders 
from pizza_runner.runner_orders
where cancellation = ''
group by runner_id;



-- 4. How many of each type of pizza was delivered?
select co.pizza_id, count(co.pizza_id) 
from pizza_runner.customer_orders co 
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
where ro.cancellation = ''
group by co.pizza_id
order by co.pizza_id;


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select co.customer_id, co.pizza_id, 
count(co.pizza_id) as pizza_ordered
from pizza_runner.customer_orders co 
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
where ro.cancellation = ''
group by co.customer_id, co.pizza_id
order by co.customer_id, co.pizza_id;


-- 6. What was the maximum number of pizzas delivered in a single order?
select distinct co.order_id as order_id, count(co.*) as orders
from pizza_runner.customer_orders co 
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
where ro.cancellation = ''
group by co.order_id
order by orders desc
limit 1;


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select co.customer_id,
sum(case when co.exclusions is not null and co.extras is not null then 1
	else 0 
	end) as customer_with_change,
sum( case when co.exclusions = '' and co.extras = '' then 1
	else 0 
	end) as customer_without_change
from pizza_runner.customer_orders co
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
where ro.distance is not null
group by co.customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras?
select co.order_id, count(co.pizza_id) from pizza_runner.customer_orders co 
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
where co.exclusions is not null and co.extras is not null
and ro.cancellation = ''
group by co.order_id;



-- 9. What was the total volume of pizzas ordered for each hour of the day?
select extract(hour from order_time)as hour_of_day, 
count(*) as pizza_volume
from pizza_runner.customer_orders
where order_time::varchar != ''
group by 1
order by 1;


-- 10. What was the volume of orders for each day of the week?
select 
CASE EXTRACT(DOW FROM order_time)
    WHEN 0 THEN 'Sunday'
    WHEN 1 THEN 'Monday'
    WHEN 2 THEN 'Tuesday'
    WHEN 3 THEN 'Wednesday'
    WHEN 4 THEN 'Thursday'
    WHEN 5 THEN 'Friday'
    WHEN 6 THEN 'Saturday'
END AS day_of_week,
count(*) as pizza_volume
from pizza_runner.customer_orders
where order_time::varchar != ''
group by 1
order by 1;
