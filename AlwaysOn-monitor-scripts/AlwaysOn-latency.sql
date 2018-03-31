SELECT wait_type
	,waiting_tasks_count
	,wait_time_ms
	,wait_time_ms / waiting_tasks_count AS 'latency in ms'
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
	AND wait_type = 'HADR_SYNC_COMMIT'
