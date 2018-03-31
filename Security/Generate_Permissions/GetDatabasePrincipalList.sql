SELECT	ISNULL(suser_sname(dp.sid),N'') AS [Login],*
FROM	sys.database_principals dp
WHERE	dp.type IN ('S','U','G') --SQL users, windows users and windows groups for now
and		dp.name not in ('public','dbo','guest','sys','INFORMATION_SCHEMA')
and		dp.is_fixed_role <> 1
