IF NOT EXISTS(SELECT * FROM sys.databases WHERE [name] = 'QueryPerformance')
BEGIN
	CREATE DATABASE QueryPerformance;
END;
GO

USE QueryPerformance;
GO

IF OBJECT_ID('dbo.LoadBigTable') IS NOT NULL DROP PROCEDURE dbo.LoadBigTable;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE PROC dbo.LoadBigTable
	@RowsToInsert int,
	@LogExecutionFlag bit = 1
AS

/********************************************
The procedure empties dbo.BigTable, then
loads with the number of rows passed via
the @RowsToInsert input parameter.

2014-01-01 gvr Initial creation
********************************************/

SET NOCOUNT ON;
SET ARITHABORT ON;

DECLARE @EventDescription varchar(1000),
	@SchemaName sysname = OBJECT_SCHEMA_NAME(@@PROCID),
	@ExecutableName sysname = OBJECT_NAME(@@PROCID),
	@DatabaseName sysname = DB_NAME(),
	@RowCount int,
	@MinNumber int = 1,
	@ChunkSize int = 2297,
	@MaxNumber int;

IF @LogExecutionFlag = 1
BEGIN;
	SET @EventDescription = 'Start';
	INSERT INTO Utility.dbo.ExecutionLog (EventDescription, DatabaseName, SchemaName, ExecutableName)
		VALUES (@EventDescription, @DatabaseName, @SchemaName, @ExecutableName);
END;

SET @MaxNumber = @MinNumber + @ChunkSize - 1;

TRUNCATE TABLE dbo.BigTable;
IF @LogExecutionFlag = 1
BEGIN
	SET @EventDescription = 'Finished truncating BigTable.';
	INSERT INTO Utility.dbo.ExecutionLog (EventDescription, DatabaseName, SchemaName, ExecutableName)
		VALUES (@EventDescription, @DatabaseName, @SchemaName, @ExecutableName);
END;

-- normally this would be a single insert statement, but for demonstration, we're looping through
-- It's still a valid example of using READUNCOMMITTED because the entire loop is in an explicit transaction
BEGIN TRAN;
WHILE @MinNumber <= @RowsToInsert
BEGIN
	INSERT INTO dbo.BigTable (i, c)
	SELECT Number, REPLICATE('XYZ', 2000)
		FROM Utility.dbo.Numbers
		WHERE Number >= @MinNumber
		AND Number <= @MaxNumber;

	SET @MinNumber = @MaxNumber + 1;
	SET @MaxNumber = @MinNumber + @ChunkSize - 1;
	IF @MaxNumber > @RowsToInsert SET @MaxNumber = @RowsToInsert;
END;

IF @LogExecutionFlag = 1
BEGIN
	SET @EventDescription = 'Finished inserting into BigTable.';
	INSERT INTO Utility.dbo.ExecutionLog (EventDescription, DatabaseName, SchemaName, ExecutableName, RowsAffected)
		VALUES (@EventDescription, @DatabaseName, @SchemaName, @ExecutableName, @RowsToInsert);
END;

WHILE @@TRANCOUNT > 0 COMMIT;

IF @LogExecutionFlag = 1
BEGIN;
	SET @EventDescription = 'Finish';
	INSERT INTO Utility.dbo.ExecutionLog (EventDescription, DatabaseName, SchemaName, ExecutableName)
		VALUES (@EventDescription, @DatabaseName, @SchemaName, @ExecutableName);
END;
 
GO
