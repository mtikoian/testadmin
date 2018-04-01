-- Preperation
RESTORE DATABASE [AdventureWorks2014_Demo01] 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo01.bak' 
WITH  FILE = 1,  NOUNLOAD,  STATS = 10, CONTINUE_AFTER_ERROR
GO






USE [AdventureWorks2014_Demo01]
GO
SELECT ProductID, SUM(ProductID) AS [Sum] FROM [AdventureWorks2014_Demo01].[Sales].[SalesOrderDetail] 
GROUP BY ProductID




-- but SELECT * works...
SELECT * FROM [AdventureWorks2014_Demo01].[Sales].[SalesOrderDetail]






DBCC CHECKDB (AdventureWorks2014_Demo01) WITH NO_INFOMSGS
GO






DBCC TRACEON (3604);
GO
DBCC PAGE ('AdventureWorks2014_Demo01',4,456,1)
GO

USE [AdventureWorks2014_Demo01]
GO
SELECT id, indid, name 
FROM sys.sysindexes 
WHERE id = '1154103152' AND indid = 3






-- let's try to rebuild
ALTER INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail] REBUILD








-- drop and create approach
DROP INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
GO
CREATE NONCLUSTERED INDEX [IX_SalesOrderDetail_ProductID] ON [Sales].[SalesOrderDetail]
(
	[ProductID] ASC
)
GO


-- but what about situation that we have many, many columns in index?






--  we can use some small hack ;)
BEGIN TRAN 
	ALTER 
		INDEX [IX_SalesOrderDetail_ProductID] 
		ON [Sales].[SalesOrderDetail] DISABLE
	ALTER 
		INDEX [IX_SalesOrderDetail_ProductID] 
		ON [Sales].[SalesOrderDetail] REBUILD
COMMIT
GO












-- check if query works
SELECT ProductID, SUM(ProductID) AS [Sum] 
FROM [AdventureWorks2014_Demo01].[Sales].[SalesOrderDetail] 
GROUP BY ProductID

SELECT * FROM [AdventureWorks2014_Demo01].[Sales].[SalesOrderDetail] 






SELECT * FROM msdb.dbo.suspect_pages









--Cleanup
DELETE FROM msdb..suspect_pages
GO
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014'
GO
USE [master]
GO
ALTER DATABASE [AdventureWorks2014_Demo01] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [AdventureWorks2014_Demo01]
GO
