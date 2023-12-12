-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id,sum(mp.price) as total_amount 
from sales s
inner join menu mp 
on s.product_id = mp.product_id
group by s.customer_id
order by s.customer_id; 
