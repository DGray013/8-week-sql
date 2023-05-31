use D4E34
/* Delete the tables if they already exist */
drop table if exists College;
drop table if exists Student;
drop table if exists Apply;

/* Create the schema for our tables */
create table College(Cname varchar(100), state varchar(100), enrollment int);
create table Student(sID int, sName varchar(100), GPA float, sizeHS int);
create table Apply(
	sID int,
	cName varchar(100), 
	major varchar(100), 
	decision varchar(100)
);

/* Populate the tables with our data */
insert into College values('Stanford', 'CA', 15000);
insert into College values('Berkeley', 'CA', 36000);
insert into College values('MIT', 'MA', 10000);
insert into College values('Cornell', 'NY', 21000);	

insert into Student values(201, 'Sarah Martinez', 3.3, 1000);
insert into Student values(202, 'Daniel Lewis', 3.9, 1500);
insert into Student values(203, 'Brittany Harris', 3.8, 1200);
insert into Student values(204, 'Mike Anderson', 2.4, 1400);
insert into Student values(205, 'Chris Jackson', 3.6, 900);
insert into Student values(206, 'Elizabeth Thomas', 3.2, 400);
insert into Student values(207, 'James Cameron', 2.9, 1600);
insert into Student values(208, 'Ashley White', 2.7, 2000);

insert into Apply values(201, 'Stanford', 'CS', 'Y');
insert into Apply values(201, 'Stanford', 'EE', 'N');
insert into Apply values(201, 'Berkeley', 'CS', 'Y');
insert into Apply values(201, 'Cornell', 'EE', 'Y');
insert into Apply values(202, 'Berkeley', 'biology', 'N');
insert into Apply values(203, 'MIT', 'bioengineer', 'Y');
insert into Apply values(203, 'Cornell', 'bioengineer', 'N');
insert into Apply values(203, 'Cornell', 'CS', 'Y');	
insert into Apply values(203, 'Cornell', 'EE', 'N');
insert into Apply values(204, 'Stanford', 'CS', 'Y');
insert into Apply values(205, 'Stanford', 'EE', 'Y');
insert into Apply values(205, 'Cornell', 'EE', 'N');
insert into Apply values(205, 'Stanford', 'EE', 'Y');
insert into Apply values(206, 'Stanford', 'history', 'Y');
insert into Apply values(206, 'Cornell', 'history', 'Y');
insert into Apply values(207, 'Cornell', 'psychology', 'Y');
insert into Apply values(208, 'MIT', 'CS', 'Y');

select top 10 * from Apply where cName = 'Stanford'
select top 10 * from College


