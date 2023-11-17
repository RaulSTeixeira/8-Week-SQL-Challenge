----------------------------------
-- CASE STUDY 2: PIZZA RUNNER --
----------------------------------

-- Author: Raul Teixeira
-- Date: 12/10/2023 
-- RDBMS used: PostgreSQL
-- Link: https://8weeksqlchallenge.com/case-study-2/

--------------------
-- CREATE DATASET --
--------------------

CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

--------------------
-- DATA CLEANSING --
--------------------
-- 1 Clean customers_orders table --
-- Copy data from customer_orders to a new table to avoid any data loss of the original table

DROP TABLE IF EXISTS pizza_runner.customer_orders_cleaned;
SELECT *
INTO pizza_runner.customer_orders_cleaned
FROM pizza_runner.customer_orders

-- Update blank and 'null' values

UPDATE pizza_runner.customer_orders_cleaned
SET exclusions = CASE
					WHEN exclusions = '' OR exclusions = 'null' THEN NULL
					ELSE exclusions
				 END,
	extras = CASE
				WHEN extras = '' OR extras = 'null' THEN NULL
				ELSE extras
				END

-- Split exclusions and extras column as we have more than 1 value per column 
-- Note: since the maximum exclusions/extras for this dataset is two, we just create one more column per type

ALTER TABLE pizza_runner.customer_orders_cleaned
ADD exclusions_2 varchar(4) NULL,
ADD extras_2 varchar(4) NULL

UPDATE pizza_runner.customer_orders_cleaned
SET exclusions = CASE 
					WHEN Length(exclusions) > 1 THEN Substring(exclusions,1,1)
					ELSE exclusions
				 END,
	exclusions_2 = CASE 
					WHEN Length(exclusions) > 1 THEN Substring(exclusions,3,3)
					ELSE NULL
				 END,
	extras = CASE 
					WHEN Length(extras) > 1 THEN Substring(extras,1,1)
					ELSE extras
				 END,
	extras_2 = CASE 
					WHEN Length(extras) > 1 THEN Substring(extras,3,3)
					ELSE NULL
				 END

-- Review data types

SELECT TABLE_NAME,COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer_orders_cleaned'

ALTER TABLE pizza_runner.customer_orders_cleaned
ALTER COLUMN exclusions TYPE INT USING exclusions::integer,
ALTER COLUMN extras TYPE INT USING extras::integer,
ALTER COLUMN exclusions_2 TYPE INT USING exclusions_2::integer,
ALTER COLUMN extras_2 TYPE INT USING extras_2::integer

-- 2 Clean runner_orders table --
-- Copy data from customer_orders to a new table to avoid any data loss of the original table

DROP TABLE IF EXISTS pizza_runner.runner_orders_cleaned;
SELECT *
INTO pizza_runner.runner_orders_cleaned
FROM pizza_runner.runner_orders

-- clean columns with empty values and incorrect strings representation

UPDATE pizza_runner.runner_orders_cleaned
SET distance = CASE
					WHEN distance = '' OR distance = 'null' THEN NULL
					ELSE CAST(REGEXP_REPLACE(distance,'[[:alpha:]]','','g') AS FLOAT)
				 END,					  
	duration = CASE
					WHEN distance = '' OR distance = 'null' THEN NULL
					ELSE CAST(REGEXP_REPLACE(duration,'[[:alpha:]]','','g') AS INT)
				 END,						  
	cancellation = CASE
					WHEN cancellation = '' OR cancellation = 'null' THEN NULL
					ELSE cancellation
				 END,
	pickup_time = CASE
					WHEN pickup_time = '' OR pickup_time = 'null' THEN NULL
					ELSE pickup_time
				 END

-- Review data types

SELECT TABLE_NAME,COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'runner_orders_cleaned'

ALTER TABLE pizza_runner.runner_orders_cleaned
ALTER COLUMN pickup_time TYPE timestamp USING pickup_time::timestamp,
ALTER COLUMN distance TYPE numeric USING distance::numeric,
ALTER COLUMN duration TYPE INT USING duration::INT

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

-- A. PIZZA METRICS --

-- A1. How many pizzas were ordered?

