/*============================================================================
  File:     3a_Targets_EventCounter.sql

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

IF EXISTS (SELECT 1 FROM [sys].[server_event_sessions] WHERE [name] = 'Count_Events')
	DROP EVENT SESSION [Count_Events] ON SERVER;
GO


CREATE EVENT SESSION [Count_Events] 
	ON SERVER 
ADD EVENT sqlserver.sp_statement_completed(
    WHERE ([sqlserver].[is_system]=(0))),
ADD EVENT sqlserver.sql_statement_completed(
    WHERE ([sqlserver].[is_system]=(0)))  
ADD TARGET package0.event_counter
WITH (
	MAX_MEMORY=16384 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF
	)
GO


/*
	start the session
*/
ALTER EVENT SESSION [Count_Events]
	ON SERVER
	STATE=START;
	GO


/*
	run .ps1 script: Run_Demo3_EventCounter

	view the data in the UI

	then run: Run_Demo3_EventCounter_2
*/


/*
	stop the event session
*/
ALTER EVENT SESSION [Count_Events]
	ON SERVER
	STATE=STOP;
	GO

/*
	clean up
*/
DROP EVENT SESSION [Count_Events] ON SERVER;