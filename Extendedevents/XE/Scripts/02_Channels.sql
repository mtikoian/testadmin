SELECT DISTINCT v.map_value AS Channel
	FROM sys.dm_xe_object_columns c
		INNER JOIN sys.dm_xe_map_values v ON c.type_name = v.name
			AND c.column_value = cast(v.map_key AS nvarchar)
	WHERE c.name = 'channel';