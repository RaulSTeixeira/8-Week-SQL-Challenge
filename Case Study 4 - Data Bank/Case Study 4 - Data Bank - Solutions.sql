--------------------------
-- CASE STUDY QUESTIONS --
--------------------------

USE CaseStudy4
GO

--A. Customer Nodes Exploration
SELECT * FROM data_bank.customer_nodes;

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

