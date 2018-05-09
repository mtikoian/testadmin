--	Create ServerMonitor database objects 

-- Run on both sides of mirroring partnership

USE [master];
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'ServerMonitor')
	BEGIN
		CREATE DATABASE [ServerMonitor];
	END 
GO

ALTER DATABASE [ServerMonitor] MODIFY FILE (NAME = N'ServerMonitor', 
               SIZE = 512MB , FILEGROWTH = 1024MB);
GO
ALTER DATABASE [ServerMonitor] MODIFY FILE (NAME = N'ServerMonitor_log', 
               SIZE = 512MB , FILEGROWTH = 1024MB);
GO
ALTER DATABASE [ServerMonitor] SET RECOVERY SIMPLE; 
GO
ALTER DATABASE [ServerMonitor] SET PAGE_VERIFY CHECKSUM;  
GO


-- Create objects in ServerMonitor database (SQL Server 2008 and greater)
USE [ServerMonitor];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create SQLServerInstanceMetricHistory table if it does not exist
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID(N'[dbo].[SQLServerInstanceMetricHistory]') 
			   AND type IN (N'U'))
	BEGIN
		CREATE TABLE [dbo].[SQLServerInstanceMetricHistory](
			[SQLServerInstanceMetricHistoryID] [bigint] IDENTITY(1,1) NOT NULL,
			[MeasurementTime] [datetime] NOT NULL,
			[AvgTaskCount] [int] NOT NULL,
			[AvgRunnableTaskCount] [int] NOT NULL,
			[AvgPendingIOCount] [int] NOT NULL,
			[SQLServerCPUUtilization] [int] NOT NULL,
			[PageLifeExpectancy] [int] NOT NULL,
		 CONSTRAINT [PK_SQLServerInstanceMetricHistory] PRIMARY KEY CLUSTERED 
		([SQLServerInstanceMetricHistoryID] ASC)
		WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
		ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
		) ON [PRIMARY];
	END
GO

-- Check for Enterprise Edition
IF SERVERPROPERTY('EngineEdition') = 3
	BEGIN
		-- Compress the clustered index
		ALTER TABLE [dbo].[SQLServerInstanceMetricHistory] REBUILD PARTITION = ALL
		WITH (DATA_COMPRESSION = PAGE);
	END

-- Drop and create DBAdminRecordSQLServerMetrics SP
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[DBAdminRecordSQLServerMetrics]') 
		   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DBAdminRecordSQLServerMetrics];
GO

/* DBAdminRecordSQLServerMetrics ==============================================
Description : Used to keep track of instance level SQL Server Metrics
						
Author: Glenn Berry	
Date: 5-16-2012	
Input: None			            	
Output:	
Used By: Only used to monitor the database            	

Last Modified      	Developer		Description
-----------------------------------------------------------------------------------
5-16-2012			Glenn Berry		Created
7-3-2013            Glenn Berry     Changed PLE query to handle multiple NUMA nodes 
=================================================================================*/
CREATE PROCEDURE [dbo].[DBAdminRecordSQLServerMetrics]
AS

	SET NOCOUNT ON;
	SET QUOTED_IDENTIFIER ON;
	SET ANSI_NULLS ON;

	
	DECLARE @PageLifeExpectancy int = 0;
	DECLARE @SQLProcessUtilization int = 0;
	
	-- Page Life Expectancy (PLE) value for current instance  
	SET @PageLifeExpectancy = (SELECT AVG(cntr_value) AS [PageLifeExpectancy]
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
	AND counter_name = N'Page life expectancy');
	
	
	-- Get CPU Utilization for last minute (SQL 2008 and above only)
	SET @SQLProcessUtilization = (SELECT TOP(1) SQLProcessUtilization 
	                              AS [SQLServerProcessCPUUtilization]              
	FROM ( 
		  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') AS [SQLProcessUtilization], [timestamp] 
		  FROM ( 
				SELECT [timestamp], CONVERT(xml, record) AS [record] 
				FROM sys.dm_os_ring_buffers 
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
				AND record LIKE N'%<SystemHealth>%') AS x 
		  ) AS y 
	ORDER BY record_id DESC);
	
	
	-- Add metrics info to SQLServerInstanceMetricHistory
	INSERT INTO dbo.SQLServerInstanceMetricHistory
	            (MeasurementTime, AvgTaskCount, AvgRunnableTaskCount, AvgPendingIOCount, 
				 SQLServerCPUUtilization, PageLifeExpectancy)
	(SELECT GETDATE() AS [MeasurementTime], AVG(current_tasks_count)AS [AvgTaskCount], 
	        AVG(runnable_tasks_count)AS [AvgRunnableTaskCount], 
	        AVG(pending_disk_io_count) AS [AvgPendingDiskIOCount], @SQLProcessUtilization, 
			@PageLifeExpectancy
	 FROM sys.dm_os_schedulers WITH (NOLOCK)
	 WHERE scheduler_id < 255);

	RETURN;
	
GO




-- Create SQL Server Agent job to call DBAdminRecordSQLServerMetrics
-- in ServerMonitor database once a minute
USE [msdb];
GO

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view 
            WHERE name = N'Record Instance Level Metrics')
	EXEC sp_delete_job @job_name = N'Record Instance Level Metrics', @delete_unused_schedule = 1;
GO

BEGIN TRANSACTION
	DECLARE @ReturnCode INT = 0;
	
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories 
	               WHERE name=N'Instance Level Job' AND category_class=1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', 
		     @name=N'Instance Level Job'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

	DECLARE @jobId BINARY(16);
	
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Record Instance Level Metrics', 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'Record Instance Level Metrics in ServerMonitor database', 
			@category_name=N'Instance Level Job', 
			@owner_login_name=N'sa', @job_id = @jobId OUTPUT;
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, 
	        @step_name=N'Record Instance Level Metrics', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'EXEC dbo.DBAdminRecordSQLServerMetrics;', 
			@database_name=N'ServerMonitor', 
			@flags=0;
			
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	DECLARE @StartDate AS INT = CONVERT(INT, CONVERT(VARCHAR(8), GETDATE(), 112));
	
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, 
	        @name=N'Record Instance Level Metrics', 
			@enabled=1, 
			@freq_type=4, 
			@freq_interval=1, 
			@freq_subday_type=4, 
			@freq_subday_interval=1, 
			@freq_relative_interval=0, 
			@freq_recurrence_factor=0, 
			@active_start_date= @StartDate, 
			@active_end_date=99991231, 
			@active_start_time=0, 
			@active_end_time=235959, 
			@schedule_uid=NULL;

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
		GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';

	IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
		GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
EndSave:
GO

