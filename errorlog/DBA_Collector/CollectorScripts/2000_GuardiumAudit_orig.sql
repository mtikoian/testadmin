/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2000

	NAME:           2000_AUDIT.SQL

    DESCRIPTION:    THIS SCRIPT REPORTS GUARDIUM FINGINS BASED ON THE FOLLOWING
                    TEST ID
                    
                    * 141 - NO GUEST ACCOUNTS
                    * 142 - ALLOW UPDATES TO SYSTEM TABLES
                    * 143 - NO PUBLIC ACCESS TO AGENT JOB CONTROL PROCEDURES
                    * 144 - NO AUTHORIZATIONS GRANTED ON PROCEDURES THAT CAN LEAD TO PRIVILEGE ESCALATION
                    * 146 - NO XP_READERRORLOG ACCESS
                    * 147 - NO XP_CMDSHELL ACCESS
                    * 149 - NO DTS PACKAGE CREATION AUTHORITIES
                    * 150 - WINDOWS ADMIN IS NOT IMPLICIT MS SQL ADMIN
                    * 151 - NO OLE AUTOMATION AUTHORIZATIONS
                    * 152 - NO SP_MSSETALERTINFO ACCESS
                    * 155 - NO PRIVILEGES WITH THE GRANT OPTION
                    * 156 - NO SAMPLE DATABASES
                    * 159 - ONLY DBAS IN FIXED SERVER ROLES
                    * 163 - NO ORPHANED USERS
                    * 205 - SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
                    * 211 - NO ACCESS TO SQLMAIL EXTENDED PROCEDURES
                    * 214 - NO ACCESS TO OLE AUTOMATION PROCEDURES'
                    * 319 - DB_OWNER GRATNED ON USERS AND ROLES
                    * 320 - DB_SECURITYADMIN GRATNED ON USERS AND ROLES
                    * 321 - DDL GRANTED TO USER
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        11/27/2011 1.0      INITIAL CREATION
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
SET @SQL = @SQL +         'FROM		    dbo.sysusers U '
SET @SQL = @SQL +         'WHERE		U.name = ''guest'' '
SET @SQL = @SQL +         '  AND		U.issqluser = 1 '
SET @SQL = @SQL +         '  AND		U.hasdbaccess = 1 '
SET @SQL = @SQL +         '  AND		''?'' NOT IN (''master'', ''tempdb'', ''msdb'') '
SET @SQL = @SQL +    ') '
SET @SQL = @SQL +         'SELECT ''' + @SQLServer + ''', ''' + @GuardiumTestId + ''', ''' + @Description + ''', ''?'', ''Guest account exist on database [?].'', '
                + '''USE [?];EXECUTE dbo.sp_revokedbaccess N''''guest'''';'', ''USE [?];EXECUTE dbo.sp_grantdbaccess N''''guest'''';'' '

INSERT INTO #Report 
EXECUTE master.dbo.sp_MSforeachdb @command1 = @SQL

/* 
	TEST ID:      142
	
	DESCRIPTION:  ALLOW UPDATES TO SYSTEM TABLES
*/
SET @GuardiumTestId = '142'
SET @Description = 'Allow updates to system tables is on'

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
			,'Public role has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [master].'
			,'USE [master];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO [public] CASCADE;'
			,'USE [master];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO [public];'
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
			,'Public role has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [msdb].'
			,'USE [msdb];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO [public] CASCADE;'
			,'USE [msdb];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO [public];'
FROM		msdb.dbo.sysobjects O
				JOIN msdb.dbo.sysprotects P ON O.id = P.id
WHERE		O.name IN ('sp_add_job', 'sp_add_jobstep', 'sp_add_jobserver','sp_start_job','xp_execresultset', 'xp_printstatements','xp_displaystatement')  
  AND		P.uid = 0 -- Public Role
  AND		P.protecttype <> 206
  AND		P.action = 224 -- EXECUTE
  
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
			,A.name + ' (' + CASE 
								WHEN A.issqlrole = 1 THEN 'Database Role'
								WHEN A.isapprole = 1 THEN 'Application Role'
								WHEN A.issqluser = 1 THEN 'SQL Account'
								ELSE 'Windows Account'
							 END + ') has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [master].'
			,'USE [master];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ' CASCADE;'
			,'USE [master];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ';'
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
								WHEN A.issqlrole = 1 THEN 'Database Role'
								WHEN A.isapprole = 1 THEN 'Application Role'
								WHEN A.issqluser = 1 THEN 'SQL Account'
								ELSE 'Windows Account'
							 END + ') has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [msdb].'
			,'USE [msdb];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ' CASCADE;'
			,'USE [msdb];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ';'
	FROM		msdb.dbo.sysusers S
					JOIN msdb.dbo.sysobjects O ON O.uid = S.uid
					JOIN msdb.dbo.sysprotects P ON O.id = P.id
					JOIN msdb.dbo.sysusers A ON P.uid = A.uid
