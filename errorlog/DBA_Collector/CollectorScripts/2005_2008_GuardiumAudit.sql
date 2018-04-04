/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2005 & UP

	NAME:           2005_2008_AUDIT.SQL

    DESCRIPTION:    THIS SCRIPT REPORTS GUARDIUM FINGINS BASED ON THE FOLLOWING
                    TEST ID
                    
                    *   141 - NO GUEST ACCOUNTS
                    *   142 - ALLOW UPDATES TO SYSTEM TABLES IS OFF
                    *   143 - NO PUBLIC ACCESS TO AGENT JOB CONTROL PROCEDURES
                    *   144 - NO AUTHORIZATIONS GRANTED ON PROCEDURES THAT CAN LEAD TO PRIVILEGE ESCALATION
                    *   145 - NO WEB TASK AUTHORIZATIONS
                    *   146 - NO XP_READERRORLOG ACCESS
                    *   147 - NO X..P.._..C..M..D..S..H..E..L..L.. ACCESS
                    *   149 - NO DTS PACKAGE CREATION AUTHORITIES
                    *   150 - WINDOWS ADMIN IS NOT IMPLICIT MS SQL ADMIN
                    *   151 - NO OLE AUTOMATION AUTHORIZATIONS
                    *   152 - NO SP_MSSETALERTINFO ACCESS
                    *   153 - NO SELECT PRIVILEGES ON SYSTEM TABLES/VIEWS IN APPLICATION DATABASE
                    *   154 - NO INDIVIDUAL USER PRIVILEGES
                    *   155 - NO PRIVILEGES WITH THE GRANT OPTION
                    *   156 - NO SAMPLE DATABASES
                    *   157 - DEFAULT PORT NOT USED
                    *   158 - NO INDIVIDUAL USER ACCESS TO SYSCOMMENTS AND SP_HELPTEXT
                    *   159 - ONLY DBAS IN FIXED SERVER ROLES
                    *   160 - NO PUBLIC OR GUEST PREDEFINED ROLE AUTHORIZATION
                    *   162 - ALL OBJECTS OWNED BY DBO
                    *   163 - NO ORPHANED USERS
                    *   164 - NO MISMATCHED USERS
                    *   185 - USER PASSWORD POLICY IS CHECKED
                    *   186 - USER PASSWORD EXPIRATION IS CHECKED
                    *   205 - SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
                    *   210 - NO ACCESS TO GENERAL EXTENDED STORED PROCEDURES
                    *   211 - NO ACCESS TO SQLMAIL EXTENDED PROCEDURES
                    *   214 - NO ACCESS TO OLE AUTOMATION PROCEDURES'
                    *   269 - WINDOWS AUTHENTICATION
                    *   270 - NO NON-EXCEMPT PUBLIC PRIVILEGES
                    *   319 - DB_OWNER GRATNED ON USERS AND ROLES
                    *   320 - DB_SECURITYADMIN GRATNED ON USERS AND ROLES
                    *   321 - DDL GRANTED TO USER
                    *   322 - PROCEDURES GRANTED TO USER
                    *   323 - ROLE GRANTED TO ROLE
                    *  2001 - DISABLE CLR OPTION FOR MSSQL 2005 AND ABOVE
                    *  2002 - DISABLE SQL MAIL USE UNLESS NEEDED FOR MSSQL 2005 AND ABOVE
                    *  2005 - RENAME SA ACCOUNT FOR MSSQL 2005 AND ABOVE
                    *  2006 - DISABLE REMOTE ADMIN CONNECTIONS OPTION FOR MSSQL 2005 AND ABOVE
                    *  2007 - DISABLE WEB ASSISTANT PROCEDURES OPTION FOR MSSQL 2005 AND ABOVE
                    *  2010 - DISABLE AD HOC DISTRIBUTED QUERIES OPTION FOR MSSQL 2005 AND ABOVE
                    *  2011 - DISABLE X..P.._..C..M..D..S..H..E..L..L.. OPTION FOR MSSQL 2005 AND ABOVE
                    *  2012 - ENABLE COMMON CRITERIA COMPLIANCE ENABLED OPTOIN FOR MSSQL 2005 SP2 AND ABOVE
                    *  2014 - DISABLE AGENT XPS OPTION FOR MSSQL 2005 AND ABOVE
                    * PATCH - SQL SERVER PATCHING LEVEL
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        11/26/2011 1.00     INITIAL CREATION
    AB82086        12/12/2011 1.01     FIX A BUG WITH 321, WASN'T GETTING INTO 
                                       REPORT
    AB82086        12/14/2011 1.02     FIX SYNTAX WITH TEST 163                                       
    AB82086        12/16/2011 1.03     ADDED CMDSHELL CHECK, TEST 147 & 2011
    AB82086        12/17/2011 1.04     FIX TEST 2007, 2010 & 2011 TO INCLUDE
                                       IN FIX AND ROLLBACK SCRIPT THE SHOW ADVANCE
                                       OPTION                         
    AB82086        12/21/2011 1.10     ADD TEST 164, 185, 186, 210.      
    AB82086        12/22/2011 1.20     ADD TEST 322(SKIPPED FOR NOW), 2012, 145, 
                                       269 &  2014.  ALSO FIX THE COLLATE ISSUE
                                       INSTEAD OF USING SP_MSFOREACHDB, I AM
                                       USING A CURSOR.  I DO THIS SO I CAN CHECK
                                       COMPAT LEVEL SO I KNOW IF I CAN USE COLLATE
                                       OR NOT.  
    AB82086        12/23/2011 1.21     ADD TEST PATCH.  CHECKS TO MAKE SURE AT A 
                                       MINIMUM THAT IT PATCH TO THE CORRECT VERSION.
                                       FIX THE IGNORE ACCOUNTS FOR SERVER
                                       FIXED ROLES TO COMPARE THEM BY UPPER CASE
                                       DOING THIS BECAUSE SOME SQL SERVERS ARE CASE
                                       SENSITIVE.
    AB82086        12/23/2011 1.22     FIX A BUG WITH TEST 186, THE FIX SYNTAX WAS
                                       INCORRECT SHOULD BE CHECK_EXPIRATION=ON NOT
                                       CHECK_POLICY=ON        
    AB82086        12/29/2011 1.30     ADDED TEST ID 142, 153, 154     
    AB82086        12/30/2011 1.31     ADDED TEST ID 157, 158, 162     
    AB82086        01/12/2012 1.32     FIX A BUG WITH TEST ID 2012, DIDN'T RPT A 
                                       FINDING IF SQL WASN'T AT SP2, BUT IT SHOULD
                                       SINCE IT IS ENTERPRISE EDITION. FIX TO POPULATE
                                       @SQLSERVICEPACK VARIABLE, ITS NOT NEEDED AT THIS
                                       TIME BUT LEFT IT IN FOR FUTURE INFO                                                                                              
    AB82086        01/17/2012 1.33     FIX TEST 163 TO LOOK AT SQL IDS ONLY           
    AB82086        01/27/2012 1.34     ADDED TEST ID 270, 323 
    AB82086        01/31/2012 1.35     ADDED THE ABILITY TO ONLY CHECK FOR A SPECIFIC
                                       TEST ID.  ALSO ADDED TEST ID 148.                           
    AB82086        05/11/2012 1.42     ADD TEST ID 160
    AB82086        06/14/2012 1.43     UPDATED TEST ID 186 TO IGNORE TIVOLI, SA &
                                       SSAID.  UPDATED TEST ID 321 TO IGNORE THE 
                                       ##MS_% ACCOUNTS
   *******************************************************************************
*/
USE [master]
GO
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#Report') IS NOT NULL
    DROP TABLE #Report

CREATE TABLE #Report
(
		SQLServer			varchar(128)	NOT NULL
		,GuardiumTestId		varchar(10)		NOT NULL
		,GuardiumTestDesc	varchar(256)	NOT NULL
		,DbName				varchar(128)	NULL
		,Description		varchar(1024)	NULL
		,FixScript			varchar(1024)	NULL
		,RollbackScript		varchar(1024)	NULL
)

DECLARE @SQLServer			varchar(128)
		,@GuardiumTestId	varchar(10)
		,@Description		varchar(512)
		,@SQL				varchar(2000)	
		,@SQLServicePack    varchar(25)
		,@SQLVersionMajor   varchar(25)
		,@SQLVersionMinor   varchar(25)
		,@SQLVersionBuild   varchar(25)
		,@SQLVersionRev     varchar(25)
		,@SQLEdition        int
		,@DbName            varchar(128)
		,@CompatLevel       tinyint 
		,@Value				int
		,@DynamicPort		varchar(128)
		,@TCPPort			varchar(128)
		,@TestId			varchar(128)
		
SET @SQLServer = CAST(SERVERPROPERTY('MachineName') AS varchar(128)) + CASE WHEN CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) IS NULL THEN '' ELSE '\' + CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) END
SET @SQLVersionMajor = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1)
SET @SQLVersionMinor = SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) + 1, CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) + 1) - CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1 )
SET @SQLVersionBuild = SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) + 1) + 1, 4 )
SET @SQLVersionRev = SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - CHARINDEX('.', REVERSE(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)))) + 2, LEN(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))))
SET @SQLEdition = CAST(SERVERPROPERTY('EngineEdition')	AS int) -- 1 - Personal/Desktop, 2 - Standard, 3 - Enterprise, 4 - Express
SET @SQLServicePack = CAST(SERVERPROPERTY('ProductLevel') AS varchar(10))

SET @TestId = '$(TestId)'

IF @TestId = CHAR(36) + CHAR(40) + CHAR(84) + CHAR(101) + CHAR(115) + CHAR(116) + CHAR(73) + CHAR(100) + CHAR(41) -- '$.(.T.e.s.t.I.d.).'
	SET @TestId = ''			

DECLARE CURSOR_DB CURSOR FAST_FORWARD
FOR
    SELECT      name 
                ,compatibility_level
    FROM        sys.databases
    WHERE       state = 0 -- ONLINE
    ORDER BY    name

/* 
    TEST ID:      PATCH	
    DESCRIPTION:  SQL SERVER PATCHING LEVEL
*/
SET @GuardiumTestId = 'PATCH'
SET @Description = 'SQL Server Patching Level'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		IF @SQLVersionMajor = 10 -- SQL 2008
			BEGIN
				IF @SQLVersionMinor = 50 -- R2
					BEGIN
						IF @SQLVersionBuild < 2500 -- SP1
							INSERT INTO #Report
							SELECT		@SQLServer
										,@GuardiumTestId
										,@Description
										,'master'
										,'Patch level is not at least 10.50.2500.0, the patch level for this Server is ' + CAST(@SQLVersionMajor  AS varchar(10)) + '.' + CAST(@SQLVersionMinor  AS varchar(10)) + '.' + CAST(@SQLVersionBuild  AS varchar(10)) + '.' + CAST(@SQLVersionRev AS varchar(10))
										,'/* PATCH IS NEEDED */'
										,'/* FOLLOW MICROSOFT PATCHING DOCUMENTATION ON HOW TO ROLLBACK */;'
					END                                    
				ELSE
					-- R1
					BEGIN
						IF @SQLVersionBuild < 4000 -- SP2
							INSERT INTO #Report
							SELECT		@SQLServer
										,@GuardiumTestId
										,@Description
										,'master'
										,'Patch level is not at least 10.00.4000.0, the patch level for this Server is ' + CAST(@SQLVersionMajor  AS varchar(10)) + '.' + CAST(@SQLVersionMinor  AS varchar(10)) + '.' + CAST(@SQLVersionBuild  AS varchar(10)) + '.' + CAST(@SQLVersionRev AS varchar(10))
										,'/* PATCH IS NEEDED */'
										,'/* FOLLOW MICROSOFT PATCHING DOCUMENTATION ON HOW TO ROLLBACK */;'
					END                                                
			END
		ELSE
			-- SQL 2005    
			BEGIN
				IF @SQLVersionBuild < 5000 -- SP4
					INSERT INTO #Report
					SELECT		@SQLServer
								,@GuardiumTestId
								,@Description
								,'master'
								,'Patch level is not at least 9.00.5000.00, the patch level for this Server is ' + CAST(@SQLVersionMajor  AS varchar(10)) + '.' + CAST(@SQLVersionMinor  AS varchar(10)) + '.' + CAST(@SQLVersionBuild  AS varchar(10)) + '.' + CAST(@SQLVersionRev AS varchar(10))
								,'/* PATCH IS NEEDED */'
								,'/* FOLLOW MICROSOFT PATCHING DOCUMENTATION ON HOW TO ROLLBACK */;'
			END                                    
	END
	
