SELECT * FROM Orders


with A as (
            select COUNT(OrderID) as tong_order,
                    SUM(Freight) as Amount
                    FROM Orders 
)
SELECT *,ROW_NUMBER() OVER ( ORDER BY Freight DESC ) row_1 
FROM A








WITH order_stats AS (
  SELECT 
    COUNT(*) AS total_orders,
    SUM(Freight) AS total_freight
  FROM Orders
),
employee_stats AS (
  SELECT 
    CEILING(AVG(total_orders) * 1.0 / 6) AS orders_per_employee,
    CEILING(AVG(total_freight) * 1.0 / 6) AS freight_per_employee
  FROM order_stats
),
ordered_orders AS (
  SELECT 
    OrderID, 
    Freight,
    ROW_NUMBER() OVER (ORDER BY Freight DESC) AS order_num
  FROM Orders
)
SELECT 
  Classify,
  SUM(Freight) AS total_freight,
  COUNT(*) AS total_orders
FROM (
  SELECT 
    OrderID, 
    Freight,
    (order_num - 1) % 6 + 1 AS Classify
  FROM ordered_orders
  CROSS JOIN employee_stats
) t
GROUP BY Classify
ORDER BY Classify;



WITH order_stats AS (
  SELECT 
    COUNT(*) AS total_orders,
    SUM(Freight) AS total_freight
  FROM Orders
),
ordered_orders AS (
  SELECT 
    OrderID, 
    Freight,
    ROW_NUMBER() OVER (ORDER BY Freight DESC) AS order_num
  FROM Orders
)
SELECT 
  Classify,
  SUM(Freight) AS total_freight,
  COUNT(*) AS total_orders
FROM (
  SELECT 
    OrderID, 
    Freight,
    (order_num - 1) % 6 + 1 AS Classify
  FROM ordered_orders

) t
GROUP BY Classify
ORDER BY Classify



WITH order_stats AS (
  SELECT 
    COUNT(*) AS total_orders,
    SUM(Freight) AS total_freight
  FROM Orders
),
employee_stats AS (
  SELECT 
    COUNT(*)  AS orders_per_employee,
    SUM(total_freight) AS freight_per_employee
  FROM order_stats
),
ordered_orders AS (
  SELECT 
    OrderID, 
    Freight,
    ROW_NUMBER() OVER (ORDER BY Freight DESC) AS order_num
  FROM Orders
)
SELECT 
  Classify,
  SUM(Freight) AS total_freight,
  COUNT(*) AS total_orders
FROM (
  SELECT 
    OrderID, 
    Freight,
    (order_num - 1) % 6 + 1 AS Classify
  FROM ordered_orders
  CROSS JOIN employee_stats
) t
GROUP BY Classify
ORDER BY Classify;



SELECT
(ROW_NUMBER() OVER (ORDER BY OrderID) - 1) % 6 + 1 AS PersonNumber,
COUNT(*) AS total_orders,
SUM(Freight) AS total_freight
FROM
Orders
GROUP BY OrderID

WITH order_stats AS (
  SELECT 
    COUNT(*) AS total_orders,
    SUM(Freight) AS total_freight
  FROM Orders
),
employee_stats AS (
  SELECT 
    (COUNT(*) * 1.0 / 6) AS orders_per_employee,
    (SUM(total_freight) * 1.0 / 6) AS freight_per_employee
  FROM order_stats
),
ordered_orders AS (
  SELECT 
    OrderID, 
    Freight,
    ROW_NUMBER() OVER (ORDER BY Freight DESC) AS order_num
  FROM Orders
)
SELECT 
  SUM(Freight) AS total_freight,
  COUNT(*) AS total_orders,
  (order_num - 1) % 6 + 1 AS Classify
FROM order_stats
  CROSS JOIN employee_stats
  CROSS JOIN ordered_orders
GROUP BY SUM(Freight)
