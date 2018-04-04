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
DECLARE @OutputDir nvarchar(max)
DECLARE @OutputFile nvarchar(max)

DECLARE @InstName NVARCHAR(100),
        @RegKey NVARCHAR(MAX),
        @InstID NVARCHAR(30),
        @BackupDir NVARCHAR(256),
        @SQL NVARCHAR(MAX);


BEGIN -- Metadata Gathering
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
  
  --Commented out section for error log file location, since we are going to log to table.
  --JF 2/13/2012
  --INSERT INTO @ErrorLog (LogDate, ProcessInfo, ErrorText)
  --EXECUTE [master].dbo.sp_readerrorlog 0

  --IF @@ERROR <> 0
  --BEGIN
  --  RAISERROR('Error reading from the error log.',16,1)
  --  SET @Error = @@ERROR
  --END

  --INSERT INTO #Config ([Name], [Value])
  --SELECT 'LogDirectory', REPLACE(REPLACE(ErrorText,'Logging SQL Server messages in file ''',''),'\ERRORLOG''.','')
  --FROM @ErrorLog
  --WHERE ErrorText LIKE 'Logging SQL Server messages in file%'

  --IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
  --BEGIN
  --  RAISERROR('The log directory could not be found.',16,1)
  --  SET @Error = @@ERROR
  --END

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
  
  SET @OutputDir = '\\abernas03\sqlbackup\AgentJobLog\' + @TokenServer;
  SET @OutputFile = @OutputDir + '\DailyMaint_' + @TokenDate + '_' + @TokenTime;
  

END -- Metadata gathering

