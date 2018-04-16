USE TriggerDemo;
SET NOCOUNT ON;
GO




-- aggregate stats since last restart
SELECT 
  [trigger] = tr.name,
  tr.is_instead_of_trigger,
  [table] = s.name + N'.' + o.name,
  last_execution_time, 
  execution_count,
  max_elapsed_time, -- microseconds!
  max_logical_reads,
  avg_elapsed_time = ts.total_elapsed_time*1.0/execution_count 
FROM sys.dm_exec_trigger_stats AS ts
  INNER JOIN sys.triggers AS tr ON ts.[object_id] = tr.[object_id]
  INNER JOIN sys.objects  AS o ON tr.parent_id = o.[object_id]
  INNER JOIN sys.schemas AS s ON o.[schema_id] = s.[schema_id]
  WHERE ts.database_id = DB_ID()
  AND ts.[type] = N'TR' AND tr.is_disabled = 0;



-- sneak up on plans you can't capture directly

-- fishing in the plan cache
SELECT query_plan 
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS ph
INNER JOIN sys.triggers AS tr
ON ph.objectid = tr.[object_id]
INNER JOIN sys.tables AS t
ON tr.parent_id = t.[object_id]
WHERE t.name LIKE N'Table[_]%'--_Cursor'
AND t.[schema_id] = 1;  --dbo

-- extended events session
CREATE EVENT SESSION [TriggerStuff] 
ON SERVER 
ADD EVENT
 sqlserver.query_post_execution_showplan
(
    ACTION(sqlserver.sql_text)
    WHERE (object_type = N'TRIGGER' 
	AND source_database_id = 8
	)
)
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY = 1 SECONDS);
GO

ALTER EVENT SESSION TriggerStuff
ON SERVER STATE = START;
GO

-- don't forget to drop it
DROP EVENT SESSION [TriggerStuff] ON SERVER;
GO