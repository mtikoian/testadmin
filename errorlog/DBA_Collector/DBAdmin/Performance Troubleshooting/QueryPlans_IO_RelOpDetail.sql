WITH	XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
		TopIOQuery AS
		(
			SELECT  TOP 10
			DB_NAME(CAST(qpa.value AS INT)) DBName,
			qs.total_logical_reads / qs.execution_count avg_logical_reads,
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
					 ) query_text,
					 qp.query_plan
			FROM	sys.dm_exec_query_stats qs
				CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
				CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
				CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) qpa
			WHERE	qpa.attribute = 'dbid' 
					AND qpa.value > 4
			ORDER BY qs.total_logical_reads / qs.execution_count DESC
		)
SELECT	t.DBName,
		t.avg_logical_reads,
		CAST('<q> ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(t.query_text,' OR ',' OR ' + CHAR(10)),' AND ',' AND ' + CHAR(10)),'&','&amp;'),'>','&gt;'),'<','&lt;') + ' </q>' AS XML) Query,
		t.query_text,
		RelOp.Col.value('(./@PhysicalOp)[1]','VARCHAR(200)') Operation,
		ISNULL(RelOp.Col.value('(.//Object[1]/@Schema)[1]','SYSNAME'),'tempdb.') + '.' + RelOp.Col.value('(.//Object[1]/@Table)[1]','SYSNAME') TableName,
		RelOp.Col.value('(./@EstimateRows)[1]','FLOAT') EstimatedRows,
		RelOp.Col.value('(./@EstimateCPU)[1]','FLOAT') EstimatedCPU,
		RelOp.Col.value('(./@EstimateIO)[1]','FLOAT') EstimatedIO,
		RelOp.Col.value('(./@EstimatedTotalSubtreeCost)[1]','FLOAT') EstimatedCost,
		RelOp.Col.query('./OutputList') OutputList,
		CAST('<p> ' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RelOp.Col.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]','VARCHAR(MAX)'),' OR ',' OR ' + CHAR(10)),' AND ',' AND ' + CHAR(10)),'&','&amp;'),'>','&gt;'),'<','&lt;') + ' </p>' AS XML) Predicate,
--		REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RelOp.Col.value('(./IndexScan/Predicate/ScalarOperator/@ScalarString)[1]','VARCHAR(MAX)'),' OR ',' OR ' + CHAR(10)),' AND ',' AND ' + CHAR(10)),'&','&amp;'),'>','&gt;'),'<','&lt;') + ' </p>' Predicate2,
		RelOp.Col.query('.') RelOpXML,
		t.query_plan QueryPlan
FROM	TopIOQuery t
			CROSS APPLY t.query_plan.nodes('//RelOp[@PhysicalOp="Clustered Index Scan"]') RelOp(col)
WHERE	RelOp.col.value('(.//Object/@Schema)[1]','SYSNAME') <> '[sys]'
ORDER BY avg_logical_reads DESC,query_text,EstimatedIO DESC