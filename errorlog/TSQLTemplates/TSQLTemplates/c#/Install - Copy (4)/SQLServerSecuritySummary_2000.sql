DECLARE @SQL			    varchar(2000)
	    ,@PwdDaysThreshold	smallint
	    ,@DbName            varchar(128)

SET NOCOUNT ON

SET @PwdDaysThreshold = 60

IF OBJECT_ID('tempdb..#SecurityReport') IS NOT NULL
    DROP TABLE #SecurityReport

IF OBJECT_ID('tempdb..#Info') IS NOT NULL
    DROP TABLE #Info

CREATE TABLE #SecurityReport
(
	SR_Security		varchar(256)
	,SR_SecurityType	varchar(256)
	,SR_Database		varchar(256)
	,SR_Class		varchar(256)
	,SR_Object		varchar(256)
	,SR_ObjectType		varchar(256)
	,SR_Column		varchar(256)
	,SR_Permission		varchar(256)
	,SR_State		varchar(60)
)

CREATE TABLE #Info
(
	SID			uniqueidentifier
	,Account	varchar(256)
)

INSERT INTO #Info
EXECUTE master.dbo.sp_validatelogins

-- MEMBER OF ANY SERVER ROLES
INSERT INTO #SecurityReport
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'sysadmin'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		sysadmin = 1
UNION ALL
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'securityadmin'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		securityadmin = 1
UNION ALL
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'serveradmin'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		serveradmin = 1
UNION ALL
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'setupadmin'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		setupadmin = 1
UNION ALL
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'processadmin'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		processadmin = 1
UNION ALL
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'diskadmin'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		diskadmin = 1
UNION ALL
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'dbcreator'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		dbcreator = 1
UNION ALL
SELECT		name
			,CASE WHEN isntgroup = 1 THEN 'WINDOWS_GROUP' ELSE CASE WHEN isntuser = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END END
			,'_N/A'
			,'SERVER'
			,'bulkadmin'
			,'SERVER_ROLE'
			,NULL
			,'MEMBER'
			,NULL
FROM		master.dbo.syslogins 
WHERE		bulkadmin = 1

-- LINK SERVERS
INSERT INTO #SecurityReport
SELECT		I.name + ' (' + CASE WHEN L.xstatus = 192 THEN 'Impersonate' ELSE 'Remote User:  ' + L.name END +  ')'
			,CASE WHEN isntgroup = 1 
					THEN 'WINDOWS_GROUP' 
					ELSE 
						CASE WHEN isntuser = 1 
							THEN 'WINDOWS_LOGIN' 
							ELSE 'SQL_LOGIN' 
						END 
			 END
			,'_N/A'
			,'SERVER'
			,S.srvname
			,'LINK_SERVER'
			,NULL
			,'LOGIN'
			,'NULL'
FROM		master.dbo.sysxlogins 			L  
			JOIN master.dbo.sysservers	S   ON L.srvid = S.srvid
			JOIN master.dbo.syslogins	I   ON L.sid = I.sid
WHERE		S.srvid <> 0

INSERT INTO #SecurityReport
SELECT		DISTINCT 
		CASE 
			WHEN LD.xstatus IS NULL THEN 'Not Be Made'
			WHEN LD.xstatus = 64 AND LD.name IS NULL THEN 'Be made without using a security context'
			WHEN LD.xstatus = 192 AND LD.name IS NULL THEN 'Be made using the login''s current security context'
			ELSE 'Be made using this security context:  ' + LD.name
		END 
		,'LOGIN_NOT_DEFINE'
		,'_N/A'
		,'SERVER'
		,S.srvname
		,'LINK_SERVER'
		,NULL
		,'LOGIN'
		,'NULL'
FROM		master.dbo.sysservers S
			JOIN master.dbo.sysxlogins LS ON S.srvid = LS.srvid
			JOIN master.dbo.syslogins P ON LS.sid = P.sid
			LEFT JOIN (
							SELECT		srvid
										,name
										,xstatus
							FROM		master.dbo.sysxlogins
							WHERE		sid IS NULL
					   ) LD ON S.srvid = LD.srvid
WHERE		S.srvid <> 0

-- PASSWORD EXPIRE
INSERT INTO #SecurityReport
SELECT		name							AS [Security]
		,'SQL_LOGIN'					AS [SecurityType]
		,'_N/A'							AS [Database]
		,'SERVER'						AS [Class]
		,'EXPIRE'						AS [Object]
		,'LOGIN_PROPERTY'				AS [ObjectType]
		,NULL							AS [Column]
		,'IS_EXPIRED'					AS [Permission]
		,DATEDIFF(d, updatedate, GETDATE()) AS [State]
