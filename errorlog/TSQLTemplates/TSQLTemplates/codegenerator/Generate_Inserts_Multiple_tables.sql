DECLARE @SQLtxt varchar(8000)
DECLARE @p_Tablename varchar(2000);
set @SQLtxt = 'RoleCategory,featureCategory,BlackjackRole,BlackjackFeature,BlackjackRoleToFeature,Claim,CompositeClaims,RequiredRoleForRoleAdmin,CompanyTypeRoles,ParentBrands,ClaimType'

--select * from [dbo].[f_DelimitedSplit8K](@SQLtxt , ',')

DECLARE CURSOR_Table CURSOR FAST_FORWARD
FOR
select item from [dbo].[f_DelimitedSplit8K](@SQLtxt , ',')

OPEN CURSOR_Table

FETCH NEXT FROM CURSOR_Table
INTO @p_Tablename
WHILE @@FETCH_STATUS = 0
BEGIN

declare @table_name SYSNAME
set @table_name = ltrim(rtrim(@p_Tablename))
--select @table_name
BEGIN

SET NOCOUNT ON

--DECLARE @table_name SYSNAME
DECLARE @handle_big_binary BIT
DECLARE @column_names BIT

-- ////////////////////
-- -> Configuration
--SET @table_name = '[dbo].[TEST12]'
SET @handle_big_binary = 1
SET @column_names = 1
-- <- Configuration
-- ////////////////////

DECLARE @object_id INT
DECLARE @schema_id INT

--SELECT * FROM sys.all_objects
SELECT @object_id = object_id, @schema_id = schema_id 
   FROM sys.tables 
   WHERE object_id = OBJECT_ID(@table_name)


DECLARE @columns TABLE (column_name SYSNAME, ordinal_position INT, data_type SYSNAME, data_length INT, is_nullable BIT)
delete from  @columns
-- Get all column information
INSERT INTO @columns
   SELECT column_name, ordinal_position, data_type, character_maximum_length, CASE WHEN is_nullable = 'YES' THEN 1 ELSE 0 END
   FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = SCHEMA_NAME(@schema_id)
   AND TABLE_NAME = OBJECT_NAME(@object_id)

DECLARE @select VARCHAR(MAX)
DECLARE @insert VARCHAR(MAX)
DECLARE @crlf CHAR(2)
DECLARE @sql VARCHAR(MAX)
DECLARE @first BIT
DECLARE @pos INT
SET @pos = 1
SET @select = null
SET @insert  = ''
SET @crlf= ''
SET @sql = ''
SET @first = ''
 

SET @crlf = CHAR(13) + CHAR(10)

