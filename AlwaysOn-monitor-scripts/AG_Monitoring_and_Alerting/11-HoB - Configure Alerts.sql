DECLARE @name VarChar(128)
DECLARE @account_name sysname

SET @account_name = 'SQLAdmin';

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 17)
	BEGIN
		SET @name = N'HoB-Severity 00017 - Insufficient Resources'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=17,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 18)
	BEGIN
		SET @name = N'HoB-Severity 00018 - Nonfatal Internal Error'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=18,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 19)
	BEGIN
		SET @name = N'HoB-Severity 00019 - Fatal Error in Resource'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=19,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 20)
	BEGIN
		SET @name = N'HoB-Severity 00020 - Fatal Error in Current Process'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=20,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 21)
	BEGIN
		SET @name = N'HoB-Severity 00021 - Fatal Error in Database Processes'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=21,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 22)
	BEGIN
		SET @name = N'HoB-Severity 00022 - Fatal Error: Table Integrity Suspect'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=22,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 23)
	BEGIN
		SET @name = N'HoB-Severity 00023 - Fatal Error: Database Integrity Suspect'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=23,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 24)
	BEGIN
		SET @name = N'HoB-Severity 00024 - Fatal Error: Hardware Error'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=24,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE Severity = 25)
	BEGIN
		SET @name = N'HoB-Severity 00025 - Fatal Error'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=0,
			@severity=25,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 823)
	BEGIN
		SET @name = N'HoB-Severity 00823 - I/O Errors'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=823,
			@severity=0,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 824)
	BEGIN
		SET @name = N'HoB-Severity 00824 - Logical Consistency Errors'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=824,
			@severity=0,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 825)
	BEGIN
		SET @name = N'HoB-Severity 00825 - I/O Retry Errors'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=825,
			@severity=0,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 1480)
	BEGIN
		SET @name = N'HoB-Severity 01480 - AG Role Change'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=1480,
			@severity=0,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 35264)
	BEGIN
		SET @name = N'HoB-Severity 35264 - AG Data Movement - Suspended'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=35264,
			@severity=0,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 35265)
	BEGIN
		SET @name = N'HoB-Severity 35265 - AG Data Movement - Resumed'
		EXEC msdb.dbo.sp_add_alert @name=@name,
			@message_id=35265,
			@severity=0,
			@enabled=1,
			@delay_between_responses=600,
			@include_event_description_in=1,
			@job_id=N'00000000-0000-0000-0000-000000000000'
		EXEC msdb.dbo.sp_add_notification @alert_name=@name, @operator_name=@account_name, @notification_method = 1
	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 34050)
	BEGIN
		SET @name = N'HoB-Severity 34050 - Policy Violation'
EXEC msdb.dbo.sp_add_alert @name=N'HoB-Severity 34050 - Policy Violation', 
		@message_id=34050, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 34050)
	BEGIN
		SET @name = N'HoB-Severity 34051 - Policy Violation'
EXEC msdb.dbo.sp_add_alert @name=N'HoB-Severity 34051 - Policy Violation', 
		@message_id=34051, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 34052)
	BEGIN
		SET @name = N'HoB-Severity 34052 - Policy Violation'
EXEC msdb.dbo.sp_add_alert @name=N'HoB-Severity 34052 - Policy Violation', 
		@message_id=34052, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 34050)
	BEGIN
		SET @name = N'HoB-Severity 34053 - Policy Violation'
EXEC msdb.dbo.sp_add_alert @name=N'HoB-Severity 34053 - Policy Violation', 
		@message_id=34053, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

	END

IF NOT EXISTS(SELECT name FROM [msdb].[dbo].[sysalerts] WHERE message_id = 34054)
	BEGIN
		SET @name = N'HoB-Severity 34054 - Policy Violation'
EXEC msdb.dbo.sp_add_alert @name=N'HoB-Severity 34054 - Policy Violation', 
		@message_id=34054, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO

	END


