USE master;
GO
-- Create the Event Session
IF EXISTS(SELECT * 
          FROM sys.server_event_sessions 
          WHERE name='DOP')
    DROP EVENT SESSION DOP 
    ON SERVER;
GO
CREATE EVENT SESSION DOP
ON SERVER
ADD EVENT sqlserver.degree_of_parallelism (
	ACTION(sqlserver.database_name,sqlserver.nt_username,sqlserver.session_id,sqlserver.client_hostname,sqlserver.client_app_name,sqlserver.sql_text)
WHERE database_name = 'Adventureworks2014'
	)
ADD TARGET package0.event_file(SET filename=N'C:\Database\XE\DOP.xel')

/* start the session */
ALTER EVENT SESSION DOP 
ON SERVER 
STATE = START;
GO
