IF OBJECT_ID('GenerateSPforInsertUpdate','P') IS NOT NULL
	DROP PROC GenerateSPforInsertUpdate
GO

CREATE PROC GenerateSPforInsertUpdate
 @Schemaname Sysname = 'dbo'
,@Tablename  Sysname
,@ProcName	 Sysname = ''
,@IdentityInsert  bit  = 0 
AS

SET NOCOUNT ON

/*
Parameters
@Schemaname			- SchemaName to which the table belongs to. Default value 'dbo'.
@Tablename			- TableName for which the procs needs to be generated.
@ProcName			- Procedure name. Default is blank and when blank the procedure name generated will be sp_<Tablename>
@IdentityInsert		- Flag to say if the identity insert needs to be done to the table or not if identity column exists in the table.
					  Default value is 0.

GenerateSPforInsertUpdate  @Schemaname  = 'dbo'
,@Tablename  = 'company'
,@ProcName	  = ''
,@IdentityInsert    = 0 
*/

DECLARE @PKTable TABLE
(
TableQualifier SYSNAME
,TableOwner	   SYSNAME
,TableName	   SYSNAME
,ColumnName	   SYSNAME
,KeySeq		   int
,PKName		   SYSNAME
)

INSERT INTO @PKTable
EXEC sp_pkeys @Tablename,@Schemaname

--SELECT * FROM @PKTable

DECLARE @columnNames			  VARCHAR(MAX)
DECLARE @columnNamesWithDatatypes VARCHAR(MAX)
DECLARE @InsertcolumnNames		  VARCHAR(MAX)
DECLARE @UpdatecolumnNames		  VARCHAR(MAX)
DECLARE @IdentityExists			  BIT

SELECT @columnNames = ''
SELECT @columnNamesWithDatatypes = ''
SELECT @InsertcolumnNames = ''
SELECT @UpdatecolumnNames = ''
SELECT @IdentityExists = 0

DECLARE @MaxLen INT



SELECT @MaxLen =  MAX(LEN(SC.NAME))
  FROM sys.schemas SCH
  JOIN sys.tables  ST
	ON SCH.schema_id =ST.schema_id
  JOIN sys.columns SC
	ON ST.object_id = SC.object_id
 WHERE SCH.name = @Schemaname
   AND ST.name  = @Tablename 
   AND SC.is_identity = CASE
					    WHEN @IdentityInsert = 1 THEN SC.is_identity
						ELSE 0
						END
   AND SC.is_computed = 0


SELECT @columnNames = @columnNames + SC.name + ','
	  ,@columnNamesWithDatatypes = @columnNamesWithDatatypes +'@' + SC.name 
															 + REPLICATE(' ',@MaxLen + 5 - LEN(SC.NAME)) + STY.name 
															 + CASE 
															   WHEN STY.NAME IN ('Char','Varchar') AND SC.max_length <> -1 THEN '(' + CONVERT(VARCHAR(4),SC.max_length) + ')'
															   WHEN STY.NAME IN ('Nchar','Nvarchar') AND SC.max_length <> -1 THEN '(' + CONVERT(VARCHAR(4),SC.max_length / 2 ) + ')'
															   WHEN STY.NAME IN ('Char','Varchar','Nchar','Nvarchar') AND SC.max_length = -1 THEN '(Max)'
															   ELSE ''
															   END 
															   + CASE
																 WHEN NOT EXISTS(SELECT 1 FROM @PKTable WHERE ColumnName=SC.name) THEN  ' = NULL,' + CHAR(13)
																 ELSE ',' + CHAR(13)
																 END
	   ,@InsertcolumnNames = @InsertcolumnNames + '@' + SC.name + ','
	   ,@UpdatecolumnNames = @UpdatecolumnNames 
						     + CASE
							   WHEN NOT EXISTS(SELECT 1 FROM @PKTable WHERE ColumnName=SC.name) THEN 
									CASE 
									WHEN @UpdatecolumnNames ='' THEN ''
									ELSE '       '
									END +  SC.name +  + REPLICATE(' ',@MaxLen + 5 - LEN(SC.NAME)) + '= ' + '@' + SC.name + ',' + CHAR(13)
							   ELSE ''
							   END 
	  ,@IdentityExists  = CASE 
						  WHEN SC.is_identity = 1 OR @IdentityExists = 1 THEN 1 
						  ELSE 0
						  END
  FROM sys.schemas SCH
  JOIN sys.tables  ST
	ON SCH.schema_id =ST.schema_id
  JOIN sys.columns SC
	ON ST.object_id = SC.object_id
  JOIN sys.types STY
    ON SC.user_type_id	 = STY.user_type_id
   AND SC.system_type_id = STY.system_type_id
 WHERE SCH.name = @Schemaname
   AND ST.name  = @Tablename
   AND SC.is_identity = CASE
					    WHEN @IdentityInsert = 1 THEN SC.is_identity
						ELSE 0
						END
   AND SC.is_computed = 0

