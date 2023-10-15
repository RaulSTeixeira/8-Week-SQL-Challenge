----------------------------------
-- CASE STUDY 1: DANNY'S DINER --
----------------------------------

-- Author: Raul Teixeira
-- Date: 12/10/2023 
-- RDBMS used: PostgreSQL
-- Link: https://8weeksqlchallenge.com/case-study-1/

--------------------
-- CREATE DATASET --
--------------------

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

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

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

-- 1. What is the total amount each customer spent at the restaurant?

SELECT customer_id, sum(price) AS total_sales 
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu ON menu.product_id = sales.product_id
GROUP BY customer_id
ORDER BY customer_id

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, count(DISTINCT order_date) as visits
FROM dannys_diner.sales
Group BY customer_id
ORDER BY customer_id

-- 3. What was the first item from the menu purchased by each customer?

SELECT DISTINCT customer_id, product_name FROM(
	SELECT customer_id, 
	product_name,
	order_date,
	RANK() OVER (PARTITION BY customer_id ORDER BY order_date) as product_rank 
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on sales.product_id = menu.product_id) as rank_numb
WHERE product_rank = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, count(sales.product_id) as number_sold
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
GROUP By product_name
ORDER By number_sold DESC
LIMIT 1

-- 5. Which item was the most popular for each customer?
-- Assuming that we want to see all products, even when they were bought the same amount of times.

SELECT customer_id, product_name,product_rank, sales FROM
	(SELECT
	customer_id,
	menu.product_name,
	RANK() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(menu.product_name)DESC) as product_rank,
	COUNT (menu.product_name) as sales
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
	GROUP By customer_id, product_name) as rank_numb
WHERE product_rank = 1

-- In this version, with ROW_NUMBER we just see one product per customer. Products with the same amount of sales within a customer are chosen by alfabetic order.

SELECT customer_id, product_name,product_rank, sales FROM
	(SELECT
	customer_id,
	menu.product_name,
	ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(menu.product_name)DESC,menu.product_name) as product_rank,
	COUNT (menu.product_name) as sales
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
	GROUP By customer_id, product_name) as rank_numb
WHERE product_rank = 1

-- 6. Which item was purchased first by the customer after they became a member?
-- Assuming that a product is ilegible when it was bought in the same day as the join_date (there are no detailed timestamp)
SELECT customer_id, product_name FROM
	(SELECT
	sales.customer_id,
	sales.order_date,
	members.join_date,
	menu.product_name,
	RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) as product_rank
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
	INNER JOIN dannys_diner.members on members.customer_id = sales.customer_id
	WHERE order_date >= join_date) as rank_numb
WHERE product_rank = 1

-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id, product_name, order_date, join_date FROM
	(SELECT
    sales.customer_id,
    sales.order_date,
    members.join_date,
    menu.product_name,
	RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) as product_rank
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
	INNER JOIN dannys_diner.members on members.customer_id = sales.customer_id
	WHERE order_date < join_date) as rank_numb
WHERE product_rank = 1

-- In this version when there are two products bought in the same day, alfabetic order is used.

SELECT customer_id, product_name FROM
	(SELECT
	sales.customer_id,
	sales.order_date,
	members.join_date,
	menu.product_name,
	ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC, menu.product_name) as product_rank
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
	INNER JOIN dannys_diner.members on members.customer_id = sales.customer_id
	WHERE order_date < join_date) as rank_numb
WHERE product_rank = 1

-- 8.  What is the total items and amount spent for each member before they became a member?

SELECT
sales.customer_id,
COUNT(menu.product_name) as total_items,
CONCAT(SUM(menu.price), ' $') as amount_spent
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
INNER JOIN dannys_diner.members on members.customer_id = sales.customer_id
WHERE order_date < join_date
GROUP BY sales.customer_id
ORDER BY sales.customer_id

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
sales.customer_id,
SUM(CASE
		WHEN menu.product_name = 'sushi' then menu.price * 20
		ELSE menu.price * 10
    END) as member_points
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id

-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- Assuming that the points are only counted from the day the customer joined the program (including the join day)

SELECT customer_id, sum(points) as points FROM
	(SELECT
	sales.customer_id,
	sales.order_date,
	members.join_date,
	menu.product_name,
	(CASE
			WHEN menu.product_name = 'sushi' THEN menu.price * 20
			WHEN sales.order_date BETWEEN members.join_date and members.join_date + INTERVAL '6 days' THEN menu.price * 20
			ELSE menu.price * 10
		END) as points
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
	INNER JOIN dannys_diner.members on members.customer_id = sales.customer_id) as points_table
WHERE order_date <= '2021-01-31' AND order_date >= join_date
GROUP BY customer_id
ORDER BY customer_id

---------------------
-- BONUS QUESTIONS --
---------------------

-- Join All The Things

SELECT
	sales.customer_id,
	sales.order_date,
	menu.product_name,
	menu.price,
	(CASE
			WHEN sales.order_date >= members.join_date THEN 'Y'
			ELSE 'N'
	   END) as member
	FROM dannys_diner.sales
	INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
	LEFT JOIN dannys_diner.members on members.customer_id = sales.customer_id
ORDER BY customer_id, order_date, product_name

-- Rank All The Things

WITH joined_tables AS(
	SELECT
		sales.customer_id,
		sales.order_date,
		menu.product_name,
		menu.price,
		(CASE
				WHEN sales.order_date >= members.join_date THEN 'Y'
				ELSE 'N'
		   END) as member
		FROM dannys_diner.sales
		INNER JOIN dannys_diner.menu on menu.product_id = sales.product_id
		LEFT JOIN dannys_diner.members on members.customer_id = sales.customer_id
	ORDER BY customer_id, order_date, product_name
)
		
SELECT
customer_id,
order_date,
product_name,
price,
member,
CASE
	WHEN member = 'N' Then NULL
	ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
END AS ranking
FROM joined_tables
