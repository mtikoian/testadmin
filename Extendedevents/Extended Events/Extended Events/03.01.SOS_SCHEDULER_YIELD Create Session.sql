DBCC FREEPROCCACHE
GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name = 'ex_SOS_SCHEDULER_YIELD')
	DROP EVENT SESSION ex_SOS_SCHEDULER_YIELD ON SERVER
GO

CREATE EVENT SESSION ex_SOS_SCHEDULER_YIELD ON SERVER
ADD EVENT sqlos.wait_info (
	ACTION (
        sqlserver.tsql_stack
        ,sqlserver.plan_handle
    )
	WHERE wait_type = 123 -- SOS_SCHEDULER_YIELD
    AND sqlserver.is_system = 0
    )
ADD TARGET package0.ring_buffer,
ADD TARGET package0.asynchronous_bucketizer (
	SET filtering_event_name = 'sqlos.wait_info',
	    source_type = 1,
	    source = 'sqlserver.tsql_stack')
WITH (max_dispatch_latency = 1 seconds)
GO

ALTER EVENT SESSION ex_SOS_SCHEDULER_YIELD ON SERVER STATE = START
GO

SELECT * FROM sys.dm_xe_map_values
WHERE name = 'wait_types'
AND map_value IN ('SOS_SCHEDULER_YIELD')
ORDER BY 4