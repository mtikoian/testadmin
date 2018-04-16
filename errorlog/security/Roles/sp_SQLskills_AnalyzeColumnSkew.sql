USE [master];
GO

IF OBJECT_ID(N'sp_SQLskills_AnalyzeColumnSkew') IS NOT NULL
	DROP PROCEDURE [sp_SQLskills_AnalyzeColumnSkew];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_SQLskills_AnalyzeColumnSkew]
(
	@schemaname			sysname = NULL			
						-- Specific schema
	, @objectname		sysname = NULL			
						-- Specific object: table/view
	, @columnname		sysname = NULL			
						-- Specific column
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
	, @keeptable		char(5) = 'FALSE'		
						-- If TRUE keeps the table that holds the 
						-- histogram analysis results (in tempdb)
	, @tablename		nvarchar(520) = NULL OUTPUT		
						-- Fully delimited name of the table in tempdb

-- Considering for v2
--	, @slowanalyze	char(5) = 'FALSE'		
					-- No index that exists with this column as the 
					-- high-order element...analyze anyway. 
					-- NOTE: This might require MULTIPLE table scans. 
					-- I would NOT RECOMMEND THIS. I'm not even sure why I'm allowing this...
)
AS
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @schemanamedelimited	nvarchar(520) = QUOTENAME(@schemaname)
	, @objectnamedelimited		nvarchar(520) = QUOTENAME(@objectname)
	, @columnnamedelimited		nvarchar(520) = QUOTENAME(@columnname)

