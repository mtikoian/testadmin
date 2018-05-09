-- Execute on the Primary to configure Log Shipping 

DECLARE @LS_BackupJobId	AS uniqueidentifier; 
DECLARE @LS_PrimaryId	AS uniqueidentifier; 
DECLARE @SP_Add_RetCode	AS int; 

-- Configure the Primary database for log shipping, create backup job and add Monitor server link
EXEC @SP_Add_RetCode = master.dbo.sp_add_log_shipping_primary_database 
		@database = N'AdventureWorks' 
		,@backup_directory = N'M:\SQLBackups\LSBackups' 
		,@backup_share = N'\\LABDB03\LSBackups' 
		,@backup_job_name = N'LSBackup_AdventureWorks' 
		,@backup_retention_period = 4320
		,@backup_compression = 1
		,@monitor_server = N'LABDB01' 
		,@monitor_server_security_mode = 0 
		,@monitor_server_login = N'sa'
		,@monitor_server_password = N'1994Acura#'
		,@backup_threshold = 60 
		,@threshold_alert_enabled = 1
		,@history_retention_period = 5760 
		,@backup_job_id = @LS_BackupJobId OUTPUT 
		,@primary_id = @LS_PrimaryId OUTPUT 
		,@overwrite = 1 


IF (@@ERROR = 0 AND @SP_Add_RetCode = 0) 
	BEGIN 

	DECLARE @LS_BackUpScheduleUID	As uniqueidentifier; 
	DECLARE @LS_BackUpScheduleID	AS int; 

	-- Add a schedule for the backup job
	EXEC msdb.dbo.sp_add_schedule 
			@schedule_name =N'LSBackupSchedule_LABDB031' 
			,@enabled = 1 
			,@freq_type = 4 
			,@freq_interval = 1 
			,@freq_subday_type = 4 
			,@freq_subday_interval = 15 
			,@freq_recurrence_factor = 0 
			,@active_start_date = 20170928 
			,@active_end_date = 99991231 
			,@active_start_time = 0 
			,@active_end_time = 235900 
			,@schedule_uid = @LS_BackUpScheduleUID OUTPUT 
			,@schedule_id = @LS_BackUpScheduleID OUTPUT; 

	-- Link the schedule to the job
	EXEC msdb.dbo.sp_attach_schedule @job_id = @LS_BackupJobId, @schedule_id = @LS_BackUpScheduleID;  

	-- Enable the backup job
	EXEC msdb.dbo.sp_update_job @job_id = @LS_BackupJobId, @enabled = 1; 

END 

	-- Add information about secondary server and database
	EXEC master.dbo.sp_add_log_shipping_primary_secondary @primary_database = N'AdventureWorks', 
		@secondary_server = N'LABDB04', @secondary_database = N'AdventureWorks', @overwrite = 1; 




