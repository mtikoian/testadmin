/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2000

	NAME:           2000_AUDIT.SQL

    DESCRIPTION:    THIS SCRIPT REPORTS GUARDIUM FINGINS BASED ON THE FOLLOWING
                    TEST ID
                    
                    *   141 - NO GUEST ACCOUNTS
                    *   142 - ALLOW UPDATES TO SYSTEM TABLES
                    *   143 - NO PUBLIC ACCESS TO AGENT JOB CONTROL PROCEDURES
                    *   144 - NO AUTHORIZATIONS GRANTED ON PROCEDURES THAT CAN LEAD TO PRIVILEGE ESCALATION
                    *   145 - NO WEB TASK AUTHORIZATIONS
                    *   146 - NO XP_READERRORLOG ACCESS
                    *   147 - NO X..P.._..C..M..D..S..H..E..L..L ACCESS
                    *   148 - NO AGENT JOB CREATION AUTHORITIES
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
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        11/27/2011 1.00     INITIAL CREATION
    AB82086        12/12/2011 1.01     FIX A BUG WITH 321, WASN'T GETTING INTO 
                                       REPORT AND IGNORING 205
    AB82086        12/14/2011 1.02     FIX SYNTAX WITH TEST 163                                       
    AB82086        12/16/2011 1.03     ADDED CMDSHELL CHECK, TEST 147
    AB82086        12/21/2011 1.10     ADD TEST 164 & 210.                               
    AB82086        12/22/2011 1.20     ADD TEST 322(SKIPPED FOR NOW). ALSO FIX
                                       THE ACCOUNT TYPE DESCRIPTION TO BE MORE
                                       CONSISTENT. ALSO FIX THE COLLATE ISSUE
                                       INSTEAD OF USING SP_MSFOREACHDB, I AM
                                       USING A CURSOR.  I DO THIS SO I CAN CHECK
                                       COMPAT LEVEL SO I KNOW IF I CAN USE COLLATE
                                       OR NOT. ADDED TEST 145, 269
    AB82086        12/29/2011 1.30     ADDED TEST ID 153, 154    
    AB82086        12/30/2011 1.31     ADDED TEST ID 157, 158, 162
    AB82086        01/24/2012 1.32     ADDED TEST 270, 323
    AB82086        01/31/2012 1.33     ADDED THE ABILITY TO ONLY CHECK FOR A SPECIFIC
                                       TEST ID.  ALSO ADDED TEST ID 148.                           
    AB82086        05/11/2012 1.42     ADD TEST ID 160
   *******************************************************************************
*/
USE [master]
GO
SET NOCOUNT ON

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
		,@SQL				varchar(4000)
		,@SQLServicePack    varchar(25)
		,@SQLVersionMajor   varchar(25)
		,@SQLVersionMinor   varchar(25)
		,@SQLVersionBuild   varchar(25)
		,@DbName            varchar(128)
		,@CompatLevel       tinyint 
		,@Value				int
		,@DynamicPort		varchar(128)
		,@TCPPort			varchar(128)
		,@TestId			varchar(128)
				
SET @SQLServer = CAST(SERVERPROPERTY('MachineName') AS varchar(128)) + CASE WHEN CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) IS NULL THEN '' ELSE '\' + CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) END
SET @SQLVersionMajor = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1)
SET @SQLVersionMinor = SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) + 1, LEN(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - CHARINDEX('.', REVERSE(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)))) - 2)
SET @SQLVersionBuild = SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), LEN(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - CHARINDEX('.', REVERSE(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)))) + 2, LEN(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))))
SET @SQLServicePack = CAST(ISNULL(SERVERPROPERTY('ProductLevel'), 'NULL') AS varchar(25))

SET @TestId = '$(TestId)'

IF @TestId = CHAR(36) + CHAR(40) + CHAR(84) + CHAR(101) + CHAR(115) + CHAR(116) + CHAR(73) + CHAR(100) + CHAR(41) -- '$.(.T.e.s.t.I.d.).'
	SET @TestId = ''			

