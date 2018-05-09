-- Moving Data with Database Mirroring

-- Turn on SQLCMD Mode


-- 1) Connect to both servers in Object Explorer
-- 2) Validate which server we're on (connect to LABDB01)

-- SQL and OS Version information for principal instance
:CONNECT LABDB01  
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];


-- SQL and OS Version information for mirror instance
:CONNECT LABDB04  
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];


-- Check the current mirroring status
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_failover_lsn
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

-- Switch to asynchronous mirroring (if you have Enterprise Edition) 
:CONNECT LABDB01
ALTER DATABASE AdventureWorks SET SAFETY OFF;
ALTER DATABASE AdventureWorks2014 SET SAFETY OFF;
GO

:CONNECT LABDB01
-- Change database mirroring to synchronous mode (FULL safety) just before failover
ALTER DATABASE AdventureWorks SET SAFETY FULL;
ALTER DATABASE AdventureWorks2014 SET SAFETY FULL;
GO

-- Check the current mirroring status
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_failover_lsn
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO


:CONNECT LABDB01
-- Initiate a manual failover of the databases (must do from Principal side)
USE master;
GO
ALTER DATABASE AdventureWorks SET PARTNER FAILOVER;
ALTER DATABASE AdventureWorks2014 SET PARTNER FAILOVER;



-- Remove mirroring if desired
:CONNECT LABDB04
ALTER DATABASE AdventureWorks SET PARTNER OFF;
ALTER DATABASE AdventureWorks2014 SET PARTNER OFF;