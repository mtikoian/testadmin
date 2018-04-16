USE [master]
GO
SET NOCOUNT ON

PRINT 'SCAN DATE:                          ' + CONVERT(varchar(30), GETDATE(), 109)
PRINT 'SCRIPT BASED ON STANDARDS:          http://sharepoint.auth.wellpoint.com/sites/WDBS_SQLServer/Steve/Proposed%20Standards%20Queue/SQL%20Server%202008%20Standards%20Version%201.00.00.docx '
PRINT ''

-- BEGIN CONSTANTS

	DECLARE @MinimumSQLVersion				varchar(25)
			,@MinimumSQLSP					varchar(5)
			,@CollationStd					varchar(50)
			,@TCPProtocolEnabled			bit
			
			,@MaxMemPercentPerPhys			money
			,@IndexCreateMemory				int
			,@MinMemoryPerQuery				int
			
			,@MaxWorkerThreads				int
			,@PriorityBoost					bit
			,@LightWeightPooling			bit
			
			,@WindowsAuthentication			bit
			,@LoginAuditing					tinyint
			,@CommonCriteriaCompliance		bit
			,@C2AuditMode					bit
			,@CrossDBChaining				bit
			
			,@MaxConcurrentConnections		smallint
			,@QueryGovernorCostLimit		int
			,@ImplicitTransactions			bit
			,@CursorCloseOnCommit			bit
			,@ANSIWarnings					bit
			,@ANSIPadding					bit
			,@ANSINulls						bit
			,@ArithmeticAbort				bit
			,@ArithmeticIgnore				bit
			,@QuotedIdentifier				bit
			,@NoCount						bit
			,@ANSINullDefaultOn				bit
			,@ANSINullDefaultOff			bit
			,@ConcatenateNullYieldsNull		bit
			,@NumericRoundAbort				bit
			,@XactAbort						bit		
			,@RemoteAccess					bit
			,@RemoteQueryTimeout			int
			,@RemoteProcTrans				bit
			
			,@IndexFillFactor				tinyint			
			,@TapeBackupWaitIndefinitely	smallint
			,@DefaultBackupRetentionDays	smallint			
			,@CompressBackup				bit
			,@RecoveryInterval				smallint
			
			,@FileStreamAccessLevel			tinyint
			,@AllowTriggersToFireOthers		bit
			,@BlockedProcessThreshold		int
			,@CursorThreshold				int
			,@DefaultFullTextLang			int
			,@DefaultLanguage				smallint
			-- ,@FullTextUpgradeOption			tinyint Unable to retrieve this info
			,@MaxTextReplicationSize		int
			,@OptimizeForAdHocWorkloads		bit
			,@ScanForStartupProcs			bit
			,@TwoDigitYearCutoff			smallint
			,@NetworkPacketSize				int
			,@RemoteLoginTimeout			int
			,@CostThresholdForParallelism	smallint
			,@Locks							int
			,@MaxDegreeofParallelism		tinyint
			,@QueryWait						int
			

			,@PolicyMgmtEnabled				bit
			,@DataCollectionConfigured		bit
			,@ResourceGovernorEnabled		bit
			,@SQLServerLogs					smallint
			,@DatabaseMailEnabled			bit
						
	-- GENERAL 			
	SET @MinimumSQLVersion = '10.0.2531.0' 		
	SET @MinimumSQLSP = 'SP1'		
	SET @CollationStd = 'SQL_Latin1_General_CP1_CI_AS'
	SET @TCPProtocolEnabled = 1
	
	-- MEMORY
	SET @MaxMemPercentPerPhys = 0.90
	SET @IndexCreateMemory = 0
	SET @MinMemoryPerQuery = 1024
	
	-- PROCESSORS
	SET @MaxWorkerThreads = 0
	SET @PriorityBoost = 0
	SET @LightWeightPooling = 0
	
	-- SECURITY
	SET @WindowsAuthentication = 1
	SET @LoginAuditing = 2 -- 0 for none, 1 for Successful, 2 for fail and 3 for Both
	SET @CommonCriteriaCompliance = 0
	SET @C2AuditMode = 0
	SET @CrossDBChaining = 0
	
	-- CONNECTIONS
	SET @MaxConcurrentConnections = 0
	SET @QueryGovernorCostLimit = 0
	
	SET @ImplicitTransactions = 0
	SET @CursorCloseOnCommit = 0
	SET @ANSIWarnings = 0
	SET @ANSIPadding = 0
	SET @ANSINulls = 0
	SET @ArithmeticAbort = 0
	SET @ArithmeticIgnore = 0
	SET @QuotedIdentifier = 0
	SET @NoCount = 0
	SET @ANSINullDefaultOn = 0
	SET @ANSINullDefaultOff = 0
	SET @ConcatenateNullYieldsNull = 0
	SET @NumericRoundAbort = 0
	SET @XactAbort = 0
	SET @RemoteAccess = 0
	SET @RemoteQueryTimeout = 600
	SET @RemoteProcTrans = 0

	-- DATABASE SETTINGS		
	SET @IndexFillFactor = 0
	SET @TapeBackupWaitIndefinitely = -1 -- -1 is Wait Indefinitely, 0 is Try Once, any # > 0 is Try For 
	SET @DefaultBackupRetentionDays = 0
	SET @CompressBackup = 0
	SET @RecoveryInterval = 0
	
	-- ADVANCE 
	SET @FileStreamAccessLevel = 0 -- 0 is Disabled, 1 is T-SQL access enabled, 2 is Full access enabled
	SET @AllowTriggersToFireOthers = 1
	SET @BlockedProcessThreshold = 0 
	SET @CursorThreshold = -1
	SET @DefaultFullTextLang = 1033
	SET @DefaultLanguage = 0 -- 0 is English, query sys.langauges to get the other languages
	-- SET @FullTextUpgradeOption = 0 -- 0 is Rebuild, 1 is Reset and 2 is Import
	SET @MaxTextReplicationSize = 65536
	SET @OptimizeForAdHocWorkloads = 0
	SET @ScanForStartupProcs = 0
	SET @TwoDigitYearCutoff	= 2049
	SET @NetworkPacketSize = 4096
	SET @RemoteLoginTimeout = 20
	SET @CostThresholdForParallelism = 5
	SET @Locks = 0
	SET @MaxDegreeofParallelism = 0
	SET @QueryWait = -1

	-- CONFIGURABLE FEATURES
	SET @PolicyMgmtEnabled = 1
	SET @DataCollectionConfigured = 0
	SET @ResourceGovernorEnabled = 0
	SET @SQLServerLogs = 6
	SET @DatabaseMailEnabled = 0
	
