DECLARE @Schemaname SYSNAME
	,@Tablename SYSNAME
	,@WhereClause NVARCHAR(2000)
	,@GenerateDeleteScripts BIT
	,@GenerateSelectScripts BIT

SET @Schemaname = 'dbo'                  --Change schema name 
SET @Tablename = 'users'				 --Change Table name 
SET @WhereClause = ''
SET @GenerateSelectScripts = 1
SET @GenerateDeleteScripts = 0		 -- 0 means disable and default value 
SET NOCOUNT ON

DECLARE @fkeytbl TABLE (
	ReferencingObjectid INT NULL
	,ReferencingSchemaname SYSNAME NULL
	,ReferencingTablename SYSNAME NULL
	,ReferencingColumnname SYSNAME NULL
	,PrimarykeyObjectid INT NULL
	,PrimarykeySchemaname SYSNAME NULL
	,PrimarykeyTablename SYSNAME NULL
	,PrimarykeyColumnname SYSNAME NULL
	,Hierarchy VARCHAR(max) NULL
	,LEVEL INT NULL
	,rnk VARCHAR(max) NULL
	,Processed BIT DEFAULT 0 NULL
	);

WITH fkey (
	ReferencingObjectid
	,ReferencingSchemaname
	,ReferencingTablename
	,ReferencingColumnname
	,PrimarykeyObjectid
	,PrimarykeySchemaname
	,PrimarykeyTablename
	,PrimarykeyColumnname
	,Hierarchy
	,LEVEL
	,rnk
	)
AS (
	SELECT soc.object_id
		,scc.NAME
		,soc.NAME
		,convert(SYSNAME, NULL)
		,convert(INT, NULL)
		,convert(SYSNAME, NULL)
		,convert(SYSNAME, NULL)
		,convert(SYSNAME, NULL)
		,CONVERT(VARCHAR(MAX), scc.NAME + '.' + soc.NAME) AS Hierarchy
		,0 AS LEVEL
		,rnk = convert(VARCHAR(max), soc.object_id)
	FROM SYS.objects soc
	JOIN sys.schemas scc ON soc.schema_id = scc.schema_id
	WHERE scc.NAME = @Schemaname
		AND soc.NAME = @Tablename
	
	UNION ALL
	
	SELECT sop.object_id
		,scp.NAME
		,sop.NAME
		,socp.NAME
		,soc.object_id
		,scc.NAME
		,soc.NAME
		,socc.NAME
		,CONVERT(VARCHAR(MAX), f.Hierarchy + ' --> ' + scp.NAME + '.' + sop.NAME) AS Hierarchy
		,f.LEVEL + 1 AS LEVEL
		,rnk = f.rnk + '-' + convert(VARCHAR(max), sop.object_id)
	FROM SYS.foreign_key_columns sfc
	JOIN Sys.Objects sop ON sfc.parent_object_id = sop.object_id
	JOIN SYS.columns socp ON socp.object_id = sop.object_id
		AND socp.column_id = sfc.parent_column_id
	JOIN sys.schemas scp ON sop.schema_id = scp.schema_id
	JOIN SYS.objects soc ON sfc.referenced_object_id = soc.object_id
	JOIN SYS.columns socc ON socc.object_id = soc.object_id
		AND socc.column_id = sfc.referenced_column_id
	JOIN sys.schemas scc ON soc.schema_id = scc.schema_id
	JOIN fkey f ON f.ReferencingObjectid = sfc.referenced_object_id
	WHERE ISNULL(f.PrimarykeyObjectid, 0) <> f.ReferencingObjectid
	)
INSERT INTO @fkeytbl (
	ReferencingObjectid
	,ReferencingSchemaname
	,ReferencingTablename
	,ReferencingColumnname
	,PrimarykeyObjectid
	,PrimarykeySchemaname
	,PrimarykeyTablename
	,PrimarykeyColumnname
	,Hierarchy
	,LEVEL
	,rnk
	)
SELECT ReferencingObjectid
	,ReferencingSchemaname
	,ReferencingTablename
	,ReferencingColumnname
	,PrimarykeyObjectid
	,PrimarykeySchemaname
	,PrimarykeyTablename
	,PrimarykeyColumnname
	,Hierarchy
	,LEVEL
	,rnk
FROM fkey

SELECT F.Relationshiptree
FROM (
	SELECT DISTINCT Replicate('------', LEVEL) + CASE LEVEL
			WHEN 0
				THEN ''
			ELSE '>'
			END + ReferencingSchemaname + '.' + ReferencingTablename 'Relationshiptree'
		,RNK
	FROM @fkeytbl
	) F
