/*============================================================================
  File:     1e_Start_Stop_Drop_Session.sql

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
	Check to see what exists
*/
SELECT * 
FROM [sys].[server_event_sessions];
GO

SELECT * 
FROM [sys].[fn_trace_getinfo](0);
GO



/*
	Start
*/
ALTER EVENT SESSION [XE_ReadsFilter_Trace]
	ON SERVER
	STATE=START;
GO

DECLARE @TraceID INT = 2;
EXEC sp_trace_setstatus @TraceID, 1;
GO


/*
	What's running?
*/
SELECT
	[es].[name] AS [EventSession],
	[xe].[create_time] AS [SessionCreateTime],
	[xe].[total_buffer_size] AS [TotalBufferSize],
	[xe].[dropped_event_count] AS [DroppedEventCount]
FROM [sys].[server_event_sessions] [es]
LEFT OUTER JOIN [sys].[dm_xe_sessions] [xe] ON [es].[name] = [xe].[name];
GO

SELECT 
	[id] AS [TraceID],
	CASE	
		WHEN [status] = 0 THEN 'Not running'
		WHEN [status] = 1 THEN 'Running'
	END AS [TraceStatus],
	[start_time] AS [TraceStartTime],
	[buffer_size] AS [BufferSize],
	[dropped_event_count] AS [DroppedEventCount]
FROM [sys].[traces];
GO


/*
	Stop (run workload before stopping - remove filter)
*/
ALTER EVENT SESSION [XE_ReadsFilter_Trace]
	ON SERVER
	STATE=STOP;
GO

DECLARE @TraceID INT = 2;
EXEC sp_trace_setstatus @TraceID, 0; 
GO


/*
	Remove
*/
DROP EVENT SESSION [XE_ReadsFilter_Trace]
	ON SERVER;
GO

DECLARE @TraceID INT = 2;
EXEC sp_trace_setstatus @TraceID, 2;
GO


