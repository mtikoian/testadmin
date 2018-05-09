-- Migrating with Database Mirroring

-- Turn on SQLCMD Mode


-- 1) Connect to all both servers in Object Explorer
-- 2) Validate which server we're on (connect to LABDB06)

-- SQL and OS Version information for principal instance
:CONNECT LABDB06  
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];


-- SQL and OS Version information for mirror instance
:CONNECT LABDB01  
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];


-- Check the current mirroring status
:CONNECT LABDB06
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

-- Switch to asynchronous mirroring (if you have Enterprise Edition) 
:CONNECT LABDB06
ALTER DATABASE AdventureWorksLT2008R2 SET SAFETY OFF;
GO

-- Check the current mirroring status
:CONNECT LABDB06
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO


:CONNECT LABDB06
-- Change database mirroring to synchronous mode (FULL safety) just before failover
ALTER DATABASE AdventureWorksLT2008R2 SET SAFETY FULL;
GO

-- Check the current mirroring status
:CONNECT LABDB06
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO


:CONNECT LABDB06
-- Initiate a manual failover of the database (must do from Principal side)
USE master;
GO
ALTER DATABASE AdventureWorksLT2008R2 SET PARTNER FAILOVER;



-- Remove mirroring
:CONNECT LABDB01
ALTER DATABASE AdventureWorksLT2008R2 SET PARTNER OFF;