/* 
	TEST ID:      141	
	DESCRIPTION:  NO GUEST ACCOUNTS
*/
SET @GuardiumTestId = '141'
SET @Description = 'No Guest Accounts'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @DbName NOT IN ('master', 'tempdb', 'msdb')
				BEGIN
					SET @SQL = 'USE [' + @DbName  +']'
					SET @SQL = @SQL + 
							   'IF EXISTS( '
					SET @SQL = @SQL +         'SELECT		* '
					SET @SQL = @SQL +         'FROM		    sys.database_principals			    U WITH (NOLOCK) '
					SET @SQL = @SQL +                           'JOIN sys.database_permissions	P WITH (NOLOCK) ON U.principal_id = P.grantee_principal_id '
					SET @SQL = @SQL +         'WHERE		U.name = ''guest'' '
					SET @SQL = @SQL +         '  AND		P.state_desc = ''GRANT'' '
					SET @SQL = @SQL +         '  AND		P.permission_name = ''CONNECT'' '

					SET @SQL = @SQL +    ') '
					SET @SQL = @SQL +         'SELECT ''' + @SQLServer + ''', ''' + @GuardiumTestId + ''', ''' + @Description + ''', ''' + @DbName + ''', ''Guest account exist on database [' + @DbName + '].'', ''USE [' + @DbName + '];REVOKE CONNECT TO [guest];'', ''USE [' + @DbName + '];GRANT CONNECT TO [guest];'' '

					INSERT INTO #Report 
					EXECUTE (@SQL)
				END

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
 /* 
    TEST ID:      142        	
    DESCRIPTION:  ALLOW UPDATES TO SYSTEM TABLES IS OFF
*/
SET @GuardiumTestId = '142'  
SET @Description = 'Allow updates to system tables is off'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "allow updates" is enabled'
					,'USE [master];EXECUTE sp_configure ''allow updates'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''allow updates'', 1;RECONFIGURE'
		 FROM		sys.configurations 
		WHERE		name = 'allow updates' 
		  AND		value_in_use = 1
	END

/* 
	TEST ID:      143	
	DESCRIPTION:  NO PUBLIC ACCESS TO AGENT JOB CONTROL PROCEDURES
*/
SET @GuardiumTestId = '143'
SET @Description = 'No public access to agent job control procedures'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Public role has ' + P.permission_name COLLATE DATABASE_DEFAULT + ' permissions on Object ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' (' + O.type_desc + ') in database [master].'
					,'USE [master];REVOKE ' +  P.permission_name COLLATE DATABASE_DEFAULT  + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO [public] CASCADE;'
					,'USE [master];GRANT ' + P.permission_name COLLATE DATABASE_DEFAULT  + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO [public];'
		FROM		master.sys.schemas S
						JOIN master.sys.all_objects O ON S.schema_id = O.schema_id
						JOIN master.sys.database_permissions P ON O.object_id = P.major_id
		WHERE		O.name IN ('sp_add_job', 'sp_add_jobstep', 'sp_add_jobserver','sp_start_job','xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.grantee_principal_id = 0 -- Public Role
		  AND		P.state NOT IN ('D', 'R')    
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'msdb'
					,'Public role has ' + P.permission_name + ' permissions on Object ' + QUOTENAME(O.name) + ' (' + O.type_desc + ') in database [msdb].'
					,'USE [msdb];REVOKE ' +  P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO [public] CASCADE;'
					,'USE [msdb];GRANT ' + P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO [public];'
		FROM		msdb.sys.schemas S
						JOIN msdb.sys.all_objects O ON S.schema_id = O.schema_id
						JOIN msdb.sys.database_permissions P ON O.object_id = P.major_id
		WHERE		O.name IN ('sp_add_job', 'sp_add_jobstep', 'sp_add_jobserver','sp_start_job','xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.grantee_principal_id = 0 -- Public Role
		  AND		P.state NOT IN ('D', 'R')  
	END
	
/* 
	TEST ID:      144	
	DESCRIPTION:  NO AUTHORIZATIONS GRANTED ON PROCEDURES THAT CAN LEAD TO PRIVILEGE ESCALATION
*/
SET @GuardiumTestId = '144'
SET @Description = 'No authorizations granted on procedures that can lead to privilege escalation.'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + ' (' + A.type_desc + ') has ' + P.permission_name + ' permissions on Object ' + QUOTENAME(O.name) + ' (' + O.type_desc + ') in database [master].'
					,'USE [master];REVOKE ' + P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ' CASCADE;'
					,'USE [master];GRANT ' + P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ';'
		FROM		master.sys.schemas S
						JOIN master.sys.all_objects O	ON S.schema_id = O.schema_id
						JOIN master.sys.database_permissions P ON O.object_id = P.major_id
						JOIN master.sys.database_principals A ON P.grantee_principal_id = A.principal_id
		WHERE		O.name IN ('xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.state NOT IN ('D', 'R')    
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'msdb'
					,QUOTENAME(A.name) + ' (' + A.type_desc + ') has ' + P.permission_name + ' permissions on Object ' + QUOTENAME(O.name) + ' (' + O.type_desc + ') in database [msdb].'
					,'USE [msdb];REVOKE ' + P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ' CASCADE;'
					,'USE [msdb];GRANT ' + P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ';'
		FROM		msdb.sys.schemas S
						JOIN msdb.sys.all_objects O	ON S.schema_id = O.schema_id
						JOIN msdb.sys.database_permissions P ON O.object_id = P.major_id
						JOIN msdb.sys.database_principals A ON P.grantee_principal_id = A.principal_id
		WHERE		O.name IN ('xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.state NOT IN ('D', 'R')  
	END
	
/* 
	TEST ID:      145	
	DESCRIPTION:  NO WEB TASK AUTHORIZATIONS
*/
SET @GuardiumTestId = '145'
SET @Description = 'No web task authorizations'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'[public] (DATABASE_ROLE) has ' + B.permission_name + ' permissions on Object dbo.' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' in database [master].'
					,'USE [msdb];REVOKE ' + B.permission_name + ' ON dbo.' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' TO [public] CASCADE;'
					,'USE [msdb];GRANT ' + B.permission_name + ' ON dbo.' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' TO [public];'
		FROM		msdb.sys.all_objects  A
						JOIN msdb.sys.database_permissions B ON A.object_id = B.major_id
		WHERE		A.name = 'mswebtasks'
		  AND		B.state NOT IN ('D', 'R')   
		  AND		B.grantee_principal_id = 0 -- Public Role
	END

/* 
	TEST ID:      146	
	DESCRIPTION:  NO XP_READERRORLOG ACCESS
*/
SET @GuardiumTestId = '146'
SET @Description = 'No xp_readerrorlog access'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(D.name) + ' (' + D.type_desc + ') has ' + C.permission_name  COLLATE DATABASE_DEFAULT + ' permissions on ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' (' + B.type_desc + ') in database [master].'
					,'USE [master];REVOKE ' + C.permission_name COLLATE DATABASE_DEFAULT + ' ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' TO ' + QUOTENAME(D.name) + ' CASCADE;'
					,'USE [master];GRANT ' + C.permission_name COLLATE DATABASE_DEFAULT + ' ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' TO ' + QUOTENAME(D.name) + ';'			
		FROM		sys.schemas A
						JOIN sys.all_objects B ON A.schema_id = B.schema_id
						JOIN sys.database_permissions C ON B.object_id = C.major_id
						JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id
		WHERE		B.name = 'xp_readerrorlog'
		  AND		C.state NOT IN ('D', 'R')  
          AND       D.type IN ('S', 'U', 'G')                            
	END
	
/* 
	TEST ID:      147	
	DESCRIPTION:  NO X..P.._..C..M..D..S..H..E..L..L ACCESS
*/
SET @GuardiumTestId = '147'
SET @Description = 'No ' + CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108) + ' access'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(D.name) + ' (' + D.type_desc + ') has ' + C.permission_name  COLLATE DATABASE_DEFAULT + ' permissions on ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' (' + B.type_desc + ') in database [master].'
					,'USE [master];REVOKE ' + C.permission_name COLLATE DATABASE_DEFAULT + ' ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' TO ' + QUOTENAME(D.name) + ' CASCADE;'
					,'USE [master];GRANT ' + C.permission_name COLLATE DATABASE_DEFAULT + ' ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' TO ' + QUOTENAME(D.name) + ';'			
		FROM		sys.schemas A
						JOIN sys.all_objects B ON A.schema_id = B.schema_id
						JOIN sys.database_permissions C ON B.object_id = C.major_id
						JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id
		WHERE		B.name = CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108)
		  AND		C.state NOT IN ('D', 'R')  
	END

/* 
	TEST ID:      148	
	DESCRIPTION:  NO AGENT JOB CREATION AUTHORITIES
*/
SET @GuardiumTestId = '148'
SET @Description = 'No agent job creation authorities'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'msdb'
					,'Public role has ' + P.permission_name + ' permissions on Object ' + QUOTENAME(O.name) + ' (' + O.type_desc + ') in database [msdb].'
					,'USE [msdb];REVOKE ' +  P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO [public] CASCADE;'
					,'USE [msdb];GRANT ' + P.permission_name + ' ON ' + QUOTENAME(S.name) + '.' + QUOTENAME(O.name) + ' TO [public];'
		FROM		msdb.sys.schemas S
						JOIN msdb.sys.all_objects O ON S.schema_id = O.schema_id
						JOIN msdb.sys.database_permissions P ON O.object_id = P.major_id
		WHERE		O.name = 'sp_add_job'
		  AND		P.grantee_principal_id = 0 -- Public Role
		  AND		P.state NOT IN ('D', 'R')  
	END
	
/* 
	TEST ID:      149	
	DESCRIPTION:  NO DTS PACKAGE CREATION AUTHORITIES
*/
SET @GuardiumTestId = '149'
SET @Description = 'No DTS package creation authorities'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'msdb'
					,'[Public] (Database Role) has EXECUTE permissions on msdb.dbo.sp_get_dtspackage.'
					,'USE [msdb];REVOKE EXECUTE ON sp_get_dtspackage TO [Public] CASCADE;'
					,'USE [msdb];GRANT EXECUTE ON sp_get_dtspackage TO [Public];'
		FROM		msdb.sys.database_permissions A
						JOIN msdb.sys.database_principals B ON A.grantee_principal_id = B.principal_id
		WHERE		OBJECT_NAME(A.major_id) = 'sp_get_dtspackage'
		  AND		A.state NOT IN ('D', 'R')	  
		  AND		A.permission_name = 'EXECUTE'
		  AND		A.grantee_principal_id = 0 -- Public Database Role
	END  
    
/* 
	TEST ID:      150	
	DESCRIPTION:  WINDOWS ADMIN IS NOT IMPLICIT MS SQL ADMIN
*/  
SET @GuardiumTestId = '150'
SET @Description = 'Windows admin is not implicit MS SQL Admin'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'The [BuiltIn\Administrators] account has sysadmin access.'
		            ,'USE [master];DECLARE @Message varchar(256); IF NOT EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''US\W9_SQL_DBA_AD'' AND sysadmin = 1) BEGIN SET @Message = ''BUILTIN\Administrators account cannot be removed, the US\W9_SQL_DBA_AD account does not exist or does not have sysadmin.  Please add this group account manually and remove BUILTIN\Administrators.'' RAISERROR (@Message, 18, 1) END ELSE BEGIN IF EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''BUILTIN\ADMINISTRATORS'') DROP LOGIN [BUILTIN\ADMINISTRATORS] END ' 
		            ,'USE [master];EXECUTE sp_grantlogin ''BUILTIN\ADMINISTRATORS'';EXECUTE master..sp_addsrvrolemember @loginame = N''BUILTIN\ADMINISTRATORS'', @rolename = N''sysadmin'' '
		FROM		sys.syslogins 
		WHERE		UPPER(name) = 'BUILTIN\ADMINISTRATORS' 
		  AND		sysadmin = 1  
	END

/* 
	TEST ID:      151	
	DESCRIPTION:  NO OLE AUTOMATION AUTHORIZATIONS
*/  
SET @GuardiumTestId = '151'
SET @Description = 'No OLE automation authorizations'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,B.name + ' (' + B.type_desc + ') has EXECUTE permissions on ' + OBJECT_NAME(A.major_id)
					,'USE [master];REVOKE EXECUTE ON ' + OBJECT_NAME(A.major_id) + ' TO ' + QUOTENAME(B.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON ' + OBJECT_NAME(A.major_id) + ' TO ' + QUOTENAME(B.name) + ';'
		FROM		sys.database_permissions A
						JOIN sys.database_principals B ON A.grantee_principal_id = B.principal_id
		WHERE		OBJECT_NAME(A.major_id) IN ('sp_OACreate','sp_OAMethod','sp_OADestroy','sp_OASetProperty','sp_OAGetErrorInfo','sp_OAStop','sp_OAGetProperty')
		  AND		A.state NOT IN ('D', 'R')
	END

/* 
	TEST ID:      152	
	DESCRIPTION:  NO SP_MSSETALERTINFO ACCESS
*/
SET @GuardiumTestId = '152'
SET @Description = 'No sp_mssetalertinfo access'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'[Public] (Database Role) has EXECUTE permissions on sp_MSsetalertinfo.'
					,'USE [msdb];REVOKE EXECUTE ON sp_MSsetalertinfo TO [Public] CASCADE;'
					,'USE [msdb];GRANT EXECUTE ON sp_MSsetalertinfo TO [Public];'
		FROM		sys.all_objects A
						JOIN sys.database_permissions B ON A.object_id = B.major_id
		WHERE		A.name = 'sp_MSsetalertinfo'
		  AND		B.state NOT IN ('D', 'R')
		  AND		B.grantee_principal_id = 0 -- Public Role
		  AND		B.permission_name = 'EXECUTE'
	END
	
/* 
	TEST ID:      153
	DESCRIPTION:  NO SELECT PRIVILEGES ON SYSTEM TABLES/VIEWS IN APPLICAITON DATABASES
*/
SET @GuardiumTestId = '153'
SET @Description = 'No Select Privileges On System Tables/Views In Application Databases'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @DbName NOT IN ('master', 'msdb', 'model', 'tempdb')
				BEGIN
					IF @CompatLevel < 80
						BEGIN
							SET @SQL = 'USE [' + @DbName + ']; '
							SET @SQL = @SQL + 
									   'SELECT ''' + @SQLServer + ''' '
							SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
							SET @SQL = @SQL + ',''' + @Description + ''' '
							SET @SQL = @SQL + ',''' + @DbName + ''' '
							SET @SQL = @SQL + ',QUOTENAME(C.name) + '' ('' + CASE WHEN C.isntname = 1 THEN CASE WHEN C.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE ''WINDOWS_USER'' END WHEN C.issqlrole = 1 THEN ''DATABASE_ROLE'' WHEN C.isapprole = 1 THEN ''APPLCATION_ROLE'' ELSE ''SQL_USER'' END + '') has SELECT permissions on '' + QUOTENAME(''' + @DbName + ''') + ''.'' + QUOTENAME(D.name) + ''.'' +  QUOTENAME(A.name) + ''.'' '
							SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE SELECT ON '' + QUOTENAME(D.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' CASCADE;''  '
							SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT SELECT ON '' + QUOTENAME(D.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '';''  '
							SET @SQL = @SQL + 
									   'FROM dbo.sysobjects A '
							SET @SQL = @SQL + 'JOIN dbo.sysprotects B ON A.id = B.id '
							SET @SQL = @SQL + 'JOIN dbo.sysusers C ON B.uid = C.uid '
							SET @SQL = @SQL + 'JOIN dbo.sysusers D ON A.uid = D.uid '
							SET @SQL = @SQL + 
									   'WHERE B.protecttype <> 206 '
							SET @SQL = @SQL + 
									   '  AND a.xtype = ''S'' '
							SET @SQL = @SQL + 
									   '  AND B.action = 193 '
							SET @SQL = @SQL + 
									   '  AND UPPER(C.name) <> ''GDMMONITOR'' '

							INSERT INTO #Report
							EXECUTE (@SQL)
						END            
					ELSE
						BEGIN
							SET @SQL = 'USE [' + @DbName + ']; '
							SET @SQL = @SQL + 
									   'SELECT ''' + @SQLServer + ''' '
							SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
							SET @SQL = @SQL + ',''' + @Description + ''' '
							SET @SQL = @SQL + ',''' + @DbName + ''' '
							SET @SQL = @SQL + ',QUOTENAME(C.name) + '' ('' + C.type_desc COLLATE DATABASE_DEFAULT + '') has SELECT permissions on '' + QUOTENAME(''' + @DbName + ''') + ''.'' + QUOTENAME(S.name) + ''.'' +  QUOTENAME(A.name) + ''.'' '
							SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE SELECT ON '' + QUOTENAME(S.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' CASCADE;''  '
							SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT SELECT ON '' + QUOTENAME(S.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '';''  '
							SET @SQL = @SQL + 
									   'FROM sys.schemas S '
							SET @SQL = @SQL + 'JOIN sys.all_objects A ON S.schema_id = A.schema_id '
							SET @SQL = @SQL + 'JOIN sys.database_permissions B ON A.object_id = B.major_id '
							SET @SQL = @SQL + 'JOIN sys.database_principals C ON B.grantee_principal_id = C.principal_id '
							SET @SQL = @SQL + 
									   'WHERE B.major_id < 0 '
							SET @SQL = @SQL + 
									   '  AND B.class = 1 '
							SET @SQL = @SQL +
										 'AND B.state IN (''G'', ''W'') '
							SET @SQL = @SQL +
										 'AND B.permission_name = ''SELECT'' '
							SET @SQL = @SQL +
										 'AND UPPER(C.name) <> ''GDMMONITOR'' '
				             
							INSERT INTO #Report
							EXECUTE (@SQL)
						END
				END
				
			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
/* 
	TEST ID:      154	
	DESCRIPTION:  NO INDIVIDUAL USER PRIVILEGES
*/
SET @GuardiumTestId = '154'  
SET @Description = 'No individual user privileges'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,QUOTENAME(D.name) + '' ('' + CASE WHEN D.isntname = 1 THEN CASE WHEN D.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE ''WINDOWS_USER'' END WHEN D.issqlrole = 1 THEN ''DATABASE_ROLE'' WHEN D.isapprole = 1 THEN ''APPLCATION_ROLE'' ELSE ''SQL_USER'' END + '') has '' + CASE C.action WHEN  26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE '' + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT ''  + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
					SET @SQL = @SQL + 
							   'FROM		sysusers A '
					SET @SQL = @SQL +          'JOIN sysobjects B ON A.uid = B.uid '
					SET @SQL = @SQL +          'JOIN sysprotects C ON B.id = C.id '
					SET @SQL = @SQL +          'JOIN sysusers D ON C.uid = D.uid '
					SET @SQL = @SQL +      
							   'WHERE		D.issqluser = 1 '
					SET @SQL = @SQL +      
								 'AND		C.protecttype <> 206 '
				END                
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(D.name) + '' ('' + D.type_desc + '') has '' + QUOTENAME(C.permission_name) COLLATE DATABASE_DEFAULT  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' ('' + B.type_desc + '')'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE '' +  C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT '' + C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
					SET @SQL = @SQL + 
							   'FROM  sys.schemas A '
					SET @SQL = @SQL +   'JOIN sys.all_objects B ON A.schema_id = B.schema_id '
					SET @SQL = @SQL +   'JOIN sys.database_permissions C ON B.object_id = C.major_id '
					SET @SQL = @SQL +   'JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id '
					SET @SQL = @SQL +      
							   'WHERE D.type IN (''S'') '
					SET @SQL = @SQL +      
								 'AND C.state IN (''G'', ''W'') '
				END

			INSERT INTO #Report 
			EXECUTE (@SQL)

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END

/* 
	TEST ID:      155	
	DESCRIPTION:  NO PRIVILEGES WITH THE GRANT OPTION
*/
SET @GuardiumTestId = '155'
SET @Description = 'No privileges with the grant option'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + ']; '
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(C.name) + '' has WITH GRANT option setup on '' + QUOTENAME(''' + @DbName + ''') + ''.'' + QUOTENAME(D.name) + ''.'' +  QUOTENAME(A.name) + ''.'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE GRANT OPTION FOR '' + CASE B.action WHEN 26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE ''UNKNOWN'' END   + '' ON '' + QUOTENAME(D.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' CASCADE;''  '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT '' + CASE B.action WHEN 26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE ''UNKNOWN'' END + '' ON '' + QUOTENAME(D.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' WITH GRANT OPTION;'' '
					SET @SQL = @SQL + 
							   'FROM dbo.sysobjects A '
					SET @SQL = @SQL + 'JOIN dbo.sysprotects B ON A.id = B.id '
					SET @SQL = @SQL + 'JOIN dbo.sysusers C ON B.uid = C.uid '
					SET @SQL = @SQL + 'JOIN dbo.sysusers D ON A.uid = D.uid '
					SET @SQL = @SQL + 
							   'WHERE B.protecttype = 204 '

					INSERT INTO #Report
					EXECUTE (@SQL)
				END            
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + ']; '
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,QUOTENAME(D.name) + '' ('' + D.type_desc + '') has WITH GRANT option setup for '' + C.permission_name COLLATE DATABASE_DEFAULT + '' permission on '' + QUOTENAME(''' + @DbName + ''') + ''.'' + QUOTENAME(A.name) + ''.'' +  QUOTENAME(B.name) + '' ('' + B.type_desc + '') .'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE GRANT OPTION FOR '' + C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO '' + QUOTENAME(D.name) + '' CASCADE;''  '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT '' + C.permission_name COLLATE DATABASE_DEFAULT + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO '' + QUOTENAME(D.name) + '' WITH GRANT OPTION;'' '
					SET @SQL = @SQL + 
							   'FROM		[' + @DbName + '].sys.schemas A '
					SET @SQL = @SQL + '	       JOIN [' + @DbName + '].sys.all_objects B ON A.schema_id = B.schema_id '
					SET @SQL = @SQL + '	       JOIN [' + @DbName + '].sys.database_permissions C ON B.object_id = C.major_id '
					SET @SQL = @SQL + '	       JOIN [' + @DbName + '].sys.database_principals D ON C.grantee_principal_id = D.principal_id '
					SET @SQL = @SQL + 
							   'WHERE		C.state = ''W'' '
					SET @SQL = @SQL + 
							   '  AND		B.type <> ''S'' /* SYSTEM_TABLE */ '

					INSERT INTO #Report 
					EXECUTE (@SQL)

					SET @SQL = 'USE [' + @DbName + ']; '
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,QUOTENAME(C.name) + '' ('' + C.type_desc + '') has WITH GRANT option setup for '' + B.permission_name COLLATE DATABASE_DEFAULT + '' permission on '' + QUOTENAME(''' + @DbName + ''') + ''.'' + QUOTENAME(A.name) + '' (SCHEMA) .'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE GRANT OPTION FOR '' + B.permission_name COLLATE DATABASE_DEFAULT + '' ON SCHEMA::'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' CASCADE;''  '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT '' + B.permission_name COLLATE DATABASE_DEFAULT + '' ON SCHEMA::'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' WITH GRANT OPTION;'' '
					SET @SQL = @SQL + 
							   'FROM		[' + @DbName + '].sys.schemas A '
					SET @SQL = @SQL + '	       JOIN [' + @DbName + '].sys.database_permissions B ON A.schema_id = B.major_id '
					SET @SQL = @SQL + '	       JOIN [' + @DbName + '].sys.database_principals C ON B.grantee_principal_id = C.principal_id '
					SET @SQL = @SQL + 
							   'WHERE		B.state = ''W'' '
					SET @SQL = @SQL + 
							   '  AND		B.class = 3 /* SCHEMA */ '

					INSERT INTO #Report 
					EXECUTE (@SQL)
				END

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END		

/* 
	TEST ID:      156	
	DESCRIPTION:  NO SAMPLE DATABASES
*/
SET @GuardiumTestId = '156'
SET @Description = 'No sample databases'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,name
					,'Sample database ' + name + ' exists.'
					,'/* MAKE A BACKUP BEFORE DROPPING DATABASE */ USE [master];DROP DATABASE ' + name 
					,'RESTORE FROM BACKUP'
		FROM		sys.databases
		WHERE		name IN (
								'Northwind', 'pubs', 
								'AdventureWorks', 'AdventureWorksAS', 'AdventureWorksDW', 'AdventureWorksLT',
								'AdventureWorks2008', 'AdventureWorksAS2008', 'AdventureWorksDW2008', 'AdventureWorksLT2008', 
								'AdventureWorks2008R2', 'AdventureWorksAS2008R2', 'AdventureWorksDW2008R2', 'AdventureWorksLT2008R2'
							)
	END
	
/* 
	TEST ID:      157	
	DESCRIPTION:  DEFAULT PORT NOT USED
*/
SET @GuardiumTestId = '157'
SET @Description = 'Default Port Not Used'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
									,N'Enabled'
									,@Value OUTPUT
									,'NO_OUTPUT'

		IF @Value = 1
			BEGIN
				EXECUTE xp_instance_regread 'HKEY_LOCAL_MACHINE' 
											,'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\'
											,'TcpDynamicPorts'
											,@DynamicPort OUTPUT
											,'NO_OUTPUT'
				 
				EXECUTE xp_instance_regread 'HKEY_LOCAL_MACHINE'
											,'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\'
											,'TcpPort'
											,@TCPPort OUTPUT
											,'NO_OUTPUT'				
					
				
				IF @TCPPort = 1433
					INSERT INTO #Report
					SELECT		@SQLServer
								,@GuardiumTestId
								,@Description
								,'master'
								,'TCP/IP connection to this server is configured to use the default port 1433, please fix the static port.'
								,'/* PLEASE CONFIGURE THE STATIC PORT PER OUR STANDARDS, YOU WILL NEED TO USE SQL SERVER CONFIGURATION MANAGER AND GO TO SQL SERVER NETWORK CONFIGURATION TO MAKE THIS CHANGE*/'
								,'/* CHANGE THE PORT BACK TO 1433 USING SQL SERVER CONFIGURATION MANAGER AND GO TO SQL SERVER NETWORK CONFIGURATION TO MAKE THIS CHANGE */'


				IF @DynamicPort = 1433
					INSERT INTO #Report
					SELECT		@SQLServer
								,@GuardiumTestId
								,@Description
								,'master'
								,'TCP/IP connection to this server is configured to use the default port 1433, please fix the dynamic port.'
								,'/* PLEASE CONFIGURE THE STATIC PORT PER OUR STANDARDS, YOU WILL NEED TO USE SQL SERVER CONFIGURATION MANAGER AND GO TO SQL SERVER NETWORK CONFIGURATION TO MAKE THIS CHANGE*/'
								,'/* CHANGE THE PORT BACK TO 1433 USING SQL SERVER CONFIGURATION MANAGER AND GO TO SQL SERVER NETWORK CONFIGURATION TO MAKE THIS CHANGE */'
			END
	END
	
/* 
	TEST ID:      158	
	DESCRIPTION:  NO INDIVIDUAL USER ACCESS TO SYSCOMMENTS AND SP_HELPTEXT
*/
SET @GuardiumTestId = '158'
SET @Description = 'No invidual user access to syscomments and sp_helptext.'

/*

-- NEEDS MORE CODING TO BE DONE, THERE ARE OTHER OBJECTS TO LOOK AT sys.sql_modules, sys.computed_columns, sys.check_constraints & sys_default_constraints
-- ALSO NEED TO SEE IF THE ACCOUNT HAS SPECIFIC PERMISSIONS TO EVEN LOOK AT THE DEFINITION OF THESE COLUMNS, FOR EXAMPLE VIEW DEFINITION, CONTROL, ALTER, DB_DDLADMIN, ETC.

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + ']; '
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(C.name) + '' ('' + CASE WHEN C.isntname = 1 THEN CASE WHEN C.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE ''WINDOWS_USER'' END WHEN C.issqlrole = 1 THEN ''DATABASE_ROLE'' WHEN C.isapprole = 1 THEN ''APPLCATION_ROLE'' ELSE ''SQL_USER'' END + '') has SELECT permissions on '' + QUOTENAME(''' + @DbName + ''') + ''.'' + QUOTENAME(D.name) + ''.'' +  QUOTENAME(A.name) + ''.'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE '' + CASE B.action WHEN 193 THEN ''SELECT'' WHEN 224 THEN ''EXECUTE'' END  + '' ON '' + QUOTENAME(D.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' CASCADE;''  '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT '' + CASE B.action WHEN 193 THEN ''SELECT'' WHEN 224 THEN ''EXECUTE'' END + '' ON '' + QUOTENAME(D.name) + ''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '';''  '
					SET @SQL = @SQL + 
							   'FROM dbo.sysobjects A '
					SET @SQL = @SQL + 'JOIN dbo.sysprotects B ON A.id = B.id '
					SET @SQL = @SQL + 'JOIN dbo.sysusers C ON B.uid = C.uid '
					SET @SQL = @SQL + 'JOIN dbo.sysusers D ON A.uid = D.uid '
					SET @SQL = @SQL + 
							   'WHERE B.protecttype <> 206 '
					SET @SQL = @SQL + 
							   '  AND A.name IN (''sql_modules'', ''syscomments'', ''sp_helptext'')  '
				END
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + ']; '
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(D.name) + '' ('' + D.type_desc COLLATE DATABASE_DEFAULT + '') has '' + C.permission_name COLLATE DATABASE_DEFAULT + '' permissions on '' + QUOTENAME(A.name) + ''.'' +  QUOTENAME(B.name) + ''.'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE '' + C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO '' + QUOTENAME(D.name) + '' CASCADE;''  '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT '' + C.permission_name COLLATE DATABASE_DEFAULT + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO '' + QUOTENAME(D.name) + '';''  '
					SET @SQL = @SQL + 
							   'FROM sys.schemas A '
					SET @SQL = @SQL + 'JOIN sys.all_objects  B ON A.schema_id = B.schema_id '
					SET @SQL = @SQL + 'JOIN sys.database_permissions C ON B.object_id = C.major_id '
					SET @SQL = @SQL + 'JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id '
					SET @SQL = @SQL + 
							   'WHERE C.state NOT IN (''D'', ''R'') '
					SET @SQL = @SQL + 
							   '  AND B.name IN (''sql_modules'', ''syscomments'', ''sp_helptext'')  '
				END
				
			INSERT INTO #Report
			EXECUTE (@SQL)
				
			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
*/

/* 
	TEST ID:      159	
	DESCRIPTION:  ONLY DBAS IN FIXED SERVER ROLES
*/
SET @GuardiumTestId = '159'
SET @Description = 'Only DBAs in fixed server roles'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		CREATE TABLE #DBA_ExclusionList
		(
			Account		varchar(128)
		)

		INSERT INTO #DBA_ExclusionList VALUES('sa')
		INSERT INTO #DBA_ExclusionList VALUES('ssaid')
		INSERT INTO #DBA_ExclusionList VALUES('US\SQLDBACLUSTERS')
		INSERT INTO #DBA_ExclusionList VALUES('US\SRCIBMSQL')
		INSERT INTO #DBA_ExclusionList VALUES('US\SRCIBMSQL2')
		INSERT INTO #DBA_ExclusionList VALUES('ANTHEMROOT\SVCSQLCLUSTER')
		INSERT INTO #DBA_ExclusionList VALUES('ANTHEMROOT\SQLDBA')
		INSERT INTO #DBA_ExclusionList VALUES('DISTRIBUTOR_ADMIN')
		INSERT INTO #DBA_ExclusionList VALUES('US\DEV_DBA')
		INSERT INTO #DBA_ExclusionList VALUES('US\DEV_DBA_AD')
		INSERT INTO #DBA_ExclusionList VALUES('US\w9_sql_dba_ad')
		INSERT INTO #DBA_ExclusionList VALUES('US\w9_sql_dba')
		INSERT INTO #DBA_ExclusionList VALUES('US\AA03279')		-- White, Brian J
		INSERT INTO #DBA_ExclusionList VALUES('US\AA03279AD')		-- White, Brian J
		INSERT INTO #DBA_ExclusionList VALUES('US\AA71727')		-- MODASRA, ARUN
		INSERT INTO #DBA_ExclusionList VALUES('US\AA71727AD')		-- MODASRA, ARUN
		INSERT INTO #DBA_ExclusionList VALUES('US\AA79441')		-- Khalidh, Shafeek
		INSERT INTO #DBA_ExclusionList VALUES('US\AA79441AD')		-- Khalidh, Shafeek
		INSERT INTO #DBA_ExclusionList VALUES('US\aa96644')		-- Terebecki, Steve
		INSERT INTO #DBA_ExclusionList VALUES('US\aa96644AD')		-- Terebecki, Steve
		INSERT INTO #DBA_ExclusionList VALUES('US\AB01886')		-- BAILEY, SARAH J
		INSERT INTO #DBA_ExclusionList VALUES('US\AB01886ad')		-- BAILEY, SARAH J
		INSERT INTO #DBA_ExclusionList VALUES('US\ab21079')		-- Jackson, Jerry
		INSERT INTO #DBA_ExclusionList VALUES('US\ab21079AD')		-- Jackson, Jerry
		INSERT INTO #DBA_ExclusionList VALUES('US\AB75155')		-- Saeger, Kristin L.
		INSERT INTO #DBA_ExclusionList VALUES('US\AB75155AD')		-- Saeger, Kristin L.
		INSERT INTO #DBA_ExclusionList VALUES('US\AB78178')		-- Patil, Kiran M.
		INSERT INTO #DBA_ExclusionList VALUES('US\AB78178AD')		-- Patil, Kiran M.
		INSERT INTO #DBA_ExclusionList VALUES('US\AB78179')		-- Thumma, Amani
		INSERT INTO #DBA_ExclusionList VALUES('US\AB78179AD')		-- Thumma, Amani
		INSERT INTO #DBA_ExclusionList VALUES('US\AB82086')		-- WILLIAMS, ANTHONY L.
		INSERT INTO #DBA_ExclusionList VALUES('US\AB82086AD')		-- WILLIAMS, ANTHONY L.
		INSERT INTO #DBA_ExclusionList VALUES('US\AC03562')		-- Adusumilli, Satyam
		INSERT INTO #DBA_ExclusionList VALUES('US\AC03562AD')		-- Adusumilli, Satyam
		INSERT INTO #DBA_ExclusionList VALUES('US\AC13939')		-- Vaddi, Kim
		INSERT INTO #DBA_ExclusionList VALUES('US\AC13939AD')		-- Vaddi, Kim
		INSERT INTO #DBA_ExclusionList VALUES('US\AC27535')		-- Prashanth, Pavan
		INSERT INTO #DBA_ExclusionList VALUES('US\AC27535AD')		-- Prashanth, Pavan
		INSERT INTO #DBA_ExclusionList VALUES('US\AC28423')		-- Kuchipudi, Swagath
		INSERT INTO #DBA_ExclusionList VALUES('US\AC28423AD')		-- Kuchipudi, Swagath
		INSERT INTO #DBA_ExclusionList VALUES('US\AC29488')		-- Boddepalli, Ramu
		INSERT INTO #DBA_ExclusionList VALUES('US\AC29488AD')		-- Boddepalli, Ramu
		INSERT INTO #DBA_ExclusionList VALUES('US\AC29489')		-- Bandi, Vijay
		INSERT INTO #DBA_ExclusionList VALUES('US\AC29489AD')		-- Bandi, Vijay
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33108')		-- Odonkor, Solomon
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33108AD')		-- Odonkor, Solomon
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33109')		-- Richardson, Jim
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33109AD')		-- Richardson, Jim
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33111')		-- Sawyer, Tom
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33111AD')		-- Sawyer, Tom
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33680')		-- Saseendrannair, Sabarinath
		INSERT INTO #DBA_ExclusionList VALUES('US\AC33680AD')		-- Saseendrannair, Sabarinath
		INSERT INTO #DBA_ExclusionList VALUES('US\AC34451')		-- Dubey, Pawan Kumar
		INSERT INTO #DBA_ExclusionList VALUES('US\AC34451AD')		-- Dubey, Pawan Kumar
		INSERT INTO #DBA_ExclusionList VALUES('US\AC34452')		-- Muthusamy, Vijayakumar
		INSERT INTO #DBA_ExclusionList VALUES('US\AC34452AD')		-- Muthusamy, Vijayakumar
		INSERT INTO #DBA_ExclusionList VALUES('US\AC34586')		-- SK, Vali
		INSERT INTO #DBA_ExclusionList VALUES('US\AC34586AD')		-- SK, Vali
		INSERT INTO #DBA_ExclusionList VALUES('US\AC35225')		-- Paul, Babu
		INSERT INTO #DBA_ExclusionList VALUES('US\AC35225AD')		-- Paul, Babu
		INSERT INTO #DBA_ExclusionList VALUES('US\AC37258')		-- PILI, JIMMY G.
		INSERT INTO #DBA_ExclusionList VALUES('US\AC37258AD')		-- PILI, JIMMY G.
		INSERT INTO #DBA_ExclusionList VALUES('US\AC37259')		-- SHANMUGHAM, BIPIN
		INSERT INTO #DBA_ExclusionList VALUES('US\AC37259AD')		-- SHANMUGHAM, BIPIN
		INSERT INTO #DBA_ExclusionList VALUES('US\AC37351')		-- Chilukuri, Sharad
		INSERT INTO #DBA_ExclusionList VALUES('US\AC37351AD')		-- Chilukuri, Sharad
		INSERT INTO #DBA_ExclusionList VALUES('US\AC43787')		-- Subramanian, Sriram
		INSERT INTO #DBA_ExclusionList VALUES('US\AC43787AD')		-- Subramanian, Sriram
		INSERT INTO #DBA_ExclusionList VALUES('US\AC43788')		-- PALADUGU, VEERANJANEYULU
		INSERT INTO #DBA_ExclusionList VALUES('US\AC43788AD')		-- PALADUGU, VEERANJANEYULU
		INSERT INTO #DBA_ExclusionList VALUES('US\AC45555')		-- James, Suja
		INSERT INTO #DBA_ExclusionList VALUES('US\AC45555AD')		-- James, Suja
		INSERT INTO #DBA_ExclusionList VALUES('US\JEGREEN')		-- Green, James
		INSERT INTO #DBA_ExclusionList VALUES('US\JEGREENAD')		-- Green, James
		INSERT INTO #DBA_ExclusionList VALUES('US\nichoby')		-- Nichols, Jay
		INSERT INTO #DBA_ExclusionList VALUES('US\nichobyAD')		-- Nichols, Jay
		INSERT INTO #DBA_ExclusionList VALUES('US\RCH0533')		-- Gaither, Ray
		INSERT INTO #DBA_ExclusionList VALUES('US\RCH0533AD')		-- Gaither, Ray
		INSERT INTO #DBA_ExclusionList VALUES('US\RCH1021')		-- Low, Lawrence
		INSERT INTO #DBA_ExclusionList VALUES('US\RCH1021AD')		-- Low, Lawrence
		INSERT INTO #DBA_ExclusionList VALUES('US\wherrmr')		-- Wherry, Martha A
		INSERT INTO #DBA_ExclusionList VALUES('US\wherrmrAD')		-- Wherry, Martha A

		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,CASE WHEN UPPER(A.name) = 'BUILTIN\ADMINISTRATORS' THEN 'USE [master];DECLARE @Message varchar(256); IF NOT EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''US\W9_SQL_DBA_AD'' AND sysadmin = 1) BEGIN SET @Message = ''BUILTIN\Administrators account cannot be removed, the US\W9_SQL_DBA_AD account does not exist or does not have sysadmin.  Please add this group account manually and remove BUILTIN\Administrators.'' RAISERROR (@Message, 18, 1) END ELSE BEGIN IF EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''BUILTIN\ADMINISTRATORS'') EXECUTE sp_droplogin ''BUILTIN\ADMINISTRATORS'' END ' ELSE 'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + '''' END
					,CASE WHEN UPPER(A.name) = 'BUILTIN\ADMINISTRATORS' THEN 'USE [master];EXECUTE sp_grantlogin ''BUILTIN\ADMINISTRATORS'';EXECUTE master..sp_addsrvrolemember @loginame = N''BUILTIN\ADMINISTRATORS'', @rolename = N''sysadmin'' ' ELSE 'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + '''' END
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'sysadmin'
		  AND       D.Account IS NULL
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'							
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'bulkadmin'
		  AND       D.Account IS NULL
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'							
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'dbcreator'
		  AND       D.Account IS NULL
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'							
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'diskadmin'
		  AND       D.Account IS NULL
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'							
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'processadmin'
		  AND       D.Account IS NULL
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'							
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'securityadmin'
		  AND       D.Account IS NULL
		  AND		UPPER(A.name) <> 'US\MO-AOC_MSSQL' 
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'							
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'serveradmin'
		  AND       D.Account IS NULL
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'							
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + '(' + A.type_desc + ') is a member of Server Fixed Role ' + QUOTENAME(C.name) + '.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''' + C.name + ''''
		FROM		sys.server_principals A
						JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id
						JOIN sys.server_principals C ON B.role_principal_id = C.principal_id
						LEFT JOIN #DBA_ExclusionList D ON UPPER(A.name) = UPPER(D.Account)
		WHERE		C.name = 'setupadmin'
		  AND       D.Account IS NULL                                    
		  AND		UPPER(A.name) <> 'US\SRCGUARDIUM'
		  AND		UPPER(A.name) <> 'US\SRCTOPOLOGY'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\MSSQL%'
		  AND		UPPER(A.name) NOT LIKE 'NT SERVICE\SQLAGENT%'	
		  
		DROP TABLE #DBA_ExclusionList						
	END

 /* 
    TEST ID:      160
	
    DESCRIPTION:  NO PUBLIC OR GUEST PREDEFINED ROLE AUTHORIZATION
*/
SET @GuardiumTestId = '160'  
SET @Description = 'No public or guest predefined role authorization'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
        OPEN CURSOR_DB

        FETCH NEXT FROM CURSOR_DB
        INTO @DbName, @CompatLevel

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SQL = 'USE [' + @DbName + '];'
            SET @SQL = @SQL + 
                       'SELECT		''' + @SQLServer + ''' '
            SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
            SET @SQL = @SQL + '	   ,''' + @Description + ''' '
            SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
            SET @SQL = @SQL + '	   ,QUOTENAME(A.name) + '' ('' + A.type_desc COLLATE DATABASE_DEFAULT  + '') is a member of  '' + QUOTENAME(C.name) + '' database role in database ' + QUOTENAME(@DbName) + '.'' '
            SET @SQL = @SQL + '	   ,''USE ' + QUOTENAME(@DbName) + ';EXECUTE sp_droprolemember '''''' + C.name + '''''', '''''' + A.name + '''''''' '
            SET @SQL = @SQL + '	   ,''USE ' + QUOTENAME(@DbName) + ';EXECUTE sp_addrolemember '''''' + C.name + '''''', '''''' + A.name + '''''''' '
            SET @SQL = @SQL + 
                       'FROM		' + QUOTENAME(@DbName) + '.sys.database_principals A '
            SET @SQL = @SQL + '	       JOIN ' + QUOTENAME(@DbName) + '.sys.database_role_members B ON A.principal_id = B.member_principal_id '
            SET @SQL = @SQL + '	       JOIN ' + QUOTENAME(@DbName) + '.sys.database_principals C ON B.role_principal_id = C.principal_id '
            SET @SQL = @SQL + 
                       'WHERE		A.principal_id IN (0, 2) -- public & guest '
            SET @SQL = @SQL + 
                       '  AND		C.is_fixed_role = 1 '

            INSERT INTO #Report 
            EXECUTE (@SQL)

            FETCH NEXT FROM CURSOR_DB
            INTO @DbName, @CompatLevel        
        END                

        CLOSE CURSOR_DB
    END
    									
/* 
	TEST ID:      162	
	DESCRIPTION:  ALL OBJECTS OWNED BY DBO
*/
SET @GuardiumTestId = '162'
SET @Description = 'All objects owned by dbo.'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + ']; '
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' ('' + CASE B.xtype WHEN ''C'' THEN ''CHECK constraint'' WHEN ''D'' THEN ''DEFAULT constraint'' WHEN ''F'' THEN ''FOREIGN KEY constraint'' WHEN ''L'' THEN ''Log'' WHEN ''FN'' THEN ''Scalar Function'' WHEN ''IF'' THEN ''In-lined table-function'' WHEN ''P'' THEN ''Stored procedure'' WHEN ''PK'' THEN ''PRIMARY KEY constraint'' WHEN ''RF'' THEN ''Replication filter stored procedure'' WHEN ''S'' THEN ''System table'' WHEN ''TF'' THEN ''Table function'' WHEN ''TR'' THEN ''Trigger'' WHEN ''U'' THEN ''User table'' WHEN ''UQ'' THEN ''UNIQUE constraint'' WHEN ''V'' THEN ''View'' WHEN ''X'' THEN ''Extended stored procedure'' ELSE B.xtype END + '') is not owned by ''''dbo''''.'''
					SET @SQL = @SQL + ',''/* RESEARCH NEEDS TO TAKE PLACE TO SEE IF OBJECT SCHEMA CAN BE ALTERED TO DBO, THIS CAN BE DONE USING ALTER SCHEMA */''  '
					SET @SQL = @SQL + ',''''  '
					SET @SQL = @SQL + 
							   'FROM dbo.sysusers A '
					SET @SQL = @SQL + 'JOIN dbo.sysobjects B ON A.uid = B.uid '
					SET @SQL = @SQL + 
							   'WHERE A.name NOT IN (''dbo'', ''sys'', ''INFORMATION_SCHEMA'') '
				END
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + ']; '
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' ('' + B.type_desc COLLATE DATABASE_DEFAULT + '') is not owned by ''''dbo''''.'''
					SET @SQL = @SQL + ',''/* RESEARCH NEEDS TO TAKE PLACE TO SEE IF OBJECT SCHEMA CAN BE ALTERED TO DBO, THIS CAN BE DONE USING ALTER SCHEMA */''  '
					SET @SQL = @SQL + ',''''  '
					SET @SQL = @SQL + 
							   'FROM sys.schemas A '
					SET @SQL = @SQL + 'JOIN sys.all_objects B ON A.schema_id = B.schema_id '
					SET @SQL = @SQL + 
							   'WHERE A.name NOT IN (''dbo'', ''sys'', ''INFORMATION_SCHEMA'') '
				END
			INSERT INTO #Report
			EXECUTE (@SQL)
				
			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
/* 
	TEST ID:      163	
	DESCRIPTION:  NO ORPHANED USERS
*/
SET @GuardiumTestId = '163'  
SET @Description = 'No orphaned users'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = 'USE [' + @DbName + '];'
			SET @SQL = @SQL + 
					   'SELECT		''' + @SQLServer + ''' '
			SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
			SET @SQL = @SQL + '	   ,''' + @Description + ''' '
			SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
			SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' is an orphan user in database [' + @DbName + '].'' '
			SET @SQL = @SQL + '	   ,''/* BEFORE DROPPING ACCOUNT, MAKE SURE YOU CAN BECAUSE ROLLBACK SCRIPT ONLY ADDS ACCOUNT BACK, NOT THE PERMISSIONS */USE [' + @DbName + '];DROP USER '' + QUOTENAME(A.name) '
			SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];CREATE USER '' + QUOTENAME(A.name) + '' WITHOUT LOGIN '' '
			SET @SQL = @SQL + 
					   'FROM		[' + @DbName + '].sys.database_principals A '
			SET @SQL = @SQL + '	       LEFT JOIN master.sys.server_principals B ON A.sid = B.sid '
			SET @SQL = @SQL + 
					   'WHERE		B.sid IS NULL '
			SET @SQL = @SQL + 
					   '  AND		A.type = ''S'' '
			SET @SQL = @SQL + 
					   '  AND		A.sid <> 0x00 '
			SET @SQL = @SQL + 
					   '  AND		A.sid IS NOT NULL '
			SET @SQL = @SQL +
					   '  AND		(''' + @DbName + ''' <> ''msdb'' AND A.name <> ''MS_DataCollectorInternalUser'') '		   

			INSERT INTO #Report 
			EXECUTE (@SQL)

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
/* 
	TEST ID:      164	
	DESCRIPTION:  NO MISMATCHED USERS
*/
SET @GuardiumTestId = '164'  
SET @Description = 'No mismatched users'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE SQL_Latin1_General_CP1_CI_AS' END + ' + '' in database [' + @DbName + '] does not have a matching SQL Login Account.'' '
					SET @SQL = @SQL + '	   ,''/* BEFORE DROPPING ACCOUNT, PLEASE MAKE SURE YOU SCRIPT THE PERMISSION IT HAS.  YOU WILL NEED THIS WHEN ADDING THE ACCOUNT BACK WITH CORRECT NAME */USE [' + @DbName + '];EXECUTE sp_dropuser '''''' + A.name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END + ' + '''''';EXECUTE sp_adduser '''''' + B.name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END + ' + ''''''; /* REAPPLY PERMISSIONS */ '''
			        SET @SQL = @SQL + '	   ,''/* BEFORE DROPPING ACCOUNT, PLEASE MAKE SURE YOU SCRIPT THE PERMISSION IT HAS.  YOU WILL NEED THIS WHEN ADDING THE ACCOUNT BACK WITH CORRECT NAME */USE [' + @DbName + '];EXECUTE sp_dropuser '''''' + B.name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END + ' + '''''';EXECUTE sp_adduser '''''' + A.name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END + ' + '''''', '''''' + B.name + ''''''; /* REAPPLY PERMISSIONS */ '''
					SET @SQL = @SQL + 
							   'FROM		[' + @DbName + '].dbo.sysusers A '
					SET @SQL = @SQL + '	       JOIN master.dbo.syslogins B ON A.sid = B.sid '
					SET @SQL = @SQL + 
							   'WHERE		A.name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END + ' <> B.name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END 
					SET @SQL = @SQL + 
							   '  AND		A.name NOT IN (''dbo'') '
					SET @SQL = @SQL + 
							   '  AND		A.name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END + ' IN (SELECT name ' + CASE WHEN @CompatLevel < 80 THEN '' ELSE 'COLLATE DATABASE_DEFAULT' END + ' FROM master.dbo.syslogins) '
		            		   
					INSERT INTO #Report 
					EXECUTE (@SQL)
				END                       
			ELSE
				BEGIN            
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' in database [' + @DbName + '] does not have a matching SQL Login Account.'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];ALTER USER '' + QUOTENAME(A.name COLLATE DATABASE_DEFAULT)  + '' WITH NAME = '' + QUOTENAME(B.name COLLATE DATABASE_DEFAULT) '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];ALTER USER '' + QUOTENAME(B.name COLLATE DATABASE_DEFAULT) + '' WITH NAME = '' + QUOTENAME(A.name COLLATE DATABASE_DEFAULT) '
					SET @SQL = @SQL + 
							   'FROM		[' + @DbName + '].sys.database_principals A '
					SET @SQL = @SQL + '	       JOIN master.sys.server_principals B ON A.sid = B.sid '
					SET @SQL = @SQL + 
							   'WHERE		A.name COLLATE DATABASE_DEFAULT <> B.name COLLATE DATABASE_DEFAULT '
					SET @SQL = @SQL + 
							   '  AND		A.name NOT IN (''dbo'') '
					SET @SQL = @SQL + 
							   '  AND		A.name COLLATE DATABASE_DEFAULT IN (SELECT name COLLATE DATABASE_DEFAULT FROM master.sys.server_principals) '

					INSERT INTO #Report 
					EXECUTE (@SQL)
				END

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
/* 
	TEST ID:      185	
	DESCRIPTION:  USER PASSWORD POLICY IS CHECKED
*/
SET @GuardiumTestId = '185'  
SET @Description = 'User password policy is checked'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'SQL Authenticated account ' + QUOTENAME(A.name) + ' password policy is not checked.'
					,'USE [master];ALTER LOGIN ' + QUOTENAME(A.name) + ' WITH CHECK_POLICY=ON;'
					,'USE [master];ALTER LOGIN ' + QUOTENAME(A.name) + ' WITH CHECK_POLICY=OFF;'
		FROM        sys.sql_logins A
		WHERE       A.is_policy_checked = 0
		  AND       A.type = 'S'
		  AND       A.is_disabled = 0
	END