SELECT COUNT(pizza_id) AS number_orders
FROM pizza_runner.customer_orders_cleaned

-- A2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM pizza_runner.customer_orders_cleaned

-- A3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS number_sucesseful_runs FROM pizza_runner.runner_orders_cleaned 
WHERE pickup_time IS NOT NULL
GROUP BY runner_id
ORDER BY runner_id

-- A4. How many of each type of pizza was delivered?

SELECT co.pizza_id, pn.pizza_name, COUNT(co.order_id) AS number_pizzas_delivered FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
INNER JOIN pizza_runner.pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE ro.cancellation IS NULL
GROUP BY co.pizza_id, pn.pizza_name
ORDER BY co.pizza_id

-- A5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT co.customer_id, pn.pizza_name, COUNT(co.order_id) AS number_pizzas_delivered FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
INNER JOIN pizza_runner.pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id, pn.pizza_name
ORDER BY co.customer_id

-- A6. What was the maximum number of pizzas delivered in a single order?
-- note: if a order is canceled, it only appers once in the order table, so for this particular problem, we dont need to inner join this two tables

SELECT co.order_id, COUNT(co.order_id) AS number_pizzas_delivered FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.order_id
ORDER BY number_pizzas_delivered DESC
LIMIT 1

-- A7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT
	co.customer_id,
	SUM(CASE
			WHEN co.exclusions IS NULL AND co.exclusions_2 IS NULL AND co.extras IS NULL AND co.extras_2 IS NULL THEN 1
			ELSE 0
		END) AS number_pizzas_delivered_NO_changes,
	SUM(CASE
			WHEN co.exclusions IS NOT NULL OR co.exclusions_2 IS NOT NULL OR co.extras IS NOT NULL OR co.extras_2 IS NOT NULL THEN 1
			ELSE 0
		END) AS number_pizzas_delivered_WITH_changes
FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id
ORDER BY co.customer_id

-- A8. How many pizzas were delivered that had both exclusions and extras?

SELECT
	SUM(CASE
			WHEN (co.exclusions IS NOT NULL OR co.exclusions_2 IS NOT NULL) AND (co.extras IS NOT NULL OR co.extras_2 IS NOT NULL) THEN 1
			ELSE 0
		END) AS number_pizzas_delivered_with_exclusions_extras
	FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULLSELECT 
	SUM(CASE
			WHEN (co.exclusions IS NOT NULL OR co.exclusions_2 IS NOT NULL) AND (co.extras IS NOT NULL OR co.extras_2 IS NOT NULL) THEN 1
			ELSE 0
		END) AS number_pizzas_delivered_with_exclusions_extras
	FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL

-- A9. What was the total volume of pizzas ordered for each hour of the day?

SELECT EXTRACT (hour FROM co.order_time) AS hour_day, 
				COUNT(order_id) AS volume_orders
FROM pizza_runner.customer_orders_cleaned co
GROUP BY hour_day
ORDER BY hour_day

-- A10. What was the volume of orders for each day of the week?

SELECT to_char(co.order_time, 'day') AS day_week, 
				COUNT(order_id) AS volume_orders
FROM pizza_runner.customer_orders_cleaned co
GROUP BY day_week
ORDER BY day_week

-- B. RUNNER AND CUSTOMER EXPERIENCE --

-- B1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- note: postgres uses iso standards to extract dates, in this case the first week is seen as 53

SELECT date_part('week', registration_date) AS registration_week,
	   count(runner_id) AS number_registrations
FROM pizza_runner.runners
GROUP BY registration_week

-- B2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- Used epoch to extract seconds from the diff, and then rounded with 2 decimals

SELECT ro.runner_id,
	   ROUND(AVG (extract(epoch from (pickup_time - order_time)))/60,2) AS avg_pickup_time
FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
GROUP BY ro.runner_id
ORDER BY ro.runner_id

-- B3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH order_avg_pickup_time AS
	(SELECT ro.order_id,
		   COUNT(co.pizza_id) AS nr_pizzas,
		   EXTRACT(epoch from (ro.pickup_time - co.order_time))/60 AS prepare_time
	FROM pizza_runner.customer_orders_cleaned co
	INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
	WHERE ro.cancellation IS NULL
	GROUP BY ro.order_id, prepare_time
	ORDER BY ro.order_id)
