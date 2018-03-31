-- Where clause

-- Comparison Predicates
	SELECT p.name AS package_name,
	        o.name AS source_name,
	        o.description
	FROM sys.dm_xe_objects AS o
	JOIN sys.dm_xe_packages AS p
	      ON o.package_guid = p.guid
	WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
	   AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
	   AND o.object_type = 'pred_compare'
	   
-- State Data Predicates
	SELECT p.name AS package_name,
	        o.name AS source_name,
	        o.description
	FROM sys.dm_xe_objects AS o
	JOIN sys.dm_xe_packages AS p
	      ON o.package_guid = p.guid
	WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)
	   AND (o.capabilities IS NULL OR o.capabilities & 1 = 0)
	   AND o.object_type = 'pred_source'