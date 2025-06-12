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

### **3. What was the first item purchased by each customer?**  
Understand initial preferences to personalize offers.  

### **4. What is the most purchased item on the menu, and how many times was it bought?**  
Identify best-selling products for inventory planning.  

### **5. Which item was the most popular for each customer?**  
Discover individual preferences for targeted marketing.  

### **6. Which item was purchased first by the customer after they became a member?**  
Analyze post-membership behavior changes.  

### **7. Which item was purchased just before the customer became a member?**  
Identify potential triggers for joining the loyalty program.  

### **8. What is the total items and amount spent for each member before they became a member?**  
Compare pre-membership spending patterns.  

### **9. If each $1 spent = 10 points, and sushi has a 2x multiplier, how many points does each customer have?**  
Calculate potential loyalty rewards under current program.  

### **10. In the first week after joining, members earn 2x points on all items—how many points do Customers A and B have by end of January?**  
Test effectiveness of new-member bonus points.  

### **11. Rank all products for each member, with NULL values for non-members**  
Provide product rankings exclusively for loyalty program members while clearly identifying non-members with NULL values.  

---

# **Insights & Recommendations**  

### **Key Findings**  
✅ **Customer B** visited most frequently (6 times in Jan 2021).  
✅ **Ramen** is the top-selling item, followed by curry and sushi.  
✅ **Customer A** loves ramen, **Customer C** only orders ramen, while **Customer B** enjoys all three equally.  
✅ Last pre-membership orders: **sushi (Customer A)** and **curry (Customer B)**—potential loyalty triggers.  

### **Actionable Steps**  
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

# **Conclusion**  
This SQL-driven analysis revealed **customer preferences, spending trends, and loyalty program opportunities** for Danny's Diner. The additional product ranking analysis (Question 11) provides clear differentiation between member and non-member purchasing patterns, enabling more focused loyalty program strategies.  

**Next Steps:**  
- Automate monthly SQL reports.  
- Expand analysis with additional customer data.  
- A/B test promotions based on insights.  

Let me know if you'd like to explore any specific aspect in more detail!




