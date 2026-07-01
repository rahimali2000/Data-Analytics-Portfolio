--          MySQL PROJECT ON Corporate Employee Database

-- STAGE 1

#  TABLE CREATION (1)
-- Employee_Demographics
 
CREATE TABLE employee_demographics 
(
 EmployeeID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender VARCHAR(10),
    Age INT,
    Department VARCHAR(50),
    City VARCHAR(50)
    );
    
# TABLE CREATION (2)
-- Employee_Salary

CREATE TABLE employee_salary
(
EmployeeID INT,
    JobTitle VARCHAR(50),
    Salary INT, 
    Bonus INT,
    HireDate VARCHAR(50)
);

-- INSERT DATA INTO TABLE 1 : 'Employee_Demograhics'

INSERT INTO employee_demographics VALUES
(1001,'John','Smith','Male',32,'IT','Lagos'),
(1002,'Mary','Johnson','Female',28,'HR','Abuja'),
(1003,'James','Brown','Male',45,'Finance','Kano'),
(1004,'Sarah','Davis','Female',38,'Marketing','Port Harcourt'),
(1005,'Michael','Wilson','Male',29,'IT','Lagos'),
(1006,'Linda','Taylor','Female',41,'Finance','Abuja'),
(1007,'David','Anderson','Male',35,'Sales','Kaduna'),
(1008,'Jennifer','Thomas','Female',31,'HR','Lagos'),
(1009,'Robert','Jackson','Male',27,'Marketing','Abuja'),
(1010,'Patricia','White','Female',50,'Management','Lagos');

-- INSERT DATA INTO TABLE 2 : Employee_Salary

INSERT INTO employee_salary VALUES
(1001,'Data Analyst',85000,5000,'2021-03-15'),
(1002,'HR Officer',65000,3000,'2022-01-10'),
(1003,'Finance Manager',120000,12000,'2018-07-22'),
(1004,'Marketing Specialist',78000,4000,'2020-11-05'),
(1005,'Business Analyst',90000,5500,'2023-02-18'),
(1006,'Senior Accountant',110000,10000,'2017-05-30'),
(1007,'Sales Executive',70000,8000,'2021-09-12'),
(1008,'HR Manager',95000,6000,'2019-06-25'),
(1009,'Marketing Analyst',72000,3500,'2022-08-08'),
(1010,'General Manager',150000,20000,'2015-04-01');

-- STAGE 2    
-- BUSINESS QUESTIONS 

-- Beginner
# Display all employees.
# Show only female employees.
# Find employees older than 35.
# Sort employees by age descending.
# Display employees from the IT department.
-- Intermediate
# Join both tables and display employee names with salaries.
# Find the average salary by department.
# Find the highest-paid employee.
# Count employees in each department.
# Find employees hired after 2021.
# Use ROW_NUMBER() to rank employees by salary.
# Use RANK() and DENSE_RANK() by salary.
# Create a CTE showing employees earning above the average salary.
# Find the top 3 highest-paid employees.
# Calculate total compensation (Salary + Bonus).
# Find the department with the highest average salary.
# Create a salary band (High, Medium, Low) using CASE.
# Find employees whose salary is above their department average.
# Use window functions to calculate running salary totals.
# Find the second-highest salary.

-- MySQL FUNCTIONS
# Select Statement
# Where Clause
# Group By
# Order By
# Having vs Where
# Limit and Aliasing
# Joins
# Unions
# String Functions
# Case Statements
# Subqueries
# Window Functions
# CTEs
# Temp Tables


-- 1. Display all employees    # SELECT SATAEMENT

SELECT * 
FROM corporate_employee_db.employee_demographics;

SELECT *
FROM corporate_employee_db.employee_salary;

-- 2. Show only female employees.   # WHERE FUNCTION

SELECT *
FROM employee_demographics
WHERE Gender = 'Female';

-- 3. Find employees older than 35.    # WHERE CLAUSE

SELECT *
FROM employee_demographics
WHERE Age > 35;

-- 4. Sort employees by age descending.    # ORDER BY 

SELECT *
FROM employee_demographics
ORDER BY Age DESC;

-- 5. Display employees from the IT department.    #  WHERE CLAUSE

SELECT *
FROM employee_demographics
WHERE Department = 'IT';

-- 6. Join both tables and display employee names with salaries. 
-- # Joins and Aliasing

-- a. INNER JOIN

SELECT *
FROM employee_demographics AS demo
JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID
;

-- b. Display employee names with salaries. 

SELECT demo.FirstName, demo.LastName, sal.Salary
FROM employee_demographics AS demo
INNER JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID
ORDER BY Salary DESC;

-- 7. Find the average salary by department.   #  GROUP By

SELECT 
	demo.Department,
AVG(Salary) AS avg_salary
FROM employee_demographics AS demo
JOIN employee_salary AS sal
	ON demo.EmployeeID = sal.EmployeeID
GROUP By demo.Department;

-- Find the highest-paid employee.   # HAVING / WHERE CLAUSE

SELECT 
	demo.FirstName, 
	demo.LastName, 
	demo.Department,
    sal.JobTitle,
	sal.Salary
FROM employee_demographics AS demo
JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID
ORDER BY salary DESC
LIMIT 1;


-- 8. Count employees in each department.    # COUNT FUNCTION

SELECT
	Department, count(FirstName) AS Number_of_employee_in_each_department
