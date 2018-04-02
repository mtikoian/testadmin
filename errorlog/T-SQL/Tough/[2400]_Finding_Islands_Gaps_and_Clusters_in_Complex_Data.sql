/*	4/26/2017 Ed Pollack

	Finding Islands, Gaps, and Clusters in Complex Data

	This file contains a wide variety of TSQL demos ranging from review of grouping basics to some 
	complex uses of CTEs in order to answer difficult analystical questions.
*/
USE AdventureWorks2014;
SET NOCOUNT ON;
SET STATISTICS IO ON;
GO
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Structured/Inorganic Grouping-------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- First, let's create and populate a new table with some ficticious alerting data.  Each row
-- represents an alert that was thrown to the on-call person.
CREATE TABLE dbo.On_Call_Error_Log
(	On_Call_Error_Log_Id INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_On_Call_Error_Log PRIMARY KEY CLUSTERED,
	Error_Datetime DATETIME NOT NULL,
	Error_Source VARCHAR(50) NOT NULL,
	Error_Type VARCHAR(50) NOT NULL,
	Error_Description VARCHAR(100) NOT NULL,
	Error_Details VARCHAR(MAX) NOT NULL
)
GO

CREATE NONCLUSTERED INDEX IX_On_Call_Error_Log_Error_Datetime ON dbo.On_Call_Error_Log (Error_Datetime);
GO

INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 01:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 00:55:00, 00:56:00, 00:57:00, 00:58:00, 00:59:00, and 01:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 03:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 02:55:00, 02:56:00, 02:57:00, 02:58:00, 02:59:00, and 03:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 04:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 03:55:00, 03:56:00, 03:57:00, 03:58:00, 03:59:00, and 04:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 06:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 05:55:00, 05:56:00, 05:57:00, 05:58:00, 05:59:00, and 06:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 07:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 06:55:00, 06:56:00, 06:57:00, 06:58:00, 06:59:00, and 07:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 05:54:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 05:53:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 05:55:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Agent Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 05:54:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 05:56:00' AS Error_Datetime, 'SQLApplication01' AS Error_Source, 'Application Database AppDB01 Unavailable' AS Error_Type, 'Connection to AppDB01 failed' AS Error_Description, 'Connection to AppDB01 failed at 05:55:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/14/2016 06:00:00' AS Error_Datetime, 'Application01' AS Error_Source, 'Application Entering Standby Mode' AS Error_Type, 'Connections failed to SQLApplication01.AppDB01' AS Error_Description, 'Connections to AppDB01 failed at 05:55:00, 05:56:00, 05:57:00, 05:58:00, 05:59:00, 06:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/20/2016 01:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 00:55:00, 00:56:00, 00:57:00, 00:58:00, 00:59:00, and 01:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/21/2016 22:00:00' AS Error_Datetime, 'FileServer02' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to FileServer02' AS Error_Description, 'Connection to FileServer02 failed at 22:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/25/2016 20:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 20:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/25/2016 21:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 21:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/25/2016 22:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 22:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/27/2016 04:00:00' AS Error_Datetime, 'ETLServer' AS Error_Source, 'ETL Process Failed' AS Error_Type, 'ETL process failed on step 2' AS Error_Description, 'PK violation on ETL_Target_Table at 04:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/23/2016 05:55:00' AS Error_Datetime, 'SQLSalesData01' AS Error_Source, 'Service Unavailable' AS Error_Type, 'SQL Server service SQLSalesData01 has unexpectedly stopped.' AS Error_Description, 'SQL Server service SQLSalesData01 unexpectedly stopped at 05:55.  Service restart failed.  Restart will be attempted in 5 mintutes.' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/23/2016 06:00:00' AS Error_Datetime, 'ReportServer' AS Error_Source, 'Report Data Load Failed' AS Error_Type, 'Data load by "Sales Data Daily Warehouse Load" Failed' AS Error_Description, 'Failed connection to replicated data source SQLSalesData01 at 06:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/23/2016 08:30:00' AS Error_Datetime, 'ReportServer' AS Error_Source, 'Report Unable to Complete' AS Error_Type, 'Report "Daily Sales Data Summary Report" failed to complete.' AS Error_Description, 'Incomplete Data load by "Sales Data Daily Warehouse Load" resulted in missing data.  Rerun data load to resolve.' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/23/2016 08:35:00' AS Error_Datetime, 'ReportServer' AS Error_Source, 'Report Unable to Complete' AS Error_Type, 'Report "Daily Sales Data Detail Report" failed to complete.' AS Error_Description, 'Incomplete Data load by "Sales Data Daily Warehouse Load" resulted in missing data.  Rerun data load to resolve.' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/29/2016 05:54:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 05:53:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/29/2016 05:55:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Agent Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 05:54:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/29/2016 05:56:00' AS Error_Datetime, 'SQLApplication01' AS Error_Source, 'Application Database AppDB01 Unavailable' AS Error_Type, 'Connection to AppDB01 failed' AS Error_Description, 'Connection to AppDB01 failed at 05:55:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/29/2016 06:00:00' AS Error_Datetime, 'Application01' AS Error_Source, 'Application Entering Standby Mode' AS Error_Type, 'Connections failed to SQLApplication01.AppDB01' AS Error_Description, 'Connections to AppDB01 failed at 05:55:00, 05:56:00, 05:57:00, 05:58:00, 05:59:00, 06:00:00' AS Error_Details;
GO
-- Look at our error log data:
SELECT
	*
FROM dbo.On_Call_Error_Log
ORDER BY On_Call_Error_Log.Error_Datetime;
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Structured/Inorganic Grouping-------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------ERROR LOG DATA----------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- Group error log data by date:
SELECT
	CAST(On_Call_Error_Log.Error_Datetime AS DATE) AS Error_date,
	COUNT(*) AS Error_Count
FROM dbo.On_Call_Error_Log
GROUP BY CAST(On_Call_Error_Log.Error_Datetime AS DATE)
ORDER BY CAST(On_Call_Error_Log.Error_Datetime AS DATE) ASC;
-- Group error log data by date and hour:
SELECT
	CAST(On_Call_Error_Log.Error_Datetime AS DATE) AS Error_date,
	DATEPART(HOUR, On_Call_Error_Log.Error_Datetime) AS Error_Hour,
	COUNT(*) AS Error_Count
FROM dbo.On_Call_Error_Log
GROUP BY CAST(On_Call_Error_Log.Error_Datetime AS DATE), DATEPART(HOUR, On_Call_Error_Log.Error_Datetime)
ORDER BY CAST(On_Call_Error_Log.Error_Datetime AS DATE), DATEPART(HOUR, On_Call_Error_Log.Error_Datetime);
GO
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------SALES DATA--------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
USE AdventureWorks2014;
GO

