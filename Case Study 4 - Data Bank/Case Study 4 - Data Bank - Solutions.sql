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
        CAST(DATEDIFF(day, cn.start_date, cn.end_date) AS int) AS date_diff
        FROM data_bank.customer_nodes cn
        WHERE end_date <> '9999-12-31' --There is some data that need to be removed since it screws the statistic 
) a;

-- A.5 What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

SELECT
    DISTINCT a.region_id,
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
ORDER BY a.region_id

--B. Customer Transactions
SELECT * FROM data_bank.customer_transactions
ORDER BY customer_id

-- B.1 What is the unique count and total amount for each transaction type?
SELECT
    ct.txn_type,
    count(ct.txn_type) as total_transactions,
    sum(ct.txn_amount) as total_amount
FROM data_bank.customer_transactions ct
GROUP BY ct.txn_type

-- B.2 What is the average total historical deposit counts and amounts for all customers?

SELECT
    AVG(a.total_transactions) as avg_nr_deposits,
    AVG(a.total_amount) as avg_deposits_amount
FROM(
    SELECT
        ct.customer_id,
        count(*) as total_transactions,
        avg(ct.txn_amount) as total_amount
    FROM data_bank.customer_transactions ct
    WHERE ct.txn_type = 'deposit'
    GROUP BY ct.customer_id
)a