/* 
	TEST ID:      186	
	DESCRIPTION:  USER PASSWORD EXPIRATION IS CHECKED
*/
SET @GuardiumTestId = '186'  
SET @Description = 'User password expiration is checked'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'SQL Authenticated account ' + QUOTENAME(A.name) + ' password expiration is not checked.'
					,'USE [master];ALTER LOGIN ' + QUOTENAME(A.name) + ' WITH CHECK_POLICY=ON,CHECK_EXPIRATION=ON;'
					,'USE [master];ALTER LOGIN ' + QUOTENAME(A.name) + ' WITH CHECK_EXPIRATION=OFF;'
		FROM        sys.sql_logins A
		WHERE       A.is_expiration_checked = 0
		  AND       A.type = 'S'
		  AND       A.is_disabled = 0
          AND       A.name NOT IN ('tivoli', 'ssaid', 'sa')
	END
	
 /* 
	TEST ID:      205	
	DESCRIPTION:  SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
*/
SET @GuardiumTestId = '205'  
SET @Description = 'SQL OLEDB disabled (DisallowedAdhocAccess registry key)'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		DECLARE @ProviderName	varchar(128)

		CREATE TABLE #OLEDBProv 
		(
				ProviderName varchar(128) NOT NULL
				,ParseName varchar(50) NOT NULL
				,Description varchar(255) NOT NULL 
		) 

		INSERT INTO #OLEDBProv 
		EXECUTE master.dbo.xp_enum_oledb_providers

		CREATE TABLE #OLEDBProp
		(
			provider_name			varchar(128)
			,allow_in_process		bit
			,disallow_adhoc_access	bit
			,dynamic_parameters		bit
			,index_as_access_path	bit
			,level_zero_only		bit
			,nested_queries			bit
			,non_transacted_updates bit
			,sql_server_like		bit
		) 

		DECLARE CURSOR_PROVIDER CURSOR FAST_FORWARD
		FOR
			SELECT		DISTINCT RTRIM(ProviderName)
			FROM		#OLEDBProv
			ORDER BY	RTRIM(ProviderName)

		OPEN CURSOR_PROVIDER
		 
		FETCH NEXT FROM CURSOR_PROVIDER 
		INTO @ProviderName 

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			INSERT INTO #OLEDBProp 
			(
					provider_name
					,allow_in_process
					,disallow_adhoc_access
					,dynamic_parameters
					,index_as_access_path
					,level_zero_only
					,nested_queries
					,non_transacted_updates
					,sql_server_like
			) 
			EXECUTE master.dbo.sp_MSset_oledb_prop @ProviderName

			FETCH NEXT FROM CURSOR_PROVIDER 
			INTO @ProviderName 
		END 

		CLOSE CURSOR_PROVIDER 
		DEALLOCATE CURSOR_PROVIDER

		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Disallow Adhoc Access is not enabled for provider ' + QUOTENAME(provider_name)
					,'USE [master];EXECUTE master.dbo.sp_MSset_oledb_prop ''' + provider_name + ''', N''DisallowAdHocAccess'', 1'
					,'USE [master];EXECUTE master.dbo.sp_MSset_oledb_prop ''' + provider_name + ''', N''DisallowAdHocAccess'', 0'
		FROM		#OLEDBProp
		WHERE		disallow_adhoc_access = 0 

		DROP TABLE #OLEDBProv
		DROP TABLE #OLEDBProp
	END
	
/* 
	TEST ID:      210	
	DESCRIPTION:  NO ACCESS TO GENERAL EXTENDED PROCEDURES
*/
SET @GuardiumTestId = '210'  
SET @Description = 'No access to general extended procedures'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(C.name) + ' (' + C.type_desc + ') has ' + B.permission_name COLLATE DATABASE_DEFAULT + ' permissions on ' + QUOTENAME(SCHEMA_NAME(A.schema_id)) + '.' + QUOTENAME(A.name) + ' (' + A.type_desc + ').  This permission needs to be removed.'
					,'USE [master];REVOKE ' + B.permission_name COLLATE DATABASE_DEFAULT + ' ON ' + QUOTENAME(SCHEMA_NAME(A.schema_id)) + '.' + QUOTENAME(A.name) + ' TO ' + QUOTENAME(C.name)
					,'USE [master];GRANT ' + B.permission_name COLLATE DATABASE_DEFAULT + ' ON ' + QUOTENAME(SCHEMA_NAME(A.schema_id)) + '.' + QUOTENAME(A.name) + ' TO ' + QUOTENAME(C.name)
		FROM        sys.all_objects A
						JOIN sys.database_permissions B ON A.object_id = B.major_id
						JOIN sys.database_principals C ON B.grantee_principal_id = C.principal_id
		WHERE       (
						A.name IN   (
										'xp_available_media'
										,'xp_dsninfo'
										,'xp_enumdsn'
										,'xp_enumerrorlogs'
										,'xp_enumgroups'
										,'xp_eventlog'
										,'xp_fixeddrives'
										,'xp_getfiledetails'
										,'xp_getnetname'
										,'xp_logevent'
										,'xp_loginconfig'
										,'xp_msver'
										,'xp_readerrorlog'
										,'xp_servicecontrol'
										,'xp_sprintf'
										,'xp_sscanf'
										,'xp_subdirs'
										,'xp_unc_to_drive'
									)  
							OR A.name = CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108) -- x..p.._..c..m..d..s..h..e..l..l
							OR A.name = CHAR(120) + CHAR(112) + CHAR(95) + CHAR(100) + CHAR(105) + CHAR(114) + CHAR(116) + CHAR(114) + CHAR(101) + CHAR(101) -- x..p.._..d..i..r..t..r..e..e
					)
		  AND       B.state NOT IN ('D', 'R')
	END
	
 /* 
	TEST ID:      211	
	DESCRIPTION:  NO ACCESS TO SQLMAIL EXTENDED PROCEDURES
*/
SET @GuardiumTestId = '211'  
SET @Description = 'No access to SQLMail extended procedures'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Account ' + QUOTENAME(D.name) + ' (' + D.type_desc + ') has ' + C.permission_name + ' permissions ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' in [master] database.'
					,'USE [master];REVOKE ' + C.permission_name + ' ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ';'
		FROM		sys.schemas A
						JOIN sys.all_objects B ON A.schema_id = B.schema_id
						JOIN sys.database_permissions C ON B.object_id = C.major_id
						JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id
		WHERE		B.name IN 				
								(
									'xp_deletemail'
									,'xp_findnextmsg'
									,'xp_get_mapi_default_profile'
									,'xp_get_mapi_profiles'
									,'xp_readmail'
									,'xp_sendmail'
									,'xp_startmail'
									,'xp_stopmail'
								)  
		  AND		C.state_desc <> 'REVOKE'
	END
	  
 /* 
	TEST ID:      214	
	DESCRIPTION:  NO ACCESS TO OLE AUTOMATION PROCEDURES
*/
SET @GuardiumTestId = '214'  
SET @Description = 'No access to OLE automation procedures'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Account ' + QUOTENAME(D.name) + ' (' + D.type_desc + ') has ' + C.permission_name + ' permissions ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' in [master] database.'
					,'USE [master];REVOKE ' + C.permission_name + ' ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ';'
		FROM		sys.schemas A
						JOIN sys.all_objects B ON A.schema_id = B.schema_id
						JOIN sys.database_permissions C ON B.object_id = C.major_id
						JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id
		WHERE		B.name IN 				
								(
									'sp_OACreate'
									,'sp_OADestroy'
									,'sp_OAGetErrorInfo'
									,'sp_OAGetProperty'
									,'sp_OAMethod'
									,'sp_OASetProperty'
									,'sp_OAStop'
								)  
		  AND		C.state_desc <> 'REVOKE'  
	END
	
/* 
	TEST ID:      269	
	DESCRIPTION:  WINDOWS AUTHENTICATION
*/
SET @GuardiumTestId = '269'  
SET @Description = 'Windows Authentication'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		IF CAST(SERVERPROPERTY('IsIntegratedSecurityOnly') AS int) = 0
			INSERT INTO #Report
			SELECT		@SQLServer
						,@GuardiumTestId
						,@Description
						,'master'
						,'SQL Server is not set for Windows Authentication.'
						,'/* THIS WILL NOT TAKE EFFECT UNTIL SQL SERVER IS RESTARTED */USE [master];EXECUTE xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''LoginMode'', REG_DWORD, 1'
						,'/* THIS WILL NOT TAKE EFFECT UNTIL SQL SERVER IS RESTARTED */USE [master];EXECUTE xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''LoginMode'', REG_DWORD, 2'
	END

/* 
	TEST ID:      270	
	DESCRIPTION:  NO NON-EXEMPT PUBLIC PRIVILEGES
*/
SET @GuardiumTestId = '270'  
SET @Description = 'NO NON-EXEMPT PUBLIC PRIVILEGES'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,QUOTENAME(D.name) + '' (DATABASE_ROLE) has '' + CASE C.action WHEN  26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE '' + CASE C.action WHEN 26 THEN ''REFERENCES'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT ''  + CASE C.action WHEN 26 THEN ''REFERENCES'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
					SET @SQL = @SQL + 
							   'FROM		sysusers A '
					SET @SQL = @SQL +          'JOIN sysobjects B ON A.uid = B.uid '
					SET @SQL = @SQL +          'JOIN sysprotects C ON B.id = C.id '
					SET @SQL = @SQL +          'JOIN sysusers D ON C.uid = D.uid '
					SET @SQL = @SQL +      
							   'WHERE		D.name = ''public'' '
					SET @SQL = @SQL +      
								 'AND		C.protecttype <> 206 '
					SET @SQL = @SQL +      
								 'AND		C.action IN (26,193,195,196,197,224) '

					INSERT INTO #Report 
					EXECUTE (@SQL)
				END                
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(D.name) + '' ('' + D.type_desc + '') has '' + QUOTENAME(C.permission_name) COLLATE DATABASE_DEFAULT  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' ('' + B.type_desc + '')'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE '' +  C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT '' + C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
					SET @SQL = @SQL + 
							   'FROM  sys.schemas A '
					SET @SQL = @SQL +   'JOIN sys.all_objects B ON A.schema_id = B.schema_id '
					SET @SQL = @SQL +   'JOIN sys.database_permissions C ON B.object_id = C.major_id '
					SET @SQL = @SQL +   'JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id '
					SET @SQL = @SQL +      
							   'WHERE D.name = ''public'' '
					SET @SQL = @SQL +      
								 'AND		C.state IN (''G'', ''W'') '

					INSERT INTO #Report 
					EXECUTE (@SQL)
				END

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
  
/* 
	TEST ID:      319	
	DESCRIPTION:  DB_OWNER GRATNED ON USERS AND ROLES
*/
SET @GuardiumTestId = '319'  
SET @Description = 'db_owner granted on users and roles'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' has db_owner permissions in database [' + @DbName + '].'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_droprolemember N''''db_owner'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_addrolemember  N''''db_owner'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL +       
							   'FROM		sysusers A '
					SET @SQL = @SQL +           'JOIN sysmembers B ON A.uid = B.memberuid '
					SET @SQL = @SQL +           'JOIN sysusers C ON B.groupuid = C.uid '
					SET @SQL = @SQL + 
							   'WHERE		C.name = ''db_owner'' '
					SET @SQL = @SQL +       
								 'AND		A.name <> ''dbo'' '
				END
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' has db_owner permissions in database [' + @DbName + '].'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_droprolemember N''''db_owner'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_addrolemember  N''''db_owner'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL +       
							   'FROM		sys.database_principals A '
					SET @SQL = @SQL +           'JOIN sys.database_role_members B ON A.principal_id = B.member_principal_id '
					SET @SQL = @SQL +           'JOIN sys.database_principals C ON B.role_principal_id = C.principal_id '
					SET @SQL = @SQL + 
							   'WHERE		C.name = ''db_owner'' '
					SET @SQL = @SQL +       
								 'AND		A.name <> ''dbo'' '
				END
				                 
			INSERT INTO #Report
			EXECUTE (@SQL)

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
 /* 
	TEST ID:      320	
	DESCRIPTION:  DB_SECURITYADMIN GRANTED ON USERS AND ROLES
*/
SET @GuardiumTestId = '320'  
SET @Description = 'db_securityadmin granted on users and roles.'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' has db_securityadmin permissions in database [' + @DbName + '].'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_droprolemember N''''db_securityadmin'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_addrolemember  N''''db_securityadmin'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL +       
							   'FROM		sysusers A '
					SET @SQL = @SQL +           'JOIN sysmembers B ON A.uid = B.memberuid '
					SET @SQL = @SQL +           'JOIN sysusers C ON B.groupuid = C.uid '
					SET @SQL = @SQL + 
							   'WHERE		C.name = ''db_securityadmin'' '
					SET @SQL = @SQL +       
								 'AND		A.name <> ''dbo'' '
				END
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' has db_securityadmin permissions in database [' + @DbName + '].'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_droprolemember N''''db_securityadmin'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_addrolemember  N''''db_securityadmin'''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL +       
							   'FROM		sys.database_principals A '
					SET @SQL = @SQL +           'JOIN sys.database_role_members B ON A.principal_id = B.member_principal_id '
					SET @SQL = @SQL +           'JOIN sys.database_principals C ON B.role_principal_id = C.principal_id '
					SET @SQL = @SQL + 
							   'WHERE		C.name = ''db_securityadmin'' '
					SET @SQL = @SQL +       
								 'AND		A.name <> ''dbo'' '
				                 
					INSERT INTO #Report 
					EXECUTE (@SQL)
				END
				
			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
 /* 
	TEST ID:      321	
	DESCRIPTION:  DDL GRANTED TO USER
*/
SET @GuardiumTestId = '321'  
SET @Description = 'DDL granted to user'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,QUOTENAME(A.name) + '' has '' + '
					SET @SQL = @SQL +      'CASE B.action '
					SET @SQL = @SQL +           'WHEN 26  THEN ''REFERENCES'' '   
					SET @SQL = @SQL +           'WHEN 178 THEN ''CREATE FUNCTION'' '   
					SET @SQL = @SQL +           'WHEN 198 THEN ''CREATE TABLE'' '   
					SET @SQL = @SQL +           'WHEN 203 THEN ''CREATE DATABASE'' '   
					SET @SQL = @SQL +           'WHEN 207 THEN ''CREATE VIEW'' '   
					SET @SQL = @SQL +           'WHEN 222 THEN ''CREATE PROCEDURE'' '   
					SET @SQL = @SQL +           'WHEN 224 THEN ''EXECUTE'' '   
					SET @SQL = @SQL +           'WHEN 228 THEN ''BACKUP DATABASE'' '   
					SET @SQL = @SQL +           'WHEN 233 THEN ''CREATE DEFAULT'' '   
					SET @SQL = @SQL +           'WHEN 235 THEN ''BACKUP LOG'' '   
					SET @SQL = @SQL +           'WHEN 236 THEN ''CREATE RULE'' '   
					SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) + '' ** UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** ''  '
					SET @SQL = @SQL +       'END '
					SET @SQL = @SQL +       ' + '' permission on database [' + @DbName + ']'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE '' + '
					SET @SQL = @SQL +      'CASE B.action '
					SET @SQL = @SQL +           'WHEN 26  THEN ''REFERENCES'' '   
					SET @SQL = @SQL +           'WHEN 178 THEN ''CREATE FUNCTION'' '   
					SET @SQL = @SQL +           'WHEN 198 THEN ''CREATE TABLE'' '   
					SET @SQL = @SQL +           'WHEN 203 THEN ''CREATE DATABASE'' '   
					SET @SQL = @SQL +           'WHEN 207 THEN ''CREATE VIEW'' '   
					SET @SQL = @SQL +           'WHEN 222 THEN ''CREATE PROCEDURE'' '   
					SET @SQL = @SQL +           'WHEN 224 THEN ''EXECUTE'' '   
					SET @SQL = @SQL +           'WHEN 228 THEN ''BACKUP DATABASE'' '   
					SET @SQL = @SQL +           'WHEN 233 THEN ''CREATE DEFAULT'' '   
					SET @SQL = @SQL +           'WHEN 235 THEN ''BACKUP LOG'' '   
					SET @SQL = @SQL +           'WHEN 236 THEN ''CREATE RULE'' '   
					SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) + '' ** UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' '
					SET @SQL = @SQL +       'END '
					SET @SQL = @SQL +      ' + '' TO '' + QUOTENAME(A.name) + '' CASCADE;'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT '' + '
					SET @SQL = @SQL +      'CASE B.action '
					SET @SQL = @SQL +           'WHEN 26  THEN ''REFERENCES'' '   
					SET @SQL = @SQL +           'WHEN 178 THEN ''CREATE FUNCTION'' '   
					SET @SQL = @SQL +           'WHEN 198 THEN ''CREATE TABLE'' '   
					SET @SQL = @SQL +           'WHEN 203 THEN ''CREATE DATABASE'' '   
					SET @SQL = @SQL +           'WHEN 207 THEN ''CREATE VIEW'' '   
					SET @SQL = @SQL +           'WHEN 222 THEN ''CREATE PROCEDURE'' '   
					SET @SQL = @SQL +           'WHEN 224 THEN ''EXECUTE'' '   
					SET @SQL = @SQL +           'WHEN 228 THEN ''BACKUP DATABASE'' '   
					SET @SQL = @SQL +           'WHEN 233 THEN ''CREATE DEFAULT'' '   
					SET @SQL = @SQL +           'WHEN 235 THEN ''BACKUP LOG'' '   
					SET @SQL = @SQL +           'WHEN 236 THEN ''CREATE RULE'' '   
					SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' '
					SET @SQL = @SQL +       'END '
					SET @SQL = @SQL +		' + '' TO '' + QUOTENAME(A.name) '
					SET @SQL = @SQL + 
							   'FROM		sysusers A '
					SET @SQL = @SQL +          'JOIN sysprotects B ON A.uid = B.uid '
					SET @SQL = @SQL +      
							   'WHERE		A.islogin = 1 '
					SET @SQL = @SQL +      
								 'AND		B.protecttype IN (204, 205) '
					SET @SQL = @SQL +      
								 'AND		B.id = 0 '
                    SET @SQL = @SQL +      
                                 'AND		A.name NOT LIKE ''##MS_%'''
		                         
					INSERT INTO #Report 
					EXECUTE (@SQL)
				END
			ELSE
				BEGIN 
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,QUOTENAME(A.name) + '' ('' + A.type_desc + '') has '' + QUOTENAME(B.permission_name) COLLATE DATABASE_DEFAULT  + '' permission on database [' + @DbName + ']'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE '' + B.permission_name COLLATE DATABASE_DEFAULT  + '' TO '' + QUOTENAME(A.name) + '' CASCADE;'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT '' + B.permission_name COLLATE DATABASE_DEFAULT  + '' TO '' + QUOTENAME(A.name) '
					SET @SQL = @SQL + 
							   'FROM		sys.database_principals A '
					SET @SQL = @SQL +          'JOIN sys.database_permissions B ON A.principal_id = B.grantee_principal_id '
					SET @SQL = @SQL +      
							   'WHERE		A.type NOT IN (''A'', ''R'') '
					SET @SQL = @SQL +      
								 'AND		B.state IN (''G'', ''W'') '
					SET @SQL = @SQL +      
								 'AND		B.type <> ''CO'' '
					SET @SQL = @SQL +      
								 'AND		B.class = 0 '
                    SET @SQL = @SQL +      
                                 'AND		A.name NOT LIKE ''##MS_%'''

					INSERT INTO #Report 
					EXECUTE (@SQL)
				END

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
/*
Account should be ignore based on http://msdn.microsoft.com/en-us/library/ms181127.aspx
    ##MS_SQLResourceSigningCertificate##
    ##MS_SQLReplicationSigningCertificate##
    ##MS_SQLAuthenticatorCertificate##
    ##MS_AgentSigningCertificate##
    ##MS_PolicyEventProcessingLogin##
    ##MS_PolicySigningCertificate##
    ##MS_PolicyTsqlExecutionLogin##
*/
 
