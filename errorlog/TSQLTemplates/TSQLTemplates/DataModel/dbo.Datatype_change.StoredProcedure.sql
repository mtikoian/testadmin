USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[Datatype_change]    Script Date: 12/30/2013 4:17:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Datatype_change] (
	-- Add the parameters for the stored procedure here	
	@strDatabaseName VARCHAR(20)
	,@strTableName VARCHAR(200)
	,@strSchemaName VARCHAR(30)
	,@strAuthorName VARCHAR(100)
	,@strDescription VARCHAR(4000)
	,@ScriptType VARCHAR(10)
	)
AS
BEGIN /*----Procedure Begin*/
	SET NOCOUNT ON

	/*Usage 
--to create
USE DBA
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[Datatype_change]
		@strDatabaseName = N'netikdp',
		@strTableName = N'DP_T_IssueActivity',
		@strSchemaName = N'dbo',
		@strAuthorName = N'vbandi',
		@strDescription = N'test',
		@ScriptType = 'create'

SELECT	'Return Value' = @return_value

GO
--to Rollback
DECLARE	@return_value int

EXEC	@return_value = [dbo].[Datatype_change]
		@strDatabaseName = N'netikdp',
		@strTableName = N'DP_T_IssueActivity',
		@strSchemaName = N'dbo',
		@strAuthorName = N'vbandi',
		@strDescription = N'test',
		@ScriptType = 'create'

SELECT	'Return Value' = @return_value

GO


*/
	DECLARE @TBL_NAME VARCHAR(100)
	DECLARE @strDt VARCHAR(10)
	DECLARE @strHeader VARCHAR(4000)
	DECLARE @strSQL VARCHAR(4000)
	DECLARE @strSQLTemp VARCHAR(4000)
	DECLARE @srtSQLCatchBlock VARCHAR(4000)
	DECLARE @srtSQLTryBlock VARCHAR(4000)
	DECLARE @strColumnName VARCHAR(255)
	DECLARE @strDataType VARCHAR(50)
	DECLARE @strAllowNull VARCHAR(50)
	DECLARE @ColumnCount INT
	DECLARE @DataModelScriptId INT

	SET @DataModelScriptId = 0
	--DECLARE @strDescription varchar(4000)
	--DECLARE @strDatabaseName varchar(30)
	--DECLARE @strTableName	varchar(200)
	--DECLARE @strSchemaName	varchar(30)
	--DECLARE @strAuthorName VARCHAR(100)
	--DECLARE @ScriptType varchar(10)
	--SET @strDatabaseName ='NETIKDP'
	--SET @strTableName ='DP_T_IssueActivity'
	--SET @strSchemaName ='dbo'
	--SET @strAuthorName = 'vperala'--SYSTEM_USER
	SET @strDt = CONVERT(CHAR(10), GETDATE(), 101)
	--SET @strDescription ='Alter table to increase column width to save Geneva data'
	--SET @ScriptType = 'ROLLBACK'
	SET @strHeader = '
USE <DatabaseName>
GO

/*     
==================================================================================================      
Name    : Alter_Table_<DatabaseName>_<TableName>.sql
Author  : <AuthorName>
Description : <ScriptDescription>
             
===================================================================================================      
 
History:      
      
Name				Date				Description      
---------------------------------------------------------------------------- 
<AuthorName>		<DateTime>			Initial Version      
========================================================================================================      
*/
DECLARE @ErrorEncountered BIT

SET @ErrorEncountered = 0;
'
	SET @srtSQLTryBlock = '
BEGIN TRY
IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = ''<SchemaName>''
				AND Table_name = ''<TableName>''
			)
BEGIN
'
	SET @srtSQLCatchBlock = '
--check for errors 
    IF @ErrorEncountered = 1
    BEGIN
        PRINT '' ''
        PRINT '' ''
        PRINT ''**********************''
        PRINT ''ERROR OCCURRED''
    END
    ELSE
    BEGIN
        PRINT '' ''
        PRINT '' ''
        PRINT ''**********************''
        PRINT ''Columns Altered Successfully for table <TableName> ''
      END
  END
  ELSE
  BEGIN
    PRINT ''Some error occured while altering table <TableName> !!!''
  END

END TRY

BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(2048);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;

	SET @ErrorMessage	= ''Error adding objects'' + ERROR_MESSAGE();
	SET @ErrorSeverity	= ERROR_SEVERITY();
	SET @ErrorState		= ERROR_STATE();

	RAISERROR (
				 @ErrorMessage
				,@ErrorSeverity
				,@ErrorState
			);
END CATCH
GO'
	SET @strSQL = '

	/*------------Alter <SchemaName>.<TableName>.<ColumnName> ----------------*/
	IF EXISTS 
	(
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE 
			TABLE_NAME = ''<TableName>'' AND
			TABLE_SCHEMA =''<SchemaName>'' AND	
			COLUMN_NAME = ''<ColumnName>''
	)
	BEGIN
		ALTER TABLE <SchemaName>.<TableName> 
			ALTER COLUMN <ColumnName> <DataType> 

		PRINT ''<SchemaName>.<TableName>.<ColumnName> column ALTERED successfully''
	END
	ELSE
	BEGIN
		PRINT ''<SchemaName>.<TableName>.<ColumnName> column NOT exists''
	END;
	
'

	UPDATE dbo.DataModelScript
	SET Script_Fl = 0
	WHERE DatabaseName = @strDatabaseName
		AND TableName = @strTableName

	SELECT *
	FROM DBA.dbo.DataModelScript DMS
	WHERE DMS.DatabaseName = @strDatabaseName
		AND DMS.TableName = @strTableName

	-- AND 
	--ColumnName IS NOT NULL
	-- AND
	--Script_Fl = 0
	SELECT @ColumnCount = COUNT(1)
	FROM DBA.dbo.DataModelScript DMS
	WHERE DMS.DatabaseName = @strDatabaseName
		AND DMS.TableName = @strTableName
		AND ColumnName IS NOT NULL
		AND Script_Fl = 0

	--Print Heade information
	SET @strHeader = REPLACE(@strHeader, '<DatabaseName>', @strDatabaseName)
	SET @strHeader = REPLACE(@strHeader, '<TableName>', @strTableName)
	SET @strHeader = REPLACE(@strHeader, '<AuthorName>', @strAuthorName)
	SET @strHeader = REPLACE(@strHeader, '<DateTime>', @strDt)
	SET @strHeader = REPLACE(@strHeader, '<ScriptDescription>', @strDescription)

	PRINT @strHeader
	PRINT '--TOTAL COLUMNS to be added ' + cast(@ColumnCount AS VARCHAR(10))

	SET @srtSQLTryBlock = REPLACE(@srtSQLTryBlock, '<TableName>', @strTableName)
	SET @srtSQLTryBlock = REPLACE(@srtSQLTryBlock, '<SchemaName>', @strSchemaName)

	PRINT @srtSQLTryBlock

	WHILE (@ColumnCount > 0)
	BEGIN
		SET @strSQLTemp = @strSQL
		SET @ColumnCount = @ColumnCount - 1

		SELECT TOP 1 @DataModelScriptId = DMS.DataModelScriptId
			,@strColumnName = DMS.ColumnName
			,@strDataType = CASE 
				WHEN @ScriptType = 'ROLLBACK'
					THEN DMS.DatatypeOld
				ELSE DMS.Datatype
				END
			,@strAllowNull = CASE 
				WHEN dms.IsAllowNull = 'Y'
					AND DMS.Datatype <> 'BIT'
					THEN 'NULL'
				ELSE 'NOT NULL'
				END
		FROM DBA.dbo.DataModelScript DMS
		WHERE DMS.DatabaseName = @strDatabaseName
			AND DMS.TableName = @strTableName
			AND ColumnName IS NOT NULL
			AND Script_Fl = 0
		ORDER BY DataModelScriptId

		UPDATE dbo.DataModelScript
		SET Script_Fl = 1
		WHERE DataModelScriptId = @DataModelScriptId

		--SELECT @strTableName,@strColumnName,@strSchemaName,@strDataType
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<TableName>', @strTableName)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<SchemaName>', @strSchemaName)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<ColumnName>', @strColumnName)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<DataType>', @strDataType)

		--SET @strSQLTemp = REPLACE(@strSQLTemp,'<AllowNULL>',@strAllowNull)
		PRINT @strSQLTemp
	END

	--PRINT @srtSQLCatchBlock
	SET @srtSQLCatchBlock = REPLACE(@srtSQLCatchBlock, '<TableName>', @strTableName)

	PRINT @srtSQLCatchBlock
END;/*----Procedure End*/

GO
