-- Connect to 


EXEC dbo.sp_configure 'show advanced options', 1
GO 
RECONFIGURE
GO
EXEC dbo.sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE
GO
EXEC dbo.sp_configure 'show advanced options',0
GO
RECONFIGURE
GO


-- Create a Database Mail profile 
EXECUTE msdb.dbo.sysmail_add_profile_sp 
@profile_name = 'SQL_Email_Profile', 
@description = 'Notification service for SQL Server' ; 
GO
-- Create a Database Mail account 
EXECUTE msdb.dbo.sysmail_add_account_sp 
@account_name = 'SQL Server Notification Service', 
@description = 'SQL Server Notification Service', 
@email_address = 'e-mail@domain.com',  -- <--------- change e-mail
@replyto_address = 'e-mail@domain.com',  -- <--------- change e-mail
@display_name = 'SQL Server', 
@mailserver_name = 'mail.domain.com' ; -- <--------- change e-mail server address
GO
-- Add the account to the profile 
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
@profile_name = 'SQL_Email_Profile', 
@account_name = 'SQL Server Notification Service', 
@sequence_number =1 ; 
GO
-- Grant access to the profile to the DBMailUsers role 
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp 
@profile_name = 'SQL_Email_Profile', 
@principal_id = 0, 
@is_default = 1 ; 
GO
SELECT * FROM msdb.dbo.sysmail_profile 
SELECT * FROM msdb.dbo.sysmail_account

-- Adding operators
USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'DBA', 
		@enabled=1, 
		@weekday_pager_start_time=0, 
		@weekday_pager_end_time=235959, 
		@saturday_pager_start_time=0, 
		@saturday_pager_end_time=235959, 
		@sunday_pager_start_time=0, 
		@sunday_pager_end_time=235959, 
		@pager_days=127, 
		@email_address=N'e-mail@domain.com',  -- <--------- change e-mail
		@pager_address=N''
GO

USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1
GO
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail', N'REG_DWORD', 1
GO
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', N'SQL_Email_Profile'
GO

-- Adding alerts for Severity >=19 and errors 823, 824, 825

EXEC msdb.dbo.sp_add_alert @name=N'017 - Insufficient Resources', 
		@message_id=0, 
		@severity=17, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'018 - Nonfatal Internal Error Detected', 
		@message_id=0, 
		@severity=18, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'019 - Fatal Error in Resources', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'020 - Fatal Error in Current Process', 
		@message_id=0, 
		@severity=20, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'021 - Fatal Error in Database Processes', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'022 - Fatal Error: Table Integrity Suspect', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'023 - Fatal Error: Database Integrity Suspect', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'024 - Fatal Error: Hardware Error', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'025 - Fatal Error', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'823 - IO operation failed at OS level', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'824 - IO operation failed at hardware level', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'825 - Read retry error', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_operator @name=N'DBA', 
		@enabled=1, 
		@weekday_pager_start_time=0, 
		@weekday_pager_end_time=235959, 
		@saturday_pager_start_time=0, 
		@saturday_pager_end_time=235959, 
		@sunday_pager_start_time=0, 
		@sunday_pager_end_time=235959, 
		@pager_days=127, 
		@email_address=N'e-mail@domain.com',  -- <--------- change e-mail
		@pager_address=N'', 
		@netsend_address=N''
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'017 - Insufficient Resources', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'018 - Nonfatal Internal Error Detected', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'019 - Fatal Error in Resources', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'020 - Fatal Error in Current Process', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'021 - Fatal Error in Database Processes', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'022 - Fatal Error: Table Integrity Suspect', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'023 - Fatal Error: Database Integrity Suspect', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'024 - Fatal Error: Hardware Error', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'025 - Fatal Error', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'823 - IO operation failed at OS level', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'824 - IO operation failed at hardware level', @operator_name=N'DBA', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'825 - Read retry error', @operator_name=N'DBA', @notification_method = 1
GO

