DECLARE @DropSynonym NVARCHAR(4000)
	,@CreateSynonym NVARCHAR(4000)
	,@Permissions NVARCHAR(4000);

SELECT @DropSynonym = ''
	,@CreateSynonym = ''
	,@Permissions = '';

SELECT @DropSynonym = @DropSynonym + 'DROP SYNONYM ' + QUOTENAME(SCHEMA_NAME(SCHEMA_ID)) + '.' + QUOTENAME(NAME) + ';
'
	,@CreateSynonym = @CreateSynonym + 'CREATE SYNONYM ' + QUOTENAME(SCHEMA_NAME(SCHEMA_ID)) + '.' + QUOTENAME(NAME) + ' FOR ' + REPLACE(base_object_name, '[OldDB]', '[NewDB]') + ';
'
FROM sys.synonyms;

SELECT @DropSynonym
	,@CreateSynonym;

WITH PermQuery
AS (
	SELECT CASE 
			WHEN PERM.STATE <> 'W'
				THEN PERM.state_desc
			ELSE 'GRANT'
			END COLLATE database_default AS PermissionState
		,PERM.permission_name COLLATE database_default AS Permission
		,SCHEMA_NAME(obj.schema_id) AS SchemaName
		,obj.NAME AS ObjectName
		,CASE 
			WHEN cl.column_id IS NULL
				THEN SPACE(0)
			ELSE '(' + QUOTENAME(cl.NAME) + ')'
			END AS ColumnName
		,CASE 
			WHEN PERM.STATE <> 'W'
				THEN 'N'
			ELSE 'Y'
			END AS WithOption
		,usr.NAME AS UserName
	FROM sys.synonyms AS s
	INNER JOIN sys.all_objects AS obj ON s.object_id = obj.object_id
	INNER JOIN sys.database_permissions AS PERM ON PERM.major_id = obj.object_id
	INNER JOIN sys.database_principals AS usr ON PERM.grantee_principal_id = usr.principal_id
	LEFT JOIN sys.columns AS cl ON cl.column_id = PERM.minor_id
		AND cl.object_id = PERM.major_id
	)
SELECT @Permissions = @Permissions + PermissionState + ' ' + Permission + ' ON ' + QUOTENAME(SchemaName) + '.' + QUOTENAME(ObjectName) + ' ' + ColumnName + ' TO ' + UserName + CASE WithOption
		WHEN 'Y'
			THEN ' WITH GRANT OPTION'
		ELSE ''
		END + ';
'
FROM PermQuery;

PRINT @DropSynonym;
--EXEC(@DropSynonym)
PRINT @CreateSynonym;
--EXEC(@CreateSynonym)
PRINT @Permissions;
	--EXEC (@Permissions)  
