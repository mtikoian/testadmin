----------------------------------------------------------------------
-- Boost your T-SQL with the APPLY Operator
-- © Itzik Ben-Gan, SolidQ
-- For more, see 5-day Advanced T-SQL Course:
-- http://tsql.solidq.com/courses.htm
----------------------------------------------------------------------

SET NOCOUNT ON;
USE TSQL2012;

-- Performance database: http://tsql.solidq.com/books/source_code/Performance.txt
-- TSQL2012 database: http://tsql.solidq.com/books/source_code/TSQL2012.zip

---------------------------------------------------------------------
-- APPLY, Described
---------------------------------------------------------------------

USE TSQL2012;

-- cross join
-- return a row for every combination of customer and year in the range 2012 - 2014
SELECT C.custid, C.companyname, Y.n AS orderyear
FROM Sales.Customers AS C
  CROSS JOIN dbo.GetNums(2012, 2014) AS Y
ORDER BY C.custid, orderyear;
GO

-- inner join
-- return information about customers and their orders
SELECT C.custid, C.companyname, O.orderid, O.orderdate, O.empid
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON C.custid = O.custid;

-- definition of GetTopOrders function
IF OBJECT_ID('dbo.GetTopOrders') IS NOT NULL
  DROP FUNCTION dbo.GetTopOrders;
GO

CREATE FUNCTION dbo.GetTopOrders(@custid AS INT, @n AS BIGINT)
  RETURNS TABLE
AS
RETURN
  SELECT TOP (@n) orderid, orderdate, empid
  FROM Sales.Orders
  WHERE custid = @custid
  ORDER BY orderdate DESC, orderid DESC;
GO

SELECT * FROM dbo.GetTopOrders(1, 3) AS O;
GO

-- attempt to return the three most-recent orders for every customer
-- using a cross join fails
SELECT C.custid, C.companyname, O.orderid, O.orderdate, O.empid
FROM Sales.Customers AS C
  CROSS JOIN dbo.GetTopOrders(C.custid, 3) AS O;

-- using an inner join fails
SELECT C.custid, C.companyname, O.orderid, O.orderdate, O.empid
FROM Sales.Customers AS C
  INNER JOIN dbo.GetTopOrders(C.custid, 3) AS O
--    ON ?;
GO

-- CROSS APPLY
SELECT C.custid, C.companyname, O.orderid, O.orderdate, O.empid
FROM Sales.Customers AS C
  CROSS APPLY dbo.GetTopOrders(C.custid, 3) AS O;

-- OUTER APPLY
SELECT C.custid, C.companyname, O.orderid, O.orderdate, O.empid
FROM Sales.Customers AS C
  OUTER APPLY dbo.GetTopOrders(C.custid, 3) AS O;

-- Implicit APPLY
SELECT C.custid, C.companyname,
  (SELECT COUNT(DISTINCT empid)
   FROM  dbo.GetTopOrders(C.custid, 3) AS O) AS numemps
FROM Sales.Customers AS C;

---------------------------------------------------------------------
-- 7.0 - TOP
---------------------------------------------------------------------

USE TSQL2012;

-- TOP N Per Group

-- create POC index
CREATE UNIQUE INDEX idx_poc
  ON Sales.Orders(custid, orderdate DESC, orderid DESC)
  INCLUDE(empid);

-- solution for low density
WITH C AS
(
  SELECT 
    ROW_NUMBER() OVER(
      PARTITION BY custid
      ORDER BY orderdate DESC, orderid DESC) AS rownum,
    orderid, orderdate, custid, empid
  FROM Sales.Orders
)
SELECT custid, orderdate, orderid, empid
FROM C
WHERE rownum <= 3;

-- solution for high density
SELECT C.custid, A.*
FROM Sales.Customers AS C
  CROSS APPLY ( SELECT TOP (3) orderid, orderdate, empid
                FROM Sales.Orders AS O
                WHERE O.custid = C.custid
                ORDER BY orderdate DESC, orderid DESC    ) AS A;