-- END CONSTANTS


DECLARE		@WindowsVerison			varchar(128)
			,@PhysicalCPUCount		tinyint
			,@LogicalCPUCount		smallint
			,@PhysicalMemory		int
			,@ApproxStartDate		datetime
			,@SValue				nvarchar(1024)
			,@NValue				int
			,@SQLPath				varchar(256)
			,@DefaultDataPath		varchar(256)
			,@DefaultLogPath		varchar(256)
			,@Command				nvarchar(4000)
			,@ReturnValue			int
			,@DetailDomainName		varchar(128)
			,@IPInfo				varchar(5)
			,@Key					varchar(128)
			
			,@Instance				varchar(128)
			,@ServiceName			varchar(128)			
			,@ServiceInstanceName	varchar(256)
			,@ReturnCode			int
			,@StartupInfo			varchar(30)
			,@ServiceAccount		AS varchar(128)
			,@DisplayName			varchar(256)
			,@BinaryPath			varchar(1024)
			,@StartupType			int

			,@64bit					bit
			,@MinMemory				int
			,@MaxMemory				int
	

-- BEGIN INITIALIZE VARIABLE

	SET @Instance = CAST(SERVERPROPERTY('InstanceName') AS varchar(128))

	IF CAST(ISNULL(SERVERPROPERTY('Edition'), 'NULL') AS varchar(128)) LIKE '%64-bit%'
		SET @64bit = 1
	ELSE
		SET @64bit = 0
	

	SELECT		@MinMemory = CAST(value AS int)
	FROM		sys.configurations WITH (NOLOCK)
	WHERE		name = 'min server memory (MB)'

	SELECT		@MaxMemory = CAST(value AS int)
	FROM		sys.configurations WITH (NOLOCK)
	WHERE		name = 'max server memory (MB)'
-- END INITIALIZE VARIABLE
			
--
IF LEFT(CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(25)), 2) <> '10'
	PRINT '*** THIS SCRIPT CAN ONLY BE RUN ON SQL SERVER 2008 ***'
