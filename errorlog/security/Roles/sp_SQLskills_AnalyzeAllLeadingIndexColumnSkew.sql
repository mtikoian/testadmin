USE [master];
GO

IF OBJECT_ID(N'sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew') IS NOT NULL
	DROP PROCEDURE [dbo].[sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew]
(
	@schemaname			sysname = NULL			
						-- Specific schema
	, @objectname		sysname = NULL
						-- Specific object: table/view
	, @difference		int = 1000
						-- Looking for the minimum difference between average
						-- and biggest difference in that step
	, @factor			decimal(5, 2) = 2.5
						-- Looking for the minimum factor of the difference
						-- against the average
	, @numofsteps		tinyint = 10
						-- This is the minimum number of steps that have to 
						-- have this @difference or @factor (or both)
	, @percentofsteps	tinyint = 10
						-- This is the minimum PERCENT of steps that have to 
						-- have this @difference or @factor (or both)
)
AS
SET NOCOUNT ON

DECLARE @columnname			sysname
	, @twopartname			nvarchar(520) = QUOTENAME(@schemaname, ']') + N'.' + QUOTENAME(@objectname, ']')
	, @schemanamedelimited	nvarchar(520) = QUOTENAME(@schemaname)
	, @objectnamedelimited	nvarchar(520) = QUOTENAME(@objectname)

IF (@schemaname IS NOT NULL AND @objectname IS NOT NULL)
	AND NOT EXISTS 
		(SELECT * 
		FROM [INFORMATION_SCHEMA].[COLUMNS] AS [isc]
		WHERE [isc].[TABLE_SCHEMA] = @schemaname
			AND [isc].[TABLE_NAME] = @objectname)
BEGIN
	RAISERROR ('Proc:sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew, @schemaname = %s, @objectname = %s. Object does not exist in this schema or this database. Check to make sure you''re in the correct database and that you did not supply an already delimited value. Additionally, these parameters are case-sensitive when the database is case-sensitive.', 16, -1, @schemanamedelimited, @objectnamedelimited)
	RETURN
END

IF (@schemaname IS NULL AND @objectname IS NULL)
-- Open cursor over schema/object/leading columns
DECLARE LeadingColumnsCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT DISTINCT 
		  [schema_name]	= SCHEMA_NAME([so].[schema_id])
		, [object_name]	= [so].[name]
		, [column_name]	= COL_NAME([so].[object_id], [sic].[column_id])
	FROM [sys].[objects] AS [so]
		INNER JOIN [sys].[indexes] AS [si]
			ON [so].[object_id] = [si].[object_id]
		INNER JOIN [sys].[index_columns] AS [sic]
			ON [si].[object_id] = [sic].[object_id]
				AND [si].[index_id] = [sic].[index_id]
		INNER JOIN [sys].[columns] AS [sc]
			ON [so].[object_id] = [sc].[object_id]
				AND [sc].[column_id] = [sic].[column_id]
		INNER JOIN [INFORMATION_SCHEMA].[COLUMNS] AS [isc]
			ON [so].[name] = [isc].[TABLE_NAME] 
				AND [so].[schema_id] = SCHEMA_ID([isc].[TABLE_SCHEMA])
				AND [sc].[name] = [isc].[COLUMN_NAME] 
	WHERE [so].[type] IN ('U','V') 
		AND OBJECTPROPERTY([so].[object_id], 'IsIndexed') = 1
		AND [so].[name] NOT LIKE '#%'
		AND [isc].[DATA_TYPE] NOT IN ('xml', 'hierarchyid')
		AND COLUMNPROPERTY([so].[object_id], COL_NAME([so].[object_id], [sic].[column_id]), 'ISComputed') = 0
		AND COLUMNPROPERTY([so].[object_id], COL_NAME([so].[object_id], [sic].[column_id]), 'IsXmlIndexable') = 0
		AND ((SUBSTRING(CONVERT(varchar, SERVERPROPERTY('ProductVersion'))
				, 1, CHARINDEX('.', CONVERT(varchar, SERVERPROPERTY('ProductVersion')))-1) >= 11
					 AND INDEXPROPERTY([so].[object_id], [si].[name], 'IsColumnStore') = 0)
			OR
			(SUBSTRING(CONVERT(varchar, SERVERPROPERTY('ProductVersion'))
				, 1, CHARINDEX('.', CONVERT(varchar, SERVERPROPERTY('ProductVersion')))-1) < 12))
		AND [sic].[index_column_id] = 1

