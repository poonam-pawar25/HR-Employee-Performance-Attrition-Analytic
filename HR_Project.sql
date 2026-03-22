/*=====================================
  Create Database & Select It
=====================================*/

CREATE DATABASE hr_project;
USE hr_project;

/*=====================================
  Create Employees Table
=====================================*/
 
 CREATE TABLE Employees (
 EmployeeNumber INT PRIMARY KEY,
    department VARCHAR(100),
   Education VARCHAR(100),
   Educationfield VARCHAR(100),
   BusinessTravel VARCHAR(100),
    age INT,
    gender VARCHAR(10),
	Jobrole VARCHAR(100),
	MaritalStatus VARCHAR(10),
    OverTime VARCHAR(10),
    JobLevel INT,
    EmployeeCount INT,
    Over18 VARCHAR(10),
    Hiredate DATE,
    StandardHours INT,
    NumCompaniesWorked INT,
    TotalWorkingYears INT,
    DistanceFromHome INT

);

/*=====================================
  Load CSV → Employees Table
=====================================*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/emp.csv'
INTO TABLE employees
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS; 
SELECT * FROM Employees;

/*=====================================
  Create Salary Table
=====================================*/

CREATE TABLE Salary (
 EmployeeNumber INT PRIMARY KEY,
 MonthlyIncome DECIMAL(10,2),
   DailyRate DECIMAL(10,2),
  HourlyRate DECIMAL(10,2),
 PercentSalaryHike DECIMAL(5,2),
StockOptionLevel INT,
 MonthlyRate DECIMAL(10,2),
    FOREIGN KEY (EmployeeNumber) REFERENCES Employees(EmployeeNumber)
	
);

/*=====================================
  Load CSV → Salary Table
=====================================*/
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/salary.csv'
INTO TABLE salary
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;
SELECT * FROM salary;


/*=====================================
  Create Performance Table
=====================================*/

CREATE TABLE Performance (
 EmployeeNumber INT PRIMARY KEY,
PerformanceRating INT,
WorkLifeBalance INT,
JobInvolvement INT,
RelationshipSatisfaction INT,
EnvironmentSatisfaction INT,
TrainingTimesLastYear INT,
    FOREIGN KEY (EmployeeNumber) REFERENCES Employees(EmployeeNumber)
	
);


/*=====================================
  Load CSV → Performance Table
=====================================*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Performance.csv'
INTO TABLE Performance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;
SELECT COUNT( *) FROM Performance;


/*=====================================
  Create Attrition Table
=====================================*/

CREATE TABLE Attrition (
 EmployeeNumber INT PRIMARY KEY,
Attrition VARCHAR(10),
YearsAtCompany INT,
YearsInCurrentRole INT,
YearsSinceLastPromotion INT,
YearsWithCurrManager INT,
FOREIGN KEY (EmployeeNumber) REFERENCES Employees(EmployeeNumber)
	
);

/*=====================================
  Load CSV → Attrition Table
=====================================*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Attrition.csv'
INTO TABLE Attrition
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;


/*=====================================
  Join All HR Tables
=====================================*/

SELECT * FROM employees e
LEFT JOIN salary s ON e.EmployeeNumber = s.EmployeeNumber
LEFT JOIN Performance p ON e.EmployeeNumber= p.EmployeeNumber
LEFT JOIN attrition a ON e.EmployeeNumber = a.EmployeeNumber; 

/*=====================================
  Department-Wise Employee Count
  Shows number of Employees in each deaprtment 
=====================================*/

 SELECT department ,COUNT(EmployeeNumber) AS total_emp
 FROM Employees
 GROUP BY department; 
 
 
/*=====================================
  Average Salary by Department & Job Role
  Shows salary pattern across the job role and department 
=====================================*/

SELECT e.department,e.jobrole,AVG(s.MonthlyIncome) As avg_salary
 FROM employees e
LEFT  JOIN salary s ON e.employeeNumber =s.EmployeeNumber
GROUP BY e.department,e.jobrole;



/*=====================================
  Attrition vs Average Years at Company
  Shows trends on average tenure of employee who left or stayed 
=====================================*/

SELECT a.Attrition AS attritionstatus ,AVG(a.YearsAtCompany) AS avg_year
FROM employees e
LEFT JOIN attrition a ON e.EmployeeNumber =a.EmployeeNumber
GROUP BY a.Attrition;


/*=====================================
  Performance Ranking Within Department
  shows Top performer within each deaprtment 
=====================================*/

SELECT e.EmployeeNumber,e.Jobrole, e.department ,p.PerformanceRating ,
DENSE_RANK() OVER (PARTITION BY e.department ORDER BY p.PerformanceRating DESC) AS Rank_emp
FROM employees e
LEFT JOIN Performance p
ON e.EmployeeNumber =p.EmployeeNumber
WHERE p.PerformanceRating IS NOT NULL;


 /*=====================================
High Attrition By Department & job role
shows employees woh left and stayed to identify roles and deaprtment
=====================================*/
 SELECT e.department,e.jobrole ,COUNT(*) AS Total_attrition 
