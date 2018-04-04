/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2005 & UP

	NAME:           2005_2008_AUDIT.SQL

    DESCRIPTION:    THIS SCRIPT REPORTS GUARDIUM FINGINS BASED ON THE FOLLOWING
                    TEST ID
                    
                    *  141 - NO GUEST ACCOUNTS
                    *  143 - NO PUBLIC ACCESS TO AGENT JOB CONTROL PROCEDURES
                    *  144 - NO AUTHORIZATIONS GRANTED ON PROCEDURES THAT CAN LEAD TO PRIVILEGE ESCALATION
                    *  146 - NO XP_READERRORLOG ACCESS
                    *  147 - NO XP_CMDSHELL ACCESS
                    *  149 - NO DTS PACKAGE CREATION AUTHORITIES
                    *  150 - WINDOWS ADMIN IS NOT IMPLICIT MS SQL ADMIN
                    *  151 - NO OLE AUTOMATION AUTHORIZATIONS
                    *  152 - NO SP_MSSETALERTINFO ACCESS
                    *  155 - NO PRIVILEGES WITH THE GRANT OPTION
                    *  156 - NO SAMPLE DATABASES
                    *  159 - ONLY DBAS IN FIXED SERVER ROLES
                    *  163 - NO ORPHANED USERS
                    *  205 - SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
                    *  211 - NO ACCESS TO SQLMAIL EXTENDED PROCEDURES
                    *  214 - NO ACCESS TO OLE AUTOMATION PROCEDURES'
                    *  319 - DB_OWNER GRATNED ON USERS AND ROLES
                    *  320 - DB_SECURITYADMIN GRATNED ON USERS AND ROLES
                    *  321 - DDL GRANTED TO USER
                    * 2001 - DISABLE CLR OPTION FOR MSSQL 2005 AND ABOVE
                    * 2002 - DISABLE SQL MAIL USE UNLESS NEEDED FOR MSSQL 2005 AND ABOVE
                    * 2005 - RENAME SA ACCOUNT FOR MSSQL 2005 AND ABOVE
                    * 2006 - DISABLE REMOTE ADMIN CONNECTIONS OPTION FOR MSSQL 2005 AND ABOVE
                    * 2007 - DISABLE WEB ASSISTANT PROCEDURES OPTION FOR MSSQL 2005 AND ABOVE
                    * 2010 - DISABLE AD HOC DISTRIBUTED QUERIES OPTION FOR MSSQL 2005 AND ABOVE
                    * 2011 - DISABLE XP_CMDSHELL OPTION FOR MSSQL 2005 AND ABOVE
                    * 
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        11/26/2011 1.0      INITIAL CREATION
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
		,@SQL				varchar(2000)	
		
SET @SQLServer = CAST(SERVERPROPERTY('MachineName') AS varchar(128)) + CASE WHEN CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) IS NULL THEN '' ELSE '\' + CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) END

/* 
	TEST ID:      141
	
	DESCRIPTION:  NO GUEST ACCOUNTS
*/
SET @GuardiumTestId = '141'
SET @Description = 'No Guest Accounts'

SET @SQL = 'USE [?]'
SET @SQL = @SQL + 
		   'IF EXISTS( '
