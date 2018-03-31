USE [DatabaseName];
GO

IF OBJECT_ID('dbo.[StoredProcedureName]') IS NOT NULL DROP PROCEDURE dbo.[StoredProcedureName];
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE PROC dbo.[StoredProcedureName]
	-- other parameters
	@LogExecutionFlag bit = 1
AS

/****************************************************

IF NOT EXISTS(SELECT * FROM sys.databases WHERE [name] = 'Utility')
BEGIN
	CREATE DATABASE Utility;
END;
GO

USE Utility;
IF OBJECT_ID('dbo.ExecutionLog') IS NOT NULL DROP TABLE dbo.ExecutionLog;
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

****************************************************/

SET NOCOUNT ON;
SET ARITHABORT ON;

DECLARE @EventDescription varchar(1000),
	@SchemaName sysname = OBJECT_SCHEMA_NAME(@@PROCID),
	@ExecutableName sysname = OBJECT_NAME(@@PROCID),
	@DatabaseName sysname = DB_NAME(),
	@RowCount int;

-- Always log the start of the procedure
IF @LogExecutionFlag = 1
BEGIN;
	SET @EventDescription = 'Start';
	INSERT INTO Utility.dbo.ExecutionLog (EventDescription, DatabaseName, SchemaName, ExecutableName)
		VALUES (@EventDescription, @DatabaseName, @SchemaName, @ExecutableName);
END;

/****************************************

Stored Procedure body

Immediately after every non-trivial DML statement,
include these lines (revising @EventDescription for each)

SET @RowCount = @@ROWCOUNT;
IF @LogExecutionFlag = 1
BEGIN
	SET @EventDescription = 'Short helpful message of what DML just completed.';
	INSERT INTO Utility.dbo.ExecutionLog (EventDescription, DatabaseName, SchemaName, ExecutableName, RowsAffected)
		VALUES (@EventDescription, @DatabaseName, @SchemaName, @ExecutableName, @RowCount);
END;

****************************************/

-- Always log the finish of the procedure
IF @LogExecutionFlag = 1
BEGIN;
	SET @EventDescription = 'Finish';
	INSERT INTO Utility.dbo.ExecutionLog (EventDescription, DatabaseName, SchemaName, ExecutableName)
		VALUES (@EventDescription, @DatabaseName, @SchemaName, @ExecutableName);
END;
 
GO

