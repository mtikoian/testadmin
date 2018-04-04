SELECT  db_name(cast(pa.value as int)),
		qp.query_plan,
		total_worker_time/execution_count AS [AVG CPU TIME],
        SUBSTRING(st.text, (
			qs.statement_start_offset/2)+1, (
				(
                   CASE qs.statement_end_offset
                            WHEN -1
                            THEN DATALENGTH(st.text)
                            ELSE qs.statement_end_offset
                   END - qs.statement_start_offset
				)/2
			) + 1
		) AS statement_text
FROM    sys.dm_exec_query_stats qs CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
		OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
		CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
WHERE	--db_name(cast(pa.value as int)) = 'SWIPROD' and
		pa.attribute = 'dbid'
ORDER BY total_worker_time/execution_count DESC;
