CREATE DATABASE Lesson4
use Lesson4

DROP TABLE [dbo].[University_info (rev2)]




SELECT *
INTO #dk2 
FROM metro_startup_ranking
WHERE Startup_Rank <= (select COUNT(Startup_Rank) from metro_startup_ranking M) * 0.25



WITH cte_a as (SELECT *,PERCENT_RANK() OVER (ORDER BY COALESCE(ViolentCrime,0)
         +COALESCE(Murder,0)
         +COALESCE(Rape,0)
         +COALESCE(Robbery,0)
         +COALESCE(AggravatedAssault,0)
         +COALESCE(PropertyCrime,0)
         +COALESCE(Burglary,0)
         +COALESCE(Theft,0)
         +COALESCE(MotorVehicleTheft,0)) AS RANK from Crime)

SELECT City,RANK
FROM cte_a
WHERE RANK < 0.5 
ORDER BY RANK DESC



SELECT *
INTO #dk1
FROM [dbo].[University_info (1)]
WHERE LOCALE in (11,12,13)




SELECT * , Case 
                when UNITID in ( select UNITID 
                                from [University_info (1)] 
                                WHERE LOCALE in (11,12,13) and PCIP11 > 0
                and CITY in ( SELECT Metro_Area_Main_City
                            FROM metro_startup_ranking
                            WHERE Startup_Rank <= (select COUNT(*) from metro_startup_ranking M) * 0.25 )   
                and CITY in ( select CITY 
                            from (SELECT *,PERCENT_RANK() OVER (ORDER BY COALESCE(ViolentCrime,0)
                                                                        +COALESCE(Murder,0)
                                                                        +COALESCE(Rape,0)
                                                                        +COALESCE(Robbery,0)
                                                                        +COALESCE(AggravatedAssault,0)
                                                                        +COALESCE(PropertyCrime,0)
                                                                        +COALESCE(Burglary,0)
                                                                        +COALESCE(Theft,0)
                                                                        +COALESCE(MotorVehicleTheft,0)) AS RANK 
                                from Crime ) a
                                WHERE RANK <= 0.5 ) )
                THEN 'yes'
                else 'no'
                end as Recommend
FROM [University_info (1)]



-- INTEREST	- all possible interest rates from data (listed lowest to highest)
-- CREDIT_AMOUNT_SUM	- sum of amounts with this interest 
-- CREDIT_AMOUNT_MAX	- maximum amount with this interest 
-- Accs	- number of accounts with this interest

/*
SELECT interest,
        sum(CREDIT_AMOUNT) as CREDIT_AMOUNT_SUM,
        count(ID) as Accs,
        Max(CREDIT_AMOUNT) as CREDIT_AMOUNT_MAX
from view_credit 
where interest < 0,18 
group by interest 


*/








use dannys_diner;

-- 1 What is the total amount each customer spent at the restaurant?
SELECT * FROM menu
SELECT * FROM members
SELECT * FROM sales

SELECT s.customer_id , SUM(m.price) total_amount
FROM sales s LEFT join menu m on s.product_id=m.product_id
GROUP by customer_id


-- 2 How many days has each customer visited the restaurant?
SELECT s.customer_id , count(DISTINCT order_date) AS spent_day
FROM sales s 
GROUP by customer_id


-- 3 What was the first item from the menu purchased by each customer?
SELECT customer_id , 
        product_name
       
FROM 
        ( select  s.customer_id , 
                m.product_name,
                s.order_date,
                RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as rank 
         from sales s 
                LEFT join menu m on s.product_id=m.product_id 
                LEFT JOIN members b ON s.customer_id=b.customer_id ) a 
where rank = 1
GROUP by customer_id,product_name


-- 4 What is the most purchased item on the menu and how many times was it purchased by all customers? 
SELECT top 1
        m.product_name, 
       COUNT(s.customer_id) as times 
FROM sales s LEFT join menu m on s.product_id=m.product_id
GROUP BY m.product_name
ORDER BY times DESC;


-- 5 Which item was the most popular for each customer?
SELECT customer_id,
       product_name
FROM (
        select s.customer_id,
               m.product_name,
               COUNT(m.product_name) as times,
               RANK() OVER (PARTITION by s.customer_id order by COUNT(m.product_name)) as rank 
        FROM sales s LEFT join menu m on s.product_id=m.product_id
        GROUP by s.customer_id,m.product_name ) a
where rank = 1


