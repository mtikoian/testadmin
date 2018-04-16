SET NOCOUNT ON;
go
use master
go
select 
'if exists(select 1 from sys.database_principals where type_desc = ''DATABASE_ROLE'' and [name] = ''db_executor'')
	print ''db_executor role already exists in '' + db_name()
else
	print ''CREATE ROLE [db_executor] AUTHORIZATION [dbo]''
	CREATE ROLE [db_executor] AUTHORIZATION [dbo]
GO
CREATE LOGIN [SampleCompany\' + [name] + '_DBO] FROM WINDOWS WITH DEFAULT_DATABASE=[tempdb]
GO
USE [' + [name] + ']
GO
CREATE USER [SampleCompany\' + [name] + '_DBO] FOR LOGIN [SampleCompany\' + [name] + '_DBO]
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_datareader'', N''SampleCompany\' + [name] + '_DBO''
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_datawriter'', N''SampleCompany\' + [name] + '_DBO''
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_executor'', N''SampleCompany\' + [name] + '_DBO''
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_owner'', N''SampleCompany\' + [name] + '_DBO''
GO
USE [master]
GO
CREATE LOGIN [SampleCompany\' + [name] + '_RWX] FROM WINDOWS WITH DEFAULT_DATABASE=[tempdb]
GO
USE [' + [name] + ']
GO
CREATE USER [SampleCompany\' + [name] + '_RWX] FOR LOGIN [SampleCompany\' + [name] + '_RWX]
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_datareader'', N''SampleCompany\' + [name] + '_RWX''
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_datawriter'', N''SampleCompany\' + [name] + '_RWX''
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_executor'', N''SampleCompany\' + [name] + '_RWX''
GO
USE [master]
GO
CREATE LOGIN [SampleCompany\' + [name] + '_RW] FROM WINDOWS WITH DEFAULT_DATABASE=[tempdb]
GO
USE [' + [name] + ']
GO
CREATE USER [SampleCompany\' + [name] + '_RW] FOR LOGIN [SampleCompany\' + [name] + '_RW]
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_datareader'', N''SampleCompany\' + [name] + '_RW''
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_datawriter'', N''SampleCompany\' + [name] + '_RW''
GO
USE [master]
GO
CREATE LOGIN [SampleCompany\' + [name] + '_RO] FROM WINDOWS WITH DEFAULT_DATABASE=[tempdb]
GO
USE [' + [name] + ']
GO
CREATE USER [SampleCompany\' + [name] + '_RO] FOR LOGIN [SampleCompany\' + [name] + '_RO]
GO
USE [' + [name] + ']
GO
EXEC sp_addrolemember N''db_datareader'', N''SampleCompany\' + [name] + '_RO''
GO'
from sysdatabases
where not exists (select 1 from sys.server_principals where [name] like 'SampleCompany\' + sysdatabases.[name] + '_RO')
and name not in ('master','model','tempdb','msdb','litespeedlocal','distribution','ReportServer','ReportserverTempDB');

