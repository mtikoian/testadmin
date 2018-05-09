-- Preparing the Mirror Database

-- Run on Principal instance

-- ********* Turn on SQLCMD Mode ************************************************

:CONNECT LABDB03
-- Check version, edition, and build number on Principal instance
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

:CONNECT LABDB03
-- Full database backup of Principal database to file share on Mirror Instance
BACKUP DATABASE AdventureWorks 
TO  DISK = N'\\LABDB01\SQLBackups\AdventureWorksFull.bak' 
WITH NOFORMAT, INIT,  NAME = N'AdventureWorks-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1;
GO

:CONNECT LABDB03
-- Transaction log backup of Principal database to file share on Mirror Instance
BACKUP LOG AdventureWorks 
TO  DISK = N'\\LABDB01\SQLBackups\AdventureWorksTrans.trn' 
WITH NOFORMAT, INIT,  NAME = N'AdventureWorks-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1;
GO


-- Run on Mirror instance

:CONNECT LABDB01
-- Check version, edition, and build number on Mirror instance
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

:CONNECT LABDB01
-- Restore full database backup with NORECOVERY
USE [master]
RESTORE DATABASE AdventureWorks 
FROM  DISK = N'M:\SQLBackups\AdventureWorksFull.bak' WITH  FILE = 1,  
NORECOVERY,  NOUNLOAD,  REPLACE,  STATS = 1;
GO

:CONNECT LABDB01
-- Restore transaction log backup with NORECOVERY
RESTORE LOG AdventureWorks 
FROM  DISK = N'M:\SQLBackups\AdventureWorksTrans.trn' WITH  FILE = 1,  
NORECOVERY,  NOUNLOAD,  STATS = 1;
GO




