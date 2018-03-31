
------------------------------------- SET UP -------------------------------------

-- abort if accidentally execute the entire script
RAISERROR('Oops - you tried to execute the entire script', 20, 1) WITH LOG;

IF NOT EXISTS(SELECT * FROM sys.databases WHERE [name] = 'QueryPerformance')
BEGIN
	CREATE DATABASE QueryPerformance;
END;
GO

ALTER DATABASE QueryPerformance SET RECOVERY SIMPLE WITH NO_WAIT;
GO

USE QueryPerformance;
GO

IF OBJECT_ID('dbo.BigTable','U') IS NOT NULL DROP TABLE dbo.BigTable;
GO

CREATE TABLE dbo.BigTable (i int, c varchar(MAX),
	CONSTRAINT PK_BigTable PRIMARY KEY CLUSTERED
		( i ASC ));
GO

IF OBJECT_ID('dbo.TableWithTrigger','U') IS NOT NULL DROP TABLE dbo.TableWithTrigger;
IF OBJECT_ID('dbo.TableWithTriggerHistory','U') IS NOT NULL DROP TABLE dbo.TableWithTriggerHistory;
GO

CREATE TABLE dbo.TableWithTrigger (k int NOT NULL PRIMARY KEY, i int);
CREATE TABLE dbo.TableWithTriggerHistory (k int NOT NULL, ModifiedTimestamp datetime2(7) NOT NULL, i int, DMLType char(6) NOT NULL);
GO

ALTER TABLE dbo.TableWithTriggerHistory
	ADD CONSTRAINT PK_TableWithTriggerHistory PRIMARY KEY CLUSTERED 
		( k, ModifiedTimestamp );
GO

CREATE TRIGGER tiudTableWithTrigger ON dbo.TableWithTrigger
	AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
	BEGIN
		-- insert
		INSERT INTO dbo.TableWithTriggerHistory (k, ModifiedTimestamp, i, DMLType)
		SELECT k, CURRENT_TIMESTAMP, i, 'INSERT'
			FROM inserted;
	END
	ELSE
	IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
	BEGIN
		-- delete
		INSERT INTO dbo.TableWithTriggerHistory (k, ModifiedTimestamp, i, DMLType)
		SELECT k, CURRENT_TIMESTAMP, i, 'DELETE'
			FROM deleted;
	END
	ELSE
	IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
	BEGIN
		-- update
		INSERT INTO dbo.TableWithTriggerHistory (k, ModifiedTimestamp, i, DMLType)
		SELECT k, CURRENT_TIMESTAMP, i, 'UPDATE'
			FROM inserted;
	END;
END;
GO

USE AdventureWorks2012;
GO

IF EXISTS(SELECT * FROM dbo.sysindexes WHERE [name] = 'XIE2_ResellerSales_OrderQuantity')
BEGIN
	DROP INDEX XIE2_ResellerSales_OrderQuantity ON dbo.ResellerSales
END;
GO

-- "randomize" the ResellerSales OrderDate
-- they all are 2007-07-01
UPDATE dbo.ResellerSales
	SET OrderDate = DATEADD(DAY, CAST(365 * RAND(ABS(CAST(CAST(NEWID() AS varbinary) AS int))) AS smallint), '2007-01-01');
GO -- takes ~ 1 minute

CREATE NONCLUSTERED INDEX XIE2_ResellerSales_OrderQuantity
	ON dbo.ResellerSales (ResellerKey,OrderQuantity);
GO

IF OBJECT_ID('dbo.NOLOCK','U') IS NOT NULL DROP TABLE dbo.NOLOCK;
GO

CREATE TABLE dbo.NOLOCK (ProductKey int, SalesOrderNumber varchar(20), ShipDate datetime);
GO

CREATE INDEX XIE1NOLOCK ON dbo.NOLOCK (ShipDate)
INCLUDE (ProductKey);
GO

IF NOT EXISTS(SELECT * FROM sys.databases WHERE [name] = 'Utility')
BEGIN
	CREATE DATABASE Utility;
END;
GO

ALTER DATABASE Utility SET RECOVERY SIMPLE WITH NO_WAIT;
GO

USE Utility;
GO

IF OBJECT_ID('dbo.ExecutionLog','U') IS NOT NULL DROP TABLE dbo.ExecutionLog;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
GO

