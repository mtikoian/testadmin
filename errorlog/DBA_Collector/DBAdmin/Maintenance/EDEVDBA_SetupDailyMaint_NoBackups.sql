SET NOCOUNT ON

USE MASTER;

DECLARE @BackupDirectory nvarchar(max)
DECLARE @CreateJobs nvarchar(max)
DECLARE @Version numeric(18,10)
DECLARE @Error int
DECLARE @LogDirectory nvarchar(max)
DECLARE @Database nvarchar(max)

DECLARE @TokenServer nvarchar(max)
DECLARE @TokenJobID nvarchar(max)
DECLARE @TokenStepID nvarchar(max)
DECLARE @TokenDate nvarchar(max)
DECLARE @TokenTime nvarchar(max)

DECLARE @JobName nvarchar(max)
DECLARE @JobID varbinary(max)
DECLARE @JobStepName nvarchar(max)
DECLARE @JobStepCommand nvarchar(max)
DECLARE @ScheduleID int
DECLARE @OutputFile nvarchar(max)

DECLARE @InstName NVARCHAR(100),
        @RegKey NVARCHAR(MAX),
        @InstID NVARCHAR(30),
        @BackupDir NVARCHAR(256);

SET @Version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

IF IS_SRVROLEMEMBER('sysadmin') = 0
BEGIN
  RAISERROR('The server role SysAdmin is needed for the installation.',16,1)
  SET @Error = @@ERROR
END

IF @Version < 9
BEGIN
  RAISERROR('The solution is supported on SQL Server 2005, SQL Server 2008 and SQL Server 2008 R2.',16,1)
  SET @Error = @@ERROR
END

IF (SELECT [compatibility_level] FROM sys.databases WHERE database_id = DB_ID()) < 90
BEGIN
  RAISERROR('The database that you are creating the objects in has to be in compatibility_level 90 or 100.',16,1)
  SET @Error = @@ERROR
END

IF OBJECT_ID('tempdb..#Config') IS NOT NULL DROP TABLE #Config

CREATE TABLE #Config ([Name] nvarchar(max),
                      [Value] nvarchar(max))

DECLARE @ErrorLog TABLE (LogDate datetime,
                         ProcessInfo nvarchar(max),
                         ErrorText nvarchar(max))

-- Collect configuration information
INSERT INTO @ErrorLog (LogDate, ProcessInfo, ErrorText)
EXECUTE [master].dbo.sp_readerrorlog 0

IF @@ERROR <> 0
BEGIN
  RAISERROR('Error reading from the error log.',16,1)
  SET @Error = @@ERROR
END

INSERT INTO #Config ([Name], [Value])
SELECT 'LogDirectory', REPLACE(REPLACE(ErrorText,'Logging SQL Server messages in file ''',''),'\ERRORLOG''.','')
FROM @ErrorLog
WHERE ErrorText LIKE 'Logging SQL Server messages in file%'

IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
BEGIN
  RAISERROR('The log directory could not be found.',16,1)
  SET @Error = @@ERROR
END

INSERT INTO #Config ([Name], [Value])
VALUES('Database', DB_NAME(DB_ID()))

INSERT INTO #Config ([Name], [Value])
VALUES('Jobs', @CreateJobs)

INSERT INTO #Config ([Name], [Value])
VALUES('Error', CAST(@Error AS nvarchar))


-- Setup job variables / tokens

IF (SELECT CAST([Value] AS nvarchar) FROM #Config WHERE Name = 'Error') <> '0' OR (SELECT [Value] FROM #Config WHERE Name = 'Jobs') <> 'Y' OR SERVERPROPERTY('EngineEdition') = 4
BEGIN
  RETURN
END

SET @Version = CAST(LEFT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)),CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - 1) + '.' + REPLACE(RIGHT(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max))) - CHARINDEX('.',CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(max)))),'.','') AS numeric(18,10))

IF @Version >= 9.002047
BEGIN
  SET @TokenServer = '$' + '(ESCAPE_SQUOTE(SRVR))'
  SET @TokenJobID = '$' + '(ESCAPE_SQUOTE(JOBID))'
  SET @TokenStepID = '$' + '(ESCAPE_SQUOTE(STEPID))'
  SET @TokenDate = '$' + '(ESCAPE_SQUOTE(STRTDT))'
  SET @TokenTime = '$' + '(ESCAPE_SQUOTE(STRTTM))'
END
ELSE
BEGIN
  SET @TokenServer = '$' + '(SRVR)'
  SET @TokenJobID = '$' + '(JOBID)'
  SET @TokenStepID = '$' + '(STEPID)'
  SET @TokenDate = '$' + '(STRTDT)'
  SET @TokenTime = '$' + '(STRTTM)'
END

SELECT @LogDirectory = Value
FROM #Config
WHERE [Name] = 'LogDirectory'

SELECT @BackupDirectory = Value
FROM #Config
WHERE [Name] = 'BackupDirectory'

SELECT @Database = Value
FROM #Config
WHERE [Name] = 'Database'

