																								--Pizza_Runner - A. Runner and Customer Experience


-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
with cte as(
select row_number() over() as rnk,
extract(week from registration_date) as week,
count(*) as count_of_runners
from pizza_runner.runners
group by 2
)
select concat('week','-',rnk), count_of_runners from cte;



-- 2. What was the average time in minutes it took for each runner to 
--arrive at the Pizza Runner HQ to pickup the order?
with cte as(
select ro.order_id, ro.runner_id, co.order_time, ro.pickup_time as duration 
from pizza_runner.runner_orders ro
inner join pizza_runner.customer_orders co
on ro.order_id = co.order_id
where ro.cancellation is not null
)
SELECT runner_id,
ROUND(AVG(MINUTE(duration)),0) as avg_time
FROM cte
GROUP BY runner_id
ORDER BY runner_id;


--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH cte_pizza AS (
	SELECT
		tco.order_id,
		COUNT(tco.order_id) AS num_pizza,
        tco.order_time,
        tro.pickup_time,
        TIMEDIFF(tro.pickup_time, tco.order_time) AS duration
	FROM pizza_runner.runner_orders tro
    JOIN pizza_runner.customer_orders tco ON tco.order_id = tro.order_id
    WHERE tro.distance != 0
    GROUP BY tco.order_id)
SELECT
	num_pizza,
    minute(duration) AS avg_prepare_time
FROM cte_pizza
GROUP BY num_pizza;



--4. What was the average distance travelled for each customer?
select runner_id, round(avg(distance::int),2) as distance_travelled
from pizza_runner.runner_orders 
group by runner_id
order by runner_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH cte_times AS (
	SELECT 
		ro.order_id,
    timediff(co.order_date, ro.pickup_time) AS times
	FROM pizza_runner.runner_orders ro
    JOIN pizza_runner.customer_orders co ON ro.order_id = co.order_id
    WHERE ro.duration != " "
    GROUP BY ro.order_id)
SELECT
	MAX(minute(times)) - MIN(minute(times)) AS diff_times
FROM cte_times;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH cte_order AS (
	SELECT 
		order_id,
        COUNT(pizza_id) AS total_pizza
	FROM pizza_runner.customer_orders
    GROUP BY order_id)
SELECT
	ro.runner_id,
    ro.order_id,
    ro.distance,
    ro.duration,
    co.total_pizza,
    ROUND(60 * distance / duration, 1) AS speedKmH
FROM pizza_runner.runner_orders ro
JOIN cte_order co ON co.order_id = ro.order_id
WHERE distance != " "
GROUP BY ro.runner_id, ro.order_id
ORDER BY ro.order_id;


-- 7. What is the successful delivery percentage for each runner?
select runner_id,
COUNT(pickup_time) AS success_delivery,
COUNT(order_id) AS total_order,
COUNT(pickup_time)/COUNT(order_id)*100 AS perc_delivery
from pizza_runner.runner_orders 
group by runner_id
order by runner_id
