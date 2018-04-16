
 CREATE PROCEDURE dbo.ShowCompile
/**********************************************************************************************************************
 Purpose:
 Return the longest code compile times and related information from cache.
----------------------------------------------------------------------------------------------------------------------- 
 Programmers Notes:
 1. The "ShowLongString" function must be available in the current database.

----------------------------------------------------------------------------------------------------------------------- 
 Usage:
--===== Default usage returns 1000 rows.  Will take 10 minutes depending on the number of items in cache.
   EXEC dbo.ShowCompile
;
--===== Include the number of rows to return.  Still takes a fairly long time to return even with just 10 rows.
   EXEC dbo.ShowCompile 10
;
----------------------------------------------------------------------------------------------------------------------- 
 Revision History:
 Rev 00 - 16 Jul 2012 - Jonathan Kehayias - Initial Publication
        - Ref: https://www.sqlskills.com/blogs/jonathan/identifying-high-compile-time-statements-from-the-plan-cache/

 Rev 01 - 18 Jun 2016 - Jeff Moden
        - Modification to make the returned code easier to read and have more than 8k characters visible.
**********************************************************************************************************************/
--===== Define the I/O for this proc
        @pRows INT = 1000
     AS
--===== Enable dirty reads.
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
;
--===== Read the compile times and other information from cache.
  WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT TOP (@pRows)
        CompileTime_ms,
        CompileCPU_ms,
        CompileMemory_KB,
        qs.execution_count,
        qs.total_elapsed_time/1000 AS duration_ms,
        qs.total_worker_time/1000 AS cputime_ms,
        (qs.total_elapsed_time/qs.execution_count)/1000 AS avg_duration_ms,
        (qs.total_worker_time/qs.execution_count)/1000 AS avg_cputime_ms,
        qs.max_elapsed_time/1000 AS max_duration_ms,
        qs.max_worker_time/1000 AS max_cputime_ms,
        (--==== Returns the query snippet as clickable/format-preserved code (Rev 01)
         SELECT LongString 
           FROM dbo.ShowLongString(SUBSTRING(st.text,
                                             (qs.statement_start_offset / 2) + 1,
                                             (CASE qs.statement_end_offset
                                              WHEN -1 THEN DATALENGTH(st.text)
                                              ELSE qs.statement_end_offset
                                               END - qs.statement_start_offset) / 2 + 1))) AS StmtText,
        query_hash,
        query_plan_hash
   FROM (--==== Get's the compile time information
         SELECT c.value('xs:hexBinary(substring((@QueryHash)[1],3))', 'varbinary(max)') AS QueryHash,
                c.value('xs:hexBinary(substring((@QueryPlanHash)[1],3))', 'varbinary(max)') AS QueryPlanHash,
                c.value('(QueryPlan/@CompileTime)[1]', 'int') AS CompileTime_ms,
                c.value('(QueryPlan/@CompileCPU)[1]', 'int') AS CompileCPU_ms,
                c.value('(QueryPlan/@CompileMemory)[1]', 'int') AS CompileMemory_KB,
                qp.query_plan
           FROM sys.dm_exec_cached_plans AS cp
          CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
          CROSS APPLY qp.query_plan.nodes('ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS n(c)
        ) AS tab
   JOIN sys.dm_exec_query_stats AS qs
     ON tab.QueryHash = qs.query_hash
  CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
  ORDER BY CompileTime_ms DESC
 OPTION (RECOMPILE)
;