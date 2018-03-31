/*============================================================================
  File:     3b_Targets_Histogram.sql

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

IF EXISTS (SELECT 1 FROM [sys].[server_event_sessions] WHERE [name] = 'TrackRecompiles')
	DROP EVENT SESSION [TrackRecompiles] ON SERVER;
GO

CREATE EVENT SESSION [TrackRecompiles] 
	ON SERVER 
ADD EVENT sqlserver.sql_statement_recompile(
		SET collect_object_name=(1),collect_statement=(1)
    WHERE (
		[sqlserver].[is_system]=(0)
		)
	) 
ADD TARGET package0.histogram(
	SET filtering_event_name=N'sqlserver.sql_statement_recompile',slots=(10),source=N'recompile_cause',source_type=(0)
	)
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO




/*
	start the session
*/
ALTER EVENT SESSION [TrackRecompiles]
	ON SERVER
	STATE=START;
	GO


/*
	run Run_Demo3_Histogram*.ps1 scripts
	view the data in the UI
*/


/*
1 = schema change
2 = stats change
3 = deferred compile
4 = SET option changed
5 = temporary table change
6 = remote rowset changed
7 = FOR BROWSE permission change
8 = query notification environment change
9 = partitioned view change
10 = cursor options changed
11 = OPTION (RECOMPILE) requested
*/


/*
	stop the event session
*/
ALTER EVENT SESSION [TrackRecompiles]
	ON SERVER
	STATE=STOP;
	GO

/*
	clean up
*/
DROP EVENT SESSION [TrackRecompiles] ON SERVER;