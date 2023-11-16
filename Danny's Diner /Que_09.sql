-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?
with cte as (
select product_id,
case when product_name='sushi' then price * 20
else price*10
end as points from menu 
)
select sales.customer_id, sum(cte.points) as points 
from cte inner join sales
on cte.product_id = sales.product_id
group by sales.customer_id
order by sales.customer_id;
