/* DMV to find usage of deprecated features */
USE master;
GO

SELECT * 
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%:Deprecated%'
AND [instance_name] in ('syslogins','sysusers','USER_ID')
AND cntr_value > 0;
GO



/* Let's run some deprecated syntax */


/* dbo.sys* are deprecated compatibility views from 2000 */

SELECT 'Deprecated Syntax - syslogins' AS QueryType, name, [sid], hasaccess, denylogin, dbname AS Default_DB 
	FROM master.dbo.syslogins 
	WHERE name like '%ID%'; 

SELECT 'Current Syntax' AS QueryType, name, [sid], principal_id, is_disabled, default_database_name 
	FROM master.sys.server_principals
	WHERE name like '%ID%'; 

GO

/* USER_ID function should be replaced with DATABASE_PRINCIPAL_ID */

USE AdventureWorks2012;

SELECT USER_ID('WhatIsMyID') AS UserID_IsDeprecated ,
	DATABASE_PRINCIPAL_ID('WhatIsMyID') AS DBPrincipalID_IsCurrent;

SELECT 'Deprecated Syntax - sysusers' AS QueryType, name, [uid], isntuser, issqluser
	FROM dbo.sysusers
	WHERE name = 'WhatIsMyID';

SELECT 'Current Syntax' AS QueryType, name, principal_id, type_desc 
	FROM sys.database_principals
	WHERE name = 'WhatIsMyID';

GO



/* Rerun DMV to find updated usage of deprecated features */
USE master;
GO

SELECT * 
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%:Deprecated%'
AND [instance_name] in ('syslogins','sysusers','USER_ID')
AND cntr_value > 0;
GO
