-- Post Migration Tasks
-- Glenn Berry
-- SQLskills.com

-- Confirm server name
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server Version Information];

-- Switch to 130 compatibility level
USE [master]
GO
ALTER DATABASE AdventureWorksLT2008R2 SET COMPATIBILITY_LEVEL = 130;
GO

-- Enable Query Store for this database
ALTER DATABASE AdventureWorksLT2008R2 SET QUERY_STORE = ON;
GO
ALTER DATABASE AdventureWorksLT2008R2 SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
GO

-- Change a database scoped configuration property (if necessary)
USE AdventureWorksLT2008R2
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
GO


-- Run sp_updatestats
-- You may want to do a more complete job later
EXEC sp_updatestats;


-- Take a full database backup
BACKUP DATABASE AdventureWorksLT2008R2 
TO  DISK = N'M:\SQLBackups\AdventureWorksLT2008R2FullCompressed.bak' WITH NOFORMAT, INIT,  
NAME = N'AdventureWorksLT2008R2-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1, CHECKSUM;
GO

-- Check the AdventureWorks database with MAXDOP = 4    
DBCC CHECKDB (AdventureWorksLT2008R2) WITH MAXDOP = 4;    
GO   


