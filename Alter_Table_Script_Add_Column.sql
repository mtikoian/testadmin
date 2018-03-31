
DECLARE @TBL_NAME VARCHAR(100)

DECLARE @strDescription varchar(4000)
DECLARE @strDt			varchar(10)
DECLARE @strHeader		varchar(4000)
DECLARE @strSQL			varchar(4000)
DECLARE @strSQLTemp		varchar(4000)
DECLARE @srtSQLCatchBlock varchar(4000)
DECLARE @srtSQLTryBlock varchar(4000)
DECLARE @strDatabaseName varchar(30)
DECLARE @strTableName	varchar(200)
DECLARE @strSchemaName	varchar(30)
DECLARE @strColumnName  varchar(255)
DECLARE @strDataType	varchar(50)
DECLARE @strAllowNull	varchar(50)
DECLARE @ColumnCount INT

DECLARE @strAuthorName VARCHAR(100)
DECLARE @DataModelScriptId INT
DECLARE @ScriptType varchar(10)

SET @DataModelScriptId =0

set nocount on

SET @strDatabaseName ='NetikExt'
SET @strTableName ='IPCClientAccountInfo'
SET @strSchemaName ='ims'
SET @strAuthorName = 'HZPatel'--SYSTEM_USER
SET @strDt = CONVERT(CHAR(10),GETDATE(),101)
SET @strDescription ='Alter table to add column in the IPCClientAccountInfo table
In the NetikEXT database IPCClientAccountInfo and IPCClientAccountSleeve tables are existing tables(Staging tables) and 
these tables used by ECR, Dashboard reporting purpose and onbased loads data into these tables.
As per new request MDB-2903, to store additional information Onbase team new columns are addded
Note: As per Misba and Adam, in the March 2014 a new project will be started to move tables to NetIkIP database and normalize tables as per standards.
'

SET @strHeader ='
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
'


SET @srtSQLTryBlock = '
BEGIN TRY
'
SET @srtSQLCatchBlock='
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

set @strSQL ='

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

		PRINT ''<SchemaName>.<TableName>.<ColumnName> column added successfully''
	END
	ELSE
	BEGIN
		PRINT ''<SchemaName>.<TableName>.<ColumnName> column  alreday exists''
	END;
	
'

	UPDATE dbo.DataModelScript
		SET Script_Fl = 0
	WHERE 
		DatabaseName =	@strDatabaseName
	AND
		TableName =		@strTableName


  SELECT @ColumnCount =COUNT(1)
  FROM dbo.DataModelScript DMS
  WHERE 
	 DMS.DatabaseName =@strDatabaseName
  AND
	 DMS.TableName =@strTableName
  AND 
	ColumnName IS NOT NULL
  AND
		Script_Fl = 0

  --Print Heade information
  SET @strHeader = REPLACE(@strHeader,'<DatabaseName>',@strDatabaseName)
  SET @strHeader = REPLACE(@strHeader,'<TableName>',@strTableName)
  SET @strHeader = REPLACE(@strHeader,'<AuthorName>',@strAuthorName)
  SET @strHeader = REPLACE(@strHeader,'<DateTime>',@strDt) 
  SET @strHeader = REPLACE(@strHeader,'<ScriptDescription>',@strDescription) 

  PRINT @strHeader

  PRINT '--TOTAL COLUMNS to be added ' + cast(@ColumnCount as varchar(10))

  

  PRINT @srtSQLTryBlock
  
  WHILE(@ColumnCount >0)
  BEGIN


	SET @strSQLTemp = @strSQL

	SET @ColumnCount = @ColumnCount - 1

	SELECT TOP 1 
		@DataModelScriptId =  DMS.DataModelScriptId,
		@strColumnName = DMS.ColumnName,
		@strDataType   = Replace(DMS.Datatype,'char','varchar'),
		@strAllowNull  = case
							 when dms.IsAllowNull = 'Y' AND DMS.Datatype <> 'BIT' THEN 'NULL'
							 ELSE
								'NOT NULL'
						 end

	FROM dbo.DataModelScript DMS
	WHERE 
		DMS.DatabaseName =@strDatabaseName
	AND
		DMS.TableName =@strTableName
	AND 
		ColumnName IS NOT NULL 
	AND
		Script_Fl = 0


	UPDATE dbo.DataModelScript
		SET Script_Fl = 1
	WHERE DataModelScriptId =@DataModelScriptId


	SET @strSQLTemp = REPLACE(@strSQLTemp,'<TableName>',@strTableName)

	SET @strSQLTemp = REPLACE(@strSQLTemp,'<SchemaName>',@strSchemaName)

	SET @strSQLTemp = REPLACE(@strSQLTemp,'<ColumnName>',@strColumnName)

	SET @strSQLTemp = REPLACE(@strSQLTemp,'<DataType>',@strDataType)

	SET @strSQLTemp = REPLACE(@strSQLTemp,'<AllowNULL>',@strAllowNull)

	PRINT @strSQLTemp
  END

  PRINT @srtSQLCatchBlock