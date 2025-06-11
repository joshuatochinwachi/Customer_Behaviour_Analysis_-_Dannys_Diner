create database dannys_diner;

use dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');




  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
---------Bonus question (join all the things together)
-- 11. Recreate the table output using the available data

---Source: https://8weeksqlchallenge.com/case-study-1 



SELECT * FROM sales;
SELECT * FROM menu;
SELECT * FROM members;


-- 1. What is the total amount each customer spent at the restaurant?

select 
	s.customer_id as customer,
	sum(m.price) as total_amount_spent
from sales s inner join menu m 
	on s.product_id = m.product_id
group by s.customer_id
;



-- 2. How many days has each customer visited the restaurant?

select
	customer_id as customer,
	count(distinct order_date) as days_visited
from sales
group by customer_id
;



-- 3. What was the first item from the menu purchased by each customer?

with full_data as (

	select 
		s.*,
		m.product_name,
		m.price,
		rank() over (partition by s.customer_id order by s.order_date asc) as rn
	from sales s inner join menu m
			on s.product_id = m.product_id

)

select 
	customer_id as customer,
	product_name as first_item_purchased
from full_data
where rn = 1
;

-------OR
---this one includes the first purchase date

with customer_first_purchase as (

	select
		customer_id,
		min(order_date) as first_purchase_date
	from sales 
	group by customer_id

)

select
	cfp.customer_id as customer,
	cfp.first_purchase_date,
	m.product_name as first_item_purchased
from customer_first_purchase cfp
	inner join sales s
		on s.customer_id = cfp.customer_id
			and cfp.first_purchase_date = s.order_date
	inner join menu m
		on m.product_id = s.product_id
;



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

---- a. most purchased item/product
with full_data as (

	select 
		s.*,
		m.product_name,
		m.price,
		row_number() over (partition by s.customer_id order by s.order_date asc) as rn
	from sales s inner join menu m
		on s.product_id = m.product_id 

)

select top 1 
	product_name,
	count(*) as number_of_purchases
from full_data
group by product_name
order by number_of_purchases desc;



---- b. most purchased item/product on the menu and number of times was it purchased by all customers
with full_data as (

	select 
		s.*,
		m.product_name,
		m.price,
		row_number() over (partition by s.customer_id order by s.order_date asc) as rn
	from sales s inner join menu m
		on s.product_id = m.product_id 

),

most_purchased_product as (

	select top 1 
		product_name,
		count(*) as number_of_purchases
	from full_data
	group by product_name
	order by number_of_purchases desc

)

select 
	fd.customer_id as customer,
	fd.product_name as most_purchased_product,
	count(*) as number_of_purchases
from full_data fd inner join most_purchased_product mpp
	on fd.product_name = mpp.product_name
group by fd.customer_id, fd.product_name
;



-- 5. Which item was the most popular for each customer?

with customer_popularity as (

	select
		s.customer_id,
		m.product_name,
		count(*) as purchase_count,
		dense_rank() over (partition by s.customer_id order by count(*) desc) as rnk
	from sales s inner join menu m 
		on s.product_id = m.product_id
	group by s.customer_id,	m.product_name

)

select
	customer_id as customer,
	product_name,
	purchase_count
from customer_popularity
where rnk = 1
;



-- 6. Which item was purchased first by the customer after they became a member?

with full_data as (

	select
		s.*,
		m.product_name,
		m.price,
		mb.join_date
	from sales s 
		join menu m
			on s.product_id = m.product_id
		left join members mb
			on s.customer_id = mb.customer_id
	where 1=1
		and mb.join_date is not null
		and s.order_date >= mb.join_date ----this ensures that the purchase is done after membership
	---customer C is obvioulsy not a member

),

ranked_data as (

	select
		*,
		rank() over (partition by customer_id order by join_date asc, order_date asc) as rn
	from full_data
)

select
	customer_id as customer,
	product_name as first_product_bought_after_becoming_members
from ranked_data
where rn=1
;

-------OR

with first_purchase_after_membership as (

	select
		s.customer_id,
		min(s.order_date) as first_purchase_date
	from sales s
		inner join members mb
			on s.customer_id = mb.customer_id
	where s.order_date >= mb.join_date
	group by s.customer_id

)

select
	fpam.customer_id as customer,
	m.product_name as first_product_bought_after_becoming_members
