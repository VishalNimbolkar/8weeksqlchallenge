																						
																						---- A - Customer Nodes Exploration
																						
																						

-- 1. What is the unique count and total amount for each transaction type?
select 
distinct txn_type,
count(*) count_of_txn,
sum(txn_amount) total_amount
from data_bank.customer_transactions
group by txn_type
order by count_of_txn;



-- 2. What is the average total historical deposit counts and amounts for all customers?
with cte as (
select
customer_id, txn_type,
count(case when txn_type = 'deposit' then 1 else 0 end) as count_of_txn,
sum(case when txn_type = 'deposit' then txn_amount end) as total_amount
from data_bank.customer_transactions
group by customer_id, txn_type
)
select 
txn_type,
round(avg(count_of_txn),3) as txn_average,
round(avg(total_amount),3) as amount_average
from cte
where txn_type = 'deposit'
group by txn_type;




-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase 
-- or 1 withdrawal in a single month?
with cte as (
select TO_CHAR(txn_date, 'Mon') AS month, customer_id,
count(case when txn_type = 'deposit' then 1 else 0 end) as deposit_cnt,
count(case when txn_type = 'purchase' then 1 else 0 end) as purchase_cnt,
count(case when txn_type = 'withdrawal' then 1 else 0 end) as withdrawal_cnt
from data_bank.customer_transactions
group by customer_id, month
)
select month, count(distinct customer_id) customers_count
from cte
where deposit_cnt > 1 and
(purchase_cnt > 1 or withdrawal_cnt > 1)
group by month
order by customers_count;



-- 4. What is the closing balance for each customer at the end of the month?
with cte as (
select customer_id,
extract(month from txn_date) as month,
sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, month 
order by customer_id
)
select 
customer_id, month, 
sum(amount) over(partition by customer_id order by month rows between unbounded preceding and current row) as last_date_amount
from cte
group by customer_id, month, amount
order by customer_id, month;



-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
with amount_cte as (
select customer_id,
extract(month from txn_date) as month,
sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, month 
order by customer_id
),
closing_bal as (
select 
customer_id, month, 
sum(amount) over(partition by customer_id order by month rows between unbounded preceding and current row) as closing_balance
from amount_cte
group by customer_id, month, amount
order by customer_id, month
),
per_inc as (
select customer_id, month, closing_balance,
100 *(closing_balance - lag(closing_balance) over(partition by customer_id order by	month))
   		 / nullif( lag(closing_balance) over(partition by customer_id order by	month), 2) as percentage_increase
from closing_bal
)
select 100 * count(distinct customer_id)/ (select count(distinct customer_id) 
from data_bank.customer_transactions)::float AS percentage_customer
FROM per_inc
WHERE percentage_increase > 5;
