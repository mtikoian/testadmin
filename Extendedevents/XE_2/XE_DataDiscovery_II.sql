select map_value Keyword,*
FROM sys.dm_xe_map_values mv
where name = 'keyword_map'
ORDER BY mv.map_key


SELECT *
	FROM sys.dm_os_dispatcher_pools

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
		AND (c.OBJECT_NAME like '%cpu%'
			or o.description like '%processor%'
			--OR o.description LIKE '%request%'
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

DECLARE @EventName VARCHAR(64) = 'query_post_execution_showplan'
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

