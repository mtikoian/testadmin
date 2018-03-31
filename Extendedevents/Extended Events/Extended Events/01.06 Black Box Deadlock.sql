--http://www.sqlservercentral.com/articles/deadlocks/65658/
--Jonathan Kehayias

;WITH 
data AS (
    SELECT CAST(target_data AS xml) AS TargetData
    FROM sys.dm_xe_session_targets st
        INNER JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
    WHERE name = 'system_health'
    AND target_name = 'ring_buffer'
	)
,deadlocks AS (
	SELECT CAST(c.query('(.)[1]') as XML) AS deadlock
        ,c.value('(./@name)[1]','varchar(100)') AS event_name
	FROM data d 
		CROSS APPLY TargetData.nodes ('/RingBufferTarget/event') AS t (c)
	WHERE c.exist('.[@name = "xml_deadlock_report"]') = 1
	)
SELECT y.query ('(deadlock/.)[1]') AS tsql_stack
FROM deadlocks
	CROSS APPLY deadlock.nodes('/event/data/value') x(y)