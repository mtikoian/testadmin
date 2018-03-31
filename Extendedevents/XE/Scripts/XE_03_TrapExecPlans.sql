/*
XE to trap actual exec plans
*/

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
WHERE sqlserver.database_id=9
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
USE AdventureWorks2012;
GO
EXECUTE AllFromT 1670000,1000
GO

EXECUTE AllFromT 500000,589
GO
 
-- Retrieve the Event Data from the Event Session Target

SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    CAST(event_data.value('(event/action[@name="plan_handle"]/value)[1]', 'varchar(max)') AS XML) as plan_handle,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text
	--,CAST(REPLACE(REPLACE(CAST(planxml.query('.') AS VARCHAR(MAX)),'<value>',''),'</value>','') AS XML) AS plan_xml
	,planxml.query('.') AS plan_xml
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

     

    
-- Use the plan_handle from one of the Events to get the query plan
DECLARE @plan_handle varbinary(64) = 0x06000800DD8D6D0840015585000000000000000000000000
SELECT * 
FROM sys.dm_exec_query_plan(@plan_handle)

--DROP EVENT SESSION TrapExecPlans
--ON SERVER
