/*============================================================================
  File:     3b_Research_SP.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2015, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


USE [AdventureWorks2014];
GO

SELECT *
FROM [sys].[all_objects]
WHERE [object_id] IN (679673469);

/*
	use object_name
	track_causality = ON
*/
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'Research_SP')
	DROP EVENT SESSION [Research_SP] ON SERVER;
GO

CREATE EVENT SESSION [Research_SP] 
	ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(
		sqlserver.client_app_name,sqlserver.database_id)
    WHERE (
		[object_name]=N'usp_GetProductInfo')
	),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(
		sqlserver.client_app_name,sqlserver.database_id)
    WHERE (
		[object_id] = (679673469)
	)
) 
ADD TARGET package0.event_file(
	SET filename=N'C:\Temp\Research_SP.xel',max_file_size=(1024),max_rollover_files=(5))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

/*
	start session
*/
ALTER EVENT SESSION [Research_SP]
	ON SERVER
	STATE=START;
	GO

/*
	run .ps1 scripts
*/

/*
	stop session
*/
ALTER EVENT SESSION [Research_SP]
	ON SERVER
	STATE=STOP;
	GO

/*
	clean up
*/
DROP EVENT SESSION [Research_SP]
	ON SERVER;
	GO