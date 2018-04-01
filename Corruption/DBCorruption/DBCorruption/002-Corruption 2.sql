RESTORE DATABASE [AdventureWorks2014_Demo02] 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014-FullRecovery.bak' 
WITH  FILE = 1,  
MOVE N'AdventureWorks2014_Default' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo02_PRIMARY.mdf',  
MOVE N'AdventureWorks2014_Data' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo02_Data.ndf',  
MOVE N'AdventureWorks2014_Index' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo02_Index.ndf', 
MOVE N'AdventureWorks2014_RO' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo02_RO.ndf',  
MOVE N'AdventureWorks2014_TLog' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo02_TLog.ldf',  NOUNLOAD,  STATS = 20
GO

BACKUP DATABASE [AdventureWorks2014_Demo02] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02_01.bak' WITH FORMAT, INIT,  NAME = N'AdventureWorks2014_Demo02-Full Database Backup', COMPRESSION,  STATS = 10
GO

BACKUP LOG [AdventureWorks2014_Demo02] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02-TLog_01.bak' WITH INIT

-- CL Index corruption
ALTER DATABASE [AdventureWorks2014_Demo02] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
-- http://www.sqlskills.com/blogs/paul/dbcc-writepage/ ,AdventureWorks2014, file 3, page 8, offset 0, value 1, value 0x00, bufferpool 1
ALTER DATABASE [AdventureWorks2014_Demo02] SET MULTI_USER WITH ROLLBACK IMMEDIATE







USE [AdventureWorks2014_Demo02]
GO
SELECT ProductID, SUM(ProductID) AS [Sum] FROM [AdventureWorks2014_Demo02].[Sales].[SalesOrderDetail] 
GROUP BY ProductID








-- check SELECT * 
SELECT * FROM [AdventureWorks2014_Demo02].[Sales].[SalesOrderDetail]








DBCC CHECKDB (AdventureWorks2014_Demo02) WITH NO_INFOMSGS
GO








DBCC TRACEON (3604);
GO
DBCC PAGE ('AdventureWorks2014_Demo02',3,8,2)
GO








USE [AdventureWorks2014_Demo02]
GO
SELECT id, indid, name
FROM sys.sysindexes 
WHERE id = '1154103152' AND indid = 1








BEGIN TRAN 
	ALTER 
		INDEX PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID 
		ON [Sales].[SalesOrderDetail] DISABLE
	ALTER 
		INDEX PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID 
		ON [Sales].[SalesOrderDetail] REBUILD
COMMIT
GO





-- ups, doesn't work...








-- last option - restore from full backup
USE [master]
GO
RESTORE DATABASE [AdventureWorks2014_Demo02] 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02_01.bak' WITH  FILE = 1,  
NORECOVERY,  NOUNLOAD,  STATS = 10

-- but...






-- in Enterprise Edition you can restore single page ;) 
USE [master]
GO
RESTORE DATABASE [AdventureWorks2014_Demo02] 
PAGE='3:8' 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02_01.bak' WITH  FILE = 1,  
NORECOVERY,  NOUNLOAD,  STATS = 10

BACKUP LOG [AdventureWorks2014_Demo02] TO DISK = 'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02_Tail.bak' WITH INIT;
GO

-- ... and restore it again.

RESTORE LOG [AdventureWorks2014_Demo02] FROM DISK = 'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02-TLog_01.bak';
GO


RESTORE LOG [AdventureWorks2014_Demo02] FROM DISK = 'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02_Tail.bak';
GO








-- check if query works
USE [AdventureWorks2014_Demo02]
GO
SELECT ProductID, SUM(ProductID) AS [Sum] FROM [AdventureWorks2014_Demo02].[Sales].[SalesOrderDetail] 
GROUP BY ProductID

SELECT * FROM [AdventureWorks2014_Demo02].[Sales].[SalesOrderDetail]








--Cleanup
DELETE FROM msdb..suspect_pages
GO
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014_Demo02'
GO
USE [master]
GO
ALTER DATABASE [AdventureWorks2014_Demo02] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [AdventureWorks2014_Demo02]
GO
