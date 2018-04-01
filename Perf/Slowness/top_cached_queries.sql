select top 20
	quotename(object_schema_name(t.objectid, t.dbid)) + '.' + quotename(object_name(t.objectid, t.dbid)) as obj_name,
	substring(t.text, qs.statement_start_offset / 2, case when qs.statement_end_offset = -1 then datalength(t.text) else (qs.statement_end_offset  - qs.statement_start_offset) / 2 end) as stmt_text,
	cast(p.query_plan as xml) as query_plan,
	cast(qs.execution_count * 1.0 / case when qs.creation_time < dateadd(second, -1, qs.last_execution_time) then datediff(second, qs.creation_time, qs.last_execution_time) else null end as decimal(28, 2)) as execution_count_per_second,
	qs.total_worker_time,
	qs.total_worker_time * 1.0 / sum(qs.total_worker_time) over () as pct_wrk_time,
	qs.total_elapsed_time,
	qs.total_elapsed_time * 1.0 / sum(qs.total_elapsed_time) over () as pct_elapsed_time,
	qs.execution_count,
	qs.total_worker_time / qs.execution_count as worker_time_per_exec,
	qs.*
from sys.dm_exec_query_stats as qs
cross apply sys.dm_exec_sql_text(qs.sql_handle) as t
cross apply sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) as p
order by qs.total_worker_time desc