-- cleanup
DROP INDEX idx_poc ON Sales.Orders;

---------------------------------------------------------------------
-- 2000 - User Defined Functions
---------------------------------------------------------------------

USE Performance;

-- inline expression
SELECT *
FROM dbo.Orders
WHERE orderdate = DATEADD(year, DATEDIFF(year, '19001231', orderdate), '19001231');

-- scalar UDF
IF OBJECT_ID(N'dbo.EndOfYear') IS NOT NULL
  DROP FUNCTION dbo.EndOfYear;
GO

CREATE FUNCTION dbo.EndOfYear( @dt AS DATETIME ) RETURNS DATETIME
AS
BEGIN
  RETURN DATEADD(year, DATEDIFF(year, '19001231', @dt), '19001231')
END;
GO

SELECT *
FROM dbo.Orders
WHERE orderdate = dbo.EndOfYear(orderdate);
GO

-- inline UDF
IF OBJECT_ID(N'dbo.EndOfYear') IS NOT NULL
  DROP FUNCTION dbo.EndOfYear;
GO

CREATE FUNCTION dbo.EndOfYear( @dt AS DATETIME ) RETURNS TABLE
AS
RETURN SELECT DATEADD(year, DATEDIFF(year, '19001231', @dt), '19001231') AS eoy
GO

SELECT O.*
FROM dbo.Orders AS O
  CROSS APPLY dbo.EndOfYear( O.orderdate ) AS A
WHERE O.orderdate = A.eoy;

---------------------------------------------------------------------
-- 2005 - Partitioning
---------------------------------------------------------------------

-- Aggregates Over Partitioned Tables

-- Creating Sample Data

-- Create sample database TestMinMax
SET NOCOUNT ON;
USE master;
IF DB_ID('TestMinMax') IS NOT NULL
  DROP DATABASE TestMinMax;
CREATE DATABASE TestMinMax
GO
USE TestMinMax;
GO

-- Create and populate partitioned table T1
CREATE PARTITION FUNCTION PF1 (INT)
AS RANGE LEFT FOR VALUES (200000, 400000, 600000, 800000);

CREATE PARTITION SCHEME PS1
AS PARTITION PF1 ALL TO ([PRIMARY]);

CREATE TABLE dbo.T1
(
  col1 INT NOT NULL,
  col2 INT NOT NULL,
  filler BINARY(200) NOT NULL DEFAULT(0x01)
) ON PS1(col1);

CREATE UNIQUE CLUSTERED INDEX idx_col1 ON dbo.T1(col1) ON PS1(col1);
CREATE NONCLUSTERED INDEX idx_col2 ON dbo.T1(col2) ON PS1(col1);

INSERT INTO dbo.T1 WITH (TABLOCK) (col1, col2)
  SELECT n, CHECKSUM(NEWID()) FROM TSQL2012.dbo.GetNums(1, 1000000);
GO

-- Query 1
-- Efficient because applying aggregate to partitioning column
SELECT MAX(col1) AS mx
FROM dbo.T1;

-- Query 2
-- Inefficient because applying aggregate to nonpartitioning column
-- even though index exists on col2 due to optimization bug
SELECT MAX(col2) AS mx
FROM dbo.T1;

-- Query 3
-- Example showing efficient index use with one partition
SELECT MAX(col2) AS pmx
FROM dbo.T1
WHERE $PARTITION.PF1(col1) = 1;

-- Query 4
-- Workaround to original need MAX(col2) with dynamic querying of partitions in table
SELECT MAX(A.pmx) AS mx
FROM sys.partitions AS P
  CROSS APPLY ( SELECT MAX(T1.col2) AS pmx
                FROM dbo.T1
                WHERE $PARTITION.PF1(T1.col1) = P.partition_number ) AS A
WHERE P.object_id = OBJECT_ID('dbo.T1')
  AND P.index_id = INDEXPROPERTY( OBJECT_ID('dbo.T1'), 'idx_col2', 'IndexID' );