-- Sales totals per day for a given year:
SELECT
	OrderDate,
	SUM(SubTotal) AS Daily_Order_Total
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2011-05-31' AND '2012-05-30'
GROUP BY OrderDate
ORDER BY OrderDate ASC;
GO
-- Sales totals per day for a given year---but only when total sales were very low (under 10k):
-- 41 out of 363 rows on my copy of AdventureWorks
SELECT
	OrderDate,
	SUM(SubTotal) AS Daily_Order_Total
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2011-05-31' AND '2012-05-30'
GROUP BY OrderDate
HAVING SUM(SubTotal) < 10000
ORDER BY OrderDate ASC;
GO
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------BASIC GAPS/ISLANDS ANALYSIS---------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- Add/remove data to our monitoring table with intentional gaps in it
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/12/2016 07:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 07:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/12/2016 08:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 08:00:00' AS Error_Details;
GO
DELETE FROM dbo.On_Call_Error_Log WHERE CAST(On_Call_Error_Log.Error_Datetime AS DATE) = '7/12/2016';
GO
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/12/2016 07:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 07:00:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/12/2016 08:00:00' AS Error_Datetime, 'PrintServer' AS Error_Source, 'Device Unavailable' AS Error_Type, 'Failed connection to PrintServer' AS Error_Description, 'Connections to PrintServer failed at 08:00:00' AS Error_Details;
GO
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 09:54:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 09:53:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 09:55:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Agent Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 09:54:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 09:56:00' AS Error_Datetime, 'SQLApplication01' AS Error_Source, 'Application Database AppDB01 Unavailable' AS Error_Type, 'Connection to AppDB01 failed' AS Error_Description, 'Connection to AppDB01 failed at 09:55:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 10:00:00' AS Error_Datetime, 'Application01' AS Error_Source, 'Application Entering Standby Mode' AS Error_Type, 'Connections failed to SQLApplication01.AppDB01' AS Error_Description, 'Connections to AppDB01 failed at 09:55:00, 09:56:00, 09:57:00, 09:58:00, 09:59:00, 10:00:00' AS Error_Details;
GO
DELETE FROM dbo.On_Call_Error_Log WHERE CAST(On_Call_Error_Log.Error_Datetime AS DATE) = '7/09/2016';
GO
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 09:54:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 09:53:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 09:55:00' AS Error_Datetime, 'SQLServer01' AS Error_Source, 'SQL Server Agent Unavailable' AS Error_Type, 'Failed connection to SQLServer01' AS Error_Description, 'Connection to SQLServer01 failed at 09:54:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 09:56:00' AS Error_Datetime, 'SQLApplication01' AS Error_Source, 'Application Database AppDB01 Unavailable' AS Error_Type, 'Connection to AppDB01 failed' AS Error_Description, 'Connection to AppDB01 failed at 09:55:00' AS Error_Details;
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/9/2016 10:00:00' AS Error_Datetime, 'Application01' AS Error_Source, 'Application Entering Standby Mode' AS Error_Type, 'Connections failed to SQLApplication01.AppDB01' AS Error_Description, 'Connections to AppDB01 failed at 09:55:00, 09:56:00, 09:57:00, 09:58:00, 09:59:00, 10:00:00' AS Error_Details;
GO
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/6/2016 04:00:00' AS Error_Datetime, 'ETLServer' AS Error_Source, 'ETL Process Failed' AS Error_Type, 'ETL process failed on step 2' AS Error_Description, 'PK violation on ETL_Target_Table at 06:00:00' AS Error_Details;
DELETE FROM dbo.On_Call_Error_Log WHERE CAST(On_Call_Error_Log.Error_Datetime AS DATE) = '7/06/2016';
GO
INSERT INTO dbo.On_Call_Error_Log (Error_Datetime, Error_Source, Error_Type, Error_Description, Error_Details)
SELECT '7/6/2016 04:00:00' AS Error_Datetime, 'ETLServer' AS Error_Source, 'ETL Process Failed' AS Error_Type, 'ETL process failed on step 2' AS Error_Description, 'PK violation on ETL_Target_Table at 06:00:00' AS Error_Details;
GO
-- Now our data has gaps in the PK, since we deleted and inserted a handful of rows in sequence.
SELECT * FROM dbo.On_Call_Error_Log;
GO
-- How can we quickly identify gaps (ie missing PK values) within our data:
-- Using NOT EXISTS to determine the start of gaps
-- Checks to see if a consecutive value exists after the current one.  If not, begin a gap.
SELECT
	GAP_START.On_Call_Error_Log_Id + 1
FROM dbo.On_Call_Error_Log GAP_START
WHERE NOT EXISTS (
	SELECT * FROM dbo.On_Call_Error_Log NEXT_ID
	WHERE NEXT_ID.On_Call_Error_Log_Id = GAP_START.On_Call_Error_Log_Id + 1)
AND GAP_START.On_Call_Error_Log_Id <> (SELECT MAX(On_Call_Error_Log_Id) FROM dbo.On_Call_Error_Log)
ORDER BY GAP_START.On_Call_Error_Log_Id ASC;

-- Add in gap ending ID:
SELECT
	On_Call_Error_Log_Id + 1 AS Current_Gap_ID,
	(SELECT MIN(B.On_Call_Error_Log_Id)
	 FROM dbo.On_Call_Error_Log AS B
	  WHERE B.On_Call_Error_Log_Id > A.On_Call_Error_Log_Id) - 1 AS Next_Gap_Id
FROM dbo.On_Call_Error_Log AS A
WHERE NOT EXISTS (
    SELECT *
    FROM dbo.On_Call_Error_Log AS B
    WHERE B.On_Call_Error_Log_Id = A.On_Call_Error_Log_Id + 1) AND
        On_Call_Error_Log_Id < (SELECT MAX(On_Call_Error_Log_Id) 
                 FROM dbo.On_Call_Error_Log B)
ORDER BY Current_Gap_ID ASC;

-- Self-join using basic row number CTE
WITH CTE_GAPS AS
(   SELECT
		On_Call_Error_Log_Id, 
		ROW_NUMBER() OVER(ORDER BY On_Call_Error_Log_Id ASC) AS Row_Num
    FROM dbo.On_Call_Error_Log)
SELECT
	Starting_Points.On_Call_Error_Log_Id + 1 AS Gap_Starting_Id,
	Ending_Points.On_Call_Error_Log_Id - 1 AS Gap_Ending_Id
FROM CTE_GAPS AS Starting_Points
INNER JOIN CTE_GAPS AS Ending_Points
ON Ending_Points.Row_Num = Starting_Points.Row_Num + 1
WHERE Ending_Points.On_Call_Error_Log_Id - Starting_Points.On_Call_Error_Log_Id > 1;

-- Similar query, but using a CTE with nested subquery.
WITH CTE_GAPS AS (
	SELECT
		On_Call_Error_Log_Id AS Current_Gap_ID,
		(SELECT MIN(Gap_Start_ID.On_Call_Error_Log_Id)
		 FROM dbo.On_Call_Error_Log AS Gap_Start_ID
		 WHERE Gap_Start_ID.On_Call_Error_Log_Id > On_Call_Error_Log.On_Call_Error_Log_Id) AS Next_Gap_Id
	FROM dbo.On_Call_Error_Log
)
SELECT
	Starting_Gap_ID = Current_Gap_ID + 1,
	End_Gap_ID = Next_Gap_Id - 1
FROM CTE_GAPS
WHERE CTE_GAPS.Next_Gap_Id - CTE_GAPS.Current_Gap_ID > 1
ORDER BY Current_Gap_ID ASC;

-- Identifying islands is similar.
-- This uses a CTE with row number comparison
WITH CTE_ISLANDS AS (
    SELECT
		On_Call_Error_Log_Id,
		On_Call_Error_Log_Id - ROW_NUMBER() OVER (ORDER BY On_Call_Error_Log_Id ASC) AS Row_Num
    FROM dbo.On_Call_Error_Log
)
SELECT
	Island_Starting_Id = MIN(CTE_ISLANDS.On_Call_Error_Log_Id),
	Island_Ending_Id = MAX(CTE_ISLANDS.On_Call_Error_Log_Id)
FROM CTE_ISLANDS
GROUP BY CTE_ISLANDS.Row_Num;