SELECT nr_pizzas,
	   ROUND(AVG(prepare_time),2) AS avg_prepare_time
FROM order_avg_pickup_time
GROUP BY nr_pizzas

-- The preparation time increases linearly with the number of pizzas ordered

-- B4. What was the average distance travelled for each customer?

SELECT co.customer_id,
	   ROUND(AVG(ro.distance), 2) AS avg_distance
FROM pizza_runner.customer_orders_cleaned co
INNER JOIN pizza_runner.runner_orders_cleaned ro ON co.order_id = ro.order_id
GROUP BY customer_id
ORDER BY customer_id

-- B5.What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(ro.duration) - MIN (ro.duration) AS diff_duration
FROM pizza_runner.runner_orders_cleaned ro

-- B6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT ro.runner_id,
	   ro.order_id,
	   ro.duration,
	   ro.distance,
	   ROUND(ro.distance*60/ro.duration,2) AS average_speed_km_h
FROM pizza_runner.runner_orders_cleaned ro
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id, ro.order_id, ro.duration, ro.distance
ORDER BY ro.runner_id

-- The average speed seems unrelated to the distance, but it increases as the runner delivers more orders

-- B7. What is the successful delivery percentage for each runner?

WITH sucefull_delivery AS
	(SELECT runner_id,
	 		order_id,
	 	    CASE
	 			WHEN ro.cancellation IS NULL THEN 1
				ELSE 0
			END AS sucess
	 FROM pizza_runner.runner_orders_cleaned ro)

SELECT runner_id,
	   (SUM (sucess)/CAST(COUNT(order_id) as FLOAT) * 100) AS sucess_percentage
FROM sucefull_delivery
GROUP BY sucefull_delivery.runner_id
ORDER BY runner_id

-- C. INGREDIENTS OPTIMIZATION --

-- C1. What are the standard ingredients for each pizza?

-- Expanded and copy pizza_recipes table, also changed data type for topping_id
DROP TABLE IF EXISTS pizza_runner.pizza_recipes_expanded;
CREATE TABLE pizza_runner.pizza_recipes_expanded AS
SELECT
	pizza_id,
	UNNEST(regexp_split_to_array(toppings, ','))as topping_id
FROM pizza_runner.pizza_recipes

SELECT TABLE_NAME,COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_recipes_expanded'

ALTER TABLE pizza_runner.pizza_recipes_expanded
ALTER COLUMN toppings_id TYPE INT USING topping_id::integer

SELECT *
FROM pizza_runner.pizza_recipes_expanded pze
INNER JOIN pizza_runner.pizza_topping pt ON pze.topping_id = pt.topping_id

SELECT pn.pizza_name, STRING_AGG(pt.topping_name,', ') as standard_ingredients
FROM pizza_runner.pizza_recipes_expanded pre
INNER JOIN pizza_runner.pizza_toppings pt ON pre.topping_id = pt.topping_id
INNER JOIN pizza_runner.pizza_names pn ON pn.pizza_id = pre.pizza_id
GROUP BY pn.pizza_name
ORDER BY pn.pizza_name

-- C2. What was the most commonly added extra?

-- In the inital data cleaning the extras columns was split into two, but in this method we will expand the original table to count the most added extra.
DROP TABLE IF EXISTS pizza_runner.customer_orders_original_cleaned;
SELECT *
INTO pizza_runner.customer_orders_original_cleaned
FROM pizza_runner.customer_orders

-- Update blank and 'null' values

UPDATE pizza_runner.customer_orders_original_cleaned
SET exclusions = CASE
					WHEN exclusions = '' OR exclusions = 'null' THEN NULL
					ELSE exclusions
				 END,
	extras = CASE
				WHEN extras = '' OR extras = 'null' THEN NULL
				ELSE extras
				END
				
WITH customer_orders_expanded AS
	(SELECT
		order_id,
		UNNEST(regexp_split_to_array(extras, ',')) AS extras_id
	FROM pizza_runner.customer_orders_original_cleaned
	)
	
