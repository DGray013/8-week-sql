CREATE DATABASE AEMR
select COUNT(*) as total_number_outage_events,
        [Status],Reason
FROM [AEMR Outage]
WHERE Start_Time < '2017' AND [Status] = 'Approved'
GROUP BY [Status],Reason
ORDER BY Reason 


SELECT * 
INTO #AEMR
From [AEMR Outage]
WHERE [Status] = 'Approved'

SELECT Reason, COUNT(*) as total_number_outage_events, MONTH(Start_Time) as Month 
FROM #AEMR
WHERE YEAR(Start_Time) = 2016 
GROUP by Reason , MONTH(Start_Time)
ORDER BY Reason,[Month]

SELECT Reason, COUNT(*) as total_number_outage_events, MONTH(Start_Time) as Month 
FROM [AEMR Outage]

GROUP by Reason , MONTH(Start_Time)
ORDER BY Reason,[Month]


SELECT COUNT(*) as total_number_outage_events, [Status],Reason
, RANK() OVER (partition by Reason ORDER BY Outage_MW DESC ) as rank_no
from #AEMR
GROUP BY [Status],Reason,Outage_MW




SELECT * 
FROM [AEMR Outage]

SELECT COUNT(*) as total_number_outage_events, [Status],Reason
FROM #AEMR
GROUP by [Status],Reason


SELECT [Status],
        Reason, 
        COUNT(*) as total_number_outage_events,
        ROUND(CONVERT(FLOAT, DATEDIFF(MINUTE,Start_Time,End_Time))/1440,2) AS Outage_Duration_Time_Days,
        YEAR(Start_Time) as year,
        RANK() OVER (partition by Reason ORDER BY   DESC ) N
from [AEMR Outage]
WHERE [Status] = 'Approved'
GROUP BY Reason,[Status],YEAR(Start_Time)
ORDER BY YEAR(Start_Time)





SELECT [Status],Reason,COUNT(*) as total_number_outage_events,MONTH(Start_Time) as month,
RANK() OVER (PARTITION by Reason order by MONTH(Start_Time))
from #AEMR
WHERE YEAR(Start_Time) = 2016
GROUP BY Reason,[Status],MONTH(Start_Time)


SELECT [Status],Reason,COUNT(*) as total_number_outage_events,MONTH(Start_Time) as month,
RANK() OVER (PARTITION by Reason order by MONTH(Start_Time))
from #AEMR
WHERE YEAR(Start_Time) = 2017
GROUP BY Reason,[Status],MONTH(Start_Time)


SELECT [Status],COUNT(*) as total_number_outage_events,MONTH(Start_Time) as month, YEAR(Start_Time) as year,
RANK() OVER (PARTITION by [Status] order by MONTH(Start_Time))
from #AEMR
GROUP BY [Status],MONTH(Start_Time),YEAR(Start_Time)
ORDER BY YEAR(Start_Time)



SELECT [Status],COUNT(*) as total_number_outage_events,MONTH(Start_Time) as month, YEAR(Start_Time) as year,
RANK() OVER (PARTITION by [Status] order by MONTH(Start_Time) )
from [AEMR Outage]
WHERE [Status] = 'Approved'
GROUP by [Status],MONTH(Start_Time),YEAR(Start_Time)
ORDER BY YEAR(Start_Time)



SELECT COUNT(*) as total_number_outage_events, Participant_Code, [Status] ,YEAR(Start_Time) as year,
RANK() OVER (PARTITION by [Status] order by Participant_Code)
FROM #AEMR 
GROUP by Participant_Code,[Status],YEAR(Start_Time)
ORDER by YEAR(Start_Time)


SELECT Participant_Code ,
        [Status],
        YEAR(Start_Time) as year,
        ROUND(CONVERT(FLOAT, DATEDIFF(MINUTE,Start_Time,End_Time))/1440,2) AS Outage_Duration_Time_Days 
FROM #AEMR
GROUP by Participant_Code,
        [Status],
        YEAR(Start_Time)
ORDER by YEAR(Start_Time),
        ROUND(CONVERT(FLOAT, DATEDIFF(MINUTE,Start_Time,End_Time))/1440,2) DESC


