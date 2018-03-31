CREATE EVENT SESSION [SlowQueries] ON SERVER
ADD EVENT sqlserver.rpc_completed (
	ACTION ( package0.callstack, sqlserver.client_app_name,
	sqlserver.database_name, sqlserver.nt_username, sqlserver.query_hash,
	sqlserver.query_plan_hash, sqlserver.session_id, sqlserver.sql_text,
	sqlserver.tsql_stack )
	WHERE ( [sqlserver].[database_name] = 'AdventureWorks2014'
			AND [duration] > ( 25000000 )
			AND [sqlserver].[client_app_name] <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
			AND [sqlserver].[client_app_name] <> 'Red Gate Software Ltd SQL Prompt%'
			) ),
ADD EVENT sqlserver.sp_statement_completed ( SET collect_object_name = ( 1 )
	ACTION ( package0.callstack, sqlserver.client_app_name,
	sqlserver.database_name, sqlserver.nt_username, sqlserver.query_hash,
	sqlserver.query_plan_hash, sqlserver.session_id, sqlserver.sql_text,
	sqlserver.tsql_stack )
	WHERE ( [sqlserver].[database_name] = 'AdventureWorks2014'
			AND [duration] > ( 25000000 )
			AND [sqlserver].[client_app_name] <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
			AND [sqlserver].[client_app_name] <> 'Red Gate Software Ltd SQL Prompt%'
			) ),
ADD EVENT sqlserver.sql_batch_completed (
	ACTION ( package0.callstack, sqlserver.client_app_name,
	sqlserver.database_name, sqlserver.nt_username, sqlserver.query_hash,
	sqlserver.query_plan_hash, sqlserver.session_id, sqlserver.sql_text,
	sqlserver.tsql_stack )
	WHERE ( [sqlserver].[database_name] = 'AdventureWorks2014'
			AND [duration] > ( 25000000 )
			AND [sqlserver].[client_app_name] <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
			AND [sqlserver].[client_app_name] <> 'Red Gate Software Ltd SQL Prompt%'
			) ),
ADD EVENT sqlserver.sql_statement_completed (
	ACTION ( package0.callstack, sqlserver.client_app_name,
	sqlserver.database_name, sqlserver.nt_username, sqlserver.query_hash,
	sqlserver.query_plan_hash, sqlserver.session_id, sqlserver.sql_text,
	sqlserver.tsql_stack )
	WHERE ( [sqlserver].[database_name] = 'AdventureWorks2014'
			AND [duration] > ( 25000000 )
			AND [sqlserver].[client_app_name] <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
			AND [sqlserver].[client_app_name] <> 'Red Gate Software Ltd SQL Prompt%'
			) )
ADD TARGET package0.event_file ( SET filename = N'Z:\Database\XE\SlowQueries.xel' )
WITH ( MAX_MEMORY = 512000 KB
		, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
		, MAX_DISPATCH_LATENCY = 30 SECONDS
		, MAX_EVENT_SIZE = 0 KB
		, MEMORY_PARTITION_MODE = NONE
		, TRACK_CAUSALITY = OFF
		, STARTUP_STATE = OFF );
GO


