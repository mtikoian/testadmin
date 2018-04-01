RESTORE DATABASE [AdventureWorks2014_Demo04] 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014-FullRecovery.bak' 
WITH  FILE = 1,  
MOVE N'AdventureWorks2014_Default' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo04_PRIMARY.mdf',  
MOVE N'AdventureWorks2014_Data' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo04_Data.ndf',  
MOVE N'AdventureWorks2014_Index' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo04_Index.ndf',  
MOVE N'AdventureWorks2014_RO' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo04_RO.ndf',  
MOVE N'AdventureWorks2014_TLog' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo04_TLog.ldf',  NOUNLOAD,  STATS = 5
GO

BACKUP DATABASE [AdventureWorks2014_Demo05] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05_01.bak' WITH FORMAT, INIT,  NAME = N'AdventureWorks2014_Demo05-Full Database Backup', COMPRESSION,  STATS = 10
GO

BACKUP LOG [AdventureWorks2014_Demo05] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05-TLog_01.bak' WITH INIT



-- NCL Index corruption
ALTER DATABASE [AdventureWorks2014_Demo02] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
-- http://www.sqlskills.com/blogs/paul/dbcc-writepage/ ,AdventureWorks2014, file 4, page 456, offset 0, length 1, value 0x00, bufferpool 1
ALTER DATABASE [AdventureWorks2014_Demo02] SET MULTI_USER WITH ROLLBACK IMMEDIATE

-- CL Index corruption

ALTER DATABASE [AdventureWorks2014_Demo02] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
-- http://www.sqlskills.com/blogs/paul/dbcc-writepage/ ,AdventureWorks2014, file 3, page 8, offset 0, length 1, value 0x00, bufferpool 1
ALTER DATABASE [AdventureWorks2014_Demo02] SET MULTI_USER WITH ROLLBACK IMMEDIATE

CHECKPOINT

USE AdventureWorks2014
GO
DBCC TRACEON (3604);

GO
DBCC IND ('AdventureWorks2014', 'Sales.SalesOrderDetail', 1);

DBCC PAGE ('AdventureWorks2014',1,5227,3)

SELECT OBJECT_NAME(1554104577)
SELECT * FROM sys.sysindexes WHERE id = '1554104577'

DBCC PAGE ('AdventureWorks2014',1,5230,2)


SELECT TOP 100 * FROM AdventureWorks2014.Sales.SalesOrderDetail WHERE ProductID = 707

SELECT ProductID, SUM(ProductID) FROM AdventureWorks2014.Sales.SalesOrderDetail 
GROUP BY ProductID

ALTER DATABASE AdventureWorks2014 SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DBCC WRITEPAGE('AdventureWorks2014', 1, 5227, 0, 1, 0x00, 1)


USE [master]
GO
ALTER DATABASE [AdventureWorks2014] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
EXEC master.dbo.sp_detach_db @dbname = N'AdventureWorks2014'
GO
CREATE DATABASE [AdventureWorks2014] ON 
( FILENAME = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Data.mdf' ),
( FILENAME = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Log.ldf' )
 FOR ATTACH
GO

DBCC CHECKDB (AdventureWorks2014)



BACKUP DATABASE [AdventureWorks2014_Demo02] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02_01.bak' WITH FORMAT, INIT,  NAME = N'AdventureWorks2014_Demo02-Full Database Backup', COMPRESSION,  STATS = 10
GO

BACKUP LOG [AdventureWorks2014_Demo02] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02-TLog_01.bak' WITH INIT

BACKUP DATABASE [AdventureWorks2014_Demo02] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02_02.bak' WITH FORMAT, INIT,  NAME = N'AdventureWorks2014_Demo02-Full Database Backup', COMPRESSION,  STATS = 10, CONTINUE_AFTER_ERROR
GO

BACKUP LOG [AdventureWorks2014_Demo02] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02-TLog_01.bak' WITH INIT
GO

USE [AdventureWorks2014_Demo02]
GO
ALTER INDEX [PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID] ON [Sales].[SalesOrderDetail] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


BACKUP LOG [AdventureWorks2014_Demo02] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo02-TLog_02.bak' WITH NOFORMAT, NOINIT,  NAME = N'AdventureWorks2014_Demo02-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CONTINUE_AFTER_ERROR
GO

RESTORE DATABASE [AdventureWorks2014-Demo03] 
FILE = N'AdventureWorks2014_Defualt'  
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014-FullRecovery.bak' 
WITH  FILE = 1,  NOUNLOAD,  STATS = 10
GO
