USE [master];
GO

IF OBJECT_ID(N'sp_SQLskills_DropAllColumnStats') IS NOT NULL
	DROP PROCEDURE [sp_SQLskills_DropAllColumnStats];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_SQLskills_DropAllColumnStats]
(
	@schemaname			sysname = NULL			
						-- Specific schema
	, @objectname		sysname = NULL			
						-- Specific object: table/view
	, @columnname		sysname = NULL			
						-- Specific column
	, @DropAll			nvarchar(5) = 'FALSE'
)
AS
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @schemanamedelimited	nvarchar(520) = QUOTENAME(@schemaname)
	, @objectnamedelimited		nvarchar(520) = QUOTENAME(@objectname)
	, @columnnamedelimited		nvarchar(520) = QUOTENAME(@columnname)
	, @stattoanalyzedelimited	nvarchar(520) = NULL

IF (@schemaname IS NULL OR @objectname IS NULL OR @columnname IS NULL OR @DropAll IS NULL)
BEGIN
	RAISERROR ('Proc:sp_SQLskills_DropAllColumnStats, @schemaname = %s, @objectname = %s, @columnname = %s, @dropall = %s. The @schemaname, @objectname, and @columnname parameters are ALL required. Do not supply a delimited value.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @dropall)
	RETURN
END

IF (@schemaname IS NOT NULL AND @objectname IS NOT NULL AND @columnname IS NOT NULL)
	AND NOT EXISTS 
		(SELECT * 
		FROM [INFORMATION_SCHEMA].[COLUMNS] AS [isc]
		WHERE [isc].[TABLE_SCHEMA] = @schemaname
			AND [isc].[TABLE_NAME] = @objectname
			AND [isc].[COLUMN_NAME] = @columnname)
BEGIN
	RAISERROR ('Proc:sp_SQLskills_DropAllColumnStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is not valid for schema.object:%s.%s. Check to make sure you''re in the correct database and that you did not supply an already delimited value. Additionally, these parameters are case-sensitive when the database is case-sensitive.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited, @schemanamedelimited, @objectnamedelimited)
	RETURN
END

DECLARE @schemaid				int
	, @twopartname				nvarchar(520)
	, @objectid					int
	, @statistictodrop			nvarchar(776)
	, @execstring				nvarchar(max)

SELECT @schemaid = SCHEMA_ID(@schemaname)
	, @twopartname = QUOTENAME(@schemaname, ']') + N'.' + QUOTENAME(@objectname, ']')
	, @objectid = OBJECT_ID(@twopartname)

IF UPPER(@DropAll) = 'FALSE'
BEGIN
	-- Get the list of all column-level statistics
	SELECT @twopartname + N'.' + QUOTENAME([s].[name], N']') AS [Since @DropAll = False, the statistics will only be listed, NOT dropped:]
	FROM [sys].[stats] AS [s]
	WHERE [s].[object_id] = @objectid
		AND INDEX_COL(OBJECT_NAME([s].[object_id]), [s].[stats_id], 1) = @columnname
		AND INDEX_COL(OBJECT_NAME([s].[object_id]), [s].[stats_id], 2) IS NULL
		AND (INDEXPROPERTY ([s].[object_id], [s].[name], 'IsStatistics') = 1
			OR INDEXPROPERTY ([s].[object_id], [s].[name], 'IsHypothetical') = 1)       
END

IF UPPER(@DropAll) = 'TRUE'
BEGIN	
	-- Cursor over all objects
	DECLARE StatisticsToDropCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT @twopartname + N'.' + QUOTENAME([s].[name], N']')
	FROM [sys].[stats] AS [s]
	WHERE [s].[object_id] = @objectid
		AND INDEX_COL(OBJECT_NAME([s].[object_id]), [s].[stats_id], 1) = @columnname
        AND INDEX_COL(OBJECT_NAME([s].[object_id]), [s].[stats_id], 2) IS NULL
        AND [s].[name] LIKE 'SQLskills[_]FS%'
		AND (INDEXPROPERTY ([s].[object_id], [s].[name], 'IsStatistics') = 1
			OR INDEXPROPERTY ([s].[object_id], [s].[name], 'IsHypothetical') = 1)
	    
	OPEN StatisticsToDropCursor

	FETCH StatisticsToDropCursor
    INTO @statistictodrop

	WHILE @@fetch_status = 0
	BEGIN
		SELECT @execstring = N'DROP STATISTICS ' + @statistictodrop
		--SELECT @execstring
		EXEC (@execstring)
		FETCH StatisticsToDropCursor
		    INTO @statistictodrop
	END
END
GO

EXEC [sys].[sp_MS_marksystemobject] 'sp_SQLskills_DropAllColumnStats';
GO