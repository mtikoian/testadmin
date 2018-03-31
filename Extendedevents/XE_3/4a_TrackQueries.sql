/*============================================================================
  File:     5a_TrackQueries.sql

  SQL Server Versions: 2008 onwards
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

IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'TrackQueries')
	DROP EVENT SESSION [TrackQueries]
	ON SERVER;
GO

/*
	create session that tracks sp_ and sql_ statement_completed
*/
CREATE EVENT SESSION [TrackQueries]
	ON SERVER 
ADD EVENT sqlserver.sql_statement_completed (
    ACTION (
		sqlserver.client_app_name,sqlserver.database_id
		)
    WHERE (
		[sqlserver].[is_system]=(0))
		),
ADD EVENT sqlserver.sp_statement_completed (
    ACTION (
		sqlserver.database_id,sqlserver.client_app_name)
    WHERE (
		[sqlserver].[is_system]=(0))
		) 
ADD TARGET package0.event_file (
	SET filename=N'C:\Temp\TrackQueries.xel')
WITH (MAX_MEMORY=1024 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,
MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO



/*
	start 
*/
ALTER EVENT SESSION [TrackQueries]
	ON SERVER
	STATE=START;
	GO


/*
	run .ps1 scripts
*/

ALTER EVENT SESSION [TrackQueries]
	ON SERVER
	DROP EVENT sp_statement_completed,
	DROP EVENT sql_statement_completed;
	GO


ALTER EVENT SESSION [TrackQueries]
	ON SERVER 
ADD EVENT sqlserver.sql_statement_completed (
    ACTION (
		sqlserver.client_app_name,sqlserver.database_id,sqlserver.query_hash,sqlserver.query_plan_hash
		)
    WHERE (
		[sqlserver].[is_system]=(0))
		),
ADD EVENT sqlserver.sp_statement_completed (
    ACTION (
		sqlserver.database_id,sqlserver.client_app_name,sqlserver.query_hash,sqlserver.query_plan_hash
		)
    WHERE (
		[sqlserver].[is_system]=(0))
		) 
/*
	stop when done
*/

ALTER EVENT SESSION [TrackQueries]
	ON SERVER
	STATE=STOP;
	GO

/*
	clean up
*/
DROP EVENT SESSION [TrackQueries] ON SERVER
