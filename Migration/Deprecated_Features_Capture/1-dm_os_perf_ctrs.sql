/* DMV: dm_os_performance_counters link: 
	http://msdn.microsoft.com/en-us/library/ms187743.aspx */


USE master;

/* See everything available in this DMV */
SELECT * 
	FROM sys.dm_os_performance_counters;


/* Limit DMV results to Deprecated Features */
SELECT * 
	FROM sys.dm_os_performance_counters
	WHERE [object_name] LIKE '%:Deprecated%';


/* Limit DMV results to Deprecated Features Used Since Startup */
SELECT * 
	FROM sys.dm_os_performance_counters
	WHERE [object_name] LIKE '%:Deprecated%'
	AND [cntr_value] > 0;