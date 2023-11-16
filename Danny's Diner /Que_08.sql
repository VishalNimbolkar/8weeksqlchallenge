-- 8. What is the total items and amount spent for each member before they became a member?
with cte as (
select s.customer_id,s.product_id,
row_number() over(partition by s.customer_id)
from sales s 
inner join members m
on s.customer_id = m.customer_id
where s.order_date < m.join_date
)
select cte.customer_id, count(menu.product_name) as total_item, sum(menu.price) as amount_spent
from cte 
inner join menu
on cte.product_id = menu.product_id
group by cte.customer_id
order by cte.customer_id;