SELECT pt.topping_name, COUNT(*) AS times_added FROM customer_orders_expanded coe
INNER JOIN pizza_runner.pizza_toppings pt ON CAST (coe.extras_id AS INTEGER)  = CAST (pt.topping_id AS INTEGER)

GROUP BY pt.topping_name
ORDER BY times_added DESC
LIMIT 1

-- C3. What was the most common exclusion??

-- Same as before, but now using the exclusions
WITH customer_orders_expanded AS
	(SELECT
		order_id,
		UNNEST(regexp_split_to_array(exclusions, ',')) AS exclusions_id
	FROM pizza_runner.customer_orders_original_cleaned
	)
	
SELECT pt.topping_name, COUNT(*) AS times_removed FROM customer_orders_expanded coe
INNER JOIN pizza_runner.pizza_toppings pt ON CAST (coe.exclusions_id AS INTEGER)  = CAST (pt.topping_id AS INTEGER)

GROUP BY pt.topping_name
ORDER BY times_removed DESC
LIMIT 1

/* C.4 Generate an order item for each record in the customers_orders table in the format of one of the following:
			Meat Lovers
			Meat Lovers - Exclude Beef
			Meat Lovers - Extra Bacon
			Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/


SELECT pn.pizza_name,
	   t1.topping_name,
	   t2.topping_name,
	   t3.topping_name,
	   t4.topping_name,
	   CASE	
	   		WHEN t1.topping_name IS NOT NULL
			AND t3.topping_name IS NULL 
			AND t2.topping_name IS NULL
			THEN CONCAT(pn.pizza_name,' - Exclude ', t1.topping_name)
			
			WHEN t1.topping_name IS NOT NULL 
			AND t3.topping_name IS NULL 
			AND t2.topping_name IS NOT NULL
			THEN CONCAT(pn.pizza_name,' - Exclude ', t1.topping_name, ', ',t2.topping_name)
			
			WHEN t1.topping_name IS NOT NULL
			AND t3.topping_name IS NOT NULL
			AND t2.topping_name IS NULL
			AND t4.topping_name IS NULL
			THEN CONCAT(pn.pizza_name,' - Exclude ', t1.topping_name, ', - Extra ',t3.topping_name)
			
			WHEN t1.topping_name IS NOT NULL
			AND t3.topping_name IS NOT NULL
			AND t2.topping_name IS NULL
			AND t4.topping_name IS NULL
			THEN CONCAT(pn.pizza_name,' - Exclude ', t1.topping_name, ', - Extra ',t3.topping_name)
			
			WHEN t1.topping_name IS NULL
			AND t3.topping_name IS NOT NULL
			AND t4.topping_name IS NULL
			THEN CONCAT(pn.pizza_name,' - Extra ',t3.topping_name)
			
			WHEN t1.topping_name IS NULL
			AND t3.topping_name IS NOT NULL
			AND t4.topping_name IS NOT NULL
			THEN CONCAT(pn.pizza_name,' - Extra ',t3.topping_name, ', ',t4.topping_name)
			
			WHEN t1.topping_name IS NOT NULL
			AND t3.topping_name IS NOT NULL
			AND t2.topping_name IS NOT NULL
			AND t4.topping_name IS NOT NULL
			THEN CONCAT(pn.pizza_name,' - Exclude ', t1.topping_name,', ', t2.topping_name, ', - Extra ',t3.topping_name, ', ', t4.topping_name)
			
			ELSE pn.pizza_name
						
	   END AS generated_order

FROM pizza_runner.customer_orders_cleaned coc
INNER JOIN pizza_runner.pizza_names pn ON coc.pizza_id = pn.pizza_id
LEFT JOIN pizza_runner.pizza_toppings t1 ON coc.exclusions = t1.topping_id
LEFT JOIN pizza_runner.pizza_toppings t2 ON coc.exclusions_2 = t2.topping_id
LEFT JOIN pizza_runner.pizza_toppings t3 ON coc.extras = t3.topping_id
LEFT JOIN pizza_runner.pizza_toppings t4 ON coc.extras_2 = t4.topping_id


/* C.5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */

