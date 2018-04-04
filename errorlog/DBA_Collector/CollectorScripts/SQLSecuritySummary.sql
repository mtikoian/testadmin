DECLARE @SQL				varchar(4000)
		,@PwdDaysThreshold	smallint
        ,@Id                int
        ,@DbName            varchar(128)
        ,@CmptLevel         varchar(10)
        ,@Total             int

SET NOCOUNT ON

SET @PwdDaysThreshold = 60

IF OBJECT_ID('tempdb..#SecurityReport') IS NOT NULL
    DROP TABLE #SecurityReport

IF OBJECT_ID('tempdb..#Info') IS NOT NULL
    DROP TABLE #Info

IF OBJECT_ID('tempdb..#DatabaseList') IS NOT NULL
    DROP TABLE #DatabaseList
    
CREATE TABLE #SecurityReport
(
		SR_Security			varchar(256)
		,SR_SecurityType	varchar(256)
		,SR_Database		varchar(256)
		,SR_Class			varchar(256)
		,SR_Object			varchar(256)
		,SR_ObjectType		varchar(256)
		,SR_Column			varchar(256)
		,SR_Permission		varchar(256)
		,SR_State			varchar(60)
)

CREATE TABLE #Info
(
	SID			uniqueidentifier
	,Account	varchar(256)
)

CREATE TABLE #DatabaseList
(
    Id          int IDENTITY(1,1)
    ,Name       varchar(128)
    ,CmptLevel  varchar(10)
)

INSERT INTO #DatabaseList
(
            Name
            ,CmptLevel
)            
SELECT      name 
            ,compatibility_level
FROM        sys.databases
WHERE       state = 0 -- ONLINE
ORDER BY    name  

INSERT INTO #Info
EXECUTE master.dbo.sp_validatelogins

/* MEMBER OF ANY SERVER ROLES */
INSERT INTO #SecurityReport
SELECT		S.name							AS [Security]
			,S.type_desc					AS [SecurityType]
			,'_N/A'							AS [Database]
			,'SERVER'						AS [Class]
			,R.name							AS [Object]
			,'SERVER_ROLE'						AS [ObjectType]
			,NULL							AS [Column]
			,'MEMBER'						AS [Permission]
			,NULL							AS [State]
FROM		sys.server_principals				S 
				JOIN sys.server_role_members	M 	ON S.principal_id		= M.member_principal_id
				JOIN sys.server_principals		R 	ON M.role_principal_id	= R.principal_id

/* PERMISSIONS ON A SERVER */
INSERT INTO #SecurityReport
SELECT		S.name							AS [Security]
			,S.type_desc					AS [SecurityType]
			,'_N/A'							AS [Database]
			,P.class_desc					AS [Class]
			,CASE WHEN P.class_desc = 'Endpoint'
				THEN E.protocol_desc
				ELSE 'SERVER'
			 END							AS [Object]
			,'SERVER'						AS [ObjectType]
			,NULL							AS [Column]		
			,P.permission_name				AS [Permission]
			,P.state_desc					AS [State]
FROM		sys.server_principals			S 
				JOIN sys.server_permissions P 	ON S.principal_id	= P.grantee_principal_id
				LEFT JOIN sys.endpoints		E 	ON P.major_id		= E.endpoint_id
															AND P.class_desc = 'Endpoint'

/* LINK SERVERS */
INSERT INTO #SecurityReport
SELECT		SP.name
			,type_desc
			,'_N/A'
			,'SERVER'
			,S.name
			,'LINK_SERVER'
			,NULL
			,'LOGIN'
			,NULL
FROM		master.sys.linked_logins				LS  
				JOIN master.sys.servers				S  	ON LS.server_id				= S.server_id
				JOIN master.sys.server_principals	SP  	ON LS.local_principal_id	= SP.principal_id
WHERE		S.server_id <> 0

