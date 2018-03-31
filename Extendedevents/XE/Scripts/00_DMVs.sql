SELECT name,create_date,is_ms_shipped
	FROM sys.system_views
	WHERE name LIKE '%dm_xe%'
		OR name LIKE '%server_event_s%'
		AND is_ms_shipped = 1