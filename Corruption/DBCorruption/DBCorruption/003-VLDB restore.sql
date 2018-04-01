-- Restoring VLDB after disaster
-- https://msdn.microsoft.com/en-us/library/ms190394.aspx



-- 1. Restore only PRIMARY filegroup

RESTORE DATABASE [AdventureWorks2014_Demo03] 
FILEGROUP = 'PRIMARY'
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03_01.bak' 
WITH  PARTIAL, NORECOVERY, STATS = 20
GO
RESTORE LOG [AdventureWorks2014_Demo03] 
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03-TLog_01.bak' WITH RECOVERY





USE [AdventureWorks2014_Demo03]
GO
SELECT OBJECT_NAME(i.[object_id]) AS [ObjectName]
    ,i.[index_id] AS [IndexID]
    ,i.[name] AS [IndexName]
    ,i.[type_desc] AS [IndexType]
    ,i.[data_space_id] AS [DatabaseSpaceID]
    ,f.[name] AS [FileGroup]
    ,d.[physical_name] AS [DatabaseFileName]
FROM [sys].[indexes] i
INNER JOIN [sys].[filegroups] f
    ON f.[data_space_id] = i.[data_space_id]
INNER JOIN [sys].[database_files] d
    ON f.[data_space_id] = d.[data_space_id]
INNER JOIN [sys].[data_spaces] s
    ON f.[data_space_id] = s.[data_space_id]
WHERE OBJECTPROPERTY(i.[object_id], 'IsUserTable') = 1
ORDER BY i.[data_space_id] DESC
GO





-- check if query works
USE [AdventureWorks2014_Demo03]
GO
SELECT TOP 10 ProductID, SUM(ProductID) AS [Sum] FROM [AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail] 
GROUP BY ProductID

SELECT * FROM [AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail]

SELECT * FROM [AdventureWorks2014_Demo03].[Sales].[Customer]

SELECT * FROM [AdventureWorks2014_Demo03].[Production].[ProductListPriceHistory]

DBCC CHECKDB ('AdventureWorks2014_Demo03') WITH NO_INFOMSGS

USE [master]
GO
RESTORE DATABASE [AdventureWorks2014_Demo03] 
FILEGROUP = 'Data'
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03_01.bak' 
WITH NORECOVERY, STATS = 20
GO
RESTORE LOG [AdventureWorks2014_Demo03] 
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03-TLog_01.bak' WITH RECOVERY





-- check if query works
USE [AdventureWorks2014_Demo03]
GO
SELECT TOP 10 ProductID, SUM(ProductID) AS [Sum] 
FROM [AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail] 
GROUP BY ProductID

SELECT * 
FROM [AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail]

SELECT * 
FROM [AdventureWorks2014_Demo03].[Sales].[Customer]

SELECT * 
FROM [AdventureWorks2014_Demo03].[Production].[ProductListPriceHistory]

USE [master]
GO
RESTORE DATABASE [AdventureWorks2014_Demo03] 
FILEGROUP = 'Index'
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03_01.bak' 
WITH NORECOVERY, STATS = 20
GO
RESTORE LOG [AdventureWorks2014_Demo03] 
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03-TLog_01.bak' WITH RECOVERY


-- check if query works
USE [AdventureWorks2014_Demo03]
GO
SELECT TOP 100 
ProductID, SUM(ProductID) AS [Sum] 
FROM [AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail] 
GROUP BY ProductID

SELECT	* 
FROM [AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail]

SELECT	* 
FROM [AdventureWorks2014_Demo03].[Sales].[Customer]

SELECT	* 
FROM [AdventureWorks2014_Demo03].[Production].[ProductListPriceHistory]





USE [master]
GO
RESTORE DATABASE [AdventureWorks2014_Demo03] 
FILEGROUP = 'ReadOnly'
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03_01.bak' 
WITH NORECOVERY, STATS = 20
GO
RESTORE LOG [AdventureWorks2014_Demo03] 
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo03-TLog_01.bak' WITH RECOVERY


USE [AdventureWorks2014_Demo03]
GO
SELECT 
	ProductID, 
	SUM(ProductID) AS [Sum] 
FROM [AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail] 
GROUP BY ProductID

SELECT * 
FROM 
	[AdventureWorks2014_Demo03].[Sales].[SalesOrderDetail]

SELECT * 
FROM 
	[AdventureWorks2014_Demo03].[Sales].[Customer]

SELECT * 
FROM 
	[AdventureWorks2014_Demo03].[Production].[ProductListPriceHistory]


--Cleanup
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014_Demo03'
GO
USE [master]
GO
ALTER DATABASE [AdventureWorks2014_Demo03] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [AdventureWorks2014_Demo03]
GO
