-- 6. Which item was purchased first by the customer after they became a member?
with cte as (
SELECT members.customer_id, sales.product_id,
ROW_NUMBER() OVER(PARTITION BY members.customer_id ORDER BY sales.order_date) AS row_num
FROM dannys_diner.members
JOIN dannys_diner.sales
ON members.customer_id = sales.customer_id
AND sales.order_date > members.join_date
)
SELECT customer_id, product_name 
FROM cte JOIN dannys_diner.menu
ON cte.product_id = menu.product_id
WHERE row_num = 1 ORDER BY customer_id ASC;
