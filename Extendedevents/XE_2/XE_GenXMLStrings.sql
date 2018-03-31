/* auto-gen the xml for the columns for your XE sessions */
DECLARE @EventName VARCHAR(64) = NULL --'query_post_execution_showplan'
	,@ReadFlag VARCHAR(64) = 'readonly' --NULL if all columntypes are desired
	,@SessionName	VARCHAR(128) = NULL --'system_health' --NULL if all Sessions are desired

SELECT oc.OBJECT_NAME AS EventName
		,oc.name AS column_name, oc.type_name
		,',event_data.value(''(event/data[@name="' + oc.name + '"]/value)[1]'',''' + 
			CASE 
				WHEN ISNULL(xmv.name,'') = ''
					AND oc.type_name = 'guid'
				THEN 'uniqueidentifier'
				WHEN ISNULL(xmv.name,'') = ''
					AND oc.type_name = 'boolean'
				THEN 'bit'
				WHEN ISNULL(xmv.name,'') = ''
					AND oc.type_name <> 'unicode_string'
					AND oc.type_name <> 'ansi_string'
					AND oc.type_name <> 'ptr'
					AND oc.type_name NOT LIKE '%int%'
				THEN oc.type_name
				WHEN ISNULL(xmv.name,'') = ''
					AND oc.type_name LIKE '%int%'
				THEN 'int'
				ELSE 'varchar(max)' END + ''') AS ' + oc.name + '' AS ColumnXML
		,oc.column_type AS column_type
		,oc.column_value AS column_value
		,oc.description AS column_description
		,ca.map_value AS SearchKeyword
	FROM sys.dm_xe_object_columns oc
	-- do we have any custom data types
		OUTER APPLY (SELECT DISTINCT mv.name FROM sys.dm_xe_map_values mv
			WHERE mv.name = oc.type_name
			AND mv.object_package_guid = oc.object_package_guid) xmv
	--just get the unique events that are tied to a session on the server (stopped or started state)
		CROSS APPLY (SELECT DISTINCT sese.name,ses.name AS SessionName
						FROM sys.server_event_session_events sese
							INNER JOIN sys.server_event_sessions ses
								ON sese.event_session_id = ses.event_session_id) sesea
	--keyword search phrase tied to the event
		CROSS APPLY (SELECT TOP 1 mv.map_value
						FROM sys.dm_xe_object_columns occ
						INNER JOIN sys.dm_xe_map_values mv
							ON occ.type_name = mv.name
							AND occ.column_value = mv.map_key
						WHERE occ.name = 'KEYWORD'
							AND occ.object_name = oc.object_name) ca
	WHERE oc.column_type <> @ReadFlag
		AND sesea.name = oc.object_name
		AND oc.object_name = ISNULL(@EventName,oc.object_name)
		AND sesea.SessionName = ISNULL(@SessionName,sesea.SessionName)
	ORDER BY sesea.SessionName,oc.object_name
	;
GO
/*
what about in the case of a custom data type?
Play with it a little bit ;)
,CASE event_data.value('(event/data[@name="new_value"]/value)[1]','int') 
		WHEN 0 THEN 'Enabled'
		WHEN 1 THEN 'Disabled'
		END AS NewValue
*/

DECLARE @EventName VARCHAR(64) = NULL --'sp_statement_completed'
		, @EventSession VARCHAR(128) = NULL --'Deadlock' --NULL
	;

/* auto generate the xml associated to an event session action deployed to the server */
SELECT p.name AS package_name
	        ,o.name AS action_name
			,',event_data.value(''(event/action[@name="' + esa.name + '"]/value)[1]'', ''' + 
			CASE 
				WHEN o.type_name = 'guid'
				THEN 'uniqueidentifier'
				WHEN o.type_name = 'boolean'
				THEN 'bit'
				WHEN o.type_name = 'binary_data'
				THEN 'varbinary(max)'
				WHEN o.type_name = 'callstack'
				THEN 'varbinary(max)'
				WHEN o.type_name = 'filetime'
				THEN 'varbinary(max)'
				WHEN o.type_name = 'cpu_cycle'
				THEN 'varbinary(max)'
				WHEN ISNULL(o.type_name,'') = ''
				THEN NULL
				WHEN o.type_name <> 'unicode_string'
					AND o.type_name <> 'ansi_string'
					AND o.type_name <> 'ptr'
					AND o.type_name NOT LIKE '%int%'
				THEN o.type_name
				WHEN o.type_name LIKE '%int%'
				THEN 'int'
				ELSE 'varchar(max)' END + ''') AS ' + esa.name +'' AS ActionXML
			,ses.name AS EventSessionName
			, ese.name AS EventName
	        ,o.description
	FROM sys.dm_xe_packages AS p
		INNER JOIN sys.dm_xe_objects AS o
			ON p.guid = o.package_guid
		INNER JOIN sys.server_event_session_actions esa
			ON o.name = esa.name
		INNER JOIN sys.server_event_sessions ses
			ON esa.event_session_id = ses.event_session_id
		INNER JOIN sys.server_event_session_events ese
			ON esa.event_session_id = ese.event_session_id
			AND ese.event_id = esa.event_id
	WHERE o.object_type = 'action'
		AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
		AND (p.capabilities IS NULL OR p.capabilities & 1 = 0)
		AND ese.name = ISNULL(@EventName,ese.name)
		AND ses.name = ISNULL(@EventSession,ses.name)
	ORDER BY esa.name, ses.name, ese.name
	;

SELECT *
	FROM sys.dm_xe_session_events

SELECT *
	FROM sys.dm_xe_session_event_actions

SELECT *
	FROM sys.server_event_sessions

SELECT *
	FROM sys.server_event_session_actions

SELECT *
	FROM sys.server_event_session_events

SELECT *
	FROM sys.server_event_session_targets
/* file path held here for a stopped session */
SELECT *
	FROM sys.server_event_session_fields

SELECT *
	FROM sys.dm_xe_sessions

SELECT *
	FROM sys.server_event_sessions

DECLARE @SessionName VARCHAR(128) = NULL --'sp_server_diagnostics session' --NULL for all
;

SELECT ISNULL(ses.name,xse.name) AS SessionName
		, CASE
			WHEN ISNULL(ses.name,'') = ''
			THEN 'Private'
			ELSE 'Public'
			END AS SessionVisibility
		, CASE
			WHEN ISNULL(xse.name,'') = ''
			THEN 'NO'
			ELSE 'YES'
			END AS SessionRunning
		, CASE
			WHEN ISNULL(xse.name,'') = ''
				AND ISNULL(ses.name,'') = ''
			THEN 'NO'
			ELSE 'YES'
			END AS IsDeployed
	FROM sys.server_event_sessions ses
	FULL OUTER JOIN sys.dm_xe_sessions xse
		ON xse.name =ses.name
	WHERE COALESCE(@SessionName, ses.name, xse.name) = ISNULL(ses.name, xse.name)
	ORDER BY ses.event_session_id;