INSERT INTO #SecurityReport
SELECT		DISTINCT CASE 
				WHEN LD.uses_self_credential IS NULL THEN 'Not Be Made'
				WHEN LD.uses_self_credential = 0 AND LD.remote_name IS NULL THEN 'Be made without using a security context'
				WHEN LD.uses_self_credential = 1 AND LD.remote_name IS NULL THEN 'Be made using the login''s current security context'
				ELSE 'Be made using this security context:  ' + LD.remote_name
			END
			,'LOGIN_NOT_DEFINE'
			,'_N/A'
			,'SERVER'
			,S.name
			,'LINK_SERVER'
			,NULL
			,'LOGIN'
			,NULL
FROM		master.sys.servers							S	
				JOIN master.sys.linked_logins			LS   ON S.server_id = LS.server_id
				LEFT JOIN master.sys.server_principals	P	 ON LS.local_principal_id = P.principal_id
				LEFT JOIN (
								SELECT		server_id
											,uses_self_credential
											,remote_name
								FROM		master.sys.linked_logins  
								WHERE		local_principal_id = 0
						   ) LD ON S.server_id = LD.server_id
WHERE		S.server_id <> 0

/* PASSWORD EXPIRE */
INSERT INTO #SecurityReport
SELECT		S.name							AS [Security]
			,S.type_desc					AS [SecurityType]
			,'_N/A'							AS [Database]
			,'SERVER'						AS [Class]
			,'EXPIRE'						AS [Object]
			,'LOGIN_PROPERTY'				AS [ObjectType]
			,CAST(LOGINPROPERTY(name, 'IsExpired') AS varchar(50))	AS [Column]
			,'IS_EXPIRED'					AS [Permission]
			,DATEDIFF(d, CAST(LOGINPROPERTY(name, 'PasswordLastSetTime') AS datetime), GETDATE())	AS [State]
FROM		sys.server_principals S
WHERE		LOGINPROPERTY(name, 'IsExpired') = 1
   OR		DATEDIFF(d, CAST(LOGINPROPERTY(name, 'PasswordLastSetTime') AS datetime), GETDATE()) >= @PwdDaysThreshold 

/* ACCOUNT LOCKED */
INSERT INTO #SecurityReport
SELECT		S.name							AS [Security]
			,S.type_desc					AS [SecurityType]
			,'_N/A'							AS [Database]
			,'SERVER'						AS [Class]
			,'LOCKED'						AS [Object]
			,'LOGIN_PROPERTY'				AS [ObjectType]
			,NULL							AS [Column]
			,'IS_LOCKED'					AS [Permission]
			,DATEDIFF(d, CAST(LOGINPROPERTY(name, 'LockoutTime') AS datetime), GETDATE())	AS [State]
FROM		sys.server_principals S
WHERE		LOGINPROPERTY(name, 'IsLocked') = 1

/* ACCOUNT DISABLED */
INSERT INTO #SecurityReport
SELECT		S.name							AS [Security]
			,S.type_desc					AS [SecurityType]
			,'_N/A'							AS [Database]
			,'SERVER'						AS [Class]
			,'DISABLE'						AS [Object]
			,'LOGIN_PROPERTY'				AS [ObjectType]
			,NULL							AS [Column]
			,'IS_DISABLED'					AS [Permission]
			,NULL							AS [State]
FROM		sys.server_principals S
WHERE		is_disabled = 1

/* INVALID DOMAIN ACCOUNT */
INSERT INTO #SecurityReport
SELECT		S.name							AS [Security]
			,S.type_desc					AS [SecurityType]
			,'_N/A'							AS [Database]
			,'SERVER'						AS [Class]
			,'INVALID_DOMAIN_ACCT'			AS [Object]
			,'LOGIN_PROPERTY'				AS [ObjectType]
			,NULL							AS [Column]
			,NULL							AS [Permission]
			,NULL							AS [State]
FROM		#Info I
				JOIN sys.server_principals S ON I.Account = S.name

/* DATABASE OWNER */
INSERT INTO #SecurityReport
SELECT		ISNULL(S.name, 'UNKNOWN')
			,ISNULL(S.type_desc, 'UNKNOWN')
			,D.name
			,'DATABASE'
			,'DATABASE'
			,'DATABASE'
			,NULL
			,'OWNER'
			,NULL
