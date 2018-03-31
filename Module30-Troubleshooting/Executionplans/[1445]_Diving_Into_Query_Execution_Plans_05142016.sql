/*
	5/14/2016: Ed Pollack
	
	Diving into Query Excecution Plans

	This SQL provides query examples that are used to illustrate a variety of query execution
	plans and how to use this information to improve your ability to optimize queries and
	understand what is happening when a SQL statement is executed.
*/
USE AdventureWorks2012
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON 
SET NOCOUNT ON

/*****************************************************************************************************************
*********************************************Using Execution Plans************************************************
******************************************************************************************************************/
CREATE STATISTICS STATS_TEST_MODEL_NAME ON Production.ProductModel (Name)

DBCC SHOW_STATISTICS ("Production.ProductModel", STATS_TEST_MODEL_NAME)

-- The first example: a simple select from one table
SELECT
	TOP 1 *
FROM Production.ProductModel

-- Example of a query with more steps
SELECT
	*
FROM Production.Product PRODUCT
LEFT JOIN Production.UnitMeasure UNITS
ON PRODUCT.SizeUnitMeasureCode = UNITS.UnitMeasureCode
INNER JOIN Production.ProductModel MODEL
ON PRODUCT.ProductModelID = MODEL.ProductModelID
WHERE MODEL.Name LIKE 'C%'

-- Query execution plans that get too large to fit on the screen should be analyzed in sections, rather than as individual steps.
-- SQL Sentry Plan Explorer (or a similar free/paid tool) can greatly help with visualizing a large execution plan:
SELECT TOP 25
	*
FROM HumanResources.vJobCandidateEducation

DROP STATISTICS Production.ProductModel.STATS_TEST_MODEL_NAME

/*****************************************************************************************************************
*************************************************Table Access*****************************************************
******************************************************************************************************************/
-- This example shows a table scan on a heap
CREATE TABLE test_table
(	id INT,
	my_data VARCHAR(25),
	another_id INT)
INSERT INTO test_table (id, my_data, another_id) VALUES (1, '', 64)
INSERT INTO test_table (id, my_data, another_id) VALUES (2, 'some stuff', 121)
INSERT INTO test_table (id, my_data, another_id) VALUES (3, NULL, 1024)

SELECT
	my_data
FROM test_table
WHERE id = 2

DROP TABLE test_table

-- This example shows a clustered index scan:
SELECT
	TOP 1 *
FROM person.person

-- This example shows an index seek
SELECT
	CUSTOMER.CustomerID,
	CUSTOMER.AccountNumber
FROM sales.Customer CUSTOMER
WHERE CUSTOMER.AccountNumber LIKE 'AW0001%'

-- This is a query that illustrates a key lookup
SELECT
	NationalIDNumber,
	HireDate,
	MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = '14417807'
GO

-- To get rid of the key lookup, you can alter the query to retrieve different data...
-- ...or create a covering index that includes these columns:
CREATE NONCLUSTERED INDEX NCI_HumanResources_Employee_Covering ON HumanResources.Employee
(	NationalIDNumber	)
INCLUDE
(	HireDate, MaritalStatus)

-- Now we get an index scan and faster performance, BUT at the cost of adding an index.
SELECT
	NationalIDNumber,
	HireDate,
	MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = '14417807'
GO

-- Get rid of the type conversion by providing the input using the correct data type.
SELECT
	NationalIDNumber,
	HireDate,
	MaritalStatus
FROM HumanResources.Employee
WHERE NationalIDNumber = '14417807'
GO

DROP INDEX NCI_HumanResources_Employee_Covering ON HumanResources.Employee

/*****************************************************************************************************************
*****************************************************Joins********************************************************
******************************************************************************************************************/
/*
	Different data sets will be joined using one of three types of joins: MERGE JOIN, NESTED LOOP JOIN, and HASH JOIN.
	If the wrong join is used in a particular case, due to outdated statistics, missing indexes, or another problem,
	this could lead to very inefficient query execution.
*/

-- This is an example of a nested loops join.  
SELECT
	Employee.BusinessEntityID,
	Employee.HireDate,
	Person.AdditionalContactInfo
