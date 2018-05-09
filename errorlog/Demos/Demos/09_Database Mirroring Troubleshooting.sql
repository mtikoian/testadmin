-- Database Mirroring Troubleshooting



-- Check log reuse wait description, log usage size and log file size for all mirrored databases
:CONNECT LABDB01 
SELECT @@SERVERNAME AS [Server Name], db.[name] AS [Database Name], db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0) AS [Log Size (MB)], CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS [Log Used (MB)],
CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %] 
FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
ON db.name = ls.instance_name
INNER JOIN sys.database_mirroring AS dm WITH (NOLOCK)
ON db.database_id = dm.database_id
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0
AND dm.mirroring_guid IS NOT NULL 
ORDER BY db.[name];


-- Check the status of the mirroring partnership
:CONNECT LABDB01
SELECT @@SERVERNAME AS [Server Name], DB_NAME(Database_id) AS [Database Name], mirroring_role_desc, 
       mirroring_state_desc, mirroring_safety_level_desc, mirroring_partner_name, mirroring_witness_name,
	   mirroring_witness_state_desc, mirroring_failover_lsn, mirroring_connection_timeout
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;


-- Check top waits for server instance since last restart or wait statistics clear 
-- Are any top waits mirroring-related?
:CONNECT LABDB01 
WITH [Waits] 
AS (SELECT wait_type, wait_time_ms/ 1000.0 AS [WaitS],
          (wait_time_ms - signal_wait_time_ms) / 1000.0 AS [ResourceS],
           signal_wait_time_ms / 1000.0 AS [SignalS],
           waiting_tasks_count AS [WaitCount],
           100.0 *  wait_time_ms / SUM (wait_time_ms) OVER() AS [Percentage],
           ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats WITH (NOLOCK)
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', 
		N'MEMORY_ALLOCATION_EXT', N'ONDEMAND_TASK_QUEUE',
		N'PREEMPTIVE_HADR_LEASE_MECHANISM', N'PREEMPTIVE_SP_SERVER_DIAGNOSTICS',
		N'PREEMPTIVE_OS_LIBRARYOPS', N'PREEMPTIVE_OS_COMOPS', N'PREEMPTIVE_OS_CRYPTOPS',
		N'PREEMPTIVE_OS_PIPEOPS', N'PREEMPTIVE_OS_AUTHENTICATIONOPS',
		N'PREEMPTIVE_OS_GENERICOPS', N'PREEMPTIVE_OS_VERIFYTRUST',
		N'PREEMPTIVE_OS_FILEOPS', N'PREEMPTIVE_OS_DEVICEOPS', N'PREEMPTIVE_OS_QUERYREGISTRY',
		N'PREEMPTIVE_OS_WRITEFILE',
		N'PREEMPTIVE_XE_CALLBACKEXECUTE', N'PREEMPTIVE_XE_DISPATCHER',
		N'PREEMPTIVE_XE_GETTARGETSTATE', N'PREEMPTIVE_XE_SESSIONCOMMIT',
		N'PREEMPTIVE_XE_TARGETINIT', N'PREEMPTIVE_XE_TARGETFINALIZE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',
		N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
		N'QDS_ASYNC_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'WAIT_XTP_RECOVERY',
		N'XE_BUFFERMGR_ALLPROCESSED_EVENT', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_LIVE_TARGET_TVF', N'XE_TIMER_EVENT')
    AND waiting_tasks_count > 0)
SELECT
    MAX (W1.wait_type) AS [WaitType],
	CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) AS [Wait Percentage],
	CAST ((MAX (W1.WaitS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgWait_Sec],
    CAST ((MAX (W1.ResourceS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgRes_Sec],
    CAST ((MAX (W1.SignalS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgSig_Sec], 
    CAST (MAX (W1.WaitS) AS DECIMAL (16,2)) AS [Wait_Sec],
    CAST (MAX (W1.ResourceS) AS DECIMAL (16,2)) AS [Resource_Sec],
    CAST (MAX (W1.SignalS) AS DECIMAL (16,2)) AS [Signal_Sec],
    MAX (W1.WaitCount) AS [Wait Count],
	CAST (N'https://www.sqlskills.com/help/waits/' + W1.wait_type AS XML) AS [Help/Info URL]
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum, W1.wait_type
HAVING SUM (W2.Percentage) - MAX (W1.Percentage) < 99 -- percentage threshold
OPTION (RECOMPILE);


-- Get some recent database mirroring statistics
:CONNECT LABDB01
SELECT TOP (15) DB_NAME(database_id) AS [database_name], *
FROM msdb.dbo.dbm_monitor_data
WHERE DB_NAME(database_id) = N'AdventureWorks'
ORDER BY [time] DESC;


-- Returns recent status rows for a monitored database from the status table
:CONNECT LABDB01 
USE msdb;  
EXEC sp_dbmmonitorresults N'AdventureWorks', 2, 1; -- Last four hours, update status


-- Get mirroring endpoint information
:CONNECT LABDB01
SELECT @@SERVERNAME AS [ServerName], [name] AS [EndpointName], endpoint_id, principal_id, 
       protocol_desc, [type_desc], state_desc, is_admin_endpoint, role_desc, is_encryption_enabled, 
	   connection_auth_desc, certificate_id, encryption_algorithm_desc
FROM sys.database_mirroring_endpoints;


-- Get more mirroring endpoint information
:CONNECT LABDB01
SELECT @@SERVERNAME AS [ServerName], dme.protocol_desc, dme.[type_desc], dme.state_desc, 
       dme.role_desc, te.port, te.ip_address, is_encryption_enabled, connection_auth_desc, 
	   certificate_id, encryption_algorithm_desc
FROM sys.database_mirroring_endpoints AS dme
INNER JOIN sys.tcp_endpoints AS te
ON dme.endpoint_id = te.endpoint_id;


-- Check permissions on endpoints
:CONNECT LABDB01
SELECT EP.name AS [Endpoint Name], SP.STATE, 
CONVERT(nvarchar(38), suser_name(SP.grantor_principal_id)) AS [Grantor], 
SP.TYPE AS [Permission],
CONVERT(nvarchar(46),suser_name(SP.grantee_principal_id)) AS [Grantee] 
FROM sys.server_permissions AS SP 
INNER JOIN sys.endpoints AS EP
ON SP.major_id = EP.endpoint_id
ORDER BY Permission,Grantor, Grantee; 



-- Some database mirroring performance troubleshooting resources

-- Database Mirroring Best Practices and Performance Considerations
-- https://technet.microsoft.com/en-us/library/cc917681.aspx

-- Database Mirroring in SQL Server 2005
-- https://technet.microsoft.com/en-us/library/cc917680.aspx 

