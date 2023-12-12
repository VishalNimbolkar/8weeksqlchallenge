																					              --Pizza_Runner - C. Ingredient Optimisation


-- 1. What are the standard ingredients for each pizza?
select pn.pizza_name,string_agg(pt.topping_name,', ') as topping_names
from pizza_runner.pizza_recipes pr
inner join pizza_runner.pizza_toppings pt
on pt.topping_id = any(STRING_TO_ARRAY(pr.toppings, ', ')::int[])
inner join pizza_runner.pizza_names pn
on pr.pizza_id = pn.pizza_id
group by pn.pizza_name
order by pn.pizza_name;


-- 2. What was the most commonly added extra?
SELECT topping_name,
COUNT(extras) AS extras_counts
FROM pizza_runner.customer_orders te
JOIN pizza_runner.pizza_toppings pt ON 
pt.topping_id = any(STRING_TO_ARRAY(te.extras, ', ')::int[])
GROUP BY topping_name;



-- 3. What was the most common exclusion?
SELECT topping_name,
COUNT(exclusions) AS exlcusions_counts
FROM pizza_runner.customer_orders te
JOIN pizza_runner.pizza_toppings pt ON 
pt.topping_id = any(STRING_TO_ARRAY(te.exclusions, ', ')::int[])
GROUP BY topping_name;


-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

select co.order_id, co.pizza_id, pn.pizza_name,
co.exclusions, co.extras,
case 
when co.pizza_id = 1 and co.exclusions = '' and extras = '' then 'Meat Lovers'
when co.pizza_id = 2 and co.exclusions = '' and extras = '' then 'Vegeterian'
when co.pizza_id = 1 and co.exclusions = '3' and extras = '' then 'Meat Lovers - Exclude Beef'
when co.pizza_id = 1 and co.exclusions = '' and extras = '1' then 'Meat Lovers - Extra Bacon'
when co.pizza_id = 1 and co.exclusions = '1,4' and extras = '' then 'Meat Lovers - Exclude Cheese'
when co.pizza_id = 1 and co.exclusions = '' and extras = '6,9' then 'Meat Lovers - Extra Mushroom, Peppers'
when co.pizza_id = 1 and co.exclusions = '1,4' and extras = '6,9' then 'Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers'
end as order_item
from pizza_runner.customer_orders co
inner join pizza_runner.pizza_names pn
on co.pizza_id = pn.pizza_id;



-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
--from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
with cte as (
select pn.pizza_id as pizza_id, pn.pizza_name as pizza_name,
string_agg(pt.topping_name,', ') as topping_names
from pizza_runner.pizza_recipes pr
inner join pizza_runner.pizza_toppings pt
on pt.topping_id = any(STRING_TO_ARRAY(pr.toppings, ', ')::int[])
inner join pizza_runner.pizza_names pn
on pr.pizza_id = pn.pizza_id
group by pn.pizza_id, pn.pizza_name
--order by pn.pizza_name
)
select distinct co.order_id, cte.pizza_name, 
concat(cte.pizza_name, ':', ' ', '2x', ' ', cte.topping_names) as ingredient_list
from cte inner join pizza_runner.customer_orders co 
on cte.pizza_id = co.pizza_id;



-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
select co.pizza_id, pt.topping_name,
count(pt.topping_name) as ingredient_count
from pizza_runner.customer_orders co 
inner join pizza_runner.runner_orders ro
on co.order_id = ro.order_id
inner join pizza_runner.pizza_recipes pr
on co.pizza_id = pr.pizza_id
inner join pizza_runner.pizza_toppings pt
on pt.topping_id = any(STRING_TO_ARRAY(pr.toppings, ', ')::int[])
where ro.cancellation = ''
group by 1,2
order by 1,2;