WHERE		O.name IN ('xp_execresultset', 'xp_printstatements','xp_displaystatement')  
  AND		P.protecttype <> 206
  AND		P.action = 224 -- EXECUTE

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
			,A.name + ' (' + CASE 
								WHEN A.issqlrole = 1 THEN 'Database Role'
								WHEN A.isapprole = 1 THEN 'Application Role'
								WHEN A.issqluser = 1 THEN 'SQL Account'
								ELSE 'Windows Account'
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
			,A.name + ' (' + CASE 
								WHEN A.issqlrole = 1 THEN 'Database Role'
								WHEN A.isapprole = 1 THEN 'Application Role'
								WHEN A.issqluser = 1 THEN 'SQL Account'
								ELSE 'Windows Account'
							 END + ') has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [master].'
			,'USE [master];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ' CASCADE;'
			,'USE [master];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO ' + QUOTENAME(A.name) + ';'
	FROM		dbo.sysusers S
					JOIN dbo.sysobjects O ON O.uid = S.uid
					JOIN dbo.sysprotects P ON O.id = P.id
					JOIN dbo.sysusers A ON P.uid = A.uid
WHERE		O.name = 'xp_cmdshell' 
  AND		P.protecttype <> 206
  AND		P.action = 224 -- EXECUTE

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
			,'master'
			,'Public role has EXECUTE permissions on Object dbo.' + QUOTENAME(O.name) + ' in database [msdb].'
			,'USE [msdb];REVOKE EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO [public] CASCADE;'
			,'USE [msdb];GRANT EXECUTE ON dbo.' + QUOTENAME(O.name) + ' TO [public];'
FROM		msdb.dbo.sysobjects O
				JOIN msdb.dbo.sysprotects P ON O.id = P.id
WHERE		O.name = 'sp_get_dtspackage'
  AND		P.uid = 0 -- Public Role
  AND		P.protecttype <> 206
  AND		P.action = 224 -- EXECUTE
  
    
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
FROM		syslogins 
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
			,C.name + ' (' + CASE 
					WHEN C.issqlrole = 1 THEN 'Database Role'
					WHEN C.isapprole = 1 THEN 'Application Role'
					WHEN C.issqluser = 1 THEN 'SQL Account'
					ELSE 'Windows Account'
				END + ') has EXECUTE permissions on ' + A.name
			,'USE [master];REVOKE EXECUTE ON dbo.' + A.name + ' TO ' + QUOTENAME(C.name) + ' CASCADE;'
			,'USE [master];GRANT EXECUTE ON dbo.' + A.name + ' TO ' + QUOTENAME(C.name) + ';'
FROM		sysobjects A
				JOIN sysprotects B ON A.id = B.id
				JOIN sysusers C ON B.uid = C.uid
WHERE		A.name IN ('sp_OACreate','sp_OAMethod','sp_OADestroy','sp_OASetProperty','sp_OAGetErrorInfo','sp_OAStop','sp_OAGetProperty')
  AND		B.protecttype <> 206


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
			,'USE [master];REVOKE EXECUTE ON sp_MSsetalertinfo TO [Public] CASCADE;'
			,'USE [master];GRANT EXECUTE ON sp_MSsetalertinfo TO [Public];'
FROM		dbo.sysobjects A
				JOIN dbo.sysprotects  B ON A.id = B.id
WHERE		A.name = 'sp_MSsetalertinfo'
  AND		B.protecttype <> 206 -- DENY
  AND		B.uid = 0 -- Public Role
  AND		B.action = 224 -- EXECUTE

/* 
	TEST ID:      155
	
	DESCRIPTION:  NO PRIVILEGES WITH THE GRANT OPTION
*/
SET @GuardiumTestId = '155'
SET @Description = 'No privileges with the grant option'

SET @SQL = 'USE [?]; '
SET @SQL = @SQL + 
           'SELECT ''' + @SQLServer + ''' '
SET @SQL = @SQL + ',''' + @GuardiumTestId + ''' '
SET @SQL = @SQL + ',''' + @Description + ''' '
SET @SQL = @SQL + ',''?'' '
SET @SQL = @SQL + ',QUOTENAME(C.name) + '' has WITH GRANT option setup on '' + QUOTENAME(''?'') + ''.'' + QUOTENAME(D.name) + ''.'' +  QUOTENAME(A.name) + ''.'' '
SET @SQL = @SQL + ',''USE [?];REVOKE GRANT OPTION FOR '' + CASE B.action WHEN 26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' '
                + 'WHEN 195 THEN ''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' '
                + 'WHEN 207 THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN '
                + '''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE ''UNKNOWN'' END   + '' ON '' + QUOTENAME(D.name) + ''.'' '
                + '+ QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' CASCADE;''  '
