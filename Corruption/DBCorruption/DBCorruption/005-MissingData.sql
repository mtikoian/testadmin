USE [master]
RESTORE DATABASE [AdventureWorks2014_Demo05] FROM  
DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014.bak' 
WITH  FILE = 1,  
MOVE N'AdventureWorks2014_Data' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo05_Data.mdf',  
MOVE N'AdventureWorks2014_Log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo05_Log.ldf',  NOUNLOAD,  STATS = 5
GO







USE [master]
GO
ALTER DATABASE [AdventureWorks2014_Demo05] SET RECOVERY FULL WITH NO_WAIT
GO







BACKUP DATABASE [AdventureWorks2014_Demo05] TO  
DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05.bak' 
WITH FORMAT, INIT,  NAME = N'AdventureWorks2014-Full Database Backup', COMPRESSION,  STATS = 10
GO







BACKUP LOG [AdventureWorks2014_Demo05] TO  
DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05-TLog.bak' 
WITH FORMAT, INIT,  NAME = N'AdventureWorks2014-TLog Database Backup', COMPRESSION,  STATS = 10
GO







SELECT * FROM [AdventureWorks2014_Demo05].[Sales].[SpecialOffer]







UPDATE [AdventureWorks2014_Demo05].[Sales].[SpecialOffer]
SET EndDate = '2016-01-01 00:00:00.000'  







SELECT * FROM [AdventureWorks2014_Demo05].[Sales].[SpecialOffer]







-- Simulate crash of disk by removing by stopping instance and removing data file







DROP DATABASE [AdventureWorks2014_Demo05]
GO






-- Create empty database with the same name
CREATE DATABASE [AdventureWorks2014_Demo05]
 ON  PRIMARY 
( NAME = N'AdventureWorks2014_Data', FILENAME = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo05_Data.mdf' , SIZE = 4096KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'AdventureWorks2014_Log', FILENAME = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo05_Log.ldf' , SIZE = 1024KB , FILEGROWTH = 10%)
GO







ALTER DATABASE [AdventureWorks2014_Demo05] SET OFFLINE







-- Replace TLog files








ALTER DATABASE [AdventureWorks2014_Demo05] SET ONLINE







BACKUP LOG [AdventureWorks2014_Demo05] TO  
DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05-TLog-Tail.bak' 
WITH FORMAT, INIT, 
NO_TRUNCATE,   --	<------
NAME = N'AdventureWorks2014-TLog Database Backup', COMPRESSION,  STATS = 10
GO







-- Try to resore database and TLog
USE [master]
RESTORE DATABASE [AdventureWorks2014_Demo05_Temp] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05.bak' WITH  FILE = 1,  MOVE N'AdventureWorks2014_Data' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo05_Temp_Data.mdf',  MOVE N'AdventureWorks2014_Log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo05_Temp_Log.ldf',  NORECOVERY,  NOUNLOAD,  STATS = 5

RESTORE LOG [AdventureWorks2014_Demo05_Temp] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05-TLog.bak' WITH  FILE = 1,  RECOVERY,  NOUNLOAD,  STATS = 5
GO







SELECT * FROM [AdventureWorks2014_Demo05_Temp].[Sales].[SpecialOffer]







DROP DATABASE [AdventureWorks2014_Demo05_Temp]
GO






-- Now with Tail log
USE [master]
RESTORE DATABASE [AdventureWorks2014_Demo05_Temp] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05.bak' WITH  FILE = 1,  MOVE N'AdventureWorks2014_Data' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo05_Temp_Data.mdf',  MOVE N'AdventureWorks2014_Log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo05_Temp_Log.ldf',  NORECOVERY,  NOUNLOAD,  STATS = 5

RESTORE LOG [AdventureWorks2014_Demo05_Temp] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05-TLog.bak' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5

RESTORE LOG [AdventureWorks2014_Demo05_Temp] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo05-TLog-Tail.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO







SELECT * FROM [AdventureWorks2014_Demo05_Temp].[Sales].[SpecialOffer]







--Cleanup
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014_Demo05'
GO
USE [master]
GO
DROP DATABASE [AdventureWorks2014_Demo05]
GO
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014_Demo05_Temp'
GO
USE [master]
GO
DROP DATABASE [AdventureWorks2014_Demo05_Temp]
GO
