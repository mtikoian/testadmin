SELECT CAST(xst.target_data AS xml) b
FROM sys.dm_xe_session_targets xst
INNER JOIN sys.dm_xe_sessions xs ON xst.event_session_address = xs.address
WHERE xst.target_name = 'ring_buffer' and xs.name = 'latch_contention'
GO 

;WITH buckets
AS (
SELECT CAST(xst.target_data AS xml) b
FROM sys.dm_xe_session_targets xst
INNER JOIN sys.dm_xe_sessions xs ON xst.event_session_address = xs.address
WHERE xst.target_name = 'histogram' and xs.name = 'latch_contention'
)
,frames 
AS (
SELECT slots.value('@count', 'bigint') AS bucket_count
,slots.query('value/frames/.') AS tsql_stack
FROM buckets b
CROSS APPLY b.nodes('//HistogramTarget/Slot') as T(slots)
)
, levels
AS (
SELECT f.bucket_count
,col.value('@level','int') AS frame_level
,col.value('@handle','varchar(255)') AS handle
,col.value('xs:hexBinary(substring(@handle,3))','varbinary(255)') AS [sql_handle]
,col.value('@offsetStart','int') AS statement_start_offset
,col.value('@offsetEnd','int') AS statement_end_offset
FROM frames f
CROSS APPLY tsql_stack.nodes('//frames/frame') as tbl(col)
)
SELECT l.bucket_count
,l.frame_level
,DB_NAME(st.dbid) AS db_name
,OBJECT_SCHEMA_NAME(st.objectid, st.dbid) AS schema_name
,OBJECT_NAME(st.objectid, st.dbid) AS object_name
,l.sql_handle
,CAST('<?query --'+CHAR(13)+SUBSTRING(st.text, (l.statement_start_offset/2)+1, 
((CASE l.statement_end_offset
WHEN -1 THEN DATALENGTH(st.text)
ELSE l.statement_end_offset
END - l.statement_start_offset)/2) + 1)+CHAR(13)+'--?>' AS xml) as sql_statement
FROM levels l
CROSS APPLY sys.dm_exec_sql_text(l.sql_handle) st