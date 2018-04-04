:SETVAR DatabaseName D0931_435_AGA_QA

USE [msdb]
GO

DECLARE @ReturnCode INT
DECLARE @jobId BINARY(16)

BEGIN TRANSACTION


SELECT @ReturnCode = 0


EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AdhocBackup_$(DatabaseName)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Takes an adhoc copy-only backup of the $(DatabaseName) database. Used by development team for "snapshot" purposes.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup database', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @BackupFileName NVARCHAR(255);

SET @BackupFileName = @@SERVERNAME + ''_$(DatabaseName).BAK'';
SET @BackupFileName = REPLACE(@BackupFileName,''\'',''$'');
SET @BackupFileName = ''\\ABERNAS03.ctc.seic.com\SQLBACKUP\'' + @BackupFileName;

BACKUP DATABASE [$(DatabaseName)] 
  TO DISK = @BackupFileName
  WITH INIT, COPY_ONLY;	', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


