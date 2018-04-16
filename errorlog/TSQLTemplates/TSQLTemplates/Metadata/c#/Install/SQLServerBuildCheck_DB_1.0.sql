USE [master]
GO
SET NOCOUNT ON

PRINT 'SCAN DATE:                          ' + CONVERT(varchar(30), GETDATE(), 109)
PRINT 'SCRIPT BASED ON STANDARDS:          http://sharepoint.auth.wellpoint.com/sites/WDBS_SQLServer/Steve/Proposed%20Standards%20Queue/SQL%20Server%202008%20Standards%20Version%201.00.00.docx '
PRINT ''

-- BEGIN CONSTANTS

DECLARE @DefAutoClose					bit
		,@DefAutoCreateStat				bit
		,@DefAutoShrink					bit
		,@DefAutoUpdStat				bit
		,@DefAutoUpdStatAsync			bit
		,@DefCloseCursorOnCommit		bit
		,@DefDefaultCursor				varchar(10)
		,@DefANSINullDef				bit
		,@DefANSINulls					bit
		,@DefANSIPadding				bit
		,@DefANSIWarnings				bit
		,@DefAritmeticAbort				bit
		,@DefConcatenateNullYieldNulls	bit
		,@DefCrossDbChaining			bit
		,@DefDataCorrelation			bit
		,@DefNumericRoundAbort			bit
		,@DefParameterization			bit
		,@DefQuotedIdentifier			bit
		,@DefRecursiveTriggers			bit
		,@DefTrustworthy				bit
		,@DefPageVerify					varchar(20)
		,@DefServiceBroker				bit
		,@DefHonorBroker				bit
		,@DefDbReadOnly					bit
		,@DefIsEncryption				bit
		,@DefRestrictAccess				varchar(20)
		,@DefCDCEnabled					bit
		,@DefRetentionPeriod			int
		,@DefRetentionUnit				varchar(60)
		,@DefAutoCleanup				bit

SET @DefAutoClose = 0
SET @DefAutoCreateStat=  1
SET @DefAutoShrink = 0
SET @DefAutoUpdStat = 1
SET @DefAutoUpdStatAsync = 0
SET @DefCloseCursorOnCommit = 0
SET @DefDefaultCursor = 'GLOBAL'
SET @DefANSINullDef = 0
SET @DefANSINulls = 0
SET @DefANSIPadding = 0
SET @DefANSIWarnings = 0
SET @DefAritmeticAbort = 0
SET @DefConcatenateNullYieldNulls = 0
SET @DefCrossDbChaining = 0
SET @DefDataCorrelation = 0
SET @DefNumericRoundAbort = 0
SET @DefParameterization = 0
SET @DefQuotedIdentifier = 0
SET @DefRecursiveTriggers = 0
SET @DefTrustworthy = 0
SET @DefPageVerify = 'CHECKSUM'
SET @DefServiceBroker = 0
SET @DefHonorBroker = 0
SET @DefDbReadOnly = 0
SET @DefIsEncryption = 0
SET @DefRestrictAccess = 'MULTI_USER'
SET @DefCDCEnabled = 0
SET @DefRetentionPeriod = 2
SET @DefRetentionUnit = 'Days'
SET @DefAutoCleanup = 1

-- END CONSTANTS

IF LEFT(CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(25)), 2) <> '10'
	PRINT '*** THIS SCRIPT CAN ONLY BE RUN ON SQL SERVER 2008 ***'
