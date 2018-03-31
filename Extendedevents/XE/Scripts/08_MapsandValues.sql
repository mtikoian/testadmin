-- Maps
	SELECT p.name AS package_name,
	        o.name AS source_name,
	        o.description
	FROM sys.dm_xe_objects AS o
	JOIN sys.dm_xe_packages AS p
	      ON o.package_guid = p.guid
	WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
	   AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
	   AND o.object_type = 'map'
	
-- Map Values
	SELECT name, map_key, map_value 
	FROM sys.dm_xe_map_values
	WHERE name = 'wait_types'
		AND map_value NOT LIKE '%Padding%'
		AND map_value NOT LIKE '%Yukon%'
		AND map_value NOT LIKE '%testing%'
		AND map_value NOT LIKE '%holder%'
		AND map_value NOT IN (
			SELECT DISTINCT wait_type
				FROM sys.dm_os_wait_stats)
	Order by map_key