FROM employees e
JOIN attrition a
ON e.EmployeeNumber=a.EmployeeNumber
WHERE a.attrition ='yes'
GROUP BY e.department ,e.jobrole
ORDER BY Total_attrition DESC;


/*=====================================
 Running total of salary within each department using window function
 shows commulative salary use for budget 
=====================================*/

SELECT e.EmployeeNumber,e.department ,s.MonthlyIncome,
SUM(s.MonthlyIncome)OVER (PARTITION BY e.department ORDER BY s.MonthlyIncome DESC) AS running_total_salary
FROM employees e
LEFT JOIN salary s
ON e.EmployeeNumber =s.EmployeeNumber
ORDER BY e.department ;


/*=====================================
Age vs Performance query
Shows performance by employee age 
=====================================*/

SELECT 
 CASE 
   WHEN e.age < 30 THEN ' under 30'
   WHEN e.age BETWEEN 30 AND 40 THEN '30-40'
   ELSE 'above 40'
 END as age_list,
 AVG(p.PerformanceRating) As avg_performance
 FROM employees e
 JOIN Performance p
 ON e.EmployeeNumber =p.EmployeeNumber 
 GROUP BY age_list 
 ORDER BY avg_performance ;


/*=====================================
  Attrition Risk Based on Performance & Salary
  shows employees in attrition risk category based on performance and salary
=====================================*/

SELECT p.PerformanceRating,s.MonthlyIncome,
   CASE
      WHEN p.PerformanceRating  < 3 AND s.MonthlyIncome < 40000 THEN 'high risk'
      WHEN p.PerformanceRating <=3 AND s.MonthlyIncome <40000 THEN 'Medium risk'
      ELSE 'low risk'
 END as atrrition_risk 
 FROM Performance p
 LEFT JOIN Salary s
 ON p.EmployeeNumber =s.EmployeeNumber;

/*=====================================
  Employee Tenure in Years
  shows employees who worked since the hire date 
=====================================*/

SELECT EmployeeNumber ,
timestampdiff(YEAR,Hiredate,CURDATE()) AS tenure_year
 FROM Employees	;
 


/*=====================================
  Highest Salary in Each Department
  shows top paid or max salary employees in each department 
=====================================*/
 
 SELECT e.EmployeeNumber ,e.department ,s.MonthlyIncome 
FROM employees e 
JOIN salary s 
ON e.EmployeeNumber = s.EmployeeNumber
WHERE s.MonthlyIncome = (
SELECT MAX(s.MonthlyIncome) AS max_salary 
FROM salary s2
JOIN employees e2
ON  e2.EmployeeNumber =s2.EmployeeNumber
WHERE e2.department=e.department
);


/*=====================================
avg performance of employees who left vs stayed.
=====================================*/

SELECT e.department ,a.attrition,AVG(p.PerformanceRating) As avg_rating 
FROM employees e
JOIN attrition a 
ON e.EmployeeNumber =a.EmployeeNumber
JOIN performance p 
ON e.EmployeeNumber =p.EmployeeNumber
GROUP BY e.department,a.attrition
ORDER BY e.department,a.attrition;

/*=====================================
 employees earning above the average salary within their department
=====================================*/

WITH dept_avg AS (
SELECT e.department ,AVG(s.MonthlyIncome) AS avg_Salary
FROM employees e
JOIN salary s
ON e.EmployeeNumber= s.EmployeeNumber 
GROUP BY e.department 
)
SELECT e.EmployeeNumber ,d.department ,s.MonthlyIncome
FROM employees e
JOIN salary s ON e.EmployeeNumber = s.EmployeeNumber 
JOIN dept_avg d ON e.department =d.department 
WHERE s.MonthlyIncome > d.avg_salary;


 /*=====================================
Salary Distribution 
shows analyzing the employees into low,mid,and high salary
=====================================*/
SELECT 
CASE 
   WHEN MonthlyIncome < 3000 THEN 'low salary'
   WHEN MonthlyIncome BETWEEN 3000 AND 6000 THEN 'Mid salary'
   ELSE  'high salary'
END As salary_distribution,
COUNT(*) AS emp_count
FROM salary 
GROUP BY salary_distribution ;


/*=====================================
  Create VIEW hr_summary
  shows employees,attrition,performance,salry in a single view use for quick report
=====================================*/
CREATE VIEW hr_summary AS 
SELECT e.EmployeeNumber, e.department,e.jobrole,s.MonthlyIncome,a.attrition,p.PerformanceRating,e.Hiredate,
e.TotalWorkingYears, a.YearsAtCompany, a.YearsInCurrentRole
FROM employees e
JOIN salary s ON e.EmployeeNumber = s.EmployeeNumber
LEFT JOIN performance p ON e.EmployeeNumber=p.EmployeeNumber
LEFT JOIN attrition a ON e.EmployeeNumber =a.EmployeeNumber;

