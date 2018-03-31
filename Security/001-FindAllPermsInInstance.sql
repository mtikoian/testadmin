USE [master];

SET NOCOUNT ON;

/*
	If "All" is used for a database name, then Server-Level roles and permissions are displayed
	along with every other permission inside each user database.  On the other hand, if a database
	is specified the security matrix is displayed relative to that one particular database.  MJM
*/
	
DECLARE
	@dbName_search nvarchar(128) = N'All',     --N'All'

	--Search for **Login** Name, not necessarily database user name (optional)
	@Login_search nvarchar(128) = N'All',

	--Only include permissions tied to a login?  1 = YES, 0 = NO
	@IncludeLoginsOnly bit = 0;


IF NOT EXISTS(SELECT * FROM sys.[databases] AS d WHERE d.[name] = @dbName_search OR @dbName_search = 'All')
  BEGIN
	RAISERROR('Database ''%s'' does not exist on this instance.', 16, 1, @dbName_search);
	RETURN
  END



BEGIN TRY;

	DECLARE
		@dbName [nvarchar] (128),
		@strSQL [nvarchar] (MAX);


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
				CASE WHEN dbp.[name] = r.[role_name] THEN ''Role Owner'' ELSE r.[role_name] END AS [PermissionName]
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
				ISNULL(
						sp.[type_desc],
						CASE WHEN rolenames.[role_name] IS NOT NULL AND grantee_principal.[name] NOT IN(''guest'') THEN ''DB_ROLE'' END
					   ) AS [LoginType],
				sp.[is_disabled] AS [Disabled?],
				sp.[create_date] AS [LoginCreateDate],
				dbperm.state_desc COLLATE Latin1_General_CI_AS + '' '' +
				dbperm.[permission_name] COLLATE Latin1_General_CI_AS + '' ON '' +
					CASE dbperm.class_desc
						WHEN ''DATABASE'' THEN dbperm.[class_desc]
						WHEN ''SCHEMA'' THEN ''SCHEMA ::'' + QUOTENAME(sch_objects.[name])
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
				--Exclude "public" role
				grantee_principal.[name] NOT IN(''public'')'
					
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



	--Combined result set; use CTE in order to provide cleaned-up order set after additional columns added.  MJM
	;WITH cte_permissions_all
	AS (
		SELECT DISTINCT
		  p.[Metric],
		  p.[DatabaseName],
		  --p.[LoginSID],
		  ISNULL(p.[LoginName], '') AS [LoginName],
		  --p.[DBUserSID],
		  p.[DBUserName],
		  p.[LoginType],
		  CASE WHEN p.[LoginType] = 'DB_ROLE' THEN 0 ELSE 99 END AS [LoginTypeSortkey],
		  --p.[Disabled?],
		  --p.[LoginCreateDate],
		  p.[PermissionName] AS [PermissionName],
		  'USE ' + QUOTENAME(CASE WHEN p.[DatabaseName] = '<All>' THEN 'master' ELSE p.[DatabaseName] END) + '; '+
			CASE
			  WHEN p.[Metric] LIKE '%OBJECT-LEVEL PERMISSION' THEN
					CASE WHEN p.[LoginType] = 'DB_ROLE' THEN 'IF NOT EXISTS(SELECT * FROM sys.database_principals AS dbp WHERE dbp.[name] = ''' + p.[DBUserName] + ''' AND dbp.[type] = ''R'') CREATE ROLE ' + QUOTENAME(p.[DBUserName]) + '; ' + REPLACE(p.[PermissionName], 'ON DATABASE', '') + ' TO ' + QUOTENAME(p.[DBUserName]) + ';'
					ELSE 'IF NOT EXISTS(SELECT * FROM sys.database_principals AS dbp WHERE dbp.[name] = ''' + p.[DBUserName] + ''') CREATE USER ' + QUOTENAME(p.[DBUserName]) + ' FOR LOGIN ' + QUOTENAME(p.[LoginName]) + '; ' + p.[PermissionName] + ' TO ' + QUOTENAME(p.[DBUserName]) + ';'
					END
			  WHEN p.[Metric] LIKE '%DATABASE ROLE' THEN 'IF NOT EXISTS(SELECT * FROM sys.database_principals AS dbp WHERE dbp.[name] = ''' + p.[DBUserName] + ''') CREATE USER ' + QUOTENAME(p.[DBUserName]) + ' FOR LOGIN ' + QUOTENAME(p.[LoginName]) + '; EXEC ' + 'sp_addrolemember ' + QUOTENAME(p.[PermissionName], '''') + ', ' + QUOTENAME(p.[DBUserName], '''') + ';'
			  WHEN p.[Metric] LIKE '%SERVER PERMISSION' THEN p.[PermissionName] + ' TO ' + QUOTENAME(p.[LoginName]) + ';'
			  WHEN p.[Metric] LIKE '%SERVER ROLE' THEN 'EXEC ' + 'sp_addsrvrolemember ' + QUOTENAME(p.[LoginName], '''') + ', ' + QUOTENAME(p.[PermissionName], '''') + ';'
			END AS [PermissionSQL]
		FROM ##dbPermit AS p
		WHERE
		  (
				p.[DatabaseName] = @dbName_search
				OR @dbName_search = N'All'
		  )
		  AND (
				p.[LoginName] = @Login_search
				OR (
					  p.DBUserName = @Login_search
					  AND @IncludeLoginsOnly = 0
					)
				OR @Login_search = N'All'
			  )
		  AND (
				(
					p.[LoginName] NOT IN('sa', 'public')
					AND p.[LoginName] NOT LIKE 'NT AUTHORITY\%'
					AND p.[LoginName] NOT LIKE 'NT SERVICE\%'
					AND p.[LoginName] NOT LIKE '##MS_%'
					AND p.[Disabled?] = 0
				 )
				 OR p.[LoginType] = 'DB_ROLE'
				 OR (
						p.[LoginName] IS NULL	--Named database user for AD Group that doesn't exist as a login
						AND @IncludeLoginsOnly = 0
					)
			  )
			AND p.[PermissionName] NOT IN('GRANT CONNECT SQL', 'GRANT CONNECT ON DATABASE')
		 )

	SELECT
		[Metric],
		[DatabaseName],
		[LoginName],
		[DBUserName],
		[LoginType],
		[PermissionName],
		[PermissionSQL]
	FROM [cte_permissions_all]
	ORDER BY [DatabaseName] ASC, [LoginTypeSortkey] ASC, [DBUserName] ASC, [Metric] DESC;

	DROP TABLE ##dbPermit;

END TRY
BEGIN CATCH

	IF EXISTS(SELECT * FROM tempdb.sys.objects WHERE name  = '##dbPermit')
		DROP TABLE ##dbPermit;
	
	DECLARE @ErrMsg nvarchar(1024)
	SET @ErrMsg = ERROR_MESSAGE()
	
	RAISERROR('%s', 16, 1, @ErrMsg);

END CATCH;
GO