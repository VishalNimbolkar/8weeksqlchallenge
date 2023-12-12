                                                              -- Product Funnel Analysis


Using a single SQL query - create a new output table which has the following details:


> How many times was each product viewed?
> 
> How many times was each product added to cart?
> 
> How many times was each product added to a cart but not purchased (abandoned)?
> 
> How many times was each product purchased? 
> 

```
drop table if exists clique_bait.product_tab
create table clique_bait.product_tab
(
page_name varchar(50),
page_views int,
cart_adds int,
cart_add_not_purchase int,
cart_add_purchase int
);


with tab1 as (
select e.visit_id, ph.page_name,
sum(case when event_name='Page View' then 1 else 0 end)as view_count,
sum(case when event_name='Add to Cart' then 1 else 0 end)as cart_adds
from clique_bait.events e
inner join clique_bait.event_identifier ei
on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph
on e.page_id = ph.page_id
where ph.product_id is not null
group by e.visit_id, ph.page_name
),
tab2 as (
select distinct e.visit_id as purchase_id
from clique_bait.events e
inner join clique_bait.event_identifier ei
on e.event_type = ei.event_type
where ei.event_name = 'Purchase'
),
tab3 as(
select *, 
(case when purchase_id is not null then 1 else 0 end) as purchase
from tab1 left join tab2
on visit_id = purchase_id
),
tab4 as(
select page_name, sum(view_count) as Page_Views, sum(cart_adds) as Cart_Adds, 
sum(case when cart_adds = 1 and purchase = 0 then 1 else 0
	end) as Cart_Add_Not_Purchase,
sum(case when cart_adds= 1 and purchase = 1 then 1 else 0
	end) as Cart_Add_Purchase
from tab3
group by page_name
)
--select * from tab4;

--select * from clique_bait.product_tab

insert into clique_bait.product_tab
(page_name ,page_views ,cart_adds ,cart_add_not_purchase ,cart_add_purchase )
select page_name, page_views, cart_adds, cart_add_not_purchase, cart_add_purchase
from tab4;

--select * from clique_bait.product_tab

```

Output :=


![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/99f5909c-dda1-4f0f-95b6-9b1292cb01c0)


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*
Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:


> Which product had the most views, cart adds and purchases?
> 
> Which product was most likely to be abandoned?
> 
> Which product had the highest view to purchase percentage?
> 
> What is the average conversion rate from view to cart add?
> 
> What is the average conversion rate from cart add to purchase?
> 


```
drop table if exists clique_bait.product_category_tab
create table clique_bait.product_category_tab
(product_category varchar(50),
page_views int,
cart_adds int ,
cart_add_not_purchase int,
cart_add_purchase int );


with tab1 as (
select e.visit_id, ph.product_category, ph.page_name,
sum(case when event_name='Page View' then 1 else 0 end)as view_count,
sum(case when event_name='Add to Cart' then 1 else 0 end)as cart_adds
from clique_bait.events e
inner join clique_bait.event_identifier ei
on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph
on e.page_id = ph.page_id
where ph.product_id is not null
group by e.visit_id, ph.product_category, ph.page_name
),
tab2 as (
select distinct e.visit_id as purchase_id
from clique_bait.events e
inner join clique_bait.event_identifier ei
on e.event_type = ei.event_type
where ei.event_name = 'Purchase'
),
tab3 as(
select *, 
(case when purchase_id is not null then 1 else 0 end) as purchase
from tab1 left join tab2
on visit_id = purchase_id
)--select * from tab3
,
tab4 as(
select product_category, sum(view_count) as Page_Views, sum(cart_adds) as Cart_Adds, 
sum(case when cart_adds = 1 and purchase = 0 then 1 else 0
	end) as Cart_Add_Not_Purchase,
sum(case when cart_adds= 1 and purchase = 1 then 1 else 0
	end) as Cart_Add_Purchase
from tab3
group by product_category
)
--select * from tab4;


insert into clique_bait.product_category_tab
(product_category,page_views ,cart_adds ,cart_add_not_purchase ,cart_add_purchase )
select product_category, page_views, cart_adds, cart_add_not_purchase, cart_add_purchase
from tab4
--select * from clique_bait.product_category_tab
```

Output :=


![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/4198c41d-611b-4248-b823-a183853e5aed)