ELSE
	BEGIN
		PRINT 'BEGIN SQL SERVER INFORMATION' 
			CREATE TABLE #ServerInfo
			(
				Id					int
				,Name				varchar(256)
				,InternalValue		int
				,Character_Value	varchar(2000)
			)

			INSERT INTO #ServerInfo
			EXECUTE master.dbo.xp_msver 

			SELECT		@WindowsVerison = ISNULL(Character_Value, '')
			FROM		#ServerInfo
			WHERE		Name = 'WindowsVersion'

			SELECT  @PhysicalCPUCount = cpu_count / hyperthread_ratio 
			FROM    sys.dm_os_sys_info;

			SELECT  @LogicalCPUCount = cpu_count
			FROM    sys.dm_os_sys_info;

			SELECT		@PhysicalMemory = ISNULL(InternalValue, '')
			FROM		#ServerInfo
			WHERE		Name = 'PhysicalMemory'

			SELECT		@ApproxStartDate = crdate
			FROM		master.dbo.sysdatabases
			WHERE		name = 'tempdb'

			PRINT '    MachineName:                    ' + CAST(ISNULL(SERVERPROPERTY('MachineName'), 'NULL') AS varchar(128))

			SET @DetailDomainName = NULL

			EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
										,'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
										,'Domain'
										,@DetailDomainName OUTPUT

			PRINT '    Domain:                         ' +  ISNULL(@DetailDomainName, 'Unable to retrieve Domain Info')
			PRINT ''
			PRINT '    IP Info:'

			SET @NValue = NULL

			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
													,'Enabled'
													,@NValue OUTPUT
													,'no_output'

			PRINT '        TCP/IP Protocol Enabled:    '  + CASE WHEN @NValue = 1 THEN 'Yes' ELSE 'No' END
		
			IF @NValue <> @TCPProtocolEnabled 
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE WHEN @TCPProtocolEnabled = 1 THEN 'Yes' ELSE 'No' END

			SET @NValue = NULL

			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
													,'ListenOnAllIPs'
													,@NValue OUTPUT
													,'no_output'
													
			PRINT '        ListenOnAllIPs:             '  + CASE WHEN @NValue = 1 THEN 'Yes' ELSE 'No' END
			PRINT ''

			CREATE TABLE #IPList
			(
				IPInfo	varchar(5)
			)

			INSERT INTO #IPList
			EXECUTE xp_instance_regenumkeys 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp'

			DECLARE CURSOR_IPINFO CURSOR FAST_FORWARD
			FOR
				SELECT		IPInfo 
				FROM		#IPList
				ORDER BY	1

			OPEN CURSOR_IPINFO

			FETCH FROM CURSOR_IPINFO 
			INTO @IPInfo

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @Key = 'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\' + @IPInfo	
				
				PRINT '        ' + @IPInfo 

				SET @SValue = NULL
				SET @NValue = NULL

				EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
														,@Key
														,'IpAddress'
														,@SValue OUTPUT
														,'no_output'

				IF @SValue IS NOT NULL
					PRINT '          IP Address:               ' + @SValue

				SET @NValue = NULL

				EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
														,@Key
														,'Active'
														,@NValue OUTPUT
														,'no_output'
				
				PRINT '          Active:                   ' + CASE WHEN @NValue = 1 THEN 'Yes' ELSE 'No' END										

				SET @NValue = NULL

				EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
														,@Key
														,'Enabled'
														,@NValue OUTPUT
														,'no_output'

				PRINT '          Enabled:                  ' + CASE WHEN @NValue = 1 THEN 'Yes' ELSE 'No' END										

				SET @SValue = NULL

				EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
														,@Key
														,'TcpDynamicPorts'
														,@SValue OUTPUT
														,'no_output'

				PRINT '          DynamicPort:              ' + ISNULL(@SValue, '')

				SET @SValue = NULL

				EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
														,@Key
														,'TcpPort'
														,@SValue OUTPUT
														,'no_output'

				PRINT '          TcpPort:                  ' + ISNULL(@SValue, '')
				
				FETCH FROM CURSOR_IPINFO 
				INTO @IPInfo
			END

			CLOSE CURSOR_IPINFO
			DEALLOCATE CURSOR_IPINFO 

			DROP TABLE #IPList

			PRINT ''
			PRINT '    WindowsVersion:                 ' +  @WindowsVerison
			PRINT '    PhysicalCPU:                    ' +  CAST(@PhysicalCPUCount AS varchar(128))
			PRINT '    LogicalCPU:                     ' +  CAST(@LogicalCPUCount AS varchar(128))
			PRINT '    PhysicalMemory:                 ' +  CAST(@PhysicalMemory AS varchar(128))
			PRINT ''
			PRINT '    SQLServer:                      ' + CAST(ISNULL(SERVERPROPERTY('ServerName'), 'NULL') AS varchar(128))
			PRINT '    InstanceName:                   ' + @Instance
			PRINT '    Approx Start Date:              ' + CONVERT(varchar(35), @ApproxStartDate, 109)
			PRINT '    SQL Edition:                    ' + CAST(ISNULL(SERVERPROPERTY('Edition'), 'NULL') AS varchar(128))

			PRINT '    ProductVersion:                 ' + CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(25))

			IF @MinimumSQLVersion > CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(25)) 
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @MinimumSQLVersion 
																		
			PRINT '    ProductLevel:                   ' + CAST(ISNULL(SERVERPROPERTY('ProductLevel'), 'NULL') AS varchar(5))

			IF @MinimumSQLSP > CAST(ISNULL(SERVERPROPERTY('ProductLevel'), 'NULL') AS varchar(5))
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @MinimumSQLSP 
																   
			PRINT '    Collation:                      ' + CAST(ISNULL(SERVERPROPERTY('Collation'), 'NULL') AS varchar(128))
			
			IF @CollationStd <> CAST(ISNULL(SERVERPROPERTY('Collation'), 'NULL') AS varchar(128))
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @CollationStd
				
			PRINT '    Character Set:                  ' + CAST(ISNULL(SERVERPROPERTY('SqlCharSetName'), 'NULL') AS varchar(128))
			PRINT '    Sort Order:                     ' + CAST(ISNULL(SERVERPROPERTY('SqlSortOrderName'), 'NULL') AS varchar(128))
			PRINT '    Is Clustered:                   ' + CAST(ISNULL(SERVERPROPERTY('IsClustered'), 'NULL') AS varchar(128))
			PRINT ''

			SET @SValue = NULL
			
			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
													,'FeatureList'
													,@SValue OUTPUT
													,'no_output'
													
			PRINT '    Feature List:                   ' + ISNULL(@SValue, '')

			PRINT ''

			SET @SValue = NULL
			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
													,'SQLProgramDir'
													,@SValue OUTPUT
													,'no_output'
													
			PRINT '    SQL Program Dir:                ' + ISNULL(@SValue, '')

			SET @SValue = NULL
			
			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
													,'SQLPath'
													,@SValue OUTPUT
													,'no_output'
													
			PRINT '    SQL Path:                       ' + ISNULL(@SValue, '')

			SET @SValue = NULL
			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
													,'SQLBinRoot'
													,@SValue OUTPUT
													,'no_output'
													
			PRINT '    SQL Binary Dir:                 ' + ISNULL(@SValue, '')
			PRINT ''

			SET @SQLPath = NULL
			SET @DefaultDataPath = NULL
			SET @DefaultLogPath = NULL

			EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
												,N'SOFTWARE\Microsoft\MSSQLServer\Setup'
												,N'SQLPath'
												,@SQLPath OUTPUT


			EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
												,N'Software\Microsoft\MSSQLServer\MSSQLServer'
												,N'DefaultData'
												,@DefaultDataPath OUTPUT
												,NO_OUTPUT


			EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
												,N'Software\Microsoft\MSSQLServer\MSSQLServer'
												,N'DefaultLog'
												,@DefaultLogPath OUTPUT
												,NO_OUTPUT

			IF RIGHT(@SQLPath, 1) <> '\'
				SET @SQLPath = @SQLPath + '\'

			SET @SQLPath = @SQLPath
			SET @DefaultDataPath = ISNULL(@DefaultDataPath, @SQLPath + 'DATA\')
			SET @DefaultLogPath = ISNULL(@DefaultLogPath, @SQLPath + 'DATA\')

			PRINT '    Default Data Dir:               ' + @DefaultDataPath
			PRINT '    Default Log Dir:                ' + @DefaultLogPath


		PRINT 'END SQL SERVER INFORMATION' 
		PRINT ''

		DROP TABLE #ServerInfo

		PRINT 'BEGIN SERVICES INFORMATION'

			CREATE TABLE #Services
			(
				Name			varchar(128)
				,DefaultName	varchar(128)
				,InstanceName	varchar(128)
			)

			CREATE TABLE #ServicesKeys
			(
				KeyName		varchar(128)
			)

			INSERT INTO #ServicesKeys
			EXECUTE xp_instance_regenumkeys N'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\Services\'

			INSERT INTO #Services VALUES ('SQL Service', 'MSSQLSERVER', 'MSSQL$<instance>')
			INSERT INTO #Services VALUES ('SQL Agent', 'SQLSERVERAGENT', 'SQLAgent$<instance>')
			INSERT INTO #Services VALUES ('Analysis Services', 'MSSQLServerOLAPService', 'MSOLAP$<instance>')
			INSERT INTO #Services VALUES ('Reporting Services', 'ReportServer', 'ReportServer$<instance>') 
			INSERT INTO #Services VALUES ('Integration Services', 'MsDtsServer', 'MsDtsServer')
			INSERT INTO #Services VALUES ('SQL Browser', 'SQLBrowser', 'SQLBrowser')
			INSERT INTO #Services VALUES ('Full Text Search Engine', 'MSFTESQL', 'MSFTESQL$<instance>') 
			INSERT INTO #Services VALUES ('SQL Full-text Filter Daemon Launcher', 'MSSQLFDLauncher', 'MSSQLFDLauncher$<instance>')
			INSERT INTO #Services VALUES ('SQL Server AD Helper', 'MSSQLServerADHelper', 'MSSQLServerADHelper')
			INSERT INTO #Services VALUES ('SQL VSS Writer', 'SQLWriter', 'SQLWriter')				
			INSERT INTO #Services VALUES ('Distributed Transaction Coordinator', 'MSDTC', 'MSDTC')				
			INSERT INTO #Services VALUES ('COM+ System Application', 'COMSysApp', 'COMSysApp')

			DECLARE CURSOR_SERVICES CURSOR FAST_FORWARD
			FOR
				SELECT		A.Name
							,CASE WHEN LTRIM(RTRIM(ISNULL(@Instance, ''))) = ''
									THEN A.DefaultName 
									ELSE REPLACE(A.InstanceName, '<instance>', @Instance)
							   END
				FROM		#Services A
								JOIN #ServicesKeys B ON CASE WHEN LTRIM(RTRIM(ISNULL(@Instance, ''))) = ''
															THEN A.DefaultName 
															ELSE REPLACE(A.InstanceName, '<instance>', @Instance)
														END = B.KeyName
				ORDER BY	A.Name

			OPEN CURSOR_SERVICES

			FETCH NEXT FROM CURSOR_SERVICES
			INTO @ServiceName, @ServiceInstanceName

			WHILE @@FETCH_STATUS = 0
			BEGIN 			
				PRINT '    Querying status of ' + @ServiceInstanceName
								   
				SET @Key = N'SYSTEM\CurrentControlSet\Services\' + @ServiceInstanceName
				
				SET @DisplayName = NULL
				SET @BinaryPath = NULL
				SET @ServiceAccount = NULL
				SET @StartupType = NULL
				
				EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
											,@Key
											,N'DisplayName'
											,@DisplayName OUTPUT

				
				EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
											,@Key
											,N'ImagePath'
											,@BinaryPath OUTPUT

				EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
											,@Key
											,N'ObjectName'
											,@ServiceAccount OUTPUT
											
				EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
											,@Key
											,N'Start' --case [StartupType] when (0) then 'Boot' (1) then 'System', (2) then 'Automatic' when (3) then 'Manual' when (4) then 'Disable'  end
											,@StartupType OUTPUT


				SET @StartupInfo = CASE @StartupType
										WHEN 0 THEN 'Boot'
										WHEN 1 THEN 'System'
										WHEN 2 THEN 'Automatic'
										WHEN 3 THEN 'Manual'
										WHEN 4 THEN 'Disabled'
										ELSE 'Unknown'
								   END

				PRINT '      Display Name:                 ' + ISNULL(@DisplayName, '')
				PRINT '        Service Account:            ' + ISNULL(@ServiceAccount, '')
				PRINT '        Startup Type:               ' + CASE ISNULL(@StartupType, '')
																								WHEN 0 THEN 'Boot'
																			  					WHEN 1 THEN 'System'
																								WHEN 2 THEN 'Automatic'
																								WHEN 3 THEN 'Manual'
																								WHEN 4 THEN 'Disabled'
																								ELSE 'Unknown'
																							  END
				PRINT '        Binary Path:                ' + ISNULL(@BinaryPath, '')
				PRINT ''

				FETCH NEXT FROM CURSOR_SERVICES
				INTO @ServiceName, @ServiceInstanceName
			END

			CLOSE CURSOR_SERVICES
			DEALLOCATE CURSOR_SERVICES

			DROP TABLE #Services
			DROP TABLE #ServicesKeys

		PRINT 'END SERVICES INFORMATION'
		PRINT ''

		PRINT 'BEGIN SQL CONFIG INFORMATION'

			SELECT		@NValue = COUNT(*) 
			FROM		sys.master_files
			WHERE		type_desc = 'ROWS'
			  AND		DB_NAME(database_id) = 'tempdb'
		  
			PRINT '    Number of tempdb data files:    ' + CAST(@NValue AS varchar(10))
			
			IF @NValue < (@LogicalCPUCount/2)
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@LogicalCPUCount/2 AS varchar(10))
	

			PRINT ''
			PRINT '    Memory Configuration'
			
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'awe enabled')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> awe enabled option does not exist.'
			ELSE
				IF EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'awe enabled' AND value = 1)
					BEGIN
						PRINT '    AWE Enabled:                    Yes'   

						IF @64bit = 1
							PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Not needed since 64-bit'					
						ELSE
							IF @PhysicalMemory < 4096
								PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> AWE is not needed since memory is less than 4 GB'					
					END
				ELSE
					BEGIN
						PRINT '        AWE Enabled:                No'   

						IF @64bit = 0 AND @PhysicalMemory > 4096
							PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> AWE is needed since memory is greater than 4 GB, unless multiple instances are installed.  If that''s the case you can set AWE but must set Max Memory for each instance unless Max Memory won''t be over 4 GB.'
					END

			PRINT '        Physical Memory:            ' + CAST(@PhysicalMemory AS varchar(25))
			PRINT '        Min Memory:                 ' + CAST(@MinMemory AS varchar(25))
			
			IF @MinMemory <> 0
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be 0'
				
			PRINT '        Max Memory:                 ' + CAST(@MaxMemory AS varchar(25))

			IF @64bit = 1 OR EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'awe enabled' AND value = 1)
				IF @PhysicalMemory > 4096	
					IF @MaxMemory >= (@PhysicalMemory * @MaxMemPercentPerPhys)
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Max Memory is set to use more than ' + CAST(@MaxMemPercentPerPhys*100 AS varchar(10)) + '% of Physical Memory.'

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'index create memory (KB)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> index create memory (KB) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'index create memory (KB)' 
					
					PRINT '        Index creation memory:      ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @IndexCreateMemory 
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@IndexCreateMemory AS varchar(25))
				END
			
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'min memory per query (KB)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> min memory per query (KB) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'min memory per query (KB)' 
					
					PRINT '        Minimum memory per query:   ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @MinMemoryPerQuery
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@MinMemoryPerQuery AS varchar(25))
				END
	
			PRINT ''
			PRINT '    Processor Configuration'
		
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'affinity mask')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> affinity mask option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'affinity mask' 
					
					PRINT '        Affinity Mask:              ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> 0 AND @NValue <> (POWER(2,@LogicalCPUCount)- 1)
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be 0 OR ' + CAST((POWER(2,@LogicalCPUCount)- 1) AS varchar(25))
				END	
	
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'affinity I/O mask')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> affinity I/O mask option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'affinity I/O mask' 
					
					PRINT '        Affinity I/O Mask:          ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> 0 AND @NValue <> (POWER(2,@LogicalCPUCount)- 1)
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be 0 OR ' + CAST((POWER(2,@LogicalCPUCount)- 1) AS varchar(25))
				END	
	
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'max worker threads')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> max worker threads option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'max worker threads' 
					
					PRINT '        Max Worker Threads:         ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @MaxWorkerThreads
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@MaxWorkerThreads AS varchar(10))
				END	
	
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'priority boost')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> priority boost option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'priority boost' 
					
					PRINT '        Priority Boost:             ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @PriorityBoost
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@PriorityBoost AS varchar(10))
				END	
	
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'lightweight pooling')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> lightweight pooling option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'lightweight pooling' 
					
					PRINT '        Priority Boost:             ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @LightWeightPooling
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@LightWeightPooling AS varchar(10))
				END	
	
			PRINT ''
			PRINT '    Security Configuration'

			PRINT '        Server Authentication:      ' + CASE SERVERPROPERTY('IsIntegratedSecurityOnly') WHEN 1 THEN 'Windows Authentication' ELSE 'SQL Authentication' END
			
			IF SERVERPROPERTY('IsIntegratedSecurityOnly') <> @WindowsAuthentication
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @WindowsAuthentication WHEN 1 THEN 'Windows Authentication' ELSE 'SQL Authentication' END

			SET @NValue = NULL
			
			EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
										,'Software\Microsoft\MSSQLServer\MSSQLServer'
										,N'AuditLevel'
										,@NValue OUTPUT

			PRINT '        Login Auditing:             ' + CASE @NValue WHEN 0 THEN 'None' WHEN 1 THEN 'Successful' WHEN 2 THEN 'Failed' WHEN 3 THEN 'Both' ELSE 'Unknown' END
			
			IF @LoginAuditing <> @NValue
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @LoginAuditing WHEN 0 THEN 'None' WHEN 1 THEN 'Successful' WHEN 2 THEN 'Failed' WHEN 3 THEN 'Both' ELSE 'Unknown' END

			IF EXISTS(
						SELECT		1
						FROM		sys.credentials
						WHERE		name = '##xp_cmdshell_proxy_account##'
					 )
				BEGIN
					PRINT '        Enable server proxy acct:   ' + 'Enabled'
					PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should be disabled.'
				END
			ELSE
				PRINT '        Enable server proxy acct:   ' + 'Disabled'

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'common criteria compliance enabled')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> common criteria compliance enabled option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'common criteria compliance enabled' 
					
					PRINT '        Common Criteria Compliance: ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @CommonCriteriaCompliance
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@CommonCriteriaCompliance AS varchar(10))
				END	
				
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'c2 audit mode')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> c2 audit mode option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'c2 audit mode' 
					
					PRINT '        C2 Audit Mode:              ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @C2AuditMode
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@C2AuditMode AS varchar(10))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'cross db ownership chaining')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> cross db ownership chaining option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'cross db ownership chaining' 
					
					PRINT '        Cross DB Ownership:         ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @CrossDBChaining
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@CrossDBChaining AS varchar(10))
				END	
	
			PRINT ''
			PRINT '    Connections Configuration'

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'user connections')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> user connections option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'user connections' 
					
					PRINT '        Max Concurrent Connections: ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @MaxConcurrentConnections
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@MaxConcurrentConnections AS varchar(10))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'query governor cost limit')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> query governor cost limit option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'query governor cost limit' 
					
					PRINT '        Query Governor Cost Limit:  ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @QueryGovernorCostLimit
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@QueryGovernorCostLimit AS varchar(10))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'user options')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> user options does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'user options' 
					
					PRINT '        Implicit Transactions:      ' + CASE WHEN @NValue & 2 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 2 = 0 THEN 0 ELSE 1 END <> @ImplicitTransactions
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ImplicitTransactions AS char(1))

					PRINT '        Cursor Close On Commit:     ' + CASE WHEN @NValue & 4 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 4 = 0 THEN 0 ELSE 1 END <> @CursorCloseOnCommit
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@CursorCloseOnCommit AS char(1))

					PRINT '        ANSI Warnings:              ' + CASE WHEN @NValue & 8 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 8 = 0 THEN 0 ELSE 1 END <> @ANSIWarnings
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ANSIWarnings AS char(1))

					PRINT '        ANSI Padding:               ' + CASE WHEN @NValue & 16 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 16 = 0 THEN 0 ELSE 1 END <> @ANSIPadding
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ANSIPadding AS char(1))

					PRINT '        ANSI Nulls:                 ' + CASE WHEN @NValue & 32 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 32 = 0 THEN 0 ELSE 1 END <> @ANSINulls
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ANSINulls AS char(1))

					PRINT '        Arithmetic Abort:           ' + CASE WHEN @NValue & 64 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 64 = 0 THEN 0 ELSE 1 END <> @ArithmeticAbort
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ArithmeticAbort AS char(1))

					PRINT '        Arithmetic Ignore:          ' + CASE WHEN @NValue & 128 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 128 = 0 THEN 0 ELSE 1 END <> @ArithmeticIgnore
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ArithmeticIgnore AS char(1))

					PRINT '        Quoted Identifier:          ' + CASE WHEN @NValue & 256 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 256 = 0 THEN 0 ELSE 1 END <> @QuotedIdentifier
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@QuotedIdentifier AS char(1))

					PRINT '        No Count:                   ' + CASE WHEN @NValue & 512 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 512 = 0 THEN 0 ELSE 1 END <> @NoCount
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@NoCount AS char(1))

					PRINT '        ANSI Null Default On:       ' + CASE WHEN @NValue & 1024 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 1024 = 0 THEN 0 ELSE 1 END <> @ANSINullDefaultOn
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ANSINullDefaultOn AS char(1))

					PRINT '        ANSI Null Default Off:      ' + CASE WHEN @NValue & 2048 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 2048 = 0 THEN 0 ELSE 1 END <> @ANSINullDefaultOff
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ANSINullDefaultOff AS char(1))

					PRINT '        Conc Null Yields Null:      ' + CASE WHEN @NValue & 4096 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 4096 = 0 THEN 0 ELSE 1 END <> @ConcatenateNullYieldsNull
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ConcatenateNullYieldsNull AS char(1))

					PRINT '        Numeric Round Abort:        ' + CASE WHEN @NValue & 8192 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 8192 = 0 THEN 0 ELSE 1 END <> @NumericRoundAbort
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@NumericRoundAbort AS char(1))

					PRINT '        Xact Abort:                 ' + CASE WHEN @NValue & 16384 > 0 THEN '1' ELSE '0' END
					
					IF CASE WHEN @NValue & 16384 = 0 THEN 0 ELSE 1 END <> @XactAbort
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@XactAbort AS char(1))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'remote access')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> remote access option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'remote access' 
					
					PRINT '        Remote Access:              ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @RemoteAccess
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@RemoteAccess AS varchar(10))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'remote query timeout (s)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> remote query timeout (s) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'remote query timeout (s)' 
					
					PRINT '        Remote Query Timeout:       ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @RemoteQueryTimeout
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@RemoteQueryTimeout AS varchar(10))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'remote proc trans')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> remote proc trans option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'remote proc trans' 
					
					PRINT '        Req Dist Trans Svr to Svr:  ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @RemoteProcTrans
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@RemoteProcTrans AS varchar(10))
				END	

			PRINT ''
			PRINT '    Database Settings Configuration'

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'fill factor (%)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> fill factor (%) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'fill factor (%)' 
					
					PRINT '        Index Fill Factor (%):      ' + CAST(@NValue AS varchar(25))
					
					IF @NValue <> @IndexFillFactor
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@IndexFillFactor AS varchar(10))
				END	

			SET @NValue = NULL

			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,'Software\Microsoft\MSSQLServer\MSSQLServer'
													,'Tapeloadwaittime'
													,@NValue OUTPUT
													,'no_output'

			PRINT '        Wait Time for New Tape:     '  + CASE @NValue WHEN -1 THEN 'Indefinitely' WHEN 0 THEN 'Try Once' ELSE 'Try For ' + CAST(@NValue AS varchar(10)) + ' minute(s)' END

			IF @NValue <> @TapeBackupWaitIndefinitely
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @NValue WHEN -1 THEN 'Indefinitely' WHEN 0 THEN 'Try Once' ELSE 'Try For ' + CAST(@NValue AS varchar(10)) + ' minute(s)' END

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'media retention')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> media retention option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'media retention' 
					
					PRINT '        Backup Media Retention:     ' + CAST(@NValue AS varchar(25)) + ' day(s)'
					
					IF @NValue <> @DefaultBackupRetentionDays
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefaultBackupRetentionDays AS varchar(10))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'backup compression default')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> backup compression default option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'backup compression default' 
					
					PRINT '        Backup Compression Default: ' + CAST(@NValue AS char(1)) 
					
					IF @NValue <> @CompressBackup
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@CompressBackup AS char(1))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'recovery interval (min)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> recovery interval (min) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'recovery interval (min)' 
					
					PRINT '        Recovery Interval (min):    ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @RecoveryInterval
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@RecoveryInterval AS varchar(25))
				END	

			PRINT ''
			PRINT '    Advance Configuration'

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'filestream access level')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> filestream access level option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'filestream access level' 
					
					PRINT '        Filestream Access Level:    ' + CASE @NValue WHEN 0 THEN 'Disabled' WHEN 1 THEN 'T-SQL Access Enabled' WHEN 2 THEN 'Full Access Enabled' ELSE 'Unknown' END
					
					IF @NValue <> @FileStreamAccessLevel
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @FileStreamAccessLevel WHEN 0 THEN 'Disabled' WHEN 1 THEN 'T-SQL Access Enabled' WHEN 2 THEN 'Full Access Enabled' ELSE 'Unknown' END
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'nested triggers')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> nested triggers option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'nested triggers' 
					
					PRINT '        Nested Triggers:            ' + CAST(@NValue AS char(1)) 
					
					IF @NValue <> @AllowTriggersToFireOthers
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@AllowTriggersToFireOthers AS char(1))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'blocked process threshold (s)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> blocked process threshold (s) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'blocked process threshold (s)' 
					
					PRINT '        Blocked Process Threshold:  ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @BlockedProcessThreshold
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@BlockedProcessThreshold AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'cursor threshold')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> cursor threshold option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'cursor threshold' 
					
					PRINT '        Cursor Threshold:           ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @CursorThreshold
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@CursorThreshold AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'default full-text language')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> default full-text language option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'default full-text language' 
					
					PRINT '        Default Full-Text Lang:     ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @DefaultFullTextLang
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefaultFullTextLang AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'default language')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> default language option does not exist.'	
			ELSE
				BEGIN
					SELECT		@SValue = B.alias
					FROM		sys.configurations A
									JOIN sys.syslanguages B ON A.value = B.langid
					WHERE		A.name = 'default language' 

					PRINT '        Default Language:           ' + ISNULL(@SValue, 'Unknown')
					
					SELECT		@SValue = CASE WHEN B.langid = C.langid THEN NULL ELSE C.alias END
					FROM		sys.configurations					A
									JOIN sys.syslanguages			B ON A.value = B.langid
									CROSS APPLY sys.syslanguages	C
					WHERE		A.name = 'default language'
					  AND		C.langid = @DefaultLanguage
					  				  										
					IF @SValue IS NOT NULL
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @SValue
				END	
				
			PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Full-text upgrade option must be manually checked.'
						
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'max text repl size (B)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> max text repl size (B) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'max text repl size (B)' 
					
					PRINT '        Max Text Repl Size (B):     ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @MaxTextReplicationSize
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@MaxTextReplicationSize AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'optimize for ad hoc workloads')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> optimize for ad hoc workloads option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'optimize for ad hoc workloads' 
					
					PRINT '        Opt for Ad Hoc Workload:    ' + CAST(@NValue AS char(1)) 
					
					IF @NValue <> @OptimizeForAdHocWorkloads
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@OptimizeForAdHocWorkloads AS varchar(1))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'scan for startup procs')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> scan for startup procs option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'scan for startup procs' 
					
					PRINT '        Scan for Startup Procs:     ' + CAST(@NValue AS char(1)) 
					
					IF @NValue <> @ScanForStartupProcs
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@ScanForStartupProcs AS varchar(1))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'two digit year cutoff')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> two digit year cutoff option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'two digit year cutoff' 
					
					PRINT '        Two Digit Year Cutoff:      ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @TwoDigitYearCutoff
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@TwoDigitYearCutoff AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'network packet size (B)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> network packet size (B) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'network packet size (B)' 
					
					PRINT '        Network Packet Size (B):    ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @NetworkPacketSize
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@NetworkPacketSize AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'remote login timeout (s)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> remote login timeout (s) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'remote login timeout (s)' 
					
					PRINT '        Remote Login Timeout (s):   ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @RemoteLoginTimeout
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@RemoteLoginTimeout AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'cost threshold for parallelism')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> cost threshold for parallelism option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'cost threshold for parallelism' 
					
					PRINT '        Cost Thres for Parallelism: ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @CostThresholdForParallelism
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@CostThresholdForParallelism AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'locks')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> locks option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'locks' 
					
					PRINT '        Locks:                      ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @Locks
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@Locks AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'max degree of parallelism')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> max degree of parallelism option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'max degree of parallelism' 
					
					PRINT '        Max Degree of Parralelism:  ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @MaxDegreeofParallelism
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@MaxDegreeofParallelism AS varchar(25))
				END	

			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'query wait (s)')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> query wait (s) option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'query wait (s)' 
					
					PRINT '        Query Wait (s):             ' + CAST(@NValue AS varchar(25)) 
					
					IF @NValue <> @QueryWait
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@QueryWait AS varchar(25))
				END	

			PRINT ''
			PRINT '    Configurable Features'
			
			SELECT		@NValue = CAST(current_value AS bit)
			FROM		msdb.dbo.syspolicy_configuration 
			WHERE		name = 'Enabled' 
			
			PRINT '        Policy Management:          ' + CASE @NValue WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END

			IF @NValue <> @PolicyMgmtEnabled
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @PolicyMgmtEnabled WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END

			SELECT		@NValue = CAST(parameter_value AS bit)
			FROM		msdb.dbo.syscollector_config_store 
			WHERE		parameter_name = 'CollectorEnabled' 
			
			PRINT '        Data Collection:            ' + CASE @NValue WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END

			IF @NValue <> @DataCollectionConfigured
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @DataCollectionConfigured WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END


			IF EXISTS(
						SELECT		1
						FROM		master.sys.resource_governor_configuration 
						WHERE		is_enabled = 0
					 )
				SET @NValue = 0
			ELSE
				SET @NValue = 1
			
			PRINT '        Resource Governor:          ' + CASE @NValue WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END

			IF @NValue <> @ResourceGovernorEnabled
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @ResourceGovernorEnabled WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END


			SET @NValue = NULL
						
			EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
										,N'Software\Microsoft\MSSQLServer\MSSQLServer'
										,N'NumErrorLogs'
										,@NValue OUTPUT
										,'NO_OUTPUT'

			SET @NValue = ISNULL(@NValue, 6)
			
			PRINT '        SQL Server Logs:            ' + CAST(@NValue AS varchar(10))

			IF @NValue <> @SQLServerLogs
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@SQLServerLogs AS varchar(10))
			
			IF NOT EXISTS(SELECT 1 FROM sys.configurations WHERE name = 'Database Mail XPs')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Database Mail XPs option does not exist.'	
			ELSE
				BEGIN
					SELECT		@NValue = CAST(value AS int)
					FROM		sys.configurations 
					WHERE		name = 'Database Mail XPs' 
					
					PRINT '        Database Mail XPs:          ' + CASE @NValue WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END
					
					IF @NValue <> @DatabaseMailEnabled
						PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CASE @DatabaseMailEnabled WHEN 1 THEN 'Enabled' WHEN 0 THEN 'Disabled' ELSE 'Unknown' END
				END	

			IF @NValue = 1
				BEGIN
					DECLARE CURSOR_MAILPROFILE CURSOR FAST_FORWARD
					FOR
							SELECT		name 
							FROM		msdb.dbo.sysmail_profile
							
					OPEN CURSOR_MAILPROFILE
					
					FETCH NEXT FROM CURSOR_MAILPROFILE
					INTO @SValue
					
					PRINT '            Mail Profile(s):'
					
					WHILE @@FETCH_STATUS = 0
					BEGIN
						PRINT '                ' + @SValue
						
						FETCH NEXT FROM CURSOR_MAILPROFILE
						INTO @SValue
					END	
					
					CLOSE CURSOR_MAILPROFILE
					DEALLOCATE CURSOR_MAILPROFILE
				END
				
		PRINT 'END SQL CONFIG INFORMATION'
	END
