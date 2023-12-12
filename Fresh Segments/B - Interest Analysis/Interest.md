
                                                                * Interest Analysis *

-- 1. Which interests have been present in all month_year dates in our dataset?
```
select count(distinct month_year) as distinct_month_year, 
count(distinct interest_id) as distinct_interest_id
from fresh_segments.interest_metrics;

with cte as (
select interest_id,
count(distinct month_year) as total_month
from fresh_segments.interest_metrics
group by interest_id
)
select total_month,
count(distinct interest_id) as common_interest_id
from cte
where total_month = 14
group by total_month
order by common_interest_id desc;
```
Output :=
![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/a1537fb2-051c-41fc-adef-d5b7e1fdde60)



-- 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
```
with cte_interest_month as (
select interest_id,
max(distinct month_year) as total_month
from fresh_segments.interest_metrics
group by interest_id
),
cte_interest_count as (
select total_month,
count(distinct interest_id) as interest_count
from cte_interest_month
group by total_month
)	
select total_month, interest_count,
round(100 * sum(interest_count) over(order by total_month desc) / 
	 sum(interest_count) over(), 2) as cumulative_perc
from cte_interest_count;
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/8b6cc479-0fd1-4b13-aab8-d826422c37fe)


-- 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

-- > getting interest ids which have month count less than 6
```
with month_counts as
(
select interest_id, count(distinct month_year) as month_count
from 
fresh_segments.interest_metrics
group by interest_id
having count(distinct month_year) < 6
)
select count(interest_id) as interest_record_to_remove
from fresh_segments.interest_metrics
where interest_id in (select interest_id from month_counts);

```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/413d11d2-c5ac-4a0c-abb9-d32231b5df99)


-- 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - 
-- think about what it means to have less months present from a segment perspective.
```
with month_counts as
(
select interest_id, count(distinct month_year) as month_count
from fresh_segments.interest_metrics
group by interest_id
having count(distinct month_year) < 6 
)
select removed.month_year, present_interest,removed_interest, 
round(removed_interest*100.0/(removed_interest+present_interest),2) as removed_prcnt
from
(
select month_year, count(*) as removed_interest
from fresh_segments.interest_metrics
where interest_id in (select interest_id from month_counts) 
group by month_year
) removed
inner join 
(
select month_year, count(*) as present_interest
from fresh_segments.interest_metrics
where interest_id not in (select interest_id from month_counts) 
group by month_year
) present
on removed.month_year= present.month_year
order by removed.month_year;
```
Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/05af452f-eb21-44c8-b7df-09459d26888e)


-- 5. After removing these interests - how many unique interests are there for each month?
```
with month_counts as
(
select interest_id, count(distinct month_year) as month_count
from fresh_segments.interest_metrics
group by interest_id
having count(distinct month_year) < 6 
)
select month_year, count(distinct interest_id) as unique_present_interest
from fresh_segments.interest_metrics
where interest_id not in (select interest_id from month_counts) 
group by month_year
order by 1
```

Output := 

![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/c9ed7814-982c-4b56-9700-c93b8e3817a0)