-- Improving Parallelism

USE Performance;
CREATE INDEX idx1 ON dbo.Orders(empid) INCLUDE(orderid);

-- Slow
SELECT empid, orderid,
  ROW_NUMBER() OVER(PARTITION BY empid
                    ORDER BY orderid) AS rownum1_asc,
  ROW_NUMBER() OVER(PARTITION BY empid 
                    ORDER BY orderid DESC) AS rownum1_desc
FROM dbo.Orders;

-- with APPLY
SELECT A.*
FROM dbo.Employees AS E
  CROSS APPLY
    (SELECT empid, orderid,
       ROW_NUMBER() OVER(ORDER BY orderid) AS rownum1_asc,
       ROW_NUMBER() OVER(ORDER BY orderid DESC) AS rownum1_desc
     FROM dbo.Orders AS O
     WHERE O.empid = E.empid) AS A
OPTION(QUERYTRACEON 8649);

-- cleanup
DROP INDEX idx1 ON dbo.Orders;

---------------------------------------------------------------------
-- 2008 - VALUES
---------------------------------------------------------------------

USE TSQL2012;

-- Reuse of Column Aliases
SELECT
  start_of_week,
  DATEADD(day, 6, start_of_week) AS end_of_week,
  SUM(val) AS total_val,
  COUNT(*) AS num_orders
FROM Sales.OrderValues
  CROSS APPLY (VALUES(DATEPART(weekday, orderdate) - 1)) AS A1(dist)
  CROSS APPLY (VALUES(DATEADD(day, -dist, orderdate))) AS A2(start_of_week)
GROUP BY start_of_week;

-- Unpivoting Multiple Sets of Columns

-- Code to Create and Populate the Sales Table
USE tempdb;
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
GO

CREATE TABLE dbo.Sales
(
  custid    VARCHAR(10) NOT NULL,
  qty2012   INT   NULL,
  qty2013   INT   NULL,
  qty2014   INT   NULL,
  val2012   MONEY NULL,
  val2013   MONEY NULL,
  val2014   MONEY NULL,
  CONSTRAINT PK_Sales PRIMARY KEY(custid)
);

INSERT INTO dbo.Sales
    (custid, qty2012, qty2013, qty2014, val2012, val2013, val2014)
  VALUES
    ('A', 606,113,781,4632.00,6877.00,4815.00),
    ('B', 243,861,637,2125.00,8413.00,4476.00),
    ('C', 932,117,202,9068.00,342.00,9083.00),
    ('D', 915,833,138,1131.00,9923.00,4164.00),
    ('E', 822,246,870,1907.00,3860.00,7399.00);

-- Solution with APPLY
SELECT custid, salesyear, qty, val
FROM dbo.Sales
  CROSS APPLY 
    ( VALUES(2012, qty2012, val2012),
            (2013, qty2013, val2013),
            (2014, qty2014, val2014) ) AS A(salesyear, qty, val);

-- Aggregate Over Columns

-- Code to Create and Populate the Sales Table
USE tempdb;
IF OBJECT_ID('dbo.Sales', 'U') IS NOT NULL DROP TABLE dbo.Sales;
GO

CREATE TABLE dbo.Sales
(
  custid    VARCHAR(10) NOT NULL,
  salesyear INT NOT NULL,
  [01]      INT NULL,
  [02]      INT NULL,
  [03]      INT NULL,
  [04]      INT NULL,
  [05]      INT NULL,
  [06]      INT NULL,
  [07]      INT NULL,
  [08]      INT NULL,
  [09]      INT NULL,
  [10]      INT NULL,
  [11]      INT NULL,
  [12]      INT NULL,
  CONSTRAINT PK_Sales PRIMARY KEY(custid, salesyear)
);

