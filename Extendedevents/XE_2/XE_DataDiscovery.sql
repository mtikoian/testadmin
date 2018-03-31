/* Is there an event session for the problem 
let's check parallelism
*/
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
		AND (c.OBJECT_NAME like '%parallel%'
			or o.description like '%parallel%'
			)
	ORDER BY o.package_guid;

/* Find events in a Channel */
SELECT v.map_value AS CHANNEL
		,c.object_name AS EventName
		,p.name AS PackageName
		,o.description AS EventDescription
	FROM sys.dm_xe_objects o
		INNER JOIN sys.dm_xe_object_columns c 
			ON o.name = c.object_name
			and o.package_guid = c.object_package_guid
		INNER JOIN sys.dm_xe_packages p
			ON o.package_guid = p.guid
		INNER JOIN sys.dm_xe_map_values v 
			ON c.type_name = v.name
			AND c.column_value = cast(v.map_key AS nvarchar)	
	WHERE object_type='event'
		AND c.name = 'channel'
		AND v.map_value = 'Debug'
	ORDER BY c.object_name;

/* what data is available in such an event 
check out the memory, # procs
*/
DECLARE @EventName VARCHAR(64) = 'perfobject_processor' --perfobject_processor --degree_of_parallelism
	,@ReadFlag VARCHAR(64) = 'readonly' --NULL if all columntypes are desired
 
SELECT oc.OBJECT_NAME AS EventName
		,oc.name AS column_name, oc.type_name
		,oc.column_type AS column_type
		,oc.column_value AS column_value
		,oc.description AS column_description 
	FROM sys.dm_xe_object_columns oc
	WHERE oc.OBJECT_NAME = @EventName
		AND oc.column_type <> @ReadFlag
	;

/* map values for the dop_statement_type
what is the data that would be returned to me ? */

SELECT oc.object_name as EventName,oc.name as ColName,mv.name as MapName, map_key, map_value 
	FROM sys.dm_xe_map_values mv
		Inner Join sys.dm_xe_object_columns oc
			on mv.name = oc.type_name
	WHERE oc.object_name = @EventName
		AND oc.column_type <> @ReadFlag;