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

SELECT * FROM pizza_runner.runner_orders_cleaned

UPDATE pizza_runner.runner_orders_cleaned

SET distance = CASE
					WHEN distance = '' OR distance = 'null' THEN NULL
					WHEN distance LIKE '%km' THEN TRIM('km' from distance)
					ELSE distance
				 END,
	duration = CASE
					WHEN duration = '' OR duration = 'null' THEN NULL
					ELSE duration = Substring(duration,1,2)
				 END




--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

-- 1. How many pizzas were ordered?

SELECT COUNT(pizza_id) AS number_orders
FROM pizza_runner.customer_orders_cleaned

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM pizza_runner.customer_orders_cleaned

-- 3. How many successful orders were delivered by each runner?




---------------------
-- BONUS QUESTIONS --
---------------------