INSERT INTO dbo.Sales
    (custid, salesyear, [01],[02],[03],[04],[05],[06],[07],[08],[09],[10],[11],[12])
  VALUES
    ('A', 2013, 90,41,75,9,85,6,65,5,30,90,11,71),
    ('A', 2014, 29,29,8,95,1,16,36,74,59,43,31,49),
    ('B', 2012, 29,51,92,15,2,45,26,90,34,14,25,9),
    ('B', 2013, 39,8,94,25,30,35,42,75,62,7,98,19),
    ('B', 2014, 39,22,41,56,5,27,2,22,32,52,74,26);

-- Solution with APPLY
SELECT *
FROM dbo.Sales
  CROSS APPLY
    (SELECT MIN(qty) AS mn, MAX(qty) AS mx
     FROM (VALUES([01]),([02]),([03]),
                 ([04]),([05]),([06]),
                 ([07]),([08]),([09]),
                 ([10]),([11]),([12])) AS D(qty)) AS A;

---------------------------------------------------------------------
-- 2012 - OFFSET-FETCH
---------------------------------------------------------------------

-- Median

USE TSQL2012;

-- Small set of sample data
IF OBJECT_ID('dbo.T1', 'U') IS NOT NULL DROP TABLE dbo.T1;
GO

CREATE TABLE dbo.T1
(
  id  INT NOT NULL IDENTITY
    CONSTRAINT PK_T1 PRIMARY KEY,
  grp INT NOT NULL,
  val INT NOT NULL
);

CREATE INDEX idx_grp_val ON dbo.T1(grp, val);

INSERT INTO dbo.T1(grp, val)
  VALUES(1, 30),(1, 10),(1, 100),
        (2, 65),(2, 60),(2, 65),(2, 10);
GO

-- Large set of sample data
DECLARE
  @numgroups AS INT = 10,
  @rowspergroup AS INT = 1000000;

TRUNCATE TABLE dbo.T1;

DROP INDEX idx_grp_val ON dbo.T1;

INSERT INTO dbo.T1 WITH(TABLOCK) (grp, val)
  SELECT G.n, ABS(CHECKSUM(NEWID())) % 101
  FROM dbo.GetNums(1, @numgroups) AS G
    CROSS JOIN dbo.GetNums(1, @rowspergroup) AS R;

CREATE INDEX idx_grp_val ON dbo.T1(grp, val);

-- Solution Using PERCENTILE_CONT
SELECT DISTINCT grp,
  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY val)
    OVER(PARTITION BY grp) AS median
FROM dbo.T1;

-- Solution Using APPLY and OFFSET-FETCH
WITH C AS
(
  SELECT grp,
    COUNT(*) AS cnt,
    (COUNT(*) - 1) / 2 AS offset_val,
    2 - COUNT(*) % 2 AS fetch_val
  FROM dbo.T1
  GROUP BY grp
)
SELECT grp, AVG(1. * val) AS median
FROM C
  CROSS APPLY ( SELECT O.val
                FROM dbo.T1 AS O
                where O.grp = C.grp
                order by O.val
                OFFSET C.offset_val ROWS FETCH NEXT C.fetch_val ROWS ONLY ) AS A
GROUP BY grp;

-- Reducing Lookups
USE Performance;
GO

DECLARE @pagenum AS BIGINT = 3, @pagesize AS BIGINT = 25;

SELECT orderid, orderdate, custid, empid
FROM dbo.Orders
ORDER BY orderid
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;
GO

DECLARE @pagenum AS BIGINT = 20000, @pagesize AS BIGINT = 25;

SELECT orderid, orderdate, custid, empid
FROM dbo.Orders
ORDER BY orderid
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;
GO

DECLARE @pagenum AS BIGINT = 20000, @pagesize AS BIGINT = 25;

WITH C AS
(
  SELECT orderid, orderdate
  FROM dbo.Orders
  ORDER BY orderid
  OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY
)
SELECT C.*, A.*
FROM C CROSS APPLY (SELECT custid, empid
                    FROM dbo.Orders AS O
                    WHERE O.orderid = C.orderid) AS A;
GO