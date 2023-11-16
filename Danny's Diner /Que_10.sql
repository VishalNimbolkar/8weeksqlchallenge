-- 10. In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with cte as (
select customer_id, join_date, join_date + 6 AS valid_date, 
DATE_TRUNC('month', '2021-01-31'::DATE) + interval '1 month' - interval '1 day' AS last_date
FROM members	
)
select cte.customer_id,
sum(
case when menu.product_name = 'sushi' then menu.price*2*10
when sales.order_date between cte.join_date and cte.valid_date then menu.price*2*10
else menu.price*10
end) as points
from cte inner join sales
ON sales.customer_id = cte.customer_id and sales.order_date <= cte.last_date
inner join menu 
on sales.product_id = menu.product_id 
group by cte.customer_id;
