SET NOCOUNT ON 

IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) = '8'
	SELECT		A.name + '<1>' +
					ISNULL(B.name, 'Unknown') + '<2>' +
					ISNULL(CAST(DATABASEPROPERTYEX(A.name, 'Collation') AS varchar(128)), 'Unknown') + '<3>' + 
					CAST(A.cmptlevel AS varchar(10)) + '<4>' +
					CAST(DATABASEPROPERTYEX(A.name, 'Recovery') AS varchar(25)) + '<5>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsAutoClose') AS char(1)) + '<6>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsAutoCreateStatistics') AS char(1)) + '<7>' + 
					CAST(DATABASEPROPERTYEX(A.name, 'IsAutoShrink') AS char(1)) + '<8>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsAutoUpdateStatistics') AS char(1)) + '<9>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsCloseCursorsOnCommitEnabled') AS char(1)) + '<10>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsAnsiNullDefault') AS char(1)) + '<11>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsAnsiNullsEnabled') AS char(1)) + '<12>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsAnsiPaddingEnabled') AS char(1)) + '<13>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsAnsiWarningsEnabled') AS char(1)) + '<14>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsArithmeticAbortEnabled')	 AS char(1)) + '<15>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsNullConcat') AS char(1)) + '<16>' +
					'1<17>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsNumericRoundAbortEnabled') AS char(1)) + '<18>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsQuotedIdentifiersEnabled') AS char(1)) + '<19>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsRecursiveTriggersEnabled') AS char(1)) + '<20>' +
					CAST(DATABASEPROPERTYEX(A.name, 'IsFulltextEnabled') AS char(1)) + '<21>' +
					'1<22>' +
					'0<23>' +
					CAST(DATABASEPROPERTY(A.name, 'IsReadOnly') AS char(1)) + '<24>' +
					CAST(DATABASEPROPERTYEX(A.name, 'UserAccess') AS varchar(20)) + '<25>' +
					CAST(DATABASEPROPERTYEX(A.name, 'Status') AS varchar(20)) + '<26>' +
					CONVERT(varchar(30), crdate, 120)
	FROM		sysdatabases A
					LEFT JOIN syslogins B ON A.sid = B.sid
					
IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) = '9'
	SELECT		A.name + '<1>' +
					ISNULL(SUSER_SNAME(A.owner_sid), 'Unknown') + '<2>' +
					ISNULl(A.collation_name, 'Unknown') + '<3>' +
					CAST(A.compatibility_level AS varchar(10)) + '<4>' +
					A.recovery_model_desc COLLATE DATABASE_DEFAULT + '<5>' +
					CAST(A.is_auto_close_on AS char(1)) + '<6>' +
					CAST(A.is_auto_create_stats_on AS char(1)) + '<7>' +
					CAST(A.is_auto_shrink_on AS char(1)) + '<8>' +
					CAST(A.is_auto_update_stats_on AS char(1)) + '<9>' +
					CAST(A.is_cursor_close_on_commit_on AS char(1)) + '<10>' +
					CAST(A.is_ansi_null_default_on AS char(1)) + '<11>' +
					CAST(A.is_ansi_nulls_on AS char(1)) + '<12>' +
					CAST(A.is_ansi_padding_on AS char(1)) + '<13>' +
					CAST(A.is_ansi_warnings_on AS char(1)) + '<14>' +
					CAST(A.is_arithabort_on AS char(1)) + '<15>' + 
					CAST(A.is_concat_null_yields_null_on AS char(1)) + '<16>' +
					CAST(A.is_db_chaining_on AS char(1)) + '<17>' +
					CAST(A.is_numeric_roundabort_on AS char(1)) + '<18>' +
					CAST(A.is_quoted_identifier_on AS char(1)) + '<19>' +
					CAST(A.is_recursive_triggers_on AS char(1)) + '<20>' +
					CAST(A.is_fulltext_enabled AS char(1)) + '<21>' + 
					CAST(A.is_trustworthy_on AS char(1)) + '<22>' +
					CAST(A.is_broker_enabled AS char(1)) + '<23>' +
					CAST(A.is_read_only AS char(1)) + '<24>' +
					A.user_access_desc + '<25>' + 
					A.State_Desc + '<26>' +										
					CONVERT(varchar(30), create_date, 120)
	FROM		sys.databases A

IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 2) = '10'
	SELECT		A.name + '<1>' +
					ISNULL(SUSER_SNAME(A.owner_sid), 'Unknown') + '<2>' +
					ISNULl(A.collation_name, 'Unknown') + '<3>' +
					CAST(A.compatibility_level AS varchar(10)) + '<4>' +
					A.recovery_model_desc COLLATE DATABASE_DEFAULT + '<5>' +
					CAST(A.is_auto_close_on AS char(1)) + '<6>' +
					CAST(A.is_auto_create_stats_on AS char(1)) + '<7>' +
					CAST(A.is_auto_shrink_on AS char(1)) + '<8>' +
					CAST(A.is_auto_update_stats_on AS char(1)) + '<9>' +
					CAST(A.is_cursor_close_on_commit_on AS char(1)) + '<10>' +
					CAST(A.is_ansi_null_default_on AS char(1)) + '<11>' +
					CAST(A.is_ansi_nulls_on AS char(1)) + '<12>' +
					CAST(A.is_ansi_padding_on AS char(1)) + '<13>' +
					CAST(A.is_ansi_warnings_on AS char(1)) + '<14>' +
					CAST(A.is_arithabort_on AS char(1)) + '<15>' + 
					CAST(A.is_concat_null_yields_null_on AS char(1)) + '<16>' +
					CAST(A.is_db_chaining_on AS char(1)) + '<17>' +
					CAST(A.is_numeric_roundabort_on AS char(1)) + '<18>' +
					CAST(A.is_quoted_identifier_on AS char(1)) + '<19>' +
					CAST(A.is_recursive_triggers_on AS char(1)) + '<20>' +
					CAST(A.is_fulltext_enabled AS char(1)) + '<21>' + 
					CAST(A.is_trustworthy_on AS char(1)) + '<22>' +
					CAST(A.is_broker_enabled AS char(1)) + '<23>' +
					CAST(A.is_read_only AS char(1)) + '<24>' +
					A.user_access_desc + '<25>' + 
					A.State_Desc + '<26>' +										
					CONVERT(varchar(30), create_date, 120)
	FROM		sys.databases A