SELECT Participant_Code,
       Status,
	   Year(Start_Time) AS Year,
	   CAST(Avg(CAST(DATEDIFF(DAY,Start_Time,End_Time) AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS Outage_Duration_Time_Days
FROM #AEMR
GROUP BY Participant_Code,
		 Status,
		 Year(Start_Time)
ORDER BY 
	Year(Start_Time),
	CAST(Avg(CAST(DATEDIFF(DAY,Start_Time,End_Time) AS DECIMAL(18,2))) AS DECIMAL(18,2)) DESC






SELECT COUNT([Status]) as Total_Number_Outage_Events , Reason ,YEAR(Start_Time) 
FROM #AEMR
WHERE Reason = 'Forced'
GROUP by Reason,YEAR(Start_Time)



SELECT [Status],
        [Reason], 
        YEAR([Start_Time]) Year, 
        ROUND(AVG([Outage_MW]),2) Avg_Outtage_MW_Loss, 
        ROUND(AVG(CONVERT(float,DATEDIFF(MINUTE,[Start_Time],[End_Time])/1440)),2) Average_outage_Duration_Time_Days
FROM [#AEMR]
WHERE  [Reason] = 'Forced'
GROUP BY YEAR([Start_Time]),[Status],[Reason]
ORDER BY [Year]




SELECT [Status],
        [Reason], 
        YEAR([Start_Time]) Year, 
        ROUND(AVG([Outage_MW]),2) Avg_Outtage_MW_Loss, 
        ROUND(AVG(CONVERT(float,DATEDIFF(MINUTE,[Start_Time],[End_Time])/1440)),2) Average_outage_Duration_Time_Days,
        ROUND(SUM(Outage_MW),2) as Summed_energy_Lost,
        RANK() OVER (PARTITION BY Reason order by YEAR([Start_Time]) )
FROM [AEMR Outage]
GROUP BY YEAR([Start_Time]),[Status],[Reason]
ORDER BY [Year]





SELECT [Status],
        [Reason], 
        YEAR([Start_Time]) Year, 
        ROUND(AVG([Outage_MW]),2) Avg_Outtage_MW_Loss, 
        ROUND(AVG(CONVERT(float,DATEDIFF(MINUTE,[Start_Time],[End_Time])/1440)),2) Average_outage_Duration_Time_Days,
        RANK() OVER (PARTITION BY Reason order by YEAR([Start_Time]) )
FROM [#AEMR]
GROUP BY YEAR([Start_Time]),[Status],[Reason]
ORDER BY [Year]

SELECT Reason, COUNT(*) as total_number_outage_events, MONTH(Start_Time) as Month 
FROM [AEMR Outage]
GROUP by Reason , MONTH(Start_Time)
ORDER BY Reason,[Month]


SELECT [Status],Start_Time,End_Time,Facility_Code,Participant_Code,Outage_MW,Recovery_Time_Minutes,[Description],
        COUNT(*) as total_number_outage_events,
        MONTH(Start_Time) as Month,
        [Reason], 
        YEAR([Start_Time]) Year, 
        ROUND(AVG([Outage_MW]),2) Avg_Outtage_MW_Loss, 
        ROUND(AVG(CONVERT(float,DATEDIFF(MINUTE,[Start_Time],[End_Time])/1440)),2) Average_outage_Duration_Time_Days,
        ROUND(SUM(Outage_MW),2) as Summed_energy_Lost

FROM [AEMR Outage]
GROUP BY YEAR([Start_Time]),[Status],[Reason],Start_Time,End_Time,Facility_Code,Participant_Code,Outage_MW,Recovery_Time_Minutes,[Description],MONTH(Start_Time)
ORDER BY [Year]




SELECT Participant_Code,
        [Status],
        YEAR([Start_Time]) Year, 
        ROUND(AVG([Outage_MW]),2) Avg_Outtage_MW_Loss, 
        ROUND(AVG(CONVERT(float,DATEDIFF(MINUTE,[Start_Time],[End_Time])/1440)),2) Average_outage_Duration_Time_Days,
        RANK() OVER (PARTITION BY Status order by ROUND(AVG([Outage_MW]),2) DESC )
FROM [#AEMR]
GROUP BY YEAR([Start_Time]),[Status],Participant_Code
ORDER BY YEAR



SELECT Participant_Code,
        Facility_Code,
        [Status],
        YEAR(Start_Time) as year,
        ROUND(AVG(Outage_MW),2) as Avg_Outtage_MW_Loss,
        ROUND(SUM(Outage_MW),2) as Summed_energy_Lost
        
FROM #AEMR
WHERE Reason = 'Forced'
GROUP BY YEAR([Start_Time]),[Status],Participant_Code,Facility_Code
ORDER by YEAR, ROUND(SUM(Outage_MW),2) DESC























-- drop TABLE customer_nodes,regions,runners,members,menu


-- A. Customer Nodes Exploration
-- How many unique nodes are there on the Data Bank system?
SELECT COUNT(distinct node_id)
FROM customer_nodes 

-- What is the number of nodes per region?
SELECT COUNT(C.region_id) as totalnumber_nodes_per_region ,R.region_name
from regions R JOIN customer_nodes C ON R.region_id=C.region_id
GROUP by region_name



-- How many customers are allocated to each region?
SELECT COUNT(C.customer_id),R.region_name
from regions R JOIN customer_nodes C ON R.region_id=C.region_id
GROUP BY region_name

-- How many days on average are customers reallocated to a different node?
SELECT node_id,
        ROUND(AVG(DATEDIFF(DAY,start_date,end_date)),2)
FROM customer_nodes
WHERE end_date!='9999-12-31'
GROUP BY node_id




-- What is the median, 80th and 95th percentile for this same reallocation days metric for each region?


SELECT distinct *,
        ROUND(PERCENT_RANK() OVER(PARTITION by region_id order by reallocation_days)*100,2) as P 
FROM (SELECT * ,
        DATEDIFF(DAY,start_date,end_date) as reallocation_days
        FROM customer_nodes 
        WHERE end_date != '9999-12-31') A 
WHERE ROUND(PERCENT_RANK() OVER(PARTITION by region_id order by reallocation_days)*100,2) BETWEEN 80 and 95





DROP TABLE IF EXISTS #TEST;
SELECT DISTINCT *,
        ROUND(PERCENT_RANK() OVER(PARTITION by region_id order by reallocation_days)*100,2) as P 
INTO #TEST
FROM (SELECT c.region_id,
             r.region_name,
        DATEDIFF(DAY,Start_date,End_date) as reallocation_days
        FROM customer_nodes c
		INNER JOIN regions r
		ON r.region_id = c.region_id
        WHERE end_date != '9999-12-31') A 
SELECT DISTINCT region_id,
       region_name,
       reallocation_days,
	   P
FROM #TEST
WHERE P > 95
GROUP BY region_id,region_name,reallocation_days,P;





-- B. Customer Transactions
-- What is the unique count and total amount for each transaction type?
select 
	txn_type,
	count(txn_type) unique_count,
	sum(txn_amount) total_amount
from customer_transactions
group by txn_type



-- What is the average total historical deposit counts and amounts for all customers?
WITH historical as 
        (SELECT N.customer_id,
                T.txn_type,
                COUNT(T.txn_type) count,
                AVG(T.txn_amount) avg_amount
        from customer_transactions T join customer_nodes N on T.customer_id=N.customer_id 
                                     join regions R on R.region_id=N.region_id
        group by n.customer_id,t.txn_type)
SELECT AVG(count) historical_count,
        AVG(avg_amount) avg_amount
FROM historical 
where txn_type = 'deposit'

SELECT distinct customer_id ,COUNT(txn_type),AVG(txn_amount)
from customer_transactions C
WHERE txn_type = 'deposit'
GROUP BY customer_id

-- For each month - how many Data Bank customers make more than 
-- 1 deposit and either 1 purchase or 1 withdrawal in a single month?
SELECT  distinct customer_id , 
        MONTH(txn_date) Month , 
        COUNT(txn_type) as NO_type,
        SUM(txn_amount) as total_amount,
        txn_type
FROM customer_transactions
GROUP BY customer_id,MONTH(txn_date),txn_type
HAVING COUNT(txn_type) > 1
ORDER BY customer_id





with deposit as 
                (SELECT T.customer_id,
                        DATENAME(MONTH,T.txn_date) as month_name,
                        DATEPART(MONTH,T.txn_date) as month_id,
                        SUM(case when txn_type = 'deposit' then 1 else 0 end) deposit 
                from customer_transactions T join customer_nodes N on T.customer_id=N.customer_id
                group by T.customer_id,DATENAME(MONTH,t.txn_date),DATEPART(MONTH,T.txn_date)),
     purchase as 
                (SELECT T.customer_id,
                        DATENAME(MONTH,T.txn_date) as month_name,
                        DATEPART(MONTH,T.txn_date) as month_id,
                        SUM(case when txn_type = 'purchase' then 1 else 0 end) purchase 
                from customer_transactions T join customer_nodes N on T.customer_id=N.customer_id
                group by T.customer_id,DATENAME(MONTH,t.txn_date),DATEPART(MONTH,T.txn_date)),
     withdrawal as 
                (SELECT T.customer_id,
                        DATENAME(MONTH,T.txn_date) as month_name,
                        DATEPART(MONTH,T.txn_date) as month_id,
                        SUM(case when txn_type = 'withdrawal' then 1 else 0 end) withdrawal
                from customer_transactions T join customer_nodes N on T.customer_id=N.customer_id
                group by T.customer_id,DATENAME(MONTH,t.txn_date),DATEPART(MONTH,T.txn_date))

     SELECT d.month_id,
        d.month_name,
                COUNT(d.customer_id) count 
     from deposit d join purchase p on d.customer_id = p.customer_id
                    join withdrawal w on p.customer_id=w.customer_id
        WHERE deposit > 1 and (purchase >=1 or withdrawal >=1 )
        GROUP BY d.month_id ,d.month_name



-- What is the closing balance for each customer at the end of the month?
SELECT  distinct customer_id , 
        MONTH(txn_date) Month,
        YEAR(txn_date) as Year,
        SUM(txn_amount) total_amount
FROM customer_transactions
GROUP BY customer_id,MONTH(txn_date),YEAR(txn_date)
ORDER BY customer_id



-- What is the percentage of customers who increase their closing balance by more than 5%?







-- C. Data Allocation Challenge

-- To test out a few different hypotheses - the Data Bank team wants to run an experiment 
-- where different groups of customers would be allocated data using 3 different options:

-- Option 1: data is allocated based off the amount of money at the end of the previous month
-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
-- Option 3: data is updated real-time


-- For this multi-part challenge question - you have been requested to generate the following data elements to help 
-- the Data Bank team estimate how much data will need to be provisioned for each option:

-- running customer balance column that includes the impact each transaction
-- customer balance at the end of each month
-- minimum, average and maximum values of the running balance for each customer
-- Using all of the data available - how much data would have been required for each option on a monthly basis?