-- DENSE_RANK can also be used for identical results/performance
WITH CTE_ISLANDS AS (
    SELECT
		On_Call_Error_Log_Id,
		On_Call_Error_Log_Id - DENSE_RANK() OVER (ORDER BY On_Call_Error_Log_Id ASC) AS Row_Num
    FROM dbo.On_Call_Error_Log
)
SELECT
	Island_Starting_Id = MIN(CTE_ISLANDS.On_Call_Error_Log_Id),
	Island_Ending_Id = MAX(CTE_ISLANDS.On_Call_Error_Log_Id)
FROM CTE_ISLANDS
GROUP BY CTE_ISLANDS.Row_Num;

-- The following syntax is a bit more intuitive, and allows for the problem to be broken into distinct parts:
WITH ISLAND_START AS
(
    SELECT
		Starting_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Starting_IDs.On_Call_Error_Log_Id ASC) AS Row_Num
    FROM dbo.On_Call_Error_Log Starting_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Next_ID
        WHERE Next_ID.On_Call_Error_Log_Id = Starting_IDs.On_Call_Error_Log_Id - 1)
),
ISLAND_END AS
(
    SELECT
		Ending_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Ending_IDs.On_Call_Error_Log_Id ASC) AS Row_Num
    FROM dbo.On_Call_Error_Log Ending_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Previous_ID
        WHERE Previous_ID.On_Call_Error_Log_Id = Ending_IDs.On_Call_Error_Log_Id + 1)
)
SELECT
	ISLAND_START.On_Call_Error_Log_Id AS Island_Starting_Id,
	ISLAND_END.On_Call_Error_Log_Id AS Island_Ending_Id
FROM ISLAND_START
INNER JOIN ISLAND_END
ON ISLAND_END.Row_Num = ISLAND_START.Row_Num;
-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------------DATA CLUSTERS----------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
-- Take data and group into events, incidents, or streaks without applying rigid guidelines.
-- Rule #1: All errors that occur within 30 MINUTES of each other are related:
WITH ISLAND_START AS
(
    SELECT
		Starting_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Starting_IDs.Error_Datetime ASC, Starting_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Starting_IDs.Error_Datetime,
		Starting_IDs.Error_Source,
		Starting_IDs.Error_Type,
		Starting_IDs.Error_Description,
		Starting_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Starting_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Previous_Id
        WHERE Previous_Id.Error_Datetime >= DATEADD(MINUTE, -30, Starting_IDs.Error_Datetime)
		AND Previous_Id.Error_Datetime < Starting_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Starting_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Starting_IDs.On_Call_Error_Log_Id)
),
ISLAND_END AS
(
    SELECT
		Ending_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Ending_IDs.Error_Datetime ASC, Ending_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Ending_IDs.Error_Datetime,
		Ending_IDs.Error_Source,
		Ending_IDs.Error_Type,
		Ending_IDs.Error_Description,
		Ending_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Ending_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Next_Id
        WHERE Next_Id.Error_Datetime <= DATEADD(MINUTE, 30, Ending_IDs.Error_Datetime)
		AND Next_Id.Error_Datetime > Ending_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Ending_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Ending_IDs.On_Call_Error_Log_Id)
)
SELECT
	ISLAND_START.Error_Datetime AS Island_Starting_Time,
	ISLAND_END.Error_Datetime AS Island_Ending_Time,
	(SELECT COUNT(*) FROM dbo.On_Call_Error_Log Error_Count WHERE Error_Count.Error_Datetime >= ISLAND_START.Error_Datetime AND Error_Count.Error_Datetime <= ISLAND_END.Error_Datetime) AS Error_Count
FROM ISLAND_START
INNER JOIN ISLAND_END
ON ISLAND_START.Row_Num = ISLAND_END.Row_Num
ORDER BY ISLAND_START.Error_Datetime;

-- Rule #2: All errors that occur within 60 MINUTES of each other are related:
WITH ISLAND_START AS
(
    SELECT
		Starting_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Starting_IDs.Error_Datetime ASC, Starting_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Starting_IDs.Error_Datetime,
		Starting_IDs.Error_Source,
		Starting_IDs.Error_Type,
		Starting_IDs.Error_Description,
		Starting_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Starting_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Previous_Id
        WHERE Previous_Id.Error_Datetime >= DATEADD(MINUTE, -30, Starting_IDs.Error_Datetime)
		AND Previous_Id.Error_Datetime < Starting_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Starting_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Starting_IDs.On_Call_Error_Log_Id)
),
ISLAND_END AS
(
    SELECT
		Ending_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Ending_IDs.Error_Datetime ASC, Ending_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Ending_IDs.Error_Datetime,
		Ending_IDs.Error_Source,
		Ending_IDs.Error_Type,
		Ending_IDs.Error_Description,
		Ending_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Ending_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Next_Id
        WHERE Next_Id.Error_Datetime <= DATEADD(MINUTE, 30, Ending_IDs.Error_Datetime)
		AND Next_Id.Error_Datetime > Ending_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Ending_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Ending_IDs.On_Call_Error_Log_Id)
)
SELECT
	ISLAND_START.Error_Datetime AS Island_Starting_Time,
	ISLAND_END.Error_Datetime AS Island_Ending_Time,
	(SELECT COUNT(*) FROM dbo.On_Call_Error_Log Error_Count WHERE Error_Count.Error_Datetime >= ISLAND_START.Error_Datetime AND Error_Count.Error_Datetime <= ISLAND_END.Error_Datetime) AS Error_Count
FROM ISLAND_START
INNER JOIN ISLAND_END
ON ISLAND_START.Row_Num = ISLAND_END.Row_Num
ORDER BY ISLAND_START.Error_Datetime;

-- Rule #3: All errors that occur within 60 MINUTES of each other and for the SAME SERVER are related:
WITH ISLAND_START AS
(
    SELECT
		Starting_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Starting_IDs.Error_Datetime ASC, Starting_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Starting_IDs.Error_Datetime,
		Starting_IDs.Error_Source,
		Starting_IDs.Error_Type,
		Starting_IDs.Error_Description,
		Starting_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Starting_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Previous_Id
        WHERE Previous_Id.Error_Datetime >= DATEADD(MINUTE, -60, Starting_IDs.Error_Datetime)
		AND Starting_IDs.Error_Source = Previous_Id.Error_Source
		AND Previous_Id.Error_Datetime < Starting_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Starting_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Starting_IDs.On_Call_Error_Log_Id
																AND DUPLICATE_TIMES.Error_Source = Starting_IDs.Error_Source)
),
ISLAND_END AS
(
    SELECT
		Ending_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Ending_IDs.Error_Datetime ASC, Ending_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Ending_IDs.Error_Datetime,
		Ending_IDs.Error_Source,
		Ending_IDs.Error_Type,
		Ending_IDs.Error_Description,
		Ending_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Ending_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Next_Id
        WHERE Next_Id.Error_Datetime <= DATEADD(MINUTE, 60, Ending_IDs.Error_Datetime)
		AND Next_Id.Error_Source = Ending_IDs.Error_Source
		AND Next_Id.Error_Datetime > Ending_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Ending_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Ending_IDs.On_Call_Error_Log_Id
																AND DUPLICATE_TIMES.Error_Source = Ending_IDs.Error_Source)
)
SELECT
	ISLAND_START.Error_Datetime AS Island_Starting_Time,
	ISLAND_END.Error_Datetime AS Island_Ending_Time,
	ISLAND_START.Error_Source,
	(SELECT COUNT(*) FROM dbo.On_Call_Error_Log Error_Count WHERE Error_Count.Error_Datetime >= ISLAND_START.Error_Datetime AND Error_Count.Error_Datetime <= ISLAND_END.Error_Datetime) AS Error_Count
