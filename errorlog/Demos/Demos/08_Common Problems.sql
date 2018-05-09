-- Common Database Mirroring Problems

-- Suspend the mirroring session
:CONNECT LABDB01
ALTER DATABASE AdventureWorks SET PARTNER SUSPEND;

-- Get current mirroring status (should be suspended)
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;

-- Resume the mirroring session
:CONNECT LABDB01
ALTER DATABASE AdventureWorks SET PARTNER RESUME;

-- Get current mirroring status (should not be suspended)
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;



-- Change database mirroring to asynchronous mode (only available in Enterprise Edition)
:CONNECT LABDB01
ALTER DATABASE [AdventureWorks] SET SAFETY OFF;
GO
ALTER DATABASE [AdventureWorks2014] SET SAFETY OFF;
GO

-- Get current mirroring status
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;

-- Change database mirroring to synchronous mode (FULL safety)
:CONNECT LABDB01
ALTER DATABASE [AdventureWorks] SET SAFETY FULL;
GO
ALTER DATABASE [AdventureWorks2014] SET SAFETY FULL;
GO

-- Get current mirroring status
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;


-- Database Mirroring Operating Modes
-- https://msdn.microsoft.com/en-us/library/dd207006.aspx



-- Bring down the witness service
:CONNECT LABDB03
SHUTDOWN WITH NOWAIT;
GO

:CONNECT LABDB01
-- Witness is disconnected
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;

-- Data is accessible on the Principal
:CONNECT LABDB01
SELECT ContactID, Title, FirstName, LastName, EMailAddress
FROM AdventureWorks.dbo.NewContact;
GO

-- Connect to LABDB01 first!
-- Bring down the mirror instance
:CONNECT LABDB04
SHUTDOWN WITH NOWAIT
GO

:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO

-- Will this work?
:CONNECT LABDB01
SELECT ContactID, Title, FirstName, LastName, EMailAddress
FROM AdventureWorks.dbo.NewContact;
GO

-- Msg 955, Level 14, State 1, Line 1
-- Database AdventureWorks is enabled for Database Mirroring, but the database lacks quorum: 
-- the database cannot be opened.  Check the partner and witness connections if configured.

-- Bring up the witness server 
-- ** (go to Node, SSMS may not respond) **
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;

:CONNECT LABDB01
SELECT ContactID, Title, FirstName, LastName, EMailAddress
FROM AdventureWorks.dbo.NewContact;
GO



-- Bring up mirror server (go to node)

-- Switch to mirror connection **
:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name];
GO

:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