DECLARE CURSOR_DB CURSOR FAST_FORWARD
FOR
    SELECT      name 
                ,cmptlevel 
    FROM        sysdatabases
    WHERE       DATABASEPROPERTY(name, 'IsOffline') = 0
      AND       DATABASEPROPERTY(name, 'IsInRecovery') = 0
      AND       DATABASEPROPERTY(name, 'IsShutDown') = 0
      AND       DATABASEPROPERTY(name, 'IsSuspect') = 0
      AND       DATABASEPROPERTY(name, 'IsNotRecovered') = 0
      AND       DATABASEPROPERTY(name, 'IsInStandBy')= 0
    ORDER BY    name


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
					SET @SQL = 'USE [' + @DbName + ']'
					SET @SQL = @SQL + 
							   'IF EXISTS( '
					SET @SQL = @SQL +         'SELECT		* '
					SET @SQL = @SQL +         'FROM		    dbo.sysusers U '
					SET @SQL = @SQL +         'WHERE		U.name = ''guest'' '
					SET @SQL = @SQL +         '  AND		U.issqluser = 1 '
					SET @SQL = @SQL +         '  AND		U.hasdbaccess = 1 '
					SET @SQL = @SQL +    ') '
					SET @SQL = @SQL +         'SELECT ''' + @SQLServer + ''', ''' + @GuardiumTestId + ''', ''' + @Description + ''', ''' + @DbName + ''', ''Guest account exist on database [' + @DbName + '].'', ''USE ['+ @DbName + '];EXECUTE dbo.sp_revokedbaccess N''''guest'''';'', ''USE [' + @DbName + '];EXECUTE dbo.sp_grantdbaccess N''''guest'''';'' '
		            
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
	DESCRIPTION:  ALLOW UPDATES TO SYSTEM TABLES
*/
SET @GuardiumTestId = '142'
SET @Description = 'Allow updates to system tables is on'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		INSERT INTO #Report
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,'Configuration "Allow updates to system tables" is enabled'
					,'USE [master];EXECUTE sp_configure ''allow updates'', 0;RECONFIGURE'
					,'USE [master];EXECUTE sp_configure ''allow updates'', 1;RECONFIGURE'
		FROM		dbo.sysconfigures 
		WHERE		comment = 'Allow updates to system tables' 
		  AND		value = 1
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
					,'Public role has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT + ' in database [master].'
					,'USE [master];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public] CASCADE;'
					,'USE [master];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public];'
		FROM		dbo.sysobjects O
						JOIN dbo.sysprotects P ON O.id = P.id
		WHERE		O.name IN ('sp_add_job', 'sp_add_jobstep', 'sp_add_jobserver','sp_start_job','xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.uid = 0 -- Public Role
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'msdb'
					,'Public role has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' in database [msdb].'
					,'USE [msdb];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public] CASCADE;'
					,'USE [msdb];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public];'
		FROM		msdb.dbo.sysobjects O
						JOIN msdb.dbo.sysprotects P ON O.id = P.id
		WHERE		O.name IN ('sp_add_job', 'sp_add_jobstep', 'sp_add_jobserver','sp_start_job','xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.uid = 0 -- Public Role
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
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
					,A.name + ' (' + CASE 
											WHEN A.isntname = 1 THEN CASE WHEN A.isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE 'WINDOWS_USER' END
											WHEN A.issqlrole = 1 THEN 'DATABASE_ROLE' 
											WHEN A.isapprole = 1 THEN 'APPLCATION_ROLE'
											ELSE 'SQL_USER'
									 END + ') has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' in database [master].'
					,'USE [master];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO ' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO ' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ';'
			FROM		dbo.sysusers S
							JOIN dbo.sysobjects O ON O.uid = S.uid
							JOIN dbo.sysprotects P ON O.id = P.id
							JOIN dbo.sysusers A ON P.uid = A.uid
		WHERE		O.name IN ('xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'msdb'
					,A.name + ' (' + CASE 
											WHEN A.isntname = 1 THEN CASE WHEN A.isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE 'WINDOWS_USER' END
											WHEN A.issqlrole = 1 THEN 'DATABASE_ROLE' 
											WHEN A.isapprole = 1 THEN 'APPLCATION_ROLE'
											ELSE 'SQL_USER'
									 END + ') has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [msdb].'
					,'USE [msdb];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO ' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' CASCADE;'
					,'USE [msdb];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO ' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ';'
			FROM		msdb.dbo.sysusers S
							JOIN msdb.dbo.sysobjects O ON O.uid = S.uid
							JOIN msdb.dbo.sysprotects P ON O.id = P.id
							JOIN msdb.dbo.sysusers A ON P.uid = A.uid
		WHERE		O.name IN ('xp_execresultset', 'xp_printstatements','xp_displaystatement')  
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
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
					,'msdb'
					,'[public] (DATABASE_ROLE) has ' + CASE B.action WHEN 193 THEN 'SELECT' WHEN 195 THEN 'INSERT' WHEN 196 THEN 'DELETE' WHEN 197 THEN 'UPDATE' WHEN 26 THEN 'REFERENCES' END  + ' permissions on Object dbo.' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' in database [master].'
					,'USE [msdb];REVOKE ' + CASE B.action WHEN 193 THEN 'SELECT' WHEN 195 THEN 'INSERT' WHEN 196 THEN 'DELETE' WHEN 197 THEN 'UPDATE' WHEN 26 THEN 'REFERENCES' END  + ' ON dbo.' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' TO [public] CASCADE;'
					,'USE [msdb];GRANT ' + CASE B.action WHEN 193 THEN 'SELECT' WHEN 195 THEN 'INSERT' WHEN 196 THEN 'DELETE' WHEN 197 THEN 'UPDATE' WHEN 26 THEN 'REFERENCES' END  + ' ON dbo.' + QUOTENAME(A.name) COLLATE DATABASE_DEFAULT  + ' TO [public];'
		FROM		msdb.dbo.sysobjects A
						JOIN msdb.dbo.sysprotects B ON A.id = B.id
		WHERE		A.name = 'mswebtasks'
		  AND		B.protecttype <> 206 -- DENY
		  AND		B.uid = 0 -- public
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
					,A.name + ' (' + CASE 
											WHEN A.isntname = 1 THEN CASE WHEN A.isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE 'WINDOWS_USER' END
											WHEN A.issqlrole = 1 THEN 'DATABASE_ROLE' 
											WHEN A.isapprole = 1 THEN 'APPLCATION_ROLE'
											ELSE 'SQL_USER'
									 END + ') has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [master].'
					,'USE [master];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ';'
			FROM		dbo.sysusers S
							JOIN dbo.sysobjects O ON O.uid = S.uid
							JOIN dbo.sysprotects P ON O.id = P.id
							JOIN dbo.sysusers A ON P.uid = A.uid
		WHERE		O.name = 'xp_readerrorlog' 
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
		  AND       A.issqluser = 1
		  
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
					,A.name + ' (' + CASE 
											WHEN A.isntname = 1 THEN CASE WHEN A.isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE 'WINDOWS_USER' END
											WHEN A.issqlrole = 1 THEN 'DATABASE_ROLE' 
											WHEN A.isapprole = 1 THEN 'APPLCATION_ROLE'
											ELSE 'SQL_USER'
									 END + ') has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [master].'
					,'USE [master];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ';'
			FROM		dbo.sysusers S
							JOIN dbo.sysobjects O ON O.uid = S.uid
							JOIN dbo.sysprotects P ON O.id = P.id
							JOIN dbo.sysusers A ON P.uid = A.uid
		WHERE		O.name = CHAR(120) + CHAR(112) + CHAR(95) + CHAR(99) + CHAR(109) + CHAR(100) + CHAR(115) + CHAR(104) + CHAR(101) + CHAR(108) + CHAR(108)
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
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
					,'Public role has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' in database [msdb].'
					,'USE [msdb];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public] CASCADE;'
					,'USE [msdb];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public];'
		FROM		msdb.dbo.sysobjects O
						JOIN msdb.dbo.sysprotects P ON O.id = P.id
		WHERE		O.name = 'sp_add_job'
		  AND		P.uid = 0 -- Public Role
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
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
					,'master'
					,'Public role has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' in database [msdb].'
					,'USE [msdb];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public] CASCADE;'
					,'USE [msdb];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) COLLATE DATABASE_DEFAULT  + ' TO [public];'
		FROM		msdb.dbo.sysobjects O
						JOIN msdb.dbo.sysprotects P ON O.id = P.id
		WHERE		O.name = 'sp_get_dtspackage'
		  AND		P.uid = 0 -- Public Role
		  AND		P.protecttype <> 206
		  AND		P.action = 224 -- EXECUTE
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
		            ,'USE [master];DECLARE @Message varchar(256); IF NOT EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''US\W9_SQL_DBA_AD'' AND sysadmin = 1) BEGIN SET @Message = ''BUILTIN\Administrators account cannot be removed, the US\W9_SQL_DBA_AD account does not exist or does not have sysadmin.  Please add this group account manually and remove BUILTIN\Administrators.'' RAISERROR (@Message, 18, 1) END ELSE BEGIN IF EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''BUILTIN\ADMINISTRATORS'') EXECUTE sp_revokelogin ''BUILTIN\ADMINISTRATORS'' END '
		            ,'USE [master];EXECUTE sp_grantlogin ''BUILTIN\ADMINISTRATORS'';EXECUTE master..sp_addsrvrolemember @loginame = N''BUILTIN\ADMINISTRATORS'', @rolename = N''sysadmin'' ' 
		FROM		syslogins 
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
					,C.name + ' (' + CASE 
											WHEN C.isntname = 1 THEN CASE WHEN C.isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE 'WINDOWS_USER' END
											WHEN C.issqlrole = 1 THEN 'DATABASE_ROLE' 
											WHEN C.isapprole = 1 THEN 'APPLCATION_ROLE'
											ELSE 'SQL_USER'
									 END + ') has EXECUTE permissions on ' + A.name
					,'USE [master];REVOKE EXECUTE ON dbo.' + A.name + ' TO ' + QUOTENAME(C.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON dbo.' + A.name + ' TO ' + QUOTENAME(C.name) + ';'
		FROM		sysobjects A
						JOIN sysprotects B ON A.id = B.id
						JOIN sysusers C ON B.uid = C.uid
		WHERE		A.name IN ('sp_OACreate','sp_OAMethod','sp_OADestroy','sp_OASetProperty','sp_OAGetErrorInfo','sp_OAStop','sp_OAGetProperty')
		  AND		B.protecttype <> 206
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
					,'USE [master];REVOKE EXECUTE ON sp_MSsetalertinfo TO [Public] CASCADE;'
					,'USE [master];GRANT EXECUTE ON sp_MSsetalertinfo TO [Public];'
		FROM		dbo.sysobjects A
						JOIN dbo.sysprotects  B ON A.id = B.id
		WHERE		A.name = 'sp_MSsetalertinfo'
		  AND		B.protecttype <> 206 -- DENY
		  AND		B.uid = 0 -- Public Role
		  AND		B.action = 224 -- EXECUTE
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
							   '  AND A.xtype = ''S'' '
					SET @SQL = @SQL + 
							   '  AND B.action = 193 '
					SET @SQL = @SQL + 
							   '  AND UPPER(C.name) <> ''GDMMONITOR'' '

					INSERT INTO #Report
					EXECUTE (@SQL)
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
			SET @SQL = 'USE [' + @DbName + '];'
			SET @SQL = @SQL + 
					   'SELECT		''' + @SQLServer + ''' '
			SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
			SET @SQL = @SQL + '	   ,''' + @Description + ''' '
			SET @SQL = @SQL + '	   ,''' + @DbName + ''' '
			SET @SQL = @SQL + '	   ,QUOTENAME(D.name) + '' ('' + CASE WHEN D.isntname = 1 THEN CASE WHEN D.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE ''WINDOWS_USER'' END WHEN D.issqlrole = 1 THEN ''DATABASE_ROLE'' WHEN D.isapprole = 1 THEN ''APPLCATION_ROLE'' ELSE ''SQL_USER'' END + '') has '' + CASE C.action WHEN  26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) '
			SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE '' + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
			SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT ''  + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
			SET @SQL = @SQL + 
					   'FROM		sysusers A '
			SET @SQL = @SQL +          'JOIN sysobjects B ON A.uid = B.uid '
			SET @SQL = @SQL +          'JOIN sysprotects C ON B.id = C.id '
			SET @SQL = @SQL +          'JOIN sysusers D ON C.uid = D.uid '
			SET @SQL = @SQL +      
					   'WHERE		D.issqluser = 1 '
			SET @SQL = @SQL +      
						 'AND		C.protecttype <> 206 '

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
		FROM		sysdatabases
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
		CREATE TABLE #ProtocolList
		(
			Name		varchar(25)
			,Protocol	varchar(25)
		)

		INSERT INTO #ProtocolList
		EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\'
									,N'ProtocolList'
									,@Value OUTPUT
									,'NO_OUTPUT'

		IF EXISTS(SELECT * FROM #ProtocolList WHERE Protocol = 'tcp')
			BEGIN
				EXECUTE xp_instance_regread 'HKEY_LOCAL_MACHINE' 
											,'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
											,'TcpDynamicPorts'
											,@DynamicPort OUTPUT
											,'NO_OUTPUT'
				 
				EXECUTE xp_instance_regread 'HKEY_LOCAL_MACHINE'
											,'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
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
								,'/* PLEASE CONFIGURE THE STATIC PORT PER OUR STANDARDS, YOU WILL NEED TO USE SERVER NETWORK UTILITY TO MAKE THESE CHANGES */'
								,'/* CHANGE THE PORT BACK TO 1433 USING THE SEVER NETWORK UTILITY */'

				IF @DynamicPort = 1433
					INSERT INTO #Report
					SELECT		@SQLServer
								,@GuardiumTestId
								,@Description
								,'master'
								,'TCP/IP connection to this server is configured to use the default port 1433, please fix the dynamic port.'
								,'/* PLEASE CONFIGURE THE STATIC PORT PER OUR STANDARDS, YOU WILL NEED TO USE SERVER NETWORK UTILITY TO MAKE THESE CHANGES */'
								,'/* CHANGE THE PORT BACK TO 1433 USING THE SEVER NETWORK UTILITY */'
			END
			
		DROP TABLE #ProtocolList
	END
	
/* 
	TEST ID:      158	
	DESCRIPTION:  NO INDIVIDUAL USER ACCESS TO SYSCOMMENTS AND SP_HELPTEXT
*/
SET @GuardiumTestId = '158'
SET @Description = 'No individual user access to syscomments and sp_helptext.'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		OPEN CURSOR_DB

		FETCH NEXT FROM CURSOR_DB
		INTO @DbName, @CompatLevel

		WHILE @@FETCH_STATUS = 0
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
					   '  AND A.name IN (''syscomments'', ''sp_helptext'')  '

			INSERT INTO #Report
			EXECUTE (@SQL)
				
			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
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
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role sysadmin.'
					,CASE WHEN UPPER(A.name) = 'BUILTIN\ADMINISTRATORS' THEN 'USE [master];DECLARE @Message varchar(256); IF NOT EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''US\W9_SQL_DBA_AD'' AND sysadmin = 1) BEGIN SET @Message = ''BUILTIN\Administrators account cannot be removed, the US\W9_SQL_DBA_AD account does not exist or does not have sysadmin.  Please add this group account manually and remove BUILTIN\Administrators.'' RAISERROR (@Message, 18, 1) END ELSE BEGIN IF EXISTS(SELECT * FROM syslogins WHERE UPPER(name) = ''BUILTIN\ADMINISTRATORS'') EXECUTE sp_droplogin ''BUILTIN\ADMINISTRATORS'' END ' ELSE 'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''sysadmin''' END
					,CASE WHEN UPPER(A.name) = 'BUILTIN\ADMINISTRATORS' THEN 'USE [master];EXECUTE sp_grantlogin ''BUILTIN\ADMINISTRATORS'';EXECUTE master..sp_addsrvrolemember @loginame = N''BUILTIN\ADMINISTRATORS'', @rolename = N''sysadmin'' ' ELSE 'EXECUTE master..sp_addsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''sysadmin''' END
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.sysadmin = 1
		  AND		B.Account IS NULL
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role securityadmin.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''securityadmin'''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''securityadmin'''
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.securityadmin = 1
		  AND		B.Account IS NULL
		  AND		UPPER(A.name) <> 'US\MO-AOC_MSSQL'
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role serveradmin.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''serveradmin'''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''serveradmin'''
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.serveradmin = 1
		  AND		B.Account IS NULL
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role setupadmin.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''setupadmin'''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''setupadmin'''
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.setupadmin = 1
		  AND		UPPER(A.name) <> 'US\SRCGUARDIUM'
		  AND		UPPER(A.name) <> 'US\SRCTOPOLOGY'
		  AND		B.Account IS NULL
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role processadmin.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''processadmin'''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''processadmin'''
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.processadmin = 1
		  AND		B.Account IS NULL
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role diskadmin.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''diskadmin'''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''diskadmin'''
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.diskadmin = 1
		  AND		B.Account IS NULL
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role dbcreator.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''dbcreator'''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''dbcreator'''
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.dbcreator = 1
		  AND		B.Account IS NULL
		UNION ALL
		SELECT		@SQLServer
					,@GuardiumTestId
					,@Description
					,'master'
					,QUOTENAME(A.name) + 'is a member of Server Fixed Role bulkadmin.'
					,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''bulkadmin'''
					,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''bulkadmin'''
		FROM		syslogins A
						LEFT JOIN #DBA_ExclusionList B ON UPPER(A.name) = UPPER(B.Account)
		WHERE		A.bulkadmin = 1
		  AND		B.Account IS NULL
			  
		DROP TABLE #DBA_ExclusionList
	END	  

 /* 
    TEST ID:      160
	
    DESCRIPTION:  NO PUBLIC OR GUEST PREDEFINED ROLE AUTHORIZATION
*/
SET @GuardiumTestId = '160'  
SET @Description = 'No Public or Guest Predefined Role Authorization'

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
            SET @SQL = @SQL + '	   ,QUOTENAME(A.name) + '' ('' + CASE WHEN A.issqluser = 1 THEN ''SQL_USER'' ELSE ''DATABASE_ROLE'' END  + '') is a member of  '' + QUOTENAME(C.name) + '' database role in database ' + QUOTENAME(@DbName) + '.'' '
            SET @SQL = @SQL + '	   ,''USE ' + QUOTENAME(@DbName) + ';EXECUTE sp_droprolemember '''''' + C.name + '''''', '''''' + A.name + '''''''' '
            SET @SQL = @SQL + '	   ,''USE ' + QUOTENAME(@DbName) + ';EXECUTE sp_addrolemember '''''' + C.name + '''''', '''''' + A.name + '''''''' '
            SET @SQL = @SQL + 
                       'FROM		' + QUOTENAME(@DbName) + '.dbo.sysusers A '
            SET @SQL = @SQL + '	       JOIN ' + QUOTENAME(@DbName) + '.dbo.sysmembers B ON A.uid = B.memberuid  '
            SET @SQL = @SQL + '	       JOIN ' + QUOTENAME(@DbName) + '.dbo.sysusers C ON B.groupuid = C.uid  '
            SET @SQL = @SQL + 
                       'WHERE		A.uid IN (0, 2) -- public & guest '
            SET @SQL = @SQL + 
                       '  AND		C.issqlrole = 1 '
            SET @SQL = @SQL + 
                       '  AND		C.name IN (''db_owner'', ''db_accessadmin'', ''db_securityadmin'', ''db_ddladmin'', ''db_backupoperator'', ''db_datareader'', ''db_datawriter'') '

            INSERT INTO #Report 
            EXECUTE (@SQL)

            FETCH NEXT FROM CURSOR_DB
            INTO @DbName, @CompatLevel        
        END                

        CLOSE CURSOR_DB

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
			        SET @SQL = 'USE [' + @DbName + ']; '
			        SET @SQL = @SQL + 
					           'SELECT ''' + @SQLServer + ''' '
			        SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
			        SET @SQL = @SQL + ',''' + @Description + ''' '
			        SET @SQL = @SQL + ',''' + @DbName + ''' '
			        SET @SQL = @SQL + ',QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' ('' + CASE B.xtype WHEN ''C'' THEN ''CHECK constraint'' WHEN ''D'' THEN ''DEFAULT constraint'' WHEN ''F'' THEN ''FOREIGN KEY constraint'' WHEN ''L'' THEN ''Log'' WHEN ''FN'' THEN ''Scalar Function'' WHEN ''IF'' THEN ''In-lined table-function'' WHEN ''P'' THEN ''Stored procedure'' WHEN ''PK'' THEN ''PRIMARY KEY constraint'' WHEN ''RF'' THEN ''Replication filter stored procedure'' WHEN ''S'' THEN ''System table'' WHEN ''TF'' THEN ''Table function'' WHEN ''TR'' THEN ''Trigger'' WHEN ''U'' THEN ''User table'' WHEN ''UQ'' THEN ''UNIQUE constraint'' WHEN ''V'' THEN ''View'' WHEN ''X'' THEN ''Extended stored procedure'' ELSE B.xtype END + '') is not owned by ''''dbo''''.'''
					        SET @SQL = @SQL + ',''/* RESEARCH NEEDS TO TAKE PLACE TO SEE IF OBJECT OWNER CAN BE ALTERED TO DBO, THIS CAN BE DONE BY USING SP_CHANGEOBJECTOWNER */''  '
			        SET @SQL = @SQL + ',''''  '
			        SET @SQL = @SQL + 
					           'FROM dbo.sysusers A '
			        SET @SQL = @SQL + 'JOIN dbo.sysobjects B ON A.uid = B.uid '
			        SET @SQL = @SQL + 
					           'WHERE A.name NOT IN (''dbo'', ''INFORMATION_SCHEMA'', ''system_function_schema'') '

			        INSERT INTO #Report
			        EXECUTE (@SQL)
        				
			        FETCH NEXT FROM CURSOR_DB
			        INTO @DbName, @CompatLevel        
		        END                

		        CLOSE CURSOR_DB
	        END
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
			SET @SQL = @SQL + '	   ,''/* BEFORE DROPPING ACCOUNT, MAKE SURE YOU CAN BECAUSE ROLLBACK SCRIPT ONLY ADDS ACCOUNT BACK, NOT THE PERMISSIONS */USE [' + @DbName + '];EXECUTE sp_dropuser '''''' + A.name + '''''''' '
			SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];EXECUTE sp_adduser '''''' + A.name + '''''''' '
			SET @SQL = @SQL + 
					   'FROM		[' + @DbName + '].dbo.sysusers A '
			SET @SQL = @SQL + '	       LEFT JOIN master.dbo.syslogins B ON A.sid = B.sid '
			SET @SQL = @SQL + 
					   'WHERE		B.sid IS NULL '
			SET @SQL = @SQL + 
					   '  AND		A.issqluser = 1 '
			SET @SQL = @SQL + 
					   '  AND		A.sid <> 0x00 '
			SET @SQL = @SQL + 
					   '  AND		A.sid IS NOT NULL '

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

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END
	
/* 
	TEST ID:      205	
	DESCRIPTION:  SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
*/
/*
SET @GuardiumTestId = '205'  
SET @Description = 'SQL OLEDB disabled (DisallowedAdhocAccess registry key)'

IF @TestId = '' OR @TestId = @GuardiumTestId
	BEGIN 
		DECLARE @ProviderName	varchar(128)
				,@Key			varchar(256)
				,@Value			int


		CREATE TABLE #OLEDBProv 
		(
				ProviderName varchar(128) NOT NULL
				,ParseName varchar(50) NOT NULL
				,Description varchar(255) NOT NULL 
		) 

		INSERT INTO #OLEDBProv 
		EXECUTE master.dbo.xp_enum_oledb_providers

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
			SET @Key = N'Software\Microsoft\MSSQLServer\Providers\' + @ProviderName
			
			EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
										,@Key
										,N'DisallowAdhocAccess'
										,@Value OUTPUT
										,'NO_OUTPUT'
										
			IF ISNULL(@Value, 0) = 0
				INSERT INTO #Report
				SELECT		@SQLServer
							,@GuardiumTestId
							,@Description
							,'master'
							,'Disallow Adhoc Access is not enabled for provider ' + QUOTENAME(@ProviderName)
							,'USE [master];EXECUTE xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''' + @Key + ''', N''DisallowAdHocAccess'', N''REG_DWORD'', 1'
							,'USE [master];EXECUTE xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''' + @Key + ''', N''DisallowAdHocAccess'', N''REG_DWORD'', 0'
			
			FETCH NEXT FROM CURSOR_PROVIDER 
			INTO @ProviderName 
		END 

		CLOSE CURSOR_PROVIDER 
		DEALLOCATE CURSOR_PROVIDER

		DROP TABLE #OLEDBProv
	END
*/

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
					,QUOTENAME(C.name) + ' (' + CASE 
													WHEN C.isntname = 1 THEN CASE WHEN C.isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE 'WINDOWS_USER' END
													WHEN C.issqlrole = 1 THEN 'DATABASE_ROLE' 
													WHEN C.isapprole = 1 THEN 'APPLCATION_ROLE'
													ELSE 'SQL_USER'
												END + ') has ' + CASE B.action 
																	WHEN  26 THEN 'REFERENCES'
																	WHEN 178 THEN 'CREATE FUNCTION'
																	WHEN 193 THEN 'SELECT'
																	WHEN 195 THEN 'INSERT'
																	WHEN 196 THEN 'DELETE'
																	WHEN 197 THEN 'UPDATE'
																	WHEN 198 THEN 'CREATE TABLE'
																	WHEN 203 THEN 'CREATE DATABASE'
																	WHEN 207 THEN 'CREATE VIEW'
																	WHEN 222 THEN 'CREATE PROCEDURE'
																	WHEN 224 THEN 'EXECUTE'
																	WHEN 228 THEN 'BACKUP DATABASE'
																	WHEN 233 THEN 'CREATE DEFAULT'
																	WHEN 235 THEN 'BACKUP LOG'
																	WHEN 236 THEN 'CREATE RULE'
																 END COLLATE DATABASE_DEFAULT + ' permissions on ' + QUOTENAME(D.name) + '.' + QUOTENAME(A.name) + ' (' + CASE A.xtype
																																											WHEN 'C' THEN 'CHECK constraint'
																																											WHEN 'D' THEN 'DEFAULT constraint'
																																											WHEN 'F' THEN 'FOREIGN KEY constraint'
																																											WHEN 'L' THEN 'Log'
																																											WHEN 'FN' THEN 'Scalar function'
																																											WHEN 'IF' THEN 'In-lined table-function'
																																											WHEN 'P' THEN 'Stored procedure'
																																											WHEN 'PK' THEN 'PRIMARY KEY constraint'
																																											WHEN 'RF' THEN 'Replication filter stored procedure'
																																											WHEN 'S' THEN 'System table'
																																											WHEN 'TF' THEN 'Table function'
																																											WHEN 'TR' THEN 'Trigger'
																																											WHEN 'U' THEN 'User table'
																																											WHEN 'UQ' THEN 'UNIQUE constraint'
																																											WHEN 'V' THEN 'View'
																																											WHEN 'X' THEN 'Extended stored procedure'
																																										  END  + ').  This permission needs to be removed.'
					,'USE [master];REVOKE ' + CASE B.action 
																	WHEN  26 THEN 'REFERENCES'
																	WHEN 178 THEN 'CREATE FUNCTION'
																	WHEN 193 THEN 'SELECT'
																	WHEN 195 THEN 'INSERT'
																	WHEN 196 THEN 'DELETE'
																	WHEN 197 THEN 'UPDATE'
																	WHEN 198 THEN 'CREATE TABLE'
																	WHEN 203 THEN 'CREATE DATABASE'
																	WHEN 207 THEN 'CREATE VIEW'
																	WHEN 222 THEN 'CREATE PROCEDURE'
																	WHEN 224 THEN 'EXECUTE'
																	WHEN 228 THEN 'BACKUP DATABASE'
																	WHEN 233 THEN 'CREATE DEFAULT'
																	WHEN 235 THEN 'BACKUP LOG'
																	WHEN 236 THEN 'CREATE RULE'
																 END COLLATE DATABASE_DEFAULT  + ' ON ' + QUOTENAME(D.name) + '.' + QUOTENAME(A.name) + ' TO ' + QUOTENAME(C.name)
					,'USE [master];GRANT ' + CASE B.action 
																	WHEN  26 THEN 'REFERENCES'
																	WHEN 178 THEN 'CREATE FUNCTION'
																	WHEN 193 THEN 'SELECT'
																	WHEN 195 THEN 'INSERT'
																	WHEN 196 THEN 'DELETE'
																	WHEN 197 THEN 'UPDATE'
																	WHEN 198 THEN 'CREATE TABLE'
																	WHEN 203 THEN 'CREATE DATABASE'
																	WHEN 207 THEN 'CREATE VIEW'
																	WHEN 222 THEN 'CREATE PROCEDURE'
																	WHEN 224 THEN 'EXECUTE'
																	WHEN 228 THEN 'BACKUP DATABASE'
																	WHEN 233 THEN 'CREATE DEFAULT'
																	WHEN 235 THEN 'BACKUP LOG'
																	WHEN 236 THEN 'CREATE RULE'
																 END COLLATE DATABASE_DEFAULT + ' ON ' + QUOTENAME(D.name) + '.' + QUOTENAME(A.name) + ' TO ' + QUOTENAME(C.name)
		FROM        dbo.sysobjects A
						JOIN dbo.sysprotects B ON A.id = B.id
						JOIN dbo.sysusers C ON B.uid = C.uid -- PERMISSIONS APPLIED TO
						JOIN dbo.sysusers D ON A.uid = D.uid -- OWNER
		                
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
		  AND       B.protecttype <> 206
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
					,'Account ' + QUOTENAME(D.name) + ' EXECUTE permissions ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' in [master] database.'
					,'USE [master];REVOKE EXECUTE ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ';'
		FROM		sysusers A
						JOIN sysobjects B ON A.uid = B.uid
						JOIN sysprotects C ON B.id = C.id
						JOIN sysusers D ON C.uid = D.uid
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
		  AND		C.protecttype <> 206
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
					,'Account ' + QUOTENAME(D.name) + ' EXECUTE permissions ON ' + QUOTENAME(A.name) + '.' + QUOTENAME(B.name) + ' in [master] database.'
					,'USE [master];REVOKE EXECUTE ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ' CASCADE;'
					,'USE [master];GRANT EXECUTE ON ' + B.name + ' TO ' + QUOTENAME(D.name) + ';'
		FROM		sysusers A
						JOIN sysobjects B ON A.uid = B.uid
						JOIN sysprotects C ON B.id = C.id
						JOIN sysusers D ON C.uid = D.uid
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
		  AND		C.protecttype <> 206
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
						,'USE [master];EXECUTE xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''LoginMode'', REG_DWORD, 1'
						,'USE [master];EXECUTE xp_instance_regwrite N''HKEY_LOCAL_MACHINE'', N''Software\Microsoft\MSSQLServer\MSSQLServer'', N''LoginMode'', REG_DWORD, 2'
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
		                 
			INSERT INTO #Report 
			EXECUTE (@SQL)

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END

/* 
	TEST ID:      320	
	DESCRIPTION:  DB_SECURITYADMIN GRATNED ON USERS AND ROLES
*/
SET @GuardiumTestId = '320'  
SET @Description = 'db_securityadmin granted on users and roles'

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
		                 
			INSERT INTO #Report 
			EXECUTE (@SQL)

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
			SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** ''  '
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
			SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' '
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
		                 
			INSERT INTO #Report 
			EXECUTE (@SQL)

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB
	END

/* 
	TEST ID:      322	
	DESCRIPTION:  PROCEDURES GRANTED TO USER
*/
SET @GuardiumTestId = '322'  
SET @Description = 'Procedures granted to user'

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
			SET @SQL = @SQL + '	   ,QUOTENAME(D.name) + '' ('' + CASE WHEN D.isntname = 1 THEN CASE WHEN D.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE ''WINDOWS_USER'' END WHEN D.issqlrole = 1 THEN ''DATABASE_ROLE'' WHEN D.isapprole = 1 THEN ''APPLCATION_ROLE'' ELSE ''SQL_USER'' END + '') has '' + CASE C.action WHEN  26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END  + '' permission on '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) '
			SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];REVOKE '' + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public] CASCADE;'' '
			SET @SQL = @SQL + '	   ,''USE [' + @DbName + '];GRANT ''  + CASE C.action WHEN 193 THEN ''SELECT'' WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ''CREATE DEFAULT'' ELSE CAST(C.action as varchar(30)) + '' **UNABLE TO DETERMINE PERMISSION, YOU HAVE TO FIND THIS INFO MANUALLY ** '' END + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO [public];'' '
			SET @SQL = @SQL + 
					   'FROM		sysusers A '
			SET @SQL = @SQL +          'JOIN sysobjects B ON A.uid = B.uid '
			SET @SQL = @SQL +          'JOIN sysprotects C ON B.id = C.id '
			SET @SQL = @SQL +          'JOIN sysusers D ON C.uid = D.uid '
			SET @SQL = @SQL +      
					   'WHERE		D.issqlrole <> 1 '
			SET @SQL = @SQL +      
						 'AND		D.isapprole <> 1 '
			SET @SQL = @SQL +      
						 'AND		C.protecttype <> 206 '
			SET @SQL = @SQL +      
						 'AND		B.xtype in (''P'',''X'',''RF'')  '

			INSERT INTO #Report 
			EXECUTE (@SQL)

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
		                 
			INSERT INTO #Report 
			EXECUTE (@SQL)

			FETCH NEXT FROM CURSOR_DB
			INTO @DbName, @CompatLevel        
		END                

		CLOSE CURSOR_DB

		DEALLOCATE CURSOR_DB       
	END
GO
SELECT		ISNULL(GuardiumTestId, '') + '<1>' +
				ISNULL(GuardiumTestDesc, '') + '<2>' +
				ISNULL(DbName, '') + '<3>' +
				ISNULL(Description, '') + '<4>' +
				ISNULL(FixScript, '') + '<5>' +
				ISNULL(RollbackScript, '')
FROM		#Report
ORDER BY	CASE WHEN ISNUMERIC(GuardiumTestId) = 0 THEN 0 ELSE CAST(GuardiumTestId AS int) END
GO 
DROP TABLE #Report