SELECT @InstName = CASE CHARINDEX('\',@@SERVERNAME)
    WHEN 0 THEN 'MSSQLSERVER'
    ELSE SUBSTRING(@@SERVERNAME,CHARINDEX('\',@@SERVERNAME) + 1,1000)
    END;

SELECT @RegKey = 'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\';
EXEC master.sys.xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE', @key = @RegKey, @value_name = 'BackupDirectory', @value = @BackupDir OUTPUT;


-- Setup jobs --

-- EDEVDBA_DailyMaint --
SET @JobName = 'EDEV DBA Daily Maintenance Job'
SET @OutputFile = @LogDirectory + '\' + @JobName + '_' + @TokenDate + '_' + @TokenTime + '.txt'

IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE NAME = @JobName)
    EXEC msdb.dbo.sp_delete_job @job_name = @JobName, @delete_history = 0, @delete_unused_schedule = 1;

EXEC msdb.dbo.sp_add_job
    @job_name = @JobName,
    @enabled = 1,
    @description = 'EDev DBA Daily Maintenance',
    @owner_login_name = 'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_email_operator_name = 'EDEV_DBA',
    @job_id = @JobID OUTPUT;

EXEC msdb.dbo.sp_add_jobserver
    @job_id = @JobID;


SET @JobStepName = 'DatabaseIntegrityCheck - ALL_DATABASES'
SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = ''ALL_DATABASES'', @PhysicalOnly = ''Y''" -b'
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 1,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action = 3,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;
    
SET @JobStepName = 'IndexOptimize - ALL_DATABASES'
SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + 
                      ' -Q "EXECUTE [dbo].[IndexOptimize] @Databases = ''ALL_DATABASES'',' + 
                      ' @FragmentationLevel1 = 10,' +
                      ' @FragmentationLevel2 = 30,' +
                      ' @FragmentationLow_LOB = ''STATISTICS_UPDATE'',' +
                      ' @FragmentationLow_NonLOB = ''STATISTICS_UPDATE''' +
                      CASE WHEN SERVERPROPERTY('EngineEdition') = 3 THEN ', @FragmentationHigh_NonLOB = ''INDEX_REBUILD_ONLINE''' ELSE '' END + 
                      '" -b'
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 2,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action =3,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;
    
SET @JobStepName = 'sp_delete_backuphistory'
SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate" -b'
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 3,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action = 3,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;
    
SET @JobStepName = 'sp_purge_jobhistory'
SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate" -b'
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 4,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action = 3,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;

SET @JobStepName = 'Output File Cleanup'
SET @JobStepCommand = 'cmd /q /c "For /F "tokens=1 delims=" %v In (''ForFiles /P "' + @LogDirectory + '" /m *.txt /d -30 2^>^&1'') do if not "%v" == "ERROR: No files found with the specified search criteria." echo del "' + @LogDirectory + '"\%v& del "' + @LogDirectory + '"\%v"'
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 5,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action = 1,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;
    
SET @JobStepName = 'Mail Sent Item Cleanup'
SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d msdb -Q "DECLARE @CleanupDate DATETIME; SET @CleanupDate = DATEADD(dd,-30,GETDATE()); EXECUTE dbo.sysmail_delete_mailitems_sp @sent_before = @CleanupDate;"';
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 6,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action = 1,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;
    
SET @JobStepName = 'Cycle Error Logs'
SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d master -Q "EXEC sp_cycle_errorlog;"';
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 7,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action = 1,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;

exec msdb.dbo.sp_add_schedule
    @schedule_name = 'EDev DBA Daily Maintenance Schedule (Daily 9PM)',
    @enabled = 1,
    @freq_type = 8,
    @freq_interval = 127,
    @freq_recurrence_factor = 1,
    @active_start_time = '210000',
    @schedule_id = @ScheduleID OUTPUT;

exec msdb.dbo.sp_attach_schedule
    @job_id = @JobID,
    @schedule_id = @ScheduleID;

--SET @JobName03 = 'DatabaseBackup - USER_DATABASES - FULL'
--SET @JobCommand03 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'', @Directory = ' + ISNULL('N''' + REPLACE(@BackupDirectory,'''','''''') + '''','NULL') + ', @BackupType = ''FULL'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y''" -b'
--SET @OutputFile03 = @LogDirectory + '\DatabaseBackup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
--
--SET @JobName04 = 'DatabaseBackup - USER_DATABASES - LOG'
--SET @JobCommand04 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''USER_DATABASES'', @Directory = ' + ISNULL('N''' + REPLACE(@BackupDirectory,'''','''''') + '''','NULL') + ', @BackupType = ''LOG'', @Verify = ''Y'', @CleanupTime = 24, @CheckSum = ''Y''" -b'
--SET @OutputFile04 = @LogDirectory + '\DatabaseBackup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
--
--SET @JobName05 = 'DatabaseIntegrityCheck - SYSTEM_DATABASES'
--SET @JobCommand05 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = ''SYSTEM_DATABASES''" -b'
--SET @OutputFile05 = @LogDirectory + '\DatabaseIntegrityCheck_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
--
--
--
--SET @JobName08 = 'sp_delete_backuphistory'
--SET @JobCommand08 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate" -b'
--SET @OutputFile08 = @LogDirectory + '\sp_delete_backuphistory_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
--
--SET @JobName09 = 'sp_purge_jobhistory'
--SET @JobCommand09 = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_purge_jobhistory @oldest_date = @CleanupDate" -b'
--SET @OutputFile09 = @LogDirectory + '\sp_purge_jobhistory_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'
--
--SET @JobName10 = 'Output File Cleanup'
--SET @JobCommand10 = 'cmd /q /c "For /F "tokens=1 delims=" %v In (''ForFiles /P "' + @LogDirectory + '" /m *.txt /d -30 2^>^&1'') do if not "%v" == "ERROR: No files found with the specified search criteria." echo del "' + @LogDirectory + '"\%v& del "' + @LogDirectory + '"\%v"'
--SET @OutputFile10 = @LogDirectory + '\OutputFileCleanup_' + @TokenJobID + '_' + @TokenStepID + '_' + @TokenDate + '_' + @TokenTime + '.txt'