--Find saved execution plans of a proc 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT TOP 20
st.text AS [SQL]
, cp.cacheobjtype
, cp.objtype
,cp.plan_handle
, COALESCE(DB_NAME(st.dbid),
DB_NAME(CAST(pa.value AS INT))+'*',
'Resource') AS [DatabaseName]
, cp.usecounts AS [Plan usage]
, qp.query_plan
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) st
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) qp
OUTER APPLY sys.dm_exec_plan_attributes(cp.plan_handle) pa
WHERE pa.attribute = 'dbid'
AND st.text LIKE '%dw_AcctTotal_List_Dynamic%'  ---YourObjectName



SELECT cp.objtype AS ObjectType,
OBJECT_NAME(st.objectid,st.dbid) AS ObjectName,
cp.usecounts AS ExecutionCount,
cp.plan_handle,
st.TEXT AS QueryText,
qp.query_plan AS QueryPlan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
WHERE OBJECT_NAME(st.objectid,st.dbid) = 'dw_AcctTotal_List_Dynamic'---YourObjectName
--SQL2005 just alter procedure or use with recompile

declare @planHandle varbinary(64);
declare @CreateProcStmnt varchar(100);

set @CreateProcStmnt = '%sp_Position_List_Dynamic_Val2%';

SELECT  @planHandle = cp.plan_handle
FROM    sys.dm_exec_cached_plans AS cp
        CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
WHERE   st.[text] LIKE @CreateProcStmnt;
select @planHandle

--set @planHandle = rtrim(ltrim(@planHandle))

if (@planHandle is not null)
begin
   print 'Freeing plan cache ' + cast(@planHandle as varchar(100));
   DBCC FREEPROCCACHE(@planHandle);  --Works only 2008 or later versions
end
else
begin
   print 'Unable to find procedure';
end;
               

SET SHOWPLAN_XML on
SET STATISTICS IO  ON

/*Scan count 

This number tells us that the optimizer has chosen a plan that caused this object to be read repeatedly    This number is used as a gauge later on in the process and you will see what object it is being scanned when I go over the execution plan. This number does not change unless you alter the query.

Logical Reads 

This number tells us the actual number of pages read from the data cache.   This is the number to focus on because it does not change unless you change the actual query structure or index structures.  Most common changes are the joins within the WHERE clause, parameter values, or  index structures.

*/

-- Clear procedure from the cache
sp_recompile 'schema.ObjectName'
--exec dbo.MyProc @MyParam=MyValue WITH RECOMPILE;



set statistics io on
exec que_transfer_issueactivity 1298429, 996190, 1


DBCC SHOW_STATISTICS ('dbo.GP_BNCHMRK_INSTRUCT',PK_GP_BNCHMRK_INSTRUCT)


UPDATE STATISTICS dbo.GP_BNCHMRK_INSTRUCT
--Find Cache

;WITH CacheSums
As (SELECT 1 As OrderBy,
            objtype AS [CacheType]
        , count_big(*) AS [Total Plans]
        , sum(cast(size_in_bytes as decimal(12,2)))/1024/1024 AS [Total MBs]
        , avg(usecounts) AS [Avg Use Count]
        , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(12,2)))/1024/1024 AS [Total MBs - USE Count 1]
        , sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
      FROM sys.dm_exec_cached_plans
      GROUP BY objtype
      UNION ALL
      SELECT 2 AS OrderBy,
            'Total' AS [CacheType]
        , count_big(*) AS [Total Plans]
        , sum(cast(size_in_bytes as decimal(12,2)))/1024/1024 AS [Total MBs]
        , avg(usecounts) AS [Avg Use Count]
        , sum(cast((CASE WHEN usecounts = 1 THEN size_in_bytes ELSE 0 END) as decimal(12,2)))/1024/1024 AS [Total MBs - USE Count 1]
        , sum(CASE WHEN usecounts = 1 THEN 1 ELSE 0 END) AS [Total Plans - USE Count 1]
      FROM sys.dm_exec_cached_plans)
SELECT CacheType, [Total Plans], [Total MBs], [Avg Use Count], [Total MBs - USE Count 1]
FROM CacheSums
ORDER BY OrderBy, [Total MBs - USE Count 1] DESC