SET @SQL = @SQL +         'SELECT		* '
SET @SQL = @SQL +         'FROM		    sys.database_principals			    U WITH (NOLOCK) '
SET @SQL = @SQL +                           'JOIN sys.database_permissions	P WITH (NOLOCK) ON U.principal_id = P.grantee_principal_id '
SET @SQL = @SQL +         'WHERE		U.name = ''guest'' '
SET @SQL = @SQL +         '  AND		P.state_desc = ''GRANT'' '
SET @SQL = @SQL +         '  AND		''?'' NOT IN (''master'', ''tempdb'', ''msdb'') '
SET @SQL = @SQL +         '  AND		P.permission_name = ''CONNECT'' '
SET @SQL = @SQL +    ') '
SET @SQL = @SQL +         'SELECT ''' + @SQLServer + ''', ''' + @GuardiumTestId + ''', ''' + @Description + ''', ''?'', ''Guest account exist on database [?].'', ''USE [?];REVOKE CONNECT TO [guest];'', ''USE [?];GRANT CONNECT TO [guest];'' '

INSERT INTO #Report 
EXECUTE master.dbo.sp_MSforeachdb @command1 = @SQL

/* 
	TEST ID:      143
	
	DESCRIPTION:  NO PUBLIC ACCESS TO AGENT JOB CONTROL PROCEDURES
*/
SET @GuardiumTestId = '143'
SET @Description = 'No public access to agent job control procedures'

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

/* 
	TEST ID:      144
	
	DESCRIPTION:  NO AUTHORIZATIONS GRANTED ON PROCEDURES THAT CAN LEAD TO PRIVILEGE ESCALATION
*/
SET @GuardiumTestId = '144'
SET @Description = 'No authorizations granted on procedures that can lead to privilege escalation.'

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

/* 
	TEST ID:      146
	
	DESCRIPTION:  NO XP_READERRORLOG ACCESS
*/
SET @GuardiumTestId = '146'
SET @Description = 'No xp_readerrorlog access'

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

/* 
	TEST ID:      147
	
	DESCRIPTION:  NO XP_CMDSHELL ACCESS
*/
SET @GuardiumTestId = '147'
SET @Description = 'No xp_cmdshell access'

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
WHERE		B.name = 'xp_cmdshell'
  AND		C.state NOT IN ('D', 'R')  

/* 
	TEST ID:      149
	
	DESCRIPTION:  NO DTS PACKAGE CREATION AUTHORITIES
*/
SET @GuardiumTestId = '149'
SET @Description = 'No DTS package creation authorities'

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
  
    
/* 
	TEST ID:      150
	
	DESCRIPTION:  WINDOWS ADMIN IS NOT IMPLICIT MS SQL ADMIN
*/  
SET @GuardiumTestId = '150'
SET @Description = 'Windows admin is not implicit MS SQL Admin'

INSERT INTO #Report
SELECT		@SQLServer
			,@GuardiumTestId
			,@Description
			,'master'
			,'The [BuiltIn\Administrators] account has sysadmin access.'
			,'USE [master];EXECUTE master..sp_dropsrvrolemember @loginame = N''BUILTIN\Administrators'', @rolename = N''sysadmin'''
			,'USE [master];EXECUTE master..sp_addsrvrolemember @loginame = N''BUILTIN\Administrators'', @rolename = N''sysadmin'''
FROM		sys.syslogins 
WHERE		UPPER(name) = 'BUILTIN\ADMINISTRATORS' 
  AND		sysadmin = 1  


/* 
	TEST ID:      151
	
	DESCRIPTION:  NO OLE AUTOMATION AUTHORIZATIONS
*/  
SET @GuardiumTestId = '151'
SET @Description = 'No OLE automation authorizations'

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


/* 
	TEST ID:      152
	
	DESCRIPTION:  NO SP_MSSETALERTINFO ACCESS
*/
SET @GuardiumTestId = '152'
SET @Description = 'No sp_mssetalertinfo access'

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

/* 
	TEST ID:      155
	
	DESCRIPTION:  NO PRIVILEGES WITH THE GRANT OPTION
*/
SET @GuardiumTestId = '155'
SET @Description = 'No privileges with the grant option'