ORDER BY F.rnk ASC

------------------------------------------------------------------------------------------------------------------------------- 
-- Generate the Delete / Select script 
------------------------------------------------------------------------------------------------------------------------------- 
DECLARE @Sql VARCHAR(MAX)
DECLARE @RnkSql VARCHAR(MAX)
DECLARE @Jointables TABLE (
	ID INT IDENTITY
	,Object_id INT
	)
DECLARE @ProcessTablename SYSNAME
DECLARE @ProcessSchemaName SYSNAME
DECLARE @JoinConditionSQL VARCHAR(MAX)
DECLARE @Rnk VARCHAR(MAX)
DECLARE @OldTablename SYSNAME

IF @GenerateDeleteScripts = 1
	OR @GenerateSelectScripts = 1
BEGIN
	WHILE EXISTS (
			SELECT 1
			FROM @fkeytbl
			WHERE Processed = 0
				AND LEVEL > 0
			)
	BEGIN
		SELECT @ProcessTablename = ''

		SELECT @Sql = ''

		SELECT @JoinConditionSQL = ''

		SELECT @OldTablename = ''

		SELECT TOP 1 @ProcessTablename = ReferencingTablename
			,@ProcessSchemaName = ReferencingSchemaname
			,@Rnk = RNK
		FROM @fkeytbl
		WHERE Processed = 0
			AND LEVEL > 0
		ORDER BY LEVEL DESC

		SELECT @RnkSql = 'SELECT ' + REPLACE(@rnk, '-', ' UNION ALL SELECT ')

		DELETE
		FROM @Jointables

		INSERT INTO @Jointables
		EXEC (@RnkSql)

		IF @GenerateDeleteScripts = 1
			SELECT @Sql = 'DELETE [' + @ProcessSchemaName + '].[' + @ProcessTablename + ']' + CHAR(10) + ' FROM [' + @ProcessSchemaName + '].[' + @ProcessTablename + ']' + CHAR(10)

		IF @GenerateSelectScripts = 1
			SELECT @Sql = 'SELECT  [' + @ProcessSchemaName + '].[' + @ProcessTablename + '].*' + CHAR(10) + ' FROM [' + @ProcessSchemaName + '].[' + @ProcessTablename + ']' + CHAR(10)

		SELECT @JoinConditionSQL = @JoinConditionSQL + CASE 
				WHEN @OldTablename <> f.PrimarykeyTablename
					THEN 'JOIN [' + f.PrimarykeySchemaname + '].[' + f.PrimarykeyTablename + '] ' + CHAR(10) + ' ON '
				ELSE ' AND '
				END + ' [' + f.PrimarykeySchemaname + '].[' + f.PrimarykeyTablename + '].[' + f.PrimarykeyColumnname + '] =  [' + f.ReferencingSchemaname + '].[' + f.ReferencingTablename + '].[' + f.ReferencingColumnname + ']' + CHAR(10)
			,@OldTablename = CASE 
				WHEN @OldTablename <> f.PrimarykeyTablename
					THEN f.PrimarykeyTablename
				ELSE @OldTablename
				END
		FROM @fkeytbl f
		JOIN @Jointables j ON f.Referencingobjectid = j.Object_id
		WHERE charindex(f.rnk + '-', @Rnk + '-') <> 0
			AND F.LEVEL > 0
		ORDER BY J.ID DESC

		SELECT @Sql = @Sql + @JoinConditionSQL

		IF LTRIM(RTRIM(@WhereClause)) <> ''
			SELECT @Sql = @Sql + ' WHERE (' + @WhereClause + ')'

		PRINT @SQL
		PRINT CHAR(10)

		UPDATE @fkeytbl
		SET Processed = 1
		WHERE ReferencingTablename = @ProcessTablename
			AND rnk = @Rnk
	END

	IF @GenerateDeleteScripts = 1
		SELECT @Sql = 'DELETE FROM [' + @Schemaname + '].[' + @Tablename + ']'

	IF @GenerateSelectScripts = 1
		SELECT @Sql = 'SELECT * FROM [' + @Schemaname + '].[' + @Tablename + ']'

	IF LTRIM(RTRIM(@WhereClause)) <> ''
		SELECT @Sql = @Sql + ' WHERE ' + @WhereClause

	PRINT @SQL
END

SET NOCOUNT OFF
GO


