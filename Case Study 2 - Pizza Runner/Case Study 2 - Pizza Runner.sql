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
ALTER COLUMN distance TYPE FLOAT USING distance::FLOAT,
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

---------------------
-- BONUS QUESTIONS --
---------------------


