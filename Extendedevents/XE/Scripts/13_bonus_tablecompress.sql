/*
The intent of this demo is to show different methods
of reviewing the data captured by an XE session.

In this bonus material, I show how to review the data by
querying the ring_buffer directly (target in the first example),
by querying the asynchronous file (target in the second example) directly,
and finally by creating a Data Collection to capture the info from
the asynchronous file.
*/

-- Create an Event Session to Track the Failed attempts
CREATE EVENT SESSION PageCompressionTracing
ON SERVER
ADD EVENT sqlserver.page_compression_attempt_failed,
ADD EVENT sqlserver.page_compression_tracing
add target package0.ring_buffer		-- Store events in the ring buffer target
WITH (MAX_MEMORY = 8MB, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=5SECONDS
		,startup_state = ON
)
GO
-- Start the Event Session
ALTER EVENT SESSION PageCompressionTracing
ON SERVER
STATE=START
GO

-- Create an Event Session to Track the Failed attempts
CREATE EVENT SESSION PageCompressionTracingII
ON SERVER
ADD EVENT sqlserver.page_compression_attempt_failed,
ADD EVENT sqlserver.page_compression_tracing
add target package0.asynchronous_file_target(
     SET filename='C:\Admin\Presentations\XE\PageCompressionTracingII.xel',
         metadatafile='C:\Admin\Presentations\XE\PageCompressionTracingII.xem')
WITH (MAX_MEMORY = 8MB, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY=5SECONDS)
GO
-- Start the Event Session
ALTER EVENT SESSION PageCompressionTracingII
ON SERVER
STATE=START
GO

/* Query the ring buffer version of the Page Compression Session 
This query runs for 8 minutes before returning the 1638 rows of data
*/
SELECT oTab.*

	FROM
	(
	SELECT 
	     ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowID,
    XEvent.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    DATEADD(hh, 
            DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
            XEvent.value('(@timestamp)[1]', 'datetime2')) AS [timestamp],
    COALESCE(XEvent.value('(data[@name="database_id"]/value)[1]', 'int'), 
             XEvent.value('(action[@name="database_id"]/value)[1]', 'int')) AS database_id,
    XEvent.value('(data[@name="file_id"]/value)[1]', 'int') AS [file_id],
    XEvent.value('(data[@name="page_id"]/value)[1]', 'int') AS [page_id],
    XEvent.value('(data[@name="rowset_id"]/value)[1]', 'bigint') AS [rowset_id],
    XEvent.value('(data[@name="failure_reason"]/text)[1]', 'nvarchar(150)') AS [failure_reason],
    XEvent.value('(action[@name="system_thread_id"]/value)[1]', 'int') AS [system_thread_id],
    XEvent.value('(action[@name="scheduler_id"]/value)[1]', 'int') AS [scheduler_id],
    XEvent.value('(action[@name="cpu_id"]/value)[1]', 'int') AS [cpu_id]
	FROM 
	( 
	   SELECT CAST(target_data AS XML) AS target_data 
	   FROM sys.dm_xe_session_targets xst 
	   JOIN sys.dm_xe_sessions xs ON xs.address = xst.event_session_address 
	   WHERE xs.name = 'PageCompressionTracing' 
	) AS tab (target_data) 
	CROSS APPLY target_data.nodes('/RingBufferTarget/event') AS EventNodes(XEvent) 
	) AS oTab
	LEFT JOIN sys.dm_os_buffer_descriptors AS obd
	   ON obd.database_id = oTab.database_id
	       AND obd.FILE_ID = oTab.FILE_ID
	       AND obd.page_id = oTab.page_id
	LEFT JOIN sys.allocation_units au
	   ON au.allocation_unit_id = obd.allocation_unit_id
	LEFT JOIN sys.partitions p 
	   ON p.partition_id = au.container_id  
	LEFT JOIN sys.indexes i
	   ON p.OBJECT_ID = i.OBJECT_ID
	       AND p.index_id = i.index_id
	       
	       
/* Query the FILE Based Version OF the PAGE COMPRESSION SESSION  

This version takes a mere few seconds to complete
Script Source --XE Session Script
http://sqlskills.com/blogs/jonathan/post/An-XEvent-a-Day-(28-of-31)-e28093-Tracking-Page-Compression-Operations.aspx

*/
CREATE DATABASE [PageCompTestResults]
GO
USE [PageCompTestResults]
GO
-- Create intermediate temp table for raw event data
CREATE TABLE RawEventData
(Rowid int identity primary key, event_data xml)
GO
-- Read the file data into intermediate temp table
INSERT INTO RawEventData (event_data)
SELECT
    CAST(event_data AS XML) AS event_data