SET @SQL = 'USE [?]; '
SET @SQL = @SQL + 
           'SELECT		''' + @SQLServer + ''' '
SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
SET @SQL = @SQL + '	   ,''' + @Description + ''' '
SET @SQL = @SQL + '	   ,''?'' '
SET @SQL = @SQL + '	   ,QUOTENAME(D.name) + '' ('' + D.type_desc + '') has WITH GRANT option setup for '' + C.permission_name COLLATE DATABASE_DEFAULT + '' permission on '' + QUOTENAME(''?'') + ''.'' + QUOTENAME(A.name) + ''.'' +  QUOTENAME(B.name) + '' ('' + B.type_desc + '') .'' '
SET @SQL = @SQL + '	   ,''USE [?];REVOKE GRANT OPTION FOR '' + C.permission_name COLLATE DATABASE_DEFAULT  + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO '' + QUOTENAME(D.name) + '' CASCADE;''  '
SET @SQL = @SQL + '	   ,''USE [?];GRANT '' + C.permission_name COLLATE DATABASE_DEFAULT + '' ON '' + QUOTENAME(A.name) + ''.'' + QUOTENAME(B.name) + '' TO '' + QUOTENAME(D.name) + '' WITH GRANT OPTION;'' '
SET @SQL = @SQL + 
           'FROM		[?].sys.schemas A '
SET @SQL = @SQL + '	       JOIN [?].sys.all_objects B ON A.schema_id = B.schema_id '
SET @SQL = @SQL + '	       JOIN [?].sys.database_permissions C ON B.object_id = C.major_id '
SET @SQL = @SQL + '	       JOIN [?].sys.database_principals D ON C.grantee_principal_id = D.principal_id '
SET @SQL = @SQL + 
		   'WHERE		C.state = ''W'' '
SET @SQL = @SQL + 
		   '  AND		B.type <> ''S'' /* SYSTEM_TABLE */ '

INSERT INTO #Report
EXECUTE master.dbo.sp_MSforeachdb @command1 = @SQL

SET @SQL = 'USE [?]; '
SET @SQL = @SQL + 
           'SELECT		''' + @SQLServer + ''' '
SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
SET @SQL = @SQL + '	   ,''' + @Description + ''' '
SET @SQL = @SQL + '	   ,''?'' '
SET @SQL = @SQL + '	   ,QUOTENAME(C.name) + '' ('' + C.type_desc + '') has WITH GRANT option setup for '' + B.permission_name COLLATE DATABASE_DEFAULT + '' permission on '' + QUOTENAME(''?'') + ''.'' + QUOTENAME(A.name) + '' (SCHEMA) .'' '
SET @SQL = @SQL + '	   ,''USE [?];REVOKE GRANT OPTION FOR '' + B.permission_name COLLATE DATABASE_DEFAULT + '' ON SCHEMA::'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' CASCADE;''  '
SET @SQL = @SQL + '	   ,''USE [?];GRANT '' + B.permission_name COLLATE DATABASE_DEFAULT + '' ON SCHEMA::'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' WITH GRANT OPTION;'' '
SET @SQL = @SQL + 
           'FROM		[?].sys.schemas A '
SET @SQL = @SQL + '	       JOIN [?].sys.database_permissions B ON A.schema_id = B.major_id '
SET @SQL = @SQL + '	       JOIN [?].sys.database_principals C ON B.grantee_principal_id = C.principal_id '
SET @SQL = @SQL + 
		   'WHERE		B.state = ''W'' '
SET @SQL = @SQL + 
		   '  AND		B.class = 3 /* SCHEMA */ '
		   
INSERT INTO #Report
EXECUTE master.dbo.sp_MSforeachdb @command1 = @SQL
		

/* 
	TEST ID:      156
	
	DESCRIPTION:  NO SAMPLE DATABASES
*/
SET @GuardiumTestId = '156'
SET @Description = 'No sample databases'

INSERT INTO #Report
SELECT		@SQLServer
			,@GuardiumTestId
			,@Description
			,name
			,'Sample database ' + name + ' exists.'
			,'/* MAKE A BACKUP BEFORE DROPPING DATABASE */ USE ' + QUOTENAME(name) + ';DROP DATABASE ' + name 
			,'RESTORE FROM BACKUP'
FROM		sys.databases
WHERE		name IN (
						'Northwind', 'pubs', 
						'AdventureWorks', 'AdventureWorksAS', 'AdventureWorksDW', 'AdventureWorksLT',
						'AdventureWorks2008', 'AdventureWorksAS2008', 'AdventureWorksDW2008', 'AdventureWorksLT2008', 
						'AdventureWorks2008R2', 'AdventureWorksAS2008R2', 'AdventureWorksDW2008R2', 'AdventureWorksLT2008R2'
					)

 /* 
	TEST ID:      159
	
	DESCRIPTION:  ONLY DBAS IN FIXED SERVER ROLES
*/
SET @GuardiumTestId = '159'
SET @Description = 'Only DBAs in fixed server roles'

INSERT INTO #Report
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
WHERE		C.name IN ('sysadmin', 'securityadmin', 'serveradmin', 'setupadmin', 'processadmin', 'diskadmin', 'dbcreator', 'bulkadmin')
  AND		A.name NOT IN	(
								'sa'
								,'US\DEV_DBA'
								,'US\DEV_DBA_AD'
								,'US\w9_sql_dba_ad'
								,'US\w9_sql_dba'
								,'US\AA03279'		-- White, Brian J
								,'US\AA03279AD'		-- White, Brian J
								,'US\AA71727'		-- MODASRA, ARUN
								,'US\AA71727AD'		-- MODASRA, ARUN
								,'US\AA79441'		-- Khalidh, Shafeek
								,'US\AA79441AD'		-- Khalidh, Shafeek
								,'US\aa96644'		-- Terebecki, Steve
								,'US\aa96644AD'		-- Terebecki, Steve
								,'US\AB01886'		-- BAILEY, SARAH J
								,'US\AB01886ad'		-- BAILEY, SARAH J
								,'US\ab21079'		-- Jackson, Jerry
								,'US\ab21079AD'		-- Jackson, Jerry
								,'US\AB75155'		-- Saeger, Kristin L.
								,'US\AB75155AD'		-- Saeger, Kristin L.
								,'US\AB78178'		-- Patil, Kiran M.
								,'US\AB78178AD'		-- Patil, Kiran M.
								,'US\AB78179'		-- Thumma, Amani
								,'US\AB78179AD'		-- Thumma, Amani
								,'US\AB82086'		-- WILLIAMS, ANTHONY L.
								,'US\AB82086AD'		-- WILLIAMS, ANTHONY L.
								,'US\AC03562'		-- Adusumilli, Satyam
								,'US\AC03562AD'		-- Adusumilli, Satyam
								,'US\AC13939'		-- Vaddi, Kim
								,'US\AC13939AD'		-- Vaddi, Kim
								,'US\AC27535'		-- Prashanth, Pavan
								,'US\AC27535AD'		-- Prashanth, Pavan
								,'US\AC28423'		-- Kuchipudi, Swagath
								,'US\AC28423AD'		-- Kuchipudi, Swagath
								,'US\AC29488'		-- Boddepalli, Ramu
								,'US\AC29488AD'		-- Boddepalli, Ramu
								,'US\AC29489'		-- Bandi, Vijay
								,'US\AC29489AD'		-- Bandi, Vijay
								,'US\AC33108'		-- Odonkor, Solomon
								,'US\AC33108AD'		-- Odonkor, Solomon
								,'US\AC33109'		-- Richardson, Jim
								,'US\AC33109AD'		-- Richardson, Jim
								,'US\AC33111'		-- Sawyer, Tom
								,'US\AC33111AD'		-- Sawyer, Tom
								,'US\AC33680'		-- Saseendrannair, Sabarinath
								,'US\AC33680AD'		-- Saseendrannair, Sabarinath
								,'US\AC34451'		-- Dubey, Pawan Kumar
								,'US\AC34451AD'		-- Dubey, Pawan Kumar
								,'US\AC34452'		-- Muthusamy, Vijayakumar
								,'US\AC34452AD'		-- Muthusamy, Vijayakumar
								,'US\AC34586'		-- SK, Vali
								,'US\AC34586AD'		-- SK, Vali
								,'US\AC35225'		-- Paul, Babu
								,'US\AC35225AD'		-- Paul, Babu
								,'US\AC37258'		-- PILI, JIMMY G.
								,'US\AC37258AD'		-- PILI, JIMMY G.
								,'US\AC37259'		-- SHANMUGHAM, BIPIN
								,'US\AC37259AD'		-- SHANMUGHAM, BIPIN
								,'US\AC37351'		-- Chilukuri, Sharad
								,'US\AC37351AD'		-- Chilukuri, Sharad
								,'US\AC43787'		-- Subramanian, Sriram
								,'US\AC43787AD'		-- Subramanian, Sriram
								,'US\AC43788'		-- PALADUGU, VEERANJANEYULU
								,'US\AC43788AD'		-- PALADUGU, VEERANJANEYULU
								,'US\AC45555'		-- James, Suja
								,'US\AC45555AD'		-- James, Suja
								,'US\JEGREEN'		-- Green, James
								,'US\JEGREENAD'		-- Green, James
								,'US\nichoby'		-- Nichols, Jay
								,'US\nichobyAD'		-- Nichols, Jay
								,'US\RCH0533'		-- Gaither, Ray
								,'US\RCH0533AD'		-- Gaither, Ray
								,'US\RCH1021'		-- Low, Lawrence
								,'US\RCH1021AD'		-- Low, Lawrence
								,'US\wherrmr'		-- Wherry, Martha A
								,'US\wherrmrAD'		-- Wherry, Martha A
							)
  AND		(A.name <> 'US\MO-AOC_MSSQL' AND C.name <> 'securityadmin')
							

 /* 
	TEST ID:      163
	
	DESCRIPTION:  NO ORPHANED USERS
*/
SET @GuardiumTestId = '163'  
SET @Description = 'No orphaned users'

SET @SQL = 'USE [?];'
SET @SQL = @SQL + 
           'SELECT		''' + @SQLServer + ''' '
SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
SET @SQL = @SQL + '	   ,''' + @Description + ''' '
SET @SQL = @SQL + '	   ,''?'' '
SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' is an orphan user in database [?].'' '
SET @SQL = @SQL + '	   ,''/* BEFORE DROPPING ACCOUNT, MAKE SURE YOU CAN BECAUSE ROLLBACK SCRIPT ONLY ADDS ACCOUNT BACK, NOT THE PERMISSIONS */USE [?];DROP USER '' + QUOTENAME(A.name) '
SET @SQL = @SQL + '	   ,''USE [?];CREATE USER '' + QUOTENAME(A.name) + '' FOR LOGIN '' + QUOTENAME(A.name) '
SET @SQL = @SQL + 
		   'FROM		[?].sys.database_principals A '
SET @SQL = @SQL + '	       LEFT JOIN master.sys.server_principals B ON A.sid = B.sid '
SET @SQL = @SQL + 
		   'WHERE		B.sid IS NULL '
SET @SQL = @SQL + 
		   '  AND		A.type IN (''S'', ''U'', ''G'') '
SET @SQL = @SQL + 
		   '  AND		A.sid <> 0x00 '
SET @SQL = @SQL + 
		   '  AND		A.sid IS NOT NULL '
SET @SQL = @SQL +
           '  AND		(''?'' <> ''msdb'' AND A.name <> ''MS_DataCollectorInternalUser'') '		   

INSERT INTO #Report
EXECUTE sp_MSforeachdb @SQL

 /* 
	TEST ID:      205
	
	DESCRIPTION:  SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
*/
SET @GuardiumTestId = '205'  
SET @Description = 'SQL OLEDB disabled (DisallowedAdhocAccess registry key)'

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

 /* 
	TEST ID:      211
	
	DESCRIPTION:  NO ACCESS TO SQLMAIL EXTENDED PROCEDURES
*/
SET @GuardiumTestId = '211'  
SET @Description = 'No access to SQLMail extended procedures'

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
  
 /* 
	TEST ID:      214
	
	DESCRIPTION:  NO ACCESS TO OLE AUTOMATION PROCEDURES
*/
SET @GuardiumTestId = '214'  
SET @Description = 'No access to OLE automation procedures'

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
  
 /* 
	TEST ID:      319
	
	DESCRIPTION:  DB_OWNER GRATNED ON USERS AND ROLES
*/
SET @GuardiumTestId = '319'  
SET @Description = 'db_owner granted on users and roles'

SET @SQL = 'USE [?];'
SET @SQL = @SQL + 
           'SELECT		''' + @SQLServer + ''' '
SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
SET @SQL = @SQL + '	   ,''' + @Description + ''' '
SET @SQL = @SQL + '	   ,''?'' '
SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' has db_owner permissions in database [?].'' '
SET @SQL = @SQL + '	   ,''USE [?];EXECUTE sp_droprolemember N''''db_owner'''', N'''''' + A.name + '''''''' '
SET @SQL = @SQL + '	   ,''USE [?];EXECUTE sp_addrolemember  N''''db_owner'''', N'''''' + A.name + '''''''' '
SET @SQL = @SQL +       
           'FROM		sys.database_principals A '
SET @SQL = @SQL +           'JOIN sys.database_role_members B ON A.principal_id = B.member_principal_id '
SET @SQL = @SQL +           'JOIN sys.database_principals C ON B.role_principal_id = C.principal_id '
SET @SQL = @SQL + 
           'WHERE		C.name = ''db_owner'' '
SET @SQL = @SQL +       
             'AND		A.name <> ''dbo'' '
             
INSERT INTO #Report
EXECUTE sp_MSforeachdb @SQL

 /* 
	TEST ID:      320
	
	DESCRIPTION:  DB_SECURITYADMIN GRATNED ON USERS AND ROLES
*/
SET @GuardiumTestId = '320'  
SET @Description = 'db_securityadmin granted on users and roles'

SET @SQL = 'USE [?];'
SET @SQL = @SQL + 
           'SELECT		''' + @SQLServer + ''' '
SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
SET @SQL = @SQL + '	   ,''' + @Description + ''' '
SET @SQL = @SQL + '	   ,''?'' '
SET @SQL = @SQL + '	   ,''Account '' + QUOTENAME(A.name) + '' has db_securityadmin permissions in database [?].'' '
SET @SQL = @SQL + '	   ,''USE [?];EXECUTE sp_droprolemember N''''db_securityadmin'''', N'''''' + A.name + '''''''' '
SET @SQL = @SQL + '	   ,''USE [?];EXECUTE sp_addrolemember  N''''db_securityadmin'''', N'''''' + A.name + '''''''' '
SET @SQL = @SQL +       
           'FROM		sys.database_principals A '
SET @SQL = @SQL +           'JOIN sys.database_role_members B ON A.principal_id = B.member_principal_id '
SET @SQL = @SQL +           'JOIN sys.database_principals C ON B.role_principal_id = C.principal_id '
SET @SQL = @SQL + 
           'WHERE		C.name = ''db_securityadmin'' '
SET @SQL = @SQL +       
             'AND		A.name <> ''dbo'' '
             
INSERT INTO #Report
EXECUTE sp_MSforeachdb @SQL

 /* 
	TEST ID:      321
	
	DESCRIPTION:  DDL GRANTED TO USER
*/
SET @GuardiumTestId = '321'  
SET @Description = 'DDL granted to user'

SET @SQL = 'USE [?];'
SET @SQL = @SQL + 
           'SELECT		''' + @SQLServer + ''' '
SET @SQL = @SQL + '	   ,''' + @GuardiumTestId + ''' '
SET @SQL = @SQL + '	   ,''' + @Description + ''' '
SET @SQL = @SQL + '	   ,''?'' '
SET @SQL = @SQL + '	   ,QUOTENAME(A.name) + '' ('' + @A.type_desc + '') has '' + QUOTENAME(B.permission_name) + '' permission on [?]'' '
SET @SQL = @SQL + '	   ,''USE [?];REVOKE '' + B.permission_name + '' TO '' + QUOTENAME(A.name) + '' CASCADE;'' '
SET @SQL = @SQL + '	   ,''USE [?];GRANT '' + B.permission_name + '' TO '' + QUOTENAME(A.name) '
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
             

 /* 
	TEST ID:      2001
	
	DESCRIPTION:  DISABLE CLR OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2001'  
SET @Description = 'Disable CLR option for MSQL 2005 and above'

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

 /* 
	TEST ID:      2002
	
	DESCRIPTION:  DISABLE SQL MAIL USE UNLESS NEEDED FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2002'  
SET @Description = 'Disable SQL Mail use unless needed for MSSQL 2005 and above'

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

 /* 
	TEST ID:      2005
	
	DESCRIPTION:  RENAME SA ACCOUNT FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2005'  
SET @Description = 'Rename sa account for MSsQL 2005 and above'

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

 /* 
	TEST ID:      2006
	
	DESCRIPTION:  DISABLE REMOTE ADMIN CONNECTIONS OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2006'  
SET @Description = 'Disable remove admin connections option for MSSQL 2005 and above'

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
  
 /* 
	TEST ID:      2007
	
	DESCRIPTION:  DISABLE WEB ASSISTANT PROCEDURES OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2007'  
SET @Description = 'Disable web assistant procedures option for MSSQL 2005 and above'

INSERT INTO #Report
SELECT		@SQLServer
			,@GuardiumTestId
			,@Description
			,'master'
			,'Configuration "Web Assistant Procedures" is enabled'
			,'USE [master];EXECUTE sp_configure ''Web Assistant Procedures'', 0;RECONFIGURE'
			,'USE [master];EXECUTE sp_configure ''Web Assistant Procedures'', 1;RECONFIGURE'
FROM		sys.configurations 
WHERE		name = 'Web Assistant Procedures' 
  AND		value_in_use = 1   
  
/* 
	TEST ID:      2010
	
	DESCRIPTION:  DISABLE AD HOC DISTRIBUTED QUERIES OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2010'  
SET @Description = 'Disable ad hoc distributed queries option for MSSQL 2005 and above'

INSERT INTO #Report
SELECT		@SQLServer
			,@GuardiumTestId
			,@Description
			,'master'
			,'Configuration "Ad Hoc Distributed Queries" is enabled'
			,'USE [master];EXECUTE sp_configure ''Ad Hoc Distributed Queries'', 0;RECONFIGURE'
			,'USE [master];EXECUTE sp_configure ''Ad Hoc Distributed Queries'', 1;RECONFIGURE'
FROM		sys.configurations 
WHERE		name = 'Ad Hoc Distributed Queries' 
  AND		value_in_use = 1
  
/* 
	TEST ID:      2011
	
	DESCRIPTION:  DISABLE XP_CMDSHELL OPTION FOR MSSQL 2005 AND ABOVE
*/
SET @GuardiumTestId = '2011'  
SET @Description = 'Disable xp_cmdshell option for MSSQL 2005 and above'

INSERT INTO #Report
SELECT		@SQLServer
			,@GuardiumTestId
			,@Description
			,'master'
			,'Configuration "xp_cmdshell" is enabled'
			,'USE [master];EXECUTE sp_configure ''xp_cmdshell'', 0;RECONFIGURE'
			,'USE [master];EXECUTE sp_configure ''xp_cmdshell'', 1;RECONFIGURE'
FROM		sys.configurations 
WHERE		name = 'xp_cmdshell' 
  AND		value_in_use = 1
GO
SELECT		ISNULL(GuardiumTestId, '') + '<1>' +
				ISNULL(GuardiumTestDesc, '') + '<2>' +
				ISNULL(DbName, '') + '<3>' +
				ISNULL(Description, '') + '<4>' +
				ISNULL(FixScript, '') + '<5>' +
				ISNULL(RollbackScript, '')
FROM		#Report
GO
DROP TABLE #Report

