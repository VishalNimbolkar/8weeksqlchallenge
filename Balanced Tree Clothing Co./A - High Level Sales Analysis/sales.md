-- 1. What was the total quantity sold for all products?
```
select pd.product_name, sum(s.qty) as quantity_sold
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.product_name;
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/dec8fee4-8190-4807-ab2c-0a4b57b9038b)



-- 2. What is the total generated revenue for all products before discounts?
```
select pd.product_name, 
sum(s.qty) * sum(s.price) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.product_name;
```

Output :=

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/10d4e7df-905e-4b9d-9390-253c8bf3de28)



-- 3. What was the total discount amount for all products?
```
select pd.product_name, 
sum(s.qty * s.price * s.discount/100) as total_revenue
from balanced_tree.sales s
inner join balanced_tree.product_details pd
on s.prod_id = pd.product_id
group by pd.product_name;
```

Output := 
![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/d576cb5b-220f-400b-8b31-fc40478a019b)


