create proc [sp_CascadingDataViewer]
(
	@pDatabaseName		sysname
,	@pSchemaName		sysname
,	@pTableName			sysname
,	@pFilterCols		nvarchar(max)		--comma delimited list of columns on which to apply filter
,	@pFilterValues		nvarchar(max)		--comma delimited list of values to filter on
,	@pNumberOfRows		int				= 0 OUTPUT
,	@pShowData			bit				= 0 --display data
,	@pPrintSQL			bit				= 0 --Print dynamic SQL or not
,	@pDebug				bit				= 0 --Output data at various points for debugging purposes
,	@pDependantLevels	smallint		= -1
)
as
BEGIN
	SET NOCOUNT ON;
	SET	@pNumberOfRows = 0;
	DECLARE	@vColumnsAndValues	TABLE
	(
		column_ordinal		tinyint not null primary key
	,	column_name			sysname not null unique nonclustered
	,	column_value		nvarchar(max)
	,	column_type			sysname	null
	,	column_precision	tinyint null
	,	column_scale		tinyint null
	);
	DECLARE	@vSQL				NVARCHAR(MAX)
	,		@vSQL2				NVARCHAR(MAX)
	,		@vParmDefinition	NVARCHAR(MAX)
	,		@vNumberOfRows		INT
	,		@raiserrormsg NVARCHAR(2000);
	DECLARE @LEN INT;	
	DECLARE	@ErrorNumber		INT
	,		@ErrorMessage		nvarchar(2048)
	,		@ErrorState			INT
	,		@ErrorSeverity		INT
	,		@vNumSelfRefKeys	INT;	
	DECLARE	@vDepends	TABLE
	(
			TableNum						smallint
	,		Occurrence						smallint
	,		child_Schema					sysname
	,		child_Table						sysname
	,		parent_Schema					sysname
	,		parent_Table					sysname
	,		DependLevel						smallint
	,		fk_name							sysname
	,		uk_name							sysname
	,		HasNoDescendantTables			bit
	,		NumOccurencesOfDependantTable	int
	);
	DECLARE	@vSelfRefKeys	TABLE
	(
		ParentUniqueKey		sysname
	,	ChildForeignKey		sysname
	,	ParentColumn		sysname
	,	ChildColumn			sysname
	);
	DECLARE	@vPrimaryAndUniqueKeys	TABLE (
			[IndexName]		sysname
	,		[IsPrimaryKey]	bit
	,		[ColumnName]	sysname
	,		[key_ordinal]	int
	);
	DECLARE	@vIndexCols	TABLE
	(
		fk_name			sysname
	,	child_schema	sysname
	,	child_table		sysname
	,	parent_schema	sysname
	,	parent_table	sysname
	,	child_column	sysname
	,	parent_column	sysname
	);
	DECLARE	@vColumns	TABLE (
		[ColumnName]		sysname
	,	[ColumnType]		sysname
	)
	DECLARE	@vTableNum						smallint
	,		@vOccurrence					smallint
	,		@vHasNoDescendantTables			bit
	,		@vNumOccurencesOfDependantTable	int
	,		@vCurrentChildSchema			sysname
	,		@vCurrentChildTable				sysname
	,		@vCurrentParentSchema			sysname
	,		@vCurrentParentTable			sysname
	,		@vCurrentFKName					sysname
	,		@vCurrentUKName					sysname
	,		@vCurrentChildColumn			sysname
	,		@vCurrentParentColumn			sysname
	,		@vFirstColumnIteration			bit
	,		@vColumnOrdinal					tinyint
	,		@vColumnName					sysname
	,		@vColumnType					sysname
	,		@vColumnPrecision				tinyint
	,		@vColumnScale					tinyint
	,		@vColumnValue					nvarchar(max);
	SET		@LEN=LEN(@pFilterCols)+1;
	
	--Remove any apostrophes from @pFilterValues
	SET		@pFilterValues = REPLACE(CAST(@pFilterValues AS NVARCHAR(MAX)),'''','''''');

	/****Check input values****/
	--Check object names are not zero-length
	IF (LEN(@pDatabaseName) = 0 OR LEN(@pSchemaName) = 0 OR LEN(@pTableName) = 0)
	BEGIN
		SET	@raiserrormsg = 'Object names cannot be zero length';
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END
	--Check database exists
	IF NOT EXISTS (SELECT	[database_id]	FROM	sys.databases d	WHERE	d.[name] = @pdatabaseName)
	BEGIN
		SET @raiserrormsg = 'Supplied database @pDatabaseName name does not exist';
		SET	@raiserrormsg = REPLACE(@raiserrormsg,'@pDatabaseName',@pDatabaseName);
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END
	--Check executer can create tables (because he/she needs to be able to in order to exec this sproc)
	BEGIN TRY 
		SET	@vSQL = N'
		create table [@pDatabaseName]..[t]([i] int);
		drop table [@pDatabaseName]..[t];
		';
		SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabaseName);
		EXEC sp_executesql @vSQL;
	END TRY
	BEGIN CATCH
		SET @raiserrormsg = ERROR_MESSAGE();
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END CATCH

	--Check at least one column name has been supplied
	IF	(REPLACE(@pFilterCols,' ','') = '')
	BEGIN
		RAISERROR('You must specify at least value one for @pFilterCols',16,1);
		RETURN;
	END
	--Check at least one column value has been supplied
	IF	@pFilterValues = ''
	BEGIN
		RAISERROR('You must specify a value for @pFilterValues',16,1);
		RETURN;
	END
	--Check specified table is valid
	SET	@vSQL = 'SELECT * into #t FROM @pDatabaseName.sys.tables where name = ''@pTableName'' and OBJECT_SCHEMA_NAME(object_id,DB_ID(''@pDatabasename'')) = ''@pSchemaName'';'
	SET	@vSQL = REPLACE(@vSQL, '@pDatabaseName',	@pdatabaseName);
	SET	@vSQL = REPLACE(@vSQL, '@pTableName',		@pTableName);
	SET	@vSQL = REPLACE(@vSQL, '@pSchemaName',		@pSchemaName);
	IF	@pPrintSQL = 1
		PRINT @vSQL;
	EXEC	sp_executesql @vSQL;
	IF	@@ROWCOUNT = 0
	BEGIN
		SET @raiserrormsg = @pDatabaseName + '.' + @pSchemaName + '.' + @pTableName + ' is not a valid table';
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END
	--Check number of columns equals number of column values
	DECLARE	@vCommaStartPos					TINYINT = 0
	,		@vNumberOfColumnsIn_pFilterCols	TINYINT = 0
	,		@vNumberOfValuesIn_pFilterValues	TINYINT = 0;
	WHILE	( CHARINDEX(',',@pFilterCols,@vCommaStartPos + 1) > 0 )
	BEGIN
		SET	@vNumberOfColumnsIn_pFilterCols = @vNumberOfColumnsIn_pFilterCols + 1;
		SET	@vCommaStartPos = CHARINDEX(',',@pFilterCols,@vCommaStartPos + 1);
	END
	SET		@vCommaStartPos	= 0;
	WHILE	( CHARINDEX(',',@pFilterValues,@vCommaStartPos + 1) > 0 )
	BEGIN
		SET	@vNumberOfValuesIn_pFilterValues = @vNumberOfValuesIn_pFilterValues + 1;
		SET	@vCommaStartPos = CHARINDEX(',',@pFilterValues,@vCommaStartPos + 1);
	END
	IF	(@vNumberOfColumnsIn_pFilterCols != @vNumberOfValuesIn_pFilterValues)
	BEGIN
		RAISERROR('There must be the same count of values in @pFilterCols as there are columns in @pFilterValues',16,1);
		RETURN;
	END

	/***First things first ... convert list of columns & list of values into a table we can query over because we will need them later at numerous points ***/
	--Get list of specified columns first
	BEGIN TRY
			;With a AS
			( 
				SELECT	cast(1 as int) AS nStart, 
						cast(isNull(NULLIF(CHARINDEX(',',@pFilterCols,1),0),@LEN) as int) AS nEnd,
						RTRIM(LTRIM(SUBSTRING(@pFilterCols,1,isNull(NULLIF(CHARINDEX(',',@pFilterCols,1),0),@LEN)-1))) AS VALUE
				UNION All
				SELECT	cast(nEnd+1 as int), 
						cast(isNull(NULLIF(CHARINDEX(',',@pFilterCols,nEnd+1),0),@LEN) as int),
						RTRIM(LTRIM(SUBSTRING(@pFilterCols,nEnd+1,isNull(NULLIF(CHARINDEX(',',@pFilterCols,nEnd+1),0),@LEN)-nEnd-1)))
				FROM a
				WHERE nEnd<@LEN
			)
			INSERT	INTO @vColumnsAndValues (column_ordinal,column_name)
			SELECT Row_Number() OVER (ORDER BY nStart) as column_ordinal,
			NULLIF(VALUE,'') as column_name
			FROM a;
			IF	(@pDebug = 1)
			BEGIN
				SELECT	'@vColumnsAndValues' AS TableName,v.column_name,v.column_ordinal,v.column_type,v.column_value,v.column_precision,v.column_scale
				FROM	@vColumnsAndValues v;
			END
	END TRY
	BEGIN CATCH
			SET	@ErrorMessage	= ERROR_MESSAGE();
			SET	@ErrorNumber	= ERROR_NUMBER();
			SET	@ErrorSeverity	= ERROR_SEVERITY();
			SET	@ErrorState		= ERROR_STATE();
			IF (@ErrorNumber = 2627)
			BEGIN
				PRINT 'Cannot have repeated column names';
				RETURN;
			END
			ELSE
			BEGIN
				--rethrow
				RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);
				RETURN;
			END
	END CATCH

	--...followed by list of specified values
	SET		@LEN=LEN(@pFilterValues)+1;
	;With a AS
	( 
		SELECT	cast(1 as int) AS nStart, 
				cast(isNull(NULLIF(CHARINDEX(',',@pFilterValues,1),0),@LEN) as int) AS nEnd,
				RTRIM(LTRIM(SUBSTRING(@pFilterValues,1,isNull(NULLIF(CHARINDEX(',',@pFilterValues,1),0),@LEN)-1))) AS VALUE
		UNION All
		SELECT	cast(nEnd+1 as int), 
				cast(isNull(NULLIF(CHARINDEX(',',@pFilterValues,nEnd+1),0),@LEN) as int),
				RTRIM(LTRIM(SUBSTRING(@pFilterValues,nEnd+1,isNull(NULLIF(CHARINDEX(',',@pFilterValues,nEnd+1),0),@LEN)-nEnd-1)))
		FROM a
		WHERE nEnd<@LEN
	)
	MERGE	INTO @vColumnsAndValues tgt
	USING	(
			SELECT Row_Number() OVER (ORDER BY nStart) as column_ordinal,
			NULLIF(VALUE,'') as column_value
			FROM a
			) src
	ON		tgt.column_ordinal = src.column_ordinal
	WHEN	MATCHED THEN
			UPDATE
			SET		tgt.column_value = src.column_value;
	IF	(@pDebug = 1)
	BEGIN
		SELECT	'@vColumnsAndValues' AS TableName,v.column_name,v.column_ordinal,v.column_type,v.column_value,v.column_precision,v.column_scale
		FROM	@vColumnsAndValues v;
	END
	
	--Now get all the necessary type information
	IF EXISTS (SELECT * FROM tempdb.sys.tables where name = 'column_metadataXW64W' and SCHEMA_NAME(schema_id) = 'dbo')
			DROP TABLE tempdb.dbo.column_metadataXW64W;
	SET	@vSQL = N'
SELECT	q.column_name
,		CASE	WHEN	q.is_user_defined = 0 THEN q.column_type
				ELSE	N''['' + q.column_type_schema + N''].['' + q.column_type + N'']''
		END		AS column_type
,		q.column_precision
,		q.column_scale
INTO	tempdb.dbo.column_metadataXW64W --Just some arbitrary name that will never be used elsewhere.
FROM	(
		select	c.name as column_name,SCHEMA_NAME(t.schema_id) as column_type_schema,t.name as column_type,c.precision as column_precision,c.scale as column_scale,t.is_user_defined
		from	[@pDatabaseName].sys.columns c
		inner	join [@pDatabaseName].sys.types t --need to join to sys.types because TYPE_NAME does not work across DBs. Also we need to know is_user_defined.
		on		c.user_type_id = t.user_type_id
		where	OBJECT_NAME(c.object_id,DB_ID(''@pDatabaseName''))		=	''@pTableName''
		and		OBJECT_SCHEMA_NAME(c.object_id,DB_ID(''@pDatabaseName''))	=	''@pSchemaName''
		)q
--select	name as column_name, TYPE_NAME(user_type_id) as column_type,precision as column_precision,scale as column_scale
--into	tempdb.dbo.column_metadataXW64W --Just some arbitrary name that will never be used elsewhere.
--from	@pDatabaseName.sys.columns
--where	OBJECT_NAME(object_id,DB_ID(''@pDatabaseName''))		=	''@pTableName''
--and		OBJECT_SCHEMA_NAME(object_id,DB_ID(''@pDatabaseName''))	=	''@pSchemaName''
	';
	SET	@vSQL = REPLACE(@vSQL, '@pDatabaseName',	@pDatabaseName);
	SET	@vSQL = REPLACE(@vSQL, '@pSchemaName',		@pSchemaName);
	SET	@vSQL = REPLACE(@vSQL, '@pTableName',		@pTableName);
	IF	@pPrintSQL = 1
		PRINT @vSQL;
	EXECUTE	sp_executesql @vSQL;

	MERGE	INTO @vColumnsAndValues tgt
	USING	tempdb.dbo.column_metadataXW64W src
	ON		tgt.column_name = src.column_name
	WHEN	MATCHED THEN
			UPDATE
			SET		tgt.column_type			= src.column_type
			,		tgt.column_precision	= src.column_precision
			,		tgt.column_scale		= src.column_scale
			;
	drop table tempdb.dbo.column_metadataXW64W;
	/***End getting list of columns and all metadata ***/
	IF	(@pDebug = 1)
	BEGIN
		SELECT	'@vColumnsAndValues' AS TableName,v.column_name,v.column_ordinal,v.column_type,v.column_value,v.column_precision,v.column_scale
		FROM	@vColumnsAndValues v;
	END
	
	
	--********Check input values are valid as per the schema********
	--Check all specified columns exist
	SELECT	1 as countofnullcolnames
	INTO	#anynullcolnames
	FROM	@vColumnsAndValues
	WHERE	column_type IS NULL;
	IF	(@@ROWCOUNT > 0)
	BEGIN
			SET @raiserrormsg = 'Not all columns specified in @pFilterCols parameter exist in ' + @pDatabasename + '.' + @pSchemaName + '.' + @pTableName;
			RAISERROR(@raiserrormsg,16,1);
			RETURN;
	END
	--Check columns are of types we are set up to handle!
	SELECT	1 AS countofnhandledcolumntypes
	INTO	#anyunhandledcolumntypes
	FROM	@vColumnsAndValues
	WHERE	lower(column_type) NOT IN ('int','tinyint','smallint','bigint','varchar','nvarchar','char','nchar');
	IF	(@@ROWCOUNT > 0)
	BEGIN
			SET @raiserrormsg = 'Current version of ' + OBJECT_NAME(@@PROCID,DB_ID('master')) + ' only works for columns of type tinyint,smallint,int,bigint,varchar,nvarchar,char,nchar. Sorry!';
			RAISERROR(@raiserrormsg,16,1);
			RETURN;
	END
	
	--********End of checking input values are valid********
	
	--Discover tables dependent on named table
	SET	@vSQL =		N'
WITH	fk_tables AS
(
		SELECT	OBJECT_SCHEMA_NAME(parent_object_id,DB_ID(''@pDatabaseName'')) AS child_schema
		,		OBJECT_NAME(parent_object_id,DB_ID(''@pDatabaseName'')) AS child_table
		,		OBJECT_SCHEMA_NAME(referenced_object_id,DB_ID(''@pDatabaseName'')) AS parent_schema
		,		OBJECT_NAME(referenced_object_id,DB_ID(''@pDatabaseName'')) AS parent_table
		,		fk.Name AS fk_name 
		,		i.Name AS uk_name  --name of unique key in referenced (i.e. parent) table
		FROM	@pdatabaseName.sys.foreign_keys fk
		INNER	JOIN @pdatabaseName.sys.indexes i
		ON		fk.referenced_object_id = i.object_id
		AND		fk.key_index_id = i.index_id
		WHERE	i.is_unique = 1
),		dependents AS
(
		SELECT	fk.child_schema,fk.child_table,fk.parent_schema,fk.parent_table,1 AS DependLevel, fk.fk_name, fk.uk_name
		FROM	fk_tables fk
		WHERE	fk.parent_schema = ''@pSchemaName''
		AND		fk.parent_table = ''@pTableName''
		UNION	ALL
		SELECT	fk.child_schema,fk.child_table,fk.parent_schema,fk.parent_table,d.DependLevel + 1, fk.fk_name, fk.uk_name
		FROM	fk_tables fk
		INNER	JOIN dependents d
		ON		(	fk.parent_schema = d.child_schema
				AND		fk.parent_table = d.child_table)
		AND		NOT		(	fk.parent_schema = d.parent_schema
						AND	fk.parent_table = d.parent_table)
),		filtered_dependants AS
(
		SELECT	DISTINCT d.child_Schema, d.child_Table, d.parent_Schema, d.parent_Table, d.DependLevel, fk_name, uk_name 
		FROM	dependents d
		WHERE	d.[DependLevel] <= @pDependantLevels OR @pDependantLevels <= -1
),		number_of_table_occurences AS
(
		SELECT	fd.[child_schema],fd.[child_table],COUNT(*) AS [NumOccurencesOfDependantTable]
		FROM	filtered_dependants fd
		GROUP	BY fd.[child_schema],fd.[child_table]
)
SELECT	ROW_NUMBER() OVER (ORDER BY q.DependLevel ASC) AS TableNum
,		ROW_NUMBER() OVER (PARTITION BY q.child_table,q.child_schema ORDER BY q.DependLevel) AS Occurrence
,		q.child_schema,q.child_table,q.parent_schema,q.parent_table,q.DependLevel,q.fk_name,q.uk_name
,		CAST(CASE WHEN q2.parent_schema IS NULL THEN  1 ELSE 0 END AS BIT) AS HasNoDescendantTables
,		occ.[NumOccurencesOfDependantTable]
FROM	filtered_dependants q
INNER	JOIN number_of_table_occurences occ
ON		q.[child_schema] = occ.[child_schema]
AND		q.[child_table] = occ.[child_table]
LEFT	OUTER JOIN (	SELECT	DISTINCT fd.[parent_schema],fd.[parent_table]
						FROM	filtered_dependants fd) q2  --Joining back to itself to see if there are any dependant tables or not
ON		q.child_schema = q2.parent_schema
AND		q.child_table = q2.parent_table
;'

	SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName', @pdatabaseName);
	SET		@vSQL = REPLACE(@vSQL, '@pSchemaName', @pSchemaName);
	SET		@vSQL = REPLACE(@vSQL, '@pTableName', @pTableName);
	SET		@vSQL = REPLACE(@vSQL, '@pDependantLevels', @pDependantLevels);
	IF	(@pPrintSQL = 1)
			PRINT	@vSQL;
	INSERT	@vDepends
	EXEC	sp_executesql	@vSQL;
	IF	(@pDebug =1)
	BEGIN
			SELECT	'@vDepends' As TableName,v.TableNum,v.child_Schema,v.child_Table,v.parent_Schema,v.parent_Table,v.DependLevel,v.fk_name,v.uk_name
			FROM	@vDepends v
	END
	--Build SELECT statement for selecting the appropriate data from the starting table
	PRINT	N'Starting table: ' + @pTableName;
	SET		@vSQL = N'
SELECT	''@pSchemaName.@pTableName'' AS CascadingDataViewerTableName, c.*
INTO	[@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName]  --wanted to make this a temp table but then not referenceable from later dynamic SQL
FROM	[@pDatabaseName].[@pSchemaName].[@pTableName] c
'

	DECLARE	columns_cursor CURSOR FOR
	SELECT	column_ordinal, column_name,column_type,column_precision,column_scale,column_value
	FROM	@vColumnsAndValues;
	OPEN	columns_cursor;
	FETCH	NEXT	FROM columns_cursor 
	INTO	@vColumnOrdinal,@vColumnName,@vColumnType,@vColumnPrecision,@vColumnScale,@vColumnValue;
	WHILE	@@FETCH_STATUS = 0
	BEGIN
			SET	@vSQL = @vSQL + CASE WHEN @vColumnOrdinal = 1 THEN 'WHERE' ELSE 'AND' END + '	';
			SET	@vSQL = @vSQL + 'c.[' + @vColumnName + '] = ' +	CASE	WHEN	@vColumnType = 'int'		THEN	@vColumnValue
																		WHEN	@vColumnType = 'bigint'		THEN	@vColumnValue
																		WHEN	@vColumnType = 'tinyint'	THEN	@vColumnValue
																		WHEN	@vColumnType = 'smallint'	THEN	@vColumnValue
																		WHEN	@vColumnType = 'varchar'	THEN	'''' + @vColumnValue + ''''
																		WHEN	@vColumnType = 'nvarchar'	THEN	'''' + @vColumnValue + ''''
																		WHEN	@vColumnType = 'char'		THEN	'''' + @vColumnValue + ''''
																		WHEN	@vColumnType = 'nchar'		THEN	'''' + @vColumnValue + ''''
																		ELSE	'' --If we get to here then something has gone wrong elsewhere because above CASEs should cover all eventualities
																END + CHAR(10);
			FETCH	NEXT	FROM columns_cursor 
			INTO	@vColumnOrdinal,@vColumnName,@vColumnType,@vColumnPrecision,@vColumnScale,@vColumnValue;
	END	
	
	SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',	@pDatabaseName);
	SET		@vSQL = REPLACE(@vSQL, '@pTableName',		@pTableName);
	SET		@vSQL = REPLACE(@vSQL, '@pSchemaName',		@pSchemaName);
	
	SET		@vSQL = @vSQL + ';
SELECT	@RowCountOUT = @@ROWCOUNT;
';
	SET		@vParmDefinition = N'@RowCountOUT int OUTPUT';

	IF	@pPrintSQL = 1
			PRINT	@vSQL;
	EXEC	sp_executesql @vSQL, @vParmDefinition, @RowCountOUT = @pNumberOfRows OUTPUT ;

	--Is table self-referencing?
	SET		@vSQL = '
SELECT	i.[name] as ParentUniqueKey,fk.[name] as ChildForeignKey,c.[name] AS ParentColumn,fkcc.[name] AS ChildColumn
FROM	[@pDatabaseName].[sys].[tables] t 
INNER	JOIN [@pDatabaseName].[sys].[foreign_keys] fk
ON		t.object_id = fk.parent_object_id
LEFT	OUTER JOIN [@pDatabaseName].[sys].[indexes] i
ON		fk.[referenced_object_id] = i.[object_id]
AND		fk.[key_index_id] = i.[index_id]
INNER	JOIN [@pDatabaseName].[sys].[index_columns] ic
ON		i.[index_id] = ic.[index_id]
AND		i.[object_id] = ic.[object_id]
INNER	JOIN [@pDatabasename].[sys].[columns] c 
ON		ic.[object_id] = c.[object_id]
AND		ic.[column_id] = c.[column_id]
INNER	JOIN [@pDatabasename].[sys].[foreign_key_columns] fkc
ON		fk.[object_id] = fkc.constraint_object_id
INNER	JOIN [@pDatabaseName].[sys].[columns] fkcc
ON		fkc.[parent_column_id] = fkcc.column_id
AND		fkc.[parent_object_id] = fkcc.[object_id]
WHERE	t.[name] = ''@pTableName''
AND		t.[type] = ''U''
AND		OBJECT_SCHEMA_NAME(t.[object_id],DB_ID(''@pDatabaseName'')) = ''@pSchemaname''
AND		fk.parent_object_id = fk.referenced_object_id --AND table is referencing itself
;

SELECT	@NumSelfRefKeysOUT = @@ROWCOUNT;
';
	SET		@vParmDefinition = N'@NumSelfRefKeysOUT int OUTPUT';
	SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabasename);
	SET		@vSQL = REPLACE(@vSQL,'@pSchemaName',@pSchemaName);
	SET		@vSQL = REPLACE(@vSQL,'@pTableName',@pTableName);
	IF	(@pPrintSQL = 1)
			PRINT	@vSQL;

	INSERT	@vSelfRefKeys
	EXEC	sp_executesql	@vSQL, @vParmDefinition, @NumSelfRefKeysOUT = @vNumSelfRefKeys OUTPUT;
	IF	(@pDebug =1)
	BEGIN
			SELECT	'@vSelfRefKeys',ParentUniqueKey,ChildForeignKey,ParentColumn,ChildColumn
			FROM	@vSelfRefKeys v
	END
	IF	@vNumSelfRefKeys > 0
	BEGIN
		--Table is self-referencing so loop until there are no more rows to pull out
		--SELECT	ParentUniqueKey,ChildForeignKey,ParentColumn,ChildColumn
		--FROM	@vSelfRefKeys v
		SET		@vSQL = N'
DECLARE	@CumulativeRowCount int = 0
,		@CurrentIterationRowCount int = -1;

WHILE (@CurrentIterationRowCount <> 0)
BEGIN
	INSERT	[@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName]
	SELECT	''@pSchemaName.@pTableName'' AS CascadingDataViewerTableName, c.*
	FROM	[@pDatabaseName].[@pSchemaName].[@pTableName] c
	INNER	JOIN [@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName] p
';
		SET		@vFirstColumnIteration = 1;
		DECLARE	self_ref_cols_cursor	CURSOR FOR
		SELECT	ParentColumn,ChildColumn
		FROM	@vSelfRefKeys
		OPEN	self_ref_cols_cursor;
		FETCH	NEXT FROM self_ref_cols_cursor
		INTO	@vCurrentParentColumn,@vCurrentChildColumn;
		WHILE	@@FETCH_STATUS = 0
		BEGIN
				SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
												ELSE N'	AND' 
										END + N'		c.[' + @vCurrentChildColumn + N'] = p.[' + @vCurrentParentColumn + ']' + CHAR(10);
				SET		@vFirstColumnIteration = 0;
				FETCH	NEXT FROM self_ref_cols_cursor
				INTO	@vCurrentChildColumn,@vCurrentParentColumn;
		END	
		CLOSE	self_ref_cols_cursor;
		DEALLOCATE self_ref_cols_cursor;

		SET		@vSQL = @vSQL + N'	LEFT	OUTER JOIN [@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName] d ' + CHAR(10);
		SET		@vFirstColumnIteration = 1;
		--Loop over columns, building up SQL statement as we go!
		DECLARE	left_join_cursor	CURSOR FOR
		SELECT	ParentColumn
		FROM	@vSelfRefKeys
		OPEN	left_join_cursor;
		FETCH	NEXT FROM left_join_cursor
		INTO	@vCurrentParentColumn;
		WHILE	@@FETCH_STATUS = 0
		BEGIN
				SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
												ELSE N'	AND' 
										END + N'		c.[' + @vCurrentParentColumn + N'] = d.[' + @vCurrentParentColumn + ']' + CHAR(10);
				SET		@vFirstColumnIteration = 0;
				FETCH	NEXT FROM left_join_cursor
				INTO	@vCurrentParentColumn;
		END	
		CLOSE	left_join_cursor;
		DEALLOCATE left_join_cursor;
		SET		@vSQL = @vSQL + N'	WHERE	d.[' + @vCurrentParentColumn + '] IS NULL'

		SET		@vSQL = @vSQL + ';
	SELECT	@CurrentIterationRowCount = @@ROWCOUNT;  --Need to store @@ROWCOUNT because we need to reference it twice, once in the next line and once in the loop condition
	SELECT	@CumulativeRowCount = @CumulativeRowCount + @CurrentIterationRowCount;
END
SELECT	@RowCountOUT = @CumulativeRowCount;
';

		SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabasename);
		SET		@vSQL = REPLACE(@vSQL,'@pSchemaName',@pSchemaName);
		SET		@vSQL = REPLACE(@vSQL,'@pTableName',@pTableName);
		IF	(@pPrintSQL = 1)
			PRINT	@vSQL;
		SET		@vParmDefinition = N'@RowCountOUT int OUTPUT';
		EXEC	sp_executesql @vSQL, @vParmDefinition, @RowCountOUT = @vNumberOfRows OUTPUT ;
		SET		@pNumberOfRows = @pNumberOfRows + @vNumberOfRows;
	END

	--END of dealing with [@pSchemaName].[@pTableName]

	DECLARE	create_table_cursor	CURSOR FOR
	SELECT	[TableNum], [child_schema], [child_table], [parent_Schema], [parent_Table], [fk_name], [uk_name], [Occurrence], [HasNoDescendantTables], [NumOccurencesOfDependantTable]
	FROM	@vDepends
	ORDER BY [dependLevel] ASC,[Occurrence] ASC;
	
	OPEN	create_table_cursor;
	FETCH	NEXT FROM create_table_cursor
	INTO	@vTableNum, @vCurrentChildSchema,@vCurrentChildTable,@vCurrentParentSchema,
			@vCurrentParentTable,@vCurrentFKName,@vCurrentUKName,@vOccurrence,@vHasNoDescendantTables,@vNumOccurencesOfDependantTable;
	
	WHILE	@@FETCH_STATUS = 0
	BEGIN
			SET	@vSQL =	N'Current table: [@vCurrentChildSchema].[@vCurrentChildTable],  Dependant on: [@vCurrentParentSchema].[@vCurrentParentTable]';
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentChildSchema',@vCurrentChildSchema);
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentChildTable',@vCurrentChildTable);
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentParentSchema',@vCurrentParentSchema);
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentParentTable',@vCurrentParentTable);
			PRINT	@vSQL;
			DELETE FROM	@vIndexCols;
			--Get columns in unique key of named table		
			SET	@vSQL = N'
select	fk.name as fk_name
,		OBJECT_SCHEMA_NAME(fkc.parent_object_id, DB_ID(''@pDatabaseName'')) as child_schema
,		OBJECT_NAME(fkc.parent_object_id, DB_ID(''@pDatabaseName'')) as child_table
,		OBJECT_SCHEMA_NAME(fkc.referenced_object_id, DB_ID(''@pDatabaseName'')) as parent_schema
,		OBJECT_NAME(fkc.referenced_object_id, DB_ID(''@pDatabaseName'')) as parent_table
,		child_c.name as child_column
,		parent_c.name as parent_column
from	@pDatabaseName.sys.foreign_keys fk
inner	join @pDatabaseName.sys.foreign_key_columns fkc
on		fk.object_id = fkc.constraint_object_id
inner	join @pDatabaseName.sys.columns child_c
on		fkc.parent_object_id = child_c.object_id
and		fkc.parent_column_id = child_c.column_id
inner	join @pDatabaseName.sys.columns parent_c
on		fkc.referenced_object_id = parent_c.object_id
and		fkc.referenced_column_id = parent_c.column_id
where	fk.Name = ''@vCurrentFKName''
and		OBJECT_NAME(child_c.object_id,DB_ID(''@pDatabaseName'')) = ''@vCurrentChildTable''
and		OBJECT_SCHEMA_NAME(child_c.object_id,DB_ID(''@pDatabaseName'')) = ''@vCurrentChildSchema''
'
			
			SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentFKName',		@vCurrentFKName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
									
			INSERT	@vIndexCols
			EXEC	sp_executesql @vSQL;
			IF		@pDebug = 1
					SELECT	'@vIndexCols' AS TableName,v.fk_name,v.child_schema,v.child_table,v.child_column,v.parent_schema,v.parent_table,v.parent_column
					FROM	@vIndexCols v;
			
			--**********************************************
			--Build SELECT statements for selecting the appropriate data from the current dependent table
			DECLARE	@vChildTableName SYSNAME	= 'cascadingdataviewer_' + @vCurrentChildSchema + '_' + @vCurrentChildTable
			,		@vParentTableName SYSNAME	= 'cascadingdataviewer_' + @vCurrentParentSchema + '_' + @vCurrentParentTable;
			DECLARE	@vSelectList NVARCHAR(MAX) = N'
SELECT	''@vCurrentChildSchema.@vCurrentChildTable'' AS [CascadingDataViewerTableName]
		--I was originally going to include the name of the referenced table and the names of the keys but then realised that there may be more than one
		--reason for a row to be considered a dependant row, so I could not include this information.
		--CAST(''@vCurrentFKName'' AS SYSNAME) AS ReferencingKey, 
		--''@vCurrentParentSchema.@vCurrentParentTable'' AS ReferencedTable, 
		--CAST(''@vCurrentUKName'' AS SYSNAME) AS ReferencedKey, 
		--c.*
		';
		SET		@vSQL = '
SELECT	cols.[Name],TYPE_NAME(cols.user_type_id)
FROM	@pDatabaseName.sys.columns cols
WHERE	OBJECT_NAME(cols.object_id,DB_ID(''@pDatabasename'')) = ''@vCurrentChildTable''
AND		OBJECT_SCHEMA_NAME(cols.object_id,DB_ID(''@pDatabasename'')) = ''@vCurrentChildSchema''
';
		SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
		SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
		SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
		PRINT	@vSQL;
		DELETE	FROM @vColumns;
		INSERT	@vColumns
		EXEC	sp_executesql @vSQL;

		--Loop over list of columns in @pTableName so we can build up @vSelectList, making sure we treat each one of them appropriately
		DECLARE	col_cur	CURSOR
		FOR		SELECT [ColumnName],[ColumnType] FROM @vColumns;
		OPEN	col_cur;
		FETCH	NEXT FROM col_cur
		INTO	@vColumnName,@vColumnType;
		WHILE	(@@FETCH_STATUS = 0)
		BEGIN
				IF	(@vColumnType <> 'timestamp' AND @vColumnType <> 'rowversion') --future-proofing by including rowversion
				SET		@vSelectList = @vSelectList + N',c.[' + @vColumnName + N']';
		
				FETCH	NEXT FROM col_cur
				INTO	@vColumnName,@vColumnType;
		END
		CLOSE	col_cur;
		DEALLOCATE	col_cur;
		----------------------------------------------------------------
		---Get a list of all the candidate keys on the current table
		SET	@vSQL	=	'
select	i.name as IndexName
,		i.is_primary_key AS IsPrimaryKey
,		c.name AS ColumnName
,		ic.[key_ordinal]
from	[@pDatabaseName].sys.indexes i
INNER	JOIN [@pDatabaseName].sys.index_columns ic 
ON		i.object_id = ic.object_id
AND		i.index_id = ic.index_id
INNER	JOIN [@pDatabaseName].sys.columns c
ON		ic.object_id = c.object_id
AND		ic.column_id = c.column_id
WHERE	i.is_unique = 1
AND		OBJECT_NAME(i.object_id,DB_ID(''@pDatabaseName''))			= ''@vCurrentChildTable''
AND		OBJECT_SCHEMA_NAME(i.object_id,DB_ID(''@pDatabaseName''))	= ''@vCurrentChildSchema'';'
			SET	@vSQL = REPLACE(@vSQL, '@pDatabaseName',			@pDatabaseName);
			SET	@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',		@vCurrentChildTable);
			SET	@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
			IF	@pPrintSQL = 1
					PRINT	@vSQL;
			DELETE	FROM @vPrimaryAndUniqueKeys;
			INSERT	@vPrimaryAndUniqueKeys
			EXEC	sp_executesql	@vSQL;
			------End getting a list of all candidate keys on current dependant table
			----------------------------------------------------------------

			IF (		@vOccurrence = 1 
					AND	(@vCurrentChildTable <> @pTableName OR @vCurrentChildSchema <> @pSchemaName) --To deal with edge case where the dependant table is the same as the "starter" table (i.e. it has a self-reference)
			)  --Table has not yet been created
			BEGIN
					SET		@vSQL = @vSelectList + N'
INTO	[@pDatabaseName]..[@vChildTableName]  --wanted to make this a temp table but then not referenceable from later dynamic SQL
FROM	[@pDatabaseName].[@vCurrentChildSchema].[@vCurrentChildTable] c 
INNER	JOIN [sys].[tables] t  --Joining to any arbitrary table means that any identities on the original table will not get carried across
ON		t.[object_id] = t.[object_id]
WHERE	1 = 0; --Create an empty table';

					--Cursor to loop over all primary/unique constraints on the table
					DECLARE	key_cursor CURSOR FOR
					SELECT	DISTINCT k.IndexName,k.IsPrimaryKey
					FROM	@vPrimaryAndUniqueKeys k;
					DECLARE	@vIndexName			sysname
					,		@vIsPrimaryKey		bit
					,		@vIndexColumnName	sysname;
					OPEN	key_cursor;
					FETCH	NEXT FROM key_cursor
					INTO	@vIndexName,@vIsPrimaryKey;
					WHILE	@@FETCH_STATUS = 0
					BEGIN
							SET	@vSQL = @vSQL + '
ALTER	TABLE [@pDatabaseName]..[@vChildTableName] ADD CONSTRAINT [@vIndexname_cascadingdataviewer] ' + CASE WHEN @vIsPrimaryKey = 1 THEN 'PRIMARY KEY' ELSE 'UNIQUE' END + ' (';	
							--Cursor to loop over all column on the index
							DECLARE	index_column_names CURSOR FOR
							SELECT	k.[ColumnName]
							FROM	@vPrimaryAndUniqueKeys k
							WHERE	k.[IndexName] = @vIndexName
							ORDER	BY k.[key_ordinal] ASC;
							OPEN	index_column_names;
							FETCH	NEXT FROM index_column_names
							INTO	@vIndexColumnName;
							WHILE	@@FETCH_STATUS = 0
							BEGIN
									SET	@vSQL = @vSQL + '[' + @vIndexColumnName + '],';
									FETCH	NEXT FROM index_column_names
									INTO	@vIndexColumnName;
							END
							CLOSE	index_column_names;
							DEALLOCATE	index_column_names;
							SET		@vSQL = SUBSTRING(@vSQL,1,LEN(@vSQL)-1);--Get rid of the last comma
							SET		@vSQL = @vSQL + ');'; --close off the list of columns on the constraint
							SET		@vSQL = REPLACE(@vSQL, '@vIndexname',@vIndexname);
							FETCH	NEXT FROM key_cursor
							INTO	@vIndexName,@vIsPrimaryKey;
					END
					CLOSE	key_cursor;
					DEALLOCATE	key_cursor;

					SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentSchema',	@vCurrentParentSchema);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentTable',	@vCurrentParentTable);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentUKName',		@vCurrentUKName);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentFKName',		@vCurrentFKName);
					SET		@vSQL = REPLACE(@vSQL, '@vChildTableName',		@vChildTableName);
					SET		@vSQL = REPLACE(@vSQL, '@vParentTableName',		@vParentTableName);

					IF	@pPrintSQL = 1
							PRINT	@vSQL;
					--**********************************************
					EXEC	sp_executesql @vSQL;
			END

			SET		@vSQL = N'
DECLARE	@CumulativeRowCount int = 0
,		@CurrentIterationRowCount int = -1;

WHILE (@CurrentIterationRowCount <> 0) --we loop in order to take care of the case where the table is self-referencing
BEGIN';
			IF (@vHasNoDescendantTables = 1 AND @pShowData = 0 AND @vOccurrence = @vNumOccurencesOfDependantTable) --IF there is no need to store the data, don't store it!!!
					SET		@vSQL = @vSQL + N'
			SELECT	@CumulativeRowCount = COUNT(*)';
			ELSE
					SET		@vSQL = @vSQL + N'
			INSERT	INTO [@pDatabaseName]..[@vChildTableName]' + @vSelectList;

			SET		@vSQL = @vSQL + N'
			FROM	[@pDatabaseName].[@vCurrentChildSchema].[@vCurrentChildTable] c 
			INNER	JOIN [@pDatabaseName]..[@vParentTableName] p
';
			SET		@vFirstColumnIteration = 1;
			--Loop over columns, building up SQL statement as we go!
			DECLARE	cols_cursor	CURSOR FOR
			SELECT	child_column, parent_column
			FROM	@vIndexCols
			OPEN	cols_cursor;
			FETCH	NEXT FROM cols_cursor
			INTO	@vCurrentChildColumn,@vCurrentParentColumn;
			WHILE	@@FETCH_STATUS = 0
			BEGIN
					SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
													ELSE N'	AND' 
											END + N'		c.[' + @vCurrentChildColumn + N'] = p.[' + @vCurrentParentColumn + ']' + CHAR(10);
					SET		@vFirstColumnIteration = 0;
					FETCH	NEXT FROM cols_cursor
					INTO	@vCurrentChildColumn,@vCurrentParentColumn;
			END	
			CLOSE	cols_cursor;
			DEALLOCATE cols_cursor;
			IF EXISTS (SELECT 1 FROM @vPrimaryAndUniqueKeys) --If there are no candidate keys on the table then we can't join it to itself
			BEGIN
					SET		@vSQL = @vSQL + N'	LEFT	OUTER JOIN [@pDatabaseName]..[@vChildTableName] d ' + CHAR(10);
					SET		@vFirstColumnIteration = 1;
					--Loop over columns, building up SQL statement as we go!
					DECLARE	left_join_cursor	CURSOR FOR
					SELECT	p.[ColumnName]--,p.[key_ordinal]
					FROM	@vPrimaryAndUniqueKeys p
					INNER	JOIN ( --We get the MAX IndexName because we only need to join on the columns for one candidate key, it doesn't matter which one. Doing a MAX gives us that one.
							SELECT	MAX([IndexName]) AS [MaxIndexName]
							FROM	@vPrimaryAndUniqueKeys
					)m_p
					ON		p.[IndexName] = m_p.[MaxIndexName]
					ORDER	BY p.[key_ordinal] ASC;

					OPEN	left_join_cursor;
					FETCH	NEXT FROM left_join_cursor
					INTO	@vCurrentChildColumn;--,@vCurrentParentColumn;
					WHILE	@@FETCH_STATUS = 0
					BEGIN
							SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
															ELSE N'	AND' 
													END + N'		c.[' + @vCurrentChildColumn + N'] = d.[' + @vCurrentChildColumn + ']' + CHAR(10);
							SET		@vFirstColumnIteration = 0;
							FETCH	NEXT FROM left_join_cursor
							INTO	@vCurrentChildColumn;--,@vCurrentParentColumn;
					END	
					CLOSE	left_join_cursor;
					DEALLOCATE left_join_cursor;
					SET		@vSQL = @vSQL + N'	WHERE	d.[' + @vCurrentChildColumn + '] IS NULL'
			END

			IF (@vHasNoDescendantTables = 1 AND @pShowData = 0 AND @vOccurrence = @vNumOccurencesOfDependantTable) --IF this is the case then we're not storing the data and we've already captured @CumulativeRowCount, so break out of the loop
					SET		@vSQL = @vSQL + '
			SET	@CurrentIterationRowCount = 0;'; --this will break out of the loop
			ELSE
					
					SET		@vSQL = @vSQL + ';
			SELECT	@CurrentIterationRowCount = @@ROWCOUNT;  --Need to store @@ROWCOUNT because we need to reference it twice, once in the next line and once in the loop condition
			SELECT	@CumulativeRowCount = @CumulativeRowCount + @CurrentIterationRowCount;'
			IF NOT EXISTS (SELECT 1 FROM @vPrimaryAndUniqueKeys) --If there are no candidate keys on the table then we looping will be an infinite loop (cos it'll just carry on adding the same rows over and over again). So, break out of the loop.
			SET		@vSQL = @vSQL + '
			SET	@CurrentIterationRowCount = 0;'; --this will break out of the loop
			SET		@vSQL = @vSQL + '
END';
			SET		@vSQL = @vSQL + '

SELECT	@RowCountOUT = @CumulativeRowCount;
';
			
			SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentSchema',	@vCurrentParentSchema);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentTable',	@vCurrentParentTable);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentUKName',		@vCurrentUKName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentFKName',		@vCurrentFKName);
			SET		@vSQL = REPLACE(@vSQL, '@vChildTableName',		@vChildTableName);
			SET		@vSQL = REPLACE(@vSQL, '@vParentTableName',		@vParentTableName);

			IF	@pPrintSQL = 1
					PRINT	@vSQL;
			--**********************************************
			SET		@vParmDefinition = N'@RowCountOUT int OUTPUT';
			EXEC	sp_executesql @vSQL, @vParmDefinition, @RowCountOUT = @vNumberOfRows OUTPUT ;    --Copies the data into a temporary table so that we can show that data later (if the user has asked to see it)
			SET		@pNumberOfRows = @pNumberOfRows + @vNumberOfRows;
			FETCH	NEXT FROM create_table_cursor
			INTO	@vTableNum,@vCurrentChildSchema,@vCurrentChildTable,@vCurrentParentSchema,
					@vCurrentParentTable,@vCurrentFKName,@vCurrentUKName,@vOccurrence,@vHasNoDescendantTables,@vNumOccurencesOfDependantTable;
	END	
	CLOSE		create_table_cursor;
	DEALLOCATE	create_table_cursor;
	
	--SELECT all data from the tables we have created, in order that we created them.
	IF	@pShowData = 1
	BEGIN
			SET	@vChildTableName = N'cascadingdataviewer_' + @pSchemaName + N'_' + @pTableName;
			SET	@vSQL = N'
IF EXISTS(SELECT 1 FROM [@pDatabaseName]..[' + @vChildTableName + N'])
SELECT	*
FROM	[@pDatabaseName]..[' + @vChildTableName + N'];';
			SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
			IF	@pPrintSQL = 1 PRINT @vSQL;
			EXEC sp_executesql @vSQL;


			DECLARE	select_cursor	CURSOR FOR
			SELECT	q.child_schema, q.child_table
			FROM	(
					SELECT	MIN(v.TableNum)MinTableNum,v.child_schema, v.child_table
					FROM	@vDepends v
					WHERE	NOT	(		v.[child_schema]	=	@pSchemaName --this WHERE clause protects against the starter table being self-referencing. Without this WHERE clause
								AND		v.[child_table]		=	@pTableName) -- we would ultimately be selecting from it twice
					GROUP	BY v.child_schema, v.child_table
					)q
			ORDER	BY q.MinTableNum;

			OPEN	select_cursor;
			FETCH	NEXT FROM select_cursor
			INTO	@vCurrentChildSchema,@vCurrentChildTable;
			
			WHILE	@@FETCH_STATUS = 0
			BEGIN
					SET	@vChildTableName = N'cascadingdataviewer_' + @vCurrentChildSchema + N'_' + @vCurrentChildTable;
					SET		@vSQL = N'
IF EXISTS(SELECT 1 FROM [@pDatabaseName]..[' + @vChildTableName + '])
SELECT	*
FROM	[@pDatabaseName]..[' + @vChildTableName + N'];';
					SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
					IF	(@pPrintSQL = 1) PRINT @vSQL;
					EXECUTE	sp_executesql @vSQL;
					FETCH	NEXT FROM select_cursor
					INTO	@vCurrentChildSchema,@vCurrentChildTable;
			END
			CLOSE		select_cursor;
			DEALLOCATE	select_cursor;
	END
	
	--**********Cleanup temp tables
	DECLARE	delete_cursor	CURSOR FOR
	SELECT	DISTINCT child_schema, child_table
	FROM	@vDepends;

	OPEN	delete_cursor;
	FETCH	NEXT FROM delete_cursor
	INTO	@vCurrentChildSchema,@vCurrentChildTable;
	
	WHILE	@@FETCH_STATUS = 0
	BEGIN
			SET		@vSQL = N'DROP TABLE [@pDatabaseName]..[cascadingdataviewer_' + @vCurrentChildSchema + '_' + @vCurrentChildTable + ']';
			SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabaseName);
			IF	(@pPrintSQL = 1) PRINT @vSQL;
			
			IF	(@vCurrentChildSchema <> @pSchemaName OR @vCurrentChildTable <> @pTableName) --If the table to be dropped is the same as the "starter" table (i.e. it self-references), don't drop it (because it gets fropped later)
				EXECUTE	sp_executesql @vSQL;
			
			FETCH	NEXT FROM delete_cursor
			INTO	@vCurrentChildSchema,@vCurrentChildTable;
	END
	CLOSE		delete_cursor;
	DEALLOCATE	delete_cursor;
	
	--Drop the starting table!
	SET		@vSQL = N'DROP TABLE [@pDatabaseName]..[cascadingdataviewer_' + @pSchemaName + '_' + @pTableName + ']';
	SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabaseName);
	IF	(@pPrintSQL = 1) PRINT @vSQL;
	EXECUTE	sp_executesql @vSQL;
END

