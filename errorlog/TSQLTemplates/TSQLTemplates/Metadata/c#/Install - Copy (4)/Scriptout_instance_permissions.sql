/*
This script will script the role members for all roles on the database.

This is useful for scripting permissions in a development environment before refreshing
	development with a copy of production.  This will allow us to easily ensure
	development permissions are not lost during a prod to dev restoration. 

URL for this script: http://www.sqlservercentral.com/scripts/Security/71562/  -- Periodically, updates are made to this script so check out the URL for updates.
	
Author: S. Kusen

Updates:

2015-08-21:
			1. Modified section 3.1 to load to a temp table and populate different users based on an error in 2005/2008 because of the update made for contained databases.  Thanks to Andrew G for pointing that out.
			2. Altered section 4.1 to include COLLATE DATABASE_DEFAULT in the join statement.  Thanks to Andrew G and PHXHoward for pointing that out.


2015-06-30: 
			1. Re-numbered all sections based on additional updates being added inline.
			2. Added sections 8, 8.1; From Eddict, user defined types needed to be added.
			3. Added sections 4, 4.1; From nhaberl, for orphaned users mapping (if logins don't exist, they will not be created by this script).
			4. Updated section 3.1; From nhaberl, updated to include a default schema of dbo. 

2014-07-25: Fix pointed out by virgo for where logins are mapped to users that are a different name.  Changed ***+ ' FOR LOGIN ' + QUOTENAME([name]) +*** to ***+ ' FOR LOGIN ' + QUOTENAME(suser_sname([sid])) +***.

2014-01-24: Updated to account for 2012 contained db users

2012-05-14: Incorporated a fix pointed out by aruopna for Schema-level permissions.

2010-01-20:	Turned statements into a cursor and then using print statements to make it easier to 
		copy/paste into a query window.
		Added support for schema level permissions


Thanks to wsoranno@winona.edu and choffman for the recommendations.

*/
/*Prep statements*/
DECLARE @DbName VARCHAR(128)

CREATE TABLE ##tbl_db_principals_statements (
	stmt VARCHAR(max)
	,result_order DECIMAL(4, 1)
	)

SET NOCOUNT ON

DECLARE CURSOR_DB CURSOR FAST_FORWARD
FOR
SELECT NAME
FROM sys.databases
WHERE STATE = 0 -- ONLINE
ORDER BY NAME

OPEN CURSOR_DB

FETCH NEXT
FROM CURSOR_DB
INTO @DbName