IF (@schemaname IS NULL OR @objectname IS NULL OR @columnname IS NULL)
BEGIN
	RAISERROR ('Proc:sp_SQLskills_AnalyzeColumnSkew, @schemaname = %s, @objectname = %s, @columnname = %s. The @schemaname, @objectname, and @columnname parameters are ALL required. Do not supply a delimited value.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited)
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
	RAISERROR ('Proc:sp_SQLskills_AnalyzeColumnSkew, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is not valid for schema.object:%s.%s. Check to make sure you''re in the correct database and that you did not supply an already delimited value. Additionally, these parameters are case-sensitive when the database is case-sensitive.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited, @schemanamedelimited, @objectnamedelimited)
	RETURN
END

IF (@difference IS NULL) AND (@factor IS NULL) 
	AND (@numofsteps IS NULL) AND (@percentofsteps IS NULL)
SELECT @difference = 1000, @numofsteps = 10
-- NOTE: We have to look for something?

RAISERROR ('-------------------------------------------------------------------------------------------------------------', 10, 1)
RAISERROR ('Begin processing @schemaname = %s, @objectname = %s, @columnname = %s.'
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
	, @rowsgreaterdiff			tinyint
	, @rowsgreaterfactor		tinyint
	, @histsteps				tinyint
	, @minstepsfrompercent		tinyint
	, @factorforraiserror		varchar(6)

SELECT @schemaid = SCHEMA_ID(@schemaname)
	, @twopartname = QUOTENAME(@schemaname, ']') + N'.' + QUOTENAME(@objectname, ']')
	, @objectid = OBJECT_ID(@twopartname)

SELECT @colid = (SELECT [sc].column_id
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
					+ ') COLLATE ' 
					+ [isc].[COLLATION_NAME]
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
	RAISERROR ('Proc:sp_SQLskills_AnalyzeColumnSkew, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is of type XML. This is not a valid data type for statistics analysis.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited)
	RETURN
END

IF @coldef = 'hierarchyid' 
BEGIN
	RAISERROR ('Proc:sp_SQLskills_AnalyzeColumnSkew, @schemaname = %s, @objectname = %s, @columnname = %s. Column:%s is of type hierarchyid. This is not a valid data type for statistics analysis.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited)
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

-- If an index does NOT exist - tell them they'll have to force the slow analysis.
-- Are we even going to allow a slow analysis? Not in V1
IF (SELECT count(*)
	FROM [sys].[index_columns] AS [sic]
	WHERE [sic].[object_id] = @objectid
		AND [sic].[column_id] = @colid
		AND [sic].[index_column_id] = 1) = 0
BEGIN
	RAISERROR ('Proc:sp_SQLskills_AnalyzeColumnSkew, @schemaname = %s, @objectname = %s, @columnname = %s. There are no indexes where column:%s is the leading column of the index. An efficient analysis cannot be done.', 16, -1, @schemanamedelimited, @objectnamedelimited, @columnnamedelimited, @columnnamedelimited)
	RETURN
END

-- Do any other histograms exist?
-- Looking for either an index or a statistic with this column as the leading column
-- If more than one exists, select the most recent
-- In other words: get the most current histogram

SELECT TOP 1 @stattoanalyze = [s].[name]
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

--SELECT @stattoanalyze

-- Create a "permanent" temp table in tempdb to hold a copy of the histogram
-- Why "permanent" - because we need to use EXEC (@string) a temp table won't work.

IF OBJECT_ID('tempdb..SQLskills_CurrentHistogramToAnalyze') IS NOT NULL 
	DROP TABLE [tempdb]..[SQLskills_CurrentHistogramToAnalyze]

SELECT @execstring = N'CREATE TABLE [tempdb]..[SQLskills_CurrentHistogramToAnalyze]' 
	+	N' ( RANGE_HI_KEY ' + @coldef + ' NULL,
		RANGE_ROWS				bigint,
		EQ_ROWS					bigint,
		DISTINCT_RANGE_ROWS		bigint,
		AVG_RANGE_ROWS			decimal(28,4));'
--SELECT @execstring
EXEC (@execstring)

SELECT @execstring = N'INSERT [tempdb]..[SQLskills_CurrentHistogramToAnalyze] ' +
	N' EXEC (''DBCC SHOW_STATISTICS(''''' 
				+ @schemaname + '.' + @objectname + N''''',''''' 
				+ @stattoanalyze + N''''') WITH HISTOGRAM, NO_INFOMSGS'')'
--SELECT @execstring
EXEC (@execstring)

--SELECT * FROM [tempdb]..[SQLskills_CurrentHistogramToAnalyze]

IF OBJECT_ID('tempdb..SQLskills_HistogramAnalysis') IS NOT NULL 
		DROP TABLE [tempdb]..[SQLskills_HistogramAnalysis]

SELECT @execstring = N'CREATE TABLE [tempdb]..[SQLskills_HistogramAnalysis] '
	+ '  ( StepID				int				identity NOT NULL,'
	+	N' RANGE_HI_KEY ' + @coldef + N' NULL,
		   AVERAGE_RANGE_ROWS	decimal(28,4)	NOT NULL,
		   MIN_RANGE_ROWS		bigint			NULL,
		   MAX_RANGE_ROWS		bigint			NULL,
		   BiggestDifference	bigint			NULL,
		   Factor				decimal(9,4)	NULL)'
--SELECT @execstring
EXEC (@execstring)

-- Cursor over the rows

DECLARE @MinValue	sql_variant = NULL
		, @MaxValue	sql_variant = NULL
		, @AvgRangeRows	decimal(28,4) = NULL
		
-- Open cursor over histogram rows
DECLARE HistogramCursor CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	SELECT Range_HI_KEY, AVG_RANGE_ROWS
	FROM [tempdb]..[SQLskills_CurrentHistogramToAnalyze]
	    
OPEN HistogramCursor

FETCH HistogramCursor
    INTO @MaxValue, @AvgRangeRows

WHILE @@fetch_status = 0
BEGIN
    IF (@MinValue IS NULL)
	BEGIN
		IF (@MaxValue IS NULL)
			FETCH HistogramCursor
				INTO @MaxValue, @AvgRangeRows
		SELECT @execstring = N'INSERT [tempdb]..[SQLskills_HistogramAnalysis]
			(Range_HI_Key, AVERAGE_RANGE_ROWS, MIN_RANGE_ROWS, MAX_RANGE_ROWS)
		VALUES (CAST(''' + REPLACE(CONVERT(varchar, @MaxValue), '''', '''''') + N''' AS ' 
			+ CASE	
				WHEN @usecollation = 0
					THEN @coldef + N')'
				WHEN @usecollation = 1
					THEN @coldefcollationforcast
			  END
		+ N', CONVERT(decimal(28,4), ''' + CONVERT(varchar, @AvgRangeRows) + N'''), NULL, NULL)'
		--SELECT @execstring
		EXEC (@execstring)
	END
	ELSE
	BEGIN
		SELECT @execstring = 
			N'INSERT [tempdb]..[SQLskills_HistogramAnalysis] '
			+ N' (Range_HI_Key, AVERAGE_RANGE_ROWS, MIN_RANGE_ROWS, MAX_RANGE_ROWS, BiggestDifference, Factor)'
			+ N' SELECT CAST(@MaxValue AS ' + CASE	
				WHEN @usecollation = 0
					THEN @coldef + N')'
				WHEN @usecollation = 1
					THEN @coldefcollationforcast
			  END
			+ N' , @AvgRangeRows, MinMax.MinCount, MinMax.MaxCount,'
			+ N' (SELECT MAX(V.Difference) FROM (VALUES (@AvgRangeRows-MinMax.MinCount), (MinMax.MaxCount-@AvgRangeRows)) AS V(Difference))'
			+ N' , (SELECT MAX(V.Difference) FROM (VALUES (@AvgRangeRows-MinMax.MinCount), (MinMax.MaxCount-@AvgRangeRows)) AS V(Difference))/@AvgRangeRows'
		    + N' FROM (SELECT MIN(AnalyzeRange.NumRows) AS MinCount, MAX(AnalyzeRange.NumRows) AS MaxCount'
			+ N' FROM (SELECT ' + QUOTENAME(@Columnname, ']') + N', COUNT(*) AS NumRows'
			+ N' FROM ' + @twopartname 
			+ N' WHERE ' + QUOTENAME(@Columnname, ']') + N' > CAST(@MinValue AS ' + CASE	
				WHEN @usecollation = 0
					THEN @coldef + N')'
				WHEN @usecollation = 1
					THEN @coldefcollationforcast
			  END
			+ N' AND '
			   		     + QUOTENAME(@Columnname, ']') + N' < CAST(@MaxValue AS ' + CASE	
				WHEN @usecollation = 0
					THEN @coldef + N')'
				WHEN @usecollation = 1
					THEN @coldefcollationforcast
			  END
			+ N' GROUP BY ' + QUOTENAME(@Columnname, ']') + N') AS AnalyzeRange) AS MinMax'
		--SELECT @execstring
		EXEC sp_executesql @execstring, 
					N'@MaxValue sql_variant, @AvgRangeRows decimal(28,4), @MinValue sql_variant',
                      @MaxValue, @AvgRangeRows, @MinValue
	END
	SELECT @MinValue = @MaxValue
	FETCH HistogramCursor
    INTO @MaxValue, @AvgRangeRows
END;

CLOSE HistogramCursor 
DEALLOCATE HistogramCursor 

-- What are we looking for?
SELECT @rowsgreaterdiff = count(*) 
	FROM [tempdb]..[SQLskills_HistogramAnalysis] 
	WHERE BiggestDifference > @difference

SELECT @rowsgreaterfactor = count(*) 
	FROM [tempdb]..[SQLskills_HistogramAnalysis] 
	WHERE Factor > @factor

DECLARE @percentforraiserror	varchar(10)
	, @columnnameforraiserror	nvarchar(520)
SELECT @histsteps = count(*) FROM [tempdb]..[SQLskills_HistogramAnalysis] 
SELECT @minstepsfrompercent = @histsteps * (@percentofsteps/100.00)
SELECT @factorforraiserror = convert(varchar, @factor)

IF ((@numofsteps IS NOT NULL AND @percentofsteps IS NOT NULL) AND (@rowsgreaterdiff > @numofsteps AND @rowsgreaterdiff > @minstepsfrompercent))
	OR ((@numofsteps IS NOT NULL AND @percentofsteps IS NULL) AND (@rowsgreaterdiff > @numofsteps))
	OR ((@numofsteps IS NULL AND @percentofsteps IS NOT NULL) AND (@rowsgreaterdiff > @minstepsfrompercent))
BEGIN
	SELECT @percentforraiserror = CONVERT(varchar(10), (CONVERT(decimal(5,2), @rowsgreaterdiff)/@histsteps) * 100)
	SELECT @percentforraiserror = SUBSTRING(@percentforraiserror, 1, CHARINDEX('.', @percentforraiserror) + 2)	
	SELECT @columnnameforraiserror = QUOTENAME(@columnname, N']')
	IF @numofsteps IS NOT NULL AND @percentofsteps IS NULL
		RAISERROR('Table: %s, column: %s has %d rows (of %d) with a greater difference than %d. This means that there are %d steps that will result in row estimations that are off by more than %d. Just analyzing step differences, this table has %s percent skew. This table shows signs of skew based on this criteria. You should consider filtered statistics on this column to help cardinality estimates.'
					, 10, 1, @twopartname, @columnnameforraiserror, @rowsgreaterdiff, @histsteps, @difference, @rowsgreaterdiff, @difference, @percentforraiserror)
	IF @percentofsteps IS NOT NULL
		RAISERROR('Table: %s, column: %s has %d rows (of %d) with a greater difference than %d. This means that there are %d steps that will result in row estimations that are off by more than %d. Just analyzing step differences, this table has %s percent skew (minimum of %d percent required by parameter). This table shows signs of skew based on this criteria. You should consider filtered statistics on this column to help cardinality estimates.'
					, 10, 1, @twopartname, @columnnameforraiserror, @rowsgreaterdiff, @histsteps, @difference, @rowsgreaterdiff, @difference, @percentforraiserror, @percentofsteps)
	SELECT @keeptable = 'TRUE'
END

IF ((@numofsteps IS NOT NULL AND @percentofsteps IS NOT NULL) AND (@rowsgreaterfactor > @numofsteps AND @rowsgreaterfactor > @minstepsfrompercent))
	OR ((@numofsteps IS NOT NULL AND @percentofsteps IS NULL) AND (@rowsgreaterfactor > @numofsteps))
	OR ((@numofsteps IS NULL AND @percentofsteps IS NOT NULL) AND (@rowsgreaterfactor > @minstepsfrompercent))
BEGIN
	SELECT @percentforraiserror = CONVERT(varchar(10), (CONVERT(decimal(5,2), @rowsgreaterfactor)/@histsteps) * 100)
	SELECT @percentforraiserror = SUBSTRING(@percentforraiserror, 1, CHARINDEX('.', @percentforraiserror) + 2)
	SELECT @columnnameforraiserror = QUOTENAME(@columnname, N']')
	IF @numofsteps IS NOT NULL AND @percentofsteps IS NULL
		RAISERROR('Table: %s, column: %s has %d rows (of %d) with a greater factor than %s. This means that there are %d steps that will result in row estimations that are off by more than %s times. Just analyzing the factor differences, this table has %s percent skew. This table shows signs of skew based on this criteria. You should consider filtered statistics on this column to help cardinality estimates.'
				, 10, 1, @twopartname, @columnnameforraiserror, @rowsgreaterfactor, @histsteps, @factorforraiserror, @rowsgreaterfactor, @factorforraiserror, @percentforraiserror)
	IF @percentofsteps IS NOT NULL
		RAISERROR('Table: %s, column: %s has %d rows (of %d) with a greater factor than %s. This means that there are %d steps that will result in row estimations that are off by more than %s times. Just analyzing the factor differences, this table has %s percent skew (minimum of %d percent required by parameter). This table shows signs of skew based on this criteria. You should consider filtered statistics on this column to help cardinality estimates.'
				, 10, 1, @twopartname, @columnnameforraiserror, @rowsgreaterfactor, @histsteps, @factorforraiserror, @rowsgreaterfactor, @factorforraiserror, @percentforraiserror, @percentofsteps)
	SELECT @keeptable = 'TRUE'
END

IF ((@rowsgreaterdiff <= @numofsteps AND @rowsgreaterfactor <= @numofsteps)
	AND (@rowsgreaterdiff <= @minstepsfrompercent AND @rowsgreaterfactor <= @minstepsfrompercent))
	OR (@rowsgreaterdiff <= @numofsteps AND @percentofsteps IS NULL AND @factor IS NULL)
	OR (@rowsgreaterfactor <= @numofsteps AND @percentofsteps IS NULL AND @difference IS NULL)
	OR (@rowsgreaterdiff <= @minstepsfrompercent AND @numofsteps IS NULL AND @factor IS NULL)
	OR (@rowsgreaterfactor <= @minstepsfrompercent AND @numofsteps IS NULL AND @difference IS NULL)
BEGIN
	SELECT @columnnameforraiserror = QUOTENAME(@columnname, N']')
	RAISERROR('Table: %s, column: %s shows no skew (based SOLELY on these parameters). You might want to review the worktable (@keeptable = ''TRUE'') to manually review the histogram analysis output.'
		, 10, 1, @twopartname, @columnnameforraiserror)
END

IF @keeptable = 'TRUE'
BEGIN
	SELECT @tablename = N'SQLskills_HistogramAnalysisOf' 
					+ N'_' + substring(db_name(), 1, 36)
					+ N'_' + substring(@schemaname, 1, 14) 
					+ N'_' + substring(@objectname, 1, 22) 
					+ N'_' + substring(@columnname, 1, 22)
	SELECT @execstring = 'USE tempdb; IF OBJECT_ID(''' + @tablename 
		+ N''') IS NOT NULL DROP TABLE ' + QUOTENAME(@tablename, ']') 
		+ N' EXEC sp_rename ''tempdb..SQLskills_HistogramAnalysis'', ' 
			+ QUOTENAME(@tablename, ']')
	EXEC (@execstring)
	SELECT @tablename = '[tempdb]..' + QUOTENAME(@tablename, ']')
	RAISERROR('Either parameter @keeptable = ''TRUE'' was chosen OR at least one of your criteria showed skew. As a result, we saved the table used for histogram analysis as %s. This table will need to be manually dropped or will remain in tempdb until it is recreated. If this procedure is run again, this table will be replaced (if @keeptable = ''TRUE'') but it will not be dropped unless you drop it.'
				, 10, 1, @tablename)
END
ELSE
BEGIN
	DROP TABLE [tempdb]..[SQLskills_CurrentHistogramToAnalyze]
	DROP TABLE [tempdb]..[SQLskills_HistogramAnalysis]
END
GO

EXEC [sys].[sp_MS_marksystemobject] 'sp_SQLskills_AnalyzeColumnSkew';
GO