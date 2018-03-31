USE master;
GO

EXECUTE xp_create_subdir 'C:\Database\XE';
GO

-- Create the Event Session
IF EXISTS ( SELECT *
				FROM sys.server_event_sessions
				WHERE name = 'DBDeletedCreated2k12' )
	DROP EVENT SESSION DBDeletedCreated2k12 
	ON SERVER;
GO
CREATE EVENT SESSION DBDeletedCreated2k12 ON SERVER
ADD EVENT sqlserver.object_created (  SET collect_database_name = ( 1 )
	ACTION ( sqlserver.nt_username, sqlserver.session_id,
	sqlserver.client_hostname, sqlserver.client_app_name, sqlserver.sql_text )
	WHERE object_type = 16964 -- 'DATABASE'

 ),
ADD EVENT sqlserver.object_deleted (  SET collect_database_name = ( 1 )
	ACTION ( sqlserver.nt_username, sqlserver.session_id,
	sqlserver.client_hostname, sqlserver.client_app_name, sqlserver.sql_text )
	WHERE object_type = 16964 -- 'DATABASE'
)
ADD TARGET package0.event_file ( SET filename = N'C:\Database\XE\DBDeletedCreated2k12.xel' );

/* start the session */
ALTER EVENT SESSION DBDeletedCreated2k12 
ON SERVER 
STATE = START;
GO

USE master;
GO
-- Create the Event Session
IF EXISTS(SELECT * 
          FROM sys.server_event_sessions 
          WHERE name='DBDeletedCreated')
    DROP EVENT SESSION DBDeletedCreated 
    ON SERVER;
GO
CREATE EVENT SESSION DBDeletedCreated
ON SERVER
ADD EVENT sqlserver.object_created (
	SET collect_database_name = (1)
	ACTION(sqlserver.nt_username,sqlserver.session_id,sqlserver.client_hostname,sqlserver.client_app_name,sqlserver.sql_text)
WHERE object_type = 'DATABASE'

	),
ADD EVENT sqlserver.object_deleted(
	SET collect_database_name = (1)
	ACTION(sqlserver.nt_username,sqlserver.session_id,sqlserver.client_hostname,sqlserver.client_app_name,sqlserver.sql_text)
WHERE object_type = 'DATABASE'
)
ADD TARGET package0.event_file(SET filename=N'C:\Database\XE\DBDeletedCreated.xel')

/* start the session */
ALTER EVENT SESSION DBDeletedCreated 
ON SERVER 
STATE = START;
GO

CREATE DATABASE XETestDB;
GO

DROP DATABASE XETestDB;
GO

USE master;
GO

SELECT event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name
		, event_data.value('(event/@timestamp)[1]', 'varchar(50)') AS [TIMESTAMP]
		, event_data.value('(event/data[@name="database_name"]/value)[1]',
							'varchar(max)') AS DBName
		, event_data.value('(event/data[@name="object_name"]/value)[1]',
							'varchar(max)') AS ObjName
		, CASE event_data.value('(event/data[@name="ddl_phase"]/value)[1]',
								'varchar(max)')
			WHEN 0 THEN 'BEGIN'
			WHEN 1 THEN 'COMMIT'
			WHEN 2 THEN 'ROLLBACK'
			END AS DDLPhase
		, event_data.value('(event/data[@name="object_type"]/value)[1]',
							'varchar(max)') AS ObjType
		, event_data.value('(event/data[@name="transaction_id"]/value)[1]',
							'varchar(max)') AS XactID
		, event_data.value('(event/action[@name="session_id"]/value)[1]',
							'varchar(max)') AS SessionID
		, event_data.value('(event/action[@name="nt_username"]/value)[1]',
							'varchar(max)') AS ExecUser
		, CONVERT(XML, event_data.value('(event/action[@name="sql_text"]/value)[1]',
										'varchar(max)')) AS sql_text
		, event_data.value('(event/action[@name="client_app_name"]/value)[1]',
							'varchar(max)') AS Client_AppName
	FROM ( SELECT CONVERT(XML, t2.event_data) AS event_data
				FROM ( SELECT target_data = CONVERT(XML, target_data)
							FROM sys.dm_xe_session_targets t
								INNER JOIN sys.dm_xe_sessions s
									ON t.event_session_address = s.address
							WHERE t.target_name = 'event_file'
								AND s.name = 'DBDeletedCreated'
						) cte1
					CROSS APPLY cte1.target_data.nodes('//EventFileTarget/File') FileEvent ( FileTarget )
					CROSS APPLY sys.fn_xe_file_target_read_file(FileEvent.FileTarget.value('@name',
																'varchar(1000)'),
																NULL, NULL, NULL) t2
			) AS evts ( event_data )
	ORDER BY event_data.value('(event/@timestamp)[1]', 'varchar(50)');


/*2012 Version*/

USE master;
GO

SELECT event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name
		, event_data.value('(event/@timestamp)[1]', 'varchar(50)') AS [TIMESTAMP]
		, event_data.value('(event/data[@name="database_name"]/value)[1]',
							'varchar(max)') AS DBName
		, event_data.value('(event/data[@name="object_name"]/value)[1]',
							'varchar(max)') AS ObjName
		, CASE event_data.value('(event/data[@name="ddl_phase"]/value)[1]',
								'varchar(max)')
			WHEN 0 THEN 'BEGIN'
			WHEN 1 THEN 'COMMIT'
			WHEN 2 THEN 'ROLLBACK'
			END AS DDLPhase
		, event_data.value('(event/data[@name="object_type"]/value)[1]',
							'varchar(max)') AS ObjType
		, event_data.value('(event/data[@name="transaction_id"]/value)[1]',
							'varchar(max)') AS XactID
		, event_data.value('(event/action[@name="session_id"]/value)[1]',
							'varchar(max)') AS SessionID
		, event_data.value('(event/action[@name="nt_username"]/value)[1]',
							'varchar(max)') AS ExecUser
		, CONVERT(XML, event_data.value('(event/action[@name="sql_text"]/value)[1]',
										'varchar(max)')) AS sql_text
		, event_data.value('(event/action[@name="client_app_name"]/value)[1]',
							'varchar(max)') AS Client_AppName
	FROM ( SELECT CONVERT(XML, t2.event_data) AS event_data
				FROM ( SELECT target_data = CONVERT(XML, target_data)
							FROM sys.dm_xe_session_targets t
								INNER JOIN sys.dm_xe_sessions s
									ON t.event_session_address = s.address
							WHERE t.target_name = 'event_file'
								AND s.name = 'DBDeletedCreated2k12'
						) cte1
					CROSS APPLY cte1.target_data.nodes('//EventFileTarget/File') FileEvent ( FileTarget )
					CROSS APPLY sys.fn_xe_file_target_read_file(FileEvent.FileTarget.value('@name',
																'varchar(1000)'),
																NULL, NULL, NULL) t2
			) AS evts ( event_data )
	ORDER BY event_data.value('(event/@timestamp)[1]', 'varchar(50)');
