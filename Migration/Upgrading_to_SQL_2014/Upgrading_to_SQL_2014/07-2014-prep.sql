-----------------------------------------------------
-- New SQL Server 2014 instance preparation        --
-----------------------------------------------------
-- Connect to SQL2014\MSSQL2014INST01
-- Enable trace flags:
-- 1117
-- 1118 
-- 1204 
-- 1222
-- 3023
-- 3226
-- 4199
-- Check which trace flags are turned on:
DBCC TRACESTATUS (- 1);
GO

-- sp_whoisactive scripts 
-- Add alerts 
-- Apply Ola's Hallengren maintenance scripts 
-- Configure SQL Server instance:
--
-- - cost threshold for parallelism
-- - max degree of parallelism
-- - max server memory (MB)
-- - min server memory (MB)
-- - optimize for ad hoc workloads (*)
-- - remote admin connections
-- 
EXEC dbo.sp_configure 'show advanced options'
	,1
GO

RECONFIGURE
GO

EXEC dbo.sp_configure
GO

EXEC dbo.sp_configure 'cost threshold for parallelism'
	,25
GO

EXEC dbo.sp_configure 'max degree of parallelism'
	,2
GO

EXEC dbo.sp_configure 'max server memory (MB)'
	,2048
GO

EXEC dbo.sp_configure 'min server memory (MB)'
	,1024
GO

EXEC dbo.sp_configure 'optimize for ad hoc workloads'
	,1
GO

EXEC dbo.sp_configure 'remote admin connections'
	,1
GO

RECONFIGURE
GO

-- SQL Server login sync 02d-login_sync.sql
-- Extended Event to track deprecated features used in application
-- Source: http://www.sqlservergeeks.com/sql-server-track-deprecated-features-with-extended-events/
--Create an Event Session to track Features that are not yet deprecated but will be removed in a feture release 
CREATE EVENT SESSION [find_deprecation_announcement] ON SERVER ADD EVENT sqlserver.deprecation_announcement ADD TARGET package0.ring_buffer
	WITH (MAX_DISPATCH_LATENCY = 3 SECONDS)
GO

--Start event session
ALTER EVENT SESSION [find_deprecation_announcement] ON SERVER STATE = START
GO

--sp_lock is one such feature
sp_lock @@spid

-- Wait for Event buffering to Target
WAITFOR DELAY '00:00:05';
GO

--Get the output of this Event Session from Ring Buffer
DECLARE @xml_holder XML;

SELECT @xml_holder = CAST(target_data AS XML)
FROM sys.dm_xe_sessions AS s
JOIN sys.dm_xe_session_targets AS t ON t.event_session_address = s.address
WHERE s.NAME = N'find_deprecation_announcement'
	AND t.target_name = N'ring_buffer';

SELECT node.value('(data[@name="feature_id"]/value)[1]', 'int') AS feature_id
	,node.value('(data[@name="feature"]/value)[1]', 'varchar(50)') AS feature
	,node.value('(data[@name="message"]/value)[1]', 'varchar(200)') AS message
	,node.value('(@name)[1]', 'varchar(50)') AS event_name
FROM @xml_holder.nodes('RingBufferTarget/event') AS p(node);
GO

-- Failing queries
IF EXISTS (
		SELECT *
		FROM sys.server_event_sessions
		WHERE NAME = 'XE_FailingQueries'
		)
	DROP EVENT SESSION XE_FailingQueries ON SERVER;
GO

CREATE EVENT SESSION [XE_FailingQueries] ON SERVER ADD EVENT sqlserver.error_reported (ACTION(package0.collect_system_time, package0.last_error, sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.database_id, sqlserver.database_name, sqlserver.nt_username, sqlserver.plan_handle, sqlserver.query_hash, sqlserver.session_id, sqlserver.sql_text, sqlserver.tsql_frame, sqlserver.tsql_stack, sqlserver.username) WHERE ([severity] > 10)) ADD TARGET package0.event_file (
	SET FILENAME = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\XEvents\XE_FailingQueries.xel'
	,METADATAFILE = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\XEvents\XE_FailingQueries.xem'
	)
	WITH (max_dispatch_latency = 5 seconds);
GO

ALTER EVENT SESSION [XE_FailingQueries] ON SERVER STATE = START;
GO

SELECT SalesOrderID
	,SalesOrderDetailID
	,CarrierTrackingNumber
	,OrderQty
	,ProductID
	,UnitPrice
	,UnitPriceDiscount
FROM AdventureWorks2012.Sales.SalesOrderDetails

-- AdventureWorks2012.Sales.SalesOrderDetail <-- correct table name
IF (OBJECT_ID('tempdb..#e') IS NOT NULL)
	DROP TABLE #e
GO

WITH cte
AS (
	SELECT CAST(event_data AS XML) AS event_data
	FROM sys.fn_xe_file_target_read_file('D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\XEvents\XE_FailingQueries*.xel', NULL, NULL, NULL)
	)
	,cte2
AS (
	SELECT event_number = ROW_NUMBER() OVER (
			ORDER BY T.x
			)
		,event_name = T.x.value('@name', 'varchar(100)')
		,event_timestamp = T.x.value('@timestamp', 'datetimeoffset')
		,event_data
	FROM cte
	CROSS APPLY event_data.nodes('/event') T(x)
	)
SELECT *
INTO #e
FROM cte2
GO

WITH cte3
AS (
	SELECT --c.event_number, 
		c.event_timestamp
		,
		--data_field = T2.x.value('local-name(.)', 'varchar(100)'), 
		data_name = T2.x.value('@name', 'varchar(100)')
		,data_value = T2.x.value('value[1]', 'varchar(max)')
	--,data_text = T2.x.value('text[1]', 'varchar(max)') 
	FROM #e c
	CROSS APPLY c.event_data.nodes('event/*') T2(x)
	)
	,cte4
AS (
	SELECT *
	FROM cte3
	WHERE data_name IN (
			'error_number'
			,'severity'
			,'message'
			,'database_name'
			,'database_id'
			,'client_hostname'
			,'client_app_name'
			,'username'
			,'sql_text'
			)
	)
SELECT *
FROM cte4
PIVOT(MAX(data_value) FOR data_name IN (
			database_name
			,[error_number]
			,[severity]
			,[message]
			,sql_text
			,username
			,client_app_name
			,client_hostname
			,database_id
			)) T
WHERE [severity] > 10
ORDER BY event_timestamp DESC
GO


