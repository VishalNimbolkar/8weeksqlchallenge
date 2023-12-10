
-- 1. How many unique transactions were there?
```
select count(distinct txn_id) from balanced_tree.sales
```

Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/110b9320-9870-455a-a88f-b26522864a3e)



-- 2. What is the average unique products purchased in each transaction?
```
select round(avg(total_quality)) as avg_unique_products
from (
select txn_id, sum(qty) as total_quality 
from balanced_tree.sales
group by txn_id
) as total_quatities;
````

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/65a2072d-64ed-4e6e-86c2-06772eb48fc4)

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
```
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
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/4051cac6-eb9a-426e-a636-816f911e6b58)



-- 4. What is the average discount value per transaction?
```
select round(avg(discount_generate)) as avg_discount
from (
select txn_id, 
sum(qty * price * discount/100) as discount_generate 
from balanced_tree.sales
group by txn_id
) as avg_discount_generated;
```

Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/64203532-8c07-4c8f-91ce-527c5295a592)


-- 5. What is the percentage split of all transactions for members vs non-members?
```
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
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/6922e246-6b24-4d46-b8d7-e3babda10ff9)



-- 6. What is the average revenue for member transactions and non-member transactions?
```
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
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/4110c128-578e-4a67-be4f-68801f61da90)