-- STEP 1: Create a new customer_orders table with a sk_row column to identify each row because we can have equal rows as one customer can order 2 equal pizzas in the same order
DROP TABLE IF EXISTS pizza_runner.ordered_ingredients;
SELECT coc2.order_id,
	   coc2.sk_row,
	   coc2.pizza_id,
	   CONCAT(coc2.order_id,coc2.sk_row) as sk_pizza,
	   pn.pizza_name as pizza_name,
	   coc2.extras,
	   coc2.exclusions,
	   pre.topping_id,
	   t1.topping_name,
	   t2.topping_name as xxx,
	   CASE
			WHEN t1.topping_name = t2.topping_name THEN CONCAT('2x',t1.topping_name) -- extras
			WHEN t1.topping_name = t4.topping_name THEN CONCAT('2x',t1.topping_name) -- extras_2
			WHEN t1.topping_name = t3.topping_name THEN '' -- exclusions
			WHEN t1.topping_name = t5.topping_name THEN '' -- exclusions_2
			ELSE t1.topping_name
	   END AS final_ingredients
INTO pizza_runner.ordered_ingredients
FROM pizza_runner.customers_orders_cleaned2 coc2
	INNER JOIN pizza_runner.pizza_names pn on coc2.pizza_id = pn.pizza_id
	INNER JOIN pizza_runner.pizza_recipes_expanded pre on pn.pizza_id = pre.pizza_id
	INNER JOIN pizza_runner.pizza_toppings t1 on pre.topping_id = t1.topping_id
	-- extras
	LEFT JOIN pizza_runner.pizza_toppings t2 on coc2.extras = t2.topping_id
	LEFT JOIN pizza_runner.pizza_toppings t4 on coc2.extras_2 = t4.topping_id
	-- exclusions
	LEFT JOIN pizza_runner.pizza_toppings t3 on coc2.exclusions = t3.topping_id
	LEFT JOIN pizza_runner.pizza_toppings t5 on coc2.exclusions_2 = t5.topping_id

-- STEP 3: Use RANK() to order ingredients_for_pizza the ingredient list for each pizza and reshape data using STRING_AGG to answer the question
SELECT oic.sk_pizza,
	   CONCAT(oic.pizza_name, ':', STRING_AGG(oic.final_ingredients,', ')) as ingredients_for_pizza
FROM	   
	(SELECT oi.sk_pizza, 
		   oi.pizza_name,
		   oi.final_ingredients,
		   CASE	
				WHEN oi.final_ingredients = '' THEN NULL
				ELSE RANK() OVER(PARTITION BY sk_pizza ORDER BY pizza_name,final_ingredients)
		   END AS ingredients_rank
	 FROM pizza_runner.ordered_ingredients oi) AS oic
WHERE oic.ingredients_rank IS NOT NULL
GROUP BY oic.sk_pizza, oic.pizza_name

--C.6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- remember to used tables calculated in previous question
SELECT oic.final_ingredients,
       CASE
	   		WHEN final_ingredients LIKE ('2x%') THEN COUNT(oic.final_ingredients) * 2
			ELSE COUNT(oic.final_ingredients)
			END AS total_amount
FROM	   
	(SELECT oi.sk_pizza, 
		   oi.pizza_name,
		   oi.final_ingredients,
		   CASE	
				WHEN oi.final_ingredients = '' THEN NULL
				ELSE RANK() OVER(PARTITION BY sk_pizza ORDER BY pizza_name,final_ingredients)
		   END AS ingredients_rank
	 FROM pizza_runner.ordered_ingredients oi) AS oic
WHERE oic.ingredients_rank IS NOT NULL
GROUP BY oic.final_ingredients
ORDER BY total_amount DESC

-- D. PRICING AND RATINGS --

--D.1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT SUM(price_table.price) AS total_income
FROM(
	SELECT pn.pizza_name, coc.order_id, roc.cancellation,
		CASE
			WHEN pn.pizza_name = 'Meatlovers' THEN 12
			ELSE 10
		END AS price
	FROM pizza_runner.customer_orders_cleaned coc
	INNER JOIN pizza_runner.runner_orders_cleaned roc ON coc.order_id = roc.order_id
	INNER JOIN pizza_runner.pizza_names pn ON coc.pizza_id = pn.pizza_id
	WHERE roc.cancellation IS NULL) AS price_table

