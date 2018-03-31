-- Event Columns
	SELECT oc.name AS column_name,
	        oc.column_type AS column_type,
	        oc.column_value AS column_value,
	        oc.description AS column_description
	FROM sys.dm_xe_packages AS p
	JOIN sys.dm_xe_objects AS o
	      ON p.guid = o.package_guid
	JOIN sys.dm_xe_object_columns AS oc
	      ON o.name = oc.OBJECT_NAME
	     AND o.package_guid = oc.object_package_guid
	WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
	   AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
	   AND (oc.capabilities IS NULL OR oc.capabilities & 1 = 0)
	   AND o.object_type = 'event'
	   AND o.name = 'wait_info'