-- 6 Which item was purchased first by the customer after they became a member?
SELECT top 1 with ties 
        s.customer_id,
        m.product_name
from sales s 
        LEFT join menu m on s.product_id=m.product_id 
        LEFT JOIN members b ON s.customer_id=b.customer_id 
WHERE b.join_date < s.order_date 
ORDER by ROW_NUMBER() OVER (partition by s.customer_id order by s.order_date)


-- 7 Which item was purchased just before the customer became a member?
SELECT customer_id , 
        product_name
       
FROM 
        ( select  s.customer_id , 
                m.product_name,
                s.order_date,
                RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) as rank 
         from sales s 
                LEFT join menu m on s.product_id=m.product_id 
                LEFT JOIN members b ON s.customer_id=b.customer_id 
         WHERE b.join_date > s.order_date) a 
where rank = 1
GROUP by customer_id,product_name


-- 8 What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
        SUM(price) amount,
        count (distinct s.product_id) items 
from sales s 
        LEFT join menu m on s.product_id=m.product_id 
        LEFT JOIN members b ON s.customer_id=b.customer_id 
WHERE b.join_date > s.order_date
GROUP by s.customer_id


-- 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id,
        SUM(tp.points) as points 
FROM sales s 
        LEFT JOIN (select *,
                            case when product_name = 'sushi' then price*20 
                            else price*10 end points 
                            from menu ) tp on s.product_id=tp.product_id 
GROUP by s.customer_id 


-- 10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--    not just sushi - how many points do customer A and B have at the end of January?
SELECT
        customer_id,
        SUM(points) as points 
FROM ( select s.customer_id,
                        case when product_name = 'sushi' and 
                                  s.order_date between DATEADD(DAY,-1,b.join_date) and 
                                  DATEADD(DAY,6,b.join_date) then price*40 
                             when product_name = 'sushi' or 
                                  s.order_date between DATEADD(DAY,-1,b.join_date) and 
                                  DATEADD(DAY,6,b.join_date) then price*20
                        else price*10 end points
        from members b
	left join sales s on s.customer_id = b.customer_id
	left join menu m on s.product_id = m.product_id
        WHERE s.order_date <= '20210131') a
GROUP BY  customer_id 


-- Join All The Things 
SELECT
        s.customer_id,s.order_date,m.product_name,m.price,
        case when s.order_date >= b.join_date then 'Y'
             else 'N' end 'Y/N'
from sales s 
        LEFT join menu m on s.product_id=m.product_id 
        LEFT JOIN members b ON s.customer_id=b.customer_id 
ORDER BY s.customer_id,s.order_date,m.product_name



-- Rank All The Things
SELECT *, case when member = 'Y' then RANK() over (partition by customer_id,member order by order_date) 
                else null end rankking 
from (SELECT
        s.customer_id,s.order_date,m.product_name,m.price,
        case when s.order_date >= b.join_date then 'Y'
                else 'N' end member
        from sales s 
        LEFT join menu m on s.product_id=m.product_id 
        LEFT JOIN members b ON s.customer_id=b.customer_id ) a 
ORDER by customer_id, order_date,product_name





















-- clean data 

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





select * 
from pizza_recipes
use pizza_runner




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
WHERE r.distance != 0
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
        c.order_id,
        COUNT(c.pizza_id) pizzas_orders
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.distance != 0 
GROUP BY c.order_id
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
SELECT c.customer_id,
        c.order_id,
        r.pickup_time,
        DATEDIFF(MINUTE,c.order_time,r.pickup_time) as pickup_mintes
FROM #customer_orders_temp c 
        JOIN #runner_orders_temp r 
        ON c.order_id=r.order_id
WHERE r.distance != 0 
GROUP BY c.customer_id,c.order_id,r.pickup_time,DATEDIFF(MINUTE,c.order_time,r.pickup_time) ) 
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
GROUP BY c.order_time,c.order_id,r.pickup_time )
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
       round(duration/60, 2) AS duration_hr,
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
        










--  C. Ingredient Optimisation

-- 1 What are the standard ingredients for each pizza?


-- 2 What was the most commonly added extra?


-- 3 What was the most common exclusion?


-- 4 Generate an order item for each record in the customers_orders table in the format of one of the following:
--   Meat Lovers
--   Meat Lovers - Exclude Beef
--   Meat Lovers - Extra Bacon
--   Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


-- 5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from 
--   the customer_orders table and add a 2x in front of any relevant ingredients
--   For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"



-- 6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?




