/* This script prints out DDL for all permissions assigned to a named principle
*/
SET NOCOUNT ON 
--SELECT 'PrincipleName=' + $(PrincipleName)
declare	@principle_name sysname
select @principle_name = $(PrincipleName)

if (@Principle_Name IS NULL or LTRIM(RTRIM(@Principle_Name)) = '')
BEGIN
	PRINT '*******************************************'
	PRINT 'Principle Name is NULL!!!!'
	PRINT '*******************************************'
END

SELECT	'--This script was generated using \Src\SQL\CreateDDLForAssigningPermissionsPerPrinciple.sql' AS [--stmt];;
SELECT	'PRINT ''Assigning permissions to principle ' + @principle_name + ' on database [' + DB_NAME() + ']''' AS [--stmt];

--CONNECT perms
SELECT	'' AS [--stmt];
SELECT	'--CONNECT permissions' AS [--stmt];
select	CASE WHEN perm.state = 'G' THEN 'GRANT ' ELSE 'DENY ' END + 'CONNECT ON [' + DB_NAME() + '] TO [' + princ.name + '];' AS [--stmt]
from	sys.database_permissions perm
inner	join sys.database_principals princ
on		perm.grantee_principal_id = princ.principal_id
where	perm.permission_name = 'CONNECT'
and		princ.name = @principle_name

--DB Permissions
--Replaced statements below with this query - mostly for expediency
--Adds the ability to get permissions granted on schemas.
SELECT '' as [--stmt];
SELECT '---DB Permissions' as [--stmt];

SELECT state_desc + ' ' + permission_name + ' on ['+ ss.name + '].[' + so.name + '] to [' + sdpr.name + '];' COLLATE LATIN1_General_CI_AS as [--stmt]
FROM SYS.DATABASE_PERMISSIONS AS sdp
JOIN sys.objects AS so
     ON sdp.major_id = so.OBJECT_ID
JOIN SYS.SCHEMAS AS ss
     ON so.SCHEMA_ID = ss.SCHEMA_ID
JOIN SYS.DATABASE_PRINCIPALS AS sdpr
     ON sdp.grantee_principal_id = sdpr.principal_id
WHERE sdpr.name = @Principle_Name

UNION

SELECT state_desc + ' ' + permission_name + ' on Schema::['+ ss.name + '] to [' + sdpr.name + '];' COLLATE LATIN1_General_CI_AS as [--stmt]
FROM SYS.DATABASE_PERMISSIONS AS sdp
JOIN SYS.SCHEMAS AS ss
     ON sdp.major_id = ss.SCHEMA_ID
     AND sdp.class_desc = 'Schema'
JOIN SYS.DATABASE_PRINCIPALS AS sdpr
     ON sdp.grantee_principal_id = sdpr.principal_id
WHERE sdpr.name = @Principle_Name
order by [--stmt];


/*
--EXECUTE perms
SELECT	'' AS [--stmt];
SELECT	'--EXECUTE permissions' AS [--stmt];
select	CASE WHEN perm.state = 'G' THEN 'GRANT ' ELSE 'DENY ' END + 'EXECUTE ON [' + OBJECT_SCHEMA_NAME(o.object_id) + '].[' + o.name + '] TO [' + princ.name + '];'  AS [--stmt]
from	sys.database_permissions perm
inner	join sys.database_principals princ
on		perm.grantee_principal_id = princ.principal_id
inner	join sys.objects o 
on		perm.major_id = o.object_id
where	princ.name = @principle_name
and		perm.permission_name = 'EXECUTE'
order	by o.name asc	


--SELECT perms
SELECT	'' AS [--stmt];
SELECT	'--SELECT permissions' AS [--stmt];
select	CASE WHEN perm.state = 'G' THEN 'GRANT ' ELSE 'DENY ' END + 'SELECT ON [' + OBJECT_SCHEMA_NAME(o.object_id) + '].[' + o.name + '] TO [' + princ.name + '];'  AS [--stmt]
from	sys.database_permissions perm
inner	join sys.database_principals princ
on		perm.grantee_principal_id = princ.principal_id
inner	join sys.objects o 
on		perm.major_id = o.object_id
where	princ.name = @principle_name
and		perm.permission_name = 'SELECT'
order	by o.name asc

--UPDATE perms
SELECT	'' AS [--stmt];
SELECT	'--UPDATE permissions' AS [--stmt];
select	CASE WHEN perm.state = 'G' THEN 'GRANT ' ELSE 'DENY ' END + 'UPDATE ON [' + OBJECT_SCHEMA_NAME(o.object_id) + '].[' + o.name + '] TO [' + princ.name + '];'  AS [--stmt]
from	sys.database_permissions perm
inner	join sys.database_principals princ
on		perm.grantee_principal_id = princ.principal_id
inner	join sys.objects o 
on		perm.major_id = o.object_id
where	princ.name = @principle_name
and		perm.permission_name = 'UPDATE'
order	by o.name asc

--INSERT perms
SELECT	'' AS [--stmt];
SELECT	'--INSERT permissions' AS [--stmt];
select	CASE WHEN perm.state = 'G' THEN 'GRANT ' ELSE 'DENY ' END + 'INSERT ON [' + OBJECT_SCHEMA_NAME(o.object_id) + '].[' + o.name + '] TO [' + princ.name + '];'  AS [--stmt]
from	sys.database_permissions perm
inner	join sys.database_principals princ
on		perm.grantee_principal_id = princ.principal_id
inner	join sys.objects o 
on		perm.major_id = o.object_id
where	princ.name = @principle_name
and		perm.permission_name = 'INSERT'
order	by o.name asc

--DELETE perms
SELECT	'' AS [--stmt];
SELECT	'--DELETE permissions' AS [--stmt];
select	CASE WHEN perm.state = 'G' THEN 'GRANT ' ELSE 'DENY ' END + 'DELETE ON [' + OBJECT_SCHEMA_NAME(o.object_id) + '].[' + o.name + '] TO [' + princ.name + '];'  AS [--stmt]
from	sys.database_permissions perm
inner	join sys.database_principals princ
on		perm.grantee_principal_id = princ.principal_id
inner	join sys.objects o 
on		perm.major_id = o.object_id
where	princ.name = @principle_name
and		perm.permission_name = 'DELETE'
order	by o.name asc
*/