FROM HumanResources.Employee
INNER JOIN Person.Person
ON Employee.BusinessEntityID = Person.BusinessEntityID
--OPTION (MERGE JOIN)

-- This is an example of a hash join.  Since the UnitMeasure table is very small, it's efficient to create a hash table on
-- it and sort through the Product table using it.  Note that a worktable was created to handle the hash process.
SELECT
	Product.Name,
	product.ProductID,
	UnitMeasure.Name
FROM Production.Product
INNER JOIN production.UnitMeasure
ON Production.UnitMeasure.UnitMeasureCode = Product.SizeUnitMeasureCode

-- This is an example of a simple merge join.  Since both inputs of the join are sorted, they can be quickly lined up and
-- joined together without the need for any additional temporary storage or row-by-row work.  Note that no worktable is needed here.
SELECT
	*
FROM Production.ProductModel
LEFT JOIN Production.ProductModelIllustration
ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID -- These are both clustered indexes on each table.
WHERE ProductModel.Instructions IS NOT NULL

/*****************************************************************************************************************
************************************************Display Options***************************************************
******************************************************************************************************************/
SET SHOWPLAN_ALL ON
GO
SELECT
	*
FROM Production.ProductModel
LEFT JOIN Production.ProductModelIllustration
ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID -- These are both clustered indexes on each table.
WHERE ProductModel.Instructions IS NOT NULL
GO
SET SHOWPLAN_ALL OFF
GO

SET SHOWPLAN_TEXT ON
GO
SELECT
	*
FROM Production.ProductModel
LEFT JOIN Production.ProductModelIllustration
ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID -- These are both clustered indexes on each table.
WHERE ProductModel.Instructions IS NOT NULL
GO
SET SHOWPLAN_TEXT OFF
GO

SET STATISTICS PROFILE ON;
SELECT
	*
FROM Production.ProductModel
LEFT JOIN Production.ProductModelIllustration
ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID -- These are both clustered indexes on each table.
WHERE ProductModel.Instructions IS NOT NULL
SET STATISTICS PROFILE OFF;

SET STATISTICS IO ON;
SELECT
	*
FROM Production.ProductModel
LEFT JOIN Production.ProductModelIllustration
ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID -- These are both clustered indexes on each table.
WHERE ProductModel.Instructions IS NOT NULL

-- Trace only!
SET SHOWPLAN_XML ON
GO
SELECT
	*
FROM Production.ProductModel
LEFT JOIN Production.ProductModelIllustration
ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID -- These are both clustered indexes on each table.
WHERE ProductModel.Instructions IS NOT NULL
GO
SET SHOWPLAN_XML OFF
GO

-- Trace only!
SET STATISTICS XML ON;
SELECT
	*
FROM Production.ProductModel
LEFT JOIN Production.ProductModelIllustration
ON Production.ProductModelIllustration.ProductModelID = Production.ProductModel.ProductModelID -- These are both clustered indexes on each table.
WHERE ProductModel.Instructions IS NOT NULL
SET STATISTICS XML OFF;

/*****************************************************************************************************************
****************************************Insight Into Query Optimization*******************************************
******************************************************************************************************************/
/*	Information on the query plan cache can be accessed via a set of dynamic management views.  This allows you
	to view query text, execution plans, resources consumed, and more!
*/

