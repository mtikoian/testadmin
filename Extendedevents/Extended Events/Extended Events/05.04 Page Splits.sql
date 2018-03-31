IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name = 'exPageSplit')
	DROP EVENT SESSION exPageSplit ON SERVER
GO

CREATE EVENT SESSION exPageSplit ON SERVER
ADD EVENT sqlserver.page_split (
    ACTION (
        sqlserver.sql_text
        ,sqlserver.database_id
        )
    )
ADD TARGET package0.ring_buffer,
ADD TARGET package0.asynchronous_bucketizer (
	SET filtering_event_name = 'sqlserver.page_split'
        ,source_type = 1
        ,source = 'sqlserver.sql_text'
        ,slots = 2048)
WITH (max_dispatch_latency = 5seconds)
GO

ALTER EVENT SESSION exPageSplit ON SERVER state = start
GO

;WITH Buckets 
AS (
    SELECT CAST(xest.target_data as xml) AS xEvent, xes.name
    FROM sys.dm_xe_session_targets xest
        INNER JOIN sys.dm_xe_sessions xes on xes.address = xest.event_session_address
    WHERE xes.name = 'exPageSplit'
    AND xest.target_name = 'histogram' 
)
SELECT slots.value('@count', 'bigint') AS bucket_count
    ,slots.value('.', 'nvarchar(4000)')
FROM Buckets
    CROSS APPLY xEvent.nodes('//HistogramTarget/Slot') as T(slots)

