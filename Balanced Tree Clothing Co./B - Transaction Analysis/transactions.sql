
-- 1. How many unique transactions were there?
select count(distinct txn_id) from balanced_tree.sales



-- 2. What is the average unique products purchased in each transaction?
select round(avg(total_quality)) as avg_unique_products
from (
select txn_id, sum(qty) as total_quality 
from balanced_tree.sales
group by txn_id
) as total_quatities;



-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
with cte as (
select distinct txn_id,
sum(qty * price) as revenue_generated
from balanced_tree.sales
group by txn_id
)
select 
percentile_cont(0.25) within group(order by revenue_generated) as percentile_25th,
percentile_cont(0.5) within group(order by revenue_generated) as percentile_50th,
percentile_cont(0.75) within group(order by revenue_generated) as percentile_75th
from cte;



-- 4. What is the average discount value per transaction?
select round(avg(discount_generate)) as avg_discount
from (
select txn_id, 
sum(qty * price * discount/100) as discount_generate 
from balanced_tree.sales
group by txn_id
) as avg_discount_generated;


-- 5. What is the percentage split of all transactions for members vs non-members?
with cte as (
select member,
count(distinct txn_id) as transactions
from balanced_tree.sales
group by member
)
select member, transactions,
round(100 * transactions / (select sum(transactions) from cte)) as percentage
from cte
group by member, transactions;



-- 6. What is the average revenue for member transactions and non-member transactions?
with cte as (
select member, txn_id,
sum(qty * price) as revenue
from balanced_tree.sales
group by member, txn_id
)
select member, 
avg(revenue) as avg_revenue
from cte
group by member;
