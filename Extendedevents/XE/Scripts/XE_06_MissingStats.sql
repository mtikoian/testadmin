/* sql 2014 XE??
*/
CREATE EVENT SESSION [Statistics] ON SERVER
	ADD EVENT sqlserver.auto_stats (ACTION (sqlserver.sql_text)
		WHERE ([sqlserver].[database_name] = N'Adventureworks2012')),
	ADD EVENT sqlserver.missing_column_statistics (ACTION (sqlserver.sql_text)
		WHERE ([sqlserver].[database_name] = N'AdventureWorks2012'))
	/*missing column stats only useful if auto_update stats is turned off*/
	--,ADD EVENT sqlserver.query_optimizer_estimate_cardinality (ACTION (sqlserver.sql_text)
	--	WHERE (sqlserver.database_name = N'AdventureWorks2012'))
	ADD TARGET package0.ring_buffer(SET max_memory=(2048))
	WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=10 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
	GO
	;

ALTER EVENT SESSION [STATISTICS] ON SERVER STATE= START;


SELECT CAST(
          REPLACE(
                REPLACE(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)'), 
               '', ''),
          '','')
    AS XML) AS sql_text
FROM
(SELECT CAST(target_data AS XML) AS TargetData
	FROM sys.dm_xe_session_targets st
	INNER JOIN sys.dm_xe_sessions s 
		ON s.address = st.event_session_address
	WHERE name = 'Statistics') AS Data
	CROSS APPLY TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)