GO

IF LEFT(CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(25)), 2) = '10'
	BEGIN
		PRINT ''

		PRINT 'BEGIN DRIVE INFORMATION'

		DECLARE @ReturnCode			int
				,@FSOObjectToken	int
				,@Drive				char(1)
				,@OutputDrive		int
				,@TotalSize			decimal
				,@Source			varchar(255)
				,@FreeSpace			decimal
				,@OLE				bit
				,@Description		varchar(255)

		SET @TotalSize = 0

		IF EXISTS(SELECT * FROM sysconfigures WHERE comment = 'Enable or disable Ole Automation Procedures' AND value = 1)
			SET @OLE = 1
		ELSE
			SET @OLE = 0


		CREATE TABLE #DriveInfo
		( 
			DI_Drive		char(1)
			,DI_FreeSpace	int
		)

		INSERT INTO #DriveInfo
		(
			DI_Drive,
			DI_FreeSpace
		)
		EXECUTE master.dbo.xp_fixeddrives

		DECLARE CURSOR_DRIVES CURSOR FAST_FORWARD
		FOR
			SELECT		DI_Drive
						,DI_FreeSpace
			FROM		#DriveInfo
			ORDER BY	1

		OPEN CURSOR_DRIVES

		FETCH NEXT FROM CURSOR_DRIVES
		INTO @Drive, @FreeSpace

		IF @OLE = 1
			EXECUTE @ReturnCode = sp_OACreate  'Scripting.FileSystemObject', @FSOObjectToken OUT
		ELSE
			SET @ReturnCode = 0
			
		IF @ReturnCode <> 0
			EXECUTE sp_OAGetErrorInfo @FSOObjectToken
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT ''

					IF @OLE = 1
						BEGIN 
							EXECUTE @ReturnCode = sp_OAMethod @FSOObjectToken, 'GetDrive', @OutputDrive OUT, @Drive

							IF @ReturnCode <> 0
								BEGIN
									EXECUTE sp_OAGetErrorInfo @FSOObjectToken, @Source OUT, @Description OUT

									PRINT ' *** Error on retrieving GetDrive (' + @Drive + ') info.  Source:  ' + ISNULL(@Source, '') + ' - Description:  ' + ISNULL(@Description, '')
								END
							ELSE
								BEGIN
									EXECUTE @ReturnCode = sp_OAGetProperty @OutputDrive, 'TotalSize', @TotalSize OUT

									IF @ReturnCode <> 0
										BEGIN
											EXECUTE sp_OAGetErrorInfo @FSOObjectToken, @Source OUT, @Description OUT
							
											PRINT ' *** Error on retrieving TotalSize (' + @Drive + ') info.  Source:  ' + ISNULL(@Source, '') + ' - Description:  ' + ISNULL(@Description, '')
										END

								END
						END
					
					PRINT '    Drive:         ' + @Drive
					PRINT '    Size:          ' + CASE WHEN @TotalSize = 0 THEN 'Unable to retrieve info' ELSE CAST(CAST((@TotalSize/1024/1024/1024.0) AS numeric(11,2)) AS varchar(50)) + ' GB' END
					PRINT '    FreeSpace:     ' + CAST(CAST((@FreeSpace/1024) AS numeric(11,2)) AS varchar(50)) + ' GB'
					PRINT '    Percent Free:  ' + CASE WHEN @TotalSize = 0 THEN 'Unable to determine percent free' ELSE CAST(CAST(((@FreeSpace/1024)/(@TotalSize/1024/1024/1024)) * 100 as numeric(11,2)) AS varchar(50))  + '%' END
					PRINT ''
					
					FETCH NEXT FROM CURSOR_DRIVES
					INTO @Drive, @FreeSpace
				END

				CLOSE CURSOR_DRIVES
				DEALLOCATE CURSOR_DRIVES

				IF @OLE = 1
					EXECUTE @ReturnCode = sp_OADestroy @FSOObjectToken
		END
			
		DROP TABLE #DriveInfo

		PRINT 'END DRIVE INFORMATION'
	END