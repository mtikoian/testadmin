USE [DBA]
GO
/****** Object:  StoredProcedure [dbo].[create_table]    Script Date: 12/30/2013 4:17:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure 

[dbo].[create_table] 

as

DECLARE @strHeader VARCHAR(4000)
DECLARE @srtSQLCatchBlock VARCHAR(4000)
DECLARE @srtSQLTryBlock VARCHAR(4000)
DECLARE @strDatabaseName VARCHAR(30)
DECLARE @strTableName VARCHAR(200)
DECLARE @strSchemaName VARCHAR(30)
DECLARE @strAuthorName VARCHAR(100)
DECLARE @strDescription VARCHAR(4000)
DECLARE @strDt VARCHAR(10)

SET @strDatabaseName = 'NetikExt'
SET @strTableName = 'IPCClientAccountInfo'
SET @strSchemaName = 'ims'
SET @strAuthorName = 'HZPatel' --SYSTEM_USER
SET @strDt = CONVERT(CHAR(10), GETDATE(), 101)
SET @strDescription = 'Alter table to add column in the IPCClientAccountInfo table
	In the NetikEXT database IPCClientAccountInfo and IPCClientAccountSleeve tables are existing tables(Staging tables) and 
	these tables used by ECR, Dashboard reporting purpose and onbased loads data into these tables.
	As per new request MDB-2903, to store additional information Onbase team new columns are addded
	Note: As per Misba and Adam, in the March 2014 a new project will be started to move tables to NetIkIP database and normalize tables as per standards.
	'
SET @strHeader = '
USE <DatabaseName>
GO

/*     
==================================================================================================      
Name    : Create_Table_<TableName>.sql
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
IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = ''<SchemaName>''
				AND Table_name = ''<TableName>''
			)
BEGIN
DROP Table <SchemaName>.<TableName>
			PRINT ''<SchemaName>.<TableName> table has been dropped.''
		END
'

SET @srtSQLCatchBlock = '
 	-- Validate if the table has been created.
	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = ''<SchemaName>''
				   AND Table_name = ''<TableName>''
		)
		BEGIN
			PRINT ''<SchemaName>.<TableName> has been created.''
		END
	ELSE
		BEGIN
			PRINT ''Failed to create Table <SchemaName>.<TableName>!!!!!!!''
		END

END TRY
BEGIN CATCH
  DECLARE @error_Message VARCHAR(2100); 
        DECLARE @error_Severity INT; 
        DECLARE @error_State INT; 
	
        SET @error_Message = Error_Message() 
        SET @error_Severity = Error_Severity() 
        SET @error_State = Error_State()         

        RAISERROR (@error_Message,@error_Severity,@error_State); 
END CATCH;
PRINT '''';
PRINT ''End of TABLE script for <SchemaName>.<TableName>'';
PRINT ''----------------------------------------'';'
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

--====================================================================================================
--DDL Generator 
--====================================================================================================
--Script created by Ryan Foote.
SET NOCOUNT ON

DECLARE @Generate TABLE (
	ColumnName CHAR(35)
	,DataType CHAR(30)
	,Nullability VARCHAR(400)
	)
DECLARE @FinalTable TABLE (CreateStatement VARCHAR(400))
DECLARE @tblPrimaryKey TABLE (
	PrimaryKeyID INT identity(1, 1)
	,ColumnName VARCHAR(500) NULL
	,IndexDefinition VARCHAR(500) NULL
	)
DECLARE @PrimaryKey VARCHAR(50)
DECLARE @TableName VARCHAR(100)

SET @TableName = 'DataModelScript' --<<Enter the table name here

IF NOT EXISTS (
		SELECT *
		FROM sysobjects
		WHERE id = object_id(@TableName)
			AND objectproperty(ID, N'IsUserTable') = 1
		)
BEGIN
	PRINT 'Table Name ' + @TableName + ' is not a valid table'

	GOTO KickOut
END
ELSE IF EXISTS (
		SELECT *
		FROM sysobjects
		WHERE id = object_id(@TableName)
			AND objectproperty(ID, N'IsUserTable') = 1
		)
BEGIN
	INSERT INTO @Generate (
		ColumnName
		,DataType
		,Nullability
		)
	SELECT CASE 
			WHEN syscolumns.colid = 1
				THEN ' '
			ELSE ','
			END + left(syscolumns.NAME, 40)
		,left(systypes.NAME + CASE 
				WHEN systypes.xusertype IN (
						175
						,11
						,167
						,165
						) --varchar, char
					THEN '(' + cast(syscolumns.length AS VARCHAR(10)) + ')'
				WHEN systypes.xusertype IN (
						239
						,231
						) --nvarchar and nchar
					THEN '(' + cast(syscolumns.length / 2 AS VARCHAR(10)) + ')'
				WHEN systypes.xusertype IN (106) --decimal
					THEN '(' + cast(syscolumns.xprec AS VARCHAR(10)) + ', ' + cast(sys.syscolumns.xscale AS VARCHAR(10)) + ')'
				ELSE ''
				END, 20)
		,CASE 
			WHEN syscolumns.isnullable = 0
				THEN 'NOT NULL'
			WHEN syscolumns.isnullable = 1
				THEN 'NULL'
			END + ' ' + CASE 
			WHEN sys.default_constraints.NAME IS NOT NULL
				THEN 'CONSTRAINT ' + ' ' + sys.default_constraints.NAME + ']' + ' ' + 'DEFAULT ' + sys.default_constraints.DEFINITION
			ELSE ''
			END + CASE 
			WHEN sys.identity_columns.NAME IS NOT NULL
				THEN 'IDENTITY' + ' ' + '(' + cast(sys.identity_columns.seed_value AS VARCHAR(20)) + ', ' + cast(sys.identity_columns.increment_value AS VARCHAR(20)) + ')'
			ELSE ''
			END
	FROM sys.syscolumns
	JOIN sys.systypes ON sys.syscolumns.xtype = sys.systypes.xtype
	LEFT JOIN sys.default_constraints ON sys.default_constraints.parent_object_id = object_id(@TableName)
		AND sys.syscolumns.colid = sys.default_constraints.parent_column_id
	LEFT JOIN sys.identity_columns ON sys.identity_columns.object_id = object_id(@TableName)
		AND sys.syscolumns.colid = sys.identity_columns.column_id
	WHERE id = object_id(@TableName)
		AND sys.systypes.NAME <> 'sysname'
	ORDER BY sys.syscolumns.colid
END

SELECT @PrimaryKey = sys.indexes.NAME
FROM sys.indexes
JOIN sys.index_columns ON sys.indexes.object_id = sys.index_columns.object_id
	AND sys.indexes.index_id = sys.index_columns.index_id
JOIN sys.syscolumns ON sys.indexes.object_id = sys.syscolumns.id
	AND sys.index_columns.column_id = sys.syscolumns.colid
WHERE sys.syscolumns.id = object_id(@TableName)
	AND sys.indexes.is_primary_key = 1

INSERT INTO @tblPrimaryKey (
	ColumnName
	,IndexDefinition
	)
SELECT sys.syscolumns.NAME
	,sys.indexes.type_desc
FROM sys.indexes
JOIN sys.index_columns ON sys.indexes.object_id = sys.index_columns.object_id
	AND sys.indexes.index_id = sys.index_columns.index_id
JOIN sys.syscolumns ON sys.indexes.object_id = sys.syscolumns.id
	AND sys.index_columns.column_id = sys.syscolumns.colid
WHERE sys.syscolumns.id = object_id(@TableName)
	AND sys.indexes.is_primary_key = 1

INSERT INTO @FinalTable (CreateStatement)
VALUES ('if not exists(select 1 from sysobjects where id = object_id(''' + @TableName + ''')')

INSERT INTO @FinalTable (CreateStatement)
VALUES (' and objectproperty(ID, N''IsUserTable'') = 1)')

INSERT INTO @FinalTable (CreateStatement)
VALUES ('begin')

INSERT INTO @FinalTable (CreateStatement)
VALUES ('create Table dbo.' + @TableName + ' (')

--insert into @FinalTable(CreateStatement)
--values( '(')
INSERT INTO @FinalTable (CreateStatement)
SELECT CHAR(9) + ColumnName + DataType + Nullability
FROM @Generate

INSERT INTO @FinalTable (CreateStatement)
VALUES (')')

IF @PrimaryKey IS NULL --table has no primary key defined
BEGIN
	GOTO statement
END

INSERT INTO @FinalTable (CreateStatement)
VALUES ('')

INSERT INTO @FinalTable (CreateStatement)
VALUES ('Alter table dbo.' + @TableName + '')

INSERT INTO @FinalTable (CreateStatement)
VALUES ('Add Constraint ' + @PrimaryKey + '')

INSERT INTO @FinalTable (CreateStatement)
SELECT 'Primary Key ' + IndexDefinition + ' (' + max(CASE 
			WHEN PrimaryKeyID = 1
				THEN ColumnName
			ELSE ' '
			END) + max(CASE 
			WHEN PrimaryKeyID = 2
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 3
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 4
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 5
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 6
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 7
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 8
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 9
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 10
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 11
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 12
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 13
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 14
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 15
				THEN ', ' + ColumnName
			ELSE ''
			END) + max(CASE 
			WHEN PrimaryKeyID = 16
				THEN ', ' + ColumnName
			ELSE ''
			END) + ')' AS PrimaryKey
FROM @tblPrimaryKey
GROUP BY IndexDefinition

statement:

INSERT INTO @FinalTable (CreateStatement)
VALUES ('End')

PRINT '--Script generated on ' + convert(VARCHAR(25), getdate(), 121)

SELECT CreateStatement AS [--CreateStatement]
FROM @FinalTable
SET @srtSQLCatchBlock = REPLACE(@srtSQLCatchBlock, '<SchemaName>', @strSchemaName)
SET @srtSQLCatchBlock = REPLACE(@srtSQLCatchBlock, '<TableName>', @strTableName)
PRINT @srtSQLCatchBlock
KickOut:

GO
