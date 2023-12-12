-- 7. Which item was purchased just before the customer became a member?
with cte as (
select s.customer_id, s.product_id,
row_number() over(partition by s.customer_id) as rnk
from sales s 
inner join members m
on s.customer_id = m.customer_id
where s.order_date < m.join_date
)
select cte.customer_id, menu.product_name
from cte inner join menu 
on cte.product_id = menu.product_id
where rnk=2
order by cte.customer_id;
