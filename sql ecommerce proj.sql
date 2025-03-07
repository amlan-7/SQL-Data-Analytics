-- Ecommerce sql --

drop table if exists ec;
create table ec  -- setting up the table
(
    CID int,  
    TID bigint primary key,  
    Gender varchar(10),
    Age_Group varchar(20),
    Purchase_Date timestamp with time zone,
    Product_Category varchar(50),
    Discount_Availed varchar(5),
    Discount_Name varchar(50),
    Discount_Amount float,
    Gross_Amount float,
    Net_Amount float,
    Purchase_Method varchar(20),
    Location varchar(50)
);

-- checking the data
select * from ec ; 

-- shape of the dataset
select 
      (select count(*) from ec) as total_rows,
      (select count(column_name) 
from information_schema.columns 
where table_name = 'ec') as total_columns;

--- DATA ANALYSIS ---

-- 1. Total (transactions + revenue)

select count(*) as total_transactions, 
       round(sum(cast(Net_Amount as numeric)),2) as total_revenue
from ec;

-- 2. Total discounts given & percentage of transactions with discounts

select round(sum(cast(Discount_Amount as numeric)), 2) as total_discounts,
       (count(*) filter (where Discount_Availed = 'Yes') * 100.0 / count(*)) as discount_percentage
from ec;

-- 3. Transactions per month

select 
      date_trunc('month', Purchase_Date) as month, 
      count(*) as total_transactions
from ec
group by month
order by total_transactions desc;

-- 4. Location by Sales (top 5)

select Location, round(sum(cast(Net_Amount as numeric)),2) as total_sales
from ec
group by Location
order by total_sales desc
limit 5;

-- 5. Highest average purchase value customers (show top 5)

select CID, 
       count(*) as total_transactions, 
       round(avg(cast(Net_Amount as numeric)), 2) as avg_transaction_value
FROM ec
group by CID
order by avg_transaction_value desc
limit 5;

-- 6. Peak purchase hours

select extract(hour from Purchase_Date) as purchase_hour, 
       count(*) as transaction_count
from ec
group by purchase_hour
order by transaction_count desc;

-- 7. Weekly sales trend

select to_char(Purchase_Date, 'Day') as day_of_week, 
       round(sum(cast(Net_Amount as numeric)),2) as total_sales
from ec
group by day_of_week
order by total_sales desc;

-- 8. Most popular product category in each location

with CategoryRank as 
    (
     select
           Location, 
           Product_Category, 
           count(*) as total_orders,
           rank() over (partition by Location order by count(*) desc) as category_rank
     from ec
     group by Location, Product_Category
	 order by total_orders desc
    )
select Location, Product_Category, total_orders
from CategoryRank
where category_rank = 1;

-- 9. Total revenue generated by each customer and rank them.

select CID, 
       count(*) as total_orders, 
       sum(Net_Amount) as total_revenue,
       rank() over (order by sum(Net_Amount) desc) as customer_rank
from ec
group by CID
order by total_revenue desc
limit 10;

-- 10. 3-month moving average of sales

with MonthlySales as 
(
 select
       date_trunc('month', Purchase_Date) as month, 
       round(sum(cast(Net_Amount as numeric)),2) as total_sales
       from ec
       group by month
)
select
      month, 
      total_sales,
      avg(total_sales) over (order by month rows between 2 preceding and current row) 
      as three_month_moving_avg
from MonthlySales
order by month;

-- 11. Customers who haven’t purchased in the last 3 months

select CID, 
       max(Purchase_Date) as last_purchase_date
       from ec
group by CID
having max(Purchase_Date) < now() - interval '3 months';

-- 12. Highest revenue by purchase method

select Purchase_Method, 
       round(sum(cast(Net_Amount as numeric)),2) as total_revenue
from ec
group by Purchase_Method
order by total_revenue desc
limit 1;

-- 13. Highest revenue by age group 

select 
	  Age_Group, 
      round(sum(cast(Net_Amount as numeric)),2) as total_revenue
from ec
group by Age_Group
order by total_revenue desc;

-- 14. Highest average discount product

select Product_Category, 
       round(avg(cast(Discount_Amount as numeric)), 2) as avg_discount
from ec
group by Product_Category 
order by avg_discount desc
limit 1;

-- 15. Gross amount monthly trend

select date_trunc('month', Purchase_Date) as month, 
       round(sum(cast(Gross_Amount as numeric)),2) as total_gross_amount
from ec
group by month
order by month asc;

-- end --