CREATE TABLE dbo.ExecutionLog(
	ExecutionLogID int IDENTITY(1,1) NOT NULL,
	EventTimestamp datetime2(7) NOT NULL
		CONSTRAINT DF_ExecutionLog_EventTimestamp DEFAULT CURRENT_TIMESTAMP,
	DatabaseName nvarchar(128) NOT NULL,
	SchemaName nvarchar(128) NOT NULL,
	ExecutableName nvarchar(128) NOT NULL,
	EventDescription varchar(max) NOT NULL,
	SessionID int NOT NULL
		CONSTRAINT DF_ExecutionLog_SessionID DEFAULT @@SPID,
	UserName nvarchar(128) NOT NULL
		CONSTRAINT DF_ExecutionLog_UserName DEFAULT SUSER_SNAME(),
	RowsAffected int NULL,
 CONSTRAINT PK_ExecutionLog PRIMARY KEY CLUSTERED
	( ExecutionLogID ASC ));
GO

IF OBJECT_ID('dbo.Numbers','U') IS NOT NULL DROP TABLE dbo.Numbers;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
GO

CREATE TABLE dbo.Numbers(
	Number int NOT NULL,
	CONSTRAINT XPKNumbers PRIMARY KEY CLUSTERED 
		( Number ASC ));
GO

-- Add twenty million rows
WITH CTE1 AS (
		SELECT 1 AS C
		UNION ALL
		SELECT 1
	), CTE2 AS (
		SELECT 1 AS C
		FROM CTE1 AS A
		CROSS JOIN CTE1 AS B
	), CTE3 AS (
		SELECT 1 AS C
		FROM CTE2 AS A
		CROSS JOIN CTE2 AS B
	), CTE4 AS (
		SELECT 1 AS C
		FROM CTE3 AS A
		CROSS JOIN CTE3 AS B
	), CTE5 AS (
		SELECT 1 AS C
		FROM CTE4 AS A
		CROSS JOIN CTE4 AS B
	), CTE6 AS (
		SELECT 1 AS C
		FROM CTE5 AS A
		CROSS JOIN CTE5 AS B
	), CTE7 AS (
	SELECT ROW_NUMBER() OVER(ORDER BY C) AS NUMBER
		FROM CTE6
	)
	INSERT INTO dbo.Numbers (Number)
	SELECT Number
        FROM CTE7
        WHERE Number <= 20000000;
GO

USE AdventureWorks2012;
GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_SCHEMA = 'dbo'
		AND TABLE_NAME = 'ResellerSales'
		AND COLUMN_NAME = 'ColumnToUpdate')
BEGIN
	ALTER TABLE dbo.ResellerSales
		ADD ColumnToUpdate char(2) NULL;
END;
GO

UPDATE dbo.ResellerSales
	SET ColumnToUpdate = 'XX'
	WHERE (ColumnToUpdate <> 'XX'
		OR ColumnToUpdate IS NULL);
GO

UPDATE dbo.ResellerSales
	SET ColumnToUpdate = 'YY'
	WHERE CarrierTrackingNumber = 'D220-4EE6-B8';
GO

-- start Zoomit

-- DEPLOY BOTH LoadBigTable and ParameterSniffing stored procedures

-- leave LoadBigTable tab open

-- open up (dont deploy) StoredProcedurExecutionLogging template

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

------------------------------------- END SET UP -------------------------------------


/****************************************
Statistics
****************************************/
USE AdventureWorks2012;
EXEC sp_helpstats 'dbo.ResellerSales', 'ALL'
GO

DBCC SHOW_STATISTICS ('dbo.ResellerSales','XIE1_ResellerSales_SalesOrderNumber') WITH HISTOGRAM;
GO

/****************************************
SET STATISTICS
****************************************/
DBCC DROPCLEANBUFFERS;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT COUNT(*) FROM AdventureWorks2012.dbo.ResellerSales
	 WHERE LEFT(SalesOrderNumber, 5) = '24007';
GO

/****************************************
Execution Plan
****************************************/
SET STATISTICS TIME OFF;
USE AdventureWorks2012;
GO

-- display actual execution plan
-- show estimated, then actual execution plans
SELECT T.[Name], SUM(R.UnitPrice) AS TotalPrice
	FROM dbo.ResellerSales AS R
	JOIN Sales.SalesTerritory AS T
		ON R.SalesTerritoryKey = T.TerritoryID
	GROUP BY T.[Name];
GO

-- do not describe SARGability yet
SELECT COUNT(*) FROM AdventureWorks2012.dbo.ResellerSales
	 WHERE LEFT(SalesOrderNumber, 5) = '24007';

SELECT COUNT(*) FROM AdventureWorks2012.dbo.ResellerSales
	 WHERE SalesOrderNumber LIKE '24007%';