BEGIN TRY -- Setup jobs --
  
  BEGIN TRANSACTION;

  BEGIN -- EDEVDBA_DailyMaint --
    SET @JobName = 'EDEV DBA Daily Maintenance Job (MSX)';

    IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE NAME = @JobName) BEGIN
  		-- Capture the current assigned job servers
  		SET @SQL =
  		(
  			SELECT	'EXEC msdb.dbo.sp_add_jobserver @job_name = ' + QUOTENAME(sj.name,'''') + ', @server_name = ' + QUOTENAME(sts.server_name,'''') + ';' + CHAR(10)
  			FROM	msdb.dbo.sysjobservers sjs
  						JOIN msdb.dbo.systargetservers sts
  							ON sjs.server_id = sts.server_id
  						JOIN msdb.dbo.sysjobs sj
  							ON sjs.job_id = sj.job_id
  			WHERE	sj.name = @JobName
  			FOR XML PATH('')
  		);
  		
  		PRINT @SQL;
  		
  		-- Delete the job
      EXEC msdb.dbo.sp_delete_job @job_name = @JobName, @delete_history = 0, @delete_unused_schedule = 1;
    END

    EXEC msdb.dbo.sp_add_job
        @job_name = @JobName,
        @enabled = 1,
        @description = 'EDev DBA Daily Maintenance (Master Server)',
        @owner_login_name = 'sa',
        @notify_level_eventlog = 2,
        @notify_level_email = 2,
        @notify_email_operator_name = 'MSXOperator',
        @job_id = @JobID OUTPUT;

    EXEC msdb.dbo.sp_add_jobserver
        @job_id = @JobID;

	  -- Removed step to create log directory if required
	  -- JF 4/3/2012
    --SET @JobStepName = 'Create Log Directory'
    --SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE master..xp_create_subdir ''' + @OutputDir + '''" -b';
    --EXEC msdb.dbo.sp_add_jobstep
    --    @job_id = @JobId,
    --    @step_id = 1,
    --    @step_name = @JobStepName,
    --    @subsystem = N'CMDEXEC',
    --    @command = @JobStepCommand,
    --    @on_success_action = 3,
    --    @on_fail_action = 2;
        
    SET @JobStepName = 'DatabaseIntegrityCheck - ALL_DATABASES'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = ''ALL_DATABASES'', @PhysicalOnly = ''Y'', @LogToTable=''Y''" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 2,
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
                          ' @LogToTable = ''Y'',' +
                          ' @FragmentationLevel1 = 10,' +
                          ' @FragmentationLevel2 = 30' +
                          -- Removed for new version of dbo.IndexOptimize
                          --' @FragmentationLow_LOB = ''STATISTICS_UPDATE'',' +
                          --' @FragmentationLow_NonLOB = ''STATISTICS_UPDATE''' +
                          --CASE WHEN SERVERPROPERTY('EngineEdition') = 3 THEN ', @FragmentationHigh_NonLOB = ''INDEX_REBUILD_ONLINE''' ELSE '' END + 
                          '" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 3,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action =3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;

    SET @JobStepName = 'DatabaseBackup - ALL_DATABASES - DIFF'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + 
					      ' -d ' + @Database + 
					      ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''ALL_DATABASES''' +  
					      ', @BackupType = ''DIFF'''+
					      ', @Verify = ''Y''' +
					      ', @LogToTable = ''Y''' + 
					      ', @CleanupTime = 334' +
					      ', @CheckSum = ''Y''" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 4,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action = 3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;
    
	--Disabled backup file cleanup (will be handled natively)
	--JF 2/13/2012
    --SET @JobStepName = 'Backup File Cleanup'
    --SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + 
				--	      ' -d ' + @Database + 
				--	      ' -Q "EXECUTE [dbo].[p_BackupFileMaintenance] ' +  
				--	      '@pi_backup_type = ''DIFF'';" -b'
    --EXEC msdb.dbo.sp_add_jobstep
    --    @job_id = @JobId,
    --    @step_id = 4,
    --    @step_name = @JobStepName,
    --    @subsystem = N'CMDEXEC',
    --    @command = @JobStepCommand,
    --    @on_success_action = 3,
    --    @on_fail_action = 2,
    --    @output_file_name = @OutputFile,
    --    @flags = 2;
        
    SET @JobStepName = 'sp_delete_backuphistory'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 5,
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
        --@step_id = 6,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action = 3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;

    -- Commented since delete command doesn't support UNC paths
    -- JF 3/30/2012
    --SET @JobStepName = 'Output File Cleanup'
    --SET @JobStepCommand = 'cmd /q /c "For /F "tokens=1 delims=" %v In (''ForFiles /P "' + @OutputDir + '" /m *.txt /d -30 2^>^&1'') do if not "%v" == "ERROR: No files found with the specified search criteria." echo del "' + @OutputDir + '"\%v& del "' + @OutputDir + '"\%v"'
    --EXEC msdb.dbo.sp_add_jobstep
    --    @job_id = @JobId,
    --    @step_id = 7,
    --    @step_name = @JobStepName,
    --    @subsystem = N'CMDEXEC',
    --    @command = @JobStepCommand,
    --    @on_success_action = 3,
    --    @on_fail_action = 2,
    --    @output_file_name = @OutputFile,
    --    @flags = 2;
        

    SET @JobStepName = 'Mail Sent Item Cleanup'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d msdb -Q "DECLARE @CleanupDate DATETIME; SET @CleanupDate = DATEADD(dd,-30,GETDATE()); EXECUTE dbo.sysmail_delete_mailitems_sp @sent_before = @CleanupDate;"';
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 8,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action = 3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;
        
    SET @JobStepName = 'Cycle Error Logs'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d master -Q "EXEC sp_cycle_errorlog;"';
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 9,
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
        @freq_interval = 63,
        @freq_recurrence_factor = 1,
        @active_start_time = '210000',
        @schedule_id = @ScheduleID OUTPUT;

    exec msdb.dbo.sp_attach_schedule
        @job_id = @JobID,
        @schedule_id = @ScheduleID;
        
    -- Add all original servers back to the job schedule
    EXEC msdb.dbo.sp_delete_jobserver @job_name=@JobName, @server_name = @@SERVERNAME
    EXEC sp_executesql @SQL;
    
  END -- Daily Maintenance

  
  BEGIN-- EDEV DBA Weekend Maintenance
    SET @JobName = 'EDEV DBA Weekend Maintenance Job (MSX)'
    
    SET @JobID = NULL

    IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE NAME = @JobName) BEGIN
  		-- Capture the current assigned job servers
  		SET @SQL =
  		(
  			SELECT	'EXEC msdb.dbo.sp_add_jobserver @job_name = ' + QUOTENAME(sj.name,'''') + ', @server_name = ' + QUOTENAME(sts.server_name,'''') + ';' + CHAR(10)
  			FROM	msdb.dbo.sysjobservers sjs
  						JOIN msdb.dbo.systargetservers sts
  							ON sjs.server_id = sts.server_id
  						JOIN msdb.dbo.sysjobs sj
  							ON sjs.job_id = sj.job_id
  			WHERE	sj.name = @JobName
  			FOR XML PATH('')
  		);
  		
  		PRINT @SQL;
    
  		-- Delete the job
      EXEC msdb.dbo.sp_delete_job @job_name = @JobName, @delete_history = 0, @delete_unused_schedule = 1;

    END

    EXEC msdb.dbo.sp_add_job
        @job_name = @JobName,
        @enabled = 1,
        @description = 'EDev DBA Weekend Maintenance (Master Server)',
        @owner_login_name = 'sa',
        @notify_level_eventlog = 2,
        @notify_level_email = 2,
        @notify_email_operator_name = 'MSXOperator',
        @job_id = @JobID OUTPUT;

    EXEC msdb.dbo.sp_add_jobserver
        @job_id = @JobID;


	  -- Removed step to create log directory
	  -- JF 4/3/2012
    --SET @JobStepName = 'Create Log Directory'
    --SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE master..xp_create_subdir ''' + @OutputDir + '''" -b';
    --EXEC msdb.dbo.sp_add_jobstep
    --    @job_id = @JobId,
    --    @step_id = 1,
    --    @step_name = @JobStepName,
    --    @subsystem = N'CMDEXEC',
    --    @command = @JobStepCommand,
    --    @on_success_action = 3,
    --    @on_fail_action = 2;

    SET @JobStepName = 'DatabaseIntegrityCheck - ALL_DATABASES'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + @Database + ' -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = ''ALL_DATABASES'', @PhysicalOnly = ''Y'', @LogToTable = ''Y''" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 2,
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
            						  ' @LogToTable = ''Y'',' +
                          ' @FragmentationLevel1 = 1,' +
                          ' @FragmentationLevel2 = 2' +
                          -- Removed for new version of dbo.IndexOptimize
                          --' @FragmentationLow_LOB = ''STATISTICS_UPDATE'',' +
                          --' @FragmentationLow_NonLOB = ''STATISTICS_UPDATE''' +
                          --CASE WHEN SERVERPROPERTY('EngineEdition') = 3 THEN ', @FragmentationHigh_NonLOB = ''INDEX_REBUILD_ONLINE''' ELSE '' END + 
                          '" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 3,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action =3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;

    SET @JobStepName = 'DatabaseBackup - ALL_DATABASES - FULL'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + 
					      ' -d ' + @Database + 
					      ' -Q "EXECUTE [dbo].[DatabaseBackup] @Databases = ''ALL_DATABASES''' +  
					      ', @BackupType = ''FULL'''+
					      ', @CleanupTime = 334' + 
					      ', @LogToTable = ''Y''' +
					      ', @Verify = ''Y''' +
					      ', @CheckSum = ''Y''" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 4,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action = 3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;
  
	-- Disabled file cleanup, will be done natively
	-- JF 2/13/2012
    --SET @JobStepName = 'Backup File Cleanup'
    --SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + 
				--	      ' -d ' + @Database + 
				--	      ' -Q "EXECUTE [dbo].[p_BackupFileMaintenance] ' +  
				--	      '@pi_backup_type = ''FULL'';" -b'
    --EXEC msdb.dbo.sp_add_jobstep
    --    @job_id = @JobId,
    --    @step_id = 4,
    --    @step_name = @JobStepName,
    --    @subsystem = N'CMDEXEC',
    --    @command = @JobStepCommand,
    --    @on_success_action = 3,
    --    @on_fail_action = 2,
    --    @output_file_name = @OutputFile,
    --    @flags = 2;
              
    SET @JobStepName = 'sp_delete_backuphistory'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d ' + 'msdb' + ' -Q "DECLARE @CleanupDate datetime SET @CleanupDate = DATEADD(dd,-30,GETDATE()) EXECUTE dbo.sp_delete_backuphistory @oldest_date = @CleanupDate" -b'
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 5,
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
        --@step_id = 6,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action = 3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;

	  -- Commented since delete command doesn't support UNC paths
	  -- JF 3/30/2012
    --SET @JobStepName = 'Output File Cleanup'
    --SET @JobStepCommand = 'cmd /q /c "For /F "tokens=1 delims=" %v In (''ForFiles /P "' + @OutputDir + '" /m *.txt /d -30 2^>^&1'') do if not "%v" == "ERROR: No files found with the specified search criteria." echo del "' + @OutputDir + '"\%v& del "' + @OutputDir + '"\%v"'
    --EXEC msdb.dbo.sp_add_jobstep
    --    @job_id = @JobId,
    --    @step_id = 7,
    --    @step_name = @JobStepName,
    --    @subsystem = N'CMDEXEC',
    --    @command = @JobStepCommand,
    --    @on_success_action = 3,
    --    @on_fail_action = 2,
    --    @output_file_name = @OutputFile,
    --    @flags = 2;
        

    SET @JobStepName = 'Mail Sent Item Cleanup'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d msdb -Q "DECLARE @CleanupDate DATETIME; SET @CleanupDate = DATEADD(dd,-30,GETDATE()); EXECUTE dbo.sysmail_delete_mailitems_sp @sent_before = @CleanupDate;"';
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 8,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action = 3,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;
        
    SET @JobStepName = 'Cycle Error Logs'
    SET @JobStepCommand = 'sqlcmd -E -S ' + @TokenServer + ' -d master -Q "EXEC sp_cycle_errorlog;"';
    EXEC msdb.dbo.sp_add_jobstep
        @job_id = @JobId,
        --@step_id = 9,
        @step_name = @JobStepName,
        @subsystem = N'CMDEXEC',
        @command = @JobStepCommand,
        @on_success_action = 1,
        @on_fail_action = 2,
        @output_file_name = @OutputFile,
        @flags = 2;

    exec msdb.dbo.sp_add_schedule
        @schedule_name = 'EDev DBA Weekend Maintenance Schedule (Sat Sun 1PM)',
        @enabled = 1,
        @freq_type = 8,
        @freq_interval = 64,
        @freq_recurrence_factor = 1,
        @active_start_time = '130000',
        @schedule_id = @ScheduleID OUTPUT;

    exec msdb.dbo.sp_attach_schedule
        @job_id = @JobID,
        @schedule_id = @ScheduleID;
    
    -- Add all original servers back to the job schedule
    EXEC msdb.dbo.sp_delete_jobserver @job_name=@JobName, @server_name = @@SERVERNAME
    EXEC sp_executesql @SQL;
  
  END -- End weekend maint
    

  COMMIT TRANSACTION;
  
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    
    DECLARE @ErrorMessage NVARCHAR(2000), @ErrorSeverity INT;
    SET @ErrorMessage = ERROR_MESSAGE();
    SET @ErrorSeverity = ERROR_SEVERITY();
    
    RAISERROR (@ErrorMessage,@ErrorSeverity,1);
END CATCH
 