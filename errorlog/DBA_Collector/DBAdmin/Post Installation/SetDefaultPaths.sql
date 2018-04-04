/****************************************************************************************
 Name: SetDefaultPaths.sql
 Author: Josh Feierman 6/1/2011
 Purpose: Sets the default log, data, and backup directories for SQL Server. Most useful in 
					SQL 2005 where these settings are not available within the setup program at a 
					granular level.
 Instructions: Use the SSMS template parameter function to enter in the paths for the default data, 
							 log, and backup directories.
********************************************************************************************/

DECLARE @BackupPath NVARCHAR(256),
				@DataPath NVARCHAR(256),
				@LogPath NVARCHAR(256);

SELECT	@BackupPath = '<Backup Path,SYSNAME,>',
				@DataPath = '<Data Path,SYSNAME,>',
				@LogPath = '<Log Path,SYSNAME,>';

DECLARE @RegValues TABLE ([Value] NVARCHAR(256), [Data] NVARCHAR(256));

INSERT	@RegValues
EXEC		master..xp_instance_regread 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\','DefaultData'

INSERT	@RegValues
EXEC		master..xp_instance_regread 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\','DefaultLog'

INSERT	@RegValues
EXEC		master..xp_instance_regread 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\','BackupDirectory'

SELECT	'Old Value',
				[Value],
				[Data]
FROM		@RegValues;

exec xp_instance_regwrite 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\','DefaultData','REG_SZ',@DataPath;
exec xp_instance_regwrite 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\','DefaultLog','REG_SZ',@LogPath;
exec xp_instance_regwrite 'HKEY_LOCAL_MACHINE','SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\','BackupDirectory','REG_SZ',@BackupPath;