FROM sys.fn_xe_file_target_read_file('C:\Admin\Presentations\XE\PageCompressionTracingII*.xel', 
                                     'C:\Admin\Presentations\XE\PageCompressionTracingII*.xem', 
                                     null, null)
GO
-- Fetch the Event Data from the Event Session Target
DROP TABLE dbo.ParsedResults
GO

SELECT 
    RowID,
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    DATEADD(hh, 
            DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
            event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp],
    COALESCE(event_data.value('(event/data[@name="database_id"]/value)[1]', 'int'), 
             event_data.value('(event/action[@name="database_id"]/value)[1]', 'int')) AS database_id,
    event_data.value('(event/data[@name="file_id"]/value)[1]', 'int') AS [file_id],
    event_data.value('(event/data[@name="page_id"]/value)[1]', 'int') AS [page_id],
    event_data.value('(event/data[@name="rowset_id"]/value)[1]', 'bigint') AS [rowset_id],
    event_data.value('(event/data[@name="failure_reason"]/text)[1]', 'nvarchar(150)') AS [failure_reason],
    event_data.value('(event/action[@name="system_thread_id"]/value)[1]', 'int') AS [system_thread_id],
    event_data.value('(event/action[@name="scheduler_id"]/value)[1]', 'int') AS [scheduler_id],
    event_data.value('(event/action[@name="cpu_id"]/value)[1]', 'int') AS [cpu_id]
INTO ParsedResults
FROM RawEventData
GO


SELECT 
    pr.database_id, 
    p.object_id, 
    p.index_id,
    failure_reason, 
    COUNT(*) as failure_count
FROM CompressTest.sys.partitions p
JOIN PageCompTestResults.dbo.ParsedResults pr
    ON pr.rowset_id = p.hobt_id
WHERE event_name = 'page_compression_attempt_failed'
GROUP BY     pr.database_id, 
    p.object_id, 
    p.index_id,
    failure_reason
GO

/*
-- Look at the compression information in sys.dm_db_index_operational_stats

I am Using the CompressTest Database that I created for this experiment
I have a table called CDTypes2 in that database that I compressed.

*/

USE CompressTest
GO
SELECT 
    database_id, 
    object_id, 
    index_id, 
    page_compression_attempt_count, 
    page_compression_success_count,
    (page_compression_attempt_count - page_compression_success_count) as page_compression_failure_count
FROM sys.dm_db_index_operational_stats(db_id(), object_id('CDTypes2'), null, null)
GO



/* V3 
Create a Data Collection Set
Management Data Warehouse is Required for this Section
*/
--new base query for the DC

SELECT 
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    DATEADD(hh, 
            DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
            event_data.value('(event/@timestamp)[1]', 'datetime2')) AS [timestamp],
    COALESCE(event_data.value('(event/data[@name="database_id"]/value)[1]', 'int'), 
             event_data.value('(event/action[@name="database_id"]/value)[1]', 'int')) AS database_id,
    event_data.value('(event/data[@name="file_id"]/value)[1]', 'int') AS [file_id],
    event_data.value('(event/data[@name="page_id"]/value)[1]', 'int') AS [page_id],
    event_data.value('(event/data[@name="rowset_id"]/value)[1]', 'bigint') AS [rowset_id],
    event_data.value('(event/data[@name="failure_reason"]/text)[1]', 'nvarchar(150)') AS [failure_reason],
    event_data.value('(event/action[@name="system_thread_id"]/value)[1]', 'int') AS [system_thread_id],
    event_data.value('(event/action[@name="scheduler_id"]/value)[1]', 'int') AS [scheduler_id],
    event_data.value('(event/action[@name="cpu_id"]/value)[1]', 'int') AS [cpu_id]
FROM (SELECT
    CAST(event_data AS XML) AS event_data
FROM sys.fn_xe_file_target_read_file('C:\Admin\Presentations\XE\PageCompressionTracingII*.xel', 
                                     'C:\Admin\Presentations\XE\PageCompressionTracingII*.xem', 
                                     null, null)
) AS e(event_data)

GO

