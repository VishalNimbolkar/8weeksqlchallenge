-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select distinct m.product_name, count(*) as most_purchased_count
from sales s inner join menu m
on s.product_id = m.product_id 
group by m.product_name
order by 2 desc 
limit 1;