FROM ISLAND_START
INNER JOIN ISLAND_END
ON ISLAND_START.Row_Num = ISLAND_END.Row_Num
ORDER BY ISLAND_START.Error_Datetime;

-- Rule #4: All errors that occur within 15 minutes of each other are related.  Filter to include only errors during business hours (M-F, 7-7)..
WITH ISLAND_START AS
(
    SELECT
		Starting_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Starting_IDs.Error_Datetime ASC, Starting_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Starting_IDs.Error_Datetime,
		Starting_IDs.Error_Source,
		Starting_IDs.Error_Type,
		Starting_IDs.Error_Description,
		Starting_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Starting_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Previous_Id
        WHERE Previous_Id.Error_Datetime >= DATEADD(MINUTE, -15, Starting_IDs.Error_Datetime)
		AND Previous_Id.Error_Datetime < Starting_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Starting_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Starting_IDs.On_Call_Error_Log_Id)
	AND DATEPART(DW, Starting_IDs.Error_Datetime) NOT IN (7, 1)
	AND CAST(Starting_IDs.Error_Datetime AS TIME) BETWEEN '07:00:00' AND '19:00:00'
),
ISLAND_END AS
(
    SELECT
		Ending_IDs.On_Call_Error_Log_Id,
		ROW_NUMBER() OVER(ORDER BY Ending_IDs.Error_Datetime ASC, Ending_IDs.On_Call_Error_Log_Id ASC) AS Row_Num,
		Ending_IDs.Error_Datetime,
		Ending_IDs.Error_Source,
		Ending_IDs.Error_Type,
		Ending_IDs.Error_Description,
		Ending_IDs.Error_Details
    FROM dbo.On_Call_Error_Log Ending_IDs
    WHERE NOT EXISTS (
        SELECT *
        FROM dbo.On_Call_Error_Log Next_Id
        WHERE Next_Id.Error_Datetime <= DATEADD(MINUTE, 15, Ending_IDs.Error_Datetime)
		AND Next_Id.Error_Datetime > Ending_IDs.Error_Datetime)
	AND NOT EXISTS (SELECT * FROM dbo.On_Call_Error_Log DUPLICATE_TIMES WHERE DUPLICATE_TIMES.Error_Datetime = Ending_IDs.Error_Datetime
																AND DUPLICATE_TIMES.On_Call_Error_Log_Id > Ending_IDs.On_Call_Error_Log_Id)
	AND DATEPART(DW, Ending_IDs.Error_Datetime) NOT IN (7, 1)
	AND CAST(Ending_IDs.Error_Datetime AS TIME) BETWEEN '07:00:00' AND '19:00:00'
)
SELECT
	ISLAND_START.Error_Datetime AS Island_Starting_Time,
	ISLAND_END.Error_Datetime AS Island_Ending_Time,
	(SELECT COUNT(*) FROM dbo.On_Call_Error_Log Error_Count WHERE Error_Count.Error_Datetime >= ISLAND_START.Error_Datetime AND Error_Count.Error_Datetime <= ISLAND_END.Error_Datetime) AS Error_Count
FROM ISLAND_START
INNER JOIN ISLAND_END
ON ISLAND_START.Row_Num = ISLAND_END.Row_Num
ORDER BY ISLAND_START.Error_Datetime;

-- Cleanup
DROP TABLE dbo.On_Call_Error_Log;
GO
-----------------------------------------------------------------------------------------------------------------------------
------------------------------------------ANSWERING CRAZY QUESTIONS----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------
/*	These metrics use baseball data imported from Retrosheet into a database called Baseball_Stats.  This data is complete through the 2015 season.
	Table Descriptions:
		dbo.GameDate: 1 row per date that any game was played.  Used as a dimension for joins/analytics.
		dbo.GameEvent: Game details, with a row for each at-bat and/or play.
		dbo.GameEventImport: Details on the original CSV data that was imported from Retrosheet.
		dbo.GameLog: 1 row per game per day, with team metrics, lineups, aggregate player statistics and game results.
		dbo.GameType: Indicates if the game is regular seas, all-star, division series, world series, etc...
		dbo.GameYear: 1 row per year that any game was played.  Used as a dimension for joins/analytics.	*/
USE Baseball_Stats
GO
-- Take a peek at the data we are using:
SELECT TOP 10 * FROM dbo.GameLog

SELECT TOP 10 * FROM dbo.GameEvent

SELECT COUNT(*) AS GameLog_Count FROM dbo.GameLog;
SELECT COUNT(*) AS GameEvent_Count FROM dbo.GameEvent;

-- This query takes baseball data for a single team (the Yankees) and uses a CASE statement to assign W, L, or T as the result for regular season games.
-- This will be used in future queries.
SELECT
	CASE WHEN HomeScore > VisitingScore AND HomeTeamName = 'NYA' THEN 'W'
			WHEN HomeScore > VisitingScore AND VisitingTeamName = 'NYA' THEN 'L'
			WHEN VisitingScore > HomeScore AND VisitingTeamName = 'NYA' THEN 'W'
			WHEN VisitingScore > HomeScore AND HomeTeamName = 'NYA' THEN 'L'
			WHEN VisitingScore = HomeScore THEN 'T'
	END AS Result,
	*
FROM dbo.GameLog
WHERE (HomeTeamName = 'NYA' OR VisitingTeamName = 'NYA')
AND GameType = 'REG'
ORDER BY GameDate ASC, GameNumber ASC;
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- Using our alerting/clustering queries from earlier, we can build a list of all winning streaks by the Yankees all-time.
-- This query provides a start date and end date for all wins (losses are omitted from analytics)
WITH CTE_BASEBALL_GAMES AS (
	SELECT
		*,
		CASE WHEN HomeScore > VisitingScore AND HomeTeamName = 'NYA' THEN 'W'
			 WHEN HomeScore > VisitingScore AND VisitingTeamName = 'NYA' THEN 'L'
			 WHEN VisitingScore > HomeScore AND VisitingTeamName = 'NYA' THEN 'W'
			 WHEN VisitingScore > HomeScore AND HomeTeamName = 'NYA' THEN 'L'
			 WHEN VisitingScore = HomeScore THEN 'T'
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum
	FROM dbo.GameLog
	WHERE (HomeTeamName = 'NYA' OR VisitingTeamName = 'NYA')
	AND GameType = 'REG'
	AND (HomeScore > VisitingScore OR VisitingScore > HomeScore)),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS StartNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS PreviousGame
        WHERE GameDay.rownum = PreviousGame.rownum + 1
		AND PreviousGame.Result <> 'W')),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS EndNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.Result <> 'W'))
SELECT
	CTE_StartofWinningStreak.GameDate AS StartDate,
	CTE_EndofWinningStreak.GameDate AS EndDate,
	(SELECT COUNT(*) FROM CTE_BASEBALL_GAMES COUNT_CHECK WHERE COUNT_CHECK.GameDate BETWEEN CTE_StartofWinningStreak.GameDate AND CTE_EndofWinningStreak.GameDate AND COUNT_CHECK.GameLogID BETWEEN CTE_StartofWinningStreak.GameLogID AND CTE_EndofWinningStreak.GameLogID) AS Games_In_Streak,
	*
