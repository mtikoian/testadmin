USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[Add_columns]    Script Date: 12/30/2013 4:17:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Add_columns] (
	-- Add the parameters for the stored procedure here	
	@strDatabaseName VARCHAR(20)
	,@strTableName VARCHAR(200)
	,@strSchemaName VARCHAR(30)
	,@strAuthorName VARCHAR(100)
	,@strDescription VARCHAR(4000)
	)
AS
BEGIN /*----Procedure Begin*/
	SET NOCOUNT ON

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
	DECLARE @ScriptType VARCHAR(10)
	DECLARE @ColDescription VARCHAR(4000) --vbandi

	SET @DataModelScriptId = 0
	--DECLARE @strDatabaseName varchar(30)
	--DECLARE @strTableName	varchar(200)
	--DECLARE @strSchemaName	varchar(30)
	--DECLARE @strAuthorName VARCHAR(100)
	--DECLARE @strDescription varchar(4000)
	--SET @strDatabaseName ='NetikExt'
	--SET @strTableName ='IPCClientAccountInfo'
	--SET @strSchemaName ='ims'
	--SET @strAuthorName = 'HZPatel'--SYSTEM_USER
	SET @strDt = CONVERT(CHAR(10), GETDATE(), 101)
	--SET @strDescription ='Alter table to add column in the IPCClientAccountInfo table
	--In the NetikEXT database IPCClientAccountInfo and IPCClientAccountSleeve tables are existing tables(Staging tables) and 
	--these tables used by ECR, Dashboard reporting purpose and onbased loads data into these tables.
	--As per new request MDB-2903, to store additional information Onbase team new columns are addded
	--Note: As per Misba and Adam, in the March 2014 a new project will be started to move tables to NetIkIP database and normalize tables as per standards.
	--'
	SET @strHeader = '
USE <DatabaseName>
GO

/*     
==================================================================================================      
Name    : Alter_Table_<TableName>.sql
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

	/*------------Add <SchemaName>.<TableName>.<ColumnName> ----------------*/
	IF NOT EXISTS 
	(
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE 
			TABLE_NAME = ''<TableName>'' AND
			TABLE_SCHEMA =''<SchemaName>'' AND	
			COLUMN_NAME = ''<ColumnName>''
	)
	BEGIN
		ALTER TABLE <SchemaName>.<TableName> ADD <ColumnName> <DataType> <AllowNULL>
		--''<Description>''
		PRINT ''<SchemaName>.<TableName>.<ColumnName> column added successfully''
	END
	ELSE
	BEGIN
		PRINT ''<SchemaName>.<TableName>.<ColumnName> column  alreday exists''
	END;
	
'

	UPDATE dbo.DataModelScript
	SET Script_Fl = 0
	WHERE DatabaseName = @strDatabaseName
		AND TableName = @strTableName

	SELECT @ColumnCount = COUNT(1)
	FROM DBA.dbo.DataModelScript DMS
	WHERE DMS.DatabaseName = @strDatabaseName
		AND DMS.TableName = @strTableName
		AND ColumnName IS NOT NULL
		AND Script_Fl = 0

	--Print Header information
	SET @strHeader = REPLACE(@strHeader, '<DatabaseName>', @strDatabaseName)
	SET @strHeader = REPLACE(@strHeader, '<TableName>', @strTableName)
	SET @strHeader = REPLACE(@strHeader, '<AuthorName>', @strAuthorName)
	SET @strHeader = REPLACE(@strHeader, '<DateTime>', @strDt)
	SET @strHeader = REPLACE(@strHeader, '<ScriptDescription>', @strDescription)

	--set @strHeader = REPLACE(@strHeader,'<ScriptDescription>',@strAuthorName) 
	PRINT @strHeader
	--PRINT '--TOTAL COLUMNS to be added ' + cast(@ColumnCount AS VARCHAR(10))
	SET @srtSQLTryBlock = REPLACE(@srtSQLTryBlock, '<TableName>', @strTableName)
	SET @srtSQLTryBlock = REPLACE(@srtSQLTryBlock, '<SchemaName>', @strSchemaName)
	PRINT @srtSQLTryBlock

	WHILE (@ColumnCount > 0)
	BEGIN
		SET @strSQLTemp = @strSQL
		SET @ColumnCount = @ColumnCount - 1

		SELECT TOP 1 @DataModelScriptId = DMS.DataModelScriptId
			,@strColumnName = DMS.ColumnName
			,@ColDescription = DMS.Description
			,--VBANDI
			@strDataType = DMS.Datatype
			,
			--Replace(DMS.Datatype,'char','varchar'),
			@strAllowNull = CASE 
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

		UPDATE dbo.DataModelScript
		SET Script_Fl = 1
		WHERE DataModelScriptId = @DataModelScriptId

		SET @strSQLTemp = REPLACE(@strSQLTemp, '<Description>', @ColDescription)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<TableName>', @strTableName)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<SchemaName>', @strSchemaName)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<ColumnName>', @strColumnName)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<DataType>', @strDataType)
		SET @strSQLTemp = REPLACE(@strSQLTemp, '<AllowNULL>', @strAllowNull)

		PRINT @strSQLTemp
	END
	SET @srtSQLCatchBlock = REPLACE(@srtSQLCatchBlock, '<TableName>', @strTableName)

	PRINT @srtSQLCatchBlock
END;/*----Procedure End*/

GO
