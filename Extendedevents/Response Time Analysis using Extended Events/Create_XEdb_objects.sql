/******************************************************************************
	Extended Events Wait Time Analysis

	Authors: Thomas Kejser (Microsoft), Mario Broodbakker (HP)
	Contributors: Jerome Hallmans (Microsoft), Raoul Illyes (MiracleAS), Sanjay Mishra (Microsoft)

	Description: Track waitstats for a specific session 
	
********************************************************************************/

USE [XEdb]
GO


CREATE TABLE [dbo].[XEtable](
	[PK] [bigint] IDENTITY(1,1) NOT NULL,
	[target_data] [xml] NULL,
 CONSTRAINT [PK_XEtable] PRIMARY KEY CLUSTERED ([PK] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO


/********************************************************************************/
CREATE PROCEDURE [dbo].[usp_wta_start]
  @session_id INT = null /* the session to track */
, @username nvarchar(max) = null /* the username to track */
, @client_app_name nvarchar(max) = null /* the application to track */
, @client_hostname nvarchar(max) = null /* the client hostname to track */
, @log_path NVARCHAR(255) = 'C:\Temp\' /* path used to to save Extended Events trace files (make sure SQL Server can write here) */
AS
SET NOCOUNT ON 

/* Validate input */
IF RIGHT(@log_path, 1) <> '\' BEGIN	/* add an end dash if not already present */
	SET @log_path = @log_path + '\'
END
DECLARE @sql_event NVARCHAR(MAX)	/* SQL to hold dynamic execution */
DECLARE @trace_name NVARCHAR(MAX)   /* SQL trace handle */


/* Find the largest session_id that is a system process (50 is not longer true on large NUMA machines) */
DECLARE @last_system_session INT
SELECT @last_system_session = MAX(session_id) FROM sys.dm_exec_sessions WHERE is_user_process = 0

IF @session_id IS NOT NULL 
	BEGIN	/* add a filter if needed */
		SET @trace_name = 'SESSION_ID_' + CAST(@session_id AS VARCHAR(10))
	END

IF @client_app_name IS NOT NULL 
	BEGIN
		SET @trace_name = 'CLIENT_APP_NAME_' +@client_app_name
	END

IF @client_hostname IS NOT NULL 
	BEGIN
		SET @trace_name = 'CLIENT_HOSTNAME_' +@client_hostname
	END

IF @username IS NOT NULL 
	BEGIN
		SET @trace_name = 'USERNAME_' +@username
	END

/* check to see if there is already an Xevent session for this user session, if so: drop it */
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='XE_wta_trace_' + @trace_name) 
BEGIN
	SET @sql_event='DROP EVENT SESSION XE_wta_trace_' + @trace_name + ' ON SERVER'
	EXEC sp_executeSql @sql_event
END

/* create sql statement need to trace event (need to play this trick to make filtering dynamic) */
SET @sql_event = '
CREATE EVENT SESSION XE_wta_trace_' + @trace_name +  ' ON SERVER
	ADD EVENT sqlserver.sql_statement_starting 
		(action (sqlserver.session_id,
			sqlserver.sql_text, 
			sqlserver.plan_handle, 
			sqlserver.tsql_stack) 
	WHERE sqlserver.session_id > <last_system_session> <sessionfilter>), 
	ADD EVENT sqlserver.sql_statement_completed 
		(action (sqlserver.session_id, 
			sqlserver.sql_text, 
			sqlserver.plan_handle, 
			sqlserver.tsql_stack) 
	WHERE sqlserver.session_id > <last_system_session> <sessionfilter>), 
	ADD EVENT sqlserver.sp_statement_starting 
		(action (sqlserver.session_id,
			sqlserver.sql_text, 
			sqlserver.plan_handle,
			sqlserver.tsql_stack) 
	WHERE sqlserver.session_id > <last_system_session> <sessionfilter>), 
	ADD EVENT sqlserver.sp_statement_completed 
		(action (sqlserver.session_id, 
			sqlserver.sql_text, 
			sqlserver.plan_handle, 
			sqlserver.tsql_stack) 
	WHERE sqlserver.session_id > <last_system_session> <sessionfilter>), 
	ADD EVENT sqlos.wait_info 
		(action (sqlserver.session_id, 
			sqlserver.plan_handle) 
	WHERE sqlserver.session_id > <last_system_session> <sessionfilter> and opcode=1) -- Only end of wait event
	--
	ADD
	TARGET package0.asynchronous_file_target 
		(SET filename = N''<log_path>XE_wta_trace_'+ @trace_name + '.etx''
			, metadatafile = N''<log_path>XE_wta_trace_' + @trace_name + '.mta''
		, max_file_size = 0, max_rollover_files = 0) 
	WITH 
	(MAX_DISPATCH_LATENCY = 1 seconds, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS )

'

SET @sql_event = REPLACE(@sql_event, '<log_path>', @log_path)
SET @sql_event = REPLACE(@sql_event, '<last_system_session>', @last_system_session)

   
	IF @session_id IS NOT NULL 
	BEGIN	/* add a filter if needed */
		SET @sql_event = REPLACE(@sql_event, '<sessionfilter>', 'AND sqlserver.session_id = ' + CAST(@session_id AS VARCHAR(10)))
	END
	IF @client_app_name IS NOT NULL 
	BEGIN
		SET @sql_event = REPLACE(@sql_event, '<sessionfilter>', 'AND sqlserver.client_app_name = ' + '''' + @client_app_name + '''') 
	END

	IF @client_hostname IS NOT NULL 
	BEGIN
		SET @sql_event = REPLACE(@sql_event, '<sessionfilter>', 'AND sqlserver.client_hostname = ' + '''' + @client_hostname + '''')
	END

	IF @username IS NOT NULL 
	BEGIN
		SET @sql_event = REPLACE(@sql_event, '<sessionfilter>', 'AND sqlserver.username = ' + '''' + @username + '''') 
	END

ELSE BEGIN
	SET @sql_event = REPLACE(@sql_event, '<sessionfilter>', '')
END

/* Create trace session */
EXEC sp_executeSql @sql_event

SET @sql_event='ALTER EVENT SESSION XE_wta_trace_' + @trace_name + ' ON SERVER state=start'
EXEC sp_executeSql @sql_event

GO


/********************************************************************************/
CREATE PROCEDURE [dbo].[usp_wta_stop]
 @trace_name NVARCHAR(MAX) = null /* the session to track*/
,@log_path NVARCHAR(255) = 'C:\Temp\'
,@drop_trace CHAR(1) = N	/* to drop the session or not */

AS
SET NOCOUNT ON 

DECLARE @sql_event NVARCHAR(MAX)	/* SQL to hold dynamic execution */


/* stop tracking */
IF @trace_name IS NULL
	BEGIN
		SELECT event_session_id, name FROM sys.server_event_sessions
	END
ELSE

SET @sql_event='ALTER EVENT SESSION ' + @trace_name + ' ON SERVER state=stop'
EXEC sp_executeSql @sql_event


/* load trace file */
DECLARE @sql_clean NVARCHAR(MAX)	/* SQL to hold dynamic execution */
SET @sql_clean='TRUNCATE TABLE XEdb.dbo.XEtable
				IF EXISTS (SELECT name FROM XEdb..sysindexes WHERE name = ''Primary_XML_idx'')
				DROP INDEX [Primary_XML_idx] ON [XEdb].[dbo].[XEtable]'
EXEC sp_executeSql @sql_clean

DECLARE @sql_load NVARCHAR(MAX)	/* SQL to hold dynamic execution */
SET @sql_load=N'INSERT INTO XEdb.dbo.XEtable (target_data)
select cast(event_data as xml) as yo from
sys.fn_xe_file_target_read_file (''' +@log_path + @trace_name + '*.etx'',''' +@log_path+ @trace_name + '*.mta'',null,null)'
EXEC sp_executeSql @sql_load


DECLARE @sql_index NVARCHAR(MAX)	/* SQL to hold dynamic execution */
SET @sql_index='IF NOT EXISTS (SELECT name FROM XEdb..sysindexes WHERE name = ''Primary_XML_idx'')
CREATE PRIMARY XML INDEX [Primary_XML_idx] ON [XEdb].[dbo].[XEtable] 
(
	[target_data]
)WITH (PAD_INDEX  = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)

IF NOT EXISTS (SELECT name FROM XEdb..sysindexes WHERE name = ''Secondary_XML_Value_idx'')
CREATE XML INDEX Secondary_XML_Value_idx 
    ON [XEdb].[dbo].[XEtable]  (target_data)
    USING XML INDEX Primary_XML_idx FOR VALUE;

'
EXEC sp_executeSql @sql_index


/* check to see if @drop Xevent session for this execution is set, if so: drop it */
IF UPPER(@drop_trace) = 'Y'
BEGIN
	SET @sql_event='DROP EVENT SESSION ' + @trace_name + ' ON SERVER'
	EXEC sp_executeSql @sql_event
END

GO



/********************************************************************************/
CREATE FUNCTION [dbo].[fn_GetWaitsSummed](@begin_time AS datetime2, @end_time AS datetime2)
  RETURNS TABLE
AS
RETURN
  SELECT sum(target_data.value('(event/data/value)[3]', 'int')+ target_data.value('(event/data/value)[6]', 'int')) waiting 
			FROM dbo.XEtable
			WHERE target_data.value('(event/@name)[1]', 'varchar(30)') = 'wait_info'
			AND target_data.value('(event/@timestamp)[1]', 'datetime2') BETWEEN @begin_time AND @end_time


GO


