-- Add Mirroring Support to ServerMonitor database.sql 

-- Run on both sides of mirroring partnership


-- This SP has to be in the master database, since you can only 
-- run the failover command from master
USE [master];
GO

-- Drop and create sp_FailoverUserDatabase SP from master database
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[sp_FailoverUserDatabase]') 
		   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[sp_FailoverUserDatabase];
GO

/* sp_FailoverUserDatabase ===================================================
Description : Failover a user database from the master database
Used By: Only used for database mirroring support             
 
Last Modified           Developer         Description 
-----------------------------------------------------------------------------
12-27-2011              Glenn Berry       Created     
=============================================================================*/
CREATE PROCEDURE [dbo].[sp_FailoverUserDatabase]
(@DatabaseName nvarchar(128))
AS
    SET NOCOUNT ON;

    DECLARE @MirroringRole tinyint = 0;
    DECLARE @SQLCommand nvarchar(255);
      
      
    -- Get mirroring role for database
    SET @MirroringRole = (SELECT mirroring_role
                          FROM sys.database_mirroring
                          WHERE DB_NAME(database_id) = @DatabaseName);  
    
    -- Must be in Principal role                                  
    IF @MirroringRole = 1  -- Principal
        BEGIN
            SET @SQLCommand = N'ALTER DATABASE ' + @DatabaseName + N' SET PARTNER FAILOVER;';
            EXECUTE (@SQLCommand);
        END                                   
      
    RETURN;
GO
-- *********************************************************************************




USE [ServerMonitor];
GO

-- Drop and create DBAdminSynchronizeMirroringStatus SP
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[DBAdminSynchronizeMirroringStatus]') 
		   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DBAdminSynchronizeMirroringStatus];
GO

/* DBAdminSynchronizeMirroringStatus =========================================
Description : Get database mirroring status for your "main" database and 
              failover appropriate databases if needed
Used By: Only used for database mirroring support              
 
Last Modified           Developer         Description 
-----------------------------------------------------------------------------
12-27-2011              Glenn Berry       Created   
=============================================================================*/
CREATE PROCEDURE [dbo].[DBAdminSynchronizeMirroringStatus]
AS
      SET NOCOUNT ON;
      DECLARE @MirroringRole tinyint = 0;
                        
      -- Get mirroring role for your "main" database
      SET @MirroringRole = (SELECT mirroring_role
                            FROM sys.database_mirroring
                            WHERE DB_NAME(database_id) = N'AdventureWorks');   
 
      IF @MirroringRole = 2 -- Mirror
            BEGIN
                  -- MainDatabaseName failed-over, so failover other related mirrored databases
                  EXEC [master].dbo.sp_FailoverUserDatabase N'AdventureWorks2014';
                  
                  --EXEC [master].dbo.sp_FailoverUserDatabase N'DatabaseTwo';
                  
                  --EXEC [master].dbo.sp_FailoverUserDatabase N'DatabaseThree';

                  -- Add more databases as needed. Make sure to change the database names!
                    
            END                                      
      RETURN;
GO

-- Drop and create DBAdminChangeJobStatus SP
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[DBAdminChangeJobStatus]') 
		   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DBAdminChangeJobStatus];
GO

/* DBAdminChangeJobStatus ===================================================
Description : Change Agent job status for all jobs in a Category              

Used By: Only used for database mirroring support              

Last Modified           Developer         Description
-----------------------------------------------------------------------------
12-27-2011              Glenn Berry       Created 
===========================================================================*/

CREATE PROCEDURE [dbo].[DBAdminChangeJobStatus]
(@CategoryID int,
 @CurrentEnabledValue tinyint,
 @NewEnabledValue tinyint)
AS

      SET NOCOUNT ON;
      DECLARE @JobName nvarchar(128);

      -- Declare cursor
      DECLARE curJobNameList CURSOR
      FAST_FORWARD
      FOR
  
            SELECT [name]
            FROM msdb.dbo.sysjobs
            WHERE category_id = @CategoryID
            AND [enabled] = @CurrentEnabledValue;
     
            OPEN curJobNameList;

            FETCH NEXT
            FROM curJobNameList
            INTO @JobName;

            WHILE @@FETCH_STATUS = 0
                  BEGIN
                        EXEC msdb.dbo.sp_update_job @job_name = @JobName, 
						                            @enabled = @NewEnabledValue;

                        FETCH NEXT
                        FROM curJobNameList
                        INTO @JobName;
                  END
            CLOSE curJobNameList;
            DEALLOCATE curJobNameList;
      RETURN;
GO

 
-- Drop and create DBAdminCheckMirroringStatus SP
IF EXISTS (SELECT * FROM sys.objects 
           WHERE object_id = OBJECT_ID(N'[dbo].[DBAdminCheckMirroringStatus]') 
		   AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DBAdminCheckMirroringStatus];
GO 

