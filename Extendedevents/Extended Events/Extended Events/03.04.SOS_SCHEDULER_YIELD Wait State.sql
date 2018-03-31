USE AdventureWorks2014
GO

-- Look for any suspicious waits during execution
IF OBJECT_ID('tempdb..#waits_base') IS NOT NULL
	DROP TABLE #waits_base

SELECT * INTO #waits_base FROM sys.dm_os_wait_stats WHERE wait_type NOT LIKE 'PREEMPTIVE_OS_%'

--CHECK WAITS
SELECT w.wait_type
    ,wait_count_delta = w.waiting_tasks_count - b.waiting_tasks_count
    ,wait_time = w.wait_time_ms - b.wait_time_ms
FROM sys.dm_os_wait_stats w 
    INNER JOIN #waits_base b ON b.wait_type = w.wait_type
ORDER BY wait_count_delta DESC