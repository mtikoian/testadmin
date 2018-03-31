-- Oldest in-use version in version store
SELECT TOP (1) *
FROM sys.dm_tran_active_snapshot_database_transactions
ORDER BY elapsed_time_seconds DESC;
Go

-- Key version store performance counters
Declare @SrvcName sysname;

Set @SrvcName = ISNULL(N'MSSQL$' + Cast(ServerProperty('InstanceName') as sysname), N'SQLServer')

SELECT object_name AS 'Counter Object',
	[Version Generation rate (KB/s)],
	[Version Cleanup rate (KB/s)],
	[Version Store Size (KB)]
FROM (SELECT object_name, 
		counter_name,
		cntr_value
	FROM sys.dm_os_performance_counters
	WHERE object_name = @SrvcName + ':Transactions'
	AND counter_name IN (
		'Version Generation rate (KB/s)',
		'Version Cleanup rate (KB/s)',
		'Version Store Size (KB)')) AS P
PIVOT (MIN(cntr_value)
	FOR counter_name IN (
		[Version Generation rate (KB/s)],
		[Version Cleanup rate (KB/s)],
		[Version Store Size (KB)])) AS Pvt;
Go
