USE DataWindows
GO


/**************************************************************
***   Aggregate Functions - MIN(), MAX(), AVG(), SUM(), COUNT()
**************************************************************/
select * from dbo.Personnel_Assignments;


-- Basic Aggregate Functions
set statistics io, time on;

-- Group By
SELECT
    dept_name
  , MIN(salary_amt) AS dept_salary_min
  , MAX(salary_amt) AS dept_salary_max
  , AVG(salary_amt) AS dept_salary_avg
  , SUM(salary_amt) AS dept_salary_sum
  , COUNT(*) AS dept_salary_count
FROM dbo.Personnel_Assignments
GROUP BY dept_name;


-- Individual vs Dept
SELECT pa.emp_name, pa.dept_name, pa.salary_amt
  , p.dept_salary_min
  , p.dept_salary_max
  , p.dept_salary_avg
  , p.dept_salary_sum
  , p.dept_salary_count
FROM dbo.Personnel_Assignments pa
CROSS APPLY (
			SELECT
				  MIN(salary_amt) AS dept_salary_min
			  , MAX(salary_amt) AS dept_salary_max
			  , AVG(salary_amt) AS dept_salary_avg
			  , SUM(salary_amt) AS dept_salary_sum
			  , COUNT(*) AS dept_salary_count
			FROM dbo.Personnel_Assignments x
      WHERE x.dept_name = pa.dept_name
            ) p(dept_salary_min, dept_salary_max, dept_salary_avg, dept_salary_sum, dept_salary_count)
ORDER BY pa.dept_name, pa.emp_name;


-- Over Dept
SELECT emp_name, dept_name, salary_amt
  , MIN(salary_amt) OVER (PARTITION BY dept_name) AS min_dept_salary
  , MAX(salary_amt) OVER (PARTITION BY dept_name) AS max_dept_salary
  , AVG(salary_amt) OVER (PARTITION BY dept_name) AS avg_dept_salary
  , SUM(salary_amt) OVER (PARTITION BY dept_name) AS tot_dept_salary
  , COUNT(*) OVER (PARTITION BY dept_name) AS dept_employees
FROM dbo.Personnel_Assignments;


-- Over Dataset
SELECT emp_name, dept_name, salary_amt
  , MIN(salary_amt) OVER () AS min_salary
  , MAX(salary_amt) OVER () AS max_salary
  , AVG(salary_amt) OVER () AS avg_salary
  , SUM(salary_amt) OVER () AS tot_salary
  , COUNT(*) OVER () AS tot_employees
FROM dbo.Personnel_Assignments;


-- Salary as % of Dept and Company
SELECT emp_name, dept_name, salary_amt
  , SUM(salary_amt) OVER (PARTITION BY dept_name) AS tot_dept_salary
  , pctDept = CAST(salary_amt / SUM(salary_amt) OVER (PARTITION BY dept_name) * 100 AS DECIMAL(18,2))
  , SUM(salary_amt) OVER () AS tot_salary
  , pctCoy = CAST(salary_amt / SUM(salary_amt) OVER () * 100 AS DECIMAL(18,2))
FROM dbo.Personnel_Assignments
ORDER BY dept_name, emp_name;




/*** NOTE::  DISTINCT AGGREGATES not supported
SELECT empid, orderdate, orderid, val
  , numcusts = COUNT(DISTINCT custid) OVER(PARTITION BY empid ORDER BY orderdate)
  , orders   = COUNT(*)               OVER(PARTITION BY empid ORDER BY orderdate)
FROM Sales.OrderValues;
***/
SELECT empid
     , numcusts = COUNT(DISTINCT custid)
     , orders = COUNT(*)
FROM Sales.OrderValues
GROUP BY empid;









/**************************************************************
***   Ranking Functions - ROW_NUMBER(), RANK(), DENSE_RANK() and NTILE(n)
**************************************************************/

SELECT
    emp_name
  , dept_name
  , salary_amt
  , ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY salary_amt DESC) AS [rownumber]
  , RANK()       OVER (PARTITION BY dept_name ORDER BY salary_amt DESC) AS [rank]
  , DENSE_RANK() OVER (PARTITION BY dept_name ORDER BY salary_amt DESC) AS [denserank]
FROM dbo.Personnel_Assignments
ORDER BY dept_name, salary_amt DESC;


-- Top 2 Salaries per dept
WITH cteSal AS (
  SELECT
      emp_name
    , dept_name
    , salary_amt
    , ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY salary_amt DESC) AS seq
  FROM dbo.Personnel_Assignments
)
SELECT cteSal.emp_name, cteSal.dept_name, cteSal.salary_amt
FROM cteSal
WHERE cteSal.seq <= 2
ORDER BY cteSal.dept_name, cteSal.seq;

-- But Absalom just got an increase.  He has the salary as Abel, so why is he not in the list.
-- Top 2 Salaries per dept, and all who get those salaries
WITH cteSal AS (
  SELECT
      emp_name
    , dept_name
    , salary_amt
    , RANK() OVER (PARTITION BY dept_name ORDER BY salary_amt DESC) AS seq
  FROM dbo.Personnel_Assignments
)
SELECT cteSal.emp_name, cteSal.dept_name, cteSal.salary_amt
FROM cteSal
WHERE cteSal.seq <= 2
ORDER BY cteSal.dept_name, cteSal.seq;

