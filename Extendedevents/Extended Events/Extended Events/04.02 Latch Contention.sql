USE AdventureWorks2014
GO

IF OBJECT_ID('tempdb..#waits_base') IS NOT NULL
	DROP TABLE #waits_base

SELECT * INTO #waits_base FROM sys.dm_os_wait_stats

SELECT w.wait_type
    ,wait_count_delta = w.waiting_tasks_count - b.waiting_tasks_count
    ,wait_time = w.wait_time_ms - b.wait_time_ms
FROM sys.dm_os_wait_stats w 
    INNER JOIN #waits_base b ON b.wait_type = w.wait_type
ORDER BY wait_count_delta DESC

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name = 'latch_contention')
	DROP EVENT SESSION latch_contention ON SERVER
GO

CREATE EVENT SESSION latch_contention ON SERVER
ADD EVENT sqlserver.latch_suspend_end (
	ACTION (sqlserver.tsql_stack, package0.callstack)
	WHERE (mode=4 or mode=3 /*Exclusive or UP latches*/) 
	AND sqlserver.is_system = 0)
ADD TARGET package0.ring_buffer,
ADD TARGET package0.asynchronous_bucketizer (
	SET filtering_event_name = 'sqlserver.latch_suspend_end',
	    source_type = 1,
	    source = 'sqlserver.tsql_stack',
	    slots=2048)
WITH (max_dispatch_latency = 5 seconds)
GO

ALTER EVENT SESSION latch_contention ON SERVER STATE = START
GO

-- Run Workload

SELECT w.wait_type
    ,wait_count_delta = w.waiting_tasks_count - b.waiting_tasks_count
    ,wait_time = w.wait_time_ms - b.wait_time_ms
FROM sys.dm_os_wait_stats w 
    INNER JOIN #waits_base b ON b.wait_type = w.wait_type
ORDER BY wait_count_delta DESC

GO

SELECT CAST(xest.target_data as xml) b
from sys.dm_xe_session_targets xest
join sys.dm_xe_sessions xes on xes.address = xest.event_session_address
where xest.target_name = 'histogram' and xes.name = 'latch_contention'

	
select slots.value('@count', 'bigint' ) AS bucket_count
	,slots.query('value/frames/.') AS tsql_stack
FROM (select cast(xest.target_data as xml) b, *
	from sys.dm_xe_session_targets xest
	join sys.dm_xe_sessions xes on xes.address = xest.event_session_address
	where xest.target_name = 'histogram' and xes.name = 'latch_contention'
) buckets
CROSS APPLY b.nodes('//HistogramTarget/Slot') as T(slots)


-- Resolve the top level statement
--
use AdventureWorks2014
go
declare @handle varbinary(50)
declare @offsetStart int
declare @offsetEnd int

set @handle = 0x03000700A329877AA4A3B4002DA5000001000000000000000000000000000000000000000000000000000000
set @offsetStart = 242
set @offsetEnd = 382

select stmt.dbid, stmt.objectid, object_name(stmt.objectid) as procedure_name,
	case when @offsetEnd = - 1 then right(stmt.text, (@offsetStart / 2)+1)
	else SUBSTRING(stmt.text,(@offsetStart / 2)+1 , 
		((@offsetEnd  - @offsetStart) / 2)+1)
	End  AS sql_statement
from 
sys.dm_exec_sql_text (@handle) as stmt