FROM		sys.databases						D 
				LEFT JOIN sys.server_principals	S 	ON D.owner_sid = S.sid

/* SQL JOB OWNERS */
INSERT INTO #SecurityReport
SELECT		ISNULL(S.name, 'UNKNOWN')
			,ISNULL(S.type_desc, 'UNKNOWN')
			,'_N/A'
			,'SERVER'
			,J.name
			,'SQL_JOB'
			,NULL
			,'OWNER'
			,NULL
FROM		msdb.dbo.sysjobs					J 
				LEFT JOIN sys.server_principals	S  ON J.owner_sid = S.sid

SELECT @Total = COUNT(*) FROM #DatabaseList

SET @Id = 1

WHILE (@Id <= @Total)
BEGIN
    SELECT      @Id = ISNULL(Id, 0)
                ,@DbName = Name
                ,@CmptLevel = CmptLevel
    FROM        #DatabaseList
    WHERE       Id = @Id

    /* ANY DATABASE USER ACCOUNT BEING ALIAS */
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

    /* MEMBER OF ANY DATABASE ROLES */
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		CAST(S.name AS varchar(128))'
    SET @SQL = @SQL + '             ,S.type_desc  '
    SET @SQL = @SQL + '             ,''' + @DbName + '''  '
    SET @SQL = @SQL + '             ,''DATABASE'' '
    SET @SQL = @SQL + '				,R.name	 '
    SET @SQL = @SQL + '             ,''DATABASE_ROLE'' '
    SET @SQL = @SQL + '				,NULL  '		
    SET @SQL = @SQL + '				,''MEMBER'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + 'FROM			sys.server_principals				S  '
    SET @SQL = @SQL + '					JOIN sys.database_principals	U 	ON S.sid				= U.sid '
    SET @SQL = @SQL + '					JOIN sys.database_role_members	M 	ON U.principal_id		= M.member_principal_id '
    SET @SQL = @SQL + '					JOIN sys.database_principals	R 	ON M.role_principal_id	= R.principal_id '

    -- GET GUEST ACCOUNT INFO IF APPLIABLE
    SET @SQL = @SQL + 'UNION ALL '
    SET @SQL = @SQL + 'SELECT		U.name COLLATE database_default '
    --SET @SQL = @SQL + 'SELECT		CAST(U.name AS varchar(128)) '
    SET @SQL = @SQL + '             ,U.type_desc  '
    SET @SQL = @SQL + '             ,''' + @DbName + '''  '
    SET @SQL = @SQL + '             ,''DATABASE'' '
    SET @SQL = @SQL + '				,R.name	 '
    SET @SQL = @SQL + '             ,''DATABASE_ROLE'' '
    SET @SQL = @SQL + '				,NULL  '		
    SET @SQL = @SQL + '				,''MEMBER'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + 'FROM			sys.database_principals				U '
    SET @SQL = @SQL + '                 JOIN (SELECT grantee_principal_id FROM sys.database_principals JOIN sys.database_permissions ON principal_id = grantee_principal_id WHERE name = ''guest'' AND state = ''G'' AND permission_name = ''CONNECT'') G ON U.principal_id = G.grantee_principal_id '
    SET @SQL = @SQL + '					JOIN sys.database_role_members	M 	ON U.principal_id		= M.member_principal_id '
    SET @SQL = @SQL + '					JOIN sys.database_principals	R 	ON M.role_principal_id	= R.principal_id '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

/* PERMISSIONS ON A DATABASE LEVEL */
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		CAST(S.name AS varchar(128)) '
    SET @SQL = @SQL + '             ,S.type_desc  '
    SET @SQL = @SQL + '				,''' + @DbName + ''' '
    SET @SQL = @SQL + '             ,P.class_desc '
    SET @SQL = @SQL + '				,CASE WHEN P.class IN (1, 8) '
    SET @SQL = @SQL + '					THEN ISNULL(QUOTENAME(SCHEMA_NAME(O.schema_id)) + ''.'' + QUOTENAME(O.name), ''DATABASE'') '
    SET @SQL = @SQL + '					ELSE ''DATABASE'' '
    SET @SQL = @SQL + '				 END	'
    SET @SQL = @SQL + '				,ISNULL(O.type_desc, ''DATABASE'') ' 
    SET @SQL = @SQL + '				,CASE WHEN class = 1 '
    SET @SQL = @SQL + '					THEN C.name '
    SET @SQL = @SQL + '					ELSE NULL '
    SET @SQL = @SQL + '				 END	'		
    SET @SQL = @SQL + '				,P.permission_name '
    SET @SQL = @SQL + '				,P.state_desc '
    SET @SQL = @SQL + 'FROM			sys.server_principals				S  '
    SET @SQL = @SQL + '					JOIN sys.database_principals	U 	ON S.sid				= U.sid '
    SET @SQL = @SQL + '					JOIN sys.database_permissions	P 	ON U.principal_id		= P.grantee_principal_id '
    SET @SQL = @SQL + '					LEFT JOIN sys.all_objects		O 	ON P.major_id			= O.object_id '
    SET @SQL = @SQL + '					LEFT JOIN sys.all_columns		C 	ON P.major_id			= C.object_id '
    SET @SQL = @SQL + '													               AND P.minor_id			= C.column_id '

    -- GET GUEST ACCOUNT INFO IF APPLIABLE
    SET @SQL = @SQL + 'UNION ALL '
    SET @SQL = @SQL + 'SELECT		U.name COLLATE database_default '
    -- SET @SQL = @SQL + 'SELECT		CAST(U.name AS varchar(128)) '
    SET @SQL = @SQL + '             ,U.type_desc  '
    SET @SQL = @SQL + '				,''' + @DbName + ''' '
    SET @SQL = @SQL + '             ,P.class_desc '
    SET @SQL = @SQL + '				,CASE WHEN P.class IN (1, 8) '
    SET @SQL = @SQL + '					THEN ISNULL(QUOTENAME(SCHEMA_NAME(O.schema_id)) + ''.'' + QUOTENAME(O.name), ''DATABASE'') '
    SET @SQL = @SQL + '					ELSE ''DATABASE'' '
    SET @SQL = @SQL + '				 END	'
    SET @SQL = @SQL + '				,ISNULL(O.type_desc, ''DATABASE'') ' 
    SET @SQL = @SQL + '				,CASE WHEN class = 1 '
    SET @SQL = @SQL + '					THEN C.name '
    SET @SQL = @SQL + '					ELSE NULL '
    SET @SQL = @SQL + '				 END	'		
    SET @SQL = @SQL + '				,P.permission_name '
    SET @SQL = @SQL + '				,P.state_desc '
    SET @SQL = @SQL + 'FROM			sys.database_principals				U '
    SET @SQL = @SQL + '					JOIN sys.database_permissions	P 	ON U.principal_id		= P.grantee_principal_id '
    SET @SQL = @SQL + '                 JOIN (SELECT grantee_principal_id FROM sys.database_principals JOIN sys.database_permissions ON principal_id = grantee_principal_id WHERE name = ''guest'' AND state = ''G'' AND permission_name = ''CONNECT'') G ON U.principal_id = G.grantee_principal_id '
    SET @SQL = @SQL + '					LEFT JOIN sys.all_objects		O 	ON P.major_id			= O.object_id '
    SET @SQL = @SQL + '					LEFT JOIN sys.all_columns		C 	ON P.major_id			= C.object_id '
    SET @SQL = @SQL + '													   AND P.minor_id			= C.column_id '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    /* DEFAULT SCHEMA DATABASE */
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		CAST(S.name AS varchar(128)) '
    SET @SQL = @SQL + '             ,S.type_desc  '
    SET @SQL = @SQL + '				,''' + @DbName + ''' '
    SET @SQL = @SQL + '				,''DATABASE'' '
    SET @SQL = @SQL + '				,U.default_schema_name '
    SET @SQL = @SQL + '				,''SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + '				,''DEFAULT SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + 'FROM			sys.server_principals				S  '
    SET @SQL = @SQL + '					JOIN sys.database_principals	U 	ON S.sid				= U.sid '

    -- GET GUEST ACCOUNT INFO IF APPLIABLE
    SET @SQL = @SQL + 'UNION ALL '
    SET @SQL = @SQL + 'SELECT		U.name COLLATE database_default '
    --SET @SQL = @SQL + 'SELECT		CAST(U.name AS varchar(128)) '
    SET @SQL = @SQL + '             ,U.type_desc  '
    SET @SQL = @SQL + '				,''' + @DbName + ''' '
    SET @SQL = @SQL + '				,''DATABASE'' '
    SET @SQL = @SQL + '				,U.default_schema_name '
    SET @SQL = @SQL + '				,''SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + '				,''DEFAULT SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + 'FROM			sys.database_principals				U '
    SET @SQL = @SQL + '                 JOIN (SELECT grantee_principal_id FROM sys.database_principals JOIN sys.database_permissions ON principal_id = grantee_principal_id WHERE name = ''guest'' AND state = ''G'' AND permission_name = ''CONNECT'') G ON U.principal_id = G.grantee_principal_id '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    /* SCHEMA OWNER IN DATABASE */
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT		S.name '
    SET @SQL = @SQL + '             ,S.type_desc  '
    SET @SQL = @SQL + '				,''' + @DbName + ''' '
    SET @SQL = @SQL + '				,''DATABASE'' '
    SET @SQL = @SQL + '				,O.name '
    SET @SQL = @SQL + '				,''SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + '				,''OWNS SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + 'FROM			sys.server_principals				S  '
    SET @SQL = @SQL + '					JOIN sys.database_principals	U 	ON S.sid				= U.sid '
    SET @SQL = @SQL + '					JOIN sys.schemas				O 	ON U.principal_id		= O.principal_id '

    -- GET GUEST ACCOUNT INFO IF APPLIABLE
    SET @SQL = @SQL + 'UNION ALL '
    SET @SQL = @SQL + 'SELECT		U.name COLLATE database_default '
    --SET @SQL = @SQL + 'SELECT		U.name '
    SET @SQL = @SQL + '             ,U.type_desc  '
    SET @SQL = @SQL + '				,''' + @DbName + ''' '
    SET @SQL = @SQL + '				,''DATABASE'' '
    SET @SQL = @SQL + '				,O.name '
    SET @SQL = @SQL + '				,''SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + '				,''OWNS SCHEMA'' '
    SET @SQL = @SQL + '				,NULL '
    SET @SQL = @SQL + 'FROM			sys.database_principals	U '
    SET @SQL = @SQL + '                 JOIN (SELECT grantee_principal_id FROM sys.database_principals JOIN sys.database_permissions ON principal_id = grantee_principal_id WHERE name = ''guest'' AND state = ''G'' AND permission_name = ''CONNECT'') G ON U.principal_id = G.grantee_principal_id '
    SET @SQL = @SQL + '					JOIN sys.schemas	O 	ON U.principal_id		= O.principal_id '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    /* ANY ROLE MEMBER OF ANY DATABASE ROLES */
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT           D.name '
    SET @SQL = @SQL + '                 ,D.type_desc '
    SET @SQL = @SQL + '                 ,''' + @DbName + ''' '
    SET @SQL = @SQL + '                 ,''DATABASE'' '
    SET @SQL = @SQL + '                 ,R.name '
    SET @SQL = @SQL + '                 ,R.type_desc '
    SET @SQL = @SQL + '                 ,NULL '
    SET @SQL = @SQL + '                 ,''MEMBER'' '
    SET @SQL = @SQL + '                 ,NULL '
    SET @SQL = @SQL + 'FROM		        sys.database_principals				D  '
    SET @SQL = @SQL + '                     JOIN sys.database_role_members	M 	ON D.principal_id		= M.member_principal_id '
    SET @SQL = @SQL + '                     JOIN sys.database_principals	R 	ON M.role_principal_id	= R.principal_id  '
    SET @SQL = @SQL + 'WHERE		D.type = ''R'' '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    /* ROLE PERMISSIONS ON A DATABASE LEVEL */
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT           D.name '
    SET @SQL = @SQL + '                 ,D.type_desc '
    SET @SQL = @SQL + '                 ,''' + @DbName + ''' '
    SET @SQL = @SQL + '                 ,''DATABASE'' '
    SET @SQL = @SQL + '				    ,P.class_desc '
    SET @SQL = @SQL + '				    ,''DATABASE'' ' 
    SET @SQL = @SQL + '				    ,NULL '		
    SET @SQL = @SQL + '                 ,P.permission_name '
    SET @SQL = @SQL + '                 ,P.state_desc '
    SET @SQL = @SQL + 'FROM		        sys.database_principals				D  '
    SET @SQL = @SQL + '                     JOIN sys.database_permissions	P  ON D.principal_id	= P.grantee_principal_id '
    SET @SQL = @SQL + 'WHERE		    D.type = ''R'' '
    SET @SQL = @SQL + '  AND		    P.class NOT IN (1, 8) '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)

    /* ROLE PERMISSIONS ON OBJECT LEVEL */
    SET @SQL = 'USE ' + QUOTENAME(@DbName) + '; '
    SET @SQL = @SQL + 'SELECT           D.name '
    SET @SQL = @SQL + '                 ,D.type_desc '
    SET @SQL = @SQL + '                 ,''' + @DbName + ''' '
    SET @SQL = @SQL + '                 ,P.class_desc '
    SET @SQL = @SQL + '				    ,QUOTENAME(SCHEMA_NAME(O.schema_id)) + ''.'' + QUOTENAME(O.name) '
    SET @SQL = @SQL + '				    ,O.type_desc ' 
    SET @SQL = @SQL + '				    ,CASE WHEN class = 1 '
    SET @SQL = @SQL + '					     THEN C.name '
    SET @SQL = @SQL + '					     ELSE NULL '
    SET @SQL = @SQL + '				     END '		
    SET @SQL = @SQL + '                 ,P.permission_name '
    SET @SQL = @SQL + '                 ,P.state_desc '
    SET @SQL = @SQL + 'FROM		        sys.database_principals				D  '
    SET @SQL = @SQL + '                     JOIN sys.database_permissions	P  ON D.principal_id	= P.grantee_principal_id '
    SET @SQL = @SQL + '					    JOIN sys.all_objects			O  ON P.major_id			= O.object_id '
    SET @SQL = @SQL + '					    LEFT JOIN sys.all_columns		C  ON P.major_id		= C.object_id '
    SET @SQL = @SQL + '														               AND P.minor_id		= C.column_id '
    SET @SQL = @SQL + 'WHERE		    D.type = ''R'' '
    SET @SQL = @SQL + '  AND		    P.class IN (1, 8) '

    INSERT INTO #SecurityReport
    EXECUTE (@SQL)
    
    SET @Id = @Id + 1        
END

SELECT		ISNULL(SR_Security, 'NULL') + '<1>' +
				ISNULL(SR_SecurityType, 'NULL') + '<2>' +
				ISNULL(SR_Database, 'NULL') + '<3>' +
				ISNULL(SR_Class, 'NULL') + '<4>' +
				ISNULL(SR_Object, 'NULL') + '<5>' +
				ISNULL(SR_ObjectType, 'NULL') + '<6>' +
				ISNULL(SR_Column, 'NULL') + '<7>' +
				ISNULL(SR_Permission, 'NULL') + '<8>' +
				ISNULL(SR_State , 'NULL')
FROM		#SecurityReport
ORDER BY	SR_Database
			,SR_Security

DROP TABLE #SecurityReport
DROP TABLE #Info
DROP TABLE #DatabaseList
