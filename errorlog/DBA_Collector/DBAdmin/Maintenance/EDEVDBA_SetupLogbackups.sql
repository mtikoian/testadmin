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
SET @JobName = 'EDEV DBA Log Backup Job'
SET @OutputFile = @LogDirectory + '\' + @JobName + '_' + @TokenDate + '_' + @TokenTime + '.txt'

IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE NAME = @JobName)
    EXEC msdb.dbo.sp_delete_job @job_name = @JobName, @delete_history = 0, @delete_unused_schedule = 1;

EXEC msdb.dbo.sp_add_job
    @job_name = @JobName,
    @enabled = 1,
    @description = 'EDev DBA Log Backups',
    @owner_login_name = 'sa',
    @notify_level_eventlog = 2,
    @notify_level_email = 2,
    @notify_email_operator_name = 'EDEV_DBA',
    @job_id = @JobID OUTPUT;

EXEC msdb.dbo.sp_add_jobserver
    @job_id = @JobID;


SET @JobStepName = 'DatabaseBackup - ALL_DATABASES - LOG'
SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + 
					  ' -d ' + @Database + 
					  ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''ALL_DATABASES''' +  
					  ', @Directory = ' + ISNULL('N''' + REPLACE(@BackupDirectory,'''','''''') + '''','NULL') + 
					  ', @BackupType = ''LOG'''+
					  ', @Verify = ''Y''' +
					  ', @CleanupTime = 12' +
					  ', @CheckSum = ''Y''" -b'
EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 1,
    @step_name = @JobStepName,
    @subsystem = N'CMDEXEC',
    @command = @JobStepCommand,
    @on_success_action = 1,
    @on_fail_action = 2,
    @output_file_name = @OutputFile,
    @flags = 2;
    

exec msdb.dbo.sp_add_schedule
    @schedule_name = 'EDev DBA Log Backup Schedule (Every 15 minutes)',
    @enabled = 1,
    @freq_type = 4,
    @freq_interval = 1,
    @freq_subday_type = 4,
    @freq_subday_interval = 15,
    @schedule_id = @ScheduleID OUTPUT;

exec msdb.dbo.sp_attach_schedule
    @job_id = @JobID,
    @schedule_id = @ScheduleID;
