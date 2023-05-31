select * from weekly_sales;
SELECT *
FROM weekly_sales_cleaned;

/* A. Data Cleansing Steps
- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
- Convert the week_date to a DATE format
- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a month_number with the calendar month for each week_date value as the 3rd column
- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
- segment	age_band
1	Young Adults
2	Middle Aged
3 or 4	Retirees
- Add a new demographic column using the following mapping for the first letter in the segment values:
segment	demographic
C	Couples
F	Families
- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record*/

DROP TABLE IF EXISTS weekly_sales_cleaned;
SELECT CONVERT(DATE, week_date, 3) AS week_date,
    DATEPART(WEEK, CONVERT(DATE, week_date, 3)) AS week_number,
    DATEPART(MONTH, CONVERT(DATE, week_date, 3)) AS month_number,
    DATEPART(YEAR, CONVERT(DATE, week_date, 3)) AS calendar_year,
    region, platform, segment, customer_type,
    CASE
        WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
        WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
        WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
        ELSE 'Unknown'
        END AS age_band,
    CASE
        WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
        WHEN LEFT(segment, 1) = 'F' THEN 'Families'
        ELSE 'Unknown'
        END AS demographic,
    transactions,
    CAST(sales AS BIGINT) AS sales,
    ROUND(CAST(sales AS FLOAT) / transactions, 2) AS avg_transaction
INTO weekly_sales_cleaned
FROM weekly_sales;

SELECT *
FROM weekly_sales_cleaned




-- B. Data Exploration
-- 1 What day of the week is used for each week_date value?
SELECT distinct (DATENAME(Day,week_date)) as week_days
FROM weekly_sales_cleaned;


-- 2 What range of week numbers are missing from the dataset?
WITH missing_weeks AS (
    SELECT 1 AS week_number
    UNION ALL
    SELECT week_number + 1
    FROM missing_weeks
    WHERE week_number < 53
)
SELECT week_number AS missing_week
FROM missing_weeks m
WHERE NOT EXISTS (
                    SELECT 1
                    FROM weekly_sales_cleaned s
                    WHERE m.week_number = s.week_number
);



WITH week_number_cte AS (
  SELECT GENERATE_SERIES(1, 52) AS week_number
)

SELECT DISTINCT c.week_number
FROM week_number_cte c
LEFT JOIN weekly_sales_cleaned s
  ON c.week_number = EXTRACT(WEEK FROM s.week_date)
WHERE s.week_date IS NULL;




-- 3 How many total transactions were there for each year in the dataset?
SELECT 
  calendar_year, 
  SUM(transactions) AS total_transactions
FROM weekly_sales_cleaned
GROUP BY calendar_year
ORDER BY calendar_year;


-- 4 What is the total sales for each region for each month?
SELECT region,
  month_number,
  SUM(sales) AS sales
FROM weekly_sales_cleaned
GROUP BY region,month_number
ORDER BY region,month_number;



-- 5 What is the total count of transactions for each platform
SELECT platform,
  SUM(transactions) AS total_transactions
FROM weekly_sales_cleaned
GROUP BY platform
ORDER BY platform;


-- 6 What is the percentage of sales for Retail vs Shopify for each month?
with Cte as (
  SELECT calendar_year,
        month_number,
        platform,
         SUM(sales) AS monthly_sales
FROM weekly_sales_cleaned
GROUP BY calendar_year,month_number,platform
)
SELECT calendar_year,
        month_number,
    ROUND(100 * MAX 
      (CASE WHEN platform = 'Retail' THEN monthly_sales ELSE NULL END) 
    / 
      SUM(monthly_sales),2) AS retail_percentage,

    ROUND(100 * MAX 
      (CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE NULL END) 
    / 
      SUM(monthly_sales),2) AS shopify_percentage      
FROM Cte
GROUP BY calendar_year,month_number
ORDER BY calendar_year,month_number




