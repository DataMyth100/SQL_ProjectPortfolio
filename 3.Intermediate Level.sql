# Joins in MySQL | Intermediate MySQL

select * 
from parks_and_recreation.employee_demographics;

select * 
from parks_and_recreation.employee_salary;


select ed.employee_id, age, occupation
from employee_demographics as ed
inner join employee_salary as es
   on ed.employee_id = es.employee_id
;

#Outer Join ___________________

select *
from employee_demographics as ed
right join employee_salary as es
   on ed.employee_id = es.employee_id
;

select *
from employee_demographics as ed
left join employee_salary as es
   on ed.employee_id = es.employee_id;
   
#___________________Self Join

select *
from employee_salary es1
join employee_salary es2
   on es1.employee_id = es2.employee_id;
   
# Multiple Join _________________________

select * 
from employee_demographics ed
join employee_salary es
    on ed.employee_id = es.employee_id
inner join parks_departments pd
    on es.dept_id = pd.department_id
    ;
    
# Unions in MySQL | Intermediate MySQL

select *
from employee_demographics
union
select *
from employee_salary
;
select first_name, last_name, 'Old Man' as Labal
from employee_demographics
where age > 40 and gender = 'male'
union 
select first_name, last_name, 'Old Woman' as Labal
from employee_demographics
where age > 40 and gender = 'female'
union
select first_name, last_name, 'Highly Paid Employee' as Labal
from employee_salary
where salary > 70000
order by first_name, last_name 
;

# String Functions in MySQL | Intermediate MySQL Series

#Length , Upper, Lower, Trim, L/R Trim,  Slicing(Lift(what you chose, number of how many letter eant to substring), Right),
#substring, Replace, Locate, concat

select  upper(first_name)
from employee_demographics;

select * ,substring(birth_date,6,2) as birth_month
from employee_demographics;
   
select first_name, last_name, 
concat(first_name , ' ' , last_name)   full_name
from employee_demographics;

# Case Statements in MySQL | Intermediate MySQL (When , Between - Then)
-- Pay Increase And Bounce
-- < 50000 Increase = 5%
-- >= 50000 Increase = 7%
-- Finance = 10%

select first_name, last_name, salary,
case
   when salary < 50000 then salary * 1.05 
   when salary >= 50000 then salary * 1.07
   when department_id = 'finance' then salary * .10
end as New_salary 
from employee_salary es
inner join parks_departments pd
on es.dept_id = pd.department_id
;

# Subqueries in MySQL | Intermediate MySQL

select *
from employee_demographics
where employee_id in (select employee_id
                           from employee_salary
                              where dept_id = 1)
;                              
                              
select first_name, last_name, salary,
(select avg(salary)
from employee_salary) as AVG_Salary
from employee_salary
;
 
select gender, avg(age), max(age), min(age), count(age)
from employee_demographics
group by gender
;

select first_name, last_name, age, avg(Max_age)
from employee_demographics,
(select avg(age), max(age) as Max_age, min(age), count(age)
from employee_demographics
group by gender) as New_table
group by first_name, last_name, age
;

select avg(Max_age)
from 
(select gender, avg(age), max(age) as Max_age, min(age), count(age)
from employee_demographics
group by gender) as New_table

;

select first_name, last_name, salary,
      (select avg(salary) from employee_salary ) as AVG_salary
from employee_salary
;      


# Window Functions in MySQL | Intermediate MySQL

SELECT gender, AVG(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender;

SELECT gender, AVG(salary) over(partition by gender)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


SELECT dem.first_name, dem.last_name, gender, AVG(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY dem.first_name, dem.last_name, gender;


SELECT dem.first_name, dem.last_name, gender, 
AVG(salary) over(partition by gender ) # complitly indenpendent 
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;

SELECT dem.first_name, dem.last_name, gender, sal.salary,
sum(salary) over(partition by gender) # complitly indenpendent 
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


SELECT dem.first_name, dem.last_name, gender, sal.salary,
sum(salary) over(partition by gender order by dem.employee_id) Rolling_Total # Rolling Total
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;


SELECT dem.first_name, dem.last_name, gender, sal.salary,
sum(salary) over(partition by gender order by dem.employee_id) Rolling_Total # Rolling Total
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
;