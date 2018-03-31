/*
Find Events that might teach us about file size changes on the instance
*/

SELECT c.object_name as EventName,p.name as PackageName,o.description as EventDescription
	FROM sys.dm_xe_objects o
		INNER JOIN sys.dm_xe_object_columns c 
			ON o.name = c.object_name
			and o.package_guid = c.object_package_guid
		INNER JOIN sys.dm_xe_packages p
			on o.package_guid = p.guid
	WHERE object_type='event'
		AND c.name = 'channel'
		AND (c.object_name like '%file_size%'
			or c.object_name like '%growth%')
	Order By o.package_guid;


/* events
databases_data_file_size_changed
databases_log_file_size_changed
databases_log_growth
*/

/* Let's take a look at the columns available for each of the events picked out
*/

SELECT * FROM sys.dm_xe_object_columns
WHERE object_name = 'databases_data_file_size_changed'
AND column_type != 'readonly';

SELECT * FROM sys.dm_xe_object_columns
WHERE object_name = 'databases_log_file_size_changed'
AND column_type != 'readonly';

SELECT * FROM sys.dm_xe_object_columns
WHERE object_name = 'databases_log_growth'
AND column_type != 'readonly';

/* 
Time to build a session
*/
select database_id
	From sys.databases
	where name = 'sandbox'

CREATE EVENT SESSION [TrackDBFileChange] ON SERVER 
ADD EVENT sqlserver.databases_data_file_size_changed(
	ACTION(sqlserver.session_id,sqlserver.database_id
		,sqlserver.client_hostname,
            sqlserver.sql_text)
	--WHERE (sqlserver.database_id = 8)
	)
,ADD EVENT sqlserver.databases_log_file_size_changed(
	ACTION(sqlserver.session_id,sqlserver.database_id
		,sqlserver.client_hostname,
            sqlserver.sql_text)
	--	WHERE (sqlserver.database_id = 8)
	)
--,ADD EVENT sqlserver.databases_log_growth(
--	ACTION(sqlserver.session_id,sqlserver.database_name,sqlserver.client_hostname,
--            sqlserver.sql_text)
--	--	WHERE (sqlserver.database_id = 8)
--	)
ADD TARGET  package0.asynchronous_file_target(
     SET filename='C:\XE\DBFileSizeChange.xel',max_file_size = 5,max_rollover_files = 4
         ,metadatafile='C:\XE\DBFileSizeChange.xem') --if the path does not exist, a nasty error will be thrown
,
ADD TARGET package0.ring_buffer		-- Store events in the ring buffer target
	(SET max_memory = 4096)
WITH (MAX_MEMORY = 4MB, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, TRACK_CAUSALITY = ON, MAX_DISPATCH_LATENCY = 1 SECONDS,startup_state = ON)
GO

ALTER EVENT SESSION TrackDBFileChange 
ON SERVER 
STATE = START;
GO

ALTER EVENT SESSION TrackDBFileChange 
ON SERVER 
STATE = STOP;
GO

DROP EVENT SESSION TrackDBFileChange
ON SERVER
GO

CREATE EVENT SESSION [TrackDBFileChange12] ON SERVER 
ADD EVENT sqlserver.database_file_size_change(
	ACTION(sqlserver.session_id,sqlserver.database_name,sqlserver.client_hostname,
            sqlserver.sql_text)
	--WHERE (sqlserver.database_id = 8)
	)
,ADD EVENT sqlserver.databases_log_growth(
	ACTION(sqlserver.session_id,sqlserver.database_name,sqlserver.client_hostname,
            sqlserver.sql_text)
	--	WHERE (sqlserver.database_id = 8)
	)
ADD TARGET  package0.asynchronous_file_target(
     SET filename='C:\XE\DBFileSizeChange12.xel',max_file_size = 5,max_rollover_files = 4
         ,metadatafile='C:\XE\DBFileSizeChange12.xem')
,
ADD TARGET package0.ring_buffer		-- Store events in the ring buffer target
	(SET max_memory = 4096)
WITH (MAX_MEMORY = 4MB, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, TRACK_CAUSALITY = ON, MAX_DISPATCH_LATENCY = 1 SECONDS,startup_state = ON)
GO

