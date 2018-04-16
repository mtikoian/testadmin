USE [msdb]
GO

/****** Object:  Job [DBATrace]    Script Date: 02/10/2012 08:53:01 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 02/10/2012 08:53:01 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBATrace', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job enabled as per change CH54939-- Job will run everynight from 11PM to 3AM to collect data for TRZ', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Create Trace]    Script Date: 02/10/2012 08:53:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Trace', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
declare @filename nvarchar (100)
DECLARE @stoptime DATETIME = DATEADD(hour,4,GETDATE())
-------Set the max trace file size here-----------
set @maxfilesize = 500
--------Set Trace File Path here-------------
set @filename = ''K:\SQLTrace\CIPOLTPTrace'' + convert (varchar,GETDATE(),112)

--The .trc extension will be appended to the filename automatically. If you are writing from
--remote server to local drive, please use UNC path and make sure server has write access to your network share.

----Change the path where the trace file needs to be saved here. DO NOT give the .trc extension-----------------
exec @rc = sp_trace_create @TraceID output, 6, @filename , @maxfilesize, @stoptime


if (@rc != 0) goto error

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 162, 7, @on
exec sp_trace_setevent @TraceID, 162, 31, @on
exec sp_trace_setevent @TraceID, 162, 8, @on
exec sp_trace_setevent @TraceID, 162, 64, @on
exec sp_trace_setevent @TraceID, 162, 1, @on
exec sp_trace_setevent @TraceID, 162, 9, @on
exec sp_trace_setevent @TraceID, 162, 41, @on
exec sp_trace_setevent @TraceID, 162, 49, @on
exec sp_trace_setevent @TraceID, 162, 6, @on
exec sp_trace_setevent @TraceID, 162, 10, @on
exec sp_trace_setevent @TraceID, 162, 14, @on
exec sp_trace_setevent @TraceID, 162, 26, @on
exec sp_trace_setevent @TraceID, 162, 30, @on
exec sp_trace_setevent @TraceID, 162, 50, @on
exec sp_trace_setevent @TraceID, 162, 66, @on
exec sp_trace_setevent @TraceID, 162, 3, @on
exec sp_trace_setevent @TraceID, 162, 11, @on
exec sp_trace_setevent @TraceID, 162, 35, @on
exec sp_trace_setevent @TraceID, 162, 51, @on
exec sp_trace_setevent @TraceID, 162, 4, @on
exec sp_trace_setevent @TraceID, 162, 12, @on
exec sp_trace_setevent @TraceID, 162, 20, @on
exec sp_trace_setevent @TraceID, 162, 60, @on
exec sp_trace_setevent @TraceID, 148, 11, @on
exec sp_trace_setevent @TraceID, 148, 51, @on
exec sp_trace_setevent @TraceID, 148, 4, @on
exec sp_trace_setevent @TraceID, 148, 12, @on
exec sp_trace_setevent @TraceID, 148, 14, @on
exec sp_trace_setevent @TraceID, 148, 26, @on
exec sp_trace_setevent @TraceID, 148, 60, @on
exec sp_trace_setevent @TraceID, 148, 64, @on
exec sp_trace_setevent @TraceID, 148, 1, @on
exec sp_trace_setevent @TraceID, 148, 41, @on
exec sp_trace_setevent @TraceID, 59, 55, @on
exec sp_trace_setevent @TraceID, 59, 32, @on
exec sp_trace_setevent @TraceID, 59, 56, @on
exec sp_trace_setevent @TraceID, 59, 64, @on
exec sp_trace_setevent @TraceID, 59, 1, @on
exec sp_trace_setevent @TraceID, 59, 21, @on
exec sp_trace_setevent @TraceID, 59, 25, @on
exec sp_trace_setevent @TraceID, 59, 41, @on
exec sp_trace_setevent @TraceID, 59, 49, @on
exec sp_trace_setevent @TraceID, 59, 57, @on
exec sp_trace_setevent @TraceID, 59, 2, @on
exec sp_trace_setevent @TraceID, 59, 14, @on
exec sp_trace_setevent @TraceID, 59, 22, @on
exec sp_trace_setevent @TraceID, 59, 26, @on
exec sp_trace_setevent @TraceID, 59, 58, @on
exec sp_trace_setevent @TraceID, 59, 3, @on
exec sp_trace_setevent @TraceID, 59, 35, @on
exec sp_trace_setevent @TraceID, 59, 51, @on
exec sp_trace_setevent @TraceID, 59, 4, @on
exec sp_trace_setevent @TraceID, 59, 12, @on
exec sp_trace_setevent @TraceID, 59, 52, @on
exec sp_trace_setevent @TraceID, 59, 60, @on
exec sp_trace_setevent @TraceID, 189, 7, @on
exec sp_trace_setevent @TraceID, 189, 15, @on
exec sp_trace_setevent @TraceID, 189, 55, @on
exec sp_trace_setevent @TraceID, 189, 8, @on
exec sp_trace_setevent @TraceID, 189, 32, @on
exec sp_trace_setevent @TraceID, 189, 56, @on
exec sp_trace_setevent @TraceID, 189, 64, @on
exec sp_trace_setevent @TraceID, 189, 1, @on
exec sp_trace_setevent @TraceID, 189, 9, @on
exec sp_trace_setevent @TraceID, 189, 41, @on
exec sp_trace_setevent @TraceID, 189, 49, @on
exec sp_trace_setevent @TraceID, 189, 57, @on
exec sp_trace_setevent @TraceID, 189, 2, @on
exec sp_trace_setevent @TraceID, 189, 10, @on
exec sp_trace_setevent @TraceID, 189, 26, @on
exec sp_trace_setevent @TraceID, 189, 58, @on
exec sp_trace_setevent @TraceID, 189, 66, @on
exec sp_trace_setevent @TraceID, 189, 3, @on
exec sp_trace_setevent @TraceID, 189, 11, @on
exec sp_trace_setevent @TraceID, 189, 35, @on
exec sp_trace_setevent @TraceID, 189, 51, @on
exec sp_trace_setevent @TraceID, 189, 4, @on
exec sp_trace_setevent @TraceID, 189, 12, @on
exec sp_trace_setevent @TraceID, 189, 52, @on
exec sp_trace_setevent @TraceID, 189, 60, @on
exec sp_trace_setevent @TraceID, 189, 13, @on
exec sp_trace_setevent @TraceID, 189, 6, @on
exec sp_trace_setevent @TraceID, 189, 14, @on
exec sp_trace_setevent @TraceID, 189, 22, @on
exec sp_trace_setevent @TraceID, 164, 7, @on
exec sp_trace_setevent @TraceID, 164, 8, @on
exec sp_trace_setevent @TraceID, 164, 24, @on
exec sp_trace_setevent @TraceID, 164, 56, @on
exec sp_trace_setevent @TraceID, 164, 64, @on
exec sp_trace_setevent @TraceID, 164, 9, @on
exec sp_trace_setevent @TraceID, 164, 25, @on
exec sp_trace_setevent @TraceID, 164, 41, @on
exec sp_trace_setevent @TraceID, 164, 49, @on
exec sp_trace_setevent @TraceID, 164, 6, @on
exec sp_trace_setevent @TraceID, 164, 10, @on
exec sp_trace_setevent @TraceID, 164, 14, @on
exec sp_trace_setevent @TraceID, 164, 22, @on
exec sp_trace_setevent @TraceID, 164, 26, @on
exec sp_trace_setevent @TraceID, 164, 34, @on
exec sp_trace_setevent @TraceID, 164, 50, @on
exec sp_trace_setevent @TraceID, 164, 66, @on
exec sp_trace_setevent @TraceID, 164, 3, @on
exec sp_trace_setevent @TraceID, 164, 11, @on
exec sp_trace_setevent @TraceID, 164, 35, @on
exec sp_trace_setevent @TraceID, 164, 51, @on
exec sp_trace_setevent @TraceID, 164, 4, @on
exec sp_trace_setevent @TraceID, 164, 12, @on
exec sp_trace_setevent @TraceID, 164, 28, @on
exec sp_trace_setevent @TraceID, 164, 52, @on
exec sp_trace_setevent @TraceID, 164, 60, @on
exec sp_trace_setevent @TraceID, 164, 21, @on
exec sp_trace_setevent @TraceID, 47, 7, @on
exec sp_trace_setevent @TraceID, 47, 8, @on
exec sp_trace_setevent @TraceID, 47, 24, @on
exec sp_trace_setevent @TraceID, 47, 56, @on
exec sp_trace_setevent @TraceID, 47, 64, @on
exec sp_trace_setevent @TraceID, 47, 9, @on
exec sp_trace_setevent @TraceID, 47, 25, @on
exec sp_trace_setevent @TraceID, 47, 41, @on
exec sp_trace_setevent @TraceID, 47, 49, @on
exec sp_trace_setevent @TraceID, 47, 6, @on
exec sp_trace_setevent @TraceID, 47, 10, @on
exec sp_trace_setevent @TraceID, 47, 14, @on
exec sp_trace_setevent @TraceID, 47, 22, @on
exec sp_trace_setevent @TraceID, 47, 26, @on
exec sp_trace_setevent @TraceID, 47, 34, @on
exec sp_trace_setevent @TraceID, 47, 50, @on
exec sp_trace_setevent @TraceID, 47, 66, @on
exec sp_trace_setevent @TraceID, 47, 3, @on
exec sp_trace_setevent @TraceID, 47, 11, @on
exec sp_trace_setevent @TraceID, 47, 35, @on
exec sp_trace_setevent @TraceID, 47, 51, @on
exec sp_trace_setevent @TraceID, 47, 4, @on
exec sp_trace_setevent @TraceID, 47, 12, @on
exec sp_trace_setevent @TraceID, 47, 28, @on
exec sp_trace_setevent @TraceID, 47, 52, @on
exec sp_trace_setevent @TraceID, 47, 60, @on
exec sp_trace_setevent @TraceID, 47, 21, @on
exec sp_trace_setevent @TraceID, 122, 7, @on
exec sp_trace_setevent @TraceID, 122, 8, @on
exec sp_trace_setevent @TraceID, 122, 64, @on
exec sp_trace_setevent @TraceID, 122, 1, @on
exec sp_trace_setevent @TraceID, 122, 9, @on
exec sp_trace_setevent @TraceID, 122, 25, @on
exec sp_trace_setevent @TraceID, 122, 41, @on
exec sp_trace_setevent @TraceID, 122, 49, @on
exec sp_trace_setevent @TraceID, 122, 2, @on
exec sp_trace_setevent @TraceID, 122, 10, @on
exec sp_trace_setevent @TraceID, 122, 14, @on
exec sp_trace_setevent @TraceID, 122, 22, @on
exec sp_trace_setevent @TraceID, 122, 26, @on
exec sp_trace_setevent @TraceID, 122, 34, @on
exec sp_trace_setevent @TraceID, 122, 50, @on
exec sp_trace_setevent @TraceID, 122, 66, @on
exec sp_trace_setevent @TraceID, 122, 3, @on
exec sp_trace_setevent @TraceID, 122, 11, @on
exec sp_trace_setevent @TraceID, 122, 35, @on
exec sp_trace_setevent @TraceID, 122, 51, @on
exec sp_trace_setevent @TraceID, 122, 4, @on
exec sp_trace_setevent @TraceID, 122, 12, @on
exec sp_trace_setevent @TraceID, 122, 28, @on
exec sp_trace_setevent @TraceID, 122, 60, @on
exec sp_trace_setevent @TraceID, 122, 5, @on
exec sp_trace_setevent @TraceID, 122, 29, @on
exec sp_trace_setevent @TraceID, 20, 7, @on
exec sp_trace_setevent @TraceID, 20, 23, @on
exec sp_trace_setevent @TraceID, 20, 31, @on
exec sp_trace_setevent @TraceID, 20, 8, @on
exec sp_trace_setevent @TraceID, 20, 64, @on
exec sp_trace_setevent @TraceID, 20, 1, @on
exec sp_trace_setevent @TraceID, 20, 9, @on
exec sp_trace_setevent @TraceID, 20, 21, @on
exec sp_trace_setevent @TraceID, 20, 49, @on
exec sp_trace_setevent @TraceID, 20, 57, @on
exec sp_trace_setevent @TraceID, 20, 6, @on
exec sp_trace_setevent @TraceID, 20, 10, @on
exec sp_trace_setevent @TraceID, 20, 14, @on
exec sp_trace_setevent @TraceID, 20, 26, @on
exec sp_trace_setevent @TraceID, 20, 30, @on
exec sp_trace_setevent @TraceID, 20, 3, @on
exec sp_trace_setevent @TraceID, 20, 11, @on
exec sp_trace_setevent @TraceID, 20, 35, @on
exec sp_trace_setevent @TraceID, 20, 51, @on
exec sp_trace_setevent @TraceID, 20, 12, @on
exec sp_trace_setevent @TraceID, 20, 60, @on
exec sp_trace_setevent @TraceID, 10, 7, @on
exec sp_trace_setevent @TraceID, 10, 15, @on
exec sp_trace_setevent @TraceID, 10, 31, @on
exec sp_trace_setevent @TraceID, 10, 8, @on
exec sp_trace_setevent @TraceID, 10, 16, @on
exec sp_trace_setevent @TraceID, 10, 48, @on
exec sp_trace_setevent @TraceID, 10, 64, @on
exec sp_trace_setevent @TraceID, 10, 1, @on
exec sp_trace_setevent @TraceID, 10, 9, @on
exec sp_trace_setevent @TraceID, 10, 17, @on
exec sp_trace_setevent @TraceID, 10, 25, @on
exec sp_trace_setevent @TraceID, 10, 41, @on
exec sp_trace_setevent @TraceID, 10, 49, @on
exec sp_trace_setevent @TraceID, 10, 2, @on
exec sp_trace_setevent @TraceID, 10, 10, @on
exec sp_trace_setevent @TraceID, 10, 18, @on
exec sp_trace_setevent @TraceID, 10, 26, @on
exec sp_trace_setevent @TraceID, 10, 34, @on
exec sp_trace_setevent @TraceID, 10, 50, @on
exec sp_trace_setevent @TraceID, 10, 66, @on
exec sp_trace_setevent @TraceID, 10, 3, @on
exec sp_trace_setevent @TraceID, 10, 11, @on
exec sp_trace_setevent @TraceID, 10, 35, @on
exec sp_trace_setevent @TraceID, 10, 51, @on
exec sp_trace_setevent @TraceID, 10, 4, @on
exec sp_trace_setevent @TraceID, 10, 12, @on
exec sp_trace_setevent @TraceID, 10, 60, @on
exec sp_trace_setevent @TraceID, 10, 13, @on
exec sp_trace_setevent @TraceID, 10, 6, @on
exec sp_trace_setevent @TraceID, 10, 14, @on
exec sp_trace_setevent @TraceID, 43, 7, @on
exec sp_trace_setevent @TraceID, 43, 15, @on
exec sp_trace_setevent @TraceID, 43, 8, @on
exec sp_trace_setevent @TraceID, 43, 48, @on
exec sp_trace_setevent @TraceID, 43, 64, @on
exec sp_trace_setevent @TraceID, 43, 1, @on
exec sp_trace_setevent @TraceID, 43, 9, @on
exec sp_trace_setevent @TraceID, 43, 41, @on
exec sp_trace_setevent @TraceID, 43, 49, @on
exec sp_trace_setevent @TraceID, 43, 2, @on
exec sp_trace_setevent @TraceID, 43, 10, @on
exec sp_trace_setevent @TraceID, 43, 26, @on
exec sp_trace_setevent @TraceID, 43, 34, @on
exec sp_trace_setevent @TraceID, 43, 50, @on
exec sp_trace_setevent @TraceID, 43, 66, @on
exec sp_trace_setevent @TraceID, 43, 3, @on
exec sp_trace_setevent @TraceID, 43, 11, @on
exec sp_trace_setevent @TraceID, 43, 35, @on
exec sp_trace_setevent @TraceID, 43, 51, @on
exec sp_trace_setevent @TraceID, 43, 4, @on
exec sp_trace_setevent @TraceID, 43, 12, @on
exec sp_trace_setevent @TraceID, 43, 28, @on
exec sp_trace_setevent @TraceID, 43, 60, @on
exec sp_trace_setevent @TraceID, 43, 5, @on
exec sp_trace_setevent @TraceID, 43, 13, @on
exec sp_trace_setevent @TraceID, 43, 29, @on
exec sp_trace_setevent @TraceID, 43, 6, @on
exec sp_trace_setevent @TraceID, 43, 14, @on
exec sp_trace_setevent @TraceID, 43, 22, @on
exec sp_trace_setevent @TraceID, 43, 62, @on
exec sp_trace_setevent @TraceID, 45, 7, @on
exec sp_trace_setevent @TraceID, 45, 55, @on
exec sp_trace_setevent @TraceID, 45, 8, @on
exec sp_trace_setevent @TraceID, 45, 16, @on
exec sp_trace_setevent @TraceID, 45, 48, @on
exec sp_trace_setevent @TraceID, 45, 64, @on
exec sp_trace_setevent @TraceID, 45, 1, @on
exec sp_trace_setevent @TraceID, 45, 9, @on
exec sp_trace_setevent @TraceID, 45, 17, @on
exec sp_trace_setevent @TraceID, 45, 25, @on
exec sp_trace_setevent @TraceID, 45, 41, @on
exec sp_trace_setevent @TraceID, 45, 49, @on
exec sp_trace_setevent @TraceID, 45, 10, @on
exec sp_trace_setevent @TraceID, 45, 18, @on
exec sp_trace_setevent @TraceID, 45, 26, @on
exec sp_trace_setevent @TraceID, 45, 34, @on
exec sp_trace_setevent @TraceID, 45, 50, @on
exec sp_trace_setevent @TraceID, 45, 66, @on
exec sp_trace_setevent @TraceID, 45, 3, @on
exec sp_trace_setevent @TraceID, 45, 11, @on
exec sp_trace_setevent @TraceID, 45, 35, @on
exec sp_trace_setevent @TraceID, 45, 51, @on
exec sp_trace_setevent @TraceID, 45, 4, @on
exec sp_trace_setevent @TraceID, 45, 12, @on
exec sp_trace_setevent @TraceID, 45, 28, @on
exec sp_trace_setevent @TraceID, 45, 60, @on
exec sp_trace_setevent @TraceID, 45, 5, @on
exec sp_trace_setevent @TraceID, 45, 13, @on
exec sp_trace_setevent @TraceID, 45, 29, @on
exec sp_trace_setevent @TraceID, 45, 61, @on
exec sp_trace_setevent @TraceID, 45, 6, @on
exec sp_trace_setevent @TraceID, 45, 14, @on
exec sp_trace_setevent @TraceID, 45, 22, @on
exec sp_trace_setevent @TraceID, 45, 62, @on
exec sp_trace_setevent @TraceID, 45, 15, @on
exec sp_trace_setevent @TraceID, 12, 7, @on
exec sp_trace_setevent @TraceID, 12, 15, @on
exec sp_trace_setevent @TraceID, 12, 31, @on
exec sp_trace_setevent @TraceID, 12, 8, @on
exec sp_trace_setevent @TraceID, 12, 16, @on
exec sp_trace_setevent @TraceID, 12, 48, @on
exec sp_trace_setevent @TraceID, 12, 64, @on
exec sp_trace_setevent @TraceID, 12, 1, @on
exec sp_trace_setevent @TraceID, 12, 9, @on
exec sp_trace_setevent @TraceID, 12, 17, @on
exec sp_trace_setevent @TraceID, 12, 41, @on
exec sp_trace_setevent @TraceID, 12, 49, @on
exec sp_trace_setevent @TraceID, 12, 6, @on
exec sp_trace_setevent @TraceID, 12, 10, @on
exec sp_trace_setevent @TraceID, 12, 14, @on
exec sp_trace_setevent @TraceID, 12, 18, @on
exec sp_trace_setevent @TraceID, 12, 26, @on
exec sp_trace_setevent @TraceID, 12, 50, @on
exec sp_trace_setevent @TraceID, 12, 66, @on
exec sp_trace_setevent @TraceID, 12, 3, @on
exec sp_trace_setevent @TraceID, 12, 11, @on
exec sp_trace_setevent @TraceID, 12, 35, @on
exec sp_trace_setevent @TraceID, 12, 51, @on
exec sp_trace_setevent @TraceID, 12, 4, @on
exec sp_trace_setevent @TraceID, 12, 12, @on
exec sp_trace_setevent @TraceID, 12, 60, @on
exec sp_trace_setevent @TraceID, 12, 13, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

----Filter the hostname if needed. All the queries originating from the local server will be filtered-------
exec sp_trace_setfilter @TraceID, 8, 0, 7, N''VA10PWPSQL023A''
exec sp_trace_setfilter @TraceID, 8, 0, 7, N''VA10PWPSQL023b''

----Filter the trace to capture only long running queries. This value filters out any queries having less duration than 10ms----
set @bigintfilter = 100000
exec sp_trace_setfilter @TraceID, 13, 0, 4, @bigintfilter

----Filter the systemdatabases... Include ReportServer if needed------
exec sp_trace_setfilter @TraceID, 35, 0, 7, N''master''
exec sp_trace_setfilter @TraceID, 35, 0, 7, N''msdb''
exec sp_trace_setfilter @TraceID, 35, 0, 7, N''mssqlsystemresource''
exec sp_trace_setfilter @TraceID, 35, 0, 7, N''model''
exec sp_trace_setfilter @TraceID, 35, 0, 7, N''ReportServer''

----Filter the SQL Server Service Account-------
exec sp_trace_setfilter @TraceID, 64, 0, 7, N''US\srcIBMsql2''

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBATrace', 
		@enabled=0, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110916, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'0724cd8e-59f0-4772-a021-f1f54f2de2d1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'IN244022', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120209, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, 
		@schedule_uid=N'213667d4-08ca-4b79-864f-037bfcfa0c1c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              