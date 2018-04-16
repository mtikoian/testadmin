RUNNING:
--Running :session is running one or more batches. When Multiple Active Result Sets (MARS) is enabled,a session can run multiple batches. 
--SUSPENDED:It means that the request currently is not active because it is waiting on a resource. 
--The resource can be an I/O for reading a page, A WAITit can be communication on the network, or it is waiting for lock or a latch. It will become active once the task it is waiting for is completed. For example, if the query the has posted a I/O request to read data of a complete table tblStudents then this task will be suspended till the I/O is complete. Once I/O is completed (Data for table tblStudents is available in the memory), query will move into RUNNABLE queue.
--You can also check my blog http://blogs.msdn.com/b/sqlsakthi/archive/2011/02/20/sql-query-slowness-troubleshooting-using-extended-events-wait-info-event.aspx to find out waits for a particular SPID using XEVENTS.
--RUNNABLE:
--The SPID is in the runnable queue of a scheduler and waiting for a quantum to run on the scheduler. This means that requests got a worker thread assigned but they are not getting CPU time.
--Now, we cannot say that the system does not have enough CPU if you see more SPID's with status RUNNABLE. Your load is really CPU bounded if a number of runnable tasks per each scheduler always greater than 1 and all of your queries have correct plan. So you have to make sure that plan generated is the effective plan but still is the query is forced to wait in RUNNABLE queue for a longer time, then adding more CPU makes sense.
--How would you ensure that plan generated is the effective one? 
--Good question. Right?
--Simple answer to this would be:
--1. Statistics are up to date? (Including manually created, auto-created and stats created by indexes)
--2. Proper MAXDOP settings (Refer KB 329204, 2023536) etc.. 
--Since this is deviating from the topic of the blog, I'm stopping the discussion about why we see more SPID's in RUNNABLE queue here.
--PENDING:
--The request is waiting for a worker to pick it up.
--This means the request is ready to run but there are no worker threads available to execute the requests in CPU.  This doesn't mean that you have to increase 'Max. Worker threads", you have to check what the currently executing threads are doing and why they are not yielding back. I personally have seen more SPID's with status PENDING on issues which ended up in "Non-yielding Scheduler" and "Scheduler deadlock". Check Q4 in Slava Oak's blog http://blogs.msdn.com/b/slavao/archive/2006/09/28/776437.aspx to decide on when to increase Max. worker threads.
--BACKGROUND: 
--The request is a background thread such as Resource Monitor or Deadlock Monitor.
--SLEEPING:
--There is no work to be done.
---what is going on with your server right now
DECLARE @OpenQueries TABLE (cpu_time INT, logical_reads INT, session_id INT)
INSERT INTO @OpenQueries(cpu_time, logical_reads, session_id)
select r.cpu_time ,r.logical_reads, r.session_id
from sys.dm_exec_sessions as s inner join sys.dm_exec_requests as r
on s.session_id =r.session_id and s.last_request_start_time=r.start_time
where is_user_process = 1
and s.session_id <> @@SPID
waitfor delay '00:00:01'
select substring(h.text, (r.statement_start_offset/2)+1 , ((case r.statement_end_offset when -1 then datalength(h.text)  else r.statement_end_offset end - r.statement_start_offset)/2) + 1) as text
, r.cpu_time-t.cpu_time as CPUDiff
, r.logical_reads-t.logical_reads as ReadDiff
, r.wait_type
, r.wait_time
, r.last_wait_type
, r.wait_resource
, r.command
, r.database_id
, r.blocking_session_id
, r.granted_query_memory
, r.session_id
, r.reads
, r.writes, r.row_count, s.[host_name]
, s.program_name, s.login_name
from sys.dm_exec_sessions as s inner join sys.dm_exec_requests as r
on s.session_id =r.session_id and s.last_request_start_time=r.start_time
left join @OpenQueries as t on t.session_id=s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) h
where is_user_process = 1
and s.session_id <> @@SPID
order by 3 desc