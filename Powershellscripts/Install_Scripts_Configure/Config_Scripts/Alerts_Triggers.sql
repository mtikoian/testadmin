EXEC msdb.dbo.sp_add_alert @name=N'Login Error', 
		@message_id=18456, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Login Error', @operator_name=N'SQLServerAdmins', @notification_method = 1;

EXEC msdb.dbo.sp_add_alert @name=N'Permission Error', 
		@message_id=15247, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Permission Error', @operator_name=N'SQLServerAdmins', @notification_method = 1;

EXEC msdb.dbo.sp_add_alert @name=N'Log Full', 
		@message_id=9002, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=900, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Log Full', @operator_name=N'SQLServerAdmins', @notification_method = 1;

EXEC msdb.dbo.sp_add_alert @name=N'On Schedule Policy Mgmt', 
		@message_id=34052, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=3600, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'On Schedule Policy Mgmt', @operator_name=N'SQLServerAdmins', @notification_method = 1;     

EXEC msdb.dbo.sp_add_alert @name=N'Disk I/O Errors', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1, 
		@notification_message=N'http://www.sqlskills.com/blogs/paul/a-little-known-sign-of-impending-doom-error-825/';
EXEC msdb.dbo.sp_add_notification @alert_name=N'Disk I/O Errors', @operator_name=N'SQLServerAdmins', @notification_method = 1;
    
EXEC msdb.dbo.sp_add_alert @name=N'Fatal Resource Error', 
		@message_id=0, 
		@severity=19, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Fatal Resource Error', @operator_name=N'SQLServerAdmins', @notification_method = 1;
    
EXEC msdb.dbo.sp_add_alert @name=N'Fatal Error in Current Process', 
		@message_id=0, 
		@severity=20, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Fatal Error in Current Process', @operator_name=N'SQLServerAdmins', @notification_method = 1;    

EXEC msdb.dbo.sp_add_alert @name=N'Fatal Error in Database Process', 
		@message_id=0, 
		@severity=21, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Fatal Error in Database Process', @operator_name=N'SQLServerAdmins', @notification_method = 1;    

EXEC msdb.dbo.sp_add_alert @name=N'Fatal Error - Table Integrity Suspect', 
		@message_id=0, 
		@severity=22, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Fatal Error - Table Integrity Suspect', @operator_name=N'SQLServerAdmins', @notification_method = 1;    

EXEC msdb.dbo.sp_add_alert @name=N'Fatal Error - Database Integrity Suspect', 
		@message_id=0, 
		@severity=23, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Fatal Error - Database Integrity Suspect', @operator_name=N'SQLServerAdmins', @notification_method = 1;    

EXEC msdb.dbo.sp_add_alert @name=N'Fatal Error in Hardware', 
		@message_id=0, 
		@severity=24, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Fatal Error in Hardware', @operator_name=N'SQLServerAdmins', @notification_method = 1;    

EXEC msdb.dbo.sp_add_alert @name=N'Fatal Error', 
		@message_id=0, 
		@severity=25, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=1;
EXEC msdb.dbo.sp_add_notification @alert_name=N'Fatal Error', @operator_name=N'SQLServerAdmins', @notification_method = 1;    

IF EXISTS (SELECT * FROM sys.server_triggers WHERE name = 'ddl_trig_new_database')
    DROP TRIGGER ddl_trig_new_database ON ALL SERVER;
GO

CREATE TRIGGER ddl_trig_new_database ON ALL SERVER FOR CREATE_DATABASE
    as 
    DECLARE @DBNAME varchar(200)
    DECLARE @BODY varchar(1000)
    SELECT @DBNAME = EVENTDATA().value('(/EVENT_INSTANCE/DatabaseName)[1]','nvarchar(max)')
    SET @BODY = 'Server = ' + @@SERVERNAME + CHAR(10) + CHAR(13) + 
                'New Database Named = ' + @DBNAME + CHAR(10) + CHAR(13) + 
                'Created By = ' + ORIGINAL_LOGIN() + CHAR(10) + CHAR(13) + 
                'Date Created = ' + cast(getdate() as CHAR)     
    EXEC msdb.dbo.sp_notify_operator
    	@name = N'SQLServerAdmins',
               @subject = N'New Database Created',
               @body = @BODY
    