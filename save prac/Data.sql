use D4E;

drop table if exists EMPLOYEE;
drop table if exists DEPARTMENT;
drop table if exists DEPT_LOCATIONS;
drop table if exists PROJECT;
drop table if exists WORKS_ON;
drop table if exists DEPENDENT;


create table EMPLOYEE (
	Fname varchar(10),
	Minit varchar(1),
	Lname varchar(10),
	Ssn bigint not null PRIMARY KEY,
	BDate datetime,
	Address varchar(100),
	Sex varchar(1),
	Salary int,
	Super_ssn bigint,
	Dno int,
);

create table DEPARTMENT (
	Dname varchar(50),
	Dnumber int not null PRIMARY KEY,
	Mgr_ssn bigint,
	Mgr_start_date datetime,
);

create table DEPT_LOCATIONS (
	Dnumber int not null,
	Dlocation varchar(50) not null,
	CONSTRAINT PK_DEPT_LOCATIONS PRIMARY KEY (Dnumber,Dlocation),
);

create table PROJECT(
	Pname varchar(50),
	Pnumber int not null PRIMARY KEY,
	Plocation varchar(50),
	Dnumber int,
);

create table WORKS_ON(
	Essn bigint,
	Pno int,
	Hours float,
	CONSTRAINT PK_WORKS_ON PRIMARY KEY (Essn,Pno)
)

create table DEPENDENT(
	Essn bigint not null,
	Dependent_name varchar(50) not null,
	Sex varchar(1),
	Bdate datetime,
	Relationship varchar(50),
	CONSTRAINT PK_DEPENDENT PRIMARY KEY (Essn,Dependent_name)
)

insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('John','B','Smith',123456789, CAST(N'1965-01-09' AS DateTime),'731 Fondren,Houston,TX','M',30000,333445555,5);
insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('Franklin','T','Wong',333445555, CAST(N'1955-12-08' AS DateTime),'638 Voss,Houston,TX','M',40000,888665555,5);
insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('Alicia','J','Zelaya',999887777, CAST(N'1968-07-19' AS DateTime),'3321 Castle,Spring,TX','F',25000,987654321,4);
insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('Jennifer','S','Wallace',987654321, CAST(N'1941-06-20' AS DateTime),'291 Berry,Bellaire,TX','F',43000,8886655555,4);
insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('Ramesh','K','Narayan',666884444, CAST(N'1962-09-15' AS DateTime),'975 Fire Oak,Humble,TX','M',38000,333445555,5);
insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('Joyce','A','English',453453453, CAST(N'1972-07-31' AS DateTime),'5631 Rice,Houston,TX','F',25000,333445555,5);
insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('Ahmad','V','Jabbar',987987987, CAST(N'1969-03-29' AS DateTime),'980 Dallas,Houston,TX','M',25000,333445555,5);
insert into EMPLOYEE(Fname,Minit,Lname,Ssn,BDate,Address,Sex,Salary,Super_ssn,Dno) values ('James','E','Borg',888665555, CAST(N'1937-11-10' AS DateTime),'450 Stone,Houston,TX','M',55000,null,1);


insert into DEPARTMENT(Dname,Dnumber,Mgr_ssn,Mgr_start_date) values ('Research',5,333445555,CAST(N'1988-05-22' AS DateTime));
insert into DEPARTMENT(Dname,Dnumber,Mgr_ssn,Mgr_start_date) values ('Administration',4,987654321,CAST(N'1995-01-01' AS DateTime));
insert into DEPARTMENT(Dname,Dnumber,Mgr_ssn,Mgr_start_date) values ('Headquarters',1,888665555,CAST(N'1981-06-19' AS DateTime));

insert into DEPT_LOCATIONS(Dnumber,Dlocation) values (1,'Houston');
insert into DEPT_LOCATIONS(Dnumber,Dlocation) values (4,'Stafford');
insert into DEPT_LOCATIONS(Dnumber,Dlocation) values (5,'Bellaire');
insert into DEPT_LOCATIONS(Dnumber,Dlocation) values (5,'Sugarland');
insert into DEPT_LOCATIONS(Dnumber,Dlocation) values (5,'Houston');


insert into PROJECT(Pname,Pnumber,Plocation,Dnumber) values ('ProductX',1,'Bellaire',5);
insert into PROJECT(Pname,Pnumber,Plocation,Dnumber) values ('ProductY',2,'Sugarland',5);
insert into PROJECT(Pname,Pnumber,Plocation,Dnumber) values ('ProductZ',3,'Houston',5);
insert into PROJECT(Pname,Pnumber,Plocation,Dnumber) values ('Computerization',10,'Stafford',4);
insert into PROJECT(Pname,Pnumber,Plocation,Dnumber) values ('Reorganization',20,'Houston',1);
insert into PROJECT(Pname,Pnumber,Plocation,Dnumber) values ('Newbenefits',30,'Stafford',4);


insert into WORKS_ON(Essn,Pno,Hours) values (123456789,1,32.5);
insert into WORKS_ON(Essn,Pno,Hours) values (123456789,2,7.5);
insert into WORKS_ON(Essn,Pno,Hours) values (666884444,3,40);
insert into WORKS_ON(Essn,Pno,Hours) values (453453453,1,20);
insert into WORKS_ON(Essn,Pno,Hours) values (453453453,2,20);
insert into WORKS_ON(Essn,Pno,Hours) values (333445555,2,10);
insert into WORKS_ON(Essn,Pno,Hours) values (333445555,3,10);
insert into WORKS_ON(Essn,Pno,Hours) values (333445555,10,10);
insert into WORKS_ON(Essn,Pno,Hours) values (333445555,20,10);
insert into WORKS_ON(Essn,Pno,Hours) values (999887777,30,30);
insert into WORKS_ON(Essn,Pno,Hours) values (999887777,10,10);
insert into WORKS_ON(Essn,Pno,Hours) values (987987987,10,35);
insert into WORKS_ON(Essn,Pno,Hours) values (987987987,30,5);
insert into WORKS_ON(Essn,Pno,Hours) values (987654321,30,20);
insert into WORKS_ON(Essn,Pno,Hours) values (987654321,20,15);
insert into WORKS_ON(Essn,Pno,Hours) values (888665555,20,null);

insert into DEPENDENT(Essn,Dependent_name,Sex,Bdate,Relationship) values (333445555,'Alice','F',CAST(N'1986-04-05' AS DateTime),'DAUGHTER');
insert into DEPENDENT(Essn,Dependent_name,Sex,Bdate,Relationship) values (333445555,'Theodore','M',CAST(N'1983-10-25' AS DateTime),'SON');
insert into DEPENDENT(Essn,Dependent_name,Sex,Bdate,Relationship) values (333445555,'Joy','F',CAST(N'1958-05-03' AS DateTime),'SPOUSE');
insert into DEPENDENT(Essn,Dependent_name,Sex,Bdate,Relationship) values (987654321,'Abner','M',CAST(N'1942-02-28' AS DateTime),'SPOUSE');
insert into DEPENDENT(Essn,Dependent_name,Sex,Bdate,Relationship) values (123456789,'Michael','M',CAST(N'1988-01-04' AS DateTime),'SON');
insert into DEPENDENT(Essn,Dependent_name,Sex,Bdate,Relationship) values (123456789,'Alice','F',CAST(N'1988-12-30' AS DateTime),'DAUGHTER');
insert into DEPENDENT(Essn,Dependent_name,Sex,Bdate,Relationship) values (123456789,'Elizabeth','F',CAST(N'1967-05-05' AS DateTime),'SPOUSE');