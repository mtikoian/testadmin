--http://www.sqlskills.com/blogs/jonathan/tracking-problematic-pages-splits-in-sql-server-2012-extended-events-no-really-this-time/

SELECT * FROM sys.dm_xe_map_values
WHERE name = 'log_op'
AND map_value IN ('LOP_DELETE_SPLIT')
ORDER BY 3

SELECT database_id 
FROM sys.databases 
WHERE name = 'AdventureWorks2014'

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name = 'ex_transaction_log_by_object')
	DROP EVENT SESSION ex_transaction_log_by_object ON SERVER
GO

CREATE EVENT SESSION ex_transaction_log_by_object ON SERVER
ADD EVENT sqlserver.transaction_log(
    WHERE operation = 11
    AND database_id = 15)
ADD TARGET package0.histogram(
    SET filtering_event_name = 'sqlserver.transaction_log'
        ,source_type = 0
        ,source = 'alloc_unit_id')
WITH (max_dispatch_latency = 5seconds)
GO

ALTER EVENT SESSION ex_transaction_log_by_object ON SERVER state = START
GO

USE AdventureWorks2014
GO

-- Query Target Data to get the top splitting objects in the database:
SELECT
    o.name AS table_name,
    i.name AS index_name,
    tab.split_count,
    i.fill_factor
FROM (    SELECT 
            n.value('(value)[1]', 'bigint') AS alloc_unit_id,
            n.value('(@count)[1]', 'bigint') AS split_count
        FROM
        (SELECT CAST(target_data as XML) target_data
         FROM sys.dm_xe_sessions AS s 
         JOIN sys.dm_xe_session_targets t
             ON s.address = t.event_session_address
         WHERE s.name = 'ex_transaction_log_by_object'
          AND t.target_name = 'histogram' ) as tab
        CROSS APPLY target_data.nodes('HistogramTarget/Slot') as q(n)
) AS tab
JOIN sys.allocation_units AS au
    ON tab.alloc_unit_id = au.allocation_unit_id
JOIN sys.partitions AS p
    ON au.container_id = p.partition_id
JOIN sys.indexes AS i
    ON p.object_id = i.object_id
        AND p.index_id = i.index_id
JOIN sys.objects AS o
    ON p.object_id = o.object_id
WHERE o.is_ms_shipped = 0;

