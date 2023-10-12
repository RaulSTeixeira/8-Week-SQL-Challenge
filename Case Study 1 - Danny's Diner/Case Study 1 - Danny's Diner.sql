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