FROM CTE_StartofWinningStreak
INNER JOIN CTE_EndofWinningStreak
ON CTE_StartofWinningStreak.StartNum = CTE_EndofWinningStreak.EndNum
ORDER BY CTE_StartofWinningStreak.GameDate, CTE_StartofWinningStreak.GameNumber;
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- This query builds on our previous one and orders all winning streaks by the Yankees from longest to shortest.
-- Details on the start and end of the streak are included as well.  Ties are not included.
WITH CTE_BASEBALL_GAMES AS (
	SELECT
		*,
		CASE WHEN HomeScore > VisitingScore AND HomeTeamName = 'NYA' THEN 'W'
			 WHEN HomeScore > VisitingScore AND VisitingTeamName = 'NYA' THEN 'L'
			 WHEN VisitingScore > HomeScore AND VisitingTeamName = 'NYA' THEN 'W'
			 WHEN VisitingScore > HomeScore AND HomeTeamName = 'NYA' THEN 'L'
			 WHEN VisitingScore = HomeScore THEN 'T'
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum
	FROM dbo.GameLog
	WHERE (HomeTeamName = 'NYA' OR VisitingTeamName = 'NYA')
	AND GameType = 'REG'),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS StartNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE GameDay.Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS PreviousGame
        WHERE (GameDay.rownum = PreviousGame.rownum + 1 OR GameDay.rownum = 1)
		AND PreviousGame.Result <> 'W')),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS EndNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.Result <> 'W'))
SELECT
	CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum + 1 AS WinningStreak,
	CTE_StartofWinningStreak.GameDate AS StartGameDate,
	CTE_StartofWinningStreak.GameNumber AS StartGameNumber,
	CTE_EndofWinningStreak.GameDate AS EndGameDate,
	CTE_EndofWinningStreak.GameNumber AS EndGameNumber,
	*
FROM CTE_StartofWinningStreak
INNER JOIN CTE_EndofWinningStreak
ON CTE_StartofWinningStreak.StartNum = CTE_EndofWinningStreak.EndNum
ORDER BY CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum DESC;
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- We can similarly track Yankees losing streaks as well.  Ties are not included.
WITH CTE_BASEBALL_GAMES AS (
	SELECT
		*,
		CASE WHEN HomeScore > VisitingScore AND HomeTeamName = 'NYA' THEN 'W'
			 WHEN HomeScore > VisitingScore AND VisitingTeamName = 'NYA' THEN 'L'
			 WHEN VisitingScore > HomeScore AND VisitingTeamName = 'NYA' THEN 'W'
			 WHEN VisitingScore > HomeScore AND HomeTeamName = 'NYA' THEN 'L'
			 WHEN VisitingScore = HomeScore THEN 'T'
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum
	FROM dbo.GameLog
	WHERE (HomeTeamName = 'NYA' OR VisitingTeamName = 'NYA')
	AND GameType = 'REG'
	AND (HomeScore > VisitingScore OR VisitingScore > HomeScore)),
CTE_StartofLosingStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS StartNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = 'L'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS PreviousGame
        WHERE (GameDay.rownum = PreviousGame.rownum + 1 OR GameDay.rownum = 1)
		AND PreviousGame.Result <> 'L')),
CTE_EndofLosingStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS EndNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = 'L'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.Result <> 'L'))
SELECT
	CTE_EndofLosingStreak.rownum - CTE_StartofLosingStreak.rownum + 1 AS LosingStreak,
	CTE_StartofLosingStreak.GameDate AS StartGameDate,
	CTE_StartofLosingStreak.GameNumber AS StartGameNumber,
	CTE_EndofLosingStreak.GameDate AS EndGameDate,
	CTE_EndofLosingStreak.GameNumber AS EndGameNumber,
	*
FROM CTE_StartofLosingStreak
INNER JOIN CTE_EndofLosingStreak
ON CTE_StartofLosingStreak.StartNum = CTE_EndofLosingStreak.EndNum
ORDER BY CTE_EndofLosingStreak.rownum - CTE_StartofLosingStreak.rownum DESC;
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	Longest winning streak for each modern team.  Here, instead of writing dozens of queries, we use dynamic SQL to
	iterate through each possible opposing team and run the calculation above.  Modern teams include all of those that have existed in
	any period after 1965.  Ties are not included.	This can be done in a set-based fashion, which is much faster, and will be introduced shortly.*/
DECLARE @Team_List TABLE (Team_Name VARCHAR(3));
INSERT INTO @Team_List
	(Team_Name)
SELECT DISTINCT
	GameLog.VisitingTeamName
FROM dbo.GameLog
WHERE GameLog.GameType = 'REG'
AND GameDate >= '1/1/1965'
UNION
SELECT DISTINCT
	GameLog.HomeTeamName
FROM dbo.GameLog
WHERE GameLog.GameType = 'REG'
AND GameLog.HomeTeamName <> 'NYA'
AND GameDate >= '1/1/1965';

CREATE TABLE #Team_Results	(Team_Name VARCHAR(3), Start_Game_Date DATE, Start_Game_Number SMALLINT, End_Game_Date DATE,End_Game_Number SMALLINT, Winning_Streak_Number_Of_Games SMALLINT);

DECLARE @Sql_Command NVARCHAR(MAX) = '';
SELECT @Sql_Command = @Sql_Command + '
WITH CTE_BASEBALL_GAMES AS (
	SELECT
		*,
		CASE WHEN HomeScore > VisitingScore AND HomeTeamName = ''' + Team_Name + ''' THEN ''W''
			 WHEN HomeScore > VisitingScore AND VisitingTeamName = ''' + Team_Name + ''' THEN ''L''
			 WHEN VisitingScore > HomeScore AND VisitingTeamName = ''' + Team_Name + ''' THEN ''W''
			 WHEN VisitingScore > HomeScore AND HomeTeamName = ''' + Team_Name + ''' THEN ''L''
			 WHEN VisitingScore = HomeScore THEN ''T''
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum
	FROM dbo.GameLog
	WHERE (HomeTeamName = ''' + Team_Name + ''' OR VisitingTeamName = ''' + Team_Name + ''')
	AND GameType = ''REG''),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS StartNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE GameDay.Result = ''W''
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS PreviousGame
        WHERE (GameDay.rownum = PreviousGame.rownum + 1 OR GameDay.rownum = 1)
		AND PreviousGame.Result <> ''W'')),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS EndNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = ''W''
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.Result <> ''W''))
INSERT INTO #Team_Results
	(Team_Name, Start_Game_Date, Start_Game_Number, End_Game_Date, End_Game_Number, Winning_Streak_Number_Of_Games)
SELECT TOP 1
	''' + Team_Name + ''' AS Team_Name,
	CTE_StartofWinningStreak.GameDate AS Start_Game_Date,
	CTE_StartofWinningStreak.GameNumber AS Start_Game_Number,
	CTE_EndofWinningStreak.GameDate AS End_Game_Date,
	CTE_EndofWinningStreak.GameNumber AS End_Game_Number,
	CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum + 1 AS Winning_Streak_Number_Of_Games
FROM CTE_StartofWinningStreak
INNER JOIN CTE_EndofWinningStreak
ON CTE_StartofWinningStreak.StartNum = CTE_EndofWinningStreak.EndNum
ORDER BY CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum DESC;'
FROM @Team_List;

EXEC sp_executesql @Sql_Command;
SELECT * FROM #Team_Results
ORDER BY Team_Name ASC;

DROP TABLE #Team_Results;
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	This query shows every game pitched during the career of Nolan Ryan.  His stats make a good
	case study as he pitched a very high number of games, and innings per game.	*/
