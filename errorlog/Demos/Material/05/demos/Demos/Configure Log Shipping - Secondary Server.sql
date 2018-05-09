-- Execute on the Secondary to configure Log Shipping 

DECLARE @LS_Secondary__CopyJobId	AS uniqueidentifier; 
DECLARE @LS_Secondary__RestoreJobId	AS uniqueidentifier; 
DECLARE @LS_Secondary__SecondaryId	AS uniqueidentifier; 
DECLARE @LS_Add_RetCode	As int; 

-- Sets up primary server information, creates copy and restore jobs, and monitor server link
EXEC @LS_Add_RetCode = master.dbo.sp_add_log_shipping_secondary_primary 
		@primary_server = N'LABDB03' 
		,@primary_database = N'AdventureWorks' 
		,@backup_source_directory = N'\\LABDB03\LSBackups' 
		,@backup_destination_directory = N'\\LABDB04\LSBackups' 
		,@copy_job_name = N'LSCopy_LABDB03_AdventureWorks' 
		,@restore_job_name = N'LSRestore_LABDB03_AdventureWorks' 
		,@file_retention_period = 4320 
		,@monitor_server = N'LABDB01' 
		,@monitor_server_security_mode = 0 
		,@monitor_server_login = N'sa' 
		,@monitor_server_password = N'1994Acura#'
		,@overwrite = 1 
		,@copy_job_id = @LS_Secondary__CopyJobId OUTPUT 
		,@restore_job_id = @LS_Secondary__RestoreJobId OUTPUT 
		,@secondary_id = @LS_Secondary__SecondaryId OUTPUT; 

IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) 
BEGIN 

DECLARE @LS_SecondaryCopyJobScheduleUID	As uniqueidentifier; 
DECLARE @LS_SecondaryCopyJobScheduleID	AS int; 

-- Creates a schedule for the copy job
EXEC msdb.dbo.sp_add_schedule 
		@schedule_name =N'DefaultCopyJobSchedule' 
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
		,@schedule_uid = @LS_SecondaryCopyJobScheduleUID OUTPUT 
		,@schedule_id = @LS_SecondaryCopyJobScheduleID OUTPUT; 

-- Links the copy job to the schedule
EXEC msdb.dbo.sp_attach_schedule @job_id = @LS_Secondary__CopyJobId, 
		                         @schedule_id = @LS_SecondaryCopyJobScheduleID;  

DECLARE @LS_SecondaryRestoreJobScheduleUID	As uniqueidentifier; 
DECLARE @LS_SecondaryRestoreJobScheduleID	AS int; 

-- Creates a schedule for the restore job
EXEC msdb.dbo.sp_add_schedule 
		@schedule_name =N'DefaultRestoreJobSchedule' 
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
		,@schedule_uid = @LS_SecondaryRestoreJobScheduleUID OUTPUT 
		,@schedule_id = @LS_SecondaryRestoreJobScheduleID OUTPUT; 

-- Links the restore job to the schedule
EXEC msdb.dbo.sp_attach_schedule @job_id = @LS_Secondary__RestoreJobId,
                                 @schedule_id = @LS_SecondaryRestoreJobScheduleID;  

END 


DECLARE @LS_Add_RetCode2 AS int; 


IF (@@ERROR = 0 AND @LS_Add_RetCode = 0) 
BEGIN 
	-- Sets up the secondary database for log shipping
	EXEC @LS_Add_RetCode2 = master.dbo.sp_add_log_shipping_secondary_database 
			@secondary_database = N'AdventureWorks' 
			,@primary_server = N'LABDB03' 
			,@primary_database = N'AdventureWorks' 
			,@restore_delay = 0 
			,@restore_mode = 0 
			,@disconnect_users	= 0 
			,@restore_threshold = 45   
			,@threshold_alert_enabled = 1 
			,@history_retention_period	= 5760 
			,@overwrite = 1; 
END 


IF (@@error = 0 AND @LS_Add_RetCode = 0) 
BEGIN 

	-- Enable the LSCopy job
	EXEC msdb.dbo.sp_update_job @job_id = @LS_Secondary__CopyJobId, @enabled = 1; 

	-- Enable the LS Restore job
	EXEC msdb.dbo.sp_update_job @job_id = @LS_Secondary__RestoreJobId, @enabled = 1; 

END 