/* 
	TEST ID:      322	
	DESCRIPTION:  PROCEDURES GRATNED TO USER
*/
SET @GuardiumTestId = '322'  
SET @Description = 'PROCEDURES GRANTED TO USERS'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(D.name) + '' ('' + CASE WHEN D.isntname = 1 THEN CASE WHEN D.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE ''WINDOWS_USER'' END ELSE ''SQL_USER'' END + '') has '' + CASE C.action WHEN  26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE '' + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT ''  + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
					SET @SQL = @SQL + 
							   'FROM sysusers A '
					SET @SQL = @SQL + 'JOIN sysobjects B ON A.uid = B.uid '
					SET @SQL = @SQL + 'JOIN sysprotects C ON B.id = C.id '
					SET @SQL = @SQL + 'JOIN sysusers D ON C.uid = D.uid '
					SET @SQL = @SQL +      
							   'WHERE D.issqlrole <> 1 '
					SET @SQL = @SQL +      
								 'AND D.isapprole <> 1 '
					SET @SQL = @SQL +      
								 'AND		C.protecttype <> 206 '
					SET @SQL = @SQL +      
								 'AND B.xtype in (''P'',''X'',''RF'')  '
					
					INSERT INTO #Report 
					EXECUTE (@SQL)
				END                
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT ''' + @SQLServer + ''' '
					SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + ',''' + @Description + ''' '
					SET @SQL = @SQL + ',''' + @DbName + ''' '
					SET @SQL = @SQL + ',QUOTENAME(D.name) + '' ('' + D.type_desc + '') has '' + QUOTENAME(C.permission_name) COLLATE DATABASE_DEFAULT  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' ('' + B.type_desc + '')'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];REVOKE '' +  C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
					SET @SQL = @SQL + ',''USE [' + @DbName + '];GRANT '' + C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
					SET @SQL = @SQL + 
							   'FROM  sys.schemas A '
					SET @SQL = @SQL +   'JOIN sys.all_objects B ON A.schema_id = B.schema_id '
					SET @SQL = @SQL +   'JOIN sys.database_permissions C ON B.object_id = C.major_id '
					SET @SQL = @SQL +   'JOIN sys.database_principals D ON C.grantee_principal_id = D.principal_id '
					SET @SQL = @SQL +      
							   'WHERE D.type NOT IN (''A'', ''R'') '
					SET @SQL = @SQL +      
								 'AND		C.state IN (''G'', ''W'') '
					SET @SQL = @SQL +      
								 'AND B.type IN (''P'',''X'',''PC'',''RF'') '

					INSERT INTO #Report 
					EXECUTE (@SQL)
				END

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
/* 
	TEST ID:      323
	DESCRIPTION:  ROLE GRANTED TO ROLE
*/
SET @GuardiumTestId = '323'  
SET @Description = 'Role granted to role'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB


		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CompatLevel < 80
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Database Role '' + QUOTENAME(A.name) + '' is member of another role '' + QUOTENAME(C.name) + ''.'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_droprolemember N'''''' + C.name + '''''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_addrolemember  N'''''' + C.name + '''''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL +       
							   'FROM		sysusers A '
					SET @SQL = @SQL +           'JOIN sysmembers B ON A.uid = B.memberuid '
					SET @SQL = @SQL +           'JOIN sysusers C ON B.groupuid = C.uid '
					SET @SQL = @SQL + 
							   'WHERE       ( '
					SET @SQL = @SQL + '          A.issqlrole = 1 '
					SET @SQL = @SQL + '              OR A.isapprole = 1 '
					SET @SQL = @SQL + '      )'
					SET @SQL = @SQL + 
							   '  AND       ( '
					SET @SQL = @SQL + '          C.issqlrole = 1 '
					SET @SQL = @SQL + '              OR C.isapprole = 1 '
					SET @SQL = @SQL + '      ) '
				END
			ELSE
				BEGIN
					SET @SQL = 'USE [' + @DbName + '];'
					SET @SQL = @SQL + 
							   'SELECT		''' + @SQLServer + ''' '
					SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
					SET @SQL = @SQL + '	   ,''' + @Description + ''' '
					SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
					SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' has db_owner permissions in database [' + @DbName + '].'' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_droprolemember N'''''' + C.name + '''''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_addrolemember  N'''''' + C.name + '''''', N'''''' + A.name + '''''''' '
					SET @SQL = @SQL +       
							   'FROM		sys.database_principals A '
					SET @SQL = @SQL +           'JOIN sys.database_role_members B ON A.principal_id = B.member_principal_id '
					SET @SQL = @SQL +           'JOIN sys.database_principals C ON B.role_principal_id = C.principal_id '
					SET @SQL = @SQL + 
							   'WHERE		A.type IN (''A'', ''R'') '
					SET @SQL = @SQL +       
								 'AND		C.type IN (''A'', ''R'') '
				END      

			INSERT INTO #Report 
			EXECUTE (@SQL)

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
 /* 
	TEST ID:      2001	
	DESCRIPTION:  DISABLE CLR OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2001'  
SET @Description = 'Disable CLR option for MSQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "clr enabled" is enabled'
					,'USE [master];EXECUTE sp_configure ''clr enabled'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''clr enabled'', 1;RECONFIGURE'
		FROM		sys.configurations 
		WHERE		name = 'clr enabled' 
		  AND		value_in_use = 1
	END
	
 /* 
	TEST ID:      2002	
	DESCRIPTION:  DISABLE SQL MAIL USE UNLESS NEEDED FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2002'  
SET @Description = 'Disable SQL Mail use unless needed for MSSQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "SQL Mail XPs" is enabled'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''SQL Mail XPs'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''SQL Mail XPs'', 1;RECONFIGURE'
		FROM		sys.configurations 
		WHERE		name = 'SQL Mail XPs' 
		  AND		value_in_use = 1
	END
	
 /* 
	TEST ID:      2005	
	DESCRIPTION:  RENAME SA ACCOUNT FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2005'  
SET @Description = 'Rename sa account for MSsQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'sa account exists, must be renamed.'
					,'ALTER LOGIN [sa] WITH NAME = [ssaid]'
					,'ALTER LOGIN [ssaid] WITH NAME = [sa]'
		FROM		sys.sql_logins 
		WHERE		name = 'sa'
	END
	
 /* 
	TEST ID:      2006	
	DESCRIPTION:  DISABLE REMOTE ADMIN CONNECTIONS OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2006'  
SET @Description = 'Disable remove admin connections option for MSSQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "remote admin connections" is enabled'
					,'USE [master];EXECUTE sp_configure ''remote admin connections'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''remote admin connections'', 1;RECONFIGURE'
		FROM		sys.configurations 
		WHERE		name = 'remote admin connections' 
		  AND		value_in_use = 1   
	END
	  
 /* 
	TEST ID:      2007	
	DESCRIPTION:  DISABLE WEB ASSISTANT PROCEDURES OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2007'  
SET @Description = 'Disable web assistant procedures option for MSSQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "Web Assistant Procedures" is enabled'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''Web Assistant Procedures'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''Web Assistant Procedures'', 1;RECONFIGURE'
		FROM		sys.configurations 
		WHERE		name = 'Web Assistant Procedures' 
		  AND		value_in_use = 1   
	END
	  
/* 
	TEST ID:      2010	
	DESCRIPTION:  DISABLE AD HOC DISTRIBUTED QUERIES OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2010'  
SET @Description = 'Disable ad hoc distributed queries option for MSSQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "Ad Hoc Distributed Queries" is enabled'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''Ad Hoc Distributed Queries'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''Ad Hoc Distributed Queries'', 1;RECONFIGURE'
		FROM		sys.configurations 
		WHERE		name = 'Ad Hoc Distributed Queries' 
		  AND		value_in_use = 1
	END
	  
/* 
	TEST ID:      2011	
	DESCRIPTION:  DISABLE X..P.._..C..M..D..S..H..E..L..L OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2011'  
SET @Description = 'Disable ' + CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108) + ' option for MSSQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "' + CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108) + '" is enabled'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''' + CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108) + ''', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''' + CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108) + ''', 1;RECONFIGURE'
		FROM		sys.configurations 
		WHERE		name = CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108) 
		  AND		value_in_use = 1
	END
	
/* 
	TEST ID:      2012	
	DESCRIPTION:  ENABLE COMMON CRITERIA COMPLIANCE ENABLED OPTION FOR MSSQL 2005 SP2 AND ABOVE
*/
SET @GuardiumTestId = '2012'  
SET @Description = 'Enable common criteria compliance enabled option for MSSQL 2005 SP2 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		IF @SQLEdition = 3
			BEGIN
				IF @SQLVersionMajor >= 9
					-- BEGIN
					--     IF (@SQLVersionMajor = 9 AND @SQLServicePack >= 'SP2') OR @SQLVersionMajor > 9
							INSERT INTO #Report
							SELECT		@SQLServer
										,@GuardiumTestId
										,@Description
										,'master'
										,'Configuration "common criteria compliance enabled" is not enabled'
										,'/* BEFORE EXECUTING, PLEASE REVIEW THE FOLLOWING LINK http://msdn.microsoft.com/en-us/library/bb326650(v=SQL.105).aspx, THERE ARE SCRIPTS THAT NEEDS TO BE EXECUTED WHEN TURNING THIS OPTION ON AND MUST BE AT CERTAIN SP */USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''common criteria compliance enabled'', 0;RECONFIGURE'
										,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''common criteria compliance enabled'', 1;RECONFIGURE'
							FROM		sys.configurations 
							WHERE		name = 'common criteria compliance enabled'
							  AND		value_in_use = 0
					-- END
			END
	END
	
/* 
	TEST ID:      2014	
	DESCRIPTION:  DISABLE AGENT XPS OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2014'  
SET @Description = 'Disable Agent XPs option for MSSQL 2005 and above'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "Agent XPs" is enabled'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''Agent XPs'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''show advanced options'', 1;RECONFIGURE;EXECUTE sp_configure ''Agent XPs'', 1;RECONFIGURE'
		FROM		sys.configurations
		WHERE		name = 'Agent XPs'
		  AND		value_in_use = 1
	END
	
DEALLOCATE CURSOR_DB

-- SELECT * FROM #Report

SELECT		ISNULL(GuardiumTestId, '') + '<1>' +
				ISNULL(GuardiumTestDesc, '') + '<2>' +
				ISNULL(DbName, '') + '<3>' +
				ISNULL(Description, '') + '<4>' +
				ISNULL(FixScript, '') + '<5>' +
				ISNULL(RollbackScript, '')
FROM		#Report
ORDER BY	CASE WHEN ISNUMERIC(GuardiumTestId) = 0 THEN 0 ELSE CAST(GuardiumTestId AS int) END