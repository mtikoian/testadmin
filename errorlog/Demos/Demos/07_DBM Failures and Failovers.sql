-- Database Mirroring Failovers

-- Turn on SQLCMD Mode


-- 1) Connect to all three servers in Object Explorer

-- 2) Validate which server we're on (connect to LABDB01)
-- 3) Validate the state of the mirroring partnership and do some manual and automatic failovers

:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

:CONNECT LABDB01
-- Initiate a manual failover of both databases (must do from Principal side)
USE master;
GO
ALTER DATABASE AdventureWorks SET PARTNER FAILOVER;
ALTER DATABASE AdventureWorks2014 SET PARTNER FAILOVER;

-- Refresh Databases and Agent jobs in Object Explorer

:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

:CONNECT LABDB04
-- Initiate a manual failover of both databases
USE master;
GO
ALTER DATABASE AdventureWorks SET PARTNER FAILOVER;
ALTER DATABASE AdventureWorks2014 SET PARTNER FAILOVER;

:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

:CONNECT LABDB01
-- Initiate a manual failover of just the AdventureWorks database
USE master;
GO
ALTER DATABASE AdventureWorks SET PARTNER FAILOVER;

:CONNECT LABDB01
-- See if AdventureWorks2014 also failed over (after a 15 second delay)
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

:CONNECT LABDB01
-- Get SQL Server Agent Alert Information (check occurrence account for alerts)
SELECT @@SERVERNAME AS [Server Name], 
       name, event_source, message_id, severity, 
       [enabled], has_notification, delay_between_responses, 
	   occurrence_count, last_occurrence_date, last_occurrence_time
FROM msdb.dbo.sysalerts 
ORDER BY name;

:CONNECT LABDB01
-- Get Agent jobs and Category information
SELECT @@SERVERNAME AS [Server Name], sj.name AS [JobName], 
sj.[description] AS [JobDescription], [enabled], 
sj.category_id, sc.name AS [CategoryName]
FROM msdb.dbo.sysjobs AS sj
INNER JOIN msdb.dbo.syscategories AS sc
ON sj.category_id = sc.category_id
ORDER BY sc.name, sj.name;


:CONNECT LABDB04
-- Initiate a manual failover of both databases
USE master;
GO
ALTER DATABASE AdventureWorks SET PARTNER FAILOVER;
ALTER DATABASE AdventureWorks2014 SET PARTNER FAILOVER;

:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

-- Shut down the mirror server service
-- Switch connection to LABDB01 first!
:CONNECT LABDB04
SHUTDOWN WITH NOWAIT;
GO

:CONNECT LABDB01
-- Mirroring state will be DISCONNECTED
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

-- Data is still accessible on principal
:CONNECT LABDB01
SELECT ContactID, Title, FirstName, LastName, EMailAddress
FROM AdventureWorks.dbo.NewContact;
GO


-- Bring up the mirror service (go to node)
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

-- Switch connection to LABDB04 first!
-- Bring down the principal server (should cause automatic failover)
:CONNECT LABDB01
SHUTDOWN WITH NOWAIT
GO

:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], 
       mirroring_role_desc, mirroring_state_desc, mirroring_safety_level_desc, 
	   mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

-- Data is accessible on new principal
:CONNECT LABDB04
SELECT ContactID, Title, FirstName, LastName, EMailAddress
FROM AdventureWorks.dbo.NewContact;
GO

:CONNECT LABDB04
-- Get SQL Server Agent Alert Information (check occurrence account for alerts)
SELECT @@SERVERNAME AS [Server Name], 
       name, event_source, message_id, severity, 
       [enabled], has_notification, delay_between_responses, 
	   occurrence_count, last_occurrence_date, last_occurrence_time
FROM msdb.dbo.sysalerts 
ORDER BY name;
