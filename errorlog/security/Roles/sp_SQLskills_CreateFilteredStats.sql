USE [master];
GO

IF OBJECT_ID(N'sp_SQLskills_CreateFilteredStats') IS NOT NULL
	DROP PROCEDURE [sp_SQLskills_CreateFilteredStats];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_SQLskills_CreateFilteredStats]
(
	@schemaname			sysname = NULL			
						-- Specific schema
	, @objectname		sysname = NULL			
						-- Specific object: table/view
	, @columnname		sysname = NULL			
						-- Specific column
	, @filteredstats	tinyint = 10
						-- this is the number of filtered statistics
						-- to create. For simplicity, you cannot
						-- create more filtered stats than there are
						-- steps within the histogram (mostly because
						-- not all data is uniform). Maybe in V2.
						-- And, 10 isn't necessarily 10. Because the 
						-- number might not divide easily there are 
						-- likely to be n + 1. And, if @everincreasing
						-- is 1 then you'll get n + 2. 
						-- (the default of 10 may create 11 or 12 stats)
	, @fullscan			varchar(8) = NULL
						-- Should be FULLSCAN or SAMPLE
						-- On the creation of the filtered stat
						-- Let SQL Server decide to fullscan or sample
						-- If you want to set FULLSCAN then you can 
						-- override the default
	, @samplepercent	tinyint = NULL
						-- If @samplepercent is defined then @fullscan
						-- must be SAMPLE.
)
AS
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @schemanamedelimited	nvarchar(520) = QUOTENAME(@schemaname)
	, @objectnamedelimited		nvarchar(520) = QUOTENAME(@objectname)
	, @columnnamedelimited		nvarchar(520) = QUOTENAME(@columnname)
	, @stattoanalyzedelimited	nvarchar(520) = NULL

