WITH [Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER',             N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',                N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',              N'CHECKPOINT_QUEUE',
        N'CHKPT',                           N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',                N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',              N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',           N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',                 N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                        N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT',     N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',               N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',            N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',                 N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',                  N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                    N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_SHUTDOWN_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH',     N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',               N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',                 N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',             N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',            N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',                N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',             N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP',     N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',           N'WAIT_FOR_RESULTS',
        N'WAITFOR',                         N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',              N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',             N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',              N'XE_TIMER_EVENT')
    AND [waiting_tasks_count] > 0
 )
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX ([W1].[Percentage]) < 95; -- percentage threshold
GO

/*
505: CXPACKET
This indicates parallelism, not necessarily that there’s a problem. The coordinator thread in a parallel query always accumulates these waits. 
If the parallel threads are not given equal amounts of work to do, or one thread blocks, the waiting threads will also accumulate CXPACKET waits,
 which will make them aggregate a lot faster – this is a problem. One thread may have a lot more to do than the others, and so the whole query 
 is blocked while the long-running thread completes. If this is combined with a high number of PAGEIOLATCH_XX waits, it could be large parallel
  table scans going on because of incorrect non-clustered indexes, or a bad query plan. If neither of these are the issue, you might want to
   try setting MAXDOP to 4, 2, or 1 for the offending queries (or possibly the whole instance). Make sure that if you have a NUMA system that
    you try setting MAXDOP to the number of cores in a single NUMA node first to see if that helps the problem. You also need to consider the
	 MAXDOP effect on a mixed-load system. To be honest, I’d play with the cost threshold for parallelism setting (bump it up to, say, 25) 
	 before reducing the MAXDOP of the whole instance. And don’t forget Resource Governor in Enterprise Edition of  SQL Server 2008 onward that allows DOP
governing for a particular group of connections to the server.
2015 update: You can read more about CXPACKET waits in my recent blog posts here and here.
304: PAGEIOLATCH_XX
This is where SQL Server is waiting for a data page to be read from disk into memory. It may indicate a bottleneck at the 
IO subsystem level (which is a common “knee-jerk” response to seeing these), but why is the I/O subsystem having to service so many reads? 
It could be buffer pool/memory pressure (i.e. not enough memory for the workload), a sudden change in query plans causing a large parallel 
scan instead of a seek, plan cache bloat, or a number of other things. Don’t assume the root cause is the I/O subsystem.
2015 update: You can read more about PAGEIOLATCH_XX waits in my recent blog post here.
275: ASYNC_NETWORK_IO
This is usually where SQL Server is waiting for a client to finish consuming data. It could be that the client has asked for a very 
large amount of data or just that it’s consuming it reeeeeally slowly because of poor programming – I rarely see this being a network issue.
 Clients often process one row at a time – called RBAR or Row-By-Agonizing-Row – instead of caching the data on the client and acknowledging 
 to SQL Server immediately.
112: WRITELOG
This is the log management system waiting for a log flush to disk. It commonly indicates that the I/O subsystem can’t keep up
 with the log flush volume, but on very high-volume systems it could also be caused by internal log flush limits,
  that may mean you have to split your workload over multiple databases or even make your transactions a little longer to reduce log flushes. 
  To be sure it’s the I/O subsystem, use the DMV sys.dm_io_virtual_file_stats to examine the I/O latency for the log file and see if it correlates 
  to the average WRITELOG time. If WRITELOG is longer, you’ve got internal contention and need to shard. If not, investigate why you’re creating 
  so much transaction log.
2015 update: See here and here for some ideas.
109: BROKER_RECEIVE_WAITFOR
This is just Service Broker waiting around for new messages to receive. I would add this to the list of waits to filter out
 and re-run the wait stats query.
086: MSQL_XP
This is SQL Server waiting for an extended stored-proc to finish. This could indicate a problem in your XP code.
074: OLEDB
As its name suggests, this is a wait for something communicating using OLEDB – e.g. a linked server. However, OLEDB is 
also used by all DMVs and by DBCC CHECKDB, so don’t assume linked servers are the problem – it could be a third-party 
monitoring tool making excessive DMV calls. If it *is* a linked server (wait times in the 10s or 100s of milliseconds), 
go to the linked server and do wait stats analysis there to figure out what the performance issue is there.
054: BACKUPIO
This can show up when you’re backing up to a slow I/O subsystem, like directly to tape, which is slooooow, or over a network.
041: LCK_M_XX
This is simply the thread waiting for a lock to be granted and indicates blocking problems. These could be caused by unwanted 
lock escalation or bad programming, but could also be from I/Os taking a long time causing locks to be held for longer than usual.
 Look at the resource associated with the lock using the DMV sys.dm_os_waiting_tasks. Don’t assume that locking is the root cause.
032: ONDEMAND_TASK_QUEUE
This is normal and is part of the background task system (e.g. deferred drop, ghost cleanup).  I would add this to the list 
of waits to filter out and re-run the wait stats query.
031: BACKUPBUFFER
 This commonly show up with BACKUPIO and is a backup thread waiting for a buffer to write backup data into.
027: IO_COMPLETION
This is SQL Server waiting for non-data page I/Os to complete and could be an indication that the I/O subsystem is overloaded 
if the latencies look high (see Are I/O latencies killing your performance?)
024: SOS_SCHEDULER_YIELD
This is code running that doesn’t hit any resource waits. See here for more details.
022: DBMIRROR_EVENTS_QUEUE
022: DBMIRRORING_CMD
 These two are database mirroring just sitting around waiting for something to do. I would add these to the list of waits
  to filter out and re-run the wait stats query.
018: PAGELATCH_XX
This is contention for access to in-memory copies of pages. The most well-known cases of these are the PFS 
and SGAM contention that can occur in tempdb under certain workloads. To find out what page the contention is on,
 you’ll need to use the DMV sys.dm_os_waiting_tasks to figure out what page the latch is for. For tempdb issues, 
 Robert Davis (blog|twitter) has a good post showing how to do this. Another common cause I’ve seen is an index hot-spot
  with concurrent inserts into an index with an identity value key.
016: LATCH_XX
This is contention for some non-page structure inside SQL Server – so not related to I/O or data at all. 
These can be hard to figure out and you’re going to be using the DMV sys.dm_os_latch_stats. More on this in my Latches category.
013: PREEMPTIVE_OS_PIPEOPS
This is SQL Server switching to pre-emptive scheduling mode to call out to Windows for something, and this 
particular wait is usually from using xp_cmdshell. These were added for 2008 and haven’t been documented yet (anywhere). 
The easiest way to figure out what they mean is to remove the PREEMPTIVE_OS_ and then search for what’s left on MSDN – 
it’ll be the name of a Windows API. XXXOPS types won’t work with that method though as they’re catch-all waits for a variety 
of underlying function calls. This one shows up commonly when using xp_cmdshell.
013: THREADPOOL
This says that there aren’t enough worker threads on the system to satisfy demand. Commonly this is large 
numbers of high-DOP queries trying to execute and taking all the threads from the thread pool.
009: BROKER_TRANSMITTER
This is just Service Broker waiting around for new messages to send. I would add this to the list of waits 
to filter out and re-run the wait stats query.
006: SQLTRACE_WAIT_ENTRIES
Part of SQL Trace. I would add this to the list of waits to filter out and re-run the wait stats query./li>
005: DBMIRROR_DBM_MUTEX
This one is undocumented and is contention for the send buffer that database mirroring shares between all 
the mirroring sessions on a server. It could indicate that you’ve got too many mirroring sessions.
005: RESOURCE_SEMAPHORE
This is queries waiting for execution memory (the memory used to process the query operators – like a sort). 
This could be memory pressure or a very high concurrent workload.
003: PREEMPTIVE_OS_AUTHENTICATIONOPS
003: PREEMPTIVE_OS_GENERICOPS
These are SQL Server switching to pre-emptive scheduling mode to call out to Windows for something. 
These were added for 2008 and haven’t been documented yet (anywhere). The easiest way to figure out what they mean is to remove the PREEMPTIVE_OS_ and then search for what’s left on MSDN – it’ll be the name of a Windows API. XXXOPS types won’t work with that method though as they’re catch-all waits for a variety of underlying function calls. The AUTHENTICATIONOPS one specifically is for looking up security information from a domain controller or active directory controller.
003: SLEEP_BPOOL_FLUSH
This is normal to see and indicates that checkpoint is throttling itself to avoid overloading the IO subsystem. 
I would add this to the list of waits to filter out and re-run the wait stats query.
002: MSQL_DQ
This is SQL Server waiting for a distributed query to finish. This could indicate a problem with the distributed query, 
or it could just be normal.
002: RESOURCE_SEMAPHORE_QUERY_COMPILE
When there are too many concurrent query compilations going on, SQL Server will throttle them. I don’t remember 
the threshold, but this can indicate excessive recompilation, or maybe single-use plans.
001: DAC_INIT
I’ve never seen this one before and BOL says it’s because the dedicated admin connection is initializing. I can’t 
see how this is the most common wait on someone’s system…
001: MSSEARCH
This is normal to see for full-text operations.  If this is the highest wait, it could mean your system is spending most 
of its time doing full-text queries. You might want to consider adding this to the filter list.
001: PREEMPTIVE_OS_FILEOPS
001: PREEMPTIVE_OS_LIBRARYOPS
001: PREEMPTIVE_OS_LOOKUPACCOUNTSID
001: PREEMPTIVE_OS_QUERYREGISTRY
These are SQL Server switching to pre-emptive scheduling mode to call out to Windows for something. 
These were added for 2008 and haven’t been documented yet (anywhere). The easiest way to figure out what 
they mean is to remove the PREEMPTIVE_OS_ and then search for what’s left on MSDN – it’ll be the name of a Windows API. 
XXXOPS types won’t work with that method though as they’re catch-all waits for a variety of underlying function calls. 
The LOOPUPACCOUNTSID one specifically is for looking up security information from a domain controller or active directory controller.
001: SQLTRACE_LOCK
Part of SQL Trace. I would add this to the list of waits to filter out and re-run the wait stats query.
*/