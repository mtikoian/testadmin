USE [master]
RESTORE DATABASE [AdventureWorks2014_Demo04] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014.bak' WITH  FILE = 1,  MOVE N'AdventureWorks2014_Data' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo04_Data.mdf',  MOVE N'AdventureWorks2014_Log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo04_Log.ldf',  NOUNLOAD,  STATS = 5
GO


BACKUP DATABASE [AdventureWorks2014] TO  
DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014-FullRecovery.bak' 
WITH FORMAT, INIT,  NAME = N'AdventureWorks2014-Full Database Backup', COMPRESSION,  STATS = 10
GO


BACKUP LOG [AdventureWorks2014] TO  
DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014-TLog.bak' 
WITH FORMAT, INIT,  NAME = N'AdventureWorks2014-TLog Database Backup', COMPRESSION,  STATS = 10
GO



--Cleanup
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014'
GO
USE [master]
GO
ALTER DATABASE [AdventureWorks2014] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [AdventureWorks2014]
GO