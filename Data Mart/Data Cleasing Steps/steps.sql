create table data_mart.clean_weekly_sales
(
week_date date,
week_number int,
month_number int,
calender_year int,
region varchar(50),
platform varchar(50),
segment varchar(50),
age_band varchar(50),
demographic varchar(50),
transactions int,
sales int,
avg_transaction float
);


insert into data_mart.clean_weekly_sales
(
week_date, week_number, month_number, calender_year, region,
platform, segment, age_band, demographic, transactions,sales,avg_transaction
)
select 
to_timestamp(week_date, 'YYYY-MM-DD') as week_date,
extract(week from to_timestamp(week_date, 'YYYY-MM-DD')) as week_number,
extract(month from to_timestamp(week_date, 'YYYY-MM-DD')) as month_number,
extract(year from to_timestamp(week_date, 'YYYY-MM-DD')) as calendar_year,
region, platform, segment, 
case 
when right (segment,1) = '1' then 'Young Adults'
when right (segment,1) = '2' then 'Middle Aged'
when right (segment,1) in ('3','4') then 'Retirees'
else 'Unknown' end as age_band,
case
when left(segment, 1) = 'C' then 'Couples'
when left(segment, 1) = 'F' then 'Families'
else 'Unknown' end as demographic, 
 transactions,sales,
round(sales/transactions,2) as avg_transaction
from data_mart.weekly_sales;


select * from data_mart.clean_weekly_sales;