-- 7 What is the percentage of sales by demographic for each year in the dataset?
with cte as (
  SELECT calendar_year,
        demographic,
         SUM(sales) AS monthly_sales
FROM weekly_sales_cleaned
GROUP BY calendar_year,demographic
)
SELECT calendar_year,
    ROUND(100 * MAX 
      (CASE WHEN demographic = 'Families' THEN monthly_sales ELSE NULL END) 
    / 
      SUM(monthly_sales),2) AS retail_percentage,

    ROUND(100 * MAX 
      (CASE WHEN demographic = 'Couples' THEN monthly_sales ELSE NULL END) 
    / 
      SUM(monthly_sales),2) AS shopify_percentage     , 
          ROUND(100 * MAX 
      (CASE WHEN demographic = 'Unknown' THEN monthly_sales ELSE NULL END) 
    / 
      SUM(monthly_sales),2) AS retail_percentage

FROM Cte
GROUP BY calendar_year
ORDER BY calendar_year


-- 8 Which age_band and demographic values contribute the most to Retail sales?
with cte as (
  SELECT age_band, 
        demographic, 
        SUM(sales) AS retail_sales
FROM weekly_sales_cleaned
where platform = 'Retail'
GROUP BY age_band,demographic
)
SELECT *,
        round((100*(retail_sales) 
        / 
        (Select sum(retail_sales) as Total from cte)),2)  as Total 
FROM cte



-- 9 Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / sum(transactions) AS avg_transaction_group
FROM weekly_sales_cleaned
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;








-- C. Before & After Analysis
--Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect. 
--  We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.
-- Using this analysis approach - answer the following questions:

--  1 What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
-- Before we start, we find out the week_number of '2020-06-15' so that we can use it for filtering.
SELECT 
  DISTINCT week_number
FROM weekly_sales_cleaned
WHERE week_date = '2020-06-15' 
  AND calendar_year = '2020'

WITH changes AS (
  SELECT 
    week_date, 
    week_number, 
    SUM(sales) AS total_sales
  FROM weekly_sales_cleaned
  WHERE (week_number BETWEEN 21 AND 28) 
    AND (calendar_year = 2020)
  GROUP BY week_date, week_number
),
changes_2 AS (
  SELECT 
    SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total_sales END) AS before_change,
    SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_change
  FROM changes)

SELECT 
  before_change, 
  after_change, 
  after_change - before_change AS variance, 
  ROUND(100 * (after_change - before_change) / before_change,2) AS percentage
FROM changes_2;




--  2 What about the entire 12 weeks before and after?
WITH changes AS (
  SELECT 
    week_date, 
    week_number, 
    SUM(sales) AS total_sales
  FROM weekly_sales_cleaned
  WHERE (week_number BETWEEN 13 AND 37) 
    AND (calendar_year = 2020)
  GROUP BY week_date, week_number
),
changes_2 AS (
  SELECT 
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_change,
    SUM(CASE WHEN week_number BETWEEN 25 AND 37 THEN total_sales END) AS after_change
  FROM changes)

SELECT 
  before_change, 
  after_change, 
  after_change - before_change AS variance, 
  ROUND(100 * (after_change - before_change) / before_change,2) AS percentage
FROM changes_2;







--  3 How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH summary AS (
  SELECT 
    calendar_year, -- added new column
    week_number, 
    SUM(sales) AS total_sales
  FROM weekly_sales_cleaned
  WHERE (week_number BETWEEN 21 AND 28) 
  GROUP BY calendar_year, week_number
),
summary_2 AS (
  SELECT 
    calendar_year,
    SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total_sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total_sales END) AS after_sales
  FROM summary
  GROUP BY calendar_year
)

SELECT 
  calendar_year, 
  before_sales, 
  after_sales, 
  after_sales - before_sales AS sales_variance, 
  ROUND(100 * (after_sales - before_sales) / before_sales,2) AS percentage
FROM summary_2
