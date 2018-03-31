Use master;

--What is in sys.dm_os_wait_stats?
Select *
From sys.dm_os_wait_stats;
Go

-- A little more relevant now
-- Tasks with highest cumulative wait time
Select *
From sys.dm_os_wait_stats
Where waiting_tasks_count > 0
Order by wait_time_ms desc;
Go

-- Even more relevant: waits we care about
-- Tasks with highest cumulative wait time
Declare @ExcludedWaits Table (WaitType sysname not null primary key)

Insert Into @ExcludedWaits
Select ('CLR_SEMAPHORE')
Union Select ('LAZYWRITER_SLEEP')
Union Select ('RESOURCE_QUEUE')
Union Select ('SLEEP_TASK')
Union Select ('SLEEP_SYSTEMTASK')
Union Select ('SQLTRACE_BUFFER_FLUSH')
Union Select ('WAITFOR')
Union Select ('LOGMGR_QUEUE')
Union Select ('CHECKPOINT_QUEUE')
Union Select ('REQUEST_FOR_DEADLOCK_SEARCH')
Union Select ('XE_TIMER_EVENT')
Union Select ('BROKER_TO_FLUSH')
Union Select ('BROKER_TASK_STOP')
Union Select ('CLR_MANUAL_EVENT')
Union Select ('CLR_AUTO_EVENT')
Union Select ('DISPATCHER_QUEUE_SEMAPHORE')
Union Select ('FT_IFTS_SCHEDULER_IDLE_WAIT')
Union Select ('XE_DISPATCHER_WAIT')
Union Select ('XE_DISPATCHER_JOIN');

Select *,
	WaitPct = Cast(100. * wait_time_ms / SUM(wait_time_ms) OVER() As decimal (20,2))
From sys.dm_os_wait_stats WS
Where waiting_tasks_count > 0
And Not Exists (Select 1 From @ExcludedWaits
			Where WaitType = WS.wait_type)
Order by WaitPct desc;
Go

-- Most relevant: how are they changing?
--Sample -> wait 1 minute -> resample and calculate
Declare @Waits Table (
	WaitID int identity(1, 1) not null primary key,
	wait_type nvarchar(60),
	wait_time_s decimal(12, 2));
Declare @ExcludedWaits Table (WaitType sysname not null primary key)

Insert Into @ExcludedWaits
Select ('CLR_SEMAPHORE')
Union Select ('LAZYWRITER_SLEEP')
Union Select ('RESOURCE_QUEUE')
Union Select ('SLEEP_TASK')
Union Select ('SLEEP_SYSTEMTASK')
Union Select ('SQLTRACE_BUFFER_FLUSH')
Union Select ('WAITFOR')
Union Select ('LOGMGR_QUEUE')
Union Select ('CHECKPOINT_QUEUE')
Union Select ('REQUEST_FOR_DEADLOCK_SEARCH')
Union Select ('XE_TIMER_EVENT')
Union Select ('BROKER_TO_FLUSH')
Union Select ('BROKER_TASK_STOP')
Union Select ('CLR_MANUAL_EVENT')
Union Select ('CLR_AUTO_EVENT')
Union Select ('DISPATCHER_QUEUE_SEMAPHORE')
Union Select ('FT_IFTS_SCHEDULER_IDLE_WAIT')
Union Select ('XE_DISPATCHER_WAIT')
Union Select ('XE_DISPATCHER_JOIN');

-- Get top waits
WITH Waits
As (SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
		100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
		ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
	FROM sys.dm_os_wait_stats WS
	WHERE Not Exists (Select 1 From @ExcludedWaits
				Where WaitType = WS.wait_type))
Insert Into @Waits (wait_type, wait_time_s)
SELECT W1.wait_type,
  CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 95; -- percentage threshold

-- Wait 1 minute
WaitFor Delay '0:01:00';

-- Get top waits again
WITH Waits
AS (SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
		100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
		ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
	FROM sys.dm_os_wait_stats WS
	WHERE Not Exists (Select 1 From @ExcludedWaits
				Where WaitType = WS.wait_type))
Insert Into @Waits (wait_type, wait_time_s)
SELECT W1.wait_type,
  CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 95; -- percentage threshold

-- calculate the total wait time over the 1 minute
Select wait_type, MAX(wait_time_s) - MIN(wait_time_s) WaitDelta
From @Waits
Group By wait_type
Order By WaitDelta Desc;
Go

-- Special case: CPU Pressure
-- Query from SQLCat blog: http://blogs.msdn.com/b/sqlcat/archive/2005/09/05/461199.aspx
-- slightly reformatted for readability
Select signal_wait_time_ms = sum(signal_wait_time_ms),
	[% signal (cpu) waits] = cast(100.0 * sum(signal_wait_time_ms) / sum (wait_time_ms) as numeric(20,2)),
	resource_wait_time_ms = sum(wait_time_ms - signal_wait_time_ms),
	[% resource waits] = cast(100.0 * sum(wait_time_ms - signal_wait_time_ms) / sum (wait_time_ms) as numeric(20,2))
From sys.dm_os_wait_stats;
Go
