
--Date: 10/15/2016
--Purpose: User Group Presentation @ Denver
--SQL Server: Microsoft SQL Server 2014 (RTM-CU14) (KB3158271) - 12.0.2569.0 (X64)  

--Check database compatibility level
USE [AdventureWorks2012];
GO
SELECT [name],
[compatibility_level]
FROM sys.[databases];

--Increased Correlation Assumption for Multiple Predicates
--Validating a Query’s Cardinality Estimator Version
--	1. Graphical Exec. plan 2. XML Exec. plan
/*
SET STATISTICS XML ON
*/
SET STATISTICS TIME,IO ON
GO
SELECT [AddressID],
[AddressLine1],
[AddressLine2]
FROM Person.[Address]
WHERE [StateProvinceID] = 9 AND
	  [City] = N'Burbank' AND
	  [PostalCode] = N'91502'
--OPTION (QUERYTRACEON 9481); -- CardinalityEstimationModelVersion 70
GO
SET STATISTICS TIME,IO OFF
GO

--EXEC sp_helpstats 'Person.[Address]'
--EXEC sp_helpindex 'Person.[Address]'

SELECT [s].[object_id],
[s].[name],
[s].[auto_created],
COL_NAME([s].[object_id], [sc].[column_id]) AS [col_name]
FROM sys.[stats] AS s
INNER JOIN sys.[stats_columns] AS [sc]
ON [s].[stats_id] = [sc].[stats_id] AND
[s].[object_id] = [sc].[object_id]
WHERE [s].[object_id] = OBJECT_ID('Person.Address');


DBCC SHOW_STATISTICS ('Person.Address', _WA_Sys_00000006_164452B1);		-- PostalCode
DBCC SHOW_STATISTICS ('Person.Address', IX_Address_StateProvinceID);	-- StateProvinceID
DBCC SHOW_STATISTICS ('Person.Address', _WA_Sys_00000004_164452B1);		-- City

/*
Selectivity = No.of rows statisfy by the condition / No.of rows in input
High selectivity (value close to 0, zero) -> less rows
Low selectivity  (value close to 1)       -> more rows

PostalCode (91502)		= 194 rows		<-- direct hit to the histogram
	Selectivity => (SELECT 194. / 19614)	= 0.009890
StateProvincedID (9)	= 4564 rows		<-- direct hit to the histogram
	Selectivity => (SELECT 4564. / 19614)	= 0.232690
City (Burbank)			= 196 rows       <-- direct hit to the histogram
	Selectivity => (SELECT 196. / 19614)	= 0.009992

Legacy CE model assumes no correlation between columns. Hence those are independence.
*/
--Table Cardinality = 19614
SELECT 0.009890 * 0.232690 * 0.009992 * 19614;
--Since the value is less than 1, Query Optimizer assumes estimated no.of rows as 1.

--============
--New CE model
--============

/*
Exponential back-off to calculate estimates for conjuntion of predicates.
Most selective predicates (p0) and followed by three most selective predicates
p0 * p1^1/2 * p2^1/4 * p3^1/8
*/

--Run the same query with new CE model
USE [AdventureWorks2012];
GO
SET STATISTICS TIME,IO ON
GO
SELECT [AddressID],
[AddressLine1],
[AddressLine2]
FROM Person.[Address]
WHERE [StateProvinceID] = 9 AND
[City] = N'Burbank' AND
[PostalCode] = N'91502'
OPTION (QUERYTRACEON 2312); -- CardinalityEstimationModelVersion 120
GO
SET STATISTICS TIME,IO OFF
GO

/*
Selectivity for each predicates is the same as above. 

Selectivity (PostalCode)		=> (SELECT 194. / 19614)	= 0.009890
Selectivity (StateProvincedID)	=> (SELECT 4564./ 19614)	= 0.232690
Selectivity (City)				=> (SELECT 196. / 19614)	= 0.009992

*/

--Calculate the cardinality estimation using exponential back-off method 
--Table Cardinality = 19614
SELECT 0.009890 * SQRT(0.009992) * SQRT(SQRT(0.232690)) * 19614; -- = 13.4673797102675

--So estimated no.of rows moved from 1 to ~13
