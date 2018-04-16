WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT	TOP 100 DB_NAME(CAST(qpa.value AS INT)) DBName,
		OBJECT_NAME(qp.objectid) ObjectName,
		cis.n1.value('(./@EstimateRows)[1]','DECIMAL') RowsAffected,
		cis.n1.query('.') NodeText,
		qp.query_plan,
		qs.total_logical_reads / qs.execution_count avg_logical_reads
FROM	sys.dm_exec_query_stats qs
			CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
			CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
			CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) qpa
			CROSS APPLY qp.query_plan.nodes('//RelOp[@PhysicalOp="Clustered Index Scan"]') cis(n1)
WHERE	qpa.attribute = 'dbid'
		AND qp.query_plan.exist('//RelOp[@PhysicalOp="Clustered Index Scan"]') = 1
		--AND qpa.value = 'IBS_SSR'
ORDER BY qs.total_logical_reads / qs.execution_count DESC