/* inaccurate_cardinality_estimate 
Occurs when an operator outputs significantly more rows than estimated by the Query Optimizer. 
Use this event to identify queries that may be using sub-optimal plans due to cardinality estimate inaccuracy. 
Using this event can have a significant performance overhead so it should only be used when troubleshooting or monitoring specific problems for brief periods of time.
*/
CREATE EVENT SESSION [QueryCardinality] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'AdventureWorks2012'))
    AND sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'),
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION (sqlserver.database_name,sqlserver.client_hostname,sqlserver.client_app_name,
            sqlserver.plan_handle,
            sqlserver.sql_text,
            sqlserver.tsql_stack,
            package0.callstack,
			sqlserver.query_hash,
			sqlserver.session_id,
            sqlserver.request_id)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'AdventureWorks2012')) 
    AND sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'),
ADD EVENT sqlserver.inaccurate_cardinality_estimate(
	WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'AdventureWorks2012'))
    AND sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense')
--ADD TARGET package0.event_file(SET filename=N'C:\XE\QueryCardinality.xel',max_file_size=(5120),max_rollover_files=(2)),
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY=5SECONDS, TRACK_CAUSALITY=ON)
GO

ALTER EVENT SESSION QueryCardinality 
ON SERVER 
STATE = START;
GO
/* Let's Take a Look at the Session Data */
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
            WHERE s.name = 'QueryCardinality'
              AND t.target_name = 'ring_buffer'
        ) AS tab
        CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS split(evnt) 
		CROSS APPLY evnt.nodes('(data[@name="showplan_xml"]/value)[last()]/*') AS showplan(xmlplan)
    ) AS evts(event_data,planxml);
    
/* Broad Strokes */
SELECT CAST(target_data AS xml) AS TargetData
    FROM sys.dm_xe_sessions AS s
    INNER JOIN sys.dm_xe_session_targets AS t
        ON s.address = t.event_session_address
    WHERE s.name = 'QueryCardinality'
      AND t.target_name = 'ring_buffer';

/* v2 */
	--events	
SELECT event_package=o.package_guid, o.description,
       event=c.object_name, channel=v.map_value,p.name as PackageName
FROM sys.dm_xe_objects o
       LEFT JOIN sys.dm_xe_object_columns c ON o.name = c.object_name
       INNER JOIN sys.dm_xe_map_values v ON c.type_name = v.name
              AND c.column_value = cast(v.map_key AS nvarchar)
		INNER JOIN sys.dm_xe_packages p
			on o.package_guid = p.guid
WHERE object_type='event' AND (c.name = 'channel' OR c.name IS NULL)
and o.description like '%cardin%'
/* inaccurate_cardinality_estimate 
Occurs when an operator outputs significantly more rows than estimated by the Query Optimizer. 
Use this event to identify queries that may be using sub-optimal plans due to cardinality estimate inaccuracy. 
Using this event can have a significant performance overhead so it should only be used when troubleshooting or monitoring specific problems for brief periods of time.
*/
CREATE EVENT SESSION [QueryCardinality] ON SERVER 
--ADD EVENT sqlserver.rpc_completed(
--    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'AdventureWorks2012'))
--    AND sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'),
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION (sqlserver.database_name,sqlserver.client_hostname,sqlserver.client_app_name,
            sqlserver.plan_handle,
            sqlserver.sql_text,
            sqlserver.tsql_stack,
            package0.callstack,
			sqlserver.query_hash,
			sqlserver.session_id,
            sqlserver.request_id)
    WHERE sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'),