DECLARE @PitcherName VARCHAR(100) = 'Nolan Ryan';
SELECT
	CASE WHEN WinningPitcherName = @PitcherName THEN 'W'
			WHEN LosingPitcherName = @PitcherName THEN 'L'
			ELSE 'N'
	END AS Result,
	ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum,
	*
FROM dbo.GameLog
WHERE (VisitingStartingPitcherName = @PitcherName OR HomeStartingPitcherName = @PitcherName)
ORDER BY GameDate ASC, GameNumber ASC;
GO
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	We can build a query to take the data from above and build streak data from it, showing all of Nolan
	Ryan's winning streaks, as well as the start & end dates for each.	*/
DECLARE @PitcherName VARCHAR(100) = 'Nolan Ryan';
WITH CTE_PITCHING AS (
	SELECT
		CASE WHEN WinningPitcherName = @PitcherName THEN 'W'
			 WHEN LosingPitcherName = @PitcherName THEN 'L'
			 ELSE 'N'
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum,
		*
	FROM dbo.GameLog
	WHERE (VisitingStartingPitcherName = @PitcherName OR HomeStartingPitcherName = @PitcherName)),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS StartNum
    FROM CTE_PITCHING AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS PreviousGame
        WHERE GameDay.rownum = PreviousGame.rownum + 1
		AND PreviousGame.Result <> 'W')),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS EndNum
    FROM CTE_PITCHING AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.Result <> 'W'))
SELECT
	CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum + 1 AS WinningStreak,
	CTE_StartofWinningStreak.GameDate AS StartGameDate, CTE_StartofWinningStreak.GameNumber AS StartGameNumber,
	CTE_EndofWinningStreak.GameDate AS EndGameDate, CTE_EndofWinningStreak.GameNumber AS EndGameNumber
FROM CTE_StartofWinningStreak
INNER JOIN CTE_EndofWinningStreak
ON CTE_StartofWinningStreak.StartNum = CTE_EndofWinningStreak.EndNum
ORDER BY CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum DESC;
GO
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	The results of streak/cluster calculations can be used to fuel further analytics.  For example,
	this query tells us how many winning streaks Nolan Ryan had per length of streak.	*/
DECLARE @PitcherName VARCHAR(100) = 'Nolan Ryan';
WITH CTE_PITCHING AS (
	SELECT
		CASE WHEN WinningPitcherName = @PitcherName THEN 'W'
			 WHEN LosingPitcherName = @PitcherName THEN 'L'
			 ELSE 'N'
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum,
		*
	FROM dbo.GameLog
	WHERE (VisitingStartingPitcherName = @PitcherName OR HomeStartingPitcherName = @PitcherName)),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS StartNum
    FROM CTE_PITCHING AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS PreviousGame
        WHERE GameDay.rownum = PreviousGame.rownum + 1
		AND PreviousGame.Result <> 'W')),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS EndNum
    FROM CTE_PITCHING AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.Result <> 'W'))
SELECT
	CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum + 1 AS WinningStreak,
	CTE_StartofWinningStreak.GameDate AS StartGameDate, CTE_StartofWinningStreak.GameNumber AS StartGameNumber,
	CTE_EndofWinningStreak.GameDate AS EndGameDate, CTE_EndofWinningStreak.GameNumber AS EndGameNumber
INTO #NolanRyanWinningStreaks
FROM CTE_StartofWinningStreak
INNER JOIN CTE_EndofWinningStreak
ON CTE_StartofWinningStreak.StartNum = CTE_EndofWinningStreak.EndNum
ORDER BY CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum DESC;

SELECT
	WinningStreak AS NumberOfGames,
	COUNT(*) AS NumberOfWinningStreaks
FROM #NolanRyanWinningStreaks
GROUP BY WinningStreak
ORDER BY COUNT(*) DESC;

DROP TABLE #NolanRyanWinningStreaks;
GO
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	Using a PARITION BY, we can further break down a data set, without iteration or the need for dynamic SQL.
	This query returns all winning streaks per opposing team, over time.  Note the use of the CASE statement
	to determine the opposition team, and the additional join predecates at the end of the query, to join
	on the opposting team name, in addition to the calculated streak start/end row numbers.	*/
DECLARE @PitcherName VARCHAR(100) = 'Nolan Ryan';
WITH CTE_PITCHING AS (
	SELECT
		CASE WHEN WinningPitcherName = @PitcherName THEN 'W'
			 WHEN LosingPitcherName = @PitcherName THEN 'L'
			 ELSE 'N'
		END AS Result,
		ROW_NUMBER() OVER (PARTITION BY CASE
											WHEN VisitingStartingPitcherName = @PitcherName THEN HomeTeamName
											WHEN HomeStartingPitcherName = @PitcherName THEN VisitingTeamName
										END ORDER BY GameDate ASC, GameNumber ASC) AS rownum,
		CASE
			WHEN VisitingStartingPitcherName = @PitcherName THEN HomeTeamName
			WHEN HomeStartingPitcherName = @PitcherName THEN VisitingTeamName
		END AS OpposingTeam,
		*
	FROM dbo.GameLog
	WHERE (VisitingStartingPitcherName = @PitcherName OR HomeStartingPitcherName = @PitcherName)),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDay.GameDate ASC, GameDay.GameNumber ASC) AS StartNum_UNORDERED
    FROM CTE_PITCHING AS GameDay
	WHERE GameDay.Result = 'W'
	AND (EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS PreviousGame
        WHERE GameDay.rownum = PreviousGame.rownum + 1
		AND GameDay.OpposingTeam = PreviousGame.OpposingTeam
		AND PreviousGame.Result <> 'W')
		OR GameDay.rownum = 1)),
CTE_StartofWinningStreak_ORDERED AS (
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY CTE_StartofWinningStreak.opposingteam ORDER BY GameDate ASC, GameNumber ASC) AS StartNum_ORDERED
	FROM CTE_StartofWinningStreak
),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY GameDay.OpposingTeam ORDER BY GameDate ASC, GameNumber ASC) AS EndNum_UNORDERED
    FROM CTE_PITCHING AS GameDay
	WHERE GameDay.Result = 'W'
	AND (EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND GameDay.OpposingTeam = NextGame.OpposingTeam
		AND NextGame.Result <> 'W')
	OR GameDay.rownum = (SELECT MAX(END_OF_LIST_CHECK.rownum) FROM CTE_PITCHING END_OF_LIST_CHECK WHERE END_OF_LIST_CHECK.OpposingTeam = GameDay.OpposingTeam AND END_OF_LIST_CHECK.Result = 'W'))),
CTE_EndofWinningStreak_ORDERED AS (
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY CTE_EndofWinningStreak.opposingteam ORDER BY GameDate ASC, GameNumber ASC) AS EndNum_ORDERED
	FROM CTE_EndofWinningStreak
)
SELECT
	CTE_StartofWinningStreak_ORDERED.OpposingTeam,
	CTE_EndofWinningStreak_ORDERED.rownum - CTE_StartofWinningStreak_ORDERED.rownum + 1 AS WinningStreak,
	CTE_StartofWinningStreak_ORDERED.GameDate AS StartGameDate,
	CTE_StartofWinningStreak_ORDERED.GameNumber AS StartGameNumber,
	CTE_EndofWinningStreak_ORDERED.GameDate AS EndGameDate,
	CTE_EndofWinningStreak_ORDERED.GameNumber AS EndGameNumber