--D.2 What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

SELECT SUM(price_table_with_extras.price) + SUM(price_table_with_extras.extras_price) AS total_income
FROM(
	SELECT pn.pizza_name, coc.order_id, roc.cancellation, coc.extras, coc.extras_2,
		CASE
			WHEN pn.pizza_name = 'Meatlovers' THEN 12
			ELSE 10
		END AS price,
		CASE
			WHEN coc.extras IS NOT NULL AND coc.extras_2 IS NULL THEN 1
			WHEN coc.extras_2 IS NOT NULL THEN 2
			ELSE 0
		END AS extras_price
	FROM pizza_runner.customer_orders_cleaned coc
	INNER JOIN pizza_runner.runner_orders_cleaned roc ON coc.order_id = roc.order_id
	INNER JOIN pizza_runner.pizza_names pn ON coc.pizza_id = pn.pizza_id
	WHERE roc.cancellation IS NULL) AS price_table_with_extras

--D.3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset -
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS pizza_runner.rating;
CREATE TABLE pizza_runner.rating (
  "rating_id" INTEGER,
  "order_id" INTEGER,
  "rating" INTEGER constraint check_rating CHECK(rating between 1 and 5),
  "comment" VARCHAR(50)
);
INSERT INTO pizza_runner.rating
VALUES
  	(1,1,2,'Took more time than estimated')
	,(2,2,4,'')
	,(3,3,4,'')
	,(4,4,5,'Really good service')
	,(5,5,2, '')
	,(6,6, NULL,'') -- order not delivered
	,(7,7,5,'')
	,(8,8,4,'Great service')
	,(9,9, NULL, '') -- order not delivered
	,(10,10,1,'The pizza arrived upside down, really disappointed');

-- D4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
/*		- customer_id
		- order_id
		- runner_id
		- rating
		- order_time
		- pickup_time
		- Time between order and pickup
		- Delivery distance
		- Delivery duration
		- Average speed
		- Total number of pizzas*/

DROP TABLE IF EXISTS general_info;
SELECT
	coc.customer_id,
	coc.order_id,
	roc.runner_id,
	rtg.rating,
	coc.order_time,
	roc.pickup_time,
	ROUND((extract(epoch from (pickup_time - order_time)))/60,2) AS time_betwen_order_and_pickup_min,
	roc.duration AS delivery_duration,
	ROUND(roc.distance*60/roc.duration,2) AS average_speed_km_h,
	count(coc.pizza_id) AS total_number_pizzas
	
INTO general_info

FROM pizza_runner.customer_orders_cleaned coc
INNER JOIN pizza_runner.runner_orders_cleaned roc ON coc.order_id = roc.order_id
INNER JOIN pizza_runner.rating rtg ON coc.order_id = rtg.order_id
WHERE roc.cancellation IS NULL
GROUP BY coc.customer_id, coc.order_id, roc.runner_id, rtg.rating, coc.order_time, roc.pickup_time, delivery_duration, average_speed_km_h 

SELECT * FROM general_info
ORDER BY order_id

-- C5 .If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled
-- how much money does Pizza Runner have left over after these deliveries?

SELECT SUM(price_table.price) - SUM(price_table.delivery_cost) AS total_income
FROM(
	SELECT 
	pn.pizza_name,
	coc.order_id,
	roc.cancellation,
	roc.distance,
	roc.distance * 0.3 AS delivery_cost,
		CASE
			WHEN pn.pizza_name = 'Meatlovers' THEN 12
			ELSE 10
		END AS price
	FROM pizza_runner.customer_orders_cleaned coc
	INNER JOIN pizza_runner.runner_orders_cleaned roc ON coc.order_id = roc.order_id
	INNER JOIN pizza_runner.pizza_names pn ON coc.pizza_id = pn.pizza_id
	WHERE roc.cancellation IS NULL) AS price_table

	
---------------------
-- BONUS QUESTIONS --
---------------------


