-----------------------------------------------------
-- Clean-up scripts                                --
-- Note: Enable SQLCMD mode                        --
-----------------------------------------------------




-- connect to SQL2k5\MSSQL2005INST01
USE [msdb]
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'DatabaseBackup - SYSTEM_DATABASES - FULL',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'DatabaseBackup - USER_DATABASES - FULL',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'DatabaseBackup - USER_DATABASES - DIFF',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'DatabaseBackup - USER_DATABASES - LOG',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'DatabaseIntegrityCheck - SYSTEM_DATABASES',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'DatabaseIntegrityCheck - USER_DATABASES',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'IndexOptimize - USER_DATABASES',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'CommandLog Cleanup',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'Output File Cleanup',
	@delete_unused_schedule=1;
GO
EXEC msdb.dbo.sp_delete_job 
	@job_name=N'Database Mirroring Monitor Job',
	@delete_unused_schedule=1;
GO
EXECUTE msdb.dbo.sysmail_delete_profile_sp 
@profile_name = 'SQL_Email_Profile' 
EXECUTE msdb.dbo.sysmail_delete_account_sp 
@account_name = 'SQL Server Notification Service'
EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp 
@profile_name = 'SQL_Email_Profile'
EXECUTE msdb.dbo.sysmail_delete_principalprofile_sp 
@profile_name = 'SQL_Email_Profile'

EXEC msdb.dbo.sp_delete_operator @name=N'DBA'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'017 - Insufficient Resources'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'018 - Nonfatal Internal Error Detected'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'019 - Fatal Error in Resources'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'020 - Fatal Error in Current Process'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'021 - Fatal Error in Database Processes'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'022 - Fatal Error: Table Integrity Suspect'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'023 - Fatal Error: Database Integrity Suspect'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'024 - Fatal Error: Hardware Error'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'025 - Fatal Error'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'823 - IO operation failed at OS level'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'824 - IO operation failed at hardware level'
GO
EXEC msdb.dbo.sp_delete_alert @name=N'825 - Read retry error'
GO



-- connect SQL2k5\MSSQL2005INST01
DROP DATABASE [Northwind]
GO

USE [master]
GO
RESTORE 
	DATABASE [AdventureWorks] 
FROM  
	DISK = N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\Backup\AdventureWorks.bak' WITH  FILE = 1,  
	MOVE N'AdventureWorks_Data' TO N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\DATA\AdventureWorks_Data.mdf',  
	MOVE N'AdventureWorks_Log' TO N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\DATA\AdventureWorks_Log.ldf',  
NORECOVERY,  NOUNLOAD,  STATS = 5
GO
RESTORE 
	LOG [AdventureWorks] 
FROM  
	DISK = N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\Backup\AdventureWorks-Log.bak' WITH
	FILE = 1,  NOUNLOAD,  STATS = 10
GO




-- connect SQL2014\MSSQL2014INST01
DROP DATABASE [AdventureWorks]
GO
DROP DATABASE [Northwind]
GO