IF (@schemaname IS NOT NULL AND @objectname IS NOT NULL)	    
DECLARE LeadingColumnsCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT DISTINCT 
		  [schema_name]	= SCHEMA_NAME([so].[schema_id])
		, [object_name]	= [so].[name]
		, [column_name]	= COL_NAME([so].[object_id], [sic].[column_id])
	FROM [sys].[objects] AS [so]
		INNER JOIN [sys].[indexes] AS [si]
			ON [so].[object_id] = [si].[object_id]
		INNER JOIN [sys].[index_columns] AS [sic]
			ON [si].[object_id] = [sic].[object_id]
				AND [si].[index_id] = [sic].[index_id]
		INNER JOIN [sys].[columns] AS [sc]
			ON [so].[object_id] = [sc].[object_id]
				AND [sc].[column_id] = [sic].[column_id]
		INNER JOIN [INFORMATION_SCHEMA].[COLUMNS] AS [isc]
			ON [so].[name] = [isc].[TABLE_NAME] 
				AND [so].[schema_id] = SCHEMA_ID([isc].[TABLE_SCHEMA])
				AND [sc].[name] = [isc].[COLUMN_NAME] 
	WHERE [so].[object_id] = OBJECT_ID(@twopartname)
		AND [so].[type] IN ('U','V') 
		AND OBJECTPROPERTY([so].[object_id], 'IsIndexed') = 1
		AND [so].[name] NOT LIKE '#%'
		AND [isc].[DATA_TYPE] NOT IN ('xml', 'hierarchyid')
		AND COLUMNPROPERTY([so].[object_id], COL_NAME([so].[object_id], [sic].[column_id]), 'ISComputed') = 0
		AND COLUMNPROPERTY([so].[object_id], COL_NAME([so].[object_id], [sic].[column_id]), 'IsXmlIndexable') = 0
		AND ((SUBSTRING(CONVERT(varchar, SERVERPROPERTY('ProductVersion'))
				, 1, CHARINDEX('.', CONVERT(varchar, SERVERPROPERTY('ProductVersion')))-1) >= 11
					 AND INDEXPROPERTY([so].[object_id], [si].[name], 'IsColumnStore') = 0)
			OR
			(SUBSTRING(CONVERT(varchar, SERVERPROPERTY('ProductVersion'))
				, 1, CHARINDEX('.', CONVERT(varchar, SERVERPROPERTY('ProductVersion')))-1) < 12))	
		AND [sic].[index_column_id] = 1

OPEN LeadingColumnsCursor

FETCH LeadingColumnsCursor
    INTO @schemaname
		, @objectname	
		, @columnname

--SELECT @schemaname, @objectname, @columnname, @@FETCH_STATUS

WHILE @@fetch_status = 0
BEGIN
    EXEC sp_SQLskills_AnalyzeColumnSkew 
		  @schemaname		= @schemaname
		, @objectname		= @objectname
		, @columnname		= @columnname
		, @difference		= @difference
		, @factor			= @factor
		, @numofsteps		= @numofsteps
		, @percentofsteps	= @percentofsteps
	FETCH LeadingColumnsCursor
		INTO @schemaname
			, @objectname	
			, @columnname
END

CLOSE LeadingColumnsCursor 
DEALLOCATE LeadingColumnsCursor 

GO

EXEC [sys].[sp_MS_marksystemobject] 'sp_SQLskills_AnalyzeAllLeadingIndexColumnSkew';
GO