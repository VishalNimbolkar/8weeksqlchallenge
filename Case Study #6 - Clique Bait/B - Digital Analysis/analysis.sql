																						--  B - Digital Analysis



-- 1. How many users are there?
select count(*) from clique_bait.users;


-- 2. How many cookies does each user have on average?
with cte as (
select user_id, count(cookie_id) as cookies
from clique_bait.users 
group by user_id
)
select round(sum(cookies)::numeric/count(user_id),2)
as avg_cookies
from cte;	

-- 3. What is the unique number of visits by all users per month?
select 
extract (month from event_time) as month,
TO_CHAR (event_time, 'Month') AS Month_Name,
count(distinct visit_id) as Visits
from clique_bait.events
group by 1,2
order by 1;


-- 4. What is the number of events for each event type?
select  
distinct e.event_type, ei.event_name,
count(*) as total_events
from clique_bait.events e 
inner join clique_bait.event_identifier ei
on e.event_type=ei.event_type
group by e.event_type, ei.event_name
order by 1;


-- 5. What is the percentage of visits which have a purchase event?
select 
round(count(distinct visit_id)*100.0/(select count(distinct visit_id) from clique_bait.events e ) ,2) as purchase_prcnt
from clique_bait.events e 
inner join clique_bait.event_identifier ei
on e.event_type = ei.event_type
where event_name='Purchase';


-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
with abc as(
select  distinct visit_id,
sum(case when event_name!='Purchase'and page_id=12 then 1 else 0 end) as checkouts,
sum(case when event_name='Purchase' then 1 else 0 end) as purchases
from
clique_bait.events e join clique_bait.event_identifier ei
on e.event_type=ei.event_type
group by visit_id
)
select sum(checkouts) as total_checkouts,sum(purchases) as total_purchases,
100-round(sum(purchases)*100.0/sum(checkouts),2) as prcnt
from abc;



-- 7. What are the top 3 pages by number of views?
select ph.page_name,
count(*) as views_count
from clique_bait.events e 
inner join clique_bait.page_hierarchy ph
on e.page_id = ph.page_id
group by 1
order by 2 desc
limit 3;


-- 8. What is the number of views and cart adds for each product category?
select p.product_category,
sum(case when event_name='Page View' then 1 else 0 end) as views_count,
sum(case when event_name='Add to Cart' then 1 else 0 end) as cart_adds
from clique_bait.events e 
inner join clique_bait.event_identifier ei   
on e.event_type=ei.event_type 
inner join clique_bait.page_hierarchy p
on p.page_id=e.page_id
where p.product_category is not null
group by p.product_category



-- 9. What are the top 3 products by purchases?
select distinct ph.product_category,ei.event_name,
count(*) as products_count
from clique_bait.events e
inner join clique_bait.event_identifier ei
on e.event_type = ei.event_type
inner join clique_bait.page_hierarchy ph
on e.page_id = ph.page_id
where ei.event_name = 'Purchase'
group by 1,2
order by 3 desc;