/* DC */
BEGIN TRANSACTION 
BEGIN Try 
DECLARE @collection_set_id_1 INT 
DECLARE @collection_set_uid_2 uniqueidentifier 
EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] @name=N'PageCompressionTracing', @collection_mode=1, 
@description=N'PageCompressionTracing', @logging_level=1, @days_until_expiration=14, 
@schedule_name=N'CollectorSchedule_Every_60min', @collection_set_id=@collection_set_id_1 OUTPUT, 
@collection_set_uid=@collection_set_uid_2 OUTPUT 

SELECT @collection_set_id_1, @collection_set_uid_2 
  
DECLARE @collector_type_uid_3 uniqueidentifier 
SELECT @collector_type_uid_3 = collector_type_uid FROM [msdb].[dbo].[syscollector_collector_types] 
WHERE name = N'Generic T-SQL Query Collector Type'; 
DECLARE @collection_item_id_4 INT 
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
@name=N'PageCompressionTracing'
, @parameters=N'<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>

SELECT 
    event_data.value(''(event/@name)[1]'', ''varchar(50)'') AS event_name,
    DATEADD(hh, 
            DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), 
            event_data.value(''(event/@timestamp)[1]'', ''datetime2'')) AS [timestamp],
    COALESCE(event_data.value(''(event/data[@name="database_id"]/value)[1]'', ''int''), 
             event_data.value(''(event/action[@name="database_id"]/value)[1]'', ''int'')) AS database_id,
    event_data.value(''(event/data[@name="file_id"]/value)[1]'', ''int'') AS [file_id],
    event_data.value(''(event/data[@name="page_id"]/value)[1]'', ''int'') AS [page_id],
    event_data.value(''(event/data[@name="rowset_id"]/value)[1]'', ''bigint'') AS [rowset_id],
    event_data.value(''(event/data[@name="failure_reason"]/text)[1]'', ''nvarchar(150)'') AS [failure_reason],
    event_data.value(''(event/action[@name="system_thread_id"]/value)[1]'', ''int'') AS [system_thread_id],
    event_data.value(''(event/action[@name="scheduler_id"]/value)[1]'', ''int'') AS [scheduler_id],
    event_data.value(''(event/action[@name="cpu_id"]/value)[1]'', ''int'') AS [cpu_id]
FROM (SELECT
    CAST(event_data AS XML) AS event_data
FROM sys.fn_xe_file_target_read_file(''C:\Admin\Presentations\XE\PageCompressionTracingII*.xel'', 
                                     ''C:\Admin\Presentations\XE\PageCompressionTracingII*.xem'', 
                                     null, null)
) AS e(event_data) 
  
</Value><OutputTable>PageCompressionTracing</OutputTable></Query></ns:TSQLQueryCollector>', 
@collection_item_id=@collection_item_id_4 OUTPUT
, @frequency=3600 --#seconds in collection interval
,@collection_set_id=@collection_set_id_1
, @collector_type_uid=@collector_type_uid_3 

SELECT @collection_item_id_4 
  
COMMIT TRANSACTION; 
END Try 
BEGIN Catch 
ROLLBACK TRANSACTION; 
DECLARE @ErrorMessage NVARCHAR(4000); 
DECLARE @ErrorSeverity INT; 
DECLARE @ErrorState INT; 
DECLARE @ErrorNumber INT; 
DECLARE @ErrorLine INT; 
DECLARE @ErrorProcedure NVARCHAR(200); 
SELECT @ErrorLine = ERROR_LINE(), 
@ErrorSeverity = ERROR_SEVERITY(), 
@ErrorState = ERROR_STATE(), 
@ErrorNumber = ERROR_NUMBER(), 
@ErrorMessage = ERROR_MESSAGE(), 
@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-'); 
RAISERROR (14684, @ErrorSeverity, 1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, 
@ErrorLine, @ErrorMessage); 
  
END Catch; 
  
GO 

--aggregation queries
SELECT 
    pr.database_id, 
    p.object_id, 
    p.index_id,
    failure_reason, 
    COUNT(*) as failure_count
FROM CompressTest.sys.partitions p
JOIN MDW.custom_snapshots.PageCompressionTracing pr
    ON pr.rowset_id = p.hobt_id
WHERE event_name = 'page_compression_attempt_failed'
GROUP BY     pr.database_id, 
    p.object_id, 
    p.index_id,
    failure_reason
GO
-- Cleanup

ALTER EVENT SESSION PageCompressionTracing
ON SERVER
STATE=STOP
GO

ALTER EVENT SESSION PageCompressionTracingII
ON SERVER
STATE=STOP
GO

DROP EVENT SESSION PageCompressionTracing
ON SERVER
GO

DROP EVENT SESSION PageCompressionTracingII
ON SERVER
GO