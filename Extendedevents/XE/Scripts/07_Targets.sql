-- Targets
	SELECT p.name AS package_name,
	        o.name AS target_name,
	        o.description
	FROM sys.dm_xe_packages AS p
	JOIN sys.dm_xe_objects AS o ON p.guid = o.package_guid
	WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
	   AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
	   AND o.object_type = 'target'