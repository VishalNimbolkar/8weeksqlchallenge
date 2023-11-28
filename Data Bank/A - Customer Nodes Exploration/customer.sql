  																				              -- A - Customer Nodes Exploration
																				
																				

-- 1. How many unique nodes are there on the Data Bank system?
select count(distinct node_id) 
from data_bank.customer_nodes;



-- 2. What is the number of nodes per region?
select 
region_id, count(node_id) total_nodes
from data_bank.customer_nodes
group by region_id
order by region_id;



-- 3. How many customers are allocated to each region?
select 
cn.region_id, r.region_name,
count(distinct cn.customer_id) as allocated_customers
from data_bank.regions r 
inner join data_bank.customer_nodes cn
on r.region_id = cn.region_id
group by cn.region_id,r.region_name
order by cn.region_id;



-- 4. How many days on average are customers reallocated to a different node?
with cte as (
select 
avg(extract(day from age(end_date, start_date))) as average
from data_bank.customer_nodes
where end_date != '99991231'
)
select round(average) from cte;



-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
with cte as (
select 
cn.region_id, r.region_name,
age(cn.end_date, cn.start_date) as reallocation_days
from data_bank.regions r 
inner join data_bank.customer_nodes cn
on r.region_id = cn.region_id
where cn.end_date != '9999-12-31'
)
select distinct region_name,
(select percentile_cont(0.5) within group(order by reallocation_days) from cte as d where d.region_name = cte.region_name) as median,
(select percentile_cont(0.8) within group(order by reallocation_days) from cte as d where d.region_name = cte.region_name) as percentile_80th,
(select percentile_cont(0.95) within group(order by reallocation_days) from cte as d where d.region_name = cte.region_name) as percentile_90th
from cte;