FROM		master.dbo.syslogins
WHERE		DATEDIFF(d, updatedate, GETDATE()) >= @PwdDaysThreshold 
  AND		isntname = 0

-- INVALID DOMAIN ACCOUNTS
INSERT INTO #SecurityReport
SELECT		S.name							AS [Security]
		,CASE WHEN isntgroup = 1 
			THEN 'WINDOWS_GROUP' 
			ELSE CASE WHEN isntuser = 1 
					THEN 'WINDOWS_LOGIN' 
					ELSE 'UNKNOWN' 
				 END 
		END								AS [SecurityType]
		,'_N/A'							AS [Database]
		,'SERVER'						AS [Class]
		,'INVALID_DOMAIN_ACCT'			AS [Object]
		,'LOGIN_PROPERTY'				AS [ObjectType]
		,NULL							AS [Column]
		,'INVALID_DOMAIN_ACCT'			AS [Permission]
		,NULL							AS [State]
FROM		#Info I
			JOIN master.dbo.syslogins S ON I.Account = S.name

DROP TABLE #Info

-- DATABASE OWNER
INSERT INTO #SecurityReport
SELECT		ISNULL(L.name, 'UNKNOWN')
		,CASE 
			WHEN L.name IS NULL 
				THEN 'UNKNOWN' 
				ELSE 
					CASE WHEN isntgroup = 1 
						THEN 'WINDOWS_GROUP' 
						ELSE 
							CASE WHEN isntuser = 1 
								THEN 'WINDOWS_LOGIN' 
								ELSE 'SQL_LOGIN' 
							END 
					END 
		 END
		,D.name
		,'DATABASE'
		,'DATABASE'
		,'DATABASE'
		,NULL
		,'OWNER'
		,NULL
FROM		master.dbo.sysdatabases				D  
			LEFT JOIN master.dbo.syslogins	L   ON D.sid = L.sid

-- SQL JOB OWNER
INSERT INTO #SecurityReport
SELECT		ISNULL(L.name, 'UNKNOWN')
		,CASE 
			WHEN L.name IS NULL 
				THEN 'UNKNOWN' 
				ELSE 
					CASE WHEN isntgroup = 1 
						THEN 'WINDOWS_GROUP' 
						ELSE 
							CASE WHEN isntuser = 1 
								THEN 'WINDOWS_LOGIN' 
								ELSE 'SQL_LOGIN' 
							END 
					END 
		 END
		,'_N/A'
		,'SERVER'
		,J.name
		,'SQL_JOB'
		,NULL
		,'OWNER'
		,NULL
FROM		msdb.dbo.sysjobs					J  
			LEFT JOIN master.dbo.syslogins	L   ON J.owner_sid = L.sid

DECLARE CURSOR_DB CURSOR FAST_FORWARD
FOR
    SELECT      name 
    FROM        sysdatabases
    WHERE       DATABASEPROPERTY(name, 'IsOffline') = 0
      AND       DATABASEPROPERTY(name, 'IsInRecovery') = 0
      AND       DATABASEPROPERTY(name, 'IsShutDown') = 0
      AND       DATABASEPROPERTY(name, 'IsSuspect') = 0
      AND       DATABASEPROPERTY(name, 'IsNotRecovered') = 0
      AND       DATABASEPROPERTY(name, 'IsInStandBy')= 0
    ORDER BY    name

OPEN CURSOR_DB

FETCH NEXT FROM CURSOR_DB
INTO @DbName

