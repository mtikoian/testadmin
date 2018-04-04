USE [msdb]
GO

DECLARE @ReturnCode INT
DECLARE @jobId BINARY(16)

BEGIN TRANSACTION


SELECT @ReturnCode = 0

-- Create job
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AdhocRestore_$(DatabaseName)', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=3,
		@notify_email_operator_name='$(DatabaseName)_AdhocBackupRestoreOperator',
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Restores the adhoc copy-only backup of the $(DatabaseName) database. Used by development team for "snapshot" purposes.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'$(DatabaseName)_ProxyAgentOwner', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- Create job step
EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, 
    @step_name=N'Restore Database', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
		@subsystem=N'CmdExec', 
		@command=N'SQLCMD -S $(ServerName) -E -d tempdb -b -Q "ALTER DATABASE [$(DatabaseName)] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;RESTORE DATABASE [$(DatabaseName)] FROM DISK = ''$(BackupLocation)\$(DatabaseName)_Adhoc.bak'' WITH RECOVERY,REPLACE"', 
		@database_name=N'master', 
		@flags=0,
		@proxy_name = '$(DatabaseName)_AdhocBackupProxy';
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
