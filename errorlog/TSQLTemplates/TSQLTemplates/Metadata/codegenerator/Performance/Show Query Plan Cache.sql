
 SELECT top (10) [cp].[refcounts]
,[cp].[usecounts]
,[cp].[objtype]
,[st].[dbid]
,[st].[objectid]
,[st].[text]
,[qp].[query_plan]
,cp.Plan_Handle
,qp.*
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle)
qp ;               
