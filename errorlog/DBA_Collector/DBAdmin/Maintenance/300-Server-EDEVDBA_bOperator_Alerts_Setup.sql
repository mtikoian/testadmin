/* 2005,2008,2008R2,2012 */

/*****************************************************************************************************
 * Auto-Install Script Template
 *----------------------------------------------------------------------------------------------------
 *
 * Instructions:
 * The top line of this document must contain a commented comma seperated list of the versions of SQL 
 * that this script applies to.  Example: "/* 2000,2005,2008,2008R2 */"
 * 
 * This script template is only suitable for statements that are to be executed as part of the 
 * auto-install process and must run only against the server instance being installed.
 *
 * The script must terminate each statement using the ";" operator and must not contain the keyword 
 * "GO". 
 *
 * This template does not support scripts that need to be called with parameters.  If your script 
 * requires parameters please use the PowerShell Script template.
 *
 * Scripts must be named using the following pattern:
 * level-level name-script name
 *
 * level: The numeric level of the script.  This controls the order in which scripts are applied to
 *		  ensure that dependancies are not broken.  See Level list for the possible values.
 *
 * level name: The friendly name of the level.  This is meant to makes the scripts more easily
 *			   identifiable.  See Level list for the possible values.
 *
 * script name: The friendly name of the script.  This should be short, but detailed enought to tell
 *				what the script will accomplish.
 *
 * Example: "300-Server-AddExtendedProperty.sql" - Server level script that adds the DBA Extended
 *			property to the master and model databases
 *
 * Level List:
 * ---------------
 * 300 - Server - Scripts that create/alter/drop server level objects and settings
 * 400 - Database - Scripts that create/alter/drop databases and settings
 * 500 - Table - Scripts that create/alter/drop tables, schemas, users, roles
 * 600 - View - Scripts that create/alter/drop views, indexes, or other objects with table dependancies
 * 700 - Procedure - Scripts that create/alter/drop objects with table/view dependancies
 * 800 - Agent - Scripts that create/alter/drop agent jobs, job steps, job schedules, notifications, etc
 * 900 - Management - Scripts that are run last that pertain to management of the instance
 *****************************************************************************************************/
 
/*****************************************************************************************************
 * Script Information
 *----------------------------------------------------------------------------------------------------
 *		Author: Josh Feierman
 *		  Date: 3/14/2012
 * Description: Sets up the standard EDEV alerts and operators for notification.
 *	   History:
 *****************************************************************************************************/
-- Setup EDEV_DBA operator and alerts --
BEGIN TRY

	EXEC sp_configure 'Show Advanced Options',1;
	RECONFIGURE WITH OVERRIDE;
	
	EXEC sp_configure 'Agent XPs', 1;
	RECONFIGURE WITH OVERRIDE;    

    IF EXISTS (SELECT 1 FROM msdb.dbo.sysoperators WHERE name = 'EDEV_DBA')
			EXEC msdb.dbo.sp_delete_operator @name = 'EDEV_DBA';
			
    IF NOT EXISTS (SELECT 1 FROM MSDB.DBO.SYSOPERATORS WHERE NAME = 'EDEV_DBA')
        EXEC msdb.dbo.sp_add_operator @name=N'EDEV_DBA', 
		        @enabled=1, 
		        @weekday_pager_start_time=90000, 
		        @weekday_pager_end_time=180000, 
		        @saturday_pager_start_time=90000, 
		        @saturday_pager_end_time=180000, 
		        @sunday_pager_start_time=90000, 
		        @sunday_pager_end_time=180000, 
		        @pager_days=0, 
		        @email_address=N'EDEV-DBA-ALERTS@SEIC.COM', 
		        @category_name=N'[Uncategorized]';
		    
    IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'SQL_SEV_17')
			EXEC msdb.dbo.sp_delete_alert @name ='SQL_SEV_17';
			
    EXEC msdb.dbo.sp_add_alert @name=N'SQL_SEV_17', 
		    @message_id=0, 
		    @severity=17, 
		    @enabled=1, 
		    @delay_between_responses=60, 
		    @include_event_description_in=1, 
		    @job_id=N'00000000-0000-0000-0000-000000000000'

    EXEC msdb.dbo.sp_add_notification @alert_name=N'SQL_SEV_17', @operator_name=N'EDEV_DBA', @notification_method = 1

    IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'SQL_SEV_18')
			EXEC msdb.dbo.sp_delete_alert @name ='SQL_SEV_18';
		
    EXEC msdb.dbo.sp_add_alert @name=N'SQL_SEV_18', 
		    @message_id=0, 
		    @severity=18, 
		    @enabled=1, 
		    @delay_between_responses=60, 
		    @include_event_description_in=1, 
		    @job_id=N'00000000-0000-0000-0000-000000000000'

    EXEC msdb.dbo.sp_add_notification @alert_name=N'SQL_SEV_18', @operator_name=N'EDEV_DBA', @notification_method = 1
    
    IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'SQL_SEV_19')
			EXEC msdb.dbo.sp_delete_alert @name ='SQL_SEV_19';
		
    EXEC msdb.dbo.sp_add_alert @name=N'SQL_SEV_19', 
		    @message_id=0, 
		    @severity=19, 
		    @enabled=1, 
		    @delay_between_responses=60, 
		    @include_event_description_in=1, 
		    @job_id=N'00000000-0000-0000-0000-000000000000'

    EXEC msdb.dbo.sp_add_notification @alert_name=N'SQL_SEV_19', @operator_name=N'EDEV_DBA', @notification_method = 1

		IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = 'SQL_SEV_20')
			EXEC msdb.dbo.sp_delete_alert @name ='SQL_SEV_20';
		
    EXEC msdb.dbo.sp_add_alert @name=N'SQL_SEV_20', 
		    @message_id=0, 
		    @severity=20, 
		    @enabled=1, 
		    @delay_between_responses=60, 
		    @include_event_description_in=1, 
		    @job_id=N'00000000-0000-0000-0000-000000000000'

    EXEC msdb.dbo.sp_add_notification @alert_name=N'SQL_SEV_20', @operator_name=N'EDEV_DBA', @notification_method = 1
    
    
		IF EXISTS (SELECT 1 FROM msdb.dbo.sysalerts WHERE name = 'SQL_Login_Failed')
			EXEC msdb.dbo.sp_delete_alert @name = 'SQL_Login_Failed';
			
		EXEC msdb.dbo.sp_add_alert @name=N'SQL_Login_Failed', 
				@message_id=18456, 
				@severity=0, 
				@enabled=1, 
				@delay_between_responses=60, 
				@include_event_description_in=1, 
				@category_name=N'[Uncategorized]', 
				@job_id=N'00000000-0000-0000-0000-000000000000'
				
		EXEC msdb.dbo.sp_add_notification @alert_name = N'SQL_Login_Failed', @operator_name = N'EDEV_DBA', @notification_method = 1;



END TRY
BEGIN CATCH

    RAISERROR('Error occurred setting up operators and alerts.',16,1)
    
    DECLARE @errno INT,
                @errmsg VARCHAR(100),
                @errsev INT,
                @errstate INT ;

    SELECT   @errno = ERROR_NUMBER(),
             @errmsg = ERROR_MESSAGE(),
             @errsev = ERROR_SEVERITY(),
             @errstate = ERROR_STATE() ;
             
    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

USE [msdb]
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=0;
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail', N'REG_DWORD', 1;
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', N'EDEV_DBA_Profile';