SELECT te.trace_event_id,tc.name AS CategoryName
	, CASE tc.type
		WHEN 0 THEN 'Normal'
		WHEN 1 THEN 'Connection'
		WHEN 2 THEN 'ERROR'
		END AS TraceEventType
	,te.name AS TraceEventName
	, xem.package_name, xem.xe_event_name
FROM sys.trace_xe_event_map xem
	RIGHT OUTER JOIN sys.trace_events te
		ON te.trace_event_id = xem.trace_event_id
	INNER JOIN sys.trace_categories tc
		ON te.category_id = tc.category_id
ORDER BY tc.category_id,te.trace_event_id ASC;


SELECT *
	FROM sys.trace_xe_action_map