WHILE @@FETCH_STATUS = 0
BEGIN
	IF (
			(
				SELECT SUBSTRING(convert(SYSNAME, SERVERPROPERTY('productversion')), 1, charindex('.', convert(SYSNAME, SERVERPROPERTY('productversion'))) - 1)
				) > 10
			)
		EXEC (
				'
INSERT INTO ##tbl_db_principals_statements (stmt, result_order)
	SELECT	
		CASE WHEN rm.authentication_type IN (2, 0) /* 2=contained database user with password, 0 =user without login; create users without logins*/ THEN (''IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] = '' + SPACE(1) + '''''''' + [name] + '''''''' + '') BEGIN CREATE USER '' + SPACE(1) + QUOTENAME([name]) + '' WITHOUT LOGIN WITH DEFAULT_SCHEMA = '' + QUOTENAME([default_schema_name]) + SPACE(1) + '', SID = '' + CONVERT(varchar(1000), sid) + SPACE(1) + '' END; '')
			ELSE (''IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] = '' + SPACE(1) + '''''''' + [name] + '''''''' + '') BEGIN CREATE USER '' + SPACE(1) + QUOTENAME([name]) + '' FOR LOGIN '' + QUOTENAME(suser_sname([sid])) + '' WITH DEFAULT_SCHEMA = '' + QUOTENAME(ISNULL([default_schema_name], ''dbo'')) + SPACE(1) + ''END; '') 
			END AS [-- SQL STATEMENTS --],
			3.1 AS [-- RESULT ORDER HOLDER --]
	FROM	sys.database_principals AS rm
	WHERE [type] IN (''U'', ''S'', ''G'') /* windows users, sql users, windows groups */'
				)
	ELSE IF (
			(
				SELECT SUBSTRING(convert(SYSNAME, SERVERPROPERTY('productversion')), 1, charindex('.', convert(SYSNAME, SERVERPROPERTY('productversion'))) - 1)
				) IN (
				9
				,10
				)
			)
		EXEC (
				'
INSERT INTO ##tbl_db_principals_statements (stmt, result_order)
	SELECT	(''IF NOT EXISTS (SELECT [name] FROM sys.database_principals WHERE [name] = '' + SPACE(1) + '''''''' + [name] + '''''''' + '') BEGIN CREATE USER '' + SPACE(1) + QUOTENAME([name]) + '' FOR LOGIN '' + QUOTENAME(suser_sname([sid])) + '' WITH DEFAULT_SCHEMA = '' + QUOTENAME(ISNULL([default_schema_name], ''dbo'')) + SPACE(1) + ''END; '') AS [-- SQL STATEMENTS --],
			3.1 AS [-- RESULT ORDER HOLDER --]
	FROM	sys.database_principals AS rm
	WHERE [type] IN (''U'', ''S'', ''G'') /* windows users, sql users, windows groups */'
				)

	--SELECT * FROM ##tbl_db_principals_statements
	DECLARE @sql VARCHAR(2048)
		,@sort INT

	DECLARE tmp CURSOR
	FOR
	/*********************************************/
	/*********   DB CONTEXT STATEMENT    *********/
	/*********************************************/
	SELECT '-- [-- DB CONTEXT --] --' AS [-- SQL STATEMENTS --]
		,1 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT 'USE' + SPACE(1) + QUOTENAME(DB_NAME()) AS [-- SQL STATEMENTS --]
		,1.1 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT '' AS [-- SQL STATEMENTS --]
		,2 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	/*********************************************/
	/*********     DB USER CREATION      *********/
	/*********************************************/
	SELECT '-- [-- DB USERS --] --' AS [-- SQL STATEMENTS --]
		,3 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT [stmt]
		,3.1 AS [-- RESULT ORDER HOLDER --]
	FROM ##tbl_db_principals_statements
	--WHERE [type] IN ('U', 'S', 'G') -- windows users, sql users, windows groups
	WHERE [stmt] IS NOT NULL
	
	UNION
	
	/*********************************************/
	/*********    MAP ORPHANED USERS     *********/
	/*********************************************/
	SELECT '-- [-- ORPHANED USERS --] --' AS [-- SQL STATEMENTS --]
		,4 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT 'ALTER USER [' + rm.NAME + '] WITH LOGIN = [' + rm.NAME + ']'
		,4.1 AS [-- RESULT ORDER HOLDER --]
	FROM sys.database_principals AS rm
	INNER JOIN sys.server_principals AS sp ON rm.NAME = sp.NAME COLLATE DATABASE_DEFAULT
		AND rm.sid <> sp.sid
	WHERE rm.[type] IN (
			'U'
			,'S'
			,'G'
			) -- windows users, sql users, windows groups
		AND rm.NAME NOT IN (
			'dbo'
			,'guest'
			,'INFORMATION_SCHEMA'
			,'sys'
			,'MS_DataCollectorInternalUser'
			)
	
	UNION
	
	/*********************************************/
	/*********    DB ROLE PERMISSIONS    *********/
	/*********************************************/
	SELECT '-- [-- DB ROLES --] --' AS [-- SQL STATEMENTS --]
		,5 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT 'EXEC sp_addrolemember @rolename =' + SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername =' + SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '''') AS [-- SQL STATEMENTS --]
		,5.1 AS [-- RESULT ORDER HOLDER --]
	FROM sys.database_role_members AS rm
	WHERE USER_NAME(rm.member_principal_id) IN (
			--get user names on the database
			SELECT [name]
			FROM sys.database_principals
			WHERE [principal_id] > 4 -- 0 to 4 are system users/schemas
				AND [type] IN (
					'G'
					,'S'
					,'U'
					) -- S = SQL user, U = Windows user, G = Windows group
			)
	--ORDER BY rm.role_principal_id ASC
	
	UNION
	
	SELECT '' AS [-- SQL STATEMENTS --]
		,7 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	/*********************************************/
	/*********  OBJECT LEVEL PERMISSIONS *********/
	/*********************************************/
	SELECT '-- [-- OBJECT LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --]
		,7.1 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT CASE 
			WHEN PERM.STATE <> 'W'
				THEN PERM.state_desc
			ELSE 'GRANT'
			END + SPACE(1) + PERM.permission_name + SPACE(1) + 'ON ' + QUOTENAME(SCHEMA_NAME(obj.schema_id)) + '.' + QUOTENAME(obj.NAME) --select, execute, etc on specific objects
		+ CASE 
			WHEN cl.column_id IS NULL
				THEN SPACE(0)
			ELSE '(' + QUOTENAME(cl.NAME) + ')'
			END + SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default + CASE 
			WHEN PERM.STATE <> 'W'
				THEN SPACE(0)
			ELSE SPACE(1) + 'WITH GRANT OPTION'
			END AS [-- SQL STATEMENTS --]
		,7.2 AS [-- RESULT ORDER HOLDER --]
	FROM sys.database_permissions AS PERM
	INNER JOIN sys.objects AS obj ON PERM.major_id = obj.[object_id]
	INNER JOIN sys.database_principals AS usr ON PERM.grantee_principal_id = usr.principal_id
	LEFT JOIN sys.columns AS cl ON cl.column_id = PERM.minor_id
		AND cl.[object_id] = PERM.major_id
	--WHERE	usr.name = @OldUser
	--ORDER BY perm.permission_name ASC, perm.state_desc ASC
	
	UNION
	
	/*********************************************/
	/*********  TYPE LEVEL PERMISSIONS *********/
	/*********************************************/
	SELECT '-- [-- TYPE LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --]
		,8 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT CASE 
			WHEN PERM.STATE <> 'W'
				THEN PERM.state_desc
			ELSE 'GRANT'
			END + SPACE(1) + PERM.permission_name + SPACE(1) + 'ON ' + QUOTENAME(SCHEMA_NAME(tp.schema_id)) + '.' + QUOTENAME(tp.NAME) --select, execute, etc on specific objects
		+ SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(USER_NAME(usr.principal_id)) COLLATE database_default + CASE 
			WHEN PERM.STATE <> 'W'
				THEN SPACE(0)
			ELSE SPACE(1) + 'WITH GRANT OPTION'
			END AS [-- SQL STATEMENTS --]
		,8.1 AS [-- RESULT ORDER HOLDER --]
	FROM sys.database_permissions AS PERM
	INNER JOIN sys.types AS tp ON PERM.major_id = tp.user_type_id
	INNER JOIN sys.database_principals AS usr ON PERM.grantee_principal_id = usr.principal_id
	
	UNION
	
	SELECT '' AS [-- SQL STATEMENTS --]
		,9 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	/*********************************************/
	/*********    DB LEVEL PERMISSIONS   *********/
	/*********************************************/
	SELECT '-- [--DB LEVEL PERMISSIONS --] --' AS [-- SQL STATEMENTS --]
		,10 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT CASE 
			WHEN PERM.STATE <> 'W'
				THEN PERM.state_desc --W=Grant With Grant Option
			ELSE 'GRANT'
			END + SPACE(1) + PERM.permission_name --CONNECT, etc
		+ SPACE(1) + 'TO' + SPACE(1) + '[' + USER_NAME(usr.principal_id) + ']' COLLATE database_default --TO <user name>
		+ CASE 
			WHEN PERM.STATE <> 'W'
				THEN SPACE(0)
			ELSE SPACE(1) + 'WITH GRANT OPTION'
			END AS [-- SQL STATEMENTS --]
		,10.1 AS [-- RESULT ORDER HOLDER --]
	FROM sys.database_permissions AS PERM
	INNER JOIN sys.database_principals AS usr ON PERM.grantee_principal_id = usr.principal_id
	--WHERE	usr.name = @OldUser
	WHERE [perm].[major_id] = 0
		AND [usr].[principal_id] > 4 -- 0 to 4 are system users/schemas
		AND [usr].[type] IN (
			'G'
			,'S'
			,'U'
			) -- S = SQL user, U = Windows user, G = Windows group
	
	UNION
	
	SELECT '' AS [-- SQL STATEMENTS --]
		,11 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT '-- [--DB LEVEL SCHEMA PERMISSIONS --] --' AS [-- SQL STATEMENTS --]
		,12 AS [-- RESULT ORDER HOLDER --]
	
	UNION
	
	SELECT CASE 
			WHEN PERM.STATE <> 'W'
				THEN PERM.state_desc --W=Grant With Grant Option
			ELSE 'GRANT'
			END + SPACE(1) + PERM.permission_name --CONNECT, etc
		+ SPACE(1) + 'ON' + SPACE(1) + class_desc + '::' COLLATE database_default --TO <user name>
		+ QUOTENAME(SCHEMA_NAME(major_id)) + SPACE(1) + 'TO' + SPACE(1) + QUOTENAME(USER_NAME(grantee_principal_id)) COLLATE database_default + CASE 
			WHEN PERM.STATE <> 'W'
				THEN SPACE(0)
			ELSE SPACE(1) + 'WITH GRANT OPTION'
			END AS [-- SQL STATEMENTS --]
		,12.1 AS [-- RESULT ORDER HOLDER --]
	FROM sys.database_permissions AS PERM
	INNER JOIN sys.schemas s ON PERM.major_id = s.schema_id
	INNER JOIN sys.database_principals dbprin ON PERM.grantee_principal_id = dbprin.principal_id
	WHERE class = 3 --class 3 = schema
	ORDER BY [-- RESULT ORDER HOLDER --]

	OPEN tmp

	FETCH NEXT
	FROM tmp
	INTO @sql
		,@sort

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @sql

		FETCH NEXT
		FROM tmp
		INTO @sql
			,@sort
	END

	CLOSE tmp

	DEALLOCATE tmp

	FETCH NEXT
	FROM CURSOR_DB
	INTO @DbName
END

CLOSE CURSOR_DB

DEALLOCATE CURSOR_DB

DROP TABLE ##tbl_db_principals_statements
