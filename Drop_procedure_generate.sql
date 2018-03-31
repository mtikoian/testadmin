set nocount on;

drop table #temp
Create table #temp 
(
SchemaNm varchar(100),
ObjectNm Varchar(250),
ObjectType varchar(100),
statusFl bit
)

insert into #temp

select 'dbo', 'brand', 'SQL_STORED_PROCEDURE', 1
union select 'dbo', 'company', 'SQL_STORED_PROCEDURE',1

/*
DEFAULT_CONSTRAINT
FOREIGN_KEY_CONSTRAINT
INTERNAL_TABLE
PRIMARY_KEY_CONSTRAINT
SERVICE_QUEUE
SQL_INLINE_TABLE_VALUED_FUNCTION
SQL_SCALAR_FUNCTION
SQL_STORED_PROCEDURE
SQL_TABLE_VALUED_FUNCTION
SQL_TRIGGER
SYSTEM_TABLE
UNIQUE_CONSTRAINT
USER_TABLE
VIEW
*/
--DECLARE @TableName varchar(100), 
--               @SQL varchar(1000)  
--SET @TableName = 'dbo.YourTableName' 
--SET @SQL = 
--'IF EXISTS( SELECT 1 FROM  dbo.sysobjects WHERE id = object_id(N' + CHAR(39) + @TableName + CHAR(39) +') ' + CHAR(10) + 
--' AND OBJECTPROPERTY(id, N' + CHAR(39) + 'IsUserTable' + CHAR(39) + ') = 1) ' 
--+ CHAR(10) -- + 'PRINT ' + CHAR(39) + 'WORKS' + CHAR(39) + CHAR(10)
--select  @SQL

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


SET @strDatabaseName ='Blackjackshared'
SET @strAuthorName = 'VBANDI'--SYSTEM_USER
SET @strDt = CONVERT(CHAR(10),GETDATE(),101)
SET @strDescription =''

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
GO;'

set @strSQL ='

	/*------------Drop <SchemaName>.<TableName> ----------------*/
	IF EXISTS 
	(
		SELECT 1
		FROM INFORMATION_SCHEMA.TABLES
		WHERE 
			ROUTINE_NAME =  ''<TableName>'' AND
			SPECIFIC_SCHEMA =''<SchemaName>'' 
			AND ROUTINE_TYPE = ''Procedure''	
			
	)
	BEGIN
		 DROP TABLE <SchemaName>.<TableName> 

		PRINT ''<SchemaName>.<TableName> Table dropped successfully''
	END
	ELSE
	BEGIN
		PRINT ''<SchemaName>.<TableName> table not exists''
	END;
	
'

  SELECT @ColumnCount =COUNT(1)
  FROM #temp DMS


  --Print Heade information
  SET @strHeader = REPLACE(@strHeader,'<DatabaseName>',@strDatabaseName)
  SET @strHeader = REPLACE(@strHeader,'<TableName>',@strTableName)
  SET @strHeader = REPLACE(@strHeader,'<AuthorName>',@strAuthorName)
  SET @strHeader = REPLACE(@strHeader,'<DateTime>',@strDt) 
  SET @strHeader = REPLACE(@strHeader,'<ScriptDescription>',@strDescription) 

  PRINT @strHeader

  --PRINT '--TOTAL COLUMNS to be added ' + cast(@ColumnCount as varchar(10))


  PRINT @srtSQLTryBlock
  
  WHILE(@ColumnCount >0)
  BEGIN


	SET @strSQLTemp = @strSQL

	SET @ColumnCount = @ColumnCount - 1
	SELECT TOP 1 
	@strTableName = ObjectNm,
	@strSchemaName = SchemaNm
	FROM #temp DMS
	WHERE objectnm ='SQL_STORED_PROCEDURE' and statusFl = 1

	select @strSQLTemp
	SET @strSQLTemp = REPLACE(@strSQLTemp,'<TableName>',@strTableName)
	
	SET @strSQLTemp = REPLACE(@strSQLTemp,'<SchemaName>',@strSchemaName)
	select @strSQLTemp
	update #temp
	set statusFl = 0
	where ObjectNm = @strTableName  and SchemaNm = @strSchemaName 
	PRINT @strSQLTemp
  END

  PRINT @srtSQLCatchBlock