-- Looking for data in TLog
RESTORE DATABASE [AdventureWorks2014_Demo07] 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014-FullRecovery.bak' 
WITH  FILE = 1,  
MOVE N'AdventureWorks2014_Default' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07_PRIMARY.mdf',  
MOVE N'AdventureWorks2014_Data' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07_Data.ndf',  
MOVE N'AdventureWorks2014_Index' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07_Index.ndf',  
MOVE N'AdventureWorks2014_RO' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07_RO.ndf',  
MOVE N'AdventureWorks2014_TLog' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo07_TLog.ldf',  NOUNLOAD,  STATS = 5
GO

BACKUP DATABASE [AdventureWorks2014_Demo07] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo07_01.bak' WITH FORMAT, INIT,  NAME = N'AdventureWorks2014_Demo07-Full Database Backup', COMPRESSION,  STATS = 10
GO

BACKUP LOG [AdventureWorks2014_Demo07] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo07-TLog_01.bak' WITH INIT









-- Delete few rows
DELETE FROM 
	[AdventureWorks2014_Demo07].[Sales].[SalesOrderDetail]
WHERE 
	SalesOrderDetailID = '43659'






BACKUP LOG [AdventureWorks2014_Demo07] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo07-TLog_Tail.bak' WITH NO_TRUNCATE, COMPRESSION, INIT, FORMAT




USE [AdventureWorks2014_Demo07]
GO
SELECT *
FROM fn_dblog(null, null)




SELECT *
FROM fn_dblog(null, null)
WHERE Operation='LOP_DELETE_ROWS'


SELECT [Transaction ID], COUNT(*) 
FROM fn_dblog(null, null)
WHERE Operation='LOP_DELETE_ROWS'
GROUP BY [Transaction ID]
ORDER BY 2 DESC

-- 0000:0000174e







SELECT MAX([Current LSN])
FROM fn_dblog(null, null)
WHERE [Transaction ID]='0000:0000174e'


-- 0000005a:00001c22:007e
/*
0000005a -> 90
00001c22 -> 7202
007e -> 126

< 5 > <   10   > < 5 >
00090 0000007202 00126
*/

RESTORE DATABASE [AdventureWorks2014_Demo07a] 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo07_01.bak' 
WITH  NORECOVERY, FILE = 1,  
MOVE N'AdventureWorks2014_Default' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07a_PRIMARY.mdf',  
MOVE N'AdventureWorks2014_Data' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07a_Data.ndf', 
MOVE N'AdventureWorks2014_Index' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07a_Index.ndf',
MOVE N'AdventureWorks2014_RO' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo07a_RO.ndf',  
MOVE N'AdventureWorks2014_TLog' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo07a_TLog.ldf',  NOUNLOAD,  STATS = 5
GO

RESTORE LOG [AdventureWorks2014_Demo07a] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo07-TLog_01.bak' WITH NORECOVERY







RESTORE LOG [AdventureWorks2014_Demo07a] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo07-TLog_Tail.bak' WITH NORECOVERY, STATS =10,
STOPBEFOREMARK = 'LSN:00090000000720200126'








RESTORE LOG [AdventureWorks2014_Demo07a] WITH RECOVERY




SELECT * FROM [AdventureWorks2014_Demo07a].[Sales].[SalesOrderDetail]






--Cleanup
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014_Demo07'
GO
USE [master]
GO
ALTER DATABASE [AdventureWorks2014_Demo07] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [AdventureWorks2014_Demo07]
GO
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014_Demo07a'
GO
USE [master]
GO
ALTER DATABASE [AdventureWorks2014_Demo07a] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [AdventureWorks2014_Demo07a]
GO