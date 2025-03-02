# CTEs (Common Table Expressions) in MySQL | Advanced MySQL Series

with Ctes_Exapmle AS
(
SELECT gender, SUM(salary), MIN(salary), MAX(salary), COUNT(salary), AVG(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
-- directly after using it we can query the CTE Because It'sn't Temp.
SELECT *
FROM Ctes_Exapmle;

-- we also have the ability to create multiple CTEs with just one With Expression

WITH CTE_Example AS 
(
SELECT employee_id, gender, birth_date
FROM employee_demographics dem
WHERE birth_date > '1985-01-01'
), -- just have to separate by using a comma
CTE_Example2 AS 
(
SELECT employee_id, salary
FROM parks_and_recreation.employee_salary
WHERE salary >= 50000
)
-- Now if we change this a bit, we can join these two CTEs together
SELECT *
FROM CTE_Example cte1
LEFT JOIN CTE_Example2 cte2
	ON cte1. employee_id = cte2. employee_id;
    
    
# Temp Tables in MySQL | Advanced MySQL Series
-- Using Temporary Tables
-- Temporary tables are tables that are only visible to the session that created them. 
-- They can be used to store intermediate results for complex queries or to manipulate data before inserting it into a permanent table.

-- There's 2 ways to create temp tables:
-- 1. This is the less commonly used way - which is to build it exactly like a real table and insert data into it

CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);

-- if we execute this it gets created and we can actualyl query it.

SELECT *
FROM temp_table;
-- notice that if we refresh out tables it isn't there. It isn't an actual table. It's just a table in memory.

-- now obviously it's balnk so we would need to insert data into it like this:

INSERT INTO temp_table
VALUES ('Alex','Freberg','Lord of the Rings: The Twin Towers');

-- now when we run it and execute it again we have our data
SELECT *
FROM temp_table;

-- the second way is much faster and my preferred method
-- 2. Build it by inserting data into it - easier and faster

CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary > 50000;

-- if we run this query we get our output
SELECT *
FROM salary_over_50k;

-- this is the primary way I've used temp tables especially if I'm just querying data and have some complex data I want to put into boxes or these temp tables to use later
-- it helps me kind of categorize and separate it out

create temporary table Temp_One
(first_name varchar(50),
last_name varchar(100),
movie_name varchar(100)
)
;

insert into Temp_One
values ('Mohammed', 'Jawad','Shawshenk')
;
select *
from Temp_One
;

# Stored Procedures in MySQL | Advanced MySQL Series
create procedure Large_Salary()
select *
from employee_salary
where salary >= 50000
;
call Large_Salary() ;


delimiter $$
CREATE PROCEDURE Multiable_2()
BEGIN	
	select * 
	from employee_demographics
	where age >=45;
	select * 
	from employee_salary
	where salary >=10000;
END $$

delimiter ;    

call Multiable_2()

-- we can also add parameters
-- USE `parks_and_recreation`;
-- DROP procedure IF EXISTS `large_salaries3`;
-- it automatically adds the dilimiter for us
DELIMITER $$
CREATE PROCEDURE large_salaries3(employee_id_param INT)
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 60000
    AND employee_id_param = employee_id;
END $$

DELIMITER ;

CALL large_salaries3(1);

#Triggers and Events in MySQL | Advanced MySQL Series

delimiter $$
create trigger emolyee_add
after insert on employee_salary
for each row
begin
	insert into employee_demographics (employee_id, first_name,last_name)
    values(new.employee_id, new.first_name, new.last_name);
end $$

delimiter ;

insert into employee_salary (employee_id, first_name,last_name, occupation, salary, dept_id)
values ('13', 'Mickl','Angelo', 'CEO of PET', 1000000, null);

select*
from employee_salary;

select *
from employee_demographics;

-- now let's look at Events

-- Now I usually call these "Jobs" because I called them that for years in MSSQL, but in MySQL they're called Events

-- Events are task or block of code that gets executed according to a schedule. These are fantastic for so many reasons. Importing data on a schedule. 
-- Scheduling reports to be exported to files and so many other things
-- you can schedule all of this to happen every day, every monday, every first of the month at 10am. Really whenever you want

-- This really helps with automation in MySQL

-- let's say Parks and Rec has a policy that anyone over the age of 60 is immediately retired with lifetime pay
-- All we have to do is delete them from the demographics table

SELECT * 
FROM parks_and_recreation.employee_demographics;

SHOW EVENTS;

-- we can drop or alter these events like this:
DROP EVENT IF EXISTS delete_retirees;
DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO BEGIN
	DELETE
	FROM parks_and_recreation.employee_demographics
    WHERE age >= 60;
END $$

DELIMITER ;

-- if we run it again you can see Jerry is now fired -- or I mean retired
SELECT * 
FROM parks_and_recreation.employee_demographics;


















































    