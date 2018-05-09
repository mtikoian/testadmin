-- Setup Database Mirroring using T-SQL


-- LABDB01 is Principal instance
-- LABDB04 is Mirror instance
-- LABDB03 is Witness instance


-- ********* Turn on SQLCMD Mode ************************************************

:CONNECT LABDB01
-- Check version, edition, and build number on Principal instance
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

-- See what global trace flags we have in effect on Principal instance
DBCC TRACESTATUS (-1);


:CONNECT LABDB04
-- Check version, edition, and build number on Mirror instance
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

-- See what global trace flags we have in effect on Mirror instance
DBCC TRACESTATUS (-1);



:CONNECT LABDB03
-- Check version, edition, and build number on Witness instance
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

-- TF 1118 helps reduce allocation contention in tempdb
-- TF 2371 reduces the threshold for automatic statistics updates on larger tables 
-- TF 3226 suppresses successful backup messages from going into the SQL Server error log
-- TF 3499 reduces the I/O requirements on the mirror instance (at the cost of a potentially longer failover time)


:CONNECT LABDB01
-- Are the databases in FULL recovery model?
SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = N'AdventureWorks';
GO

:CONNECT LABDB01
-- If not, set them to FULL recovery
ALTER DATABASE AdventureWorks SET RECOVERY FULL;
GO


-- Start to "initialize the mirror" for both databases ******************************************

:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name];
-- Full compressed backup to file share on mirror instance
-- (Using backup compression is very helpful here)
BACKUP DATABASE AdventureWorks 
TO  DISK = N'\\LABDB04\SQLBackups\AdventureWorksFullCompressed.bak' 
WITH  DESCRIPTION = N'Full Backup to initialize mirror', 
NOFORMAT, INIT,  NAME = N'AdventureWorks-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1, CHECKSUM;
GO


-- Transaction log backup to file share on mirror instance
-- (since SQL Server 2008, you must run at least one log backup/restore)
:CONNECT LABDB01
BACKUP LOG AdventureWorks 
TO  DISK = N'\\LABDB04\SQLBackups\AdventureWorks1.trn' 
WITH  DESCRIPTION = N'Log Backup to initialize mirror', NOFORMAT, INIT,  
NAME = N'AdventureWorks-Transaction Log  Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1, CHECKSUM;
GO





-- Mirror Partner
:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name];

-- On "Mirror Instance"
-- Restore Full backup and all log backups with NORECOVERY

-- Restore full backup of AdventureWorks database with no recovery
:CONNECT LABDB04
RESTORE DATABASE [AdventureWorks] 
FROM  DISK = N'\\LABDB04\SQLBackups\AdventureWorksFullCompressed.bak' 
WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 1;
GO
 
-- Transaction log restore with no recovery
:CONNECT LABDB04
RESTORE LOG  AdventureWorks
FROM DISK = '\\LABDB04\SQLBackups\AdventureWorks1.trn'
WITH NORECOVERY;



-- Principal Endpoint
:CONNECT LABDB01

IF NOT EXISTS (SELECT name FROM sys.database_mirroring_endpoints WHERE name = N'Mirroring')
	BEGIN
		-- Creating an Endpoint always takes a few seconds...
		CREATE ENDPOINT [Mirroring] 
		AS TCP (LISTENER_PORT = 5022)
		FOR DATA_MIRRORING (ROLE = PARTNER, 
		ENCRYPTION = REQUIRED ALGORITHM AES); 
		-- DEFAULT encryption algorithm pre-2012 was RC4!
		-- AES is a stronger encryption than RC4

		ALTER ENDPOINT [Mirroring] STATE = STARTED;
	END

-- Check the endpoint
SELECT @@SERVERNAME AS [Server Name], name, state_desc, role_desc
FROM sys.database_mirroring_endpoints;
GO

USE master;  
GO
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'BASELAB\SQLServerService')
	CREATE LOGIN [BASELAB\SQLServerService] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO  
GRANT CONNECT ON ENDPOINT::Mirroring TO [baselab\SQLServerService];  
GO  

-- Create Mirror Endpoint
:CONNECT LABDB04

IF NOT EXISTS (SELECT name FROM sys.database_mirroring_endpoints WHERE name = N'Mirroring')
	BEGIN
		-- Creating an Endpoint always takes a few seconds...
		CREATE ENDPOINT [Mirroring] 
		AS TCP (LISTENER_PORT = 5022)
			FOR DATA_MIRRORING (ROLE = PARTNER, 
			ENCRYPTION = REQUIRED ALGORITHM AES);
			-- DEFAULT encryption algorithm pre-2012 was RC4!
			-- AES is a stronger encryption than RC4

		ALTER ENDPOINT [Mirroring] STATE = STARTED;
	END