GO

/****************************************
Execution Logging
****************************************/
USE Utility;
GO

TRUNCATE TABLE dbo.ExecutionLog;
GO

USE QueryPerformance;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- show LoadBigTable stored procedure

TRUNCATE TABLE dbo.BigTable;
GO

EXEC dbo.LoadBigTable @RowsToInsert = 100000;
GO -- takes ~ 15 seconds

-- then...
SELECT E.ExecutionLogID,
	CAST(CURRENT_TIMESTAMP AS time(3)) AS [Now],
 	E.EventTimestamp,
	CASE
		WHEN E.EventDescription IN ('Start','About to start.') THEN NULL
		ELSE DATEDIFF(second, LAG(E.EventTimestamp) OVER(PARTITION BY E.ExecutableName, E.UserName ORDER BY E.EventTimestamp, E.ExecutionLogID), E.EventTimestamp)
		END AS [Duration (sec)],
	E.RowsAffected,
	E.Databasename + '.' + E.SchemaName + '.' + E.ExecutableName AS ExecutableName,
	E.EventDescription,
	E.SessionID,
	E.UserName
	FROM Utility.dbo.ExecutionLog AS E
	WHERE E.EventTimestamp > DATEADD(DAY, -1, CURRENT_TIMESTAMP)
	ORDER BY E.EventTimestamp DESC, E.ExecutionLogID DESC;
GO

/****************************************
WITH (NOLOCK) (READUNCOMMITTED)
****************************************/
USE QueryPerformance;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

TRUNCATE TABLE dbo.BigTable;
GO

INSERT INTO dbo.BigTable (i, c)
SELECT Number, REPLICATE('XYZ', 2000)
	FROM Utility.dbo.Numbers
	WHERE Number <= 1000000;
GO -- takes ~ 2 minutes

-- in another window, monitor progress
SELECT COUNT(*)
	FROM QueryPerformance.dbo.BigTable WITH (READUNCOMMITTED);
GO

USE AdventureWorks2012;
GO

INSERT INTO dbo.NOLOCK (ProductKey, SalesOrderNumber, ShipDate)
SELECT RS1.ProductKey, RS1.SalesOrderNumber, RS1.ShipDate
	FROM dbo.ResellerSales AS RS1
	WHERE RS1.CustomerPONumber = 'PO1740169151';

TRUNCATE TABLE dbo.NOLOCK;

INSERT INTO dbo.NOLOCK (ProductKey, SalesOrderNumber, ShipDate)
SELECT RS1.ProductKey, RS1.SalesOrderNumber, RS1.ShipDate
	FROM dbo.ResellerSales AS RS1
	JOIN dbo.ResellerSales AS RS2
		ON RS1.ProductKey = RS2.ProductKey
		AND RS1.ShipDate = RS2.ShipDate
		AND RS1.OrderDate < RS2.OrderDate
	WHERE RS1.CustomerPONumber IN ('PO17574111985','PO18299133687')
	AND RS2.CustomerPONumber IN ('PO17574111985','PO18299133687');
GO

-- in another window
USE AdventureWorks2012;
GO

SELECT TOP 10 *
FROM dbo.NOLOCK WITH (NOLOCK);
GO

SELECT COUNT(*)
FROM dbo.NOLOCK WITH (NOLOCK);
GO

SELECT ProductKey, ShipDate
FROM dbo.NOLOCK WITH (NOLOCK)
WHERE ShipDate = '2007-07-08 00:00:00.000';
GO

-- cancel the query

/****************************************
SELECT *
****************************************/
-- show actual execution plan
SET STATISTICS IO ON;
SET STATISTICS TIME OFF;
GO

SELECT LastName + ',' + FirstName + COALESCE(' ' + MiddleName, '') AS FullName
	FROM AdventureWorks2012.Person.Person
	WHERE LastName LIKE 'Ol%';

SELECT LastName + ',' + FirstName + COALESCE(' ' + MiddleName, '') AS FullName, *
	FROM AdventureWorks2012.Person.Person
	WHERE LastName LIKE 'Ol%';
GO

/****************************************
UNION/UNION ALL
****************************************/
USE AdventureWorks2012;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

--show actual execution plan
SELECT [Name]
	FROM Sales.Store
UNION ALL
SELECT [Name]
	FROM Purchasing.Vendor;

SELECT [Name]
	FROM Sales.Store
UNION
SELECT [Name]
	FROM Purchasing.Vendor;
GO

