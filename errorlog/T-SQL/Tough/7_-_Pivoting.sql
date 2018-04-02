USE DataWindows
GO




/**************************************************************
***   Pivoting
**************************************************************/


-- total order values for each year and month
-- show years on rows, months on columns, and total order values in data
WITH cteSource AS (
  SELECT YEAR(orderdate) AS orderyear, MONTH(orderdate) AS ordermonth, val
  FROM Sales.OrderValues
)
SELECT *
FROM cteSource
  PIVOT(SUM(val)
    FOR ordermonth IN ([1],[2],[3],[4],[5]) ) AS P; --,[6],[7],[8],[9],[10],[11],[12]) ) AS P; --



-- Find order values of 5 most recent orders per customer
-- show customer IDs on rows, ordinals on columns, and total order values in data

-- generate row numbers
SELECT custid, val,
  ROW_NUMBER() OVER(PARTITION BY custid
                    ORDER BY orderdate DESC, orderid DESC) AS rownum
FROM Sales.OrderValues;

-- handle pivoting
WITH cteSource AS (
  SELECT custid, val,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate DESC, orderid DESC) AS rownum
  FROM Sales.OrderValues
)
SELECT *
FROM cteSource
  PIVOT(MAX(val) FOR rownum IN ([1],[2],[3],[4],[5])) AS P;



-- concatenate order IDs of 5 most recent orders per customer
WITH cteSource AS (
  SELECT custid, CAST(orderid AS VARCHAR(11)) AS sorderid,
    ROW_NUMBER() OVER(PARTITION BY custid
                      ORDER BY orderdate DESC, orderid DESC) AS rownum
  FROM Sales.OrderValues
)
SELECT custid, CONCAT([1], ','+[2], ','+[3], ','+[4], ','+[5]) AS orderids
FROM cteSource
  PIVOT(MAX(sorderid) FOR rownum IN ([1],[2],[3],[4],[5])) AS P;

