SELECT	s.name SchemaName,
		o.name ObjectName,
		i.name IndexName,
		ips.avg_fragmentation_in_percent,
		ips.page_count,
		ips.forwarded_record_count
FROM	sys.dm_db_index_physical_stats(db_id(),null,null,null,'DETAILED') ips
			JOIN sys.indexes i 
				ON ips.index_id = i.index_id
				AND ips.object_id = i.object_id
			JOIN sys.objects o
				ON i.object_id = o.object_id
			JOIN sys.schemas s 
				ON o.schema_id = s.schema_id
				AND s.name <> 'SYS'
ORDER BY s.name, o.name