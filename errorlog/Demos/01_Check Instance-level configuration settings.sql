-- Check Instance-level configuration settings


-- Get server name and SQL Server version information
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];


-- Get socket, physical core and logical core count from the SQL Server Error log
EXEC sys.xp_readerrorlog 0, 1, N'detected', N'socket';


-- Get selected instance-level configuration values for instance  
SELECT [name], [value], value_in_use, [description]
FROM sys.configurations
WHERE name IN (N'automatic soft-NUMA disabled', N'backup checksum default', N'backup compression default',
               N'clr enabled', N'cost threshold for parallelism', N'max degree of parallelism',
			   N'max server memory (MB)', N'optimize for ad hoc workloads', N'remote admin connections') 
ORDER BY [name];


-- Returns a list of all global trace flags that are enabled 
DBCC TRACESTATUS (-1);


-- Get number of data files in tempdb database 
EXEC sys.xp_readerrorlog 0, 1, N'The tempdb database has';


-- Returns status of instant file initialization 
EXEC sys.xp_readerrorlog 0, 1, N'Database Instant File Initialization';


-- Hardware information from SQL Server 2016  
SELECT cpu_count AS [Logical CPU Count], physical_memory_kb/1024 AS [Physical Memory (MB)], 
softnuma_configuration_desc AS [Soft NUMA Configuration], sql_memory_model_desc 
FROM sys.dm_os_sys_info;


-- Get processor description from Windows Registry 
EXEC sys.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 
N'ProcessorNameString';



-- Change some instance-level settings ******************************************************
EXEC sys.sp_configure 'show advanced options', 1;  
GO
RECONFIGURE WITH OVERRIDE;


-- Enable backup checksum default
EXEC sys.sp_configure 'backup checksum default', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

-- Enable backup compression default
EXEC sys.sp_configure 'backup compression default', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

-- Enable the CLR
EXEC sys.sp_configure 'clr enabled', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO


-- Change cost threshold for parallelism to a higher value
EXEC sys.sp_configure 'cost threshold for parallelism', 25;
GO
RECONFIGURE WITH OVERRIDE;
GO

-- Set max degree of parallelism to 4
EXEC sys.sp_configure 'max degree of parallelism', 4;
GO
RECONFIGURE WITH OVERRIDE;
GO

-- Set max server memory to 19456 (19GB)
EXEC sys.sp_configure 'max server memory (MB)', 19456;
GO
RECONFIGURE WITH OVERRIDE;
GO


-- Enable optimize for ad hoc workloads
EXEC sys.sp_configure 'optimize for ad hoc workloads', 1;
RECONFIGURE WITH OVERRIDE;
GO


-- Get selected instance-level configuration values for instance  
SELECT [name], [value], value_in_use, [description]
FROM sys.configurations
WHERE name IN (N'automatic soft-NUMA disabled', N'backup checksum default', N'backup compression default',
               N'clr enabled', N'cost threshold for parallelism', N'max degree of parallelism',
			   N'max server memory (MB)', N'optimize for ad hoc workloads', N'remote admin connections') 
ORDER BY [name];