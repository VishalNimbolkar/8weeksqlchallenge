                                                      -- Customers Journey


Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.


**Answer:**
```
select s.customer_id, p.plan_name, s.start_date 
from plans p inner join subscriptions s
on p.plan_id = s.plan_id
where s.customer_id='6';
```

We can take a look on the Customer 6's journey :
![image](https://github.com/VishalNimbolkar/8weeksqlchallenge/assets/80448632/e128e596-a845-4a51-9463-25b8876fd168)

Here we can see that the customer 6's journey starts with the trial on 2020-12-23, and when the trial ends they upgrade to the basic monthly plan on 2020-12-30. After a couple of month they churn the subscriptions on 2021-02-26.
