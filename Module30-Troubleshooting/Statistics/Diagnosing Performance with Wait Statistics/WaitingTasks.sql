Use master;

--What is in sys.dm_os_waiting_tasks?
Select *
From sys.dm_os_waiting_tasks;
Go

--What is in sys.dm_os_waiting_tasks?
Select *
From sys.dm_exec_requests;
Go

--What is in sys.dm_exec_sessions?
Select *
From sys.dm_exec_sessions;
Go

-- More relevant look at waiting tasks
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

Select SessionID = session_id, 
	WaitDuration_ms = wait_duration_ms,
	WaitType = wait_type,
	WaitResource = resource_description
From sys.dm_os_waiting_tasks WT
Where session_id > 50
And Not Exists (Select 1 From @ExcludedWaits
			Where WaitType = WT.wait_type);
Go

-- More relevant look at requests
Select R.session_id, 
	R.request_id,
	R.start_time,
	R.status,
	R.command,
	DBName = DB_NAME(R.database_id),
	R.blocking_session_id,
	R.wait_type,
	R.wait_time,
	R.last_wait_type,
	R.wait_resource
From sys.dm_exec_requests R
Inner Join sys.dm_exec_sessions S On R.session_id = S.session_id
Where R.status = 'suspended'
And S.is_user_process = 1
And R.session_id <> @@spid;
Go

-- closer look at last_wait_type
Select R.session_id, 
	R.request_id,
	R.start_time,
	R.status,
	R.command,
	DBName = DB_NAME(R.database_id),
	R.blocking_session_id,
	R.wait_type,
	R.wait_time,
	R.last_wait_type,
	R.wait_resource
From sys.dm_exec_requests R
Inner Join sys.dm_exec_sessions S On R.session_id = S.session_id
Where R.wait_type Is Null;
Go

-- Expanding on requests to include query and query plan
Select R.session_id, 
	R.request_id,
	R.start_time,
	R.status,
	R.command,
	DBName = DB_NAME(R.database_id),
	R.blocking_session_id,
	R.wait_type,
	R.wait_time,
	R.last_wait_type,
	R.wait_resource,
	QueryPlan = CP.query_plan,
	SQLText = SUBSTRING(ST.text, (R.statement_start_offset/2)+1, 
		((Case R.statement_end_offset
			  When -1 Then DATALENGTH(ST.text)
			 Else R.statement_end_offset
		 End - R.statement_start_offset)/2) + 1)
From sys.dm_exec_requests R
Cross Apply sys.dm_exec_query_plan (R.plan_handle) CP
Cross Apply sys.dm_exec_sql_text(R.sql_handle) ST
Inner Join sys.dm_exec_sessions S On R.session_id = S.session_id
Where R.status = 'suspended'
And S.is_user_process = 1
And R.session_id <> @@spid;
Go

-- Now let's put all of these DMVs together
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

Select SessionID = WT.session_id, 
	WaitDuration_ms = WT.wait_duration_ms,
	WaitType = WT.wait_type,
	WaitResource = WT.resource_description,
	Program = S.program_name,
	QueryPlan = CP.query_plan,
	SQLText = SUBSTRING(ST.text, (R.statement_start_offset/2)+1, 
		((Case R.statement_end_offset
			  When -1 Then DATALENGTH(ST.text)
			 Else R.statement_end_offset
		 End - R.statement_start_offset)/2) + 1),
	DBName = DB_NAME(R.database_id),
	BlocingSessionID = WT.blocking_session_id,
	BlockerQueryPlan = CPBlocker.query_plan,
	BlockerSQLText = SUBSTRING(STBlocker.text, (RBlocker.statement_start_offset/2)+1, 
		((Case RBlocker.statement_end_offset
			  When -1 Then DATALENGTH(STBlocker.text)
			 Else RBlocker.statement_end_offset
		 End - RBlocker.statement_start_offset)/2) + 1)
From sys.dm_os_waiting_tasks WT
Inner Join sys.dm_exec_sessions S on WT.session_id = S.session_id
Inner Join sys.dm_exec_requests R on R.session_id = WT.session_id
Cross Apply sys.dm_exec_query_plan (R.plan_handle) CP
Cross Apply sys.dm_exec_sql_text(R.sql_handle) ST
Left Join sys.dm_exec_requests RBlocker on RBlocker.session_id = WT.blocking_session_id
Outer Apply sys.dm_exec_query_plan (RBlocker.plan_handle) CPBlocker
Outer Apply sys.dm_exec_sql_text(RBlocker.sql_handle) STBlocker
Where R.status = 'suspended'
And S.is_user_process = 1
And R.session_id <> @@spid
And Not Exists (Select 1 From @ExcludedWaits
			Where WaitType = WT.wait_type);
Go
