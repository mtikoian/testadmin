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