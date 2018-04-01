/* Use as Multi-instance Query against 2008/2008R2/2012 */

/* Usage of deprecated features by Microsoft internally is also logged */
 
SELECT * 
	FROM sys.dm_os_performance_counters
	WHERE [object_name] LIKE '%:Deprecated%'
	AND [instance_name] LIKE '%encryption%'
	AND [cntr_value] > 0;
GO

/* Notice the change in algorithm between versions */
SELECT name, key_algorithm, algorithm_desc 
	FROM master.sys.symmetric_keys;
GO
