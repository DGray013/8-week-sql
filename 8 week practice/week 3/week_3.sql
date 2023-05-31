
ALTER TABLE subscriptions
ALTER COLUMN customer_id FLOAT;

-- Data Analysis Questions
SELECT * FROM plans
SELECT * FROM subscriptions

-- 1 How many customers has Foodie-Fi ever had?
SELECT COUNT(distinct customer_id) as total_cus
From subscriptions 

-- 2 What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT MONTH(s.start_date) as monthly,
       COUNT(distinct customer_id) as total_cus_trial
FROM plans p JOIN subscriptions s ON p.plan_id=s.plan_id
WHERE s.plan_id = 0
GROUP BY MONTH(s.start_date)

-- 3 What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT s.plan_id,
       p.plan_name,
       COUNT(*) as events
FROM plans p JOIN subscriptions s ON p.plan_id=s.plan_id
WHERE year(s.start_date) > 2020
GROUP BY s.plan_id, p.plan_name


-- 4 What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT p.plan_name,
       COUNT(distinct customer_id) as total_cus_chrun,
       ROUND((count(DISTINCT customer_id)*100) / (
                                                SELECT count(DISTINCT customer_id) AS 'distinct customers'
                                                FROM subscriptions
                                                ),2) as 'churn percentage'
FROM plans p JOIN subscriptions s ON p.plan_id=s.plan_id
WHERE p.plan_id = 4 
GROUP BY p.plan_name;

WITH counts_cte AS
  (SELECT plan_name,
          count(DISTINCT customer_id) AS distinct_customer_count,
          SUM(CASE
                  WHEN p.plan_id=4 THEN 1
                  ELSE 0
              END) AS churned_customer_count
FROM plans p JOIN subscriptions s ON p.plan_id=s.plan_id
WHERE p.plan_id = 4
GROUP BY plan_name
)
SELECT *,
       round((100*(churned_customer_count)/distinct_customer_count), 2) AS churn_percentage
FROM counts_cte;

-- 5 How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH next_plan_cte as (
  SELECT 
    *, 
    LEAD(plan_id, 1) OVER (
      partition by customer_id 
      ORDER by 
        plan_id
    ) as next_plan 
  FROM 
    subscriptions
), 
Chrun as (
  SELECT 
    * 
  from 
    next_plan_cte 
  where 
    next_plan = 4 
    and plan_id = 0
) 
SELECT 
  count(customer_id) AS 'churn after trial count', 
  round(
    100 * count(customer_id)/ (
                                SELECT 
                                    count(DISTINCT customer_id) AS 'distinct customers' 
                                FROM 
                                    subscriptions
    ), 
    2) AS 'churn percentage' 
From Chrun

-- 6 What is the number and percentage of customer plans after their initial free trial?
SELECT p.plan_name,
       COUNT(distinct customer_id) as total_cus,
       ROUND((count(DISTINCT customer_id)*100) / (
                                                SELECT count(DISTINCT customer_id) AS 'distinct customers'
                                                FROM subscriptions
                                                ),2) as 'CUS percentage'
FROM plans p JOIN subscriptions s ON p.plan_id=s.plan_id
--WHERE p.plan_name != 'trial'
WHERE p.plan_id != 0
GROUP BY p.plan_name;

WITH previous_plan_cte AS
  (SELECT *,
          lag(p.plan_id, 1) over(PARTITION BY customer_id
                               ORDER BY start_date) AS previous_plan
   FROM plans p JOIN subscriptions s ON p.plan_id=s.plan_id
   )
SELECT *,
       count(customer_id) customer_count,
       round(100 *count(DISTINCT customer_id) /
               (SELECT count(DISTINCT customer_id) AS 'distinct customers'
                FROM subscriptions), 2) AS 'customer percentage'
FROM previous_plan_cte
WHERE previous_plan=0
GROUP BY plan_name ;

WITH next_plan_cte AS (
SELECT 
  customer_id, 
  plan_id, 
  LEAD(plan_id, 1) OVER( -- Offset by 1 to retrieve the immediate row's value below 
    PARTITION BY customer_id 
    ORDER BY plan_id) as next_plan
FROM subscriptions)

SELECT 
  next_plan, 
  COUNT(*) AS conversions,
  ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),1) AS conversion_percentage
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan
ORDER BY next_plan;


-- 7 What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH next_plan AS(
  SELECT 
    customer_id, 
    plan_id, 
    start_date, 
    LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date) as next_date 
  FROM 
    subscriptions 
  WHERE 
    start_date <= '2020-12-31'
), 
customer_breakdown AS (
  SELECT 
    plan_id, 
    COUNT(DISTINCT customer_id) AS customers 
  FROM 
    next_plan 
  WHERE 
    (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31')) 
    OR (next_date IS NULL AND start_date < '2020-12-31') 
  GROUP BY 
    plan_id
) 
SELECT 
  plan_id, 
  customers, 
  ROUND(100 * customers / (
                            SELECT 
                            COUNT(DISTINCT customer_id) 
                            FROM 
                            subscriptions
    ), 1) AS percentage 
FROM 
  customer_breakdown 
GROUP BY 
  plan_id, 
  customers 
ORDER BY 
  plan_id


-- 8 How many customers have upgraded to an annual plan in 2020?
SELECT plan_id,
       COUNT(DISTINCT customer_id) AS annual_plan_customer_count
FROM subscriptions
WHERE plan_id = 3
  AND year(start_date) = 2020
GROUP BY plan_id;

-- 9 How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_plan AS 
(SELECT 
  customer_id, 
  start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0
),
annual_plan AS
(SELECT 
  customer_id, 
  start_date AS annual_date
FROM subscriptions
WHERE plan_id = 3
)
SELECT 
  ROUND(AVG(DATEDIFF(DAY,trial_date,annual_date)),2) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap
  ON tp.customer_id = ap.customer_id;


-- 10 Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial_plan AS (
  SELECT 
  customer_id, 
  start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0
),
annual_plan AS (
  SELECT 
  customer_id, 
  start_date AS annual_date
FROM subscriptions
WHERE plan_id = 3
),
-- Sort values above in buckets of 12 with range of 30 days each
bins AS (
  SELECT 
(DATE_BUCKET(day,1,trial_date,annual_date)) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap
  ON tp.customer_id = ap.customer_id
  )
SELECT 
  ((avg_days_to_upgrade - 1) * 30 + ' - ' + (avg_days_to_upgrade) * 30) + ' days' AS breakdown, 
  COUNT(*) AS customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;







DROP TABLE IF EXISTS #trial_plan, #annual_plan, #date_diff;
SELECT s.customer_id, s.start_date AS start_trial
INTO #trial_plan
FROM subscriptions s
INNER JOIN plans p
    ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial';

SELECT s.customer_id, s.start_date AS start_annual
INTO #annual_plan
FROM subscriptions s
INNER JOIN plans p
    ON s.plan_id = p.plan_id
WHERE p.plan_name = 'pro annual';

SELECT t.customer_id, DATEDIFF(d, t.start_trial, a.start_annual) AS diff
INTO #date_diff
FROM #trial_plan t
INNER JOIN #annual_plan a
    ON t.customer_id = a.customer_id;

WITH periods AS (
    SELECT 0 AS start_period, 
        30 AS end_period
    UNION ALL
    SELECT end_period + 1 AS start_period,
        end_period + 30 AS end_period
    FROM periods
    WHERE end_period < 360
)

SELECT p.start_period ,
    p.end_period,
    COUNT(*) AS customer_count
FROM periods p
LEFT JOIN #date_diff d
    ON (d.diff >= p.start_period AND d.diff <= p.end_period)
GROUP BY p.start_period, p.end_period;





-- 11 How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH next_plan_cte AS (
  SELECT 
    customer_id, 
    plan_id, 
    start_date, 
    LEAD(plan_id, 1) OVER(
      PARTITION BY customer_id 
      ORDER BY 
        plan_id
    ) as next_plan 
  FROM 
    subscriptions
) 
SELECT 
  COUNT(*) AS downgraded 
FROM 
  next_plan_cte 
WHERE 
  start_date <= '2020-12-31' 
  AND plan_id = 2 
  AND next_plan = 1;