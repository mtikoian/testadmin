USE master;
GO
-- Create the Event Session
IF EXISTS(SELECT * 
          FROM sys.server_event_sessions 
          WHERE name='TraceIncomingQueries')
    DROP EVENT SESSION TraceIncomingQueries 
    ON SERVER;
GO
CREATE EVENT SESSION TraceIncomingQueries
ON SERVER
ADD EVENT sqlserver.sp_statement_starting (
	SET collect_object_name=(1)
	ACTION(sqlserver.database_name,sqlserver.nt_username,sqlserver.session_id,sqlserver.client_hostname,sqlserver.client_app_name)
WHERE sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
	),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(sqlserver.database_name,sqlserver.nt_username,sqlserver.session_id,sqlserver.client_hostname,sqlserver.client_app_name)
WHERE sqlserver.database_name='AdventureWorks2014'
	AND sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
	)
ADD TARGET package0.event_file(SET filename=N'C:\Database\XE\TraceIncomingQueries.xel')

/* start the session */
ALTER EVENT SESSION TraceIncomingQueries 
ON SERVER 
STATE = START;
GO

/* now run a query */
USE AdventureWorks2014;
GO

SELECT r.session_id, r.status, r.start_time, r.command, s.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.status = 'running';

/* Parse the event data */

use master;
GO

SELECT
event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    event_data.value('(event/@timestamp)[1]', 'varchar(50)') AS [TIMESTAMP],
	event_data.value('(event/action[@name="database_name"]/value)[1]', 'varchar(max)') AS DBName
	,event_data.value('(event/data[@name="statement"]/value)[1]', 'varchar(max)') AS SQLText
	,event_data.value('(event/data[@name="object_name"]/value)[1]', 'varchar(max)') AS ObjName
	,event_data.value('(event/action[@name="session_id"]/value)[1]', 'varchar(max)') AS SessionID
	,event_data.value('(event/action[@name="nt_username"]/value)[1]', 'varchar(max)') AS ExecUser
	,event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'varchar(max)') AS Client_HostName,
	event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'varchar(max)') AS Client_AppName
FROM(
SELECT CONVERT(XML, t2.event_data) AS event_data
 FROM (
  SELECT target_data = convert(XML, target_data)
   FROM sys.dm_xe_session_targets t
    INNER JOIN sys.dm_xe_sessions s 
        ON t.event_session_address = s.address
   WHERE t.target_name = 'event_file'
    AND s.name = 'TraceIncomingQueries') cte1
   CROSS APPLY cte1.target_data.nodes('//EventFileTarget/File') FileEvent(FileTarget)
   CROSS APPLY  sys.fn_xe_file_target_read_file(FileEvent.FileTarget.value('@name', 'varchar(1000)'), NULL, NULL, NULL) t2)
    AS evts(event_data);