FROM CTE_StartofWinningStreak_ORDERED
INNER JOIN CTE_EndofWinningStreak_ORDERED
ON CTE_StartofWinningStreak_ORDERED.StartNum_ORDERED = CTE_EndofWinningStreak_ORDERED.EndNum_ORDERED
AND CTE_StartofWinningStreak_ORDERED.OpposingTeam = CTE_EndofWinningStreak_ORDERED.OpposingTeam
ORDER BY CTE_StartofWinningStreak_ORDERED.OpposingTeam, CTE_StartofWinningStreak_ORDERED.GameDate ASC;
GO
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	Using the data above, we can calculate the longest winning streak for a player versus any team by
	moving that data into a temp table and performing further grouping on it.  This approach bypases the need
	for dynamic SQL or loops, but presents us with a much more complex query.  Depending on the number of
	entities being processed, this approach may or may not be faster than using a discrete analyutical method,
	such as iteration.	*/
DECLARE @PitcherName VARCHAR(100) = 'Nolan Ryan';
WITH CTE_PITCHING AS (
	SELECT
		CASE WHEN WinningPitcherName = @PitcherName THEN 'W'
			 WHEN LosingPitcherName = @PitcherName THEN 'L'
			 ELSE 'N'
		END AS Result,
		ROW_NUMBER() OVER (PARTITION BY CASE
											WHEN VisitingStartingPitcherName = @PitcherName THEN HomeTeamName
											WHEN HomeStartingPitcherName = @PitcherName THEN VisitingTeamName
										END ORDER BY GameDate ASC, GameNumber ASC) AS rownum,
		CASE
			WHEN VisitingStartingPitcherName = @PitcherName THEN HomeTeamName
			WHEN HomeStartingPitcherName = @PitcherName THEN VisitingTeamName
		END AS OpposingTeam,
		*
	FROM dbo.GameLog
	WHERE (VisitingStartingPitcherName = @PitcherName OR HomeStartingPitcherName = @PitcherName)),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDay.GameDate ASC, GameDay.GameNumber ASC) AS StartNum_UNORDERED
    FROM CTE_PITCHING AS GameDay
	WHERE GameDay.Result = 'W'
	AND (EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS PreviousGame
        WHERE GameDay.rownum = PreviousGame.rownum + 1
		AND GameDay.OpposingTeam = PreviousGame.OpposingTeam
		AND PreviousGame.Result <> 'W')
		OR GameDay.rownum = 1)),
CTE_StartofWinningStreak_ORDERED AS (
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY CTE_StartofWinningStreak.opposingteam ORDER BY GameDate ASC, GameNumber ASC) AS StartNum_ORDERED
	FROM CTE_StartofWinningStreak
),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY GameDay.OpposingTeam ORDER BY GameDate ASC, GameNumber ASC) AS EndNum_UNORDERED
    FROM CTE_PITCHING AS GameDay
	WHERE GameDay.Result = 'W'
	AND (EXISTS (
        SELECT
			*
        FROM CTE_PITCHING AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND GameDay.OpposingTeam = NextGame.OpposingTeam
		AND NextGame.Result <> 'W')
	OR GameDay.rownum = (SELECT MAX(END_OF_LIST_CHECK.rownum) FROM CTE_PITCHING END_OF_LIST_CHECK WHERE END_OF_LIST_CHECK.OpposingTeam = GameDay.OpposingTeam AND END_OF_LIST_CHECK.Result = 'W'))),
CTE_EndofWinningStreak_ORDERED AS (
	SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY CTE_EndofWinningStreak.opposingteam ORDER BY GameDate ASC, GameNumber ASC) AS EndNum_ORDERED
	FROM CTE_EndofWinningStreak
)
SELECT
	CTE_StartofWinningStreak_ORDERED.OpposingTeam,
	CTE_EndofWinningStreak_ORDERED.rownum - CTE_StartofWinningStreak_ORDERED.rownum + 1 AS WinningStreak,
	CTE_StartofWinningStreak_ORDERED.GameDate AS StartGameDate,
	CTE_StartofWinningStreak_ORDERED.GameNumber AS StartGameNumber,
	CTE_EndofWinningStreak_ORDERED.GameDate AS EndGameDate,
	CTE_EndofWinningStreak_ORDERED.GameNumber AS EndGameNumber
INTO #WinningStreaksPerTeam
FROM CTE_StartofWinningStreak_ORDERED
INNER JOIN CTE_EndofWinningStreak_ORDERED
ON CTE_StartofWinningStreak_ORDERED.StartNum_ORDERED = CTE_EndofWinningStreak_ORDERED.EndNum_ORDERED
AND CTE_StartofWinningStreak_ORDERED.OpposingTeam = CTE_EndofWinningStreak_ORDERED.OpposingTeam
ORDER BY CTE_StartofWinningStreak_ORDERED.OpposingTeam, CTE_StartofWinningStreak_ORDERED.GameDate ASC;

WITH CTE_LONGEST_STREAK AS (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY OpposingTeam ORDER BY WinningStreak DESC) AS GameNum,
		*
	FROM #WinningStreaksPerTeam)
SELECT
	*
FROM CTE_LONGEST_STREAK
WHERE CTE_LONGEST_STREAK.GameNum = 1
ORDER BY CTE_LONGEST_STREAK.OpposingTeam ASC

DROP TABLE #WinningStreaksPerTeam;
GO
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	What if we would like to go after some more obscure facts?  For example, night games played on
	Wednesdays in July by the New York Mets.  This sounds complicated, but in reality, the primary changes to
	our query is within the initial CTE.  The following TSQL identifies the base data set we are interested
	in, thus discarding other data from what we will soon be ordering/numbering.	*/
SELECT
	CASE WHEN HomeScore > VisitingScore AND HomeTeamName = 'NYN' THEN 'W'
			WHEN HomeScore > VisitingScore AND VisitingTeamName = 'NYN' THEN 'L'
			WHEN VisitingScore > HomeScore AND VisitingTeamName = 'NYN' THEN 'W'
			WHEN VisitingScore > HomeScore AND HomeTeamName = 'NYN' THEN 'L'
			ELSE 'N'
	END AS Result,
	ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum,
	*
FROM dbo.GameLog
WHERE (HomeTeamName = 'NYN' OR VisitingTeamName = 'NYN')
AND GameType = 'REG'
AND (HomeScore > VisitingScore OR VisitingScore > HomeScore)
AND DayorNight IS NOT NULL AND DayorNight = 'N'
AND GameDayofWeek = 'Wed'
AND MONTH(GameDate) = 7;
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	This CTE takes the data from above and filters it down to only games that were won by the Mets on Wednesdays
	in July at night	*/
WITH CTE_METS_WINS AS (
	SELECT
		CASE WHEN HomeScore > VisitingScore AND HomeTeamName = 'NYN' THEN 'W'
				WHEN HomeScore > VisitingScore AND VisitingTeamName = 'NYN' THEN 'L'
				WHEN VisitingScore > HomeScore AND VisitingTeamName = 'NYN' THEN 'W'
				WHEN VisitingScore > HomeScore AND HomeTeamName = 'NYN' THEN 'L'
				ELSE 'N'
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum,
		*
	FROM dbo.GameLog
	WHERE (HomeTeamName = 'NYN' OR VisitingTeamName = 'NYN')
	AND GameType = 'REG'
	AND (HomeScore > VisitingScore OR VisitingScore > HomeScore)
	AND DayorNight IS NOT NULL AND DayorNight = 'N'
	AND GameDayofWeek = 'Wed'
	AND MONTH(GameDate) = 7)
