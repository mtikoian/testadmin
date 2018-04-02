--******************************************************************************
-- Gather Configuration Information 
--******************************************************************************
SET NOCOUNT ON;
CREATE TABLE #Configuration
	( name varchar(50)
	, [Description] varchar(100)
	, [Default] int
	, Bad_Default int
	, value int
	, value_in_use int
	, minimum int
	, maximum int
	, Comment varchar(120)
	);

INSERT INTO #Configuration
SELECT 
	  name, [description]
	, 0 --default placeholder
	, NULL --bad_default placeholder
	, CAST(value as int)
	, CAST(value_in_use as int)
	, CAST(minimum as int)
	, CAST(maximum as int)
	, NULL
FROM sys.configurations WITH (NOLOCK)


UPDATE #Configuration SET Bad_Default = 0
	WHERE [Name] IN ('backup compression default','min server memory (MB)', 'optimize for ad hoc workloads', 'priority boost','Agent XPs'); 
UPDATE #Configuration SET Bad_Default = 1
	WHERE [Name] IN ('clr enabled', 'lightweight pooling', 'max degree of parallelism', 'priority boost');
UPDATE #Configuration SET [Default] = 1
	WHERE [Name] IN ('default trace enabled','nested triggers','remote access','server trigger recursion','SMO and DMO XPs')
UPDATE #Configuration SET [Default] = 4 WHERE [Name] = 'max full-text crawl range';
UPDATE #Configuration SET [Default] = 65536 WHERE [Name] ='max text repl size (B)';
UPDATE #Configuration SET [Default] = 1024 WHERE [Name] ='min memory per query (KB)';
UPDATE #Configuration SET [Default] = 4096 WHERE [Name] ='network packet size (B)';
UPDATE #Configuration SET [Default] = 60 WHERE [Name] ='PH timeout (s)';
UPDATE #Configuration SET [Default] = 10 WHERE [Name] ='remote login timeout (s)';
UPDATE #Configuration SET [Default] = 600 WHERE [Name] ='remote query timeout (s)';
UPDATE #Configuration SET [Default] = 2049 WHERE [Name] ='two digit year cutoff';
UPDATE #Configuration SET [Default] = 100 WHERE [Name] IN ('ft crawl bandwidth (max)','ft notify bandwidth (max)');
UPDATE #Configuration SET [Default] = -1 WHERE [Name] IN('cursor threshold','query wait (s)');
UPDATE #Configuration SET [Default] = 1033 WHERE [Name] ='default full-text language'
UPDATE #Configuration SET [Default] = 5, Bad_Default = 5 WHERE [Name] = 'cost threshold for parallelism';
UPDATE #Configuration SET [Default] = 2147483647, Bad_Default = 2147483647  WHERE [Name] = 'max server memory (MB)';

UPDATE #Configuration SET [Comment] = 'set to 1 when SQL Agent is enabled' WHERE [Name] = 'Agent XPs'
UPDATE #Configuration SET [Comment] = 'should be 1 in most cases' WHERE [Name] = 'backup compression default'
UPDATE #Configuration SET [Comment] = 'only enable if it is needed' WHERE [Name] = 'clr enabled';
UPDATE #Configuration SET [Comment] = 'depends on your workload' WHERE [Name] = 'cost threshold for parallelism';
UPDATE #Configuration SET [Comment] = 'should be zero' WHERE [Name] = 'lightweight pooling';
UPDATE #Configuration SET [Comment] = 'depends on your workload' WHERE [Name] = 'max degree of parallelism';
UPDATE #Configuration SET [Comment] = 'set to an appropriate value, not the default' WHERE [Name] = 'max server memory (MB)';
UPDATE #Configuration SET [Comment] = 'set to an appropriate value, not the default' WHERE [Name] = 'min server memory (MB)';
UPDATE #Configuration SET [Comment] = 'should be 1 in almost all cases' WHERE [Name] = 'optimize for ad hoc workloads';
UPDATE #Configuration SET [Comment] = 'should be zero' WHERE [Name] = 'priority boost';
UPDATE #Configuration SET [Comment] = 'investigate: http://www.sqlsoldier.com/wp/sqlserver/networkpacketsizetofiddlewithornottofiddlewith' WHERE [Name] = 'network packet size (B)';
UPDATE #Configuration SET [Comment] = 'rarely change from default, ref: https://msdn.microsoft.com/en-us/library/ms187104%28v=sql.120%29.aspx' WHERE [Name] = 'affinity mask';
UPDATE #Configuration SET [Comment] = 'rarely change from default' WHERE [Name] = 'index create memory (KB)' 
UPDATE #Configuration SET [Comment] = 'rarely change from default' WHERE [Name] = 'min memory per query (KB)'


--******************************************
-- All Configuration Values 
--******************************************
SELECT * from #Configuration
ORDER BY name;

--******************************************
-- CPU Related Configuration Values 
--******************************************
SELECT * from #Configuration
WHERE NAME IN(
  'cost threshold for parallelism' 
, 'lightweight pooling'
, 'max degree of parallelism'  
, 'priority boost' 
, 'affinity mask'                 
)
ORDER BY name;


--******************************************
-- Memory Related Configuration Values 
--******************************************
SELECT * from #Configuration
WHERE NAME IN(
  'max server memory (MB)'          
, 'min server memory (MB)'
, 'optimize for ad hoc workloads'  
, 'index create memory (KB)' 
, 'min memory per query (KB)'
)
ORDER BY name;


DROP TABLE #Configuration


