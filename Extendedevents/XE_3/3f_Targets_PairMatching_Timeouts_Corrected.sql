/*============================================================================
  File:     3d_Targets_PairMatching_Timeouts_Corrected.sql

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


/************************** Setup the Environment  ***************************
USE [AdventureWorks2014]
GO
IF OBJECT_ID(N'SPDoesNotFinish') IS NOT NULL
BEGIN
	DROP PROCEDURE [dbo].[SPDoesNotFinish]
END
GO
CREATE PROCEDURE [dbo].[SPDoesNotFinish]
( @WaitForValue varchar(12) = '00:00:00:050')
AS
BEGIN

	SELECT * 
	FROM Sales.SalesOrderDetail
	WHERE [SalesOrderDetailID] < 25
	OPTION(RECOMPILE)

	WAITFOR DELAY @WaitForValue;

END

GO
******************************************************************************/

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='SpStatementTimeouts')
    DROP EVENT SESSION [SpStatementTimeouts] ON SERVER;
GO

/*
	Create the Event Session
*/
CREATE EVENT SESSION [SpStatementTimeouts]
	ON SERVER
ADD EVENT sqlserver.sp_statement_starting(
	ACTION(
		sqlserver.session_id, sqlserver.tsql_stack, sqlserver.sql_text, sqlserver.plan_handle
		)
	/* If we remove the state predicate we'll get invalid unmatched events */
	WHERE (state = 0) /* Don't fire Recompiled Events */
	),
ADD EVENT sqlserver.sp_statement_completed(
	ACTION(
		sqlserver.session_id, sqlserver.tsql_stack)
	)
ADD TARGET package0.pair_matching(
	SET	begin_event = N'sqlserver.sp_statement_starting',
		begin_matching_actions = N'sqlserver.session_id, sqlserver.tsql_stack',
		end_event = N'sqlserver.sp_statement_completed',
		end_matching_actions = N'sqlserver.session_id, sqlserver.tsql_stack',
		respond_to_memory_pressure = 0
	),
ADD TARGET event_file(SET filename=N'C:\Temp\SpStatementTimeouts.xel', max_file_size=50, max_rollover_files=10)
WITH(MAX_DISPATCH_LATENCY=1 SECONDS, TRACK_CAUSALITY=ON, STARTUP_STATE = ON);
GO

/*
	Start the Event Session
*/
ALTER EVENT SESSION [SpStatementTimeouts]
ON SERVER
STATE = START;
GO

/*
	Change connection properties to time out at 2 seconds and run the workload
	run the test
	refresh the target data to show the unpaired event
*/
EXECUTE [AdventureWorks2014].[dbo].[SPDoesNotFinish];
GO 10
EXECUTE [AdventureWorks2014].[dbo].[SPDoesNotFinish] '00:00:05.000';
GO
EXECUTE [AdventureWorks2014].[dbo].[SPDoesNotFinish];
GO 10