WHILE @@FETCH_STATUS = 0
BEGIN
    -- DATABASE USER CONNECT ACCESS
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		L.name '
    SET @SQL = @SQL + ',CASE WHEN L.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE CASE WHEN L.isntuser = 1 THEN ''WINDOWS_LOGIN'' ELSE ''SQL_LOGIN'' END END '
    SET @SQL = @SQL + ',''' + @DbName + ''' '
    SET @SQL = @SQL + ',''DATABASE'' '
    SET @SQL = @SQL + ',''DATABASE'' '
    SET @SQL = @SQL + ',''DATABASE'' '
    SET @SQL = @SQL + ',NULL '
    SET @SQL = @SQL + ',''CONNECT'' '
    SET @SQL = @SQL + ',''GRANT'' '
    SET @SQL = @SQL + 'FROM		sysusers U '
    SET @SQL = @SQL + '		JOIN master.dbo.syslogins L ON U.sid = L.sid '
    SET @SQL = @SQL + 'UNION '
    SET @SQL = @SQL + 'SELECT		U.name '
    SET @SQL = @SQL + ',''SQL_LOGIN'' '
    SET @SQL = @SQL + ',''' + @DbName + ''' '
    SET @SQL = @SQL + ',''DATABASE'' '
    SET @SQL = @SQL + ',''DATABASE'' '
    SET @SQL = @SQL + ',''DATABASE'' '
    SET @SQL = @SQL + ',NULL '
    SET @SQL = @SQL + ',''CONNECT'' '
    SET @SQL = @SQL + ',''GRANT'' '
    SET @SQL = @SQL + 'FROM		sysusers U '
    SET @SQL = @SQL + 'WHERE name = ''guest'' AND hasdbaccess = 1'

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    -- ANY DATABASE USER ACCOUNT BEING ALIAS
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		L.name '
    SET @SQL = @SQL + ',CASE WHEN L.isntgroup = 1 THEN ''WINDOWS_GROUP'' ELSE CASE WHEN L.isntuser = 1 THEN ''WINDOWS_LOGIN'' ELSE ''SQL_LOGIN'' END END '
    SET @SQL = @SQL + ',''' + @DbName + ''' '
    SET @SQL = @SQL + ',''DATABASE'' '
    SET @SQL = @SQL + ',A.name '
    SET @SQL = @SQL + ',''ALIAS'' '
    SET @SQL = @SQL + ',NULL '
    SET @SQL = @SQL + ',''ALIAS'' '
    SET @SQL = @SQL + ',NULL '
    SET @SQL = @SQL + 'FROM		sysusers U '
    SET @SQL = @SQL + '		JOIN sysusers A ON U.altuid = A.uid '
    SET @SQL = @SQL + '		JOIN master.dbo.syslogins L ON U.sid = L.sid '
    SET @SQL = @SQL + 'WHERE		U.isaliased = 1 '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    -- MEMBER OF ANY DATABASE ROLES
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		U.name '
    SET @SQL = @SQL + '             ,CASE '
    SET @SQL = @SQL + '                 WHEN S.isntgroup = 1 '
    SET @SQL = @SQL + '                     THEN ''WINDOWS_GROUP'' '
    SET @SQL = @SQL + '                     ELSE '
    SET @SQL = @SQL + '                         CASE WHEN S.isntuser = 1 '
    SET @SQL = @SQL + '                             THEN ''WINDOWS_LOGIN'' '
    SET @SQL = @SQL + '                             ELSE ''SQL_LOGIN'' '
    SET @SQL = @SQL + '                         END '
    SET @SQL = @SQL + '              END '
    SET @SQL = @SQL + '             ,''' + @DbName + ''' '
    SET @SQL = @SQL + '             ,''DATABASE'' '
    SET @SQL = @SQL + '             ,R.name '
    SET @SQL = @SQL + '             ,''DATABASE_ROLE'' '
    SET @SQL = @SQL + '             ,NULL '
    SET @SQL = @SQL + '             ,''MEMBER'' '
    SET @SQL = @SQL + '             ,NULL '
    SET @SQL = @SQL + 'FROM		    master.dbo.syslogins		S   '
    SET @SQL = @SQL + '                 JOIN dbo.sysusers		U   ON S.sid		= U.sid '
    SET @SQL = @SQL + '                 JOIN dbo.sysmembers		M   ON U.uid		= M.memberuid '
    SET @SQL = @SQL + '                 JOIN dbo.sysusers		R   ON M.groupuid	= R.uid '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)


    -- CHECK FOR GUEST ACCOUNT, IF APPLICABLE
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		U.name '
    SET @SQL = @SQL + '             ,CASE '
    SET @SQL = @SQL + '                 WHEN U.isntgroup = 1 '
    SET @SQL = @SQL + '                     THEN ''WINDOWS_GROUP'' '
    SET @SQL = @SQL + '                     ELSE '
    SET @SQL = @SQL + '                         CASE WHEN U.isntuser = 1 '
    SET @SQL = @SQL + '                             THEN ''WINDOWS_LOGIN'' '
    SET @SQL = @SQL + '                             ELSE ''SQL_LOGIN'' '
    SET @SQL = @SQL + '                         END '
    SET @SQL = @SQL + '              END '
    SET @SQL = @SQL + '             ,''' + @DbName + ''' '
    SET @SQL = @SQL + '             ,''DATABASE'' '
    SET @SQL = @SQL + '             ,R.name '
    SET @SQL = @SQL + '             ,''DATABASE_ROLE'' '
    SET @SQL = @SQL + '             ,NULL '
    SET @SQL = @SQL + '             ,''MEMBER'' '
    SET @SQL = @SQL + '             ,NULL '
    SET @SQL = @SQL + 'FROM		    dbo.sysusers				U '
    SET @SQL = @SQL + '                 JOIN (SELECT uid FROM dbo.sysusers WHERE name = ''guest'' AND hasdbaccess = 1) G ON U.uid = G.uid '
    SET @SQL = @SQL + '                 JOIN dbo.sysmembers		M   ON U.uid		= M.memberuid '
    SET @SQL = @SQL + '                 JOIN dbo.sysusers		R   ON M.groupuid	= R.uid '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)


    -- PERMISSIONS ON DATABASE LEVEL
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT L.name  '
    SET @SQL = @SQL + '  ,CASE WHEN L.isntgroup = 1 THEN ''WINDOWS_GROUP''ELSE CASE WHEN L.isntuser = 1 THEN ''WINDOWS_LOGIN'' ELSE ''SQL_LOGIN'' END END '
    SET @SQL = @SQL + '  ,''' + @DbName + ''' '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL THEN ''OBJECT_OR_COLUMN'' ELSE ''DATABASE'' END '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL THEN QUOTENAME(S.name) + ''.'' + QUOTENAME(O.name) ELSE ''DATABASE'' END '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL '
    SET @SQL = @SQL + '    THEN '  
    SET @SQL = @SQL + '      CASE O.xtype '
    SET @SQL = @SQL + '   	   WHEN ''C'' THEN ''CHECK'' '
    SET @SQL = @SQL + '   	   WHEN ''D'' THEN ''DEFAULT'' '                           
    SET @SQL = @SQL + '   	   WHEN ''F'' THEN ''FOREIGN KEY'' '
    SET @SQL = @SQL + '   	   WHEN ''L'' THEN ''LOG'' '
    SET @SQL = @SQL + '   	   WHEN ''FN'' THEN ''SCALAR FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''IF'' THEN ''INLINE FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''P'' THEN ''STORED PROCEDURE'' '
    SET @SQL = @SQL + '   	   WHEN ''PK'' THEN ''PRIMARY KEY'' '
    SET @SQL = @SQL + '   	   WHEN ''RF'' THEN ''REPLICATION FILTER'' '
    SET @SQL = @SQL + '   	   WHEN ''S'' THEN ''SYSTEM TABLE'' '
    SET @SQL = @SQL + '   	   WHEN ''TF'' THEN ''TABLE FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''TR'' THEN ''TRIGGER'' '
    SET @SQL = @SQL + '   	   WHEN ''U'' THEN ''USER TABLE'' '
    SET @SQL = @SQL + '   	   WHEN ''UQ'' THEN ''UNQIUE CONSTRAINT'' '                           
    SET @SQL = @SQL + '   	   WHEN ''V'' THEN ''VIEW'' '
    SET @SQL = @SQL + '   	   WHEN ''E'' THEN ''EXTENDED STORED PROCEDURE'' '
    SET @SQL = @SQL + '        ELSE O.xtype '		    
    SET @SQL = @SQL + '     END '                   
    SET @SQL = @SQL + '   ELSE ''DATABASE'' '
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + '  ,NULL '
    SET @SQL = @SQL + '  ,CASE action '
    SET @SQL = @SQL + '    WHEN  26 THEN ''REFERENCES'' '
    SET @SQL = @SQL + '    WHEN 178 THEN ''CREATE FUNCTION'' ' 
    SET @SQL = @SQL + '    WHEN 193 THEN ''SELECT'' '
    SET @SQL = @SQL + '    WHEN 195 THEN ''INSERT'' '
    SET @SQL = @SQL + '    WHEN 196 THEN ''DELETE'' '
    SET @SQL = @SQL + '    WHEN 197 THEN ''UPDATE'' '
    SET @SQL = @SQL + '    WHEN 198 THEN ''CREATE TABLE'' ' 
    SET @SQL = @SQL + '    WHEN 203 THEN ''CREATE DATABASE'' '
    SET @SQL = @SQL + '    WHEN 207 THEN ''CREATE VIEW'' ' 
    SET @SQL = @SQL + '    WHEN 222 THEN ''CREATE PROCEDURE'' ' 
    SET @SQL = @SQL + '    WHEN 224 THEN ''EXECUTE'' ' 
    SET @SQL = @SQL + '    WHEN 228 THEN ''BACKUP DATABASE'' ' 
    SET @SQL = @SQL + '    WHEN 233 THEN ''CREATE DEFAULT'' ' 
    SET @SQL = @SQL + '    WHEN 235 THEN ''BACKUP LOG'' '
    SET @SQL = @SQL + '    WHEN 236 THEN ''CREATE RULE'' ' 
    SET @SQL = @SQL + '    ELSE ''UNKOWN'' '		    
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + '  ,CASE protecttype '
    SET @SQL = @SQL + '    WHEN 204 THEN ''GRANT WITH GRANT'' '
    SET @SQL = @SQL + '    WHEN 205 THEN ''GRANT'' '
    SET @SQL = @SQL + '    WHEN 206 THEN ''DENY'' '
    SET @SQL = @SQL + '    ELSE NULL '
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + 'FROM	master.dbo.syslogins L  '
    SET @SQL = @SQL + '	  JOIN dbo.sysusers U  ON L.sid	= U.sid '
    SET @SQL = @SQL + '	  JOIN dbo.sysprotects P  ON U.uid	= P.uid '
    SET @SQL = @SQL + '	  LEFT JOIN dbo.sysobjects O  ON P.id	= O.id '
    SET @SQL = @SQL + '   LEFT JOIN dbo.sysusers S  ON O.uid	= S.uid '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    -- CHECK FOR GUEST ACCOUNT, IF APPLICABLE
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT U.name  '
    SET @SQL = @SQL + '  ,CASE WHEN U.isntgroup = 1 THEN ''WINDOWS_GROUP''ELSE CASE WHEN U.isntuser = 1 THEN ''WINDOWS_LOGIN'' ELSE ''SQL_LOGIN'' END END '
    SET @SQL = @SQL + '  ,''' + @DbName + ''' '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL THEN ''OBJECT_OR_COLUMN'' ELSE ''DATABASE'' END '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL THEN QUOTENAME(S.name) + ''.'' + QUOTENAME(O.name) ELSE ''DATABASE'' END '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL '
    SET @SQL = @SQL + '    THEN '  
    SET @SQL = @SQL + '      CASE O.xtype '
    SET @SQL = @SQL + '   	   WHEN ''C'' THEN ''CHECK'' '
    SET @SQL = @SQL + '   	   WHEN ''D'' THEN ''DEFAULT'' '                           
    SET @SQL = @SQL + '   	   WHEN ''F'' THEN ''FOREIGN KEY'' '
    SET @SQL = @SQL + '   	   WHEN ''L'' THEN ''LOG'' '
    SET @SQL = @SQL + '   	   WHEN ''FN'' THEN ''SCALAR FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''IF'' THEN ''INLINE FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''P'' THEN ''STORED PROCEDURE'' '
    SET @SQL = @SQL + '   	   WHEN ''PK'' THEN ''PRIMARY KEY'' '
    SET @SQL = @SQL + '   	   WHEN ''RF'' THEN ''REPLICATION FILTER'' '
    SET @SQL = @SQL + '   	   WHEN ''S'' THEN ''SYSTEM TABLE'' '
    SET @SQL = @SQL + '   	   WHEN ''TF'' THEN ''TABLE FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''TR'' THEN ''TRIGGER'' '
    SET @SQL = @SQL + '   	   WHEN ''U'' THEN ''USER TABLE'' '
    SET @SQL = @SQL + '   	   WHEN ''UQ'' THEN ''UNQIUE CONSTRAINT'' '                           
    SET @SQL = @SQL + '   	   WHEN ''V'' THEN ''VIEW'' '
    SET @SQL = @SQL + '   	   WHEN ''E'' THEN ''EXTENDED STORED PROCEDURE'' '
    SET @SQL = @SQL + '        ELSE O.xtype '		    
    SET @SQL = @SQL + '     END '                   
    SET @SQL = @SQL + '   ELSE ''DATABASE'' '
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + '  ,NULL '
    SET @SQL = @SQL + '  ,CASE action '
    SET @SQL = @SQL + '    WHEN  26 THEN ''REFERENCES'' '
    SET @SQL = @SQL + '    WHEN 178 THEN ''CREATE FUNCTION'' ' 
    SET @SQL = @SQL + '    WHEN 193 THEN ''SELECT'' '
    SET @SQL = @SQL + '    WHEN 195 THEN ''INSERT'' '
    SET @SQL = @SQL + '    WHEN 196 THEN ''DELETE'' '
    SET @SQL = @SQL + '    WHEN 197 THEN ''UPDATE'' '
    SET @SQL = @SQL + '    WHEN 198 THEN ''CREATE TABLE'' ' 
    SET @SQL = @SQL + '    WHEN 203 THEN ''CREATE DATABASE'' '
    SET @SQL = @SQL + '    WHEN 207 THEN ''CREATE VIEW'' ' 
    SET @SQL = @SQL + '    WHEN 222 THEN ''CREATE PROCEDURE'' ' 
    SET @SQL = @SQL + '    WHEN 224 THEN ''EXECUTE'' ' 
    SET @SQL = @SQL + '    WHEN 228 THEN ''BACKUP DATABASE'' ' 
    SET @SQL = @SQL + '    WHEN 233 THEN ''CREATE DEFAULT'' ' 
    SET @SQL = @SQL + '    WHEN 235 THEN ''BACKUP LOG'' '
    SET @SQL = @SQL + '    WHEN 236 THEN ''CREATE RULE'' ' 
    SET @SQL = @SQL + '    ELSE ''UNKOWN'' '		    
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + '  ,CASE protecttype '
    SET @SQL = @SQL + '    WHEN 204 THEN ''GRANT WITH GRANT'' '
    SET @SQL = @SQL + '    WHEN 205 THEN ''GRANT'' '
    SET @SQL = @SQL + '    WHEN 206 THEN ''DENY'' '
    SET @SQL = @SQL + '    ELSE NULL '
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + 'FROM	dbo.sysusers U   '
    SET @SQL = @SQL + '   JOIN (SELECT uid FROM dbo.sysusers WHERE name = ''guest'' AND hasdbaccess = 1) G ON U.uid = G.uid '
    SET @SQL = @SQL + '	  JOIN dbo.sysprotects P  ON U.uid	= P.uid '
    SET @SQL = @SQL + '	  LEFT JOIN dbo.sysobjects O  ON P.id	= O.id '
    SET @SQL = @SQL + '   LEFT JOIN dbo.sysusers S  ON O.uid	= S.uid '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    -- ANY ROLE MEMBER OF DATABASE ROLES
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		U.name '
    SET @SQL = @SQL + '             ,''DATABASE_ROLE'' '
    SET @SQL = @SQL + '             ,''' + @DbName + ''' '
    SET @SQL = @SQL + '             ,''DATABASE'' '
    SET @SQL = @SQL + '             ,R.name '
    SET @SQL = @SQL + '             ,''DATABASE_ROLE'' '
    SET @SQL = @SQL + '             ,NULL '
    SET @SQL = @SQL + '             ,''MEMBER'' '
    SET @SQL = @SQL + '             ,NULL '
    SET @SQL = @SQL + 'FROM		    dbo.sysusers				U   '
    SET @SQL = @SQL + '                 JOIN dbo.sysmembers		M   ON U.uid		= M.memberuid '
    SET @SQL = @SQL + '                 JOIN dbo.sysusers		R   ON M.groupuid	= R.uid '
    SET @SQL = @SQL + 'WHERE		U.issqlrole = 1 OR U.isapprole = 1 '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    -- ROLE PERMISSIONS ON DATABASE &  LEVEL
    -- PERMISSIONS ON DATABASE LEVEL
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT U.name  '
    SET @SQL = @SQL + '  ,''DATABASE_ROLE'' '
    SET @SQL = @SQL + '  ,''' + @DbName + ''' '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL THEN ''OBJECT_OR_COLUMN'' ELSE ''DATABASE'' END '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL THEN QUOTENAME(S.name) + ''.'' + QUOTENAME(O.name) ELSE ''DATABASE'' END '
    SET @SQL = @SQL + '  ,CASE WHEN O.id IS NOT NULL '
    SET @SQL = @SQL + '    THEN '  
    SET @SQL = @SQL + '      CASE O.xtype '
    SET @SQL = @SQL + '   	   WHEN ''C'' THEN ''CHECK'' '
    SET @SQL = @SQL + '   	   WHEN ''D'' THEN ''DEFAULT'' '                           
    SET @SQL = @SQL + '   	   WHEN ''F'' THEN ''FOREIGN KEY'' '
    SET @SQL = @SQL + '   	   WHEN ''L'' THEN ''LOG'' '
    SET @SQL = @SQL + '   	   WHEN ''FN'' THEN ''SCALAR FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''IF'' THEN ''INLINE FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''P'' THEN ''STORED PROCEDURE'' '
    SET @SQL = @SQL + '   	   WHEN ''PK'' THEN ''PRIMARY KEY'' '
    SET @SQL = @SQL + '   	   WHEN ''RF'' THEN ''REPLICATION FILTER'' '
    SET @SQL = @SQL + '   	   WHEN ''S'' THEN ''SYSTEM TABLE'' '
    SET @SQL = @SQL + '   	   WHEN ''TF'' THEN ''TABLE FUNCTION'' '
    SET @SQL = @SQL + '   	   WHEN ''TR'' THEN ''TRIGGER'' '
    SET @SQL = @SQL + '   	   WHEN ''U'' THEN ''USER TABLE'' '
    SET @SQL = @SQL + '   	   WHEN ''UQ'' THEN ''UNQIUE CONSTRAINT'' '                           
    SET @SQL = @SQL + '   	   WHEN ''V'' THEN ''VIEW'' '
    SET @SQL = @SQL + '   	   WHEN ''E'' THEN ''EXTENDED STORED PROCEDURE'' '
    SET @SQL = @SQL + '        ELSE O.xtype '		    
    SET @SQL = @SQL + '     END '                   
    SET @SQL = @SQL + '   ELSE ''DATABASE'' '
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + '  ,NULL '
    SET @SQL = @SQL + '  ,CASE action '
    SET @SQL = @SQL + '    WHEN  26 THEN ''REFERENCES'' '
    SET @SQL = @SQL + '    WHEN 178 THEN ''CREATE FUNCTION'' ' 
    SET @SQL = @SQL + '    WHEN 193 THEN ''SELECT'' '
    SET @SQL = @SQL + '    WHEN 195 THEN ''INSERT'' '
    SET @SQL = @SQL + '    WHEN 196 THEN ''DELETE'' '
    SET @SQL = @SQL + '    WHEN 197 THEN ''UPDATE'' '
    SET @SQL = @SQL + '    WHEN 198 THEN ''CREATE TABLE'' ' 
    SET @SQL = @SQL + '    WHEN 203 THEN ''CREATE DATABASE'' '
    SET @SQL = @SQL + '    WHEN 207 THEN ''CREATE VIEW'' ' 
    SET @SQL = @SQL + '    WHEN 222 THEN ''CREATE PROCEDURE'' ' 
    SET @SQL = @SQL + '    WHEN 224 THEN ''EXECUTE'' ' 
    SET @SQL = @SQL + '    WHEN 228 THEN ''BACKUP DATABASE'' ' 
    SET @SQL = @SQL + '    WHEN 233 THEN ''CREATE DEFAULT'' ' 
    SET @SQL = @SQL + '    WHEN 235 THEN ''BACKUP LOG'' '
    SET @SQL = @SQL + '    WHEN 236 THEN ''CREATE RULE'' ' 
    SET @SQL = @SQL + '    ELSE ''UNKOWN'' '		    
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + '  ,CASE protecttype '
    SET @SQL = @SQL + '    WHEN 204 THEN ''GRANT WITH GRANT'' '
    SET @SQL = @SQL + '    WHEN 205 THEN ''GRANT'' '
    SET @SQL = @SQL + '    WHEN 206 THEN ''DENY'' '
    SET @SQL = @SQL + '    ELSE NULL '
    SET @SQL = @SQL + '  END '
    SET @SQL = @SQL + 'FROM	dbo.sysusers U  '
    SET @SQL = @SQL + '	  JOIN dbo.sysprotects P  ON U.uid	= P.uid '
    SET @SQL = @SQL + '	  LEFT JOIN dbo.sysobjects O  ON P.id	= O.id '
    SET @SQL = @SQL + '   LEFT JOIN dbo.sysusers S  ON O.uid	= S.uid '
    SET @SQL = @SQL + 'WHERE     U.issqlrole = 1 OR U.isapprole = 1 '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)
    
    FETCH NEXT FROM CURSOR_DB
    INTO @DbName    
END

CLOSE CURSOR_DB
DEALLOCATE CURSOR_DB

SELECT		@@SERVERNAME        AS [SQLServer]
            ,SR_Security		AS [Principal]
            ,SR_SecurityType    AS [PrincipalType]
			,SR_Database		AS [Database]
			,SR_Object			AS [Object]
			,SR_ObjectType		AS [ObjectType]
			,SR_State			AS [State]
			,SR_Permission		AS [Permission]
FROM		#SecurityReport
ORDER BY	SR_Database
			,SR_Security




/*
-- ACCOUNTS MEMBER OF FIXED SERVER ROLES 
SELECT		*
FROM		#SecurityReport 
WHERE		SR_ObjectType = 'SERVER_ROLE'
ORDER BY	SR_Security

-- ACCOUNTS MEMBER OF FIXED DATABASE ROLES
SELECT		*
FROM		#SecurityReport 
WHERE		SR_ObjectType = 'DATABASE_ROLE'
  AND		SR_Object IN ('db_owner', 'db_accessadmin', 'db_backupoperator', 'db_ddladmin', 'db_securityadmin', 'db_datareader', 'db_datawriter')
ORDER BY	SR_Security
			,SR_Database
			  
-- ANY USER ACCOUNT ALIAS
SELECT		*
FROM		#SecurityReport
WHERE		SR_ObjectType = 'Alias'
ORDER BY	SR_Security

-- SQL ACCOUNTS THAT NEEDS THERE PASSWORD CHANGE, PASSWORD ALREAD EXPIRED, DISABLED, LOCKED OR INVALID DOMAIN ACCOUNT
SELECT		*
FROM		#SecurityReport 
WHERE		SR_ObjectType = 'LOGIN_PROPERTY'
ORDER BY	SR_Security

-- GUEST USERS
SELECT		*
FROM		#SecurityReport
WHERE		SR_Security = 'guest'
  AND		SR_Database NOT IN ('tempdb', 'master')
  AND		SR_Permission = 'Connect'
  AND		SR_State = 'Grant'
ORDER BY	SR_Security
			,SR_Database

-- DATABASE LEVEL PERMISSIONS
SELECT		*
FROM		#SecurityReport
WHERE		SR_ObjectType = 'DATABASE'
  AND		SR_State = 'GRANT'
  AND		SR_Security NOT IN ('sa', 'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\NETWORK SERVICE')
  AND		SR_Security NOT LIKE '##%'
  AND		SR_Permission <> 'CONNECT'
ORDER BY	SR_Security
			,SR_Database
			
-- SERVER LEVEL PERMISSIONS 
SELECT		*
FROM		#SecurityReport
WHERE		SR_ObjectType = 'SERVER'
  AND		SR_State = 'GRANT'
  AND		SR_Security NOT IN ('sa', 'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\NETWORK SERVICE')
  AND		SR_Security NOT LIKE '##%'
  AND		SR_Permission NOT IN ('CONNECT', 'CONNECT SQL')
ORDER BY	SR_Security
			,SR_Database

-- MASTER, MODEL, MSDB & TEMPDB USERS 
SELECT		*
FROM		#SecurityReport
WHERE		(
				(
					SR_Database IN ('tempdb', 'master')
						AND SR_Security <> 'guest'
				)
					OR
				(
					SR_Database IN ('model', 'msdb')
				)
			)
  AND		SR_Permission = 'Connect'
  AND		SR_State = 'Grant'
  AND		SR_Security NOT IN ('sa')
ORDER BY	SR_Security
			,SR_Database


--	ACCOUNTS THAT HAVE CONNECT ABILITY TO SQL BUT DO NOT 
--	HAVE ACCESS TO ANY DATABASES.  THIS EXCLUDES ACCOUNTS
--	WITH SQL SERVER FIX ROLES.
SELECT		*
FROM		#SecurityReport A
				LEFT JOIN ( -- FIND ACCOUNTS THAT DON'T HAVE DB CONNECT
								SELECT		DISTINCT
											SR_Security
								FROM		#SecurityReport
								WHERE		SR_SecurityType IN ('WINDOWS_LOGIN', 'SQL_LOGIN')
								  AND		SR_Database <> '_N/A'
								  AND		SR_ObjectType = 'DATABASE'
								  AND		SR_Permission = 'CONNECT'
								  AND		SR_State = 'GRANT'
								  AND		SR_Security NOT IN ('sa', 'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\NETWORK SERVICE')
								  AND		SR_Security NOT LIKE '##%'
						  ) B ON A.SR_Security = B.SR_Security
				LEFT JOIN ( -- FIND ACCOUNTS THAT HAVE SERVER ROLES
								SELECT		SR_Security
								FROM		#SecurityReport
								WHERE		SR_SecurityType IN ('WINDOWS_LOGIN', 'SQL_LOGIN')
								  AND		SR_Security NOT IN ('sa', 'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\NETWORK SERVICE')
								  AND		SR_ObjectType = 'SERVER_ROLE'
								  AND		SR_Class = 'SERVER'
								  AND		SR_Permission = 'Member'
						  ) C ON A.SR_Security = C.SR_Security
				LEFT JOIN ( -- FIND ACCOUNTS WITH SERVER PERMISSIONS
								SELECT		SR_Security
								FROM		#SecurityReport
								WHERE		SR_SecurityType IN ('WINDOWS_LOGIN', 'SQL_LOGIN')
								  AND		SR_Security NOT IN ('sa', 'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\NETWORK SERVICE')
								  AND		SR_ObjectType = 'SERVER'
								  AND		SR_Permission <> 'CONNECT SQL'
						  ) D ON A.SR_Security = D.SR_Security
WHERE		A.SR_SecurityType IN ('WINDOWS_LOGIN', 'SQL_LOGIN')
  AND		A.SR_Security NOT IN ('sa', 'NT AUTHORITY\SYSTEM', 'NT AUTHORITY\NETWORK SERVICE')
  AND		A.SR_Security NOT LIKE '##%'
  AND		A.SR_ObjectType = 'SERVER'
  AND		A.SR_Permission = 'CONNECT SQL'
  AND		B.SR_Security IS NULL
  AND		C.SR_Security IS NULL
  AND		D.SR_Security IS NULL
ORDER BY	A.SR_Security

-- LINKED SERVER INFO
SELECT		*
FROM		#SecurityReport
WHERE		SR_ObjectType = 'LINK_SERVER'
ORDER BY	SR_Security	
		,SR_Object
*/




