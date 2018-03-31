USE [AdventureWorks2014]
GO
    
CREATE PROCEDURE [dbo].[getSalesSalesOrderHeaderSlow]
    (@SalesPersonID int)
AS

SELECT SalesOrderID, CustomerID, SalesPersonID
FROM Sales.SalesOrderHeader
WHERE SalesPersonID = @SalesPersonID

WAITFOR DELAY '00:00:15'
GO

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name = 'AttentionEvent')
	DROP EVENT SESSION [AttentionEvent] ON SERVER
GO

CREATE EVENT SESSION [AttentionEvent] ON SERVER 
ADD EVENT sqlserver.attention(
    ACTION(
		sqlserver.client_app_name
		,sqlserver.client_hostname
		,sqlserver.database_id
		,sqlserver.database_name
		,sqlserver.is_system
		,sqlserver.plan_handle
		,sqlserver.sql_text
		,sqlserver.tsql_stack
		,sqlserver.username)
    WHERE ([sqlserver].[is_system]=(0) 
	AND [sqlserver].[database_id]>(4))) 
ADD TARGET package0.event_file(SET filename=N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\Log\AttentionEvent.xel'),
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS
,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [AttentionEvent] ON SERVER STATE = START
GO

EXEC [dbo].[getSalesSalesOrderHeader] 282