----------------------------------
-- CASE STUDY 7: Balanced Tree --
----------------------------------

-- Author: Raul Teixeira
-- Date: 02/09/2024
-- Data Base used: PostgreSQL
-- RDBMS used: pgAdmin4
-- Link: https://8weeksqlchallenge.com/case-study-7/

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

--SELECT * FROM balanced_tree.product_details;

-- 1. High Level Sales Analysis
-- 1.1 What was the total quantity sold for all products?

SELECT SUM(qty) AS sold_quantiy
FROM balanced_tree.sales

-- grouping per product

SELECT prod_id, sum(qty) AS sold_quantiy
FROM balanced_tree.sales
GROUP BY prod_id

-- 1.2 What is the total generated revenue for all products before discounts?

SELECT SUM(qty * price) AS total_revenue_before_discounts
FROM balanced_tree.sales

-- grouping per product

SELECT prod_id, sum(qty * price) AS total_revenue_before_discounts
FROM balanced_tree.sales
GROUP BY prod_id

-- 1.3 What was the total discount amount for all products?

SELECT SUM(qty * price * CAST(discount as float)/100) AS total_discounts
FROM balanced_tree.sales

-- grouping per product

SELECT prod_id, sum(qty * price * CAST(discount as float)/100) AS total_discounts
FROM balanced_tree.sales
GROUP BY prod_id

--other type of solution

SELECT ROUND(CAST(SUM(qty * price * percentage_discount) as numeric), 2) as total_discounts
FROM(

		SELECT
		qty,
		price,
		CAST(discount as float)/100 as percentage_discount
		FROM balanced_tree.sales
) as subquery

--other type of solution, by product

SELECT prod_id, ROUND(CAST(SUM(qty * price * percentage_discount) as numeric), 2) as total_discounts
FROM(

		SELECT
		prod_id,
		qty,
		price,
		CAST(discount as float)/100 as percentage_discount
		FROM balanced_tree.sales
) as subquery
GROUP BY prod_id

-- 2. Transaction Analysis

-- 2.1 How many unique transactions were there?

SELECT * from balanced_tree.sales
ORDER BY txn_id

SELECT COUNT(DISTINCT(txn_id)) as unique_transaction 
FROM balanced_tree.sales

-- 2.1 What is the average unique products purchased in each transaction?

SELECT AVG(unique_products) as avg_unique_products_per_transaction
FROM(

	SELECT txn_id, count(DISTINCT(prod_id)) as unique_products
	FROM balanced_tree.sales
	GROUP BY txn_id
) as aux

-- Using CTE

With table_unique_products AS (
	SELECT txn_id, count(DISTINCT(prod_id)) as unique_products
	FROM balanced_tree.sales
	GROUP BY txn_id)

SELECT AVG(unique_products) as avg_unique_products_per_transaction
FROM table_unique_products

-- Using temp table

DROP TABLE IF EXISTS temptable_unique_products

SELECT txn_id, count(DISTINCT(prod_id)) as unique_products
INTO TEMPORARY Table temptable_unique_products
FROM balanced_tree.sales
GROUP BY txn_id;

SELECT AVG(unique_products) as avg_unique_products_per_transaction
FROM temptable_unique_products


-- 2.3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

SELECT
	percentile_cont(0.5) WITHIN GROUP (ORDER BY revenue)

FROM(
		SELECT txn_id, sum(qty*price) as revenue
		FROM balanced_tree.sales
		GROUP BY txn_id) b;
		
-- 2.4 What is the average discount value per transaction?

SELECT avg (discount_per_transaction)
FROM(
	SELECT txn_id, SUM(qty * price * CAST(discount as float)/100) as discount_per_transaction
	FROM balanced_tree.sales
	GROUP BY txn_id) b

-- 2.5 What is the percentage split of all transactions for members vs non-members?

SELECT * FROM balanced_tree.sales


DECLARE txn_total integer:= SELECT COUNT (DISTINCT(txn_id)) FROM balanced_tree.sales;
txn_total 


WHERE member = 'true'
	





