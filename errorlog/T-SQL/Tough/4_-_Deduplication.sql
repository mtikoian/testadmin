USE DataWindows
GO




/**************************************************************
***   Removing Duplicates
**************************************************************/

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;
GO

SELECT * INTO Sales.MyOrders
FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders;
GO

--sp_help 'Sales.Orders'
SELECT * FROM Sales.MyOrders
ORDER BY orderid;



-- find duplicates
SELECT *
FROM Sales.MyOrders
WHERE orderid IN (10248, 10249)
ORDER BY orderid;

SELECT orderid,
  ROW_NUMBER() OVER(PARTITION BY orderid
                    ORDER BY (SELECT NULL)) AS n
FROM Sales.MyOrders;



-- small number of duplicates
-- remove duplicates
WITH cteDups AS (
  SELECT orderid,
    ROW_NUMBER() OVER(PARTITION BY orderid
                      ORDER BY (SELECT NULL)) AS n
  FROM Sales.MyOrders
)
DELETE FROM cteDups
WHERE n > 1;

SELECT *
FROM Sales.MyOrders
WHERE orderid IN (10248, 10249);



-- another solution

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;
GO

SELECT * INTO Sales.MyOrders
FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders;
GO


-- mark row numbers and ranks
SELECT orderid,
  ROW_NUMBER() OVER(ORDER BY orderid) AS rownum,
  RANK() OVER(ORDER BY orderid) AS rnk
FROM Sales.MyOrders;


-- remove duplicates
WITH cteDups AS (
  SELECT orderid,
    ROW_NUMBER() OVER(ORDER BY orderid) AS rownum,
    RANK() OVER(ORDER BY orderid) AS rnk
  FROM Sales.MyOrders
)
DELETE FROM cteDups
WHERE rownum != rnk;

SELECT *
FROM Sales.MyOrders
WHERE orderid IN (10248, 10249);




-- Large number of duplicates

IF OBJECT_ID('Sales.MyOrders') IS NOT NULL DROP TABLE Sales.MyOrders;
GO

SELECT * INTO Sales.MyOrders
FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders
UNION ALL
SELECT * FROM Sales.Orders;
GO


WITH cteDups AS (
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY orderid
                      ORDER BY (SELECT NULL)) AS n
  FROM Sales.MyOrders
)
SELECT orderid, custid, empid, orderdate, requireddate, shippeddate, 
  shipperid, freight, shipname, shipaddress, shipcity, shipregion, 
  shippostalcode, shipcountry
INTO Sales.OrdersTmp
FROM cteDups
WHERE n = 1;

DROP TABLE Sales.MyOrders;
EXEC sp_rename 'Sales.OrdersTmp', 'MyOrders';
-- recreate indexes, constraints, triggers