/* DBAdminCheckMirroringStatus ===============================================
Description : Get database mirroring status for all mirrored databases 
and change Agent job status if needed

Used By: Only used for database mirroring support               

Last Modified           Developer         Description
-----------------------------------------------------------------------------
12-27-2011              Glenn Berry       Created 
============================================================================*/

CREATE PROCEDURE [dbo].[DBAdminCheckMirroringStatus]
AS

      SET NOCOUNT ON;
      DECLARE @DatabaseName nvarchar(128);
      DECLARE @MirroringRole tinyint = 0;
      DECLARE @CategoryID int = 0;

      DECLARE curDatabaseNameList CURSOR
      FAST_FORWARD
      FOR
            -- Get list of all mirrored databases
            SELECT DB_NAME(database_id) AS [DatabaseName]
            FROM sys.database_mirroring
            WHERE database_id > 4
            AND NOT mirroring_role IS NULL;

            OPEN curDatabaseNameList;

            FETCH NEXT
            FROM curDatabaseNameList
            INTO @DatabaseName;

            WHILE @@FETCH_STATUS = 0
                  BEGIN
                        -- Get the CategoryID for the CategoryName that matches the DatabaseName
                        SET @CategoryID = (SELECT TOP(1) sj.category_id
										   FROM msdb.dbo.sysjobs AS sj
                                           INNER JOIN msdb.dbo.syscategories AS sc
                                           ON sj.category_id = sc.category_id
                                           WHERE sc.name = @DatabaseName
                                           ORDER BY sj.category_id);

                        IF @CategoryID > 0 
                              BEGIN
                                -- Get mirroring role for database
								SET @MirroringRole = (SELECT mirroring_role
													  FROM sys.database_mirroring
                                                      WHERE DB_NAME(database_id)=@DatabaseName);

                                IF @MirroringRole = 1  -- Principal
									BEGIN
										-- Enable all jobs in this Category that are disabled
										EXEC dbo.DBAdminChangeJobStatus @CategoryID, 0, 1;
									END

                                IF @MirroringRole = 2 -- Mirror
									BEGIN
										-- Disable all jobs in this Category that are enabled
										EXEC dbo.DBAdminChangeJobStatus @CategoryID, 1, 0;
									END
                              END

                        SET @CategoryID = 0;

                        FETCH NEXT
                        FROM curDatabaseNameList
                        INTO @DatabaseName;
                  END

            CLOSE curDatabaseNameList;
            DEALLOCATE curDatabaseNameList;

      RETURN;
GO
-- ********************************************************************************


-- Create a new SQL Server Agent job called “Check Mirroring Status of All Databases” 
-- that calls the DBAdminCheckMirroringStatus stored procedure every 15 seconds

USE [msdb]
GO

IF EXISTS (SELECT name FROM msdb.dbo.sysjobs 
           WHERE name = N'Check Mirroring Status of All Databases')
	EXEC msdb.dbo.sp_delete_job @job_name = N'Check Mirroring Status of All Databases', 
	                            @delete_unused_schedule = 1, @delete_history = 1;
GO


BEGIN TRANSACTION
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories 
               WHERE name=N'Instance Level Job' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', 
     @type=N'LOCAL', @name=N'Instance Level Job'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=N'Check Mirroring Status of All Databases', 
@enabled=1, 
@notify_level_eventlog=0, 
@notify_level_email=0, 
@notify_level_netsend=0, 
@notify_level_page=0, 
@delete_level=0, 
@description=N'Check Mirroring Status of All Databases by 
               callingDBAdminCheckMirroringStatus in ServerMonitor database', 
@category_name=N'Instance Level Job', 
@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep 
        @job_id=@jobId, @step_name=N'Check Mirroring Status of All Databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.DBAdminCheckMirroringStatus;', 
		@database_name=N'ServerMonitor', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, 
        @name=N'Check Mirroring Status of All Databases', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140218, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'fc23c476-4218-46cb-94f3-51b7bf6d85ff'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


-- Create a new SQL Server Agent job called “Synchronize Mirroring Status” 
-- that simply calls the DBAdminSynchronizeMirroringStatus stored procedure
-- in response to a SQL Agent Alert
USE [msdb]
GO

IF EXISTS (SELECT name FROM msdb.dbo.sysjobs WHERE name = N'Synchronize Mirroring Status')
	EXEC msdb.dbo.sp_delete_job @job_name = N'Synchronize Mirroring Status', 
	@delete_unused_schedule=1, @delete_history = 1;
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories 
               WHERE name=N'Instance Level Job' AND category_class=1)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category 
		     @class=N'JOB', @type=N'LOCAL', @name=N'Instance Level Job'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Synchronize Mirroring Status', 
@enabled=1, 
@notify_level_eventlog=0, 
@notify_level_email=0, 
@notify_level_netsend=0, 
@notify_level_page=0, 
@delete_level=0, 
@description=N'Synchronize Mirroring Status calls the DBAdminSynchronizeMirroringStatus 
             stored procedure in the ServerMonitor database in response to a 
			 SQL Agent Alert. This job is enabled, but does not have a schedule by design.', 
