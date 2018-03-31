/*============================================================================
  File:     4a_The_UI.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2014, SQLskills.com. All rights reserved.

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

/*
	Default templates exist, just as in Profiler
	The Activity Tracking Template recreates what the default trace captures
	Issue with said template in SQL 2012:
	https://www.sqlskills.com/blogs/jonathan/workaround-for-bug-in-activity-tracking-event-session-template-in-2012-rc0/
*/

/*
	Create XE session with:
		sp_statement_completed
		sql_batch_completed
*/

IF EXISTS (
		SELECT 1 FROM sys.server_event_sessions 
		WHERE name = 'UI_Data')
	DROP EVENT SESSION [UI_Data] ON SERVER;
GO

CREATE EVENT SESSION [UI_Data] 
	ON SERVER 
	ADD EVENT sqlserver.sp_statement_completed(
		SET collect_object_name=(1),collect_statement=(1)
    ACTION(
		sqlserver.client_app_name,sqlserver.database_name)
	),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(
		sqlserver.client_app_name,sqlserver.database_name)
	) 
ADD TARGET package0.event_file(
	SET filename=N'C:\temp\FilterQueryText.xel'),
ADD TARGET package0.ring_buffer(SET max_memory=(16384))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


ALTER EVENT SESSION [UI_Data] 
	ON SERVER 
	STATE = START;

/*
	run .ps scripts
	view targets - ring_buffer vs. event_file
	view live data
		note statement versus batch_text columns (merge them together)
		sort
		group
		aggregate
		filter (could remove all non-AW queries)
*/
ALTER EVENT SESSION [UI_Data] 
	ON SERVER 
	STATE = STOP;

/*
	add filter on database_id
*/
ALTER EVENT SESSION [UI_Data] 
	ON SERVER 
	DROP EVENT sqlserver.sp_statement_completed, 
	DROP EVENT sqlserver.sql_batch_completed;

ALTER EVENT SESSION [UI_Data] 
	ON SERVER 
	ADD EVENT sqlserver.sp_statement_completed(
			SET collect_object_name=(1),collect_statement=(1)
		ACTION(
			sqlserver.client_app_name,sqlserver.database_name
			)
		WHERE (
			[package0].[equal_uint64]([sqlserver].[database_id],(7))
			)
		),
	ADD EVENT sqlserver.sql_batch_completed(
		ACTION(
			sqlserver.client_app_name,sqlserver.database_name
			)
		WHERE (
			[package0].[equal_uint64]([sqlserver].[database_id],(7))
			)
		)


ALTER EVENT SESSION [UI_Data] 
	ON SERVER 
	STATE = START;

/*
	note that only AW queries collected
*/
ALTER EVENT SESSION [UI_Data] 
	ON SERVER 
	STATE = STOP;

DROP EVENT SESSION [UI_Data] 
	ON SERVER;
