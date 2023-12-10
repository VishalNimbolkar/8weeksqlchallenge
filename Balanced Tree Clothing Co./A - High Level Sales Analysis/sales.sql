-- 1. What was the total quantity sold for all products?
select pd.product_name, sum(s.qty) as quantity_sold
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.product_name;



-- 2. What is the total generated revenue for all products before discounts?
select pd.product_name, 
sum(s.qty) * sum(s.price) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.product_name;



-- 3. What was the total discount amount for all products?
select pd.product_name, 
sum(s.qty * s.price * s.discount/100) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.product_name;
