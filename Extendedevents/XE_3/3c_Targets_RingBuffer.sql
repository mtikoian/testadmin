/*============================================================================
  File:     3e_Targets_RingBuffer.sql

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

IF EXISTS (SELECT 1 FROM [sys].[server_event_sessions] WHERE [name] = 'Capture_Queries')
	DROP EVENT SESSION [Capture_Queries] ON SERVER;
GO

/*
	What event should we capture?
*/
SELECT 
	[xo].[name], 
	[xo].[description], 
	[xp].[name] AS [package]
FROM [sys].[dm_xe_objects] [xo]
JOIN [sys].[dm_xe_packages] [xp]
	ON [xo].[package_guid] = [xp].[guid]
WHERE [xo].[object_type] = N'event'
AND [xo].[name] like '%completed%'
ORDER BY [xo].[name];
GO

/*
	What's included in the default payload
	for rpc_completed?
	What if we also want to include database_id
	and the client application name?
*/
SELECT * 
FROM [sys].[dm_xe_object_columns]
WHERE [object_name] = N'rpc_completed'
AND [column_type] <> 'readonly';
GO


/*
	Can we find database_id and client
	application name in the actions?
*/
SELECT 
	[xo].[name], 
	[xo].[description], 
	[xp].[name] AS [package]
FROM [sys].[dm_xe_objects] [xo]
JOIN [sys].[dm_xe_packages] [xp]
	ON [xo].[package_guid] = [xp].[guid]
WHERE [xo].[object_type] = N'action'
ORDER BY [xo].[name];
GO

/*
	create the event session
*/
CREATE EVENT SESSION [Capture_Queries] 
	ON SERVER 
ADD EVENT sqlserver.rpc_completed (
    ACTION (
		sqlserver.database_id,
		sqlserver.client_app_name
		)
    WHERE (
		[sqlserver].[is_system]=(0))
		),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION (
		sqlserver.database_id,
		sqlserver.client_app_name
		)
    WHERE (
		[sqlserver].[is_system]=(0))
		) 
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=1024 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO


/*
	start the session
*/
ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	STATE=START;
	GO

--run .ps1 scripts

/*
	query the ring_buffer in a separate window
*/


/*
	Check to see how many events are in the ring_buffer, and how many you can really see
*/
SELECT
    ring_buffer_event_count, 
    event_node_count, 
    ring_buffer_event_count - event_node_count AS events_not_in_xml
FROM
(    SELECT target_data.value('(RingBufferTarget/@eventCount)[1]', 'int') AS ring_buffer_event_count,
        target_data.value('count(RingBufferTarget/event)', 'int') as event_node_count
    FROM
    (    SELECT CAST(target_data AS XML) AS target_data  
        FROM sys.dm_xe_sessions as s
        INNER JOIN sys.dm_xe_session_targets AS st 
            ON s.address = st.event_session_address
        WHERE s.name = N'Capture_Queries'
            AND st.target_name = N'ring_buffer'    ) AS n    ) AS t;


/*
	Check memory allocated for ring_buffer and what can be read 
*/
SELECT
    target_data.value('(RingBufferTarget/@memoryUsed)[1]', 'int') AS buffer_memory_used_bytes,
    ROUND(target_data.value('(RingBufferTarget/@memoryUsed)[1]', 'int')/1024., 1) AS buffer_memory_used_kb,
    ROUND(target_data.value('(RingBufferTarget/@memoryUsed)[1]', 'int')/1024/1024., 1) AS buffer_memory_used_MB,
    DATALENGTH(target_data) AS xml_length_bytes,
    ROUND(DATALENGTH(target_data)/1024., 1) AS xml_length_kb,
    ROUND(DATALENGTH(target_data)/1024./1024,1) AS xml_length_MB
FROM (
SELECT CAST(target_data AS XML) AS target_data  
FROM sys.dm_xe_sessions as s
INNER JOIN sys.dm_xe_session_targets AS st 
    ON s.address = st.event_session_address
WHERE s.name = N'Capture_Queries'
 AND st.target_name = N'ring_buffer') as tab(target_data)


/*
	alter session to stop collecting rpc_completed event
*/
ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	DROP EVENT sqlserver.rpc_completed;
	GO

/*
	alter session to stop collecting sp_statement_completed event
*/
ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	DROP EVENT sqlserver.sp_statement_completed;
	GO


/*
	query the ring_buffer again in a separate window
*/


/*
	stop the event session, then query 
	the ring_buffer one more time
*/
ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	STATE=STOP;
	GO


/*
	remove the ring_buffer target
	add event_file target
*/
ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	DROP TARGET package0.ring_buffer;
GO

ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	ADD TARGET package0.event_file (
	SET filename=N'C:\Temp\CaptureQueries.xel')
GO


/*
	no events exist at this point...
	re-add one
*/
ALTER EVENT SESSION [Capture_Queries] 
	ON SERVER 
ADD EVENT sqlserver.sp_statement_completed (
    ACTION (
		sqlserver.database_id,
		sqlserver.session_nt_username)
    WHERE (
		[sqlserver].[is_system]=(0))
		);
GO


/*
	restart
*/
ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	STATE=START;
	GO


/*
	collect some data, then stop
*/
ALTER EVENT SESSION [Capture_Queries]
	ON SERVER
	STATE=STOP;
GO

/*
	could have stopped the session, dropped it, and then recreated it
*/
DROP EVENT SESSION [Capture_Queries]
	ON SERVER;
	GO
   
CREATE EVENT SESSION [Capture_Queries] 
	ON SERVER 
ADD EVENT sqlserver.sp_statement_completed (
    ACTION (
		sqlserver.database_id,sqlserver.session_nt_username)
    WHERE (
		[sqlserver].[is_system]=(0))
		) 
ADD TARGET package0.event_file (
	SET filename=N'C:\Temp\CaptureQueries.xel')
WITH (MAX_MEMORY=1024 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,
MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF);
GO




