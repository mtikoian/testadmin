select
	s.login_name
	,s.host_name
	,t.text
	,object_schema_name(t.objectid) + '.' + object_name(t.objectid) as object_name
	,substring(t.text, r.statement_start_offset / 2, case when r.statement_end_offset = -1 then len(t.text) else (r.statement_end_offset - r.statement_start_offset) / 2 end) as stmt
	,tsk.task_state
	,wt.wait_type
	,wt.wait_duration_ms
	,wt.resource_description
	,s.session_id
	,wt.blocking_session_id
	,bs.login_name
	,substring(bt.text, br.statement_start_offset / 2, case when br.statement_end_offset = -1 then len(bt.text) else (br.statement_end_offset - br.statement_start_offset) / 2 end) as blocking_stmt
	,object_schema_name(bt.objectid) + '.' + object_name(bt.objectid) as blocking_object_name
	,bs.login_name as blocking_login_name
	,cast(p.query_plan as xml) as query_plan
	,r.status
	,*
from sys.dm_exec_requests r
inner join sys.dm_exec_sessions as s on s.session_id = r.session_id
inner join sys.dm_os_tasks as tsk on tsk.session_id = r.session_id
left join sys.dm_os_waiting_tasks as wt on wt.waiting_task_address = tsk.task_address
left join sys.dm_exec_sessions as bs on bs.session_id = wt.blocking_session_id
left join sys.dm_exec_requests as br on br.session_id = bs.session_id
outer apply sys.dm_exec_sql_text(r.sql_handle) as t
outer apply sys.dm_exec_text_query_plan(r.plan_handle, r.statement_start_offset, r.statement_end_offset) as p
outer apply sys.dm_exec_sql_text(br.sql_handle) as bt
where
	r.session_id > 50;
