-- 3. What was the first item from the menu purchased by each customer?
with cte as(
select s.customer_id as customer_id, m.product_name as product_name, s.order_date,
dense_rank() over(partition by s.customer_id order by s.order_date) as rnk
from sales s inner join menu m
on s.product_id = m.product_id
)
select distinct customer_id, product_name from cte
where rnk=1;
