/*============================================================================
  File:     5c_Find_Plan.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2015, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


/*
	conversion from:
	http://sqlscope.wordpress.com/2013/10/20/query-hash-and-plan-hash-conversions/
*/

DECLARE @m BIGINT
SET @m = 0x8000000000000000

DECLARE @query_plan_hash DECIMAL(20,0)
SET @query_plan_hash = 14867181800548474191

SELECT *
FROM sys.dm_exec_query_stats
WHERE query_plan_hash = CASE 
	WHEN @query_plan_hash < CONVERT(DECIMAL(20,0),@m)*-1
	-- if topmost bit is not set convert to bigint and then convert to binary(8)
	THEN CONVERT(BINARY(8),CONVERT(BIGINT,@query_plan_hash))
	-- if topmost bit is set subtract topmost bit value, convert to bigint, set topmost bit and convert to binary(8)
	ELSE CONVERT(BINARY(8),CONVERT(BIGINT,@query_plan_hash - CONVERT(DECIMAL(20,0),@m)*-1)|@m)
	END

/*
	Use query_plan_hash from dm_exec_query_stats
*/
SELECT
	OBJECT_NAME([qp].[objectid],[qp].[dbid]),
    [qs].[sql_handle],
	[qs].[plan_handle],
	[qs].[query_hash],
	[qs].[query_plan_hash],
	[qs].[creation_time],
	[qs].[execution_count],
	(DATEDIFF(ms,[qs].[creation_time],GETDATE())/[qs].[execution_count]) [Executions/ms],
	[qs].[last_execution_time],
	[qs].[last_logical_reads],
	[qs].[last_worker_time],
	[qs].[min_logical_reads],
	[qs].[max_logical_reads],
	[qs].[min_worker_time],
	[qs].[max_worker_time],
	[qs].[min_rows],
	[qs].[max_rows],
	[qs].[total_logical_reads],
	[qs].[total_worker_time],
	[qp].[query_plan]
FROM [sys].[dm_exec_query_stats] [qs]
CROSS APPLY [sys].[dm_exec_query_plan]([qs].[plan_handle]) [qp]
WHERE [query_plan_hash] = 0xCE52D713F0D81D4F


USE [AdventureWorks2014];
GO

--Enable Actual Execution Plan
SET STATISTICS IO ON;

--Get ProductID for query with low duration
EXEC [Sales].[usp_GetProductInfo] <enterProductID>
--


--Get ProductID for query with high duration
EXEC [Sales].[usp_GetProductInfo] <enterProductID>
--


EXEC [Sales].[usp_GetProductInfo] <enterProductID> WITH RECOMPILE;


DBCC FREEPROCCACHE;


DBCC FREEPROCCACHE (<Enter_Really_Crazy_Long_Plan_Handle_That_You_Can_Never_Memorize_Here>)


SELECT ProductID, COUNT(*)
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY COUNT(*) DESC