DECLARE @InsertSQL VARCHAR(MAX)
DECLARE @UpdateSQL VARCHAR(MAX)
DECLARE @DeleteSQL VARCHAR(MAX)
DECLARE @IFExistsSQL VARCHAR(MAX)
DECLARE @PKWhereClause VARCHAR(MAX)

SELECT @PKWhereClause = ''

SELECT @PKWhereClause = @PKWhereClause + ColumnName + ' = ' + '@' + ColumnName + CHAR(13) + '   AND ' 
  FROM @PKTable
ORDER BY KeySeq

SELECT @columnNames		  = SUBSTRING(@columnNames,1,LEN(@columnNames)-1)
SELECT @InsertcolumnNames = SUBSTRING(@InsertcolumnNames,1,LEN(@InsertcolumnNames)-1)
SELECT @UpdatecolumnNames = SUBSTRING(@UpdatecolumnNames,1,LEN(@UpdatecolumnNames)-2)
SELECT @PKWhereClause	  = SUBSTRING(@PKWhereClause,1,LEN(@PKWhereClause)-5)
SELECT @columnNamesWithDatatypes = SUBSTRING(@columnNamesWithDatatypes,1,LEN(@columnNamesWithDatatypes)-2)
SELECT @columnNamesWithDatatypes = @columnNamesWithDatatypes 


SELECT @IFExistsSQL = 'IF EXISTS (SELECT 1 FROM ' + @Schemaname +'.' + @Tablename + CHAR(13) + 
'WHERE ' + @PKWhereClause + ')'


SELECT @InsertSQL = 'INSERT INTO ' + @Schemaname +'.' + @Tablename 
								   + CHAR(13) + '(' + @columnNames + ')' + 
								   + CHAR(13) + 'SELECT ' + @InsertcolumnNames 

SELECT @UpdateSQL = 'UPDATE '  + @Schemaname +'.' + @Tablename 
							   + CHAR (13) + '   SET ' + @UpdatecolumnNames 
							   + CHAR (13) + ' WHERE ' + @PKWhereClause

 IF LTRIM(RTRIM(@ProcName)) = '' 
	SELECT @ProcName = 'SP_' + @Tablename
	
 PRINT 'IF OBJECT_ID(''' + @ProcName + ''',''P'') IS NOT NULL'
 PRINT 'DROP PROC ' + @ProcName
 PRINT 'GO'
 PRINT 'CREATE PROCEDURE ' + @ProcName +  CHAR (13) +  @columnNamesWithDatatypes +  CHAR (13) + 'AS' +  CHAR (13)
 
 PRINT @IFExistsSQL
 PRINT 'BEGIN'
 PRINT ''
 PRINT @UpdateSQL
 PRINT ''
 PRINT 'END'
 PRINT 'ELSE'
 PRINT 'BEGIN'
 IF @IdentityExists = 1 AND @IdentityInsert = 1 
 PRINT 'SET IDENTITY_INSERT ' + @Schemaname + '.' + @Tablename + ' ON '
 PRINT ''
 PRINT @InsertSQL
 PRINT ''
 IF @IdentityExists = 1 AND @IdentityInsert = 1 
 PRINT 'SET IDENTITY_INSERT ' + @Schemaname + '.' + @Tablename + ' OFF '
 PRINT 'END'
 PRINT ''
 
 
 
 PRINT 'GO'
 
SET NOCOUNT OFF


go

                             