SELECT TOP 20
	DB_NAME(qt.dbid) AS [Database_Name],
	SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
	((CASE qs.statement_end_offset
	WHEN -1 THEN DATALENGTH(qt.TEXT)
	ELSE qs.statement_end_offset
	END - qs.statement_start_offset)/2)+1) AS [Query_Text],
	qs.execution_count AS [Execution_Count],
	qs.total_logical_reads AS [Total_Logical_Reads],
	qs.last_logical_reads AS [Last_Logical_Reads],
	qs.total_logical_writes AS [Total_Logical_Writes],
	qs.last_logical_writes AS [Last_Logical_Writes],
	qs.total_worker_time AS [Total_Worker_Time],
	qs.last_worker_time AS [Last_Worker_Time],
	qs.total_elapsed_time/1000000 AS [Total_Elapsed_Time_In_S],
	qs.last_elapsed_time/1000000 AS [Last_Elapsed_Time_In_S],
	qs.last_execution_time AS [Last_Execution_Time],
	qp.query_plan AS [Query_Plan],
	tqp.query_plan AS [Text_Query_Plan],
	pa.*
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY sys.dm_exec_text_query_plan(qs.plan_handle, 0, -1) tqp
CROSS APPLY sys.dm_exec_plan_attributes (qs.plan_handle) pa
WHERE pa.attribute = 'hits_exec_context' -- Get # of times the plan was being used.
ORDER BY qs.total_logical_reads DESC -- logical reads
--ORDER BY qs.total_worker_time DESC -- CPU time
--ORDER BY qs.total_logical_writes DESC -- logical writes
--ORDER BY qs.execution_count DESC -- execution count

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

-- Search the plan cache for all execution plans that use a specific index
DECLARE @IndexName AS NVARCHAR(128) = 'AK_UnitMeasure_Name';

-- Make sure the name passed is appropriately quoted
IF (LEFT(@IndexName, 1) <> '[' AND RIGHT(@IndexName, 1) <> ']') SET @IndexName = QUOTENAME(@IndexName);
-- Handle the case where the left or right was quoted manually but not the opposite side
IF LEFT(@IndexName, 1) <> '[' SET @IndexName = '['+@IndexName;
IF RIGHT(@IndexName, 1) <> ']' SET @IndexName = @IndexName + ']';

-- Dig into the plan cache and find all plans using this index
;WITH XMLNAMESPACES
    (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')   
SELECT
stmt.value('(@StatementText)[1]', 'varchar(max)') AS SQL_Text,
obj.value('(@Database)[1]', 'varchar(128)') AS DatabaseName,
obj.value('(@Schema)[1]', 'varchar(128)') AS SchemaName,
obj.value('(@Table)[1]', 'varchar(128)') AS TableName,
obj.value('(@Index)[1]', 'varchar(128)') AS IndexName,
obj.value('(@IndexKind)[1]', 'varchar(128)') AS IndexKind,
cp.plan_handle,
query_plan
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS batch(stmt)
CROSS APPLY stmt.nodes('.//IndexScan/Object[@Index=sql:variable("@IndexName")]') AS idx(obj)
OPTION(MAXDOP 1, RECOMPILE);

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

/*	Search the plan cache based on specific query text
*/

select TOP 50
 bucketid,
 a.plan_handle,
 refcounts, 
 usecounts,
 execution_count,
 size_in_bytes,
 cacheobjtype,
 objtype,
 text,
 query_plan,
 creation_time,
 last_execution_time,
 execution_count,
 total_elapsed_time,
 last_elapsed_time
 from sys.dm_exec_cached_plans a 
       inner join sys.dm_exec_query_stats b on a.plan_handle=b.plan_handle
     cross apply sys.dm_exec_sql_text(b.sql_handle) as sql_text
     cross apply sys.dm_exec_query_plan(a.plan_handle) as query_plan
 where text like '%UnitMeasure.Name%'
 -- and a.plan_handle = 0x06000B00C96DEC2AB8A16D06000000000000000000000000
 -- and b.last_execution_time between '2009-09-24 09:00' and '2009-09-25 17:00'
 -- order by last_execution_time desc
 order by b.execution_count desc

--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------

/*	Recompiles can harm query performance as additional time and resources are being consumed in order to optimize
	a query each time this happens.
*/
-- Simple query to find the top queries being recompiled.
SELECT TOP 25
      sql_text.text,
      sql_handle,
      plan_generation_num,
      execution_count,
      dbid,
      objectid 
FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sql_text
WHERE plan_generation_num > 1 -- This is the number of times a query has been recompiled
ORDER BY plan_generation_num DESC

-- This clears the entire plan cache.  Never do this in production unless you truly mean it!
-- This removes all execution plans from memory, meaning that all queries going forward
-- will need to be optmized from scratch, which on a busy server can mean immense resource consumption for a while.
-- Can be used in a dev environment to test queries over and over with no interference from the query cache.
DBCC FREEPROCCACHE
