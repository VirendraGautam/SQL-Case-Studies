--------------------------------------
8 Weeks SQL Challenge - Danny's Dinner

CASE STUDY 1 - Solution
--------------------------------------

Solution by Virendra Gautam
Tool: MS SQL Server
Date: 22 Aug 2022
--------------------------------------



--Que1.  What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, 
	   SUM(m.price) as total_amount_spent
FROM menu m
JOIN sales s
	ON m.product_id = s.product_id
GROUP BY s.customer_id

 					--------------------------------------------------------------------------------------





-- Que 2. How many days has each customer visited the restaurant?
select customer_id, COUNT(distinct order_date) num_of_days_visited
from sales
group by customer_id

					--------------------------------------------------------------------------------------





-- Que 3. What was the first item from the menu purchased by each customer?

 WITH cte AS (
		SELECT customer_id, 
			   product_name, 
			   order_date,
				DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) AS rank_num
 FROM menu m
 JOIN sales s
 ON m.product_id = s.product_id )

 -- filtering(WHERE rank =1) the the data based on the items perchased on 1st day(order_date) by each customer(GROUP BY customer_id)
SELECT 
	customer_id, 
	product_name 
FROM cte
WHERE rank_num = 1
GROUP BY customer_id, product_name;

				       --------------------------------------------------------------------------------------
				       
				       
				       

-- QUE 4. What is the most purchased item on the menu and how many times was it purchased by all customers?


SELECT TOP 1 (count(s.product_id)) AS product_purchased, 
		m.product_name 
FROM menu m
join sales s
		ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY product_purchased DESC

        				--------------------------------------------------------------------------------------




 Que 5. Which item was the most popular for each customer?

WITH fav_item AS
(
	SELECT 
		COUNT(s.product_id) as order_count, 
		product_name, 
		customer_id,
		DENSE_RANK() OVER( PARTITION BY customer_id ORDER BY COUNT(s.customer_id) DESC) as rnk
	FROM menu m
	JOIN sales s
		ON m.product_id = s.product_id	
	GROUP BY s.customer_id, product_name
)

SELECT * 
	FROM fav_item
WHERE rnk = 1;
				--------------------------------------------------------------------------------------





--6. Which item was purchased first by the customer after they became a member?

WITH first_item AS  (

		SELECT 
			m.product_name, s.customer_id, s.order_date, 
			DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as rnk
		FROM sales s
		JOIN members mem
			ON mem.customer_id = s.customer_id
		JOIN menu m
			ON m.product_id = s.product_id
		WHERE s.order_date >= mem.join_date
)
SELECT * 
	FROM first_item
WHERE rnk =1
					--------------------------------------------------------------------------------------




--7. Which item was purchased just before the customer became a member?

WITH first_item AS  (

		SELECT 
			m.product_name, s.customer_id, s.order_date, 
			DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) as rnk
		FROM sales s
		JOIN members mem
			ON mem.customer_id = s.customer_id
		JOIN menu m
			ON m.product_id = s.product_id
		WHERE s.order_date < mem.join_date
)
SELECT * 
	FROM first_item
WHERE rnk = 1

					--------------------------------------------------------------------------------------




--8. What is the total items and amount spent for each member before they became a member?

SELECT 
	DISTINCT s.customer_id,		
	SUM(m.price) as total_spent, 
	COUNT(s.product_id) as items
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
JOIN members mem
	ON s.customer_id = mem.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id
					--------------------------------------------------------------------------------------



-- Que 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


