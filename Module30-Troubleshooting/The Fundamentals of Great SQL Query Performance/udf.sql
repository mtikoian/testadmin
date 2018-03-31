

-- Demo #6: Scalar UDFs

SET STATISTICS IO ON
SET STATISTICS TIME ON

DROP FUNCTION scalar_test
GO


CREATE FUNCTION scalar_test (@i int)
RETURNS int
AS
BEGIN
	DECLARE @ret int

	SELECT @ret = COUNT(*) 
	FROM Sales.SalesOrderDetail
	WHERE SalesOrderID < @i

	RETURN @ret
END

GO

SELECT SalesOrderNumber, h.SalesOrderID
FROM Sales.SalesOrderHeader h
	INNER JOIN Sales.SalesOrderDetail d
		ON h.SalesOrderID = d.SalesOrderID 
WHERE d.SalesOrderID <= 75123
	AND h.OrderDate > '7/25/2008'

GO

SELECT SalesOrderNumber, h.SalesOrderID
FROM Sales.SalesOrderHeader h
	INNER JOIN Sales.SalesOrderDetail d
		ON h.SalesOrderID = d.SalesOrderID 
WHERE d.SalesOrderID <= dbo.scalar_test(60932)
	AND h.OrderDate > '7/25/2008' 

GO

SELECT SalesOrderNumber, h.SalesOrderID
FROM Sales.SalesOrderHeader h
	INNER JOIN Sales.SalesOrderDetail d
		ON h.SalesOrderID = d.SalesOrderID 
WHERE d.SalesOrderID <= dbo.scalar_test(d.SalesOrderID)
	AND h.OrderDate > '7/25/2008' 

GO

-- Demo #8 -- MTVF vs ITVF

DROP FUNCTION related_sales
DROP FUNCTION related_sales_inline

GO

CREATE FUNCTION related_sales (@prod_id int)
RETURNS @ret TABLE (CustomerID int, SalesPersonID int, 
	ProductID int)
AS
BEGIN
	INSERT INTO @ret (CustomerID, SalesPersonID, ProductID)
	SELECT soh.CustomerID, soh2.SalesPersonID, sod2.ProductID
	FROM Sales.SalesOrderHeader soh
		INNER JOIN Sales.SalesOrderDetail sod 
			ON soh.SalesOrderID = sod.SalesOrderID
		INNER JOIN Sales.SalesOrderHeader soh2 
			ON soh.CustomerID = soh2.CustomerID
		INNER JOIN Sales.SalesOrderDetail sod2 
			ON soh2.SalesOrderID = sod2.SalesOrderID
		INNER JOIN Production.Product prod 
			ON sod2.ProductID = prod.ProductID
	WHERE sod.ProductID = @prod_id

	RETURN
END

GO

CREATE FUNCTION related_sales_inline (@prod_id int)
RETURNS TABLE
AS
	RETURN
	SELECT soh.CustomerID, soh2.SalesPersonID, sod2.ProductID
	FROM Sales.SalesOrderHeader soh
		INNER JOIN Sales.SalesOrderDetail sod 
			ON soh.SalesOrderID = sod.SalesOrderID
		INNER JOIN Sales.SalesOrderHeader soh2 
			ON soh.CustomerID = soh2.CustomerID
		INNER JOIN Sales.SalesOrderDetail sod2 
			ON soh2.SalesOrderID = sod2.SalesOrderID
		INNER JOIN Production.Product prod 
			ON sod2.ProductID = prod.ProductID
	WHERE sod.ProductID = @prod_id

GO

SELECT pers.LastName, pers.FirstName, prod.Name
FROM related_sales(783) rs
	INNER JOIN Sales.Customer cust 
		ON rs.CustomerID = cust.CustomerID
	INNER JOIN Person.Person pers 
		ON cust.PersonID = pers.BusinessEntityID
	INNER JOIN Production.Product prod 
		ON rs.ProductID = prod.ProductID

GO

SELECT pers.LastName, pers.FirstName, prod.Name
FROM related_sales_inline(783) rs
	INNER JOIN Sales.Customer cust 
		ON rs.CustomerID = cust.CustomerID
	INNER JOIN Person.Person pers 
		ON cust.PersonID = pers.BusinessEntityID
	INNER JOIN Production.Product prod 
		ON rs.ProductID = prod.ProductID

