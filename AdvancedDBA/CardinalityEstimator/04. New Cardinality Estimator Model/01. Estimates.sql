

USE AdventureWorks2012
GO

EXEC sp_helpindex '[Sales].[SalesOrderDetail]'

SELECT COUNT(*) 
FROM [Sales].[SalesOrderDetail]
WHERE ProductID=870

--DBCC SHOW_STATISTICS('[Sales].[SalesOrderDetail]','IX_SalesOrderDetail_ProductID')