@category_name=N'Instance Level Job', 
@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, 
        @step_name=N'Synchronize Mirroring Status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.DBAdminSynchronizeMirroringStatus;', 
		@database_name=N'ServerMonitor', 
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


-- Create two SQL Agent Alerts to detect automatic and manual mirroring state changes
-- that call the "Synchronize Mirroring Status" Agent Job
-- 8 is automatic, 7 is manual
-- These alerts use the following WMI queries:
/*
	SELECT * FROM Database_Mirroring_State_Change 
	WHERE DatabaseName = 'DatabaseName' AND State = 8  

	SELECT * FROM Database_Mirroring_State_Change 
	WHERE DatabaseName = 'DatabaseName' AND State = 7 
*/

USE [msdb];
GO

-- Change @OperatorName as needed
DECLARE @OperatorName sysname = N'SQLDBAGroup';

-- Change @CategoryName as needed
DECLARE @CategoryName sysname = N'SQL Server Agent Alerts';

-- Change @DatabaseName as needed
DECLARE @DatabaseName sysname = N'AdventureWorks';

DECLARE @JobName sysname = N'Synchronize Mirroring Status';

DECLARE @JobID uniqueidentifier = (SELECT job_id
                                   FROM msdb.dbo.sysjobs 
                                   WHERE name = @JobName);

-- Make sure you have an Agent Operator defined that matches the name you supplied
IF NOT EXISTS(SELECT * FROM msdb.dbo.sysoperators WHERE name = @OperatorName)
	BEGIN
		RAISERROR ('There is no SQL Operator with a name of %s' , 18 , 16 , @OperatorName);
		RETURN;
	END

-- Add Alert Category if it does not exist
IF NOT EXISTS (SELECT *
               FROM msdb.dbo.syscategories
               WHERE category_class = 2  -- ALERT
			   AND category_type = 3
               AND name = @CategoryName)
	BEGIN
		EXEC dbo.sp_add_category @class = N'ALERT', @type = N'NONE', @name = @CategoryName;
	END
  

-- Get the server name
DECLARE @ServerName sysname = (SELECT @@SERVERNAME);


-- Alert Names start with the name of the server 
DECLARE @AutomaticStateChangeAlertName sysname = @ServerName + 
        N' ' + @DatabaseName + N' Database Automatic Mirroring State Change';
DECLARE @ManualStateChangeAlertName sysname = @ServerName + 
        N' ' + @DatabaseName + N' Database Manual Mirroring State Change';

DECLARE @AutomaticWMIQuery nvarchar(512) = 
        N'SELECT * FROM Database_Mirroring_State_Change WHERE DatabaseName = ''' 
		+ @DatabaseName  + ''' AND State = 8';
DECLARE @ManualWMIQuery nvarchar(512) = 
        N'SELECT * FROM Database_Mirroring_State_Change WHERE DatabaseName = ''' 
		+ @DatabaseName  + ''' AND State = 7';


-- Database Automatic Mirroring State Change
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts 
               WHERE name = @AutomaticStateChangeAlertName)
	EXEC msdb.dbo.sp_add_alert @name = @AutomaticStateChangeAlertName, 
				  @message_id = 0, @severity = 0, @enabled = 1, 
				  @delay_between_responses = 0, @include_event_description_in = 1,
				  @category_name = @CategoryName,
				  @wmi_namespace=N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
				  @wmi_query= @AutomaticWMIQuery, 
				  @job_id = @JobID;


-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
		      FROM dbo.sysalerts AS sa
              INNER JOIN dbo.sysnotifications AS sn
              ON sa.id = sn.alert_id
              WHERE sa.name = @AutomaticStateChangeAlertName)
	BEGIN
		EXEC msdb.dbo.sp_add_notification @alert_name = @AutomaticStateChangeAlertName, 
		                       @operator_name = @OperatorName, @notification_method = 1;
	END

-- Database Manual Mirroring State Change
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = @ManualStateChangeAlertName)
	EXEC msdb.dbo.sp_add_alert @name = @ManualStateChangeAlertName, 
				  @message_id = 0, @severity = 0, @enabled = 1, 
				  @delay_between_responses = 0, @include_event_description_in = 1,
				  @category_name = @CategoryName,
				  @wmi_namespace = N'\\.\root\Microsoft\SqlServer\ServerEvents\MSSQLSERVER', 
				  @wmi_query = @ManualWMIQuery, 
				  @job_id = @JobID;


-- Add a notification if it does not exist
IF NOT EXISTS(SELECT *
		      FROM dbo.sysalerts AS sa
              INNER JOIN dbo.sysnotifications AS sn
              ON sa.id = sn.alert_id
              WHERE sa.name = @ManualStateChangeAlertName)
	BEGIN
		EXEC msdb.dbo.sp_add_notification @alert_name = @ManualStateChangeAlertName, 
		                                  @operator_name = @OperatorName, 
										  @notification_method = 1;
	END

GO