SET @SQL = @SQL + ',''USE [?];GRANT '' + CASE B.action WHEN 26 THEN ''REFERENCES'' WHEN 178 THEN ''CREATE FUNCTION'' WHEN 193 THEN ''SELECT'' WHEN 195 THEN '
                + '''INSERT'' WHEN 196 THEN ''DELETE'' WHEN 197 THEN ''UPDATE'' WHEN 198 THEN ''CREATE TABLE'' WHEN 203 THEN ''CREATE DATABASE'' WHEN 207 '
                + 'THEN ''CREATE VIEW'' WHEN 222 THEN ''CREATE PROCEDURE'' WHEN 224 THEN ''EXECUTE'' WHEN 228 THEN ''BACKUP DATABASE'' WHEN 233 THEN ' 
                + '''CREATE DEFAULT'' WHEN 235 THEN ''BACKUP LOG'' WHEN 236 THEN ''CREATE RULE'' ELSE ''UNKNOWN'' END + '' ON '' + QUOTENAME(D.name) + '
                + '''.'' + QUOTENAME(A.name) + '' TO '' + QUOTENAME(C.name) + '' WITH GRANT OPTION;'' '
SET @SQL = @SQL + 
           'FROM dbo.sysobjects A '
SET @SQL = @SQL + 'JOIN dbo.sysprotects B ON A.id = B.id '
SET @SQL = @SQL + 'JOIN dbo.sysusers C ON B.uid = C.uid '
SET @SQL = @SQL + 'JOIN dbo.sysusers D ON A.uid = D.uid '
SET @SQL = @SQL + 
		   'WHERE B.protecttype = 204 '

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
FROM		sysdatabases
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

CREATE TABLE #DBA_ExclusionList
(
	Account		varchar(128)
)

INSERT INTO #DBA_ExclusionList VALUES('sa')
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
			,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''sysadmin'''
			,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''sysadmin'''
FROM		syslogins A
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
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
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
WHERE		A.securityadmin = 1
  AND		B.Account IS NULL
  AND		A.name <> 'US\MO-AOC_MSSQL'
UNION ALL
SELECT		@SQLServer
			,@GuardiumTestId
			,@Description
			,'master'
			,QUOTENAME(A.name) + 'is a member of Server Fixed Role serveradmin.'
			,'EXECUTE master..sp_dropsrvrolemember @loginame = N''' + A.name + ''', @rolename = N''serveradmin'''
			,'EXECUTE master..sp_addsrvrolemember  @loginame = N''' + A.name + ''', @rolename = N''serveradmin'''
FROM		syslogins A
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
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
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
WHERE		A.setupadmin = 1
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
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
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
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
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
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
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
				LEFT JOIN #DBA_ExclusionList B ON A.name = B.Account
WHERE		A.bulkadmin = 1
  AND		B.Account IS NULL
	  
DROP TABLE #DBA_ExclusionList
	  
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
SET @SQL = @SQL + '	   ,''/* BEFORE DROPPING ACCOUNT, MAKE SURE YOU CAN BECAUSE ROLLBACK SCRIPT ONLY ADDS ACCOUNT BACK, '
                + 'NOT THE PERMISSIONS */USE [?];EXECUTE sp_dropuser '''''' + QUOTENAME(A.name) + '''''''' '
SET @SQL = @SQL + '	   ,''USE [?];EXECUTE sp_adduser '''''' + QUOTENAME(A.name) + '''''''' '
SET @SQL = @SQL + 
		   'FROM		[?].dbo.sysusers A '
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
EXECUTE sp_MSforeachdb @SQL

 /* 
	TEST ID:      205
	
	DESCRIPTION:  SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
*/
SET @GuardiumTestId = '205'  
SET @Description = 'SQL OLEDB disabled (DisallowedAdhocAccess registry key)'

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
           'FROM		sysusers A '
SET @SQL = @SQL +           'JOIN sysmembers B ON A.uid = B.memberuid '
SET @SQL = @SQL +           'JOIN sysusers C ON B.groupuid = C.uid '
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
           'FROM		sysusers A '
SET @SQL = @SQL +           'JOIN sysmembers B ON A.uid = B.memberuid '
SET @SQL = @SQL +           'JOIN sysusers C ON B.groupuid = C.uid '
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
SET @SQL = @SQL + '	   ,QUOTENAME(A.name) + '') has '' + '
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
SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) '
SET @SQL = @SQL +       'END '
SET @SQL = @SQL +       ' + '' permission on [?]'' '
SET @SQL = @SQL + '	   ,''USE [?];REVOKE '' + '
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
SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) '
SET @SQL = @SQL +       'END '
SET @SQL = @SQL +      ' + '' TO '' + QUOTENAME(A.name) + '' CASCADE;'' '
SET @SQL = @SQL + '	   ,''USE [?];GRANT '' + '
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
SET @SQL = @SQL +           'ELSE CAST(B.action as varchar(30)) '
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