-- Check the endpoint
SELECT @@SERVERNAME AS [Server Name], name, state_desc, role_desc
FROM sys.database_mirroring_endpoints;
GO

USE master;  
GO
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'BASELAB\SQLServerService')
	CREATE LOGIN [BASELAB\SQLServerService] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO  
GRANT CONNECT ON ENDPOINT::Mirroring TO [baselab\SQLServerService];  
GO  

-- Create Witness Endpoint
:CONNECT LABDB03

IF NOT EXISTS (SELECT name FROM sys.database_mirroring_endpoints WHERE name = N'Mirroring')
	BEGIN
		CREATE ENDPOINT [Mirroring] 
		AS TCP (LISTENER_PORT = 5022)
			FOR DATA_MIRRORING
		(ROLE = WITNESS, 
		ENCRYPTION = REQUIRED ALGORITHM AES);

		ALTER ENDPOINT [Mirroring] STATE = STARTED;
	END

-- Check the endpoint
SELECT @@SERVERNAME AS [Server Name], name, state_desc, role_desc
FROM sys.database_mirroring_endpoints;
GO

USE master;  
GO
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'BASELAB\SQLServerService')
	CREATE LOGIN [BASELAB\SQLServerService] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO  
GRANT CONNECT ON ENDPOINT::Mirroring TO [baselab\SQLServerService];  
GO  

-- Enable mirroring from MIRROR (do this first)
:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name];

ALTER DATABASE [AdventureWorks] 
SET PARTNER = N'TCP://LABDB01.baselab.com:5022';
GO




-- Enable next from Principal
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name];

ALTER DATABASE [AdventureWorks] 
SET PARTNER = N'TCP://labdb04.baselab.com:5022';
GO



-- Add witness (from the Principal)
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name];

ALTER DATABASE [AdventureWorks] 
SET WITNESS = N'TCP://LABDB03.baselab.com:5022';
GO



-- Add the "Database Mirroring Monitor Job" Agent Job to the Principal instance
-- The SSMS GUI does this automatically when you use the Wizard to create a mirror
:CONNECT LABDB01
EXEC sp_dbmmonitoraddmonitoring;

-- Add the "Database Mirroring Monitor Job" Agent Job to the Mirror instance
:CONNECT LABDB04
EXEC sp_dbmmonitoraddmonitoring;


:CONNECT LABDB01
-- Let's look at the status of the mirroring partnership
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;

-- Same query with columns documented
SELECT 
	-- Suspended / Disconnected / Synchronizing
	-- Pending Failover / Synchronized /
	-- Unsynchronized / NULL
	mirroring_state_desc, 
	-- Principal or Mirror
	mirroring_role_desc,
	-- Off (Async) / Full (Sync)
	mirroring_safety_level_desc,
	mirroring_partner_name, 
	mirroring_witness_name,
	-- Connected / Disconnected
	mirroring_witness_state_desc,
	-- LSN of latest transaction log record 
	-- guaranteed to be hardened on disk on both
	-- partners (used after failover as point of
	-- reconciliation)
	mirroring_failover_lsn, 
	-- Seconds to wait for a reply from partner
	-- or witness before deeming "unavailable"
	mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;
GO




-- Get information about TCP Listener for SQL Server  
SELECT listener_id, ip_address, is_ipv4, port, type_desc, state_desc, start_time
FROM sys.dm_tcp_listener_states;

-- Should show DATABASE_MIRRORING port, if a mirroring endpoint exists

-- What about external objects (logins/linked-servers/packages)?  
-- We'll cover in a separate set of scripts.

-- ***
-- What if it didn't work?

-- 1) Check that the SQL Server Agent accounts have correct endpoint permissions (check SQL error log for signs)

:CONNECT LABDB01
SELECT  @@SERVERNAME AS [Server Name], e.endpoint_id, p.permission_name,
		suser_name(p.grantee_principal_id) AS [User Name],
		e.name, p.state_desc
FROM sys.server_permissions AS p
INNER JOIN sys.endpoints AS e 
ON p.major_id = e.endpoint_id
WHERE protocol_desc = N'TCP';
GO

:CONNECT LABDB04
SELECT  @@SERVERNAME AS [Server Name], e.endpoint_id, p.permission_name,
		suser_name(p.grantee_principal_id) AS [User Name],
		e.name, p.state_desc
FROM sys.server_permissions AS p
INNER JOIN sys.endpoints AS e 
ON p.major_id = e.endpoint_id
WHERE protocol_desc = N'TCP';
GO

