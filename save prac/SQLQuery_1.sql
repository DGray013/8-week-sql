create database D4437

use D4437
create table customer(
    name nvarchar(100),
    age int,
    city nvarchar(100)

)

/*insert into customer (city, age, nane)
VALUES ('hồ chí minh', 18, 'acb')

insert into customer (city, name)
VALUES ('hồ chí minh', 18, 'acb')

insert into customer
VALUES ('hồ chí minh')*/

insert into customer
VALUES ('bùi đức dương', 18, 'hồ chí minh')

insert into customer 
VALUES (N'bùi đức dương', 18, 'hồ chí minh')

select *
 from customer
 where city = N'hồ chí minh'


select *
from Film_Locations_in_San_Francisco
SELECT Title, ReleaseYear, Locations
WHERE ReleaseYear>=2001;
SELECT DISTINCT [Fun_Facts], [Locations]
FROM Film_Locations_in_San_Francisco;
SELECT  DISTINCT [Fun_Facts], [Locations]
FROM Film_Locations_in_San_Francisco;
SELECT  DISTINCT [Title], [Locations], [Release_Year]
FROM Film_Locations_in_San_Francisco
WHERE [Release_Year] <= 2000;
SELECT  DISTINCT [Title], [Locations], [Production_Company]
FROM Film_Locations_in_San_Francisco
WHERE [Writer] <> 'James Cameron'


SELECT DISTINCT [Title],[Locations],[Production_Company],[Release_Year]
from [dbo].[Film_Locations_in_San_Francisco]
where [Writer] in ('Aaron Sorkin', 'Alan Black', 'Albert Brooks', 'Alexandra Cunningham')

Select Title, Locations, Production_Company, Release_Year
From Film_Locations_in_San_Francisco
Where Writer IN ('Aaron Sorkin', 'Alan Black', 'Albert Brooks', 'Alexandra Cunningham')

Select Title, Locations, Production_Company, Release_Year
From Film_Locations_in_San_Francisco
Where Writer NOT IN ('Aaron Sorkin', 'Alan Black', 'Albert Brooks', 'Alexandra Cunningham') AND Release_Year BETWEEN 2000 AND 2015