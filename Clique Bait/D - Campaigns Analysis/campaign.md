                                                                    * Campaigns Analysis *


Generate a table that has 1 single row for every unique visit_id record and has the following columns:

> user_id
> 
> visit_id
> 
> visit_start_time: the earliest event_time for each visit
> 
> page_views: count of page views for each visit
> 
> cart_adds: count of product cart add events for each visit
> 
> purchase: 1/0 flag if a purchase event exists for each visit
> 
> campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
> 
> impression: count of ad impressions for each visit
> 
> click: count of ad clicks for each visit
> 
> (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart
> (hint: use the sequence_number)


```
create table clique_bait.campaign_analysis
(
user_id int,
visit_id varchar(20),
visit_start_time timestamp,
page_views int,
cart_adds int,
purchase int,
impressions int, 
click int, 
Campaign varchar(200),
cart_products varchar(200)
);

with cte as(
select distinct visit_id, user_id,min(event_time) as visit_start_time,count(e.page_id) as page_views, 
sum(case when event_name='Add to Cart' then 1 else 0 end) as cart_adds,
sum(case when event_name='Purchase' then 1 else 0 end) as purchase,
sum(case when event_name='Ad Impression' then 1 else 0 end) as impressions,
sum(case when event_name='Ad Click' then 1 else 0 end) as click,
case
when min(event_time) > '2020-01-01 00:00:00' and min(event_time) < '2020-01-14 00:00:00'
		then 'BOGOF - Fishing For Compliments'
when min(event_time) > '2020-01-15 00:00:00' and min(event_time) < '2020-01-28 00:00:00'
		then '25% Off - Living The Lux Life'
when min(event_time) > '2020-02-01 00:00:00' and min(event_time) < '2020-03-31 00:00:00'
		then 'Half Off - Treat Your Shellf(ish)' 
else NULL
end as Campaign,
string_agg(case when product_id IS NOT NULL AND event_name='Add to Cart'
			then page_name ELSE NULL END, ', ') AS cart_products
from clique_bait.events e 
inner join clique_bait.event_identifier ei
on e.event_type=ei.event_type  
inner join clique_bait.users u
on u.cookie_id=e.cookie_id 
inner join clique_bait.page_hierarchy ph 
on e.page_id = ph.page_id
group by visit_id, user_id
)


insert into clique_bait.campaign_analysis 
(user_id, visit_id, visit_start_time, page_views, cart_adds, purchase, impressions, click, Campaign, cart_products)
select user_id,visit_id, visit_start_time, page_views, cart_adds, purchase, impressions, click, Campaign, cart_products
from cte;

-- select * from clique_bait.campaign_analysis
```

Output := 


![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/aec2b6c4-b100-4f2b-8a0d-3c95cd8abca7)
