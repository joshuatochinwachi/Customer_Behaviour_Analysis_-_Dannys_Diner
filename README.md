# **Danny's Diner: Customer Behavior Analysis Using SQL**  

## **Project Overview**  
This project analyzes customer transaction data from **Danny’s Diner** to uncover spending habits, visiting patterns, and menu preferences. Using **SQL**, I extracted insights to help Danny improve customer experience and optimize his loyalty program. This project and the data used was part of a case study which can be found [here](https://8weeksqlchallenge.com/case-study-1/).

## **Project Objectives**  
- Analyze **customer spending** and favorite menu items.  
- Track **visiting patterns** (frequency, first/last orders).  
- Evaluate **loyalty program performance** through reward points.  
- Provide **actionable recommendations** for business growth.  

## **Data Used**  
Three key tables:  
1. **`sales`** (customer orders: `customer_id`, `order_date`, `product_id`)  
2. **`menu`** (menu items: `product_id`, `product_name`, `price`)  
3. **`members`** (loyalty program sign-ups: `customer_id`, `join_date`)  

### Sales Table
| customer_id | order_date | product_id |
|-------------|------------|------------|
|      A      | 2021-01-01 |      1     |
|      A      | 2021-01-01 |      2     |
|      A      | 2021-01-07 |      2     |
|      A      | 2021-01-10 |      3     |
|      A      | 2021-01-11 |      3     |
|      A      | 2021-01-11 |      3     |
|      B      | 2021-01-01 |      2     |
|      B      | 2021-01-02 |      2     |
|      B      | 2021-01-04 |      1     |
|      B      | 2021-01-11 |      1     |
|      B      | 2021-01-16 |      3     |
|      B      | 2021-02-01 |      3     |
|      C      | 2021-01-01 |      3     |
|      C      | 2021-01-01 |      3     |
|      C      | 2021-01-07 |      3     |

### Menu Table
| product_id | product_name | price | 
|------------|--------------|-------|
|      1     |     sushi    |   10  |
|      2     |     curry    |   15  |
|      3     |     ramen    |   12  |

### Members Table
| customer_id |  join_date  |
|-------------|-------------|
|      A      |  2021-01-07 |
|      B      |  2021-01-09 |

### Entity Relationship Diagram

![image](https://github.com/user-attachments/assets/f3e8b92c-2ed7-4db1-a913-d61b91e1819c)

## **Tools Used**  
- **SQL** (CTEs, Window Functions, JOINs, Aggregations)  
- **SQL Server** (Database management)  

---

## **Key SQL Analysis Questions**  

### **1. What is the total amount each customer spent at the restaurant?**  
Identify high-spending customers to focus loyalty rewards.  

#### Method:
```
select 
	s.customer_id as customer,
	sum(m.price) as total_amount_spent
from sales s inner join menu m 
	on s.product_id = m.product_id
group by s.customer_id
;
```
#### Result:
![image](https://github.com/user-attachments/assets/a164ea4d-75b4-4561-a63f-9425b34d9dd1)


### **2. How many days has each customer visited the restaurant?**  
Measure customer engagement frequency.

#### Method:
```
select
	customer_id as customer,
	count(distinct order_date) as days_visited
from sales
group by customer_id
;
```
#### Result:
![image](https://github.com/user-attachments/assets/3ba327b3-18d1-4a90-9d80-05630f2ecd42)


### **3. What was the first item purchased by each customer?**  
Understand initial preferences to personalize offers.  

#### Method:
```
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
```
OR
...including the first purchase date
```
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
```
#### Results:
![image](https://github.com/user-attachments/assets/4cf0b484-2e02-495d-a21a-cc9c62138039)


### **4. What is the most purchased item on the menu, and how many times was it bought?**  
Identify best-selling products for inventory planning.  

#### Method:
a. most purchased item/product
```
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
order by number_of_purchases desc
;
```
b. most purchased item/product on the menu and number of times was it purchased by all customers
```
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
```
#### Results:
![image](https://github.com/user-attachments/assets/68b38272-5485-4230-a203-ed50f17dd7b0)


### **5. Which item was the most popular for each customer?**  
Discover individual preferences for targeted marketing.  

#### Method:
```
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
```
#### Result:
![image](https://github.com/user-attachments/assets/832f9e65-cc1a-49f8-9fd9-fc2fd855a3e8)


### **6. Which item was purchased first by the customer after they became a member?**  
Analyze post-membership behavior changes.  

#### Method:
```
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
```
OR
```
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
```
#### Results:
![image](https://github.com/user-attachments/assets/3497dbfc-2679-4cc5-9e8d-361fae4f4caf)


### **7. Which item was purchased just before the customer became a member?**  
Identify potential triggers for joining the loyalty program.  

#### Method:
```
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
```
OR
```
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
```
#### Results:
![image](https://github.com/user-attachments/assets/7d6820eb-5166-4a17-a316-90837bb34db4)


### **8. What is the total items and amount spent for each member before they became a member?**  
Compare pre-membership spending patterns.  

#### Method:
```
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
```
OR
```
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
```
#### Results:
![image](https://github.com/user-attachments/assets/82dac048-7ccf-41dc-beb8-dbb8a4662a7d)


### **9. If each $1 spent = 10 points, and sushi has a 2x multiplier, how many points does each customer have?**  
Calculate potential loyalty rewards under current program.  

#### Method:
```
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
```
OR
```
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
```
#### Results:
![image](https://github.com/user-attachments/assets/f270f5a1-7828-49aa-bca9-7ef3aa6bc9d2)


### **10. In the first week after joining, members earn 2x points on all items—how many points do Customers A and B have by end of January?**  
Test effectiveness of new-member bonus points.  

#### Method:
```
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
```
#### Result:
![image](https://github.com/user-attachments/assets/dd0dc26d-06e9-4333-8158-33ca06cd6a6c)


### **11. Rank all products for each member, with NULL values for non-members**  
*Danny also requires further information about the ranking of products. He purposely does not need the ranking of non member purchases so he expects NULL ranking values for customers who are not yet part of the loyalty program.*
Provide product rankings exclusively for loyalty program members while clearly identifying non-members with NULL values.  

#### Method:
```
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
```
#### Result:
![image](https://github.com/user-attachments/assets/0857f066-9a3f-41a9-96fd-fa25f0cf6ecc)


---

## **Insights & Recommendations**  

### **Key Findings**  
✅ **Customer B** visited most frequently (6 times).  
✅ **Ramen** is the top-selling item, followed by curry and sushi.  
✅ **Customer A** loves ramen, **Customer C** only orders ramen, while **Customer B** enjoys all three equally.  
✅ Last pre-membership orders: **sushi (Customer A)** and **curry (Customer B)**—potential loyalty triggers.  

### **Actionable Steps for Danny**  
1. **Boost Loyalty Program:**  
   - Offer **double points on sushi** and **first-week bonuses**.  
   - Personalize rewards (e.g., free ramen for frequent buyers).  
2. **Increase Engagement:**  
   - Target **Customer B** with exclusive deals (highest visits).  
   - Investigate why **Customer C** only orders ramen—expand menu appeal?  
3. **Menu Optimization:**  
   - Introduce **new ramen variants** (top seller).  
   - Create **bundles** (e.g., sushi + curry) to diversify orders.  

---

## **Conclusion**  
This SQL-driven analysis revealed **customer preferences, spending trends, and loyalty program opportunities** for Danny's Diner. The additional product ranking analysis (Question 11) provides clear differentiation between member and non-member purchasing patterns, enabling more focused loyalty program strategies.
