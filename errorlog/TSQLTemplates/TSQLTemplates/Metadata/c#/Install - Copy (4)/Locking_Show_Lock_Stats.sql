SELECT	sess.session_id,
		sess.host_name,
		sess.program_name,
		tl.resource_type,
		tl.resource_subtype,
		resource_description,
		resource_associated_entity_id,
		request_mode,
		request_type,
		request_status
FROM	SYS.DM_TRAN_LOCKS tl
			JOIN sys.dm_exec_sessions sess
				ON tl.request_session_id = sess.session_id
WHERE	tl.resource_database_id = 8
		AND sess.program_name LIKE '2007 Microsoft%'
ORDER BY tl.resource_type, tl.resource_associated_entity_id

SELECT	sess.session_id,
		sess.host_name,
		sess.program_name,
		count(1) count_of_locks,
		tl.resource_type,
		tl.resource_subtype,
		request_mode,
		request_type,
		request_status
FROM	SYS.DM_TRAN_LOCKS tl
			JOIN sys.dm_exec_sessions sess
				ON tl.request_session_id = sess.session_id
WHERE	tl.resource_database_id = 8
		AND sess.program_name LIKE '2007 Microsoft%'
GROUP BY sess.session_id,sess.host_name,sess.program_name,tl.resource_type,tl.resource_subtype,tl.request_mode,tl.request_type,tl.request_status
ORDER BY tl.resource_type, tl.request_type


exec sp_whoisactive --@show_sleeping_spids = 2, 
					@get_locks = 1, 
					@output_column_list = '[dd%][login_name][host_name][program_name][tempdb_allocations][tempdb_current][status][wait_info][locks][sql_command][sql_text]',
					@filter_type = 'database',
					@filter = 'advisor_dev'