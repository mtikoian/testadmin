CREATE PROCEDURE [dbo].[sp_CascadingDataViewerTableWrapper]
		@pDatabaseName		sysname
,		@pTableName			sysname
,		@pSchemaName		sysname
,		@pFilterCols		NVARCHAR(MAX)
,		@pAscending			bit				= 0
,		@pDependantLevels	smallint		= -1
,		@pDebug				bit				= 0
AS
BEGIN
	DECLARE	@pFilterCols2					NVARCHAR(MAX)
	,		@vSQL							NVARCHAR(MAX)	= ''
	,		@vNumberOfCommasInFilterCols	INT				= 0
	,		@vNumberOfCommasInFilterValues	INT				= 0
	,		@vFilterColsForCommaLoop		NVARCHAR(MAX)	= @pFilterCols
	,		@vFilterValuesForCommaLoop		NVARCHAR(MAX)
	,		@vComma							CHAR(1)			= ',';
	DECLARE	@FilterCols	TABLE (
			FilterVals	NVARCHAR(MAX)
	);
	WHILE CHARINDEX(@vComma,@vFilterColsForCommaLoop,0) > 0
	BEGIN
		SET		@vFilterColsForCommaLoop = SUBSTRING(@vFilterColsForCommaLoop,CHARINDEX(@vComma,@vFilterColsForCommaLoop,0) + 1, LEN(@vFilterColsForCommaLoop));
		SET		@vNumberOfCommasInFilterCols += 1;
	END	

	SET		@pFilterCols2 = 'CAST([' + REPLACE(@pFilterCols,',','] AS NVARCHAR(MAX)) + '','' + CAST([') + '] AS NVARCHAR(MAX))';
	SET		@vSQL = N'SELECT DISTINCT @pFilterCols2 AS FilterVals FROM [@pDatabaseName].[@pSchemaName].[@pTableName];';
	SET		@vSQL = REPLACE(REPLACE(REPLACE(REPLACE(@vSQL,'@pFilterCols2',@pFilterCols2),'@pSchemaName',@pSchemaName),'@pTableName',@pTableName),'@pDatabaseName',@pDatabaseName);

	INSERT	@FilterCols
	EXEC	sp_executesql @vSQL;

	DECLARE	_values CURSOR FOR
	SELECT	[FilterVals] 
	FROM	@FilterCols;

	DECLARE	@value NVARCHAR(MAX)
	,		@vNumberOfRows	INT
	,		@vCastedValue	NVARCHAR(MAX)
	,		@vStartTime		DATETIME2;
	DECLARE	@results TABLE (
			[FilterValues]	NVARCHAR(MAX)
	,		[NumberOfRows]	INT
	,		[TimeToCascade]	INT
	);
	OPEN	_values;

	FETCH NEXT FROM _values
	INTO	@value;
	WHILE	(@@FETCH_STATUS = 0)
	BEGIN
			SET		@vCastedValue = CAST(@value AS NVARCHAR(MAX));
			IF		@pDebug = 1
					PRINT	N'Processing value(s):' + @vCastedValue;
			SET		@vFilterValuesForCommaLoop = @vCastedValue;
			SET		@vNumberOfCommasInFilterValues = 0;
			WHILE	CHARINDEX(@vComma,@vFilterValuesForCommaLoop,0) > 0
			BEGIN
					SET		@vFilterValuesForCommaLoop = SUBSTRING(@vFilterValuesForCommaLoop,CHARINDEX(@vComma,@vFilterValuesForCommaLoop,0) + 1, LEN(@vFilterValuesForCommaLoop));
					SET		@vNumberOfCommasInFilterValues += 1;
			END	
			IF		@vNumberOfCommasInFilterValues = @vNumberOfCommasInFilterCols
			BEGIN
					SET		@vStartTime = SYSDATETIME();
					PRINT	@vCastedValue;
					EXEC	sp_CascadingDataViewer
								@pDatabaseName		=	@pDatabaseName
							,	@pTableName			=	@pTableName
							,	@pSchemaName		=	@pSchemaName
							,	@pNumberOfRows		=	@vNumberOfRows OUTPUT
							,	@pFilterCols		=	@pFilterCols
							,	@pFilterValues		=	@vCastedValue
							,	@pShowData			=	0
							,	@pDependantLevels	=	@pDependantLevels;
							INSERT	@results ([FilterValues],[NumberOfRows],[TimeToCascade])
							SELECT	@vCastedValue, @vNumberOfRows AS NumberOfRows, DATEDIFF(MS,@vStartTime,SYSDATETIME());
	
			END
			ELSE --@vNumberOfCommasInFilterValues <> @vNumberOfCommasInFilterCols
			BEGIN
					INSERT	@results ([FilterValues],[NumberOfRows],[TimeToCascade])
					SELECT	@vCastedValue, CAST(NULL AS INT) AS NumberOfRows, 0;
			END
	
			FETCH NEXT FROM _values
			INTO	@value;
	END
	CLOSE	_values;
	DEALLOCATE	_values;


	DECLARE	@vTotalRows				INT
	,		@vTotalTimeToCascade	INT;
	SELECT	@vTotalRows				= SUM(r.[NumberOfRows])
	,		@vTotalTimeToCascade	= SUM(r.[TimeToCascade])
	FROM	@results r;

	SELECT	q2.[FilterValues]
	,		q2.[NumberOfRows]
	,		q2.[PercentOfTotalRows]
	,		q2.[TimeToCascade]
	,		q2.[PercentOfTotalTimeToCascade]
	,		q2.[OutputOrder] AS [OrderId]
	FROM	(
			SELECT	q.[FilterValues]
			,		q.[NumberOfRows]
			,		q.[PercentOfTotalRows]
			,		q.[TimeToCascade]
			,		q.[PercentOfTotalTimeToCascade]
			,		CASE	WHEN	@pAscending = 0 THEN ROW_NUMBER() OVER (ORDER BY q.[NumberOfRows] DESC)
							ELSE	ROW_NUMBER() OVER (ORDER BY q.[NumberOfRows] ASC)
					END AS [OutputOrder]
			FROM	(
					SELECT	r.[FilterValues]
					,		r.[NumberOfRows]
					,		CASE	WHEN	r.[NumberOfRows] IS NOT NULL THEN CAST(r.NumberOfRows AS DECIMAL(38,5)) / CAST(@vTotalRows AS DECIMAL(38,5)) * 100
									ELSE	CAST(NULL AS DECIMAL(38,5))
							END	 AS [PercentOfTotalRows]
					,		r.[TimeToCascade]
					,		CASE	WHEN	r.[NumberOfRows] IS NOT NULL THEN CAST(r.[TimeToCascade] AS DECIMAL(38,5)) / CAST(@vTotalTimeToCascade AS DECIMAL(38,5)) * 100
									ELSE	CAST(NULL AS DECIMAL(38,5))
							END		AS [PercentOfTotalTimeToCascade]
					FROM	@results r
			)q
	) q2
	ORDER	BY q2.[OutputOrder] ASC;	
END