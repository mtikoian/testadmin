/**************Blocking Script*****************
				--------->Status<--------------------
Background:The SPID is running a background task, such as deadlock detection.
Sleeping  :The SPID is not currently executing. This usually indicates that the SPID is awaiting a command from the application.
Running	The SPID is currently running on a scheduler.
Runnable  :	The SPID is in the runnable queue of a scheduler and waiting to get scheduler time.
Sos_scheduler_yield	The SPID was running, but it has voluntarily yielded its time slice on the scheduler to allow another SPID to acquire scheduler time.
Suspended :	The SPID is waiting for an event, such as a lock or a latch.
Rollback  :	The SPID is in rollback of a transaction.
Defwakeup :	Indicates that the SPID is waiting for a resource that is in the process of being freed. The waitresource field should indicate the resource in question.
http://support.microsoft.com/kb/224453

*/

                                             
SELECT
Blocking.session_id as BlockingSessionId
, Sess.login_name AS BlockingUser
, BlockingSQL.text AS BlockingSQL
, Waits.wait_type WhyBlocked
, Blocked.session_id AS BlockedSessionId
, USER_NAME(Blocked.user_id) AS BlockedUser
, BlockedSQL.text AS BlockedSQL
, DB_NAME(Blocked.database_id) AS DatabaseName
FROM sys.dm_exec_connections AS Blocking
INNER JOIN sys.dm_exec_requests AS Blocked
ON Blocking.session_id = Blocked.blocking_session_id
INNER JOIN sys.dm_os_waiting_tasks AS Waits
ON Blocked.session_id = Waits.session_id
RIGHT OUTER JOIN sys.dm_exec_sessions Sess
ON Blocking.session_id = sess.session_id
CROSS APPLY sys.dm_exec_sql_text(Blocking.most_recent_sql_handle)
AS BlockingSQL
CROSS APPLY sys.dm_exec_sql_text(Blocked.sql_handle) AS BlockedSQL
ORDER BY BlockingSessionId, BlockedSessionId


--PAGEIOLATCH_SCH
--13:1:105021895  --Page
SELECT FILE_NAME(1)
SELECT o.name, i.name 
FROM sys.partitions p 
JOIN sys.objects o ON p.object_id = o.object_id 
JOIN sys.indexes i ON p.object_id = i.object_id 
AND p.index_id = i.index_id 
WHERE p.hobt_id = 105021895

DBCC PAGE(13, 1, 105021895)
DBCC PAGE (16, 1, 1323, 3) 
page 16:1:1321
DBCC PAGE (dbid, fileid, pageid, output_option) 


SELECT object_name(105021895) 

SELECT name FROM sys.indexes WHERE   index_id = 10


PositionView