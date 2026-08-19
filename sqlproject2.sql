
select * from public.customer limit 20

--Q1.what was the total revenue genarated by the male vs female?
select gender,
sum(purchase_amount)as revenue
from customer
group by gender

--Q2.which customer used discount but still spent more than the average amount?
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (
      SELECT AVG(purchase_amount)
      FROM customer
  );
--Q3.which are the top 5 products with highest average review rating.
select item_purchased, round(avg(review_rating::numeric),2) as avg_product_rating
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

-->Q4.COMPARE THE AVERAGE PURCHASE AMOUNT BETWEEN STANDERD AND EXPRESS SHIPPING
SELECT shipping_type,
       AVG(purchase_amount) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

--->Q5.DO SUBSCRIBED CUSTOMER SPEND MORE ? COMPARE AVERAGE SPEND AND TOTAL REVENUE BETWEEN SUBSCRIBERS AND NON SUBSCRIBERS.
SELECT subscription_status,
count(customer_id) as total_customer,
round(avg(purchase_amount),2)as avg_spend,
round(sum(purchase_amount),2)as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc

--> Q6.WHICH 5 PRODUCTS HAVE THE HIGHEST PERCENTAGE OF PURCHASES WITH DISCOUNT APPLIED?
SELECT item_purchased,
round(100 * sum(case when discount_applied ='Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased 
order by discount_rate desc
limit 5

--->Q7.SEGMENT CUSTOMERS INTO NEW , RETURNING , AND LOYAL  BASED ON THEIR TOTAL NUMBER OF PREVIOUS PURCHASES ,
---AND SHOW THE COUNT OF EACH SEGMENT?
WITH customer_type as 
(
select customer_id, previous_purchases,
case 
      when previous_purchases = 1 then 'new'
	  when previous_purchases between 2 and 10  then 'returning'
	  else 'loyal'
	  end as customer_segment
from customer
)
select customer_segment, count (*) as "no_of_customers"
from customer_type
group by customer_segment

--->Q8.WHAT ARE TOP 3 MOST PURCHASED PRODUCTS WITHIN EACH CATEGORY?
WITH item_counts as (
select category, item_purchased,
count(customer_id) as total_orders,
row_number() over (partition by category order by count(customer_id) desc ) as item_rank
from customer
group by category, item_purchased
)
select item_rank,item_purchased,total_orders
from item_counts
where item_rank <=3

--->Q9. ARE CUSTOMERS WHO ARE REPEAT BUYERS(MORE THEN 5 PREVIOUS PURCHASES) ALSO LIKELY TO SUBSCRIBE?
select subscription_status,
count(customer_id)as repeat_buyers
from customer
where previous_purchases >5
group by subscription_status

--->Q10.WHAT IS THE REVENUE CONTRIBUTION OF EACH AGE GROUP?
select age_group,
sum(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc