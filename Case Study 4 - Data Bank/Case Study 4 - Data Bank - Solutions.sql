--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

USE CaseStudy4
GO

--A. Customer Nodes Exploration

-- A.1 How many unique nodes are there on the Data Bank system?

SELECT COUNT(DISTINCT(node_id)) AS unique_node
FROM data_bank.customer_nodes cn;

-- A.2 What is the number of nodes per region?

SELECT
    cn.region_id,
    r.region_name,
    COUNT(cn.node_id) as nr_nodes
FROM data_bank.customer_nodes cn
INNER JOIN data_bank.regions r ON cn.region_id = r.region_id
GROUP BY cn.region_id, r.region_name
ORDER BY cn.region_id;

-- A.3 How many customers are allocated to each region?

SELECT
    cn.region_id,
    r.region_name,
    COUNT(DISTINCT(cn.customer_id)) as nr_clients
FROM data_bank.customer_nodes cn
INNER JOIN data_bank.regions r ON cn.region_id = r.region_id
GROUP BY cn.region_id, r.region_name
ORDER BY cn.region_id;

-- A.4 How many days on average are customers reallocated to a different node?

-- By Customer
SELECT
    customer_id,
    AVG(date_diff)
FROM(    
        SELECT
        cn.customer_id,
        CAST(DATEDIFF(day, cn.start_date, cn.end_date) AS int) AS date_diff
        FROM data_bank.customer_nodes cn
        WHERE end_date <> '9999-12-31' --There is some data that need to be removed since it screws the statistic 
) a
GROUP BY customer_id
ORDER BY customer_id;

-- Total average (this is probably what was asked)

SELECT
    AVG(date_diff) as avg_days_reallocation
FROM(    
        SELECT
        cn.customer_id,
        CAST(DATEDIFF(day, cn.start_date, cn.end_date) AS float) AS date_diff
        FROM data_bank.customer_nodes cn
        WHERE end_date <> '9999-12-31' --There is some data that need to be removed since it screws the statistic 
) a;

-- A.5 What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

SELECT
    DISTINCT a.region_id, -- by doing distinct we dont need another subquery and we have the results by region
    a.region_name,
    PERCENTILE_CONT (0.5) WITHIN GROUP (ORDER BY a.date_diff) OVER (PARTITION BY a.region_id) as median,
    PERCENTILE_CONT (0.8) WITHIN GROUP (ORDER BY a.date_diff) OVER (PARTITION BY a.region_id) as percentile_8,
    PERCENTILE_CONT (0.95) WITHIN GROUP (ORDER BY a.date_diff) OVER (PARTITION BY a.region_id) as percentile_9 
FROM(    
        SELECT
        cn.region_id,
        r.region_name,
        CAST(DATEDIFF(day, cn.start_date, cn.end_date) AS int) AS date_diff
        FROM data_bank.customer_nodes cn
        INNER JOIN data_bank.regions r ON cn.region_id = r.region_id
        WHERE cn.end_date <> '9999-12-31' --There is some data that need to be removed since it screws the statistic 
) a
ORDER BY a.region_id;

--B. Customer Transactions
SELECT * FROM data_bank.customer_transactions
ORDER BY customer_id

-- B.1 What is the unique count and total amount for each transaction type?
SELECT
    ct.txn_type,
    count(ct.txn_type) as total_transactions,
    sum(ct.txn_amount) as total_amount
FROM data_bank.customer_transactions ct
GROUP BY ct.txn_type;

-- B.2 What is the average total historical deposit counts and amounts for all customers?

SELECT
    AVG(a.total_transactions) as avg_nr_deposits,
    AVG(a.total_amount) as avg_amount_per_deposit
FROM(
    SELECT
        ct.customer_id,
        count(*) as total_transactions,
        avg(ct.txn_amount) as total_amount
    FROM data_bank.customer_transactions ct
    WHERE ct.txn_type = 'deposit'
    GROUP BY ct.customer_id
)a;

-- B.3 For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

SELECT
    year_month,
    COUNT(CASE
            WHEN deposit > 1 AND (purchase =1 OR withdrawal =1) THEN 1
            ELSE NULL
        END) AS nr_customers
FROM(
    SELECT
        ct.customer_id,
        FORMAT(ct.txn_date, 'yyyy-MM') as year_month,
        SUM(CASE
                WHEN ct.txn_type = 'deposit' Then 1
                ELSE 0
            END) AS deposit,
        SUM(CASE
                WHEN ct.txn_type = 'purchase' Then 1
                ELSE 0
            END) AS purchase,
        SUM(CASE
                WHEN ct.txn_type = 'withdrawal' Then 1
                ELSE 0
            END) AS withdrawal
    FROM data_bank.customer_transactions ct
    GROUP BY ct.customer_id, FORMAT(ct.txn_date, 'yyyy-MM')
)a
GROUP BY year_month

-- Another solution

SELECT
    year_month,
    COUNT(b.customer_id) AS nr_customers
FROM(
    SELECT
        ct.customer_id,
        FORMAT(ct.txn_date, 'yyyy-MM') as year_month,
        SUM(CASE
                WHEN ct.txn_type = 'deposit' Then 1
                ELSE 0
            END) AS deposit,
        SUM(CASE
                WHEN ct.txn_type = 'purchase' Then 1
                ELSE 0
            END) AS purchase,
        SUM(CASE
                WHEN ct.txn_type = 'withdrawal' Then 1
                ELSE 0
            END) AS withdrawal
    FROM data_bank.customer_transactions ct
    GROUP BY ct.customer_id, FORMAT(ct.txn_date, 'yyyy-MM')
)b
WHERE b.deposit > 1 AND (b.purchase = 1 OR b.withdrawal = 1) -- uses where condition in the end
GROUP BY year_month

-- B.4 What is the closing balance for each customer at the end of the month?

DROP TABLE IF EXISTS #monthly_balance

SELECT
    ct.customer_id,
    FORMAT(ct.txn_date, 'yyyy-MM') as year_month,
    sum(CASE
        WHEN ct.txn_type = 'deposit' THEN txn_amount
        ELSE -ct.txn_amount
    END) AS amount
INTO #monthly_balance
FROM data_bank.customer_transactions ct
GROUP BY ct.customer_id, FORMAT(ct.txn_date, 'yyyy-MM')
ORDER BY customer_id;

SELECT * FROM #monthly_balance
ORDER BY customer_id, year_month

