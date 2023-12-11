                                                          *  Product Analyst  *
                                                          
![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/c5d014b0-f851-4daa-99a0-5e42bb6d34ca | width="200" height="400")



-- 1. What are the top 3 products by total revenue before discount?
```
select pd.product_id, pd.product_name,
sum(s.qty) * sum(s.price) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.product_id, pd.product_name
order by total_revenue desc
limit 3;
```

Output := 


![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/29b41d89-4772-4f64-8c15-c32ff78a8d7e)



-- 2. What is the total quantity, revenue and discount for each segment?
```
select pd.segment_id, pd.segment_name,
sum(s.qty) as total_quantity,
sum(s.qty * s.price) as total_revenue,
sum(s.qty * s.price * s.discount/100) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.segment_id, pd.segment_name
order by total_quantity desc;
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/aa9df03d-c721-4b3f-8c7a-77079434ba69)


-- 3. What is the top selling product for each segment?
```
with cte as (
select pd.segment_id, pd.segment_name,
pd.product_id, pd.product_name,
sum(s.qty) as quatity,
rank() over(partition by pd.segment_id order by sum(s.qty) desc) as rnk
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.segment_id, pd.segment_name, pd.product_id, pd.product_name
)
select segment_id, segment_name , 
product_id, product_name, quatity
from cte where rnk = 1;
```
Output : = 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/e0d2738c-e928-4795-981b-9a96f07fe510)


-- 4. What is the total quantity, revenue and discount for each category?
```
select pd.category_id, pd.category_name,
sum(s.qty) as total_quantity,
sum(s.qty * s.price) as total_revenue,
sum(s.qty * s.price * s.discount/100) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.category_id, pd.category_name
order by total_quantity desc;
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/3981f118-f942-4202-9e2d-517767d3af23)



-- 5. What is the top selling product for each category?
```
with cte as (
select pd.category_id, pd.category_name,
pd.product_id, pd.product_name,
sum(s.qty) as quatity,
rank() over(partition by pd.category_id order by sum(s.qty) desc) as rnk
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.category_id, pd.category_name, pd.product_id, pd.product_name
)
select category_id, category_name, 
product_id, product_name, quatity
from cte where rnk = 1;
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/137bb049-d011-40cd-9c14-e11f0aef0b7b)



-- 6. What is the percentage split of revenue by product for each segment?
```
with cte as (
select pd.segment_id, pd.segment_name,
pd.product_id, pd.product_name,
sum(s.qty * s.price) as revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.segment_id, pd.segment_name, pd.product_id, pd.product_name
)
select segment_name, product_name,
100 * revenue / sum(revenue) over(partition by segment_id) as seg_prod_prec
from cte
order by segment_id, seg_prod_prec desc;
```
Output:= 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/f42412d4-4e4b-4ba7-ab09-d51f78b2ea8d)


-- 7. What is the percentage split of revenue by product for each category?
```
with cte as (
select pd.category_id, pd.category_name,
pd.product_id, pd.product_name,
sum(s.qty * s.price) as revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.category_id, pd.category_name, pd.product_id, pd.product_name
)
select category_name, product_name,
100 * revenue / sum(revenue) over(partition by category_id) as seg_prod_prec
from cte
order by category_id, seg_prod_prec desc;
```

Output:= 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/11d0f005-bdca-4cad-b674-d6f71a2ce2ad)


-- 8. What is the percentage split of total revenue by category?
```
select 
round(100 * sum(case when pd.category_id = 1 then (s.qty * s.price) end) /
	 sum(s.qty * s.price), 2) as category_1,
(100 - round(100 * sum(case when pd.category_id = 1 then (s.qty * s.price) end) /
	 sum(s.qty * s.price), 2)) as category_2
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id;
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/a5c0fdf3-7340-41a5-8eab-2bbdf962d76c)



-- 9. What is the total transaction “penetration” for each product? 
-- (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by 
-- total number of transactions)
```

with prod_txn as (
select prod_id,
count(distinct txn_id) as prod_txn
from balanced_tree.sales 
group by prod_id
),
total_txn as (
select
count(distinct txn_id) as total_txn
from balanced_tree.sales 
)
select pd.product_id, pd.product_name,
round(100 * prod_txn.prod_txn / total_txn.total_txn, 2) as penetration
from prod_txn cross join total_txn
inner join balanced_tree.product_details pd
on prod_txn.prod_id = pd.product_id
order by penetration desc;
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/da801615-bddf-44dc-96a9-debdf10375dd)



-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
```
select s.prod_id, t1.prod_id, t2.prod_id, 
count(*) as combination_cnt       
from balanced_tree.sales s
join balanced_tree.sales t1 on t1.txn_id = s.txn_id 
and s.prod_id < t1.prod_id
join balanced_tree.sales t2 on t2.txn_id = s.txn_id
and t1.prod_id < t2.prod_id
group by 1, 2, 3
order by 4 desc;
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/32962e10-95cf-4817-a3db-59c4e90f22a4)