-- But Shipping can't all have the same salary.
WITH cteSal AS (
  SELECT
      emp_name
    , dept_name
    , salary_amt
    , DENSE_RANK() OVER (PARTITION BY dept_name ORDER BY salary_amt DESC) AS seq
  FROM dbo.Personnel_Assignments
)
SELECT cteSal.emp_name, cteSal.dept_name, cteSal.salary_amt
FROM cteSal
WHERE cteSal.seq <= 2
ORDER BY cteSal.dept_name, cteSal.seq;







/**************************************************************
***   Analytic Functions - LAG(), LEAD()               ... Offset relative to current row
                         - FIRST_VALUE(), LAST_VALUE() ... Offset relative to beginning/end of the window frame
**************************************************************/

-- Prev and next items ...
WITH cteBASEData AS (
  SELECT
      emp_name
    , dept_name
    , salary_amt
    , rn = ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY salary_amt DESC, emp_name)
  FROM dbo.Personnel_Assignments
)
SELECT
      c.emp_name
    , c.dept_name
    , c.salary_amt
    , Prev_Emp = p.emp_name
    , Next_Emp = n.emp_name
FROM cteBASEData AS c
LEFT JOIN cteBASEData AS p
   ON c.dept_name = p.dept_name
  AND c.rn = p.rn +1
LEFT JOIN cteBASEData AS n
   ON c.dept_name = n.dept_name
  AND c.rn = n.rn -1
ORDER BY c.dept_name, c.salary_amt DESC, c.emp_name;


-- Prev(LAG) and next(LEAD) items ...
SELECT
    emp_name
  , dept_name
  , salary_amt
  , Prev_Emp = LAG(emp_name) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC)
  , Next_Emp = LEAD(emp_name) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC)
FROM dbo.Personnel_Assignments;


-- Prev and next items - No NULLs ...
WITH cteBASEData AS (
  SELECT
      emp_name
    , dept_name
    , salary_amt
    , rn = ROW_NUMBER() OVER (PARTITION BY dept_name ORDER BY salary_amt DESC, emp_name)
  FROM dbo.Personnel_Assignments
)
SELECT
    c.emp_name
  , c.dept_name
  , c.salary_amt
  , Prev_Emp = ISNULL(p.emp_name, '')
  , Next_Emp = ISNULL(n.emp_name, '...')
FROM cteBASEData AS c
LEFT JOIN cteBASEData AS p
   ON c.dept_name = p.dept_name
  AND c.rn = p.rn +1
LEFT JOIN cteBASEData AS n
   ON c.dept_name = n.dept_name
  AND c.rn = n.rn -1
ORDER BY c.dept_name, c.salary_amt DESC, c.emp_name;


-- Prev and next items - No NULLs ...
SELECT
    emp_name
  , dept_name
  , salary_amt
  --          [val, Offset, DefaultVal]
  , Prev_Emp = LAG(emp_name, 2) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC)
  , Next_Emp = LEAD(emp_name, 3, 'xx') OVER (PARTITION BY dept_name ORDER BY salary_amt DESC)
FROM dbo.Personnel_Assignments;



-- First and Last Emp_Name per Dept ...
SELECT
    pa.emp_name
  , pa.dept_name
  , pa.salary_amt
  , FV_Dept_Name = FV.emp_name
  , LV_Dept_Name = LV.emp_name
FROM dbo.Personnel_Assignments AS pa
CROSS APPLY (SELECT TOP (1) emp_name FROM dbo.Personnel_Assignments AS paf
             WHERE paf.dept_name = pa.dept_name
             ORDER BY paf.salary_amt DESC, paf.emp_name) AS FV
CROSS APPLY (SELECT TOP (1) emp_name FROM dbo.Personnel_Assignments AS pal
             WHERE pal.dept_name = pa.dept_name
             ORDER BY pal.salary_amt, pal.emp_name DESC) AS LV
ORDER BY pa.dept_name, pa.salary_amt DESC, pa.emp_name;


SELECT
    emp_name
  , dept_name
  , salary_amt
  , FV_Dept_Name = FIRST_VALUE(emp_name) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC, emp_name)
  , LV_Dept_Name = LAST_VALUE(emp_name) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC, emp_name)
FROM dbo.Personnel_Assignments
ORDER BY dept_name, salary_amt DESC, emp_name;


SELECT
    emp_name
  , dept_name
  , salary_amt
  , FV_Dept_Name = FIRST_VALUE(emp_name) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC
                                               RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
  , LV_Dept_Name = LAST_VALUE(emp_name) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC, emp_name
                                               ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
FROM dbo.Personnel_Assignments
ORDER BY dept_name, salary_amt DESC, emp_name;


-- NOTE: RANGE is over "PARTITION BY, ORDER BY", ROWS is over "PARTITION BY"
SELECT
    emp_name
  , dept_name
  , salary_amt
  , RANGE_SUM = SUM(salary_amt) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC
                                               RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
  , ROW_SUM = SUM(salary_amt) OVER (PARTITION BY dept_name ORDER BY salary_amt DESC
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM dbo.Personnel_Assignments
ORDER BY dept_name, salary_amt DESC, emp_name;



set statistics io, time off;
