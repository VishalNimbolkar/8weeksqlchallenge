																					                                              --Pizza_Runner - C. Pricing and Ratings



-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?
with cte as(
select co.pizza_id, r.runner_id,
case when co.pizza_id = 1 then count(co.order_id)*12 
when co.pizza_id = 2 then count(co.order_id)*10 
end as money_
from pizza_runner.customer_orders co
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
inner join pizza_runner.runners r
on ro.runner_id = r.runner_id
where ro.cancellation = ''
group by 1,2
)
select sum(money_) as money_made from cte;



-- 2. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
with cte as(
select co.pizza_id, r.runner_id,
case 
when co.pizza_id = 1 and co.extras != '' then count(co.order_id)*12 + 1
when co.pizza_id = 1 then count(co.order_id)*12 
when co.pizza_id = 2 and co.extras != '' then count(co.order_id)*10 + 1
when co.pizza_id = 2 then count(co.order_id)*10 
end as money_made
from pizza_runner.customer_orders co
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
inner join pizza_runner.runners r
on ro.runner_id = r.runner_id
where ro.cancellation = ''
group by 1,2,co.extras
)
select sum(cte.money_made) as total_price
from cte;



-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - generate a schema for this new table and insert your 
-- own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS rating;
CREATE TABLE pizza_runner.rating (order_id INT NOT NULL, rating INT);
INSERT INTO pizza_runner.rating
VALUES
    (1, 4),
    (2, 5),
    (3, 3),
    (4, 1),
    (5, 5),
    (7, 2),
    (8, 4),
    (10, 2);
SELECT * FROM pizza_runner.rating;



-- 4. Using your newly generated table - can you join all of the information together to form a table 
-- which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
select co.customer_id, co.order_id, ro.runner_id, ra.rating, co.order_time, ro.pickup_time, 
(co.order_time - ro.pickup_time) as time_order_pickup,
ro.duration as duration,
round(avg(ro.distance * 1000 / ro.distance)) as avg_speed,
count(co.pizza_id) as num_pizza
from pizza_runner.customer_orders co 
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
inner join pizza_runner.runners r
on ro.runner_id = r.runner_id
inner join pizza_runner.rating ra
on co.order_id = ra.order_id
group by 1,2,3,4,5,6,ro.duration;



-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and 
-- each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after 
-- these deliveries?
with cte as(
select co.pizza_id, r.runner_id, ro.distance,
case when co.pizza_id = 1 then count(co.order_id)*12 - ro.distance*0.30
when co.pizza_id = 2 then count(co.order_id)*10 - ro.distance*0.30
end as money_maid
from pizza_runner.customer_orders co
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
inner join pizza_runner.runners r
on ro.runner_id = r.runner_id
where ro.cancellation = ''
group by 1,2,3
)
select sum(money_maid) as money_made from cte;