ELSE
	BEGIN

		DECLARE		@WindowsVerison			varchar(128)
					,@PhysicalCPUCount		tinyint
					,@LogicalCPUCount		smallint
					,@PhysicalMemory		int
					,@ApproxStartDate		datetime
					,@DbName				varchar(128)
					,@DbOwner				varchar(128)
					,@DbCreateDate			datetime
					,@CompatibilityLevel	varchar(10)
					,@AutoUpdStatsAsync		bit
					,@DbChaining			bit
					,@DataCorrelationOn		bit
					,@Trustworthy			bit
					,@PageVerifyOption		varchar(20)
					,@Broker				bit
					,@HonorBrokerPriority	bit
					,@IsEncrypted			bit
					,@LogicalName			varchar(128)
					,@PhysicalName			varchar(256)
					,@Size					bigint
					,@AutoGrowthInfo		varchar(512)
					,@CDCEnabled			bit
					,@RetentionPeriod		int
					,@RetentionUnit			varchar(60)
					,@AutoCleanup			bit

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

		DROP TABLE #ServerInfo
						
		PRINT 'BEGIN SQL SERVER INFORMATION' 
		PRINT '    MachineName:                    ' + CAST(ISNULL(SERVERPROPERTY('MachineName'), 'NULL') AS varchar(128))
		PRINT ''
		PRINT '    WindowsVersion:                 ' +  @WindowsVerison
		PRINT '    PhysicalCPU:                    ' +  CAST(@PhysicalCPUCount AS varchar(128))
		PRINT '    LogicalCPU:                     ' +  CAST(@LogicalCPUCount AS varchar(128))
		PRINT '    PhysicalMemory:                 ' +  CAST(@PhysicalMemory AS varchar(128))
		PRINT ''
		PRINT '    SQLServer:                      ' + CAST(ISNULL(SERVERPROPERTY('ServerName'), 'NULL') AS varchar(128))
		PRINT '    InstanceName:                   ' + CAST(SERVERPROPERTY('InstanceName') AS varchar(128))
		PRINT '    SQL Edition:                    ' + CAST(ISNULL(SERVERPROPERTY('Edition'), 'NULL') AS varchar(128))
		PRINT '    ProductVersion:                 ' + CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(25))
		PRINT '    ProductLevel:                   ' + CAST(ISNULL(SERVERPROPERTY('ProductLevel'), 'NULL') AS varchar(5))
		PRINT 'END SQL SERVER INFORMATION' 
		PRINT ''
		
		DECLARE CURSOR_DBS CURSOR FAST_FORWARD
		FOR
		    -- Most of the options are stored in sysdatabases but to limit on declaring 
		    -- a lot variables, going to try to use the DATABASEPROPERTYEX function as much
		    -- as I can.
			SELECT		A.name
						,B.name
						,A.create_date
						,A.compatibility_level
						,A.is_auto_update_stats_async_on
						,A.is_db_chaining_on						
						,A.is_date_correlation_on
						,A.is_trustworthy_on
						,A.page_verify_option_desc
						,A.is_broker_enabled
						,A.is_honor_broker_priority_on
						,A.is_encrypted
						,A.is_cdc_enabled
						,ISNULL(C.retention_period, 2)
						,ISNULL(C.retention_period_units_desc, 'Days')
						,ISNULL(C.is_auto_cleanup_on, 1)
			FROM		sys.databases A
							LEFT JOIN sys.server_principals B ON A.owner_sid = B.sid
							LEFT JOIN sys.change_tracking_databases C ON A.database_id = C.database_id
			
		OPEN CURSOR_DBS
		
		FETCH NEXT FROM CURSOR_DBS
		INTO @DbName, @DbOwner, @DbCreateDate, @CompatibilityLevel, @AutoUpdStatsAsync, @DbChaining, 
		     @DataCorrelationOn, @Trustworthy, @PageVerifyOption, @Broker, @HonorBrokerPriority, @IsEncrypted,
			 @CDCEnabled, @RetentionPeriod, @RetentionUnit, @AutoCleanup

		PRINT 'BEGIN DATABASE INFORMATION' 
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT '    ' + QUOTENAME(@DbName)
			PRINT '        General Information'
			PRINT '            Status:                               ' + CAST(DATABASEPROPERTYEX(@DbName, 'Status') AS varchar(25))
			PRINT '            Owner:                                ' + @DbOwner
			PRINT '            Date Created:                         ' + CONVERT(varchar(30), @DbCreateDate, 109)
			PRINT '            Collation:                            ' + CAST(DATABASEPROPERTYEX(@DbName, 'Collation') AS varchar(30))
			PRINT '            Recovery Model:                       ' + CAST(DATABASEPROPERTYEX(@DbName, 'Recovery') AS varchar(30))
			PRINT '            Compatibility Level:                  ' + @CompatibilityLevel
			PRINT ''
			PRINT '        File Information'

			DECLARE CURSOR_DB_FILES CURSOR FAST_FORWARD
			FOR
				SELECT		name
							,physical_name
							,CEILING((size * 8192)/1024/1024.0) AS [Size_MB]
							,'By ' +
								CASE 
									WHEN is_percent_growth = 1 THEN CAST(growth AS varchar(10)) + ' percent'
									ELSE CAST(CEILING((growth * 8192.0)/1024/1024) AS varchar(50)) + ' MB'
								END + ', ' +
									CASE 
										WHEN max_size = -1 THEN 'unrestricted growth'
										ELSE 'restricted growth to ' + CAST(CEILING((max_size * 8192.0)/1024/1024) AS varchar(50)) + ' MB'
									END	
				FROM		master.sys.master_files
				WHERE		database_id = DB_ID(@DbName)
				ORDER BY	file_id
				
			OPEN CURSOR_DB_FILES
			
			FETCH NEXT FROM CURSOR_DB_FILES
			INTO @LogicalName, @PhysicalName, @Size, @AutoGrowthInfo

			WHILE @@FETCH_STATUS = 0
			BEGIN
				PRINT '            Logical Name:                         ' + @LogicalName
				PRINT '            Physical Name:                        ' + @PhysicalName
				PRINT '            Size:                                 ' + CAST(@Size AS varchar(50)) + ' MB'
				PRINT '            Autogrowth                            ' + @AutoGrowthInfo
				PRINT ''
				
				FETCH NEXT FROM CURSOR_DB_FILES
				INTO @LogicalName, @PhysicalName, @Size, @AutoGrowthInfo
			END

			CLOSE CURSOR_DB_FILES
			DEALLOCATE CURSOR_DB_FILES
			
			PRINT '        Option Information'
			PRINT '            Auto Close:                           ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoClose') AS char(1))
			
			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoClose') AS bit) <> @DefAutoClose
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefAutoClose AS char(1))
							
			PRINT '            Auto Create Statistics:               ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoCreateStatistics') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoCreateStatistics') AS bit) <> @DefAutoCreateStat
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefAutoCreateStat AS char(1))

			PRINT '            Auto Shrink:                          ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoShrink') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoShrink') AS bit) <> @DefAutoShrink
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefAutoShrink AS char(1))

			PRINT '            Auto Update Statistics:               ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoUpdateStatistics') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAutoUpdateStatistics') AS bit) <> @DefAutoUpdStat
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefAutoUpdStat AS char(1))

			PRINT '            Auto Update Statistics Async:         ' + CAST(@AutoUpdStatsAsync AS char(1))

			IF @AutoUpdStatsAsync <> @DefAutoUpdStatAsync
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefAutoUpdStatAsync AS char(1))

			PRINT ''  
			PRINT '            Close Cursor on Commit:               ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsCloseCursorsOnCommitEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsCloseCursorsOnCommitEnabled') AS bit) <> @DefCloseCursorOnCommit
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefCloseCursorOnCommit AS char(1))

			PRINT '            Default Cursor:                       ' + CASE CAST(DATABASEPROPERTYEX(@DbName, 'IsLocalCursorsDefault') AS char(1))
																			WHEN 0 THEN 'GLOBAL'
																			WHEN 1 THEN 'LOCAL'
																			ELSE 'UNKNOWN'
																		 END																		 

			IF CASE CAST(DATABASEPROPERTYEX(@DbName, 'IsLocalCursorsDefault') AS char(1))
																			WHEN 0 THEN 'GLOBAL'
																			WHEN 1 THEN 'LOCAL'
																			ELSE 'UNKNOWN'
																		 END <> @DefDefaultCursor
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @DefDefaultCursor

			PRINT ''
			PRINT '            ANSI NULL Default:                    ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiNullDefault') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiNullDefault') AS bit) <> @DefANSINullDef
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefANSINullDef AS char(1))

			PRINT '            ANSI NULLS:                           ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiNullsEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiNullsEnabled') AS bit) <> @DefANSINulls
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefANSINulls AS char(1))

			PRINT '            ANSI Padding:                         ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiPaddingEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiPaddingEnabled') AS bit) <> @DefANSIPadding
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefANSIPadding AS char(1))

			PRINT '            ANSI Warnings:                        ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiWarningsEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsAnsiWarningsEnabled') AS bit) <> @DefANSIWarnings
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefANSIWarnings AS char(1))

			PRINT '            Arithmetic Abort:                     ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsArithmeticAbortEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsArithmeticAbortEnabled') AS bit) <> @DefAritmeticAbort
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefAritmeticAbort AS char(1))

			PRINT '            Concatenate Null Yields Null:         ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsNullConcat') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsNullConcat') AS bit) <> @DefConcatenateNullYieldNulls
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefConcatenateNullYieldNulls AS char(1))

			PRINT '            Cross-database Ownership Chaning:     ' + CAST(@DbChaining AS char(1))

			IF @DbChaining <> @DefCrossDbChaining AND @DbName NOT IN ('master', 'tempdb', 'msdb')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefCrossDbChaining AS char(1))

			PRINT '            Data Correlation Optimization:        ' + CAST(@DataCorrelationOn AS char(1))

			IF @DataCorrelationOn <> @DefDataCorrelation
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefDataCorrelation AS char(1))

			PRINT '            Numeric Round-Abort:                  ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsNumericRoundAbortEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsNumericRoundAbortEnabled') AS bit) <> @DefNumericRoundAbort
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefNumericRoundAbort AS char(1))

			PRINT '            Parameterization:                     ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsParameterizationForced') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsParameterizationForced') AS bit) <> @DefParameterization
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefParameterization AS char(1))

			PRINT '            Quoted Identifiers:                   ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsQuotedIdentifiersEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsQuotedIdentifiersEnabled') AS bit) <> @DefQuotedIdentifier
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefQuotedIdentifier AS char(1))

			PRINT '            Recursive Triggers:                   ' + CAST(DATABASEPROPERTYEX(@DbName, 'IsRecursiveTriggersEnabled') AS char(1))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'IsRecursiveTriggersEnabled') AS bit) <> @DefRecursiveTriggers
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefRecursiveTriggers AS char(1))

			PRINT '            Trustworthy:                          ' + CAST(@Trustworthy AS char(1))

			IF @Trustworthy <> @DefTrustworthy AND @DbName NOT IN ('msdb')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefTrustworthy AS char(1))

