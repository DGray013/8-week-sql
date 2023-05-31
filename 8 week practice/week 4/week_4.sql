SELECT * FROM customer_nodes;
SELECT * FROM customer_transactions;
SELECT * FROM regions;

SELECT COUNT(*) FROM customer_nodes 
SELECT COUNT(*) FROM customer_transactions

-- A. Customer Nodes Exploration
-- 1 How many unique nodes are there on the Data Bank system?
SELECT COUNT(distinct node_id ) as 'unique nodes'
FROM customer_nodes;

-- 2 What is the number of nodes per region?
SELECT r.region_id,
    r.region_name,
    COUNT(*) as nodes_count
FROM customer_nodes cn JOIN regions r ON cn.region_id=r.region_id
GROUP BY r.region_id,
     r.region_name
ORDER BY r.region_id;
    

-- 3 How many customers are allocated to each region?
SELECT r.region_id,
    r.region_name,
    COUNT(distinct cn.customer_id) as cus_count
FROM customer_nodes cn JOIN regions r ON cn.region_id=r.region_id
GROUP BY r.region_id,
     r.region_name
ORDER BY r.region_id;


-- 4 How many days on average are customers reallocated to a different node?
SELECT ROUND(avg(DATEDIFF(day,start_date,end_date)),2) as avg_days
FROM customer_nodes
WHERE end_date != '9999-12-31'


with cte_a as (
    SELECT customer_id,node_id,start_date,end_date,
            DATEDIFF(day,start_date,end_date) as days_diff
    from customer_nodes
    where end_date != '9999-12-31'
    GROUP BY customer_id,node_id,start_date,end_date
   
), sum_days_diff as (
    SELECT customer_id,node_id,
        SUM(days_diff) as sum_diff
    FROM cte_a
    GROUP BY customer_id,node_id
)
SELECT ROUND(avg(sum_diff),2) as avg_reallocation_days
FROM sum_days_diff;



-- 5 What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH reallocation_days_cte AS
  (SELECT *,
          (datediff(day,end_date, start_date)) AS reallocation_days
    FROM customer_nodes cn 
        JOIN regions r 
        ON cn.region_id=r.region_id
   WHERE end_date!='9999-12-31'),
     percentile_cte AS
  (SELECT *,
          percent_rank() over(PARTITION BY region_id
                              ORDER BY reallocation_days)*100 AS p
   FROM reallocation_days_cte)
SELECT region_id,
       region_name,
       reallocation_days
FROM percentile_cte
WHERE p > 95
GROUP BY region_id;





WITH CTE AS (
            SELECT region_id,
                    DATEDIFF(day,start_date,end_date) as allocation_days
            FROM customer_nodes
            WHERE end_date != '9999-12-31'
            )

SELECT distinct region_id , 
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY allocation_days) OVER (PARTITION BY region_id) AS 'median',
        PERCENTILE_DISC(0.8) WITHIN GROUP (ORDER BY allocation_days) OVER (PARTITION BY region_id) AS '80th_percentile',
        PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY allocation_days) OVER (PARTITION BY region_id) AS '95TH_percentile'
FROM CTE


-- B. Customer Transactions
-- 1 What is the unique count and total amount for each transaction type?
SELECT  txn_type,
        COUNT(*) as NO_trans,
        SUM(txn_amount) as total_amount
FROM customer_transactions
GROUP BY txn_type;


-- 2 What is the average total historical deposit counts and amounts for all customers?
WITH deposit_cte as (
            SELECT  customer_id,
                    COUNT( customer_id) as times_deposit,
                    ROUND(AVG(txn_amount),2) as amout_deposit 
            FROM customer_transactions
            WHERE txn_type = 'deposit'
            GROUP BY customer_id
)
SELECT AVG(times_deposit) as avg_times,
        ROUND(AVG(amout_deposit),2) as avg_amount
FROM deposit_cte;


-- 3 For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
with monthly_trans as (
        SELECT customer_id,
                DATEPART(MONTH,txn_date) as monthly_tran,
                SUM(CASE 
                        when txn_type = 'deposit' then 1 else 0 end ) AS deposit_count,
                SUM(CASE 
                        when txn_type = 'withdrawal' then 1 else 0 end ) AS withdrawal_count,
                SUM(CASE 
                        when txn_type = 'purchase' then 1 else 0 end ) AS purchase_count
        from customer_transactions
        GROUP BY customer_id,
                DATEPART(MONTH,txn_date)
)
SELECT monthly_tran,
    COUNT(*) as customer_count 
FROM monthly_trans
WHERE deposit_count > 1 
    AND ( purchase_count = 1 or withdrawal_count = 1 )
GROUP BY monthly_tran;



-- 4 What is the closing balance for each customer at the end of the month?
with monthly_trans as (
        SELECT customer_id,
                DATEPART(MONTH,txn_date) as monthly_tran,
                SUM(CASE 
                        when txn_type = 'deposit' then txn_amount else 0 end ) AS deposit_count,
                SUM(CASE 
                        when txn_type = 'withdrawal' then - txn_amount else 0 end ) AS withdrawal_count,
                SUM(CASE 
                        when txn_type = 'purchase' then - txn_amount else 0 end ) AS purchase_count
        from customer_transactions
        GROUP BY customer_id,
                DATEPART(MONTH,txn_date)
), 
cte as (
    SELECT customer_id,
            monthly_tran,
            (deposit_count + withdrawal_count + purchase_count ) as total_amount
    from monthly_trans
)
SELECT  customer_id,
        monthly_tran,
        SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY customer_id,monthly_tran
                                ROWS BETWEEN UNBOUNDED PRECEDING AND current ROW ) AS balance,
        total_amount as change_in_balance 
from cte;


-- 5 What is the percentage of customers who increase their closing balance by more than 5%?

with cte as (
        SELECT customer_id,
                DATEPART(MONTH,txn_date) as monthly_tran,
                SUM(CASE 
                        when txn_type = 'deposit' then txn_amount else 0 end ) AS deposit_count,
                SUM(CASE 
                        when txn_type = 'withdrawal' then - txn_amount else 0 end ) AS withdrawal_count,
                SUM(CASE 
                        when txn_type = 'purchase' then - txn_amount else 0 end ) AS purchase_count
        from customer_transactions
        GROUP BY customer_id,
                DATEPART(MONTH,txn_date)
), 
cte_1 as (
    SELECT customer_id,
            monthly_tran,
            (deposit_count + withdrawal_count + purchase_count ) as total_amount
    from cte
),
cte_2 as (
SELECT  customer_id,
        monthly_tran,
        SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY customer_id,monthly_tran
                                ROWS BETWEEN UNBOUNDED PRECEDING AND current ROW ) AS balance,
        total_amount as change_in_balance 
from cte_1
),
CTE_3 AS (      SELECT distinct customer_id , 
                        first_value(balance) over (partition by customer_id order by customer_id) as start_balance,
                        last_value(balance) over (partition by customer_id order by customer_id) as end_balance
                FROM cte_2 
),

CTE_4 AS (
                SELECT *, 
                ((end_balance - start_balance) * 100 / start_balance) as growing_rate
                FROM CTE_3
                WHERE ((end_balance - start_balance) * 100 / start_balance) >= 5 AND end_balance >start_balance
)
SELECT 
    CAST(COUNT (customer_id) AS FLOAT) * 100 / (SELECT COUNT (DISTINCT customer_id) from customer_transactions) as Percent_Customer
FROM CTE_4
