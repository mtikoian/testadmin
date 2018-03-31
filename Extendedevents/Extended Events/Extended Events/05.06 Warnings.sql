
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name = 'UnmatchedIndexes')
	DROP EVENT SESSION [UnmatchedIndexes] ON SERVER
GO

CREATE EVENT SESSION [UnmatchedIndexes] ON SERVER 
ADD EVENT sqlserver.unmatched_filtered_indexes(
    ACTION(sqlserver.plan_handle
	,sqlserver.sql_text
	,sqlserver.tsql_frame
	,sqlserver.tsql_stack)
    WHERE ([sqlserver].[is_system]=(0) AND [sqlserver].[database_id]>(3)))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS
,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [UnmatchedIndexes] ON SERVER STATE = START
GO

USE AdventureWorks2014
GO

SET STATISTICS IO ON

IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'FTR_IX_SalesOrderDetail_ProductID')
	DROP INDEX FTR_IX_SalesOrderDetail_ProductID ON [Sales].[SalesOrderDetail]

SELECT * FROM Production.Product
WHERE ProductID = 870

SELECT sd.SalesOrderID, sd.SalesOrderDetailID, sd.OrderQty, sd.ProductID, sd.LineTotal, sd.CarrierTrackingNumber, sd.ModifiedDate, sd.UnitPriceDiscount
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID 
WHERE sd.ProductID = 870
--Table 'SalesOrderDetail'. Scan count 1, logical reads 1246, physical reads 2, read-ahead reads 1277, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

CREATE NONCLUSTERED INDEX FTR_IX_SalesOrderDetail_ProductID
ON [Sales].[SalesOrderDetail] ([ProductID])
INCLUDE ([SalesOrderID],[SalesOrderDetailID],[OrderQty],[LineTotal],[CarrierTrackingNumber], [ModifiedDate], [UnitPriceDiscount])
WHERE ProductID >= 800 
AND ProductID < 900
GO

SELECT sd.SalesOrderID, sd.SalesOrderDetailID, sd.OrderQty, sd.ProductID, sd.LineTotal, sd.CarrierTrackingNumber, sd.ModifiedDate, sd.UnitPriceDiscount
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID 
WHERE sd.ProductID = 870
GO
--Table 'SalesOrderDetail'. Scan count 1, logical reads 37, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

DECLARE @ProductID int = 870

SELECT sd.SalesOrderID, sd.SalesOrderDetailID, sd.OrderQty, sd.ProductID, sd.LineTotal
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID 
WHERE sd.ProductID = @ProductID
GO
--Table 'SalesOrderDetail'. Scan count 1, logical reads 1246, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

DECLARE @ProductID int = 870

SELECT sd.SalesOrderID, sd.SalesOrderDetailID, sd.OrderQty, sd.ProductID, sd.LineTotal
FROM Sales.SalesOrderHeader sh
JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID 
WHERE sd.ProductID >= 800 
AND sd.ProductID < 900
AND sd.ProductID = @ProductID
GO

DECLARE @ProductID INT = 700
--DECLARE @ProductID INT = 870

DECLARE @SQL NVARCHAR(MAX)

SET @SQL = CONCAT('SELECT sd.SalesOrderID, sd.SalesOrderDetailID, sd.OrderQty, sd.ProductID, sd.LineTotal
	FROM Sales.SalesOrderHeader sh
	JOIN Sales.SalesOrderDetail sd ON sh.SalesOrderID = sd.SalesOrderID 
	WHERE sd.ProductID = ',@ProductID)

PRINT @SQL 

EXEC sp_ExecuteSQL @SQL