SELECT
	*
FROM CTE_METS_WINS
WHERE Result = 'W';
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	Combining our new (and a bit wacky) data set with our winning streak/clustering methods from above,
	we can determine winning streaks across the set of Mets games on Wednesday nights in July	*/
WITH CTE_BASEBALL_GAMES AS (
	SELECT
		*,
		CASE WHEN HomeScore > VisitingScore AND HomeTeamName = 'NYN' THEN 'W'
				WHEN HomeScore > VisitingScore AND VisitingTeamName = 'NYN' THEN 'L'
				WHEN VisitingScore > HomeScore AND VisitingTeamName = 'NYN' THEN 'W'
				WHEN VisitingScore > HomeScore AND HomeTeamName = 'NYN' THEN 'L'
				ELSE 'N'
		END AS Result,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS rownum
	FROM dbo.GameLog
	WHERE (HomeTeamName = 'NYN' OR VisitingTeamName = 'NYN')
	AND GameType = 'REG'
	AND (HomeScore > VisitingScore OR VisitingScore > HomeScore)
	AND DayorNight IS NOT NULL AND DayorNight = 'N'
	AND GameDayofWeek = 'Wed'
	AND MONTH(GameDate) = 7),
CTE_StartofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS StartNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS PreviousGame
        WHERE GameDay.rownum = PreviousGame.rownum + 1
		AND PreviousGame.Result = 'L')),
CTE_EndofWinningStreak AS (
    SELECT
		*,
		ROW_NUMBER() OVER (ORDER BY GameDate ASC, GameNumber ASC) AS EndNum
    FROM CTE_BASEBALL_GAMES AS GameDay
	WHERE Result = 'W'
	AND EXISTS (
        SELECT
			*
        FROM CTE_BASEBALL_GAMES AS NextGame
        WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.Result = 'L'))
SELECT
	CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum + 1 AS WinningStreak,
	CTE_StartofWinningStreak.GameDate AS StartGameDate, CTE_StartofWinningStreak.GameNumber AS StartGameNumber,
	CTE_EndofWinningStreak.GameDate AS EndGameDate, CTE_EndofWinningStreak.GameNumber AS EndGameNumber,
	*
FROM CTE_StartofWinningStreak
INNER JOIN CTE_EndofWinningStreak
ON CTE_StartofWinningStreak.StartNum = CTE_EndofWinningStreak.EndNum
ORDER BY CTE_EndofWinningStreak.rownum - CTE_StartofWinningStreak.rownum DESC;
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
/*	Clustering analysis can be used to find patterns within seemingly random data.  Analytics can even be
	automated into a loop or complex set in which a group of similar metrics are checked at once.

	Let's say we wanted to find scenarios in which a player performed particularly well.  We could
	run a set of metrics against our data, collect the results, and then sort/compare them at the end.

	In this example, we will analyze all at-bats by Derek Jeter, who played from 1995 - 2014 and had 13950 at-bats.
	I'd like to not only know under which circumstances he performed best, but which of those metrics allowed
	for the longest and most statistically significant streaks.

	To enumerate this, we will use EventType, which indicates what resulted from his at-bat as follows:
	      0    Unknown event (0)
          1    No event (0)
          2    Generic out (-1)
          3    Strikeout (-1)
          4    Stolen base (1)
          5    Defensive indifference (0)
          6    Caught stealing (-1)
          7    Pickoff error (0)
          8    Pickoff (-1)
          9    Wild pitch (0)
          10   Passed ball (0)
          11   Balk (0)
          12   Other advance (0)
          13   Foul error (0)
          14   Walk (1)
          15   Intentional walk (1)
          16   Hit by pitch (0)
          17   Interference (0)
          18   Error (0)
          19   Fielder's choice (0)
          20   Single (1)
          21   Double (2)
          22   Triple (3)
          23   Home run (4)
          24   Missing play (0)

	Based on this data, we will assign positive or negative points to each play based on his performance.  Neutral events will be assigned zero.
	See above for those details.  This will help us analyze the quality of each at-bat and game.

	For this example, we will compare streaks of "good games", those in which Jeter's net at-bat quality is greater than 0, and their lengths.
	Finally, we calculate the longest streaks, including starting and ending game.
*/
DECLARE @BatterName VARCHAR(100) = 'jeted001'; -- This is the player abbreviation/code for Derek Jeter

WITH CTE_BATTING AS (
	SELECT
		CASE WHEN GameEvent.EventType IN (0, 1, 5, 7, 9, 10, 11, 12, 13, 16, 17, 18, 19, 24) THEN 0
			 WHEN GameEvent.EventType IN (2, 3, 6, 8) THEN -1
			 WHEN GameEvent.EventType IN (4, 14, 15, 20) THEN 1
			 WHEN GameEvent.EventType = 21 THEN 2
			 WHEN GameEvent.EventType = 22 THEN 3
			 WHEN GameEvent.EventType = 23 THEN 4
			 ELSE 0
		END AS AtBatQuality,
		*
	FROM dbo.GameEvent
	WHERE Batter = @BatterName),
CTE_BATTING_GROUPED AS (
	SELECT
		CTE_BATTING.GameDate,
		CTE_BATTING.GameNumber,
		SUM(CTE_BATTING.AtBatQuality) AS GameAtBatQuality,
		ROW_NUMBER() OVER (ORDER BY CTE_BATTING.GameDate, CTE_BATTING.GameNumber) AS rownum
	FROM CTE_BATTING
	GROUP BY CTE_BATTING.GameDate, CTE_BATTING.GameNumber),
CTE_StartOfQualityHittingStreak AS (
	SELECT
		ROW_NUMBER() OVER (ORDER BY GameDay.GameDate, GameDay.GameNumber) AS StartNum,
		*
	FROM CTE_BATTING_GROUPED AS GameDay
	WHERE GameDay.GameAtBatQuality > 0
	AND EXISTS (
		SELECT
			*
		FROM CTE_BATTING_GROUPED AS PreviousGame
		WHERE GameDay.rownum = PreviousGame.rownum + 1
		AND PreviousGame.GameAtBatQuality <= 0)),
CTE_EndOfQualityHittingStreak AS (
	SELECT
		ROW_NUMBER() OVER (ORDER BY GameDay.GameDate, GameDay.GameNumber) AS EndNum,
		*
	FROM CTE_BATTING_GROUPED AS GameDay
	WHERE GameDay.GameAtBatQuality > 0
	AND EXISTS (
		SELECT
			*
		FROM CTE_BATTING_GROUPED AS NextGame
		WHERE GameDay.rownum = NextGame.rownum - 1
		AND NextGame.GameAtBatQuality <= 0))
SELECT
	CTE_EndOfQualityHittingStreak.rownum - CTE_StartOfQualityHittingStreak.rownum + 1 AS QualityHittingStreak,
	CTE_StartOfQualityHittingStreak.GameDate AS StartGameDate, CTE_StartOfQualityHittingStreak.GameNumber AS StartGameNumber,
	CTE_EndOfQualityHittingStreak.GameDate AS EndGameDate, CTE_EndOfQualityHittingStreak.GameNumber AS EndGameNumber
FROM CTE_StartOfQualityHittingStreak
INNER JOIN CTE_EndOfQualityHittingStreak
ON CTE_StartOfQualityHittingStreak.StartNum = CTE_EndOfQualityHittingStreak.EndNum
ORDER BY CTE_EndOfQualityHittingStreak.rownum - CTE_StartOfQualityHittingStreak.rownum DESC
GO
