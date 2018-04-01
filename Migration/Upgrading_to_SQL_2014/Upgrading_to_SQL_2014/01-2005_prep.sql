-- Turn on ZoomIt!
-----------------------------------------------------
-- Show SQL 2000 on other VM                       --
-----------------------------------------------------
-- Connect to SQL2K5\MSSQL2005INST01
-----------------------------------------------------
-- New instance preparation                        --
-----------------------------------------------------
-- Enable trace flags:
-- 1117
-- 1118 
-- 1204 
-- 1222
-- 3023
-- 3226
-- 4199
-- 1117: Grows all data files at once, else it goes in turns.
-- 1118: Switches allocations in tempDB from 1pg (8kb) at a time (for first 8 pages) to one extent (64k). 
-- 1204: Returns resources and types of locks participating in a deadlock and command affected. Scope: global
-- 1222: Returns the resources & types of locks that are participating in a deadlock and also the current command affected, in an XML format that does not comply with any XSD schema. Scope: global
-- 3023:  the CHECKSUM option is automatically enabled for the BACKUP command
-- 3226: By default, every successful backup operation adds an entry in the SQL Server error log and in the system event log. If you create very frequent log backups, these success messages accumulate quickly, resulting in huge error logs in which finding other messages is problematic. With this trace flag, you can suppress these log entries. This is useful if you are running frequent log backups and if none of your scripts depend on those entries.
-- 4199: This one trace flag can be used to enable all the fixes that were previously made for the query processor under many trace flags. In addition, all future query processor fixes will be controlled by using this trace flag. Scope: global / session.
/*	
KB article	Flag	KB article	Flag	KB article	Flag	KB article	Flag
318530		4101	926024		4108	942659		4119	953569		4127
940128		4102	926773		4109	953948		4120	955694		4128
919905		4103	933724		4110	942444		4121	957872	
920346		4104	934065		4111	946020		4122	958547		4129
920347		4105	946793		4115	948248		4124	956686		4131
922438		4106	950880		4116	949854		4125	958006		4133
923849		4107	948445		4117	959013		4126	960770		4135*
2276330				2698639				2649913				2260502	 
*/
-- 9481: Use when running SQL Server 2014 with the default database compatibility level 120. Trace flag 9481 forces the query optimizer to use version 70 (the SQL Server 2012 version) of the cardinality estimator when creating the query plan.
-- List of important trace flags:
-- - http://www.sqlservercentral.com/articles/trace+flags/70131/
-- - https://victorisakov.wordpress.com/category/trace-flag/ - presentation of Victor Isakov (MCA, MCM, MCT, MVP) from PASS Summit 2011 about trace flags: "Important Trace Flags that Every DBA Should Know"
-- Check which trace flags are turned on:
DBCC TRACESTATUS (- 1);
GO

-- sp_whoisactive scripts - 01a-sp_whoisactive.sql
-- Add alerts - 02b-alerts.sql
-- Apply Ola's Hallengren maintenance scripts - 02c-maintenance_jobs.sql
-- Configure SQL Server instance:
--
-- - cost threshold for parallelism
-- - max degree of parallelism
-- - max server memory (MB)
-- - min server memory (MB)
-- - optimize for ad hoc workloads (*)
-- - remote admin connections
-- 
EXEC dbo.sp_configure 'show advanced options'
	,1
GO

RECONFIGURE
GO

EXEC dbo.sp_configure
GO

EXEC dbo.sp_configure 'cost threshold for parallelism'
	,25
GO

EXEC dbo.sp_configure 'max degree of parallelism'
	,2
GO

EXEC dbo.sp_configure 'max server memory (MB)'
	,2048
GO

EXEC dbo.sp_configure 'min server memory (MB)'
	,1024
GO

EXEC dbo.sp_configure 'remote admin connections'
	,1
GO

RECONFIGURE
GO

-- SQL Server login sync 02d-login_sync.sql