FROM employee_demographics
GROUP BY Department;

-- ALSO 

SELECT Department, count(*)
FROM employee_demographics
GROUP BY Department;

-- 9. Find employees hired after 2021.   # CASE STATEMENT

SELECT 
demo.firstName, 
demo.LastName,
sal.JobTitle, 
Hiredate,
CASE
	WHEN HireDate BETWEEN 2022 AND 2030 THEN 'Employees hired after 2021'
END AS New_Employees
FROM employee_demographics AS demo 
JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID;

-- ALSO CAN BE GET USING WHERE CLAUSE

SELECT *
FROM employee_salary
WHERE HireDate > '2021-12-31';
    
-- 10. Use ROW_NUMBER() to rank employees by salary.   # WINDOW FUNCTIONS

SELECT 
demo.FirstName, 
demo.LastName, 
demo.Department, 
demo.gender, 
sal.JobTitle, 
sal.Salary,
ROW_NUMBER() OVER(ORDER BY Salary DESC) AS row_numbered
FROM employee_demographics AS demo 
JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID;
    
-- ALSO ROW_NUBERER BY SALARY 

SELECT EmployeeID, Jobtitle, Salary,
ROW_NUMBER() 
	OVER(ORDER BY Salary ASC) AS row_num
FROM employee_salary;


-- 11. Use RANK() and DENSE_RANK() by salary.  # WINDOW FUNCTIONS

SELECT 
	demo.FirstName, 
	demo.LastName, 
	demo.Department, 
	demo.gender, 
	sal.JobTitle, 
	sal.Salary,
ROW_NUMBER()
	OVER(ORDER BY Salary DESC) AS row_num,
RANK() 
	OVER(ORDER BY Salary DESC) AS rank_num,
DENSE_RANK()
	OVER(ORDER BY Salary  DESC) AS dense_rank_num
FROM employee_demographics AS demo 
JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID;
    
-- ALSO 

SELECT EmployeeID, JobTItle, Salary,
ROW_NUMBER()
	OVER(ORDER BY Salary DESC) AS row_num,
RANK() 
	OVER(ORDER BY Salary DESC) AS rank_num,
DENSE_RANK()
	OVER(ORDER BY Salary DESC) AS dense_rank_num
FROM employee_salary;

-- 12. Create a CTE showing employees earning above the average salary.
# CTE - Common Table Expression 

With CTE_Employee AS
(SELECT AVG(Salary) AS avg_salary
FROM employee_salary)

SELECT demo.FirstName, demo.LastName, sal.Salary
FROM employee_demographics AS demo
INNER JOIN employee_salary AS sal
	ON demo.EmployeeID = sal.EmployeeID
WHERE sal.Salary > (SELECT avg_salary FROM CTE_Employee)
ORDER BY Salary DESC;

-- 13. Find the top 3 highest-paid employees.  
# WHERE CLAUSE and LIMIT

SELECT demo.FirstName, demo.LastName, demo.Department, sal.Salary
FROM employee_demographics AS demo
JOIN employee_salary AS sal
	ON demo.EmployeeID = sal.EmployeeID
ORDER BY Salary DESC
LIMIT 3;

-- 14. Calculate total compensation (Salary + Bonus).
# ORDER BY and ALIASING

SELECT EmployeeID, JobTitle, Salary, Bonus,
	(Salary + Bonus) AS total_compensation
FROM employee_salary
ORDER BY Salary DESC;

-- 15. Find the department with the highest average salary.
# GROUP BY, ORDER BY and LIMIT

SELECT demo.Department, AVG(Salary) AS avg_salary
FROM employee_demographics AS demo
INNER JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID
GROUP BY demo.Department
ORDER BY avg_salary DESC
LIMIT 1;


-- 16. Create a salary band (High, Medium, Low) using CASE.  
#  CASE STATEMENT 

SELECT 
	demo.FirstName, 
	demo.LastName, 
	Department, 
	sal.JobTitle, 
	sal.Salary,
CASE
	WHEN Salary >= 100000 THEN 'High'
    WHEN Salary >= 70000 THEN 'Medium'
    ELSE 'Low'
END AS salary_band 
FROM employee_demographics AS demo 
JOIN employee_salary AS sal 
	ON demo.EmployeeID = sal.EmployeeID;

-- 17. Find employees whose salary is above their department average.

SELECT 
	demo.FirstName, 
	demo.LastName, 
	demo.Department, 
	sal.JobTitle, 
	sal.Salary
FROM employee_demographics AS demo
INNER JOIN employee_salary AS sal
	ON demo.EmployeeID = sal.EmployeeID
WHERE sal.Salary > 
	(SELECT AVG(Salary)
    FROM employee_salary AS sal2
    INNER JOIN employee_demographics AS demo2
		ON sal2.EmployeeID = demo2.EmployeeID
WHERE demo2.Department = demo.Department);

-- 18. Use window functions to calculate running salary totals.
# Window Function

SELECT EmployeeID, JobTitle, Salary,
	SUM(Salary) OVER(ORDER BY Salary ASC
    ROWS UNBOUNDED PRECEDING) AS running_total_salary
FROM employee_salary;

-- Find the second-highest salary.

SELECT MAX(Salary) AS second_highest_salary
FROM employee_salary
WHERE Salary < (SELECT MAX(Salary) FROM employee_salary);
























 




    