/****************************************
SARGable
****************************************/
USE AdventureWorks2012;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME OFF;
GO

-- show actual execution plan
DECLARE @i int = 2;
SELECT *
	FROM Utility.dbo.Numbers
	WHERE Number < @i + 1;
SELECT *
	FROM Utility.dbo.Numbers
	WHERE Number - 1 < @i;
GO -- show statistics and execution plan

SELECT COUNT(*) FROM AdventureWorks2012.dbo.ResellerSales
	 WHERE LEFT(SalesOrderNumber, 5) = '24007';

SELECT COUNT(*) FROM AdventureWorks2012.dbo.ResellerSales
	 WHERE SalesOrderNumber LIKE '24007%';
GO

/****************************************
Implicit conversion
****************************************/
USE AdventureWorks2012;
GO

SET STATISTICS IO ON;
GO

-- show actual execution plan
DECLARE @IntegerSalesOrderNumber int = 240071774;

SELECT * FROM AdventureWorks2012.dbo.ResellerSales
	WHERE SalesOrderNumber = @IntegerSalesOrderNumber;

SELECT * FROM AdventureWorks2012.dbo.ResellerSales
	WHERE SalesOrderNumber = CAST(@IntegerSalesOrderNumber AS varchar(30));
GO
-- point out warning on "SELECT"

/****************************************
Avoid scalar functions in predicates
****************************************/
USE AdventureWorks2012;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

SELECT COUNT(*)
	FROM dbo.ResellerSales
	WHERE MONTH(OrderDate) = 3;
GO

IF OBJECT_ID('dbo.fxMonth','FN') IS NOT NULL DROP FUNCTION dbo.fxMonth;
GO

CREATE FUNCTION dbo.fxMonth (
	@Date date)
RETURNS tinyint
AS
BEGIN
	RETURN MONTH(@Date);
END;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT COUNT(*)
	FROM dbo.ResellerSales
	WHERE MONTH(OrderDate) = 3;

SELECT COUNT(*)
	FROM dbo.ResellerSales
	WHERE dbo.fxMonth(OrderDate) = 3;
GO -- show how Execution plan inaccurately represents

/****************************************
Only Update if something changes
****************************************/
USE AdventureWorks2012;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- reset to "bad" values
-- there are 4.9M rows in table, only 1645 match this CarrierTrackingNumber
-- again, Execution Plan misleading

DECLARE @Time1 time(2),
	@Time2 time(2),
	@Time3 time(2);

UPDATE dbo.ResellerSales
	SET ColumnToUpdate = 'YY'
	WHERE CarrierTrackingNumber = 'D220-4EE6-B8';

SET @Time1 =  CURRENT_TIMESTAMP;

UPDATE dbo.ResellerSales
	SET ColumnToUpdate = 'XX'
	WHERE (ColumnToUpdate <> 'XX'
		OR ColumnToUpdate IS NULL);
SET @Time2 = CURRENT_TIMESTAMP;

UPDATE dbo.ResellerSales
	SET ColumnToUpdate = 'XX';

SET @Time3 = CURRENT_TIMESTAMP;

SELECT DATEDIFF(MS, @Time1, @Time2),
	DATEDIFF(MS, @Time2, @Time3);	
GO

/****************************************
Parameter sniffing
****************************************/
USE QueryPerformance;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME OFF;
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO

EXEC dbo.ParameterSniffing
	@OrderQuantity = 1; -- show IO
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS;
GO

EXEC dbo.ParameterSniffing
	@OrderQuantity = 26;
GO

EXEC dbo.ParameterSniffing
	@OrderQuantity = 1; -- show IO
GO

/****************************************
Trigger code & estimated execution plan
****************************************/
USE QueryPerformance;
GO

TRUNCATE TABLE dbo.TableWithTrigger;
GO

-- Display estimated execution plan then display actual execution plan
INSERT INTO dbo.TableWithTrigger (k, i)
SELECT N.Number, -1 * N.Number
	FROM Utility.dbo.Numbers AS N
	WHERE N.Number <= 50000;
GO

/****************************************
CleanUp
****************************************/
USE AdventureWorks2012;
GO

IF OBJECT_ID('dbo.NOLOCK','U') IS NOT NULL DROP TABLE dbo.NOLOCK;
GO

IF EXISTS(SELECT * FROM dbo.sysindexes WHERE [name] = 'XIE2_ResellerSales_OrderQuantity')
BEGIN
	DROP INDEX XIE2_ResellerSales_OrderQuantity ON dbo.ResellerSales
END;
GO