ADD EVENT sqlserver.inaccurate_cardinality_estimate(
    ACTION (sqlserver.database_name,sqlserver.client_hostname,sqlserver.client_app_name,
            sqlserver.plan_handle,
            sqlserver.sql_text,
            sqlserver.tsql_stack,
            package0.callstack,
			sqlserver.query_hash,
			sqlserver.session_id,
            sqlserver.request_id)
	WHERE sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense')
--ADD TARGET package0.event_file(SET filename=N'C:\XE\QueryCardinality.xel',max_file_size=(5120),max_rollover_files=(2)),
ADD TARGET package0.ring_buffer
WITH (MAX_DISPATCH_LATENCY=5SECONDS, TRACK_CAUSALITY=ON)
GO

ALTER EVENT SESSION QueryCardinality 
ON SERVER 
STATE = START;
GO

ALTER EVENT SESSION QueryCardinality 
ON SERVER 
STATE = stop;
GO

drop event session QueryCardinality
on server
GO

/* UGLY QUERY */
USE AdventureWorks2014;
GO
SELECT e.[BusinessEntityID],
       p.[Title],
       p.[FirstName],
       p.[MiddleName],
       p.[LastName],
       p.[Suffix],
       e.[JobTitle],
       pp.[PhoneNumber],
       pnt.[Name] AS [PhoneNumberType],
       ea.[EmailAddress],
       p.[EmailPromotion],
       a.[AddressLine1],
       a.[AddressLine2],
       a.[City],
       sp.[Name] AS [StateProvinceName],
       a.[PostalCode],
       cr.[Name] AS [CountryRegionName],
       p.[AdditionalContactInfo]
FROM   [HumanResources].[Employee] AS e
       INNER JOIN [Person].[Person] AS p
       ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID]))
       INNER JOIN [Person].[BusinessEntityAddress] AS bea
       ON RTRIM(LTRIM(bea.[BusinessEntityID])) = RTRIM(LTRIM(e.[BusinessEntityID]))
       INNER JOIN [Person].[Address] AS a
       ON RTRIM(LTRIM(a.[AddressID])) = RTRIM(LTRIM(bea.[AddressID]))
       INNER JOIN [Person].[StateProvince] AS sp
       ON RTRIM(LTRIM(sp.[StateProvinceID])) = RTRIM(LTRIM(a.[StateProvinceID]))
       INNER JOIN [Person].[CountryRegion] AS cr
       ON RTRIM(LTRIM(cr.[CountryRegionCode])) = RTRIM(LTRIM(sp.[CountryRegionCode]))
       LEFT OUTER JOIN [Person].[PersonPhone] AS pp
       ON RTRIM(LTRIM(pp.BusinessEntityID)) = RTRIM(LTRIM(p.[BusinessEntityID]))
       LEFT OUTER JOIN [Person].[PhoneNumberType] AS pnt
       ON RTRIM(LTRIM(pp.[PhoneNumberTypeID])) = RTRIM(LTRIM(pnt.[PhoneNumberTypeID]))
       LEFT OUTER JOIN [Person].[EmailAddress] AS ea
       ON RTRIM(LTRIM(p.[BusinessEntityID])) = RTRIM(LTRIM(ea.[BusinessEntityID]))
OPTION(QUERYTRACEON 9481); --CE Version 70
--option(QUERYTRACEON 2312); --CE version 120
/* parse xml */
SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    CAST(event_data.value('(event/action[@name="plan_handle"]/value)[1]', 'varchar(max)') AS XML) as plan_handle,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text
	,event_data.value('(event/data[@name="estimated_rows"]/value)[1]','int') as EstimatedRows
	,event_data.value('(event/data[@name="actual_rows"]/value)[1]','int') as ActualRows
	,planxml.query('.') AS plan_xml
FROM(    SELECT evnt.query('.') AS event_data,xmlplan.query('.') AS event_plan
        FROM
        (    SELECT CAST(target_data AS xml) AS TargetData
            FROM sys.dm_xe_sessions AS s
            INNER JOIN sys.dm_xe_session_targets AS t
                ON s.address = t.event_session_address
            WHERE s.name = 'QueryCardinality'
              AND t.target_name = 'ring_buffer'
        ) AS tab
        CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS split(evnt) 
		CROSS APPLY evnt.nodes('(data[@name="showplan_xml"]/value)[last()]/*') AS showplan(xmlplan)
    ) AS evts(event_data,planxml)
WHERE event_data.value('(event/@name)[1]', 'varchar(50)') = 'query_post_execution_showplan'
	
Union ALL
SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    CAST(event_data.value('(event/action[@name="plan_handle"]/value)[1]', 'varchar(max)') AS XML) as plan_handle,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text
	,event_data.value('(event/data[@name="estimated_rows"]/value)[1]','int') as EstimatedRows
	,event_data.value('(event/data[@name="actual_rows"]/value)[1]','int') as ActualRows
	,'' AS plan_xml
FROM(    SELECT evnt.query('.') AS event_data--,xmlplan.query('.') AS event_plan
        FROM
        (    SELECT CAST(target_data AS xml) AS TargetData
            FROM sys.dm_xe_sessions AS s
            INNER JOIN sys.dm_xe_session_targets AS t
                ON s.address = t.event_session_address
            WHERE s.name = 'QueryCardinality'
              AND t.target_name = 'ring_buffer'
        ) AS tab
        CROSS APPLY TargetData.nodes ('RingBufferTarget/event') AS split(evnt) 
    ) AS evts(event_data)
WHERE event_data.value('(event/@name)[1]', 'varchar(50)') = 'inaccurate_cardinality_estimate';