from first_purchase_after_membership fpam
	inner join sales s
		on s.customer_id = fpam.customer_id
			and fpam.first_purchase_date = s.order_date
	inner join menu m
		on s.product_id = m.product_id
;



-- 7. Which item was purchased just before the customer became a member?

with full_data as (

	select
		s.*,
		m.product_name,
		m.price,
		mb.join_date
	from sales s 
		join menu m
			on s.product_id = m.product_id
		left join members mb
			on s.customer_id = mb.customer_id
	where 1=1
		and mb.join_date is not null
		and s.order_date < mb.join_date ----this ensures that the purchase is done before membership

),

ranked_data as (

	select 
		*,
		rank() over (partition by customer_id order by order_date desc) as rnk
	from full_data

)

select 
	customer_id as customer,
	product_name as last_product_bought_before_becoming_members
from ranked_data
where rnk = 1
;

-------OR

with last_purchase_before_membership as (

	select
		s.customer_id,
		max(s.order_date) as last_purchase_date
	from sales s
		inner join members mb
			on s.customer_id = mb.customer_id
	where s.order_date < mb.join_date
	group by s.customer_id

)

select
	lpbm.customer_id as customer,
	m.product_name as last_product_bought_before_becoming_members
from last_purchase_before_membership lpbm
	inner join sales s
		on lpbm.customer_id = s.customer_id
			and lpbm.last_purchase_date = s.order_date
	inner join menu m
		on s.product_id = m.product_id
;



-- 8. What is the total items and amount spent for each member before they became a member?

with full_data as (

	select
		s.*,
		m.product_name,
		m.price,
		mb.join_date
	from sales s 
		join menu m
			on s.product_id = m.product_id
		left join members mb
			on s.customer_id = mb.customer_id
	where 1=1
		and mb.join_date is not null
		and s.order_date < mb.join_date ----this ensures that the purchase is done before membership

)

select
	customer_id as customer,
	count(product_name) as total_items_bought_before_membership,
	sum(price) as total_amount_spent_before_membership
from full_data
group by customer_id
;

-------OR

select
	s.customer_id as customer,
	count(*) as total_items_bought_before_membership,
	sum(m.price) as total_amount_spent_before_membership
from sales s
	inner join menu m
		on s.product_id = m.product_id
	inner join members mb
		on s.customer_id = mb.customer_id
where s.order_date < mb.join_date
group by s.customer_id
;



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with full_data as (

	select
		s.*,
		m.product_name,
		m.price,
		mb.join_date
	from sales s 
		left join menu m
			on s.product_id = m.product_id
		left join members mb
			on s.customer_id = mb.customer_id

),
---if sushi, then 20 points * price....if not sushi, then 10 points * price
customers_points as (

	select
		customer_id as customer,
		product_name,
		price as price_usd,
		case when product_name = 'sushi' then price * 20
			else price * 10 end as customer_points
	from full_data

)

select
	customer,
	sum(customer_points) as total_customer_points
from customers_points
group by customer
;

-------OR

select
	s.customer_id as customer,
	sum(case 
			when m.product_name = 'sushi' then m.price * 20
				else m.price * 10 end) as total_customer_points
from sales s
	inner join menu m
		on s.product_id = m.product_id
group by s.customer_id
;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select
	s.customer_id as customer,
	sum(case
			when s.order_date between mb.join_date and dateadd(day, 7, mb.join_date)  ---order_date >= dateadd(day, 7, join_date) --- is another option
				then m.price * 20
			when m.product_name = 'sushi'
				then m.price * 20
			else m.price * 10 end) as total_customer_points
from sales s
	inner join menu m
		on s.product_id = m.product_id
	left join members mb
		on s.customer_id = mb.customer_id
where s.customer_id in ('A', 'B')
	and s.order_date <= '2021-01-31'
group by s.customer_id
;



---Bonus question (join all the things together)
-- 11. Recreate the table output using the available data

with customers_data as (

	select 
		s.customer_id as customer, 
		s.order_date, 
		m.product_name, 
		m.price,
		case
			when s.order_date < mb.join_date then 'N'
			when s.order_date >= mb.join_date then 'Y'
			else 'N' 
			end as member
	from sales s
		left join members mb
			on s.customer_id = mb.customer_id
		inner join menu m
			on s.product_id = m.product_id

)

select 
	*, 
	case
		when member = 'N' then null
		else rank() over (partition by customer, member order by order_date) 
	end as ranking
from customers_data
order by customer, order_date
;