/*
IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) = '8'
	SELECT		A.name															AS [Db]
				,ISNULL(B.name, 'Unknown')										AS [Owner]
				,DATABASEPROPERTYEX(A.name, 'Collation')						AS [Collation]
				,A.cmptlevel													AS [CompatibilityLeve]
				,DATABASEPROPERTYEX(A.name, 'Recovery')							AS [RecoveryModel]
				,DATABASEPROPERTYEX(A.name, 'IsAutoClose')						AS [AutoClose]
				,DATABASEPROPERTYEX(A.name, 'IsAutoCreateStatistics')			AS [AutoCreateStatistics]
				,DATABASEPROPERTYEX(A.name, 'IsAutoShrink')						AS [AutoShrink]
				,DATABASEPROPERTYEX(A.name, 'IsAutoUpdateStatistics')			AS [AutoUpdateStatistics]
				,DATABASEPROPERTYEX(A.name, 'IsCloseCursorsOnCommitEnabled')	AS [CloseCursorOnCommitEnabled]
				,DATABASEPROPERTYEX(A.name, 'IsAnsiNullDefault')				AS [ANSINullDefault]
				,DATABASEPROPERTYEX(A.name, 'IsAnsiNullsEnabled')				AS [ANSINullsEnabled]
				,DATABASEPROPERTYEX(A.name, 'IsAnsiPaddingEnabled')				AS [ANSIPaddingEnabled]			
				,DATABASEPROPERTYEX(A.name, 'IsAnsiWarningsEnabled')			AS [ANSIWarningsEnabled]		
				,DATABASEPROPERTYEX(A.name, 'IsArithmeticAbortEnabled')			AS [ArithmeticAbortEnabled]
				,DATABASEPROPERTYEX(A.name, 'IsNullConcat')						AS [ConcatenateNullYieldsNull]			
				,1																AS [CrossDbOwnership]			
				,DATABASEPROPERTYEX(A.name, 'IsNumericRoundAbortEnabled')		AS [NumericRoundAbort]
				,DATABASEPROPERTYEX(A.name, 'IsQuotedIdentifiersEnabled')		AS [QuotedIdentifierEnabled]
				,DATABASEPROPERTYEX(A.name, 'IsRecursiveTriggersEnabled')		AS [RecursiveTriggersEnabled]
				,DATABASEPROPERTYEX(A.name, 'IsFulltextEnabled')				AS [FullTextEnabled]
				,1																AS [Trustworthy]
				,0																AS [BrokerEnabled]
				,DATABASEPROPERTY(A.name, 'IsReadOnly')							AS [ReadOnly]
				,0																AS [EncryptionEnabled]
				,DATABASEPROPERTYEX(A.name, 'UserAccess')						AS [RestrictUserAccess]
				,DATABASEPROPERTYEX(A.name, 'Status')							AS [Status]
	FROM		sysdatabases A
					LEFT JOIN syslogins B ON A.sid = B.sid
					
IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) = '9'
	SELECT		A.name															AS [Db]
				,ISNULL(B.name, 'Unknown')										AS [Owner]
				,A.collation_name												AS [Collation]
				,A.compatibility_level											AS [CompatibilityLeve]
				,A.recovery_model_desc											AS [RecoveryModel]
				,A.is_auto_close_on												AS [AutoClose]
				,A.is_auto_create_stats_on										AS [AutoCreateStatistics]
				,A.is_auto_shrink_on											AS [AutoShrink]
				,A.is_auto_update_stats_on										AS [AutoUpdateStatistics]
				,A.is_cursor_close_on_commit_on									AS [CloseCursorOnCommitEnabled]
				,A.is_ansi_null_default_on										AS [ANSINullDefault]
				,A.is_ansi_nulls_on												AS [ANSINullsEnabled]
				,A.is_ansi_padding_on											AS [ANSIPaddingEnabled]			
				,A.is_ansi_warnings_on											AS [ANSIWarningsEnabled]		
				,A.is_arithabort_on												AS [ArithmeticAbortEnabled]
				,A.is_concat_null_yields_null_on								AS [ConcatenateNullYieldsNull]			
				,A.is_db_chaining_on											AS [CrossDbOwnership]			
				,A.is_numeric_roundabort_on										AS [NumericRoundAbort]
				,A.is_quoted_identifier_on										AS [QuotedIdentifierEnabled]
				,A.is_recursive_triggers_on										AS [RecursiveTriggersEnabled]
				,A.is_fulltext_enabled											AS [FullTextEnabled]
				,A.is_trustworthy_on											AS [Trustworthy]
				,A.is_broker_enabled											AS [BrokerEnabled]
				,A.is_read_only													AS [ReadOnly]
				,0																AS [EncryptionEnabled]
				,A.user_access_desc												AS [RestrictUserAccess]
				,A.State_Desc													AS [Status]
	FROM		sys.databases A
					LEFT JOIN sys.server_principals B ON A.owner_sid = B.sid
ELSE
	SELECT		A.name															AS [Db]
				,ISNULL(B.name, 'Unknown')										AS [Owner]
				,A.collation_name												AS [Collation]
				,A.compatibility_level											AS [CompatibilityLeve]
				,A.recovery_model_desc											AS [RecoveryModel]
				,A.is_auto_close_on												AS [AutoClose]
				,A.is_auto_create_stats_on										AS [AutoCreateStatistics]
				,A.is_auto_shrink_on											AS [AutoShrink]
				,A.is_auto_update_stats_on										AS [AutoUpdateStatistics]
				,A.is_cursor_close_on_commit_on									AS [CloseCursorOnCommitEnabled]
				,A.is_ansi_null_default_on										AS [ANSINullDefault]
				,A.is_ansi_nulls_on												AS [ANSINullsEnabled]
				,A.is_ansi_padding_on											AS [ANSIPaddingEnabled]			
				,A.is_ansi_warnings_on											AS [ANSIWarningsEnabled]		
				,A.is_arithabort_on												AS [ArithmeticAbortEnabled]
				,A.is_concat_null_yields_null_on								AS [ConcatenateNullYieldsNull]			
				,A.is_db_chaining_on											AS [CrossDbOwnership]			
				,A.is_numeric_roundabort_on										AS [NumericRoundAbort]
				,A.is_quoted_identifier_on										AS [QuotedIdentifierEnabled]
				,A.is_recursive_triggers_on										AS [RecursiveTriggersEnabled]
				,A.is_fulltext_enabled											AS [FullTextEnabled]
				,A.is_trustworthy_on											AS [Trustworthy]
				,A.is_broker_enabled											AS [BrokerEnabled]
				,A.is_read_only													AS [ReadOnly]
				,A.is_encrypted													AS [EncryptionEnabled]
				,A.user_access_desc												AS [RestrictUserAccess]
				,A.State_Desc													AS [Status]
	FROM		sys.databases A
					LEFT JOIN sys.server_principals B ON A.owner_sid = B.sid
*/