ALTER EVENT SESSION TrackDBFileChange12
ON SERVER 
STATE = START;
GO

ALTER EVENT SESSION TrackDBFileChange12
ON SERVER 
STATE = STOP;
GO

DROP EVENT SESSION TrackDBFileChange12
ON SERVER
GO
/* Query the XE */

SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name
	,event_data.value('(event/@timestamp)[1]','varchar(max)') as timestamp
    ,event_data.value('(event/data[@name="count"]/value)[1]', 'bigint') AS TraceFlag
	,event_data.value('(event/data[@name="increment"]/value)[1]', 'bigint') AS FlagType
	,event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text
	,event_data.value('(event/action[@name="database_name"]/value)[1]', 'varchar(max)') AS DBQueryExecutedFrom
	,db_name(event_data.value('(event/data[@name="database_id"]/value)[1]','int')) as DBNamethatShrunk
	,event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'varchar(max)') AS ClientHost
	,event_data.value('(event/action[@name="session_id"]/value)[1]', 'varchar(max)') AS session_id
FROM(    SELECT evnt.query('.') AS event_data
        FROM
        (SELECT CAST(event_data AS xml) AS TargetData
            FROM sys.fn_xe_file_target_read_file('C:\XE\DBFileSizeChange*.xel','C:\XE\DBFileSizeChange*.xem',NULL, NULL)
        ) AS tab
        CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS split(evnt) 
    ) AS evts(event_data)
WHERE event_data.value('(event/@name)[1]', 'varchar(50)') = 'databases_log_file_size_changed'
	or event_data.value('(event/@name)[1]', 'varchar(50)') = 'databases_data_file_size_changed'
	or event_data.value('(event/@name)[1]', 'varchar(50)') = 'databases_log_growth'
ORDER BY timestamp asc;

    SELECT CAST(target_data AS xml) AS TargetData
            FROM sys.dm_xe_sessions AS s
            INNER JOIN sys.dm_xe_session_targets AS t
                ON s.address = t.event_session_address
            WHERE s.name = 'TrackDBFileChange'
              AND t.target_name = 'ring_buffer'


/* XE 2012 */

SELECT * FROM sys.dm_xe_object_columns
WHERE object_name = 'database_file_size_change'
AND column_type != 'readonly';

SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name
	,event_data.value('(event/@timestamp)[1]','varchar(max)') as timestamp
    ,event_data.value('(event/data[@name="size_change_kb"]/value)[1]', 'bigint') AS SizeChangeKb
	,event_data.value('(event/data[@name="total_size_kb"]/value)[1]', 'bigint') AS TotalSizeKb
	,event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint') AS Duration_ms
	,event_data.value('(event/data[@name="is_automatic"]/value)[1]', 'varchar(20)') AS AutoChangeEvent
	,event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text
	,event_data.value('(event/action[@name="database_name"]/value)[1]', 'varchar(max)') AS DBQueryExecutedFrom
	,db_name(event_data.value('(event/data[@name="database_id"]/value)[1]','int')) as AffectedDB
	,event_data.value('(event/data[@name="file_name"]/value)[1]','varchar(max)') as AffectedFile
	,event_data.value('(event/data[@name="file_type"]/text)[1]','varchar(max)') as FileType
	,event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'varchar(max)') AS ClientHost
	,event_data.value('(event/action[@name="session_id"]/value)[1]', 'varchar(max)') AS session_id
FROM(   SELECT CAST(event_data AS xml) AS TargetData
            FROM sys.fn_xe_file_target_read_file('C:\XE\DBFileSizeChange12*.xel',NULL,NULL, NULL)
        
    ) AS evts(event_data)
WHERE event_data.value('(event/@name)[1]', 'varchar(50)') = 'database_file_size_change'
	or event_data.value('(event/@name)[1]', 'varchar(50)') = 'databases_log_growth'
ORDER BY AffectedDB,FileType,timestamp asc;

    SELECT CAST(target_data AS xml) AS TargetData
            FROM sys.dm_xe_sessions AS s
            INNER JOIN sys.dm_xe_session_targets AS t
                ON s.address = t.event_session_address
            WHERE s.name = 'TrackDBFileChange12'
              AND t.target_name = 'ring_buffer'