IF (@schemaname IS NULL OR @objectname IS NULL OR @columnname IS NULL)
BEGIN
	RAISERROR ('Proc:sp_SQLskills_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. The @schemaname, @objectname, and @columnname parameters are ALL required. Do not supply a delimited value.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited)
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
	RAISERROR ('Proc:sp_SQLskills_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is not valid for schema.object:%s.%s. Check to make sure you''re in the correct database and that you did not supply an already delimited value. Additionally, these parameters are case-sensitive when the database is case-sensitive.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited, @schemanamedelimited, @objectnamedelimited)
	RETURN
END

RAISERROR ('-------------------------------------------------------------------------------------------------------------', 10, 1)
RAISERROR ('Creating filtered statistic for @schemaname = %s, @objectname = %s, @columnname = %s.'
	, 10, 1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited)

DECLARE @schemaid				int
	, @twopartname				nvarchar(520)
	, @objectid					int
	, @colid					smallint
	, @coldef					nvarchar(100)
	, @coldefcollationforcast	nvarchar(100)
	, @usecollation				bit = 0
	, @stattoanalyze			sysname
	, @statsdate				datetime
	, @histtoanalyze			sysname
	, @execstring				nvarchar(max)
	, @fetchrate				tinyint
	, @fetchcounter				tinyint = 0
	, @rowsgreaterdiff			tinyint
	, @rowsgreaterfactor		tinyint
	, @histsteps				tinyint
	, @minstepsfrompercent		tinyint
	, @factorforraiserror		varchar(6)

SELECT @schemaid = SCHEMA_ID(@schemaname)
	, @twopartname = QUOTENAME(@schemaname, ']') + N'.' + QUOTENAME(@objectname, ']')
	, @objectid = OBJECT_ID(@twopartname)

SELECT @colid = (SELECT [sc].[column_id]
				FROM [sys].[columns] AS [sc]
				WHERE [sc].[object_id] = @objectid
					AND [sc].[name] = @columnname)
	, @coldef = 
		CASE 
			WHEN [isc].[DATA_TYPE] IN ('tinyint', 'smallint', 'int', 'bigint')
				THEN [isc].[DATA_TYPE]
			WHEN [isc].[DATA_TYPE] IN ('char', 'varchar', 'nchar', 'nvarchar')
				THEN [isc].[DATA_TYPE] 
					+ '(' 
					+ CONVERT(varchar, [isc].[CHARACTER_MAXIMUM_LENGTH])
					+ ') ' 
					--+ ') COLLATE ' 
					--+ [isc].[COLLATION_NAME]
			WHEN [isc].[DATA_TYPE] IN ('datetime2', 'datetimeoffset', 'time')
				THEN [isc].[DATA_TYPE]
					+ '('
					+ CONVERT(varchar, [isc].[DATETIME_PRECISION])
					+ ')'
			WHEN [isc].[DATA_TYPE] IN ('numeric', 'decimal')
				THEN [isc].[DATA_TYPE]
					+ '('
					+ CONVERT(varchar, [isc].[NUMERIC_PRECISION])
					+ ', ' 
					+ CONVERT(varchar, [isc].[NUMERIC_SCALE])
					+ ')'
			WHEN [isc].[DATA_TYPE] IN ('float', 'decimal')
				THEN [isc].[DATA_TYPE]
					+ '('
					+ CONVERT(varchar, [isc].[NUMERIC_PRECISION])
					+ ')'
			WHEN [isc].[DATA_TYPE] = 'uniqueidentifier'
				THEN 'char(36)'			
			--WHEN [isc].[DATA_TYPE] IN ('bit', 'money', 'smallmoney', 'date', 'datetime', 'real', 'smalldatetime', 'hierarchyid', 'sql_variant')
			ELSE [isc].[DATA_TYPE]
		END
	, @coldefcollationforcast = 
		CASE 
			WHEN [isc].[DATA_TYPE] IN ('char', 'varchar', 'nchar', 'nvarchar')
				THEN [isc].[DATA_TYPE] 
					+ '(' 
					+ CONVERT(varchar, [isc].[CHARACTER_MAXIMUM_LENGTH])
					+ ')) COLLATE ' 
					+ [isc].[COLLATION_NAME]
			ELSE ''
		END
FROM [INFORMATION_SCHEMA].[COLUMNS] AS [isc]
WHERE [isc].[TABLE_SCHEMA] = @schemaname
	AND [isc].[TABLE_NAME] = @objectname
	AND [isc].[COLUMN_NAME] = @columnname

IF @coldef = 'XML' 
BEGIN
	RAISERROR ('Proc:sp_SQLskills_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is of type XML. This is not a valid data type for filtered statistic creation.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited)
	RETURN
END

IF @coldef = 'hierarchyid' 
BEGIN
	RAISERROR ('Proc:sp_SQLskills_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is of type hierarchyid. This is not a valid data type for filtered statistic creation.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited)
	RETURN
END

IF @coldefcollationforcast <> ''
	SELECT @usecollation = 1

-------------------------------------
-- First test
--SELECT @schemaid
--	, @twopartname
--	, @objectid
--	, @colid
--	, @coldef
-------------------------------------

-- Get the statistic on which our filtered stats will be based:
SELECT TOP 1 @stattoanalyze = [s].[name]
	, @stattoanalyzedelimited = QUOTENAME([s].[name], N']')
	, @statsdate = STATS_DATE([s].[object_id], [s].[stats_id])
FROM [sys].[stats] AS [s]
WHERE [s].[object_id] = @objectid
	AND INDEX_COL(OBJECT_NAME([s].[object_id]), [s].[stats_id], 1) = @columnname
	AND [s].[has_filter] = 0
	AND STATS_DATE([s].[object_id], [s].[stats_id]) = 
		(SELECT MAX(STATS_DATE([ssc].[object_id], [ssc].[stats_id]))
		FROM [sys].[stats] AS [ssc]
		WHERE [ssc].[object_id] = @objectid
			AND [ssc].[has_filter] = 0
			AND INDEX_COL(OBJECT_NAME([ssc].[object_id]), [ssc].[stats_id], 1) = @columnname)

-------------------------------------
-- Second test
--SELECT @stattoanalyze, @stattoanalyzedelimited, @statsdate
-------------------------------------

-- Create a "permanent" temp table in tempdb to hold a copy of the histogram
-- Why "permanent" - because we need to use EXEC (@string) a temp table won't work.

IF OBJECT_ID('tempdb..SQLskills_CurrentHistogramForFilteredStats') IS NOT NULL 
	DROP TABLE [tempdb]..[SQLskills_CurrentHistogramForFilteredStats]

SELECT @execstring = N'CREATE TABLE [tempdb]..[SQLskills_CurrentHistogramForFilteredStats]' 
	+	N' ( RANGE_HI_KEY ' + @coldef + ' NULL,
		RANGE_ROWS				bigint,
		EQ_ROWS					bigint,
		DISTINCT_RANGE_ROWS		bigint,
		AVG_RANGE_ROWS			decimal(28,4));'
--SELECT @execstring
EXEC (@execstring)

SELECT @execstring = N'INSERT [tempdb]..[SQLskills_CurrentHistogramForFilteredStats] ' +
	N' EXEC (''DBCC SHOW_STATISTICS(''''' 
				+ @schemaname + '.' + @objectname + N''''',''''' 
				+ @stattoanalyze + N''''') WITH HISTOGRAM, NO_INFOMSGS'')'
--SELECT @execstring
EXEC (@execstring)

--SELECT * FROM [tempdb]..[SQLskills_CurrentHistogramForFilteredStats]

-- Clean up all other SINGLE column filtered stats 
-- and non-filtered column-level stats for this column
EXEC [sp_SQLskills_DropAllColumnStats]
	  @schemaname		= @schemaname
	, @objectname		= @objectname
	, @columnname		= @columnname
	, @DropAll			= 'TRUE'

SELECT @histsteps = count(*) 
FROM [tempdb]..[SQLskills_CurrentHistogramForFilteredStats]

IF @histsteps < @filteredstats
BEGIN
	RAISERROR ('Proc:sp_SQLskills_CreateFilteredStats, @schemaname = %s, @objectname = %s, @columnname = %s. The histogram:%s has only %d steps. You must create your filtered statistics manually.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @stattoanalyze, @histsteps)
	RETURN
END

-- This will define the specific step values that we'll use:
SELECT @fetchrate = FLOOR(@histsteps/(@filteredstats * 1.00))

-- Cursor over the rows 
-- starting with fetch first
-- then, stepping at the @fetchrate
-- stopping at @fetchrate = @filteredstats
-- then, doing a final one for less than fetch last

DECLARE @MinValue	sql_variant = NULL
		, @MaxValue	sql_variant = NULL
	
-- Open cursor over histogram rows
DECLARE [HistogramCursor] CURSOR 
LOCAL STATIC READ_ONLY FOR
	SELECT [Range_HI_KEY]
	FROM [tempdb]..[SQLskills_CurrentHistogramForFilteredStats]
	    
OPEN [HistogramCursor]

FETCH FIRST 
FROM [HistogramCursor]
    INTO @MinValue

FETCH RELATIVE @fetchrate 
FROM [HistogramCursor]
	INTO @MaxValue

WHILE @fetchcounter < @filteredstats
BEGIN
	IF @MaxValue > @MinValue
    EXEC [sp_SQLskills_CreateFilteredStatsString]
			  @schemaname				= @schemaname	
			, @objectname				= @objectname
			, @columnname				= @columnname
			, @twopartname				= @twopartname
			, @MinValue					= @MinValue
			, @MaxValue					= @MaxValue
			, @coldef					= @coldef
			, @coldefcollationforcast	= @coldefcollationforcast
			, @usecollation				= @usecollation
			, @fullscan					= @fullscan
			, @samplepercent			= @samplepercent

	SELECT @MinValue = @MaxValue
	FETCH RELATIVE @fetchrate 
	FROM [HistogramCursor]
		INTO @MaxValue
	SELECT @fetchcounter = @fetchcounter + 1
END

-- Create last statistic on actual set
FETCH LAST 
	FROM [HistogramCursor]
		INTO @MaxValue

--SELECT @MinValue AS [Min], @MaxValue AS [Max]

IF @MaxValue > @MinValue
    EXEC [sp_SQLskills_CreateFilteredStatsString]
	          @schemaname				= @schemaname	
		    , @objectname				= @objectname
		    , @columnname				= @columnname
		    , @twopartname				= @twopartname
		    , @MinValue					= @MinValue
		    , @MaxValue					= @MaxValue
		    , @coldef					= @coldef
		    , @coldefcollationforcast	= @coldefcollationforcast
		    , @usecollation				= @usecollation
		    , @fullscan					= @fullscan
		    , @samplepercent			= @samplepercent
	
-- Create final statistic on future set growth 
SELECT @MinValue = @MaxValue, @MaxValue = NULL

EXEC [sp_SQLskills_CreateFilteredStatsString]
			  @schemaname				= @schemaname	
			, @objectname				= @objectname
			, @columnname				= @columnname
			, @twopartname				= @twopartname
			, @MinValue					= @MinValue
			, @MaxValue					= NULL -- this will make it unbounded
			, @coldef					= @coldef
			, @coldefcollationforcast	= @coldefcollationforcast
			, @usecollation				= @usecollation
			, @fullscan					= @fullscan
			, @samplepercent			= @samplepercent
		
CLOSE [HistogramCursor] 
DEALLOCATE [HistogramCursor] 

BEGIN
	DROP TABLE [tempdb]..[SQLskills_CurrentHistogramForFilteredStats]
END
GO

EXEC [sys].[sp_MS_marksystemobject] N'sp_SQLskills_CreateFilteredStats';
GO