SELECT	Name
FROM	sys.database_principals dp
WHERE	dp.type IN ('R') --SQL Roles
and		dp.name not in ('public','dbo','guest','sys','INFORMATION_SCHEMA')
and		dp.is_fixed_role <> 1
ORDER BY name
