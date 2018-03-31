/*============================================================================
  File:     1d_CreateSession.sql

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

IF EXISTS (
		SELECT 1 FROM sys.server_event_sessions 
		WHERE name = 'XE_ReadsFilter_Trace')
	DROP EVENT SESSION [XE_ReadsFilter_Trace] ON SERVER;
GO

CREATE EVENT SESSION [XE_ReadsFilter_Trace]
ON SERVER
ADD EVENT sqlserver.rpc_completed(
	ACTION 
	(
		sqlserver.client_app_name	-- ApplicationName from SQLTrace
		, sqlserver.client_pid	-- ClientProcessID from SQLTrace
		, sqlserver.database_id	-- DatabaseID from SQLTrace
		, sqlserver.server_instance_name	-- ServerName from SQLTrace
		, sqlserver.server_principal_name	-- LoginName from SQLTrace
		, sqlserver.session_id	-- SPID from SQLTrace
		-- BinaryData not implemented in XE for this event
		-- EndTime implemented by another Action in XE already
		-- StartTime implemented by another Action in XE already
	)
	WHERE 
	(
			logical_reads >= 10000
	)
),
ADD EVENT sqlserver.sql_statement_completed(
	ACTION 
	(
			sqlserver.client_app_name	-- ApplicationName from SQLTrace
		, sqlserver.client_pid	-- ClientProcessID from SQLTrace
		, sqlserver.database_id	-- DatabaseID from SQLTrace
		, sqlserver.server_instance_name	-- ServerName from SQLTrace
		, sqlserver.server_principal_name	-- LoginName from SQLTrace
		, sqlserver.session_id	-- SPID from SQLTrace
		-- EndTime implemented by another Action in XE already
		-- StartTime implemented by another Action in XE already
	)
	WHERE 
	(
			logical_reads >= 10000
	)
)
ADD TARGET package0.event_file
(
	SET filename = 'C:\Temp\XE_ReadsFilter_Trace.xel',
		max_file_size = 100,
		max_rollover_files = 1
)

--remove reads filter before running workload!