--******************************************************************************
-- Global trace flags that are enabled 
--******************************************************************************
DBCC TRACESTATUS (-1);


--******************************************************************************
--*   Copyright (C) 2015 Glenn Berry, SQLskills.com
--*   All rights reserved. 
--*
--*   For more scripts and sample code, check out 
--*      http://sqlskills.com/blogs/glenn
--*
--*   You may alter this code for your own *non-commercial* purposes. You may
--*   republish altered code as long as you include this copyright and give due credit. 
--*
--*
--*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
--*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
--*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
--*   PARTICULAR PURPOSE. 
--*
--******************************************************************************

-- ==============================================
-- Tempdb files properties
-- ============================================== 
SELECT DB_NAME([database_id]) AS [Database Name], 
       [file_id], 
	   LEFT(physical_name, 3) AS [Drive Location],
	   name AS [Logical File Name], 
	   physical_name AS [Physical Path & File Name], 
	   type_desc AS [File Type], 
	   is_percent_growth AS [Growth Type], --1 = %, 0 = MB
	   growth AS growth_amt,
	   CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE database_id = 2
ORDER BY DB_NAME([database_id]) 
OPTION (RECOMPILE);

-- Is TempDB on dedicated drives?
-- Is there only one TempDB data file?
-- Are all of the TempDB data files the same size?



-- ==============================================
-- Check Tempdb Contention
-- ==============================================
SELECT  session_id
       ,wait_type
       ,wait_duration_ms
       ,blocking_session_id
       ,resource_description
       ,ResourceType =
              CASE WHEN CAST(RIGHT(resource_description,
                       LEN(resource_description) - CHARINDEX(':', resource_description, 3)) AS int)
                       - 1 % 8088 = 0 THEN 'Is PFS Page'
             WHEN CAST(RIGHT(resource_description,
                       LEN(resource_description) - CHARINDEX(':', resource_description, 3)) AS int)
                       - 2 % 511232 = 0 THEN 'Is GAM Page'
             WHEN CAST(RIGHT(resource_description,
                       LEN(resource_description) - CHARINDEX(':', resource_description, 3)) AS int)
                       - 3 % 511232 = 0 THEN 'Is SGAM Page'
             ELSE 'Is Not PFS, GAM, or SGAM page'
         END
FROM    sys.dm_os_waiting_tasks
WHERE   wait_type LIKE 'PAGE%LATCH_%'
  AND resource_description LIKE '2:%';




-- ==============================================
-- Database File Configurations
-- ==============================================

-- File names and paths for all user and system databases on instance 
SELECT DB_NAME([database_id]) AS [Database Name], 
       [file_id], 
	   LEFT(physical_name, 3) AS Drive_Location,
	   name AS [Logical File Name], 
	   physical_name AS [Physical Path & File Name], 
	   type_desc AS [File Type], 
	   CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE database_id > 4
ORDER BY DB_NAME([database_id]) 
OPTION (RECOMPILE);


-- Database Files set to Percent file Growth
SELECT DB_NAME([database_id]) AS [Database Name], 
       name AS [Logical File Name], 
	   type_desc AS [File Type],
	   'Percent' AS [Growth Type], 
	   growth AS [Growth Amt],
       CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE is_percent_growth = 1
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);


-- Database Filess set to Percent file Growth
SELECT DB_NAME([database_id]) AS [Database Name], 
       name AS [Logical File Name], 
	   type_desc AS [File Type],
	   'MB' AS  [Growth Type], 
	   growth AS [Growth Amt],
	   CONVERT(bigint, growth/128.0) AS [Growth in MB], 
       CONVERT(bigint, size/128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE is_percent_growth = 0
ORDER BY DB_NAME([database_id]) 
OPTION (RECOMPILE);

-- Things to look at:
-- Are data files and log files on different drives?
-- Is everything on the C: drive?
-- Are there multiple data files for user databases?
-- Is percent growth enabled for any files (which is bad)?





/* *****************************************************************************
    Instant File Initialization

	Do you have Instant File Initialization enabled?
	How can you tell?
	Create a database and time it using some reasonable size 
	for your data file, like 5GB. 
	
	Remember that we never have Instant File Initialization for log files. 
	
	Adapt the code below for file path name, possibly 
	database name and the datetime handling if you are lower then SQL Server 2008:
** ******************************************************************************/

DECLARE @t time(3) = SYSDATETIME()
CREATE DATABASE IFI_test_ld
ON PRIMARY
(NAME = N'IFI_test', FILENAME = N'D:\IFI_test_ld.mdf', SIZE = 5GB, FILEGROWTH = 100MB)
LOG ON
(NAME = N'IFI_test_log', FILENAME = N'D:\IFI_test_ld.ldf', SIZE = 4MB, FILEGROWTH = 10MB)
SELECT DATEDIFF(ms, @t, CAST(SYSDATETIME() AS time(3))) AS LargeDataFile
SET @t = SYSDATETIME()
CREATE DATABASE IFI_test_ll
ON PRIMARY
(NAME = N'IFI_test2', FILENAME = N'D:\IFI_test_ll.mdf', SIZE = 4MB, FILEGROWTH = 100MB)
LOG ON
(NAME = N'IFI_test_log2', FILENAME = N'D:\IFI_test_ll.ldf', SIZE = 5GB, FILEGROWTH = 10MB)
SELECT DATEDIFF(ms, @t, CAST(SYSDATETIME() AS time(3))) AS LargeLogFile
GO

--Drop databases
DROP DATABASE IFI_test_ld
GO
DROP DATABASE IFI_test_ll
GO


