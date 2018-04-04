SELECT  TOP 10
		DB_NAME(CAST(qpa.value AS INT)) DBName,
		qs.total_logical_reads / qs.execution_count avg_logical_reads,
		qp.query_plan,
		tqp.query_plan,
		SUBSTRING(st.text, CASE
							WHEN qs.statement_start_offset IN (0,NULL) THEN 1
							ELSE qs.statement_start_offset/2 + 1 
						   END,
						   CASE 
							WHEN qs.statement_end_offset IN (0,-1,NULL) THEN LEN(st.text)
							ELSE qs.statement_end_offset/2
						   END - CASE
									WHEN qs.statement_start_offset IN (0, NULL) THEN 1
									ELSE qs.statement_start_offset/2 +1
							END
			      ) query_text
FROM	sys.dm_exec_query_stats qs
			CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
			CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
			CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) qpa
			CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle,qs.statement_start_offset,qs.statement_end_offset) tqp
WHERE	qpa.attribute = 'dbid' and qpa.value = DB_ID('D225_198')
ORDER BY qs.total_logical_reads / qs.execution_count DESC