	--events	
SELECT event_package=o.package_guid, o.description,
       event=c.object_name, channel=v.map_value
FROM sys.dm_xe_objects o
       LEFT JOIN sys.dm_xe_object_columns c ON o.name = c.object_name
       INNER JOIN sys.dm_xe_map_values v ON c.type_name = v.name
              AND c.column_value = cast(v.map_key AS nvarchar)
WHERE object_type='event' AND (c.name = 'channel' OR c.name IS NULL)