WHILE EXISTS (SELECT TOP 1 * FROM @columns WHERE ordinal_position >= @pos)
BEGIN
   DECLARE @column_name SYSNAME
   DECLARE @data_type SYSNAME
   DECLARE @data_length INT
   DECLARE @is_nullable BIT

   -- Get information for the current column
   SELECT @column_name = column_name, @data_type = data_type, @data_length = data_length, @is_nullable = is_nullable
      FROM @columns
      WHERE ordinal_position = @pos

   -- Create column select information to script the name of the source/destination column if configured
   IF (@select IS NULL)
      SET @select = ' ''' + QUOTENAME(@column_name)
   ELSE
      SET @select = @select + ','' + ' + @crlf + ' ''' + QUOTENAME(@column_name)

   -- Handle NULL values
   SET @sql = ' '
   SET @sql = @sql + 'CASE WHEN ' + QUOTENAME(@column_name) + ' IS NULL THEN ''NULL'' ELSE '

   -- Handle the different data types
   IF (@data_type IN ('bigint', 'bit', 'decimal', 'float', 'int', 'money', 'numeric',
'real', 'smallint', 'smallmoney', 'tinyint'))
   BEGIN
      SET @sql = @sql + 'CONVERT(VARCHAR(40), ' + QUOTENAME(@column_name) + ')'
   END
   ELSE IF (@data_type IN ('char', 'nchar', 'nvarchar', 'varchar'))
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(' + QUOTENAME(@column_name) + ', '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type = 'date')
   BEGIN
      SET @sql = @sql + '''CONVERT(DATE, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(3), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'time')
   BEGIN
      SET @sql = @sql + '''CONVERT(TIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(5), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'datetime')
   BEGIN
      SET @sql = @sql + '''CONVERT(DATETIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'datetime2')
   BEGIN
      SET @sql = @sql + '''CONVERT(DATETIME2, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'smalldatetime')
   BEGIN
      SET @sql = @sql + '''CONVERT(SMALLDATETIME, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(4), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'text')
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(CONVERT(VARCHAR(MAX), ' + QUOTENAME(@column_name) + '), '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type IN ('ntext', 'xml'))
   BEGIN
      SET @sql = @sql + ''''''''' + REPLACE(CONVERT(NVARCHAR(MAX), ' + QUOTENAME(@column_name) + '), '''''''', '''''''''''') + '''''''''
   END
   ELSE IF (@data_type IN ('binary', 'varbinary'))
   BEGIN
      -- Use udf_varbintohexstr_big if available to avoid cutted binary data
      IF (@handle_big_binary = 1)
         SET @sql = @sql + ' dbo.udf_varbintohexstr_big (' + QUOTENAME(@column_name) + ')'
      ELSE
         SET @sql = @sql + ' master.sys.fn_varbintohexstr (' + QUOTENAME(@column_name) + ')'
   END
   ELSE IF (@data_type = 'timestamp')
   BEGIN
      SET @sql = @sql + '''CONVERT(TIMESTAMP, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(8), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'uniqueidentifier')
   BEGIN
      SET @sql = @sql + '''CONVERT(UNIQUEIDENTIFIER, '' + master.sys.fn_varbintohexstr (CONVERT(BINARY(16), ' + QUOTENAME(@column_name) + ')) + '')'''
   END
   ELSE IF (@data_type = 'image')
   BEGIN
      -- Use udf_varbintohexstr_big if available to avoid cutted binary data
      IF (@handle_big_binary = 1)
         SET @sql = @sql + ' dbo.udf_varbintohexstr_big (CONVERT(VARBINARY(MAX), ' + QUOTENAME(@column_name) + '))'
      ELSE
         SET @sql = @sql + ' master.sys.fn_varbintohexstr (CONVERT(VARBINARY(MAX), ' + QUOTENAME(@column_name) + '))'
   END
   ELSE
   BEGIN
      PRINT 'ERROR: Not supported data type: ' + @data_type
      RETURN
   END

   SET @sql = @sql + ' END'

   -- Script line end for finish or next column
   IF EXISTS (SELECT TOP 1 * FROM @columns WHERE ordinal_position > @pos)
      SET @sql = @sql + ' + '', '' +'
   ELSE
      SET @sql = @sql + ' + '

   -- Remember the data script
   IF (@insert IS NULL)
      SET @insert = @sql
   ELSE
      SET @insert = @insert + @crlf + @sql

   SET @pos = @pos + 1
END

-- Close the column names select
SET @select = @select + ''' +'
DECLARE @sqltxt1 NVARCHAR(4000)


-- Print the INSERT INTO part
PRINT 'SELECT ''INSERT INTO ' + @table_name + ''' + '
set @sqltxt1 = 'SELECT ''INSERT INTO ' + @table_name + ''' + '
-- Print the column names if configured
IF (@column_names = 1)
BEGIN
PRINT ' ''('' + '
PRINT @select
PRINT ' '')'' + '
select @sqltxt1 = @sqltxt1 + ' ''('' + ' + @select +  ' '')'' + '
END
--ELSE 
--BEGIN
--select @sqltxt1 =  ''
--END

PRINT ' '' VALUES ('' +'

-- Print the data scripting
PRINT @insert

-- Script the end of the statement
PRINT ' '')'''
PRINT ' FROM ' + @table_name

select @sqltxt1 = @sqltxt1 + ' '' VALUES ('' +'  + @insert + ' '')''' + ' FROM ' + @table_name

--SELECT @sqltxt1

EXEC (@sqltxt1)

END

set @table_name = ''

 FETCH NEXT FROM CURSOR_Table
    INTO @p_Tablename
END      

CLOSE CURSOR_Table
DEALLOCATE CURSOR_Table