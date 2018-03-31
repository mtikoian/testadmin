SELECT c.OBJECT_NAME AS EventName
		,p.name AS PackageName
		,o.description AS EventDescription
	FROM sys.dm_xe_objects o
		INNER JOIN sys.dm_xe_object_columns c 
			ON o.name = c.OBJECT_NAME
			and o.package_guid = c.object_package_guid
		INNER JOIN sys.dm_xe_packages p
			ON o.package_guid = p.guid
	WHERE object_type='event'
		AND c.name = 'channel'
		AND (c.OBJECT_NAME like '%alter%'
			or o.description like '%setting%'
			OR o.description LIKE '%read%'
			)
	ORDER BY o.package_guid;

SELECT oc.OBJECT_NAME AS EventName
		,oc.name AS column_name, oc.type_name
		,oc.column_type AS column_type
		,oc.column_value AS column_value
		,oc.description AS column_description 
	FROM sys.dm_xe_object_columns oc
	--WHERE oc.name LIKE '%second%'
	WHERE oc.column_type <> 'readonly'
		AND oc.description LIKE '%batch%'
	ORDER BY EventName,column_name
GO

DECLARE @EventName VARCHAR(64) = 'object_altered'
	,@ReadFlag VARCHAR(64) = 'readonly' --NULL if all columntypes are desired
 
SELECT oc.OBJECT_NAME AS EventName
		,oc.name AS column_name, oc.type_name
		,oc.column_type AS column_type
		,oc.column_value AS column_value
		,oc.description AS column_description
		,ca.map_value AS SearchKeyword
	FROM sys.dm_xe_object_columns oc
		CROSS APPLY (SELECT TOP 1 mv.map_value
						FROM sys.dm_xe_object_columns occ
						INNER JOIN sys.dm_xe_map_values mv
							ON occ.type_name = mv.name
							AND occ.column_value = mv.map_key
						WHERE occ.name = 'KEYWORD'
							AND occ.object_name = oc.object_name) ca
	WHERE oc.object_name = @EventName
		AND oc.column_type <> @ReadFlag
	;

/* map values for the dop_statement_type
what is the data that would be returned to me ? */

SELECT oc.object_name as EventName,oc.name as ColName,mv.name as MapName, map_key, map_value 
	FROM sys.dm_xe_map_values mv
		Inner Join sys.dm_xe_object_columns oc
			on mv.name = oc.type_name
			AND mv.object_package_guid = oc.object_package_guid
	WHERE oc.object_name = @EventName
		AND oc.column_type <> @ReadFlag;

USE master;
GO
-- Create the Event Session
IF EXISTS ( SELECT *
				FROM sys.server_event_sessions
				WHERE name = 'DBSettingChange' )
	DROP EVENT SESSION DBSettingChange 
    ON SERVER;
GO

EXECUTE xp_create_subdir 'C:\Database\XE';
GO

CREATE EVENT SESSION DBSettingChange ON SERVER
ADD EVENT sqlserver.object_altered ( SET collect_database_name = ( 1 )
	ACTION ( sqlserver.sql_text,sqlserver.nt_username,sqlserver.server_principal_name,sqlserver.client_hostname,
	package0.collect_system_time,package0.event_sequence ) 
	WHERE object_type = 'DATABASE'
		AND sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
	)
ADD TARGET package0.event_file ( SET filename = N'C:\Database\XE\DBSettingChange.xel' );

/* start the session */
ALTER EVENT SESSION DBSettingChange 
ON SERVER 
STATE = START;
GO

USE master;
GO

ALTER DATABASE AdventureWorks2014
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	GO

ALTER DATABASE AdventureWorks2014
	SET MULTI_USER WITH ROLLBACK IMMEDIATE;
	GO

USE [master]
GO
ALTER DATABASE [AdventureWorks2014] SET  READ_ONLY WITH NO_WAIT
GO
ALTER DATABASE [AdventureWorks2014] SET RECOVERY FULL WITH NO_WAIT
GO
ALTER DATABASE [AdventureWorks2014] SET RECOVERY SIMPLE WITH NO_WAIT
GO


SELECT event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name
		, event_data.value('(event/data[@name="database_name"]/value)[1]',
							'varchar(max)') AS DBName
		, event_data.value('(event/data[@name="ddl_phase"]/text)[1]',
							'varchar(max)') AS DDLPhase
		, event_data.value('(event/@timestamp)[1]', 'varchar(50)') AS [TIMESTAMP]
		, event_data.value('(event/action[@name="collect_system_time"]/value)[1]',
							'varchar(max)') AS SystemTime
		, event_data.value('(event/action[@name="client_hostname"]/value)[1]',
							'varchar(max)') AS ClientHostName
		, event_data.value('(event/action[@name="server_principal_name"]/value)[1]',
							'varchar(max)') AS ServerPrincipalName
		, event_data.value('(event/action[@name="nt_username"]/value)[1]',
							'varchar(max)') AS nt_username
		, event_data.value('(event/action[@name="sql_text"]/value)[1]',
							'varchar(max)') AS sql_text
	FROM ( SELECT CONVERT(XML, t2.event_data) AS event_data
				FROM ( SELECT target_data = CONVERT(XML, target_data)
							FROM sys.dm_xe_session_targets t
								INNER JOIN sys.dm_xe_sessions s
									ON t.event_session_address = s.address
							WHERE t.target_name = 'event_file'
								AND s.name = 'DBSettingChange'
						) cte1
					CROSS APPLY cte1.target_data.nodes('//EventFileTarget/File') FileEvent ( FileTarget )
					CROSS APPLY sys.fn_xe_file_target_read_file(FileEvent.FileTarget.value('@name',
																'varchar(1000)'),
																NULL, NULL, NULL) t2
			) AS evts ( event_data )
	ORDER BY [TIMESTAMP],DDLPhase,event_data.value('(event/action[@name="event_sequence"]/value)[1]',
							'varchar(max)');

/* stop the session */
ALTER EVENT SESSION DBSettingChange 
ON SERVER 
STATE = STOP;
GO