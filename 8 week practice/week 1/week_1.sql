CREATE DATABASE dannys_dinner
SELECT * from members
SELECT * from menu 
SELECT * FROM sales

-- 1 What is the total amount each customer spent at the restaurant?
SELECT s.customer_id  , SUM(m.price) as total_spent
from menu m JOIN sales s on m.product_id = s.product_id 
GROUP BY s.customer_id 



-- 2 How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(distinct order_date) as days
FROM sales s 
GROUP BY customer_id 



-- 3 What was the first item from the menu purchased by each customer?
WITH cte AS (
SELECT  s.customer_id,
        s.order_date,
        m.product_name,
        RANK() OVER (partition by s.customer_id ORDER by s.order_date ) as rnk,
        ROW_NUMBER() OVER (partition by s.customer_id ORDER by s.order_date ) as rn
FROM menu m JOIN sales s on m.product_id = s.product_id 
)
SELECT * 
FROM cte 
where rn = 1


-- 4 What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1
       m.product_name,
       COUNT(s.product_id) as most_purchased
FROM menu m JOIN sales s on m.product_id = s.product_id
GROUP By m.product_name,s.product_id
ORDER BY most_purchased DESC


-- 5 Which item was the most popular for each customer?
with cte as (
  SELECT
       s.customer_id,
       m.product_name,
       COUNT(s.order_date) as orders,
       RANK() OVER (partition by s.customer_id ORDER by COUNT(s.order_date) DESC ) as rnk,
       ROW_NUMBER() OVER (partition by s.customer_id ORDER by COUNT(s.order_date) DESC ) as rn
FROM menu m JOIN sales s on m.product_id = s.product_id
GROUP BY s.customer_id,
       m.product_name
)
SELECT customer_id, product_name,orders
from cte 
where rnk = 1


-- 6 Which item was purchased first by the customer after they became a member?
with cte as (
SELECT s.customer_id,
       s.order_date,
       mem.join_date,
       m.product_name,
       RANK() OVER (partition by s.customer_id ORDER by order_date ) as rnk,
       ROW_NUMBER() OVER (partition by s.customer_id ORDER by order_date ) as rn
from sales s 
    JOIN members as mem on s.customer_id = mem.customer_id 
    JOIN menu m on m.product_id = s.product_id
WHERE order_date >= join_date 
)
SELECT customer_id, product_name
FROM cte 
where rnk = 1


-- 7 Which item was purchased just before the customer became a member?
with cte as (
SELECT s.customer_id,
       s.order_date,
       mem.join_date,
       m.product_name,
       RANK() OVER (partition by s.customer_id ORDER by order_date DESC ) as rnk,
       ROW_NUMBER() OVER (partition by s.customer_id ORDER by order_date DESC ) as rn
from sales s 
    JOIN members as mem on s.customer_id = mem.customer_id 
    JOIN menu m on m.product_id = s.product_id
WHERE order_date < join_date 
)
SELECT customer_id, product_name
FROM cte 
where rnk = 1


-- 8 What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,
       Count(m.product_name) as total_items,
       SUM(m.price) as amount
from sales s 
    JOIN members as mem on s.customer_id = mem.customer_id 
    JOIN menu m on m.product_id = s.product_id
WHERE order_date < join_date 
GROUP BY s.customer_id


-- 9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id

,   SUM(Case
        WHEN m.product_name = 'sushi' then m.price * 10 * 2 
        else m.price *10 
        end) as points 
FROM menu m JOIN sales s on m.product_id = s.product_id 
GROUP BY s.customer_id

-- 10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?

SELECT s.customer_id
,SUM(CASE
        When s.order_date between mem.join_date and DATEADD(DAY,6,mem.join_date) then price * 10 * 2 
        WHEN m.product_name = 'sushi' then m.price * 10 * 2 
        else m.price *10 
        end) as points 
FROM sales s 
    JOIN members as mem on s.customer_id = mem.customer_id 
    JOIN menu m on m.product_id = s.product_id
Where s.order_date <= '20210131'
GROUP BY s.customer_id

SELECT
        customer_id,
        SUM(points) as points 
FROM ( select s.customer_id,
                        case when product_name = 'sushi' and 
                                  s.order_date between DATEADD(DAY,-1,mem.join_date) and 
                                  DATEADD(DAY,6,mem.join_date) then price*40 
                             when product_name = 'sushi' or 
                                  s.order_date between DATEADD(DAY,-1,mem.join_date) and 
                                  DATEADD(DAY,6,mem.join_date) then price*20
                        else price*10 end points
        from members mem
	left join sales s on s.customer_id = mem.customer_id
	left join menu m on s.product_id = m.product_id
        WHERE s.order_date <= '20210131') a
GROUP BY  customer_id ;



-- Join All The Things 

SELECT s.customer_id,
       s.order_date,
       m.product_name,
       m.price,
       Case 
            when mem.join_date is NULL then 'N'
            when s.order_date < mem.join_date then 'N'
            Else 'Y'
            END as members
from sales s 
      LEFT join menu m on s.product_id=m.product_id 
      LEFT JOIN members mem ON s.customer_id=mem.customer_id 
ORDER BY s.customer_id,s.order_date,m.product_name,m.price DESC 


-- Rank All The Things
WITH CTE AS (
  SELECT 
    S.customer_id, 
    S.order_date, 
    product_name, 
    price, 
    CASE 
      WHEN join_date IS NULL THEN 'N'
      WHEN order_date < join_date THEN 'N'
      ELSE 'Y' 
    END as member 
  FROM 
    SALES as S 
    INNER JOIN MENU AS M ON S.product_id = M.product_id
    LEFT JOIN MEMBERS AS MEM ON MEM.customer_id = S.customer_id
  ORDER BY 
    customer_id, 
    order_date, 
    price DESC
)
SELECT 
  *
  ,CASE 
    WHEN member = 'N'  THEN NULL
    ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)  
  END as rnk
FROM CTE;


SELECT 
  *, 
  case 
    when member = 'Y' then RANK() over (partition by customer_id,member order by order_date) 
    else null 
    end ranking 
from 
  (
    SELECT 
      s.customer_id, 
      s.order_date, 
      m.product_name, 
      m.price, 
      case when s.order_date >= mem.join_date then 'Y' else 'N' end member 
    from 
      sales s 
      LEFT join menu m on s.product_id = m.product_id 
      LEFT JOIN members mem ON s.customer_id = mem.customer_id
  ) a 
ORDER by 
  customer_id, 
  order_date, 
  product_name


