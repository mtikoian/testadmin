WITH xevent_data AS (
	SELECT TOP 100
		object_name
		,CAST(event_data AS XML) AS event_data
	FROM sys.fn_xe_file_target_read_file 
	('C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Log\system_health*.xel'
	, 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Log\system_health*.xem'
	, NULL, NULL))
SELECT OBJECT_NAME
	, event_data.value('(event/@timestamp)[1]','datetime2') AS time_stamp
	, event_data.value ('(event/data[@name="component"]/text)[1]','varchar(100)') AS component
	, event_data.query ('(event/data[@name="component"]/.)[1]') AS data  
FROM xevent_data
WHERE OBJECT_NAME = 'sp_server_diagnostics_component_result'
GO

SELECT CAST(target_data AS xml) AS TargetData
FROM sys.dm_xe_session_targets st
    INNER JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
WHERE name = 'system_health' and target_name = 'ring_buffer'
GO

;WITH 
XMLData AS (
    SELECT CAST(target_data AS xml) AS target_data
    FROM sys.dm_xe_session_targets st
        INNER JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
    WHERE name = 'system_health' and target_name = 'ring_buffer'
    )
,ErrorData AS (
    SELECT x.query('.') AS target_data
    FROM XMLData d
        CROSS APPLY target_data.nodes ('/RingBufferTarget/event') AS n(x)
	WHERE x.exist('.[@name="sp_server_diagnostics_component_result"]') = 1
    )
SELECT
	 target_data.value('(event/@timestamp)[1]','datetime2') AS time_stamp
	, target_data.value ('(event/data[@name="component"]/text)[1]','varchar(100)') AS component
    , target_data.value ('(event/data[@name="component"]/value)[1]','varchar(100)') AS component_id
	, target_data.value ('(event/data[@name="state"]/text)[1]','varchar(100)') AS [state]
    , target_data.value ('(event/data[@name="state"]/value)[1]','varchar(100)') AS state_id
    , target_data.query('(event/data[@name="data"]/value)[1]')
FROM ErrorData
