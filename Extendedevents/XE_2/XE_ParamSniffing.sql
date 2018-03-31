/*
XE to trap actual exec plans
*/

-- put the AdventureWorks database id into the XE below
SELECT name, database_id FROM sys.databases WHERE name = 'AdventureWorks2014';
GO
-- Create the Event Session
IF EXISTS(SELECT * 
          FROM sys.server_event_sessions 
          WHERE name='TrapExecPlans')
    DROP EVENT SESSION TrapExecPlans 
    ON SERVER;
GO
CREATE EVENT SESSION TrapExecPlans
ON SERVER
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
/* The pre_execution_showplan event will trap estimated plan */
--ADD EVENT sqlserver.query_pre_execution_showplan,
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION (sqlserver.database_name,sqlserver.client_hostname,sqlserver.client_app_name,
            sqlserver.plan_handle,
            sqlserver.sql_text,
            sqlserver.tsql_stack,
            package0.callstack,
			sqlserver.query_hash,
			sqlserver.session_id,
            sqlserver.request_id)
 
--Change this to match the AdventureWorks, 
--AdventureWorks2008 or AdventureWorks2012 DB_ID()
WHERE sqlserver.database_id=8
	AND sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
)
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY=5SECONDS, TRACK_CAUSALITY=ON)
GO
 
-- Start the Event Session
ALTER EVENT SESSION TrapExecPlans 
ON SERVER 
STATE = START;
GO
 
-- Change database contexts and insert one row
USE AdventureWorks2014;
GO
EXECUTE AllFromT 1670000,1000
GO

EXECUTE AllFromT 500000,589
GO
 
/* Parameter Sniffing */ 
-- The column ParameterRuntimeValue is only available in actual execution plans when run by SSMS.
 
SET NOCOUNT ON; 
 
WITH XMLNAMESPACES   
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
    
  
SELECT query_plan, plan_handle,sql_handle,execution_count 
       ,n.value('(@ParameterCompiledValue)[1]', 'VARCHAR(50)') AS ParameterCompiledValue 
       ,n.value('(@ParameterRuntimeValue)[1]', 'VARCHAR(50)') AS ParameterRuntimeValue 
       ,ROW_NUMBER() OVER (PARTITION BY plan_handle ORDER BY (SELECT NULL)) AS ORowNum 
INTO #planeval 
FROM   
(  
   SELECT query_plan,plan_handle,sql_handle,execution_count 
 ,ROW_NUMBER() OVER (PARTITION BY plan_handle ORDER BY (SELECT NULL)) AS RowNum 
   FROM (     
           SELECT DISTINCT plan_handle,sql_handle,execution_count 
           FROM sys.dm_exec_query_stats 
         ) AS qs  
       OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) tp 
) AS tab (query_plan,plan_handle,sql_handle,execution_count,RowNum)  
CROSS APPLY query_plan.nodes('//StmtSimple/QueryPlan/ParameterList/ColumnReference') AS q(n)  
WHERE q.n.exist('//StmtSimple/QueryPlan/ParameterList/ColumnReference') = 1 
 --AND q.n.exist('(@ParameterRuntimeValue)[1]') = 1 
 AND RowNum = 1; 
 
SELECT  pe.query_plan,
        pe.plan_handle,
        pe.sql_handle,
        pe.execution_count,
        pe.ParameterCompiledValue,
        pe.ParameterRuntimeValue
FROM    #planeval pe
WHERE   ORowNum = 1; 
 
DROP TABLE #planeval;
GO


/*
Read from the XE session and the ringbuffer to query actual execution plans
*/
IF OBJECT_ID('tempdb.dbo.#plantemp','U') IS NOT NULL DROP TABLE dbo.#plantemp;
GO

SET NOCOUNT ON;


  
SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    CAST(event_data.value('(event/action[@name="plan_handle"]/value)[1]', 'varchar(max)') AS XML) as plan_handle,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text
	,event_data.value('(event/action[@name="database_name"]/value)[1]', 'varchar(max)') AS database_name
	,event_data.value('(event/action[@name="client_hostname"]/value)[1]', 'varchar(max)') AS client_hostname
	,event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'varchar(max)') AS client_app_name
	,event_data.value('(event/action[@name="query_hash"]/value)[1]', 'varchar(max)') AS query_hash
	,event_data.value('(event/action[@name="session_id"]/value)[1]', 'varchar(max)') AS session_id
	,planxml.query('.') AS plan_xml
INTO #plantemp
FROM(    SELECT evnt.query('.') AS event_data,xmlplan.query('.') AS event_plan
        FROM
        (    SELECT CAST(target_data AS xml) AS TargetData
            FROM sys.dm_xe_sessions AS s
            INNER JOIN sys.dm_xe_session_targets AS t
                ON s.address = t.event_session_address
            WHERE s.name = 'TrapExecPlans'
              AND t.target_name = 'ring_buffer'
        ) AS tab
        CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS split(evnt) 
		CROSS APPLY evnt.nodes('(data[@name="showplan_xml"]/value)[last()]/*') AS showplan(xmlplan)
    ) AS evts(event_data,planxml)
--	WHERE event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'varchar(max)') <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
;

WITH XMLNAMESPACES  
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')

SELECT event_name,pt.database_name,pt.client_hostname,pt.client_app_name,pt.query_hash,pt.session_id,plan_handle,sql_text,plan_xml
       ,n.value('(@ParameterCompiledValue)[1]', 'VARCHAR(50)') AS ParameterCompiledValue
       ,n.value('(@ParameterRuntimeValue)[1]', 'VARCHAR(50)') AS ParameterRuntimeValue
       --,ROW_NUMBER() OVER (PARTITION BY plan_handle ORDER BY (SELECT NULL)) AS ORowNum
FROM #plantemp pt
	CROSS APPLY plan_xml.nodes('//StmtSimple/QueryPlan/ParameterList/ColumnReference') AS q(n)

WHERE q.n.exist('//StmtSimple/QueryPlan/ParameterList/ColumnReference') = 1
	AND q.n.exist('(@ParameterRuntimeValue)[1]') = 1
	;


