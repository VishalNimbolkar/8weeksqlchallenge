																						 D -  Outside The Box Questions 





-- 1. How would you calculate the rate of growth for Foodie-Fi?
```
with cte as (
select extract(month from start_date) as mon,
count(customer_id) as num_customers
from subscriptions 
where plan_id = 0
group by 1
)
select 
row_number() over(order by mon) as rnk,
mon || ' - ' || '2020' as yr,
num_customers,
sum(num_customers) over(order by mon) num_customers_order
from cte;
```



-- 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
```
with cte as (	
select 
extract(month from payment_date) as mon,
round(sum(amount)) as paid_amount
from payments_2020
group by 1
order by 1
)
select
row_number() over(order by mon) as rnk,
mon || ' - ' || '2020' as pay_month_year,
paid_amount
from cte;
```


-- 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?

If we want to improve customer retention, we should focus more on after-purchase stage where encourage the customer 
to purchase more and dont let him/her to move to our competitors, in case there are. So we can work more on customer service, 
guarantee, and providing offers, especially to loyal customers. If we do these things well and get a good reputation, 
we can move to another stage, which is the stage of customer support (Advocacy phase). If the customer gets the product 
or service he/she needs well and obtains post-purchase service and other offers, this will not only encourage him/her to 
return to buy again, but also will make him/her a supporter of the company and work to promote our company in his/her surround.



-- 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?

We can ask many questions in this survey, but we shouldn't put too many questions in order to guarantee that the customer doesn't feel boring and fill out the survey.

A. We can ask about the reasons that prompted the customer to cancel the subscription, and the question consists of two parts, 
the first part is a multiple choice and the choices are the possible reasons for cancellation (such as prices, customer service, better service elsewhere), 
the second part is an open question which asks customer to add some details about the reason for cancellation.

B. Also, we can ask some questions through which we can know if the customer wants to re-subscribe again, such as: Do you want to continue receiving messages, 
advertisements or offers?, Or we can tell the customer that we will keep his/her information in case he/she wants to re-subscribe again.

C. Its important to put an open question which asks the customer to add some suggestions and comments to improve the provided services according to him/her.



-- 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?

The answer is Data, the first thing to start with if we want to reduce the churn rate is knowing our customers well, Why did they cancel their subscription 
or why they could cancel their subscription, what is the demographic information of customers through which we can classify our customers and deal with each category according to its habits, 
values and preferences. I believe that the first step to reducing the customer churn rate is to collect information about them, followed by the rest of the steps that depend heavily on it. 
Examples of the following steps include:

Proveding offers and discounts to customers, especially the most loyal ones and allocating offers to specific categories of customers.
improving post-purchase service and customer service. And focus on the groups most likely to be churned.
We can validate the effictivness of these ideas, if the churn rate reduces and thus we reach our goals.
