/*
Ever see an error like this??

The query processor ran out of internal resources and could not produce a query plan. 
This is a rare event and only expected for extremely complex queries or queries that 
reference a very large number of tables or partitions. Please simplify the query. 
If you believe you have received this message in error, 
contact Customer Support Services for more information.

Error 8623
Severity 16

*/

/* Find the very specific query(ies) that is causing the 8623 error */
/* filename path must be changed
sql 2012 the metadatafile is not required
*/
--Create an extended event session
CREATE EVENT SESSION
    overly_complex_queries
ON SERVER
ADD EVENT sqlserver.error_reported
(
    ACTION (package0.callstack,sqlserver.database_id,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE (([severity] = 16 or [severity] = 17)
		AND ([error_number] = 8623 or [error_number] = 8632)
		)
)
ADD TARGET package0.asynchronous_file_target
(set filename = 'C:\Database\XE\overly_complex_queries.xel' ,
    metadatafile = 'C:\Database\XE\overly_complex_queries.xem',
    max_file_size = 10,
    max_rollover_files = 5)
,
ADD TARGET package0.ring_buffer		-- Store events in the ring buffer target
	(set max_memory = 4096, max_events_limit = 10)
WITH (MAX_DISPATCH_LATENCY = 5SECONDS)
GO
 
-- Start the session
ALTER EVENT SESSION overly_complex_queries
    ON SERVER STATE = START
GO

/* connection pooling */
CREATE EVENT SESSION
    connection_pooling_reset
ON SERVER
ADD EVENT sqlserver.error_reported
(
    ACTION (sqlserver.sql_text, sqlserver.tsql_stack, sqlserver.database_id, sqlserver.username)
    WHERE ([severity] = 20
		AND [error_number] = 18056)
)
ADD TARGET package0.asynchronous_file_target
(set filename = 'C:\Database\XE\connection_pooling_reset.xel' ,
    metadatafile = 'C:\Database\XE\connection_pooling_reset.xem',
    max_file_size = 10,
    max_rollover_files = 5)
WITH (MAX_DISPATCH_LATENCY = 5SECONDS)
GO
 
-- Start the session
ALTER EVENT SESSION connection_pooling_reset
    ON SERVER STATE = START
GO

/* General find all failed queries */
--Create an extended event session
CREATE EVENT SESSION
    failed_queries
ON SERVER
ADD EVENT sqlserver.error_reported
(
    ACTION (sqlserver.sql_text, sqlserver.tsql_stack, sqlserver.database_id, sqlserver.username)
    WHERE ([severity]> 10
		)
)
ADD TARGET package0.asynchronous_file_target
(set filename = 'C:\Database\XE\failed_queries.xel' ,
    metadatafile = 'C:\Database\XE\failed_queries.xem',
    max_file_size = 5,
    max_rollover_files = 5)
WITH (MAX_DISPATCH_LATENCY = 5SECONDS)
GO
 
-- Start the session
ALTER EVENT SESSION failed_queries
    ON SERVER STATE = START
GO