--			PRINT '            VarDecimal Storage Format:            'xx
			PRINT ''
			PRINT '            Page Verify:                          ' + @PageVerifyOption 

			IF @PageVerifyOption <> @DefPageVerify
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @DefPageVerify

			PRINT ''
			PRINT '            Broker Enabled:                       ' + CAST(@Broker AS char(1))

			IF @Broker <> @DefServiceBroker AND @DbName NOT IN ('tempdb', 'msdb')
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefServiceBroker AS char(1))

			PRINT '            Honor Broker Priority:                ' + CAST(@HonorBrokerPriority AS char(1))

			IF @HonorBrokerPriority <> @DefHonorBroker
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefHonorBroker AS char(1))

			PRINT ''
			PRINT '            Database Read-Only:                   ' + CAST(DATABASEPROPERTY(@DbName, 'IsReadOnly') AS char(1))

			IF CAST(DATABASEPROPERTY(@DbName, 'IsReadOnly') AS bit) <> @DefDbReadOnly
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefDbReadOnly AS char(1))

			PRINT '            Encryption Enabled:                   ' + CAST(@IsEncrypted AS char(1))

			IF @IsEncrypted <> @DefIsEncryption
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefIsEncryption AS char(1))

			PRINT '            Restrict Access:                      ' + CAST(DATABASEPROPERTYEX(@DbName, 'UserAccess') AS varchar(20))

			IF CAST(DATABASEPROPERTYEX(@DbName, 'UserAccess') AS varchar(25)) <> @DefRestrictAccess
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @DefRestrictAccess

			PRINT ''

			PRINT '        Change Tracking Information'   
			PRINT '            Change Tracking:                      ' + CAST(@CDCEnabled AS char(1))

			IF @DefCDCEnabled <> @CDCEnabled
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefCDCEnabled AS char(1))

			PRINT '            Retention Period:                     ' + CAST(@RetentionPeriod AS varchar(25))

			IF @DefRetentionPeriod <> @RetentionPeriod
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefRetentionPeriod AS varchar(25))

			PRINT '            Retention Period Units:               ' + @RetentionUnit

			IF @DefRetentionUnit <> @RetentionUnit
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + @DefRetentionUnit

			PRINT '            Auto Cleanup:                         ' + CAST(@AutoCleanup AS char(1))

			IF @DefAutoCleanup <> @AutoCleanup
				PRINT '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Should Be ' + CAST(@DefAutoCleanup AS char(1))

			PRINT ''
						
			FETCH NEXT FROM CURSOR_DBS
			INTO @DbName, @DbOwner, @DbCreateDate, @CompatibilityLevel, @AutoUpdStatsAsync, @DbChaining, 
				 @DataCorrelationOn, @Trustworthy, @PageVerifyOption, @Broker, @HonorBrokerPriority, @IsEncrypted,
				 @CDCEnabled, @RetentionPeriod, @RetentionUnit, @AutoCleanup
		END
		
		PRINT 'END DATABASE INFORMATION' 
				
		CLOSE CURSOR_DBS
		DEALLOCATE CURSOR_DBS
		
	END