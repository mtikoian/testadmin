IF OBJECT_ID('tempdb..#PageSplitBaseline') IS NOT NULL
	DROP TABLE #PageSplitBaseline
	
SELECT object_name
	,counter_name
	,instance_name
	,cntr_value
INTO #PageSplitBaseline
FROM sys.dm_os_performance_counters opc
WHERE counter_name = 'Page Splits/sec'
 
WAITFOR DELAY '00:00:02'

SELECT opc.[object_name]
	,opc.counter_name
	,opc.instance_name
	,CAST((opc.cntr_value - b.cntr_value)/2. AS decimal(12,2)) AS calculated_counter_value 
FROM sys.dm_os_performance_counters opc
	INNER JOIN #PageSplitBaseline b ON opc.counter_name = b.counter_name AND opc.object_name = b.object_name AND opc.instance_name = b.instance_name