SELECT
    customer_id,
    year_month,
    SUM(amount) OVER(PARTITION BY customer_id ORDER BY year_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as balance
FROM #monthly_balance;

SELECT * FROM #monthly_balance
ORDER BY customer_id

-- B.5 What is the percentage of customers who increase their closing balance by more than 5%?

DECLARE @total_customers int = (SELECT COUNT(DISTINCT customer_id)
								FROM data_bank.customer_transactions);

WITH rank_cte as(
    SELECT
        customer_id,
        year_month,
        SUM(amount) OVER(PARTITION BY customer_id ORDER BY year_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as balance,
        RANK() OVER (PARTITION BY customer_id ORDER BY year_month) as rank
    FROM #monthly_balance
),

max_rank_cte as(
    SELECT
        customer_id,
        MAX(rank) as max_rank
    FROM rank_cte
    GROUP BY customer_id
),

joining_cte as(
    SELECT
        r.customer_id,
        r.year_month,
        r.balance,
        r.rank,
        mr.max_rank
    FROM rank_cte r
    INNER JOIN max_rank_cte mr ON r.customer_id = mr.customer_id
    WHERE r.rank = 1 OR r.rank = mr.max_rank
),

percentage_cte as (
    SELECT
        customer_id,
        year_month,
        balance,
        CASE
            WHEN balance < 0 OR LAG(balance,1) OVER (PARTITION BY customer_id ORDER BY year_month) IS NULL THEN NULL
            ELSE (balance - LAG(balance,1) OVER (PARTITION BY customer_id ORDER BY year_month)) / CAST(LAG(balance,1) OVER (PARTITION BY customer_id ORDER BY year_month) as FLOAT) * 100
            END as growth
    FROM joining_cte
),

final_cte as(
    SELECT
        customer_id,
        year_month,
        balance,
        ROUND(growth, 2) as rounded_growth
    FROM percentage_cte
    WHERE growth > 0 and growth is not NULL
)

--SELECT * FROM final_cte

SELECT ROUND(COUNT(customer_id)/CAST(@total_customers as float) * 100,2) as nr_customers_growth_more_than_5
FROM final_cte
WHERE rounded_growth > 5.00

--C. Data Allocation Challenge

-- 1. Calculate running customer balance column that includes the impact of each transaction

DROP TABLE IF EXISTS #running_customer_balance;

WITH amount_cte AS(
    SELECT
        ct.customer_id,
        ct.txn_date,
        ct.txn_type,
        ct.txn_amount,
        CASE
            WHEN ct.txn_type = 'deposit' THEN ct.txn_amount
            ELSE -ct.txn_amount
        END AS amount
    FROM data_bank.customer_transactions ct
)

SELECT
    customer_id,
    txn_date,
    txn_type,
    amount,
    sum(amount) OVER (PARTITION BY customer_id ORDER BY txn_date) AS runing_balance
    INTO #running_customer_balance
    FROM amount_cte
ORDER BY customer_id

SELECT * FROM #running_customer_balance
ORDER BY customer_id;

-- 2. Calculate customer balance at the end of each month
-- we could have used cte's instead of sub-quering

DROP TABLE IF EXISTS #monthly_customer_balance;
SELECT 
    customer_id,
    year_month,
    SUM(monthly_amount) OVER (PARTITION BY customer_id ORDER BY year_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS monthly_balance
INTO #monthly_customer_balance
FROM(
    SELECT 
        customer_id,
        FORMAT(txn_date, 'yyyy-MM') as year_month,
        sum (amount) as monthly_amount
    FROM #running_customer_balance rcb
    GROUP BY customer_id, FORMAT(txn_date, 'yyyy-MM')
)a;

SELECT * FROM #monthly_customer_balance
ORDER BY customer_id, year_month;

-- 3. Minimum, average and maximum values of the running balance for each customer

DROP TABLE IF EXISTS #running_customer_balance_statistics;
SELECT
    customer_id,
    FORMAT(txn_date, 'yyyy-MM') as year_month,
    MIN(runing_balance) as min,
    AVG(runing_balance) as avg,
    MAX(runing_balance) as max
INTO #running_customer_balance_statistics
FROM #running_customer_balance
GROUP BY customer_id,FORMAT(txn_date, 'yyyy-MM');

SELECT * FROM #running_customer_balance_statistics
ORDER BY customer_id, year_month

/*
Help the Data Bank team estimate how much data will need to be provisioned for each option:
	- Option 1: data is allocated based off the amount of money at the end of the previous month
	- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
	- Option 3: data is updated real-time

Using all of the data available - how much data would have been required for each option on a monthly basis?
*/

-- Option 1: data is allocated based off the amount of money at the end of the previous month

SELECT
    year_month,
    CASE
        WHEN LAG(total_monthly_data,1) OVER (ORDER BY year_month) IS NULL THEN total_monthly_data
        ELSE LAG(total_monthly_data,1) OVER (ORDER BY year_month)
    END AS previous_month_data
FROM(
    SELECT
        year_month,
        sum(IIF(monthly_balance > 0,monthly_balance,0)) as total_monthly_data -- Return "YES" if the condition is TRUE, or "NO" if the condition is FALSE: SELECT IIF(500<1000, 'YES', 'NO');
    FROM #monthly_customer_balance
    GROUP BY year_month
)a;

-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

SELECT
    year_month,
    CASE
        WHEN LAG(avg_monthly_data,1) OVER (ORDER BY year_month) IS NULL THEN avg_monthly_data
        ELSE LAG(avg_monthly_data,1) OVER (ORDER BY year_month)
    END AS previous_month_data
FROM(
    SELECT
        year_month,
        sum(IIF(avg > 0,avg,0)) as avg_monthly_data -- Return "YES" if the condition is TRUE, or "NO" if the condition is FALSE: SELECT IIF(500<1000, 'YES', 'NO');
    FROM #running_customer_balance_statistics
    GROUP BY year_month
)a;

-- Option 3: data is updated real-time

SELECT
        FORMAT(txn_date, 'yyyy-MM') as year_month,
        sum(IIF(runing_balance > 0,runing_balance,0)) as runing_monthly_data -- Return "YES" if the condition is TRUE, or "NO" if the condition is FALSE: SELECT IIF(500<1000, 'YES', 'NO');
    FROM #running_customer_balance
    GROUP BY FORMAT(txn_date, 'yyyy-MM');

