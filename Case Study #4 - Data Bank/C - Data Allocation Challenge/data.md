To test out a few different hypotheses - 
the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:



Option 1: data is allocated based off the amount of money at the end of the previous month

Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

Option 3: data is updated real-time

For this multi-part challenge question - 
you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

-- 1. running customer balance column that includes the impact each transaction
```
with cte as (
select customer_id,
txn_date,
sum(case when txn_type = 'deposit' then txn_amount else -txn_amount end) as amount
from data_bank.customer_transactions
group by customer_id, txn_date 
order by customer_id
)
select 
customer_id, txn_date, 
sum(amount) over(partition by customer_id order by txn_date rows between unbounded preceding and current row) as last_date_amount
from cte
group by customer_id, txn_date, amount
order by customer_id, txn_date;
```
output :


![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/53491d70-9da8-462c-8d88-fe2f81a1ebc3)





-- 2. customer balance at the end of each month
```
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
```
output : 


![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/7a61dcd1-dde9-4131-97a3-887ad6fa5595)




-- 3. minimum, average and maximum values of the running balance for each customer
```
with cte as (
select customer_id,
txn_date,
sum(case when txn_type = 'deposit' then txn_amount 
	when txn_type = 'purchase' then -txn_amount 
	when txn_type = 'withdrawal' then txn_amount 
	else 0 end) 
over (partition by customer_id order by txn_date rows between unbounded preceding and current row) as amount
from data_bank.customer_transactions
group by customer_id, txn_date, txn_type, txn_amount
order by customer_id
)
select 
customer_id, 
min(amount) as min_amount,
round(avg(amount),3) as avg_amount,
max(amount) as max_amount	
from cte
group by customer_id
order by customer_id;
```

output :


![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/85e3a83c-13bc-4b10-8fb4-43a87732eab5)