:CONNECT LABDB03
SELECT  @@SERVERNAME AS [Server Name], e.endpoint_id, p.permission_name,
		suser_name(p.grantee_principal_id) AS [User Name],
		e.name, p.state_desc
FROM sys.server_permissions AS p
INNER JOIN sys.endpoints AS e 
ON p.major_id = e.endpoint_id
WHERE protocol_desc = N'TCP';
GO

-- 2) For cross domains or non-domain accounts, do the logins exist on the other partner 
--    and do they have CONNECT permission? 

-- 3) For certificate based DBM, check the deployment steps per "Using Certificates for Database Mirroring"
-- http://technet.microsoft.com/en-us/library/ms191477.aspx

-- 4) Are the endpoints started on the partners?

:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], name, state_desc
FROM sys.database_mirroring_endpoints;
GO
:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name], name, state_desc
FROM sys.database_mirroring_endpoints;
GO
:CONNECT LABDB03
SELECT @@SERVERNAME AS [Server Name], name, state_desc
FROM sys.database_mirroring_endpoints;
GO

-- 5) What ports are being used?  Are they open on the firewall?

:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], port
FROM sys.tcp_endpoints
WHERE name = N'Mirroring';
GO
:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name], port
FROM sys.tcp_endpoints
WHERE name = N'Mirroring';
GO
:CONNECT LABDB03
SELECT @@SERVERNAME AS [Server Name], port
FROM sys.tcp_endpoints
WHERE name = N'Mirroring';
GO

-- 6) Is anyone else using the port? Are firewall ports unblocked?
-- Check netstat -abn

-- 7) Are the roles configured correctly per instance?
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], role_desc
FROM sys.database_mirroring_endpoints;
GO
:CONNECT LABDB04
SELECT @@SERVERNAME AS [Server Name], role_desc
FROM sys.database_mirroring_endpoints;
GO
:CONNECT LABDB03
SELECT @@SERVERNAME AS [Server Name], role_desc
FROM sys.database_mirroring_endpoints;
GO

-- 8) Have you tried the fully qualified domain name? 
--    Does it unambiguously identify the instance and port? 
--    TCP :// < system-address> : < port> 

-- 9) Were all log backups created after the last full backup applied with NO RECOVERY?

-- 10) Is the file layout path the same?  
--     If different, did you use the MOVE option?

-- 11) Was the first ALTER DATABASE SET PARTNER run on the mirror? (it must be)  
--     And was the second ALTER DATABASE on the principal server?

-- Other errors?
-- 1412 or 1478 - you didn't apply tran log or additional tran log backup was taken
-- 1416 - mirror not in NORECOVERY
-- 1418 - The server network address "%.*ls" can not be reached or does not exist. Check the network address name and that the ports for the local and remote endpoints are operational.
-- http://www.sqlsoldier.com/wp/sqlserver/troubleshooting-atabasemirroringerror1418 (Robert Davis)
-- 1456 - The ALTER DATABASE command could not be sent to the remote server instance '%.*ls'. The database mirroring configuration was not changed. Verify that the server is connected, and try again.

-- Some database mirroring resources

-- SQL Server Database Mirroring (Not Dead Yet)
-- http://sqlserverperformance.wordpress.com/2012/03/07/sql-server-database-mirroring-not-dead-yet/

-- SQL Server Database Mirroring Tips and Tricks, Part 1
-- http://sqlserverperformance.wordpress.com/2012/03/12/sql-server-database-mirroring-tips-and-tricks-part-1/

-- SQL Server Database Mirroring Tips and Tricks, Part 2
-- http://sqlserverperformance.wordpress.com/2012/03/21/sql-server-database-mirroring-tips-and-tricks-part-2/

-- SQL Server Database Mirroring Tips and Tricks, Part 3
-- http://sqlserverperformance.wordpress.com/2012/03/27/sql-server-database-mirroring-tips-and-tricks-part-3/

-- How to Perform a Rolling Edition Upgrade While Using Database Mirroring
-- http://www.sqlskills.com/blogs/glenn/how-to-perform-a-rolling-edition-upgrade-while-using-database-mirroring/

-- Using SQL Agent Job Categories to Automate SQL Agent Job Enabling with Database Mirroring
-- http://blogs.msdn.com/b/sqlcat/archive/2010/04/01/using-sql-agent-job-categories-to-automate-sql-agent-job-enabling-with-database-mirroring.aspx

-- Troubleshooting Database Mirroring Error 1418
-- http://www.sqlsoldier.com/wp/sqlserver/troubleshooting-atabasemirroringerror1418



-- FIX: SQL Server service performs more I/O operations on the mirror server than on the principal server 
-- https://support.microsoft.com/en-us/kb/3103472








