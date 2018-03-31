/*============================================================================
  File:     2a_Concepts_through_the_UI.sql

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

/*
	Default templates exist, just as in Profiler
	The Activity Tracking Template recreates what the default trace captures
	Issue with said template in SQL 2012:
	https://www.sqlskills.com/blogs/jonathan/workaround-for-bug-in-activity-tracking-event-session-template-in-2012-rc0/
*/

/*
	create an event session DBUse with lock_acquired event

	owner = SharedXactWorkspace
	resource = Database level lock
	only user databases (database_id > 4)
	only user processes (is_system = 0)
*/


/*
	Look at the lock_acquired event columns
*/
SELECT * 
FROM [sys].[dm_xe_object_columns]
WHERE [object_name] = 'lock_acquired';


/*
	Look at the Lock Resource Type and the Lock Owner Type
*/
SELECT * 
FROM [sys].[dm_xe_map_values]
WHERE [name] IN ('lock_resource_type','lock_owner_type')
ORDER BY [name], [map_value];


/*
	create the event session
*/
IF EXISTS (SELECT 1 FROM [sys].[server_event_sessions] WHERE [name] = 'DBUse')
	DROP EVENT SESSION [DBUse] ON SERVER;
GO

CREATE EVENT SESSION [DBUse] 
ON SERVER 
ADD EVENT sqlserver.lock_acquired( 
	WHERE owner_type = 4 -- SharedXactWorkspace
		AND resource_type = 2 -- Database level lock
		AND database_id > 4 -- non system database
		AND sqlserver.is_system = 0 -- must be a user process
) 
ADD TARGET package0.event_file(SET filename=N'C:\Temp\DBUse')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO

/*
	start the event session
*/

ALTER EVENT SESSION [DBUse] 
	ON SERVER 
	STATE = START;

/*
	run .ps scripts to get some data
*/


/*
	stop the event session
*/
ALTER EVENT SESSION [DBUse] 
	ON SERVER 
	STATE = STOP;

/*
	clean up
*/
DROP EVENT SESSION [DBUse] ON SERVER;