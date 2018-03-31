USE [master];

SET NOCOUNT ON;

--Enter a valid Domain account, local account, or SQL Login.  NOTE:  An entire Windows group cannot be impersonated.
DECLARE @LoginToImpersonate [nvarchar](128);

SET @LoginToImpersonate = 'OMC-CND4223440\SS654';


BEGIN TRY;

	DECLARE
		@dbName [nvarchar] (128),
		@strSQL [nvarchar] (MAX);


	--First, ensure user indicated above can actually be impersonated and reverted without error
	SET @strSQL = ''
	SET @strSQL = 'USE [master]; EXECUTE AS LOGIN = ' + QUOTENAME(@LoginToImpersonate, '''') + '; REVERT;';

	EXEC sp_executesql @strSQL;

	--Store all permission-related data for later analysis
	CREATE TABLE ##dbPermit
		(
		[Metric] [varchar](50) NOT NULL,
		[DatabaseName] [nvarchar](128) NOT NULL,
		[LoginSID] [varbinary](85) NULL,
		[LoginName] [nvarchar](128) NULL,
		[DBUserSID] [varbinary](85) NULL,
		[DBUserName] [nvarchar](128) NULL,
		[LoginType] [nvarchar](60) NULL,
		[Disabled?] [bit] NULL,
		[LoginCreateDate] [datetime] NULL,
		[PermissionName] [nvarchar](500) NULL
		);

	--Interrogate each db on instance for role-based and object-level permissions in one pass (gathered by original connection security context)
	DECLARE cAllDatabases CURSOR FAST_FORWARD LOCAL
	  FOR SELECT sdb.[name] FROM sys.databases AS sdb WHERE sdb.state_desc = 'ONLINE'
		OPEN cAllDatabases
		FETCH cAllDatabases INTO @dbName
		  WHILE @@FETCH_STATUS = 0
		BEGIN
		  SET @strSQL = N'INSERT INTO ##dbPermit
			SELECT
				''----------DATABASE ROLE'' AS [Metric],
				''' + @dbName + ''' AS [DatabaseName],
				sp.[sid] AS [LoginSID],
				sp.[name] AS [LoginName],
				dbp.[sid] AS [DBUserSID],
				dbp.[name] AS [DBUserName],
				sp.[type_desc] AS [LoginType],
				sp.[is_disabled] AS [Disabled?],
				sp.[create_date] AS [LoginCreateDate],
				r.[role_name] AS [PermissionName]
			FROM ' + QUOTENAME(@dbName) + '.sys.database_principals AS dbp
				LEFT JOIN sys.server_principals AS sp ON sp.[sid] = dbp.[sid] 
				LEFT JOIN ' + QUOTENAME(@dbName) + '.sys.database_role_members rm ON rm.member_principal_id = dbp.principal_id
				--This inline view is our list of Database and Application Roles by Name
				INNER JOIN (
							SELECT r.[principal_id], r.[name] AS role_name
							FROM ' + QUOTENAME(@dbName) + '.sys.database_principals r
							WHERE r.[type] IN(''A'',''R'')
							) r ON r.[principal_id] = rm.[role_principal_id]'
					
			EXEC sp_executesql @strSQL;

					
		  SET @strSQL = N'INSERT INTO ##dbPermit
			SELECT
				''---------------OBJECT-LEVEL PERMISSION'' AS [Metric],
				''' + @dbName + ''' AS [DatabaseName],
				sp.[sid] AS [LoginSID],
				sp.[name] AS [LoginName],
				grantee_principal.[sid] AS [DBUserSID],
				grantee_principal.[name] AS [DBUserName],
				sp.[type_desc] AS [LoginType],
				sp.[is_disabled] AS [Disabled?],
				sp.[create_date] AS [LoginCreateDate],
				dbperm.state_desc COLLATE Latin1_General_CI_AS + '' '' +
				dbperm.[permission_name] COLLATE Latin1_General_CI_AS + '' ON '' +
					CASE dbperm.class_desc
						WHEN ''DATABASE'' THEN dbperm.[class_desc]
						WHEN ''SCHEMA'' THEN ''SCHEMA '' + QUOTENAME(sch_objects.[name])
						WHEN ''OBJECT_OR_COLUMN'' THEN QUOTENAME(sch_objects2.[name]) + ''.'' + QUOTENAME(o.[name])
					ELSE dbperm.class_desc + '' (ID:'' + CAST(dbperm.[major_id] AS [nvarchar](38)) + '')''
						END AS [PermissionName]
			FROM ' + QUOTENAME(@dbName) + '.sys.database_permissions AS dbperm
				LEFT JOIN ' + QUOTENAME(@dbName) + '.sys.all_objects AS o ON o.[object_id] = dbperm.major_id
				LEFT JOIN ' + QUOTENAME(@dbName) + '.sys.database_principals AS grantee_principal ON grantee_principal.principal_id = dbperm.grantee_principal_id
				LEFT JOIN sys.server_principals AS sp ON sp.[sid] = grantee_principal.[sid]
				LEFT JOIN (
							SELECT r.[name] AS role_name
							FROM ' + QUOTENAME(@dbName) + '.sys.database_principals r
							WHERE
								r.[type] IN(''A'',''R'')
								OR r.[principal_id] < 5
							) as rolenames on rolenames.[role_name] = grantee_principal.[name]
				LEFT JOIN ' + QUOTENAME(@dbName) + '.sys.schemas AS sch_objects ON sch_objects.[schema_id] = dbperm.[major_id]
				LEFT JOIN ' + QUOTENAME(@dbName) + '.sys.schemas AS sch_objects2 ON sch_objects2.[schema_id] = o.[schema_id]
			WHERE
				--Exclude Database/Application/System roles as named users
				rolenames.[role_name] IS NULL'
					
			EXEC sp_executesql @strSQL;

					
		  SET @strSQL = N'INSERT INTO ##dbPermit
			SELECT
				''----------DATABASE ROLE'' AS [Metric],
				''' + @dbName + ''' AS [DatabaseName],
				sp.[sid] AS [LoginSID],
				sp.[name] AS [LoginName],
				sdb.[owner_sid] AS [DBUserSID],
				dbp.[name] AS [DBUserName],
				sp.[type_desc] AS [LoginType],
				sp.[is_disabled] AS [Disabled?],
				sp.[create_date] AS [LoginCreateDate],
				''Explicit Database Owner (Properties Page)'' AS [PermissionName]
			FROM sys.[databases] AS sdb
				LEFT JOIN sys.[server_principals] AS sp ON sp.[sid] = sdb.[owner_sid]
				LEFT JOIN ' + QUOTENAME(@dbName) + '.sys.[database_principals] AS dbp ON dbp.[sid] = sdb.[owner_sid]
			WHERE sdb.[name] = ''' + @dbName + ''';
 			'
			
			EXEC sp_executesql @strSQL;
		FETCH cAllDatabases INTO @dbName
		END
	CLOSE cAllDatabases
	DEALLOCATE cAllDatabases;


	INSERT INTO ##dbPermit
	--Server role assignments
	SELECT
	  'SERVER ROLE' AS [Metric],
	  '<All>' AS [DatabaseName],
	  sp.[sid] AS [LoginSID],
	  sp.[name] AS [LoginName],
	  NULL AS [DBUserSID],
	  '--' AS [DBUserName],
	  sp.[type_desc] COLLATE database_default AS [LoginType],
	  sp.[is_disabled] AS [Disabled?],
	  sp.[create_date] AS [LoginCreateDate],
	  srvroles.[name] AS [PermissionName]
	FROM sys.server_role_members AS members
	  INNER JOIN sys.server_principals AS sp ON sp.principal_id = members.member_principal_id
	  INNER JOIN (
					SELECT r.[name], r.[principal_id]
					FROM sys.server_principals AS r
					WHERE r.[type] = 'R'
				  ) AS srvroles ON srvroles.principal_id = members.role_principal_id;



	INSERT INTO ##dbPermit
	--Specific server permission grants
	SELECT DISTINCT
	  '-----SERVER PERMISSION' AS [Metric],
	  '<All>' AS [DatabaseName],
	  sp.[sid] AS [LoginSID],
	  sp.[name] AS [LoginName],
	  NULL AS [DBUserSID],
	  '--' AS [DBUserName],
	  sp.[type_desc] COLLATE database_default AS [LoginType],
	  sp.[is_disabled] AS [Disabled?],
	  sp.[create_date] AS [LoginCreateDate],
	  srvperm.[state_desc] + ' ' + srvperm.[permission_name] AS [PermissionName]
	FROM sys.server_permissions AS srvperm
	  INNER JOIN sys.server_principals AS sp ON sp.principal_id = srvperm.[grantee_principal_id];


	--Tie in security data gathered with impersonated token; use additional temp table as we will REVERT and then perform a final query to make this more readable.
	CREATE TABLE ##dbPermitToken
		(
		[Metric] [varchar](50) NOT NULL,
		[DatabaseName] [nvarchar](128) NOT NULL,
		[LoginSID] [varbinary](85) NULL,
		[LoginName] [nvarchar](128) NULL,
		[DBUserSID] [varbinary](85) NULL,
		[DBUserName] [nvarchar](128) NULL,
		[LoginType] [nvarchar](60) NULL,
		[Disabled?] [bit] NULL,
		[LoginCreateDate] [datetime] NULL,
		[PermissionName] [nvarchar](500) NULL
		);

	--Re-initialize variable
	SET @strSQL = ''
	SET @strSQL = 'USE [master]; EXECUTE AS LOGIN = ' + QUOTENAME(@LoginToImpersonate, '''') + ';';

	SET @strSQL = @strSQL + 'INSERT INTO ##dbPermitToken
							 SELECT DISTINCT
								p.[Metric],
								p.[DatabaseName],
								p.[LoginSID],
								ISNULL(p.[LoginName], SUSER_SNAME(p.[DBUserSID]) + '' (without server login)'') AS [LoginName],
								--p.[LoginName],
								p.[DBUserSID],
								p.[DBUserName],
								p.[LoginType],
								p.[Disabled?],
								p.[LoginCreateDate],
								p.[PermissionName]
							 FROM ##dbPermit AS p
							 WHERE EXISTS(SELECT *
										  FROM sys.login_token AS tn
										  WHERE
											tn.[sid] = p.[LoginSID]
											OR tn.[sid] = p.[DBUserSID]
											OR SUSER_SNAME(p.[DBUserSID]) = ' + QUOTENAME(@LoginToImpersonate, '''') + '
										  );
								   REVERT;';

	EXEC sp_executesql @strSQL;



	--Use CROSS APPLY to concatenate rows together
	SELECT
		@LoginToImpersonate AS [LoginImpersonated],
		p1.[DatabaseName],
		p1.[Metric],
		--p1.[LoginSID],
		ISNULL(p1.[LoginName], SUSER_SNAME(p1.[DBUserSID]) + ' (without server login)') AS [LoginName],
		p1.[DBUserName],
		p1.[LoginType],
		p1.[Disabled?],
		p1.[LoginCreateDate],
  		CASE WHEN LEN(concat_rows.PermissionsList) = 0 THEN ''
			ELSE LEFT(concat_rows.PermissionsList, LEN(concat_rows.PermissionsList) - 1) END AS PermissionsList
	FROM (
			--Define what columns intersect the values being concatenated
			SELECT DISTINCT
			  p1.[Metric],
			  p1.[DatabaseName],
			  p1.[LoginSID],
			  p1.[LoginName],
			  p1.[DBUserSID],
			  p1.[DBUserName],
			  p1.[LoginType],
			  p1.[Disabled?],
			  p1.[LoginCreateDate]
			FROM ##dbPermitToken AS p1
		  ) AS p1
	CROSS APPLY (
				--Generate list of concatenated values
				SELECT DISTINCT p2.[PermissionName] + ', '
				FROM ##dbPermitToken AS p2
				--"Join" line to insersecting values
				WHERE p2.[Metric] = p1.[Metric]
					  AND p2.[DatabaseName] = p1.[DatabaseName]
					  --AND p2.[LoginSID] = p1.[LoginSID]
					  AND p2.[LoginName] = p1.[LoginName]

				FOR XML PATH('')
			) concat_rows(PermissionsList)
	ORDER BY [DatabaseName] ASC, [Metric] DESC, [LoginName] ASC;

	DROP TABLE ##dbPermit;
	DROP TABLE ##dbPermitToken;

END TRY
BEGIN CATCH

	DECLARE @ErrMsg nvarchar(1024)
	SET @ErrMsg = ERROR_MESSAGE()

		IF EXISTS (SELECT * FROM sys.[server_principals] AS sp WHERE SUSER_SNAME(sp.[sid]) = @LoginToImpersonate AND sp.[type_desc] = 'WINDOWS_GROUP')
		  BEGIN
			RAISERROR('You cannot impersonate a Windows group.  Please enter an individual Windows login.', 16, 1);
		  END
		ELSE
		  BEGIN
			RAISERROR('%s', 16, 1, @ErrMsg);
		  END

		IF EXISTS(SELECT * FROM tempdb.sys.objects WHERE name  = '##dbPermit')
			DROP TABLE ##dbPermit;
		IF EXISTS(SELECT * FROM tempdb.sys.objects WHERE name  = '##dbPermitToken')
			DROP TABLE ##dbPermitToken;

END CATCH;
GO