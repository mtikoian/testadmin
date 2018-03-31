/*
Execute in SSMS and set results to text (CTRL-T)
*/
SET NOCOUNT ON
SELECT	'EXEC sp_addrolemember N''' + rp.name + ''', N''' + mp.name + ''';' AS [Stmt]
FROM	sys.database_role_members rm
INNER	JOIN sys.database_principals rp
ON		rm.role_principal_id = rp.principal_id
INNER	JOIN sys.database_principals mp
ON		rm.member_principal_id = mp.principal_id
WHERE	mp.name NOT IN ('dbo')
ORDER	BY rp.name
                