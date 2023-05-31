

-- cleaning data
DROP TABLE IF EXISTS #customer_orders_temp;
SELECT order_id,customer_id,pizza_id,
        case 
            when exclusions = '' then NULL 
            when exclusions = 'null' then NULL 
            else exclusions 
            end as exclusions, 
        case 
            when extras = '' then NULL
            when extras = 'null' then NULL 
            else extras 
            end as extras,
        order_time
INTO #customer_orders_temp
FROM customer_orders;
SELECT * from #customer_orders_temp;


DROP TABLE IF EXISTS #runner_orders_temp;
SELECT order_id,runner_id,
        case 
            when pickup_time = 'null' then NULL 
            else pickup_time 
            end as pickup_time,
        case 
            when distance = 'null' then NULL 
            when distance LIKE '%km' then TRIM('km ' from distance)
            else distance
            end as distance,
        case 
            when duration = 'null' then NULL
            when duration LIKE '%mins' then TRIM('mins' from duration)
            when duration LIKE '%minutes' then TRIM('minutes' from duration)
            when duration LIKE '%minute' then TRIM('minute' from duration)
            else duration
            end as duration,
        case 
            when cancellation = 'null' then NULL
            when cancellation = '' then NULL
            else cancellation
            end as cancellation
INTO #runner_orders_temp
from runner_orders;
SELECT * FROM #runner_orders_temp

ALTER TABLE #runner_orders_temp
ALTER COLUMN pickup_time DATETIME;
ALTER TABLE #runner_orders_temp
ALTER COLUMN distance FLOAT;
ALTER TABLE #runner_orders_temp
ALTER COLUMN duration INT;

ALTER TABLE pizza_recipes
ALTER COLUMN toppings INT
ALTER TABLE pizza_names
ALTER COLUMN pizza_name NVARCHAR(MAX)


-- A. Pizza Metrics
-- 1 How many pizzas were ordered?
SELECT COUNT(*) NO_order
FROM customer_orders
SELECT *
FROM customer_orders


-- 2 How many unique customer orders were made?
SELECT COUNT(distinct order_id ) unique_cus
FROM customer_orders

-- 3 How many successful orders were delivered by each runner?
select runner_id,
	count(order_id) as orders
FROM #runner_orders_temp
where cancellation IS NULL
GROUP BY runner_id

-- 4 How many of each type of pizza was delivered?
SELECT n.pizza_name,
        COUNT(c.pizza_id) deliverd
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
        JOIN pizza_names n 
        ON c.pizza_id=n.pizza_id
WHERE r.cancellation IS NULL
GROUP BY pizza_name



-- 5 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id,
        n.pizza_name,
        COUNT(n.pizza_name) pizzas_orders
FROM #customer_orders_temp c 
        JOIN pizza_names n 
        ON c.pizza_id=n.pizza_id
GROUP BY c.customer_id,n.pizza_name
ORDER BY c.customer_id



-- 6 What was the maximum number of pizzas delivered in a single order?
WITH cte_a AS
(SELECT c.order_id,
        COUNT(c.pizza_id) count
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.distance != 0 
GROUP BY c.order_id)
SELECT MAX(count) as pizza_delivered_order
FROM cte_a ;

SELECT 
TOP 1
        c.customer_id,
        c.order_id,
        COUNT(c.pizza_id) pizzas_orders
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.distance != 0 
GROUP BY c.order_id,c.customer_id
ORDER BY COUNT(c.pizza_id) DESC




-- 7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT c.customer_id,
        SUM(
                case when c.exclusions is not NULL or c.extras is not NULL THEN 1 
                else 0 
                end) as at_least_1_change,
        SUM(
                case when c.exclusions is NULL and c.extras is NULL THEN 1 
                else 0 
                end) as no_change
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.distance != 0 
GROUP BY c.customer_id



-- 8 How many pizzas were delivered that had both exclusions and extras?
SELECT c.customer_id,
        SUM( case when (c.exclusions is not NULL and c.extras is not NULL) then 1 
                else 0 
                end ) as had_both 
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.cancellation is NULL
GROUP BY customer_id

-- 9 What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR,order_time) hour,
    
        COUNT(order_time) as pizza_ordered 
FROM #customer_orders_temp
GROUP BY DATEPART(HOUR,order_time)


-- 10 What was the volume of orders for each day of the week?
SELECT 
        FORMAT(DATEADD(DAY,2,order_time),'dddd') as 'day of week' -- add 2 to adjust 1st day of the week as Monday,+
        ,COUNT(order_time) as pizza_count
FROM #customer_orders_temp
GROUP BY FORMAT(DATEADD(DAY,2,order_time),'dddd')




-- B. Runner and Customer Experience

-- Returned week number is between 0 and 52 or 0 and 53.
-- Default mode of the week =0 -> First day of the week is Sunday
-- Extract week -> WEEK(registration_date) or EXTRACT(week from registration_date)

-- 1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATEPART(WEEK,registration_date) as 'registration week',
        COUNT(runner_id) 'NO runner'
FROM runners
GROUP BY DATEPART(WEEK,registration_date);


-- 2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with cte_b as (
        SELECT  c.customer_id,
                c.order_id,
                r.pickup_time,
                DATEDIFF(MINUTE,c.order_time,r.pickup_time) as pickup_mintes
        FROM #customer_orders_temp c 
                JOIN #runner_orders_temp r 
                ON c.order_id=r.order_id
        WHERE r.distance != 0 
        GROUP BY c.customer_id,
                c.order_id,
                r.pickup_time,
                DATEDIFF(MINUTE,c.order_time,r.pickup_time) 
) 

SELECT AVG(pickup_mintes) as 'avg pickup minutes'
FROM cte_b


-- 3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
with prep_time as (
SELECT COUNT(c.order_id) pizza_order,
        c.order_id,
        r.pickup_time,
        c.order_time,
        DATEDIFF(MINUTE,c.order_time,r.pickup_time) as pre_pickup_times
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.distance != 0 
GROUP BY c.order_time,c.order_id,r.pickup_time 
)
SELECT  pizza_order,
        AVG(pre_pickup_times) as avg_prep_times
FROM prep_time
WHERE pre_pickup_times > 1 
GROUP BY pizza_order

-- 4 What was the average distance travelled for each customer?
SELECT c.customer_id,
        AVG(r.distance) 'avg distance'
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.distance != 0 
GROUP BY c.customer_id

-- 5 What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration) Max_duration,
        MIN(duration) Min_duration,
        MAX(duration) - MIN(duration) as difference_durattion
FROM #runner_orders_temp

-- 6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,
       distance AS distance_km,
       round(duration/60,2) AS duration_hr,
       round(distance*60/duration, 2) AS avg_speed
FROM #runner_orders_temp
WHERE cancellation IS NULL
ORDER BY runner_id;


-- 7  What is the successful delivery percentage for each runner?
SELECT runner_id,
        COUNT(pickup_time) as 'delivered orders',
        COUNT(*) total_orders,
        ROUND(100* SUM(
                        case when distance is NULL then 0
                        else 1 
                        END ) / COUNT(*) , 0) as 'delivery success per'
FROM #runner_orders_temp
GROUP BY runner_id