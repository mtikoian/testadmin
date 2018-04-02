/*
SQLVer Version tracking system for MSSQL.
https://sourceforge.net/projects/sqlver/


You may safely run this entire script:  it creates a schema named sqlver in the
current database to which it adds some objects, and it creates a single DDL
Database Trigger to log to a table in this schema.  It does not make any other
changes to the server or the dataabse.

After running this script, check the Messages tab in SSMS to see some
examples for usage.

Written for Microsoft SQL 2008 R2 or later, but should run on MSSQL 2005.

Copyright (C) 2014 David B. Rueter (drueter@assyst.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

HISTORY

Version .961  11/20/2014
  Initial public version
  
*/

SET NOCOUNT ON

/****** Object:  Schema [sqlver]    Script Date: 11/20/2014 17:16:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE SCHEMA [sqlver] AUTHORIZATION [dbo]
GO
/****** Object:  StoredProcedure [sqlver].[sputilPrintString]    Script Date: 11/20/2014 17:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[sputilPrintString]
@Buf varchar(MAX)
WITH EXECUTE AS OWNER
AS 
BEGIN
  DECLARE @S varchar(MAX)
  DECLARE @P int
  SET @P = 1
  
  WHILE @P < LEN(@Buf + 'x') - 1 BEGIN
    SET @S = SUBSTRING(@Buf, @P, 4000)
    PRINT @S + '~'
    SET @P = @P + 4000
  END

END
GO
/****** Object:  StoredProcedure [sqlver].[sputilGetRowCounts]    Script Date: 11/20/2014 17:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[sputilGetRowCounts]
AS 
BEGIN
  SET NOCOUNT ON
  SELECT sch.name, so.name, si.rows
  FROM
    sys.objects so
    JOIN sys.schemas sch ON
      so.schema_id = sch.schema_id
    JOIN sys.sysindexes AS si ON 
      so.object_id = si.id AND si.indid < 2
  WHERE
    so.type = 'U'
  ORDER BY
    si.rows DESC  

  SELECT 
   'Total Rows', 
    SUM(si.rows)
  FROM
    sys.objects so
    JOIN sys.schemas sch ON
      so.schema_id = sch.schema_id
    JOIN sys.sysindexes AS si ON 
      so.object_id = si.id AND si.indid < 2
  WHERE
    so.type = 'U'
END
GO
/****** Object:  StoredProcedure [sqlver].[spUninstall]    Script Date: 11/20/2014 17:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[spUninstall]
@ReallyRemoveAll bit = 0
AS
BEGIN
  DECLARE @CRLF varchar(5)
  SET @CRLF = CHAR(13) + CHAR(10)
  
  IF ISNULL(@ReallyRemoveAll, 0) = 0 BEGIN
    PRINT 'Executing this procedure will remove ALL SqlVer objects from the database ' + DB_NAME() + ' ' +
      'and will therefore PERMANENTLY DELETE ALL VERSION INFORMATION in the tables ' +
      'sqlver.tblSchemaManifest and sqlver.tblSchemaLog.' + @CRLF + @CRLF +
      'If this is really what you want to do, execute this procedure with the @ReallyRemoveAll paramter ' +
      'set to 1, like this:' + @CRLF + @CRLF +
      '  EXEC sqlver.spUninstall @ReallyRemoveAll = 1' + @CRLF + @CRLF +
      'You should probably make a backup of the data in the tables sqlver.tblSchemaManifest and sqlver.tblSchemaLog ' +
      'before you do so, and you should also verify that you are in the correct database.  Do you really want to ' +
      'remove all version information for database ' + DB_NAME() + '??'          
      
    RETURN
  END
  ELSE BEGIN    
    IF EXISTS(SELECT object_id FROM sys.synonyms WHERE name = 'ver' AND schema_id = SCHEMA_ID('sqlver')) BEGIN
      DROP SYNONYM [sqlver].ver
    END
    
    IF EXISTS(SELECT object_id FROM sys.synonyms WHERE name = 'uninstall' AND schema_id = SCHEMA_ID('sqlver')) BEGIN
      DROP SYNONYM [sqlver].uninstall
    END
    
    IF EXISTS(SELECT object_id FROM sys.synonyms WHERE name = 'buildManifest' AND schema_id = SCHEMA_ID('sqlver')) BEGIN
      DROP SYNONYM [sqlver].buildManifest
    END
    
    IF EXISTS(SELECT object_id FROM sys.synonyms WHERE name = 'find' AND schema_id = SCHEMA_ID('sqlver')) BEGIN
      DROP SYNONYM [sqlver].find
    END    
        
    IF EXISTS(SELECT object_id FROM sys.synonyms WHERE name = 'printStr' AND schema_id = SCHEMA_ID('sqlver')) BEGIN
      DROP SYNONYM [sqlver].printStr
    END            

    IF EXISTS(SELECT object_id FROM sys.synonyms WHERE name = 'RTLog' AND schema_id = SCHEMA_ID('sqlver')) BEGIN
      DROP SYNONYM [sqlver].RTLog
    END             
        
    IF EXISTS(SELECT object_id FROM sys.triggers WHERE name = 'dtgLogSchemaChanges') BEGIN
      DROP TRIGGER [dtgLogSchemaChanges] ON DATABASE
    END

    IF OBJECT_ID('[sqlver].[udfScriptTable]') IS NOT NULL BEGIN
      DROP FUNCTION [sqlver].[udfScriptTable]
    END
    
    IF OBJECT_ID('[sqlver].[udfHashBytesNMax]') IS NOT NULL  BEGIN
      DROP FUNCTION [sqlver].[udfHashBytesNMax]
    END

    IF OBJECT_ID('[sqlver].[udfIsInComment]') IS NOT NULL BEGIN
      DROP FUNCTION [sqlver].[udfIsInComment]
    END
    
    IF OBJECT_ID('[sqlver].[spVersion]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].[spVersion]
    END  
    
    IF OBJECT_ID('[sqlver].[spBuildManifest]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].[spBuildManifest]
    END

    IF OBJECT_ID('[sqlver].[spinsSysRTLog]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].spinsSysRTLog
    END
    
    IF OBJECT_ID('[sqlver].[spShowRTLog]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].spShowRTLog
    END    
    
    IF OBJECT_ID('[sqlver].[spShowSlowQueries]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].spShowSlowQueries
    END     
    
    IF OBJECT_ID('[sqlver].[sputilFindInCode]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].[sputilFindInCode]
    END       
    
    IF OBJECT_ID('[sqlver].[sputilGetRowCounts]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].[sputilGetRowCounts]
    END     

    IF OBJECT_ID('[sqlver].[sputilPrintString]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].[sputilPrintString]
    END     
            
    IF OBJECT_ID('[sqlver].[spWhoIsHogging]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].[spWhoIsHogging]
    END     
              
    IF OBJECT_ID('[sqlver].[udfLTRIMSuper]') IS NOT NULL BEGIN
      DROP FUNCTION [sqlver].[udfLTRIMSuper]
    END     
                  
    IF OBJECT_ID('[sqlver].[udfRTRIMSuper]') IS NOT NULL BEGIN
      DROP FUNCTION [sqlver].[udfRTRIMSuper]
    END     
                        
    IF OBJECT_ID('[sqlver].[tblSchemaLog]') IS NOT NULL  BEGIN
      DROP TABLE [sqlver].[tblSchemaLog]
    END

    IF OBJECT_ID('[sqlver].[tblSchemaManifest]') IS NOT NULL BEGIN
      DROP TABLE [sqlver].[tblSchemaManifest]
    END    
    
    IF OBJECT_ID('[sqlver].[tblSysRTLog]') IS NOT NULL BEGIN
      DROP TABLE [sqlver].[tblSysRTLog]
    END
    
    IF OBJECT_ID('[sqlver].[spUninstall]') IS NOT NULL BEGIN
      DROP PROCEDURE [sqlver].[spUninstall]
    END    
    
    IF EXISTS (SELECT schema_id from sys.schemas WHERE name = 'sqlver') BEGIN
      DROP SCHEMA [sqlver]
    END
    
    PRINT 'All SQLVer objects have been removed'
  END

END
GO
/****** Object:  StoredProcedure [sqlver].[spShowSlowQueries]    Script Date: 11/20/2014 17:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[spShowSlowQueries]
@ClearStatistics bit = 0
AS
BEGIN
  --Based on article by Pinal Dave at http://blog.sqlauthority.com/2009/01/02/sql-server-2008-2005-find-longest-running-query-tsql/

  IF @ClearStatistics = 1 BEGIN
    DBCC FREEPROCCACHE
  END
  

  SELECT DISTINCT TOP 100
    COALESCE(OBJECT_SCHEMA_NAME(t.objectid, t.dbid) + '.' + OBJECT_NAME(t.objectid), t.TEXT) AS Query,
    s.total_elapsed_time / 1000 / 60  AS TotalElapsedTimeMinutes,    
    s.execution_count AS ExecutionCount,
    --s.max_elapsed_time / 1000 / 60 AS MaxElapsedTimeMinutes,  
    ISNULL(s.total_elapsed_time / NULLIF(s.execution_count, 0), 0)  / 1000 / 60 AS AvgElapsedTimeMinutes,
    ISNULL(s.total_elapsed_time / NULLIF(s.execution_count, 0), 0) AvgElapsedTimeMS,    
    s.creation_time AS LogCreatedOn,
    ISNULL(s.execution_count / NULLIF(DATEDIFF(s, s.creation_time, GETDATE()), 0), 0) AS FrequencyPerSec,
    s.total_physical_reads,
    s.last_physical_reads,
    s.total_logical_writes,
    s.last_logical_writes,
    s.total_rows,
    s.last_rows,
    DB_NAME(t.dbid),
    s.*
  FROM
    sys.dm_exec_query_stats s
    CROSS APPLY sys.dm_exec_sql_text( s.sql_handle ) t
  WHERE
    t.dbid = DB_ID()  
  ORDER BY
    TotalElapsedTimeMinutes DESC
END
GO
/****** Object:  UserDefinedFunction [sqlver].[udfScriptTable]    Script Date: 11/20/2014 17:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sqlver].[udfScriptTable](
@ObjectSchema sysname,
@ObjectName sysname)
RETURNS varchar(MAX)
WITH EXECUTE AS OWNER
AS 
BEGIN
  --Based on script contributed by Marcello - 25/09/09, in comment to article posted by 
  --Tim Chapman, TechRepublic, 2008/11/20
  --http://www.builderau.com.au/program/sqlserver/soa/Script-Table-definitions-using-TSQL/0,339028455,339293405,00.htm
  
  --Formatting altered by David Rueter (drueter@assyst.com) 2010/05/11 to match
  --script generated by MS SQL Server Management Studio 2005

	DECLARE @Id int,
	@i int,
	@i2 int,
	@Sql varchar(MAX),
	@Sql2 varchar(MAX),
	@f1 varchar(5),
	@f2 varchar(5),
	@f3 varchar(5),
	@f4 varchar(5),
	@T varchar(5)

	SELECT
	  @Id=obj.object_id,
	  @f1 = CHAR(13) + CHAR(10),
	  @f2 = '	',
	  @f3=@f1+@f2,
	  @f4=',' + @f3
	FROM
    sys.schemas sch
    JOIN sys.objects obj ON
      sch.schema_id = obj.schema_id
  WHERE
    sch.name LIKE @ObjectSchema AND
    obj.name LIKE @ObjectName    

	IF @Id IS NULL RETURN NULL

	DECLARE @tvData table(
	  Id int identity primary key,
	  D varchar(max) not null,
	  ic int null,
	  re int null,
	  o int not null);

	-- Columns
  WITH c AS(
		SELECT
		  c.column_id,
		  Nr = ROW_NUMBER() OVER (ORDER BY c.column_id),
		  Clr=COUNT(*) OVER(),
			D = QUOTENAME(c.name) + ' ' +
				CASE 
				  WHEN s.name = 'sys' OR c.is_computed=1 THEN '' 
				  ELSE QUOTENAME(s.name) + '.' 
				END +				
				
				CASE
				  WHEN c.is_computed=1 THEN ''
				  WHEN s.name = 'sys' THEN QUOTENAME(t.Name)
				  ELSE QUOTENAME(t.name)
				END +
				
				CASE
				  WHEN ((c.user_type_id <> c.system_type_id) OR (c.is_computed=1)) THEN ''
					WHEN t.Name IN (
					  'xml', 'uniqueidentifier', 'tinyint', 'timestamp', 'time', 'text', 'sysname',
					  'sql_variant', 'smallmoney', 'smallint', 'smalldatetime', 'ntext', 'money',
					  'int', 'image', 'hierarchyid', 'geometry', 'geography', 'float', 'datetimeoffset',
					  'datetime2', 'datetime', 'date', 'bigint', 'bit') THEN ''
					WHEN t.Name in(
					  'varchar','varbinary', 'real', 'nvarchar', 'numeric', 'nchar', 'decimal', 'char', 'binary') THEN
						'(' + ISNULL(CONVERT(varchar, NULLIF(
						CASE WHEN t.Name IN ('numeric', 'decimal') THEN c.precision ELSE c.max_length END, -1)), 'MAX') + 
						ISNULL(',' + CONVERT(varchar, NULLIF(c.scale, 0)), '') + ')'
				  ELSE '??'
			  END + 
			  
				CASE 
				  WHEN ic.object_id IS NOT NULL THEN ' IDENTITY(' + CONVERT(varchar, ic.seed_value) + ',' +
				    CONVERT(varchar,ic.increment_value) + ')'
				  ELSE ''
				END +
				  
				CASE
				  WHEN c.is_computed = 1 THEN 'AS' + cc.definition 
				  WHEN c.is_nullable = 1 THEN ' NULL'
				  ELSE ' NOT NULL'
				END +

				CASE c.is_rowguidcol 
				  WHEN 1 THEN ' rowguidcol'
				  ELSE ''
				END +

				CASE 
				  WHEN d.object_id IS NOT NULL THEN  ' CONSTRAINT ' + QUOTENAME(d.name) + ' DEFAULT ' + d.definition
				  ELSE '' 
				END	

		FROM
		  sys.columns c
      INNER JOIN sys.types t ON t.user_type_id = c.user_type_id
      INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
		  LEFT OUTER JOIN sys.computed_columns cc ON
		    cc.object_id = c.object_id AND
		    cc.column_id = c.column_id

		  LEFT OUTER JOIN sys.default_constraints d ON
		    d.parent_object_id = @id AND
		    d.parent_column_id=c.column_id

		  LEFT OUTER JOIN sys.identity_columns ic ON
		    ic.object_id = c.object_id AND
		    ic.column_id=c.column_id

		WHERE
		  c.object_id=@Id	
  )

  INSERT INTO @tvData(D, o)
  SELECT
    '	' + D + CASE Nr WHEN Clr THEN '' ELSE ',' + @f1 END,
		0
  FROM c
	ORDER by column_id
	

	-- SubObjects
	SET @i=0

	WHILE 1=1 BEGIN

		SELECT TOP 1
		  @i = c.object_id,
		  @T = c.type,
		  @i2=i.index_id
		FROM
		  sys.objects c 
		  LEFT OUTER JOIN sys.indexes i ON
		    i.object_id = @Id AND
		    i.name=c.name
    WHERE
      parent_object_id=@Id AND
      c.object_id>@i AND
      c.type NOT IN ('D', 'TR') --ignore triggers as of 1/15/2012
		ORDER BY c.object_id

		IF @@rowcount=0 BREAK

		IF @T = 'C' BEGIN
		  INSERT INTO @tvData 
			SELECT
			  @f4 + 'CHECK ' +
			    CASE is_not_for_replication 
			      WHEN 1 THEN 'NOT FOR REPLICATION '
			      ELSE ''
			    END + definition, null, null, 10
			FROM
			  sys.check_constraints 
			WHERE object_id=@i
	  END
    ELSE IF @T = 'Pk' BEGIN
		  INSERT INTO @tvData 
			SELECT
			  @f4 + 'CONSTRAINT ' + 
			  QUOTENAME('pk' + REPLACE(@ObjectName, 'tbl', '')) +
			  ' PRIMARY KEY' + ISNULL(' ' + NULLIF(UPPER(i.type_desc),'NONCLUSTERED'), ''),
			  @i2, null, 20			
			FROM sys.indexes i
			WHERE
			  i.object_id=@Id AND i.index_id=@i2
    END
    ELSE IF @T = 'uq' BEGIN
		  INSERT INTO @tvData VALUES(@f4 + 'UNIQUE', @i2, null, 30)
	  END
		ELSE IF @T = 'f' BEGIN
		  INSERT INTO @tvData 
			SELECT
			  @f4 + 'CONSTRAINT ' +  QUOTENAME(f.name) +
			  ' FOREIGN KEY ',
			  -1,
			  @i,
			  40
			FROM
			  sys.foreign_keys f        
      WHERE
        f.object_id=@i
          
      INSERT INTO @tvData 
      SELECT ' REFERENCES ' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name), -2, @i, 41
			FROM
			  sys.foreign_keys f
        INNER JOIN sys.objects o ON o.object_id = f.referenced_object_id
        INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
			WHERE
			  f.object_id=@i
			
			INSERT INTO @tvData 
			SELECT ' NOT FOR REPLICATION', -3, @i, 42
			FROM
			  sys.foreign_keys f
			  INNER JOIN sys.objects o ON o.object_id = f.referenced_object_id
			  INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
			WHERE
			  f.object_id = @i AND
			  f.is_not_for_replication=1
    END
    ELSE BEGIN
			INSERT INTO @tvData
			VALUES(@f4 + 'Unknow SubObject [' + @T + ']', null, null, 99)
	  END
	END

  INSERT INTO @tvData
  VALUES(@f1+') ON ' + QUOTENAME('PRIMARY'), null, null, 100)	
  
  -- Indexes
  INSERT INTO @tvData
  SELECT
    @f1 + CHAR(13) + CHAR(10) + 'CREATE ' +
      CASE is_unique WHEN 1 THEN 'UNIQUE ' ELSE '' END +
      UPPER(s.type_desc) + ' INDEX ' + 
      s.name  + ' ON ' +
      QUOTENAME(sc.Name) + '.' + QUOTENAME(o.name),      

    index_id,
    NULL,
    1000
  FROM 
    sys.indexes s
    INNER JOIN sys.objects o ON o.object_id = s.object_id
    INNER JOIN sys.schemas sc ON sc.schema_id = o.schema_id
  WHERE
    s.object_id = @Id AND
    is_unique_constraint = 0 AND
    is_primary_key = 0 AND
    s.type_desc <> 'heap'

  -- Columns
  SET @i=0
  WHILE 1=1 BEGIN
    SELECT TOP 1 
      @i = ic
    FROM
      @tvData
    WHERE
      ic > @i
    ORDER BY ic 

    IF @@ROWCOUNT = 0 BREAK

    SELECT
      @i2=0,
      @Sql=NULL,
      @Sql2=NULL--,
      --@IxCol=NULL
  	    
    WHILE 1=1 BEGIN
	    SELECT 
	      @i2 = index_column_id, 
	            
		    @Sql = CASE c.is_included_column 
		      WHEN 1 THEN @Sql
		      ELSE ISNULL(@Sql + ', ', CHAR(13) + CHAR(10) + '(' + CHAR(13) + CHAR(10)) + '  ' + QUOTENAME(cc.Name) + 
		        CASE c.is_descending_key 
		          WHEN 1 THEN ' DESC'
		          ELSE ' ASC'
		        END
		      END,
			    
		    @Sql2 = CASE c.is_included_column 
		      WHEN 0 THEN @Sql2 
		      ELSE ISNULL(@Sql2 + ', ', CHAR(13) + CHAR(10) + '(' + CHAR(13) + CHAR(10)) + '  ' + QUOTENAME(cc.Name) --+ 
--		        CASE c.is_descending_key 
--		          WHEN 1  THEN ' DESC'
--		          ELSE ' ASC' 
--		        END
		      END

	      FROM
	        sys.index_columns c
	        INNER JOIN sys.columns cc ON
	          c.column_id = cc.column_id AND
	          cc.object_id = c.object_id
	      WHERE
	        c.object_id = @Id AND
	        index_id=@i AND
	        index_column_id > @i2
        ORDER BY
          index_column_id

		    IF @@ROWCOUNT = 0 BREAK
		              
		  END
		  
		  
      UPDATE @tvData
      SET
        D = D + @Sql + CHAR(13) + CHAR(10) + ')' +
        ISNULL(' INCLUDE' + @Sql2 + ')', '') +
        'WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ' + QUOTENAME('PRIMARY')
        
      WHERE
        ic = @i
    END

  	

    -- References
    SET @i = 0

    WHILE 1 = 1 BEGIN
	    SELECT TOP 1 
	      @i = re
	    FROM
	      @tvData
	    WHERE
	       re > @i
	    ORDER BY re

      IF @@ROWCOUNT = 0 BREAK
  	
	    SELECT
	      @i2=0,
	      @Sql=NULL,
	      @Sql2=NULL
  	  
	    WHILE 1=1 BEGIN
		    SELECT 
		      @i2=f.constraint_column_id, 
			    @Sql = ISNULL(@Sql + ', ', '(') + QUOTENAME(c1.Name),
			    @Sql2 = ISNULL(@Sql2 + ', ', '(') + QUOTENAME(c2.Name)
		    FROM
		      sys.foreign_key_columns f
		      INNER JOIN sys.columns c1 ON
		        c1.column_id = f.parent_column_id AND
		        c1.object_id = f.parent_object_id
		      INNER JOIN sys.columns c2 ON
		        c2.column_id = f.referenced_column_id AND
		        c2.object_id = f.referenced_object_id
		    WHERE
		      f.constraint_object_id = @i AND
		      f.constraint_column_id > @i2
		    ORDER BY
		      f.constraint_column_id

		    IF @@ROWCOUNT = 0 BREAK

		  END

	    UPDATE @tvData 
	    SET
	      D = D + @Sql + ')' --close foreign key
	    WHERE
	      re = @i AND
	      ic = -1

	    UPDATE @tvData
	    SET
	      D = D + @Sql2 + ')'
	    WHERE
	      re = @i AND
	      ic = -2
	  END;

  -- Render
  WITH x AS (
	  SELECT
	    id = d.id-1,
	    D = d.D + ISNULL(d2.D, '')
	  FROM
	    @tvData d
	    LEFT OUTER JOIN @tvData d2 ON
	      d.re = d2.re AND
	      d2.o = 42
	  WHERE
	    d.o = 41		
  )

  UPDATE @tvData
  SET
    D = d.D + x.D
  FROM
    @tvData d
    INNER JOIN x ON x.id=d.id	

  DELETE FROM @tvData
  WHERE
    o IN (41, 42)
    
  SELECT
    @Sql = 'CREATE TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + '(' + @f1
  FROM
    sys.objects o
    INNER JOIN sys.schemas s
  ON
    o.schema_id = s.schema_id
  WHERE
    o.object_id = @Id

  SET @i = 0

  WHILE 1 = 1 BEGIN
	  SELECT TOP 1
	    @I = Id,
	    @Sql = @Sql + D 
	  FROM
	    @tvData
	  ORDER BY
	    o,
	    CASE WHEN o=0 THEN RIGHT('0000' + CONVERT(VARCHAR, id), 5)  ELSE D END,
	    id

	  IF @@ROWCOUNT = 0 BREAK

	  DELETE FROM @tvData
	  WHERE
	    id = @i

  END

	RETURN @Sql
END
GO
/****** Object:  UserDefinedFunction [sqlver].[udfRTRIMSuper]    Script Date: 11/20/2014 17:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sqlver].[udfRTRIMSuper](@S varchar(MAX))
RETURNS varchar(MAX)
AS 
BEGIN
  DECLARE @Result varchar(MAX)
  DECLARE @P int
  SET @P = LEN(@S + 'x') - 1
  WHILE @P >= 1 BEGIN
    IF ISNULL(SUBSTRING(@S, @P, 1), ' ') IN (' ', CHAR(9), CHAR(10), CHAR(13)) BEGIN
      SET @P = @P - 1
    END
    ELSE BEGIN
      BREAK
    END
  END
  
  SET @Result = LEFT(@S, @P)
  
  RETURN @Result  
END
GO
/****** Object:  UserDefinedFunction [sqlver].[udfLTRIMSuper]    Script Date: 11/20/2014 17:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sqlver].[udfLTRIMSuper](@S varchar(MAX))
RETURNS varchar(MAX)
AS 
BEGIN
  DECLARE @Result varchar(MAX)
  DECLARE @P int
  SET @P = 1
  WHILE @P <= LEN(@S + 'x') - 1 BEGIN
    IF SUBSTRING(@S, @P, 1) IN  (' ', CHAR(9), CHAR(10), CHAR(13)) BEGIN
      SET @P = @P + 1
    END
    ELSE BEGIN
      BREAK
    END
  END
  
  SET @Result = RIGHT(@S, LEN(@S + 'x') - 1 - @P + 1)
  
  RETURN @Result  
END
GO
/****** Object:  UserDefinedFunction [sqlver].[udfIsInComment]    Script Date: 11/20/2014 17:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sqlver].[udfIsInComment](
@CharIndex int,
@SQL nvarchar(MAX))
RETURNS BIT
WITH EXECUTE AS OWNER
AS 
BEGIN
  DECLARE @Result bit
  
  IF @CharIndex < 3 BEGIN
    SET @Result = 0
  END
  ELSE IF @CharIndex > LEN(@SQL + 'x') - 1 BEGIN
    SET @Result = NULL
  END
  ELSE BEGIN
    DECLARE @InComment bit
    DECLARE @InBlockComment bit
    
    DECLARE @P int
    DECLARE @C char(1)
    DECLARE @C2 char(1)

    SET @InComment = 0
    SET @InBlockComment = 0
    SET @P = 1
    WHILE @P <= LEN(@SQL + 'x') - 1 - 1 BEGIN
      SET @C = SUBSTRING(@SQL, @P, 1)
      SET @C2 = SUBSTRING(@SQL, @P+1, 1)
    
      IF @InBlockComment = 1 BEGIN
        IF @C + @C2 = '*/' SET @InBlockComment = 0
      END
      ELSE IF @InComment = 1 BEGIN
        IF @C IN (CHAR(13), CHAR(10)) SET @InComment = 0
      END
      ELSE IF @C + @C2 = '/*' BEGIN
        SET @InBlockComment = 1
      END
      ELSE IF @C + @C2 = '--' BEGIN
        SET @InComment = 1
      END
      
      IF @P + 2 >= @CharIndex BEGIN
        BREAK
      END
      ELSE BEGIN    
        SET @P = @P + 1  
      END
    END
    
   SET @Result = CASE WHEN ((@InComment = 1) OR (@InBlockComment = 1)) THEN 1 ELSE 0 END
    
  END
  
  RETURN @Result
END
GO
/****** Object:  UserDefinedFunction [sqlver].[udfHashBytesNMax]    Script Date: 11/20/2014 17:16:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [sqlver].[udfHashBytesNMax](@Algorithm sysname, @Input nvarchar(MAX))
RETURNS varbinary(MAX)
AS
BEGIN
  DECLARE @Result varbinary(MAX)

  DECLARE @Chunk int
  DECLARE @ChunkSize int
  
  SET @ChunkSize = 4000
  SET @Chunk = 1
  SET @Result = CAST('' AS varbinary(MAX))

  WHILE @Chunk * @ChunkSize < LEN(@Input + 'x') - 1 BEGIN
    --Append the hash for each chunk
    SET @Result = @Result + HASHBYTES(@Algorithm, SUBSTRING(@Input, ((@Chunk - 1) * @ChunkSize) + 1, @ChunkSize))
    SET @Chunk = @Chunk + 1
  END

  --Append the hash for the final partial chunk
  SET @Result =  HASHBYTES(@Algorithm, RIGHT(@Input, LEN(@Input + 'x') - 1 - ((@Chunk - 1) * @ChunkSize)))

  IF @Chunk > 1 BEGIN
    --If we have appended more than one hash, hash the hash.
    --We want to return just normal 160 bit (or whatever the @Algorithm calls for) value,
    --but at the moment we have any number of concatenated hash values in @Result.
    --We therefore need to hash the whole @Result buffer. 
    SET @Result = HASHBYTES(@Algorithm, @Result)    
  END
  
  RETURN @Result
END
GO
/****** Object:  Table [sqlver].[tblSysRTLog]    Script Date: 11/20/2014 17:16:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [sqlver].[tblSysRTLog](
	[SysRTLogId] [int] IDENTITY(1,1) NOT NULL,
	[DateLogged] [datetime] NULL,
	[Msg] [varchar](max) NULL,
	[MsgXML] [xml] NULL,
	[ThreadGUID] [uniqueidentifier] NULL,
	[SPID] [int] NULL,
 CONSTRAINT [pkSysRTMessages] PRIMARY KEY CLUSTERED 
(
	[SysRTLogId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [sqlver].[tblSchemaManifest]    Script Date: 11/20/2014 17:16:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [sqlver].[tblSchemaManifest](
	[SchemaManifestId] [int] IDENTITY(1,1) NOT NULL,
	[ObjectName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[OrigDefinition] [nvarchar](max) NULL,
	[DateAppeared] [datetime] NULL,
	[CreatedByLoginName] [sysname] NOT NULL,
	[DateUpdated] [datetime] NULL,
	[OrigHash] [varbinary](128) NULL,
	[CurrentHash] [varbinary](128) NULL,
	[IsEncrypted] [bit] NULL,
	[StillExists] [bit] NULL,
	[SkipLogging] [bit] NULL,
	[Comments] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[SchemaManifestId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Table [sqlver].[tblSchemaLog]    Script Date: 11/20/2014 17:16:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [sqlver].[tblSchemaLog](
	[SchemaLogId] [int] IDENTITY(1,1) NOT NULL,
	[SPID] [smallint] NULL,
	[EventType] [varchar](50) NULL,
	[ObjectName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[DatabaseName] [sysname] NOT NULL,
	[ObjectType] [varchar](25) NULL,
	[SQLCommand] [nvarchar](max) NULL,
	[EventDate] [datetime] NULL,
	[LoginName] [sysname] NOT NULL,
	[EventData] [xml] NULL,
	[Hash] [varbinary](128) NULL,
	[Comments] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[SchemaLogId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  StoredProcedure [sqlver].[spWhoIsHogging]    Script Date: 11/20/2014 17:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[spWhoIsHogging]
@LockType varchar(100) = 'X' --default is eXclusive locks only.  Pass NULL or 'all' to show all locks
AS
BEGIN
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  
  SELECT DISTINCT
    DB_NAME(l.resource_database_id) AS DBName,
    CASE 
      WHEN l.resource_type = 'OBJECT' THEN OBJECT_NAME(l.resource_associated_entity_id) 
      WHEN l.resource_type IN ('KEY', 'PAGE', 'RID') THEN OBJECT_NAME(part.object_id)         
    END AS ObjectName, 
    l.request_session_id AS SPID,     
    sp.loginame AS LoginName,   
    sp.hostname AS HostName,     
    sp.last_batch AS LastBatchTime,   
    sp.open_tran AS SessionOpenTran,
    
    COALESCE(OBJECT_SCHEMA_NAME(tx.objectid, tx.dbid) + '.' + OBJECT_NAME(tx.objectid), tx.text) AS Query, 
        
    sp.blocked AS Blocked,
    
    CASE 
      WHEN er.blocking_session_id > 0 THEN er.blocking_session_id 
    END AS BlockedBySPID,
    CASE er.blocking_session_id
      WHEN 0  Then 'Not Blocked'
      WHEN -2 Then 'Orphaned Distributed Transaction'
      WHEN -3 Then 'Deferred Recovery Transaction'
      WHEN -4 Then 'Latch owner not determined'
    END AS Blocking_Type,    
    
    l.request_mode AS RequestMode,    
    l.request_type AS RequestType,
    l.request_status AS RequestStatus, 
    l.resource_type AS ResourceType, 

    l.resource_subtype AS ResourceSubType,      
    sp.cmd AS Cmd,
 
    sp.waittype AS WaitType,
    sp.waittime AS WaitTime,
    er.total_elapsed_time AS TotalElapsedTime,
    sp.cpu AS CPU,
    sp.physical_io AS PhysicalIO,
    er.reads,
    er.writes,
    er.logical_reads,
    er.Command,    
    sp.program_name AS ProgramName,
    l.request_owner_type,
    l.request_reference_count,
    l.request_lifetime,
    --l.resource_description,
    l.resource_lock_partition,
    CASE er.transaction_isolation_level
      WHEN 0 THEN 'Unspecified'
      WHEN 1 THEN 'Read Uncomitted'
      WHEN 2 THEN 'Read Committed'
      WHEN 3 THEN 'Repeatable'
      WHEN 4 THEN 'Serializable'
      WHEN 5 THEN 'Snapshot'
    END AS TransactionIsolationLevel,       
    er.percent_complete,
    er.estimated_completion_time  
  FROM 
    sys.dm_tran_locks l
    LEFT JOIN sys.sysprocesses sp ON
      l.request_session_id = sp.spid
    LEFT JOIN sys.dm_exec_requests er ON
      sp.spid = er.session_id     
    LEFT JOIN sys.partitions part ON
      l.resource_associated_entity_id  = part.hobt_id                                                  
    OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) tx    
  WHERE
    DB_NAME(l.resource_database_id) <> 'tempdb' AND
    l.resource_database_id = DB_ID() AND
    sp.spid <> @@SPID AND
    (NULLIF(NULLIF(@LockType, 'all'), '1') IS NULL OR l.request_type = @LockType)
    
  ORDER BY
    DB_NAME(l.resource_database_id),
    l.request_session_id
    
--select * from master.sys.dm_exec_sessions     
    
END
GO
/****** Object:  StoredProcedure [sqlver].[spVersion]    Script Date: 11/20/2014 17:16:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[spVersion]
@ObjectName nvarchar(512) = NULL,
@MaxVersions int = NULL,
@ChangedSince datetime = NULL,
@SchemaLogId int = NULL,
@SortByName bit = 0
AS
BEGIN
  SET NOCOUNT ON
  
  DECLARE @TargetDBName sysname
  DECLARE @TargetSchemaName sysname
  DECLARE @TargetObjectName sysname
  
  SET @TargetDBName = ISNULL(PARSENAME(@ObjectName, 3), DB_NAME())
  SET @TargetSchemaName = ISNULL(PARSENAME(@ObjectName, 2), '%')
  SET @TargetObjectName = ISNULL(PARSENAME(@ObjectName, 1), '%')

  SELECT
    x.Object,
    x.LastUpdate,
    x.LastUpdateBy,
    x.Comments,
    x.SQLCommand,
    x.DateAppeared,
    x.SchemaLogId,
    x.Hash
  FROM (
    SELECT
      COALESCE(
        l.DatabaseName + '.' + l.SchemaName + '.' + l.ObjectName,
        m.DatabaseName + '.' + m.SchemaName + '.' + m.ObjectName) AS Object,
      m.DateAppeared,
      l.SchemaLogId,
      COALESCE(l.EventDate, m.DateUpdated) AS LastUpdate,
      COALESCE(l.LoginName, m.CreatedByLoginName) AS LastUpdateBy,
      COALESCE(l.Comments, m.Comments) AS Comments,
      COALESCE(l.Hash, m.CurrentHash) AS Hash,
      COALESCE(l.SQLCommand, m.OrigDefinition) AS SQLCommand,
      CASE 
        WHEN l.SchemaLogID IS NULL THEN 0 
        ELSE ROW_NUMBER() OVER (PARTITION BY l.DatabaseName, l.SchemaName, l.ObjectName ORDER BY l.SchemaLogId DESC)
      END AS Seq
    FROM
      sqlver.tblSchemaLog l
      FULL OUTER JOIN sqlver.tblSchemaManifest m ON
        l.SchemaName = m.SchemaName AND
        l.ObjectName = m.ObjectName
    WHERE
      COALESCE(l.DatabaseName, m.DatabaseName) LIKE @TargetDBName AND
      COALESCE(l.SchemaName, m.SchemaName) LIKE @TargetSchemaName AND
      COALESCE(l.ObjectName, m.ObjectName) LIKE @TargetObjectName AND
      
      (@ChangedSince IS NULL OR COALESCE(l.EventDate, m.DateUpdated) >= @ChangedSince) AND
      (@SchemaLogId IS NULL OR l.SchemaLogId = @SchemaLogId)
    ) x
  WHERE
    (
     (@MaxVersions IS NULL AND x.Seq < 2) OR
     (x.Seq < = @MaxVersions)
    )
  ORDER BY
    CASE 
      WHEN @SortByName = 1 THEN x.Object
    END,
    CASE    
      WHEN @ChangedSince IS NOT NULL OR 
        (
        @ObjectName IS NULL AND
        @MaxVersions IS NULL AND
        @ChangedSince IS NULL AND
        @SchemaLogId IS NULL
        )
        THEN x.LastUpdate
    END DESC,
    x.LastUpdate DESC,
    x.Object
    
    
    
    
    
  IF @SchemaLogId IS NOT NULL BEGIN
    DECLARE @Buf nvarchar(MAX)
    SELECT @Buf = l.SQLCommand
    FROM
      sqlver.tblSchemaLog l
    WHERE
      l.SchemaLogID = @SchemaLogID
      
   EXEC sqlver.sputilPrintString @Buf
          
  END
END
GO
/****** Object:  StoredProcedure [sqlver].[spShowRTLog]    Script Date: 11/20/2014 17:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[spShowRTLog]
AS
BEGIN
  SET NOCOUNT ON
  
  SELECT TOP 5000
    rt.*
  FROM 
    sqlver.tblSysRTLog (NOLOCK) rt
  ORDER BY
    rt.SysRTLogID DESC  
END
GO
/****** Object:  StoredProcedure [sqlver].[spinsSysRTLog]    Script Date: 11/20/2014 17:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[spinsSysRTLog]
@Msg varchar(MAX) = NULL,
@MsgXML xml = NULL,
@ThreadGUID uniqueidentifier = NULL,
@SPID int = NULL,
@PersistAfterRollback bit = 0
WITH EXECUTE AS OWNER
AS 
BEGIN
  SET NOCOUNT ON
  
  --Added 2/13/2013.  Since this procedure is used for logging messages, including errors, it is possible
  --that this routine may be called in a TRY / CATCH block when there is a doomed transaction.  In such a
  --case this insert would fail.  Since the transaction is doomed anyway, I think that rolling it back here
  --(instead of explicitly within each CATCH block) is cleaner.
  IF XACT_STATE() = -1 BEGIN
    ROLLBACK TRAN
  END  
  
  SET @SPID = COALESCE(@@SPID, @SPID)
  
  IF @PersistAfterRollback = 0 BEGIN
    INSERT INTO sqlver.tblSysRTLog
      (DateLogged, Msg, MsgXML, ThreadGUID, SPID)
    VALUES
      (GETDATE(), @Msg, @MsgXML, @ThreadGUID, @SPID)
  END
  ELSE BEGIN
    /*
    This procedure is designed to allow a caller to provide a message that will be written to an error log table,
    and allow the caller to call it within a transaction.  The provided message will be persisted to the
    error log table even if the transaction is rolled back.
    
    To accomplish this, this procedure utilizes ADO to establish a second database connection (outside
    the transaction context) back into the database to call the dbo.spLogError procedure.
    */
    DECLARE @ConnStr varchar(MAX)
      --connection string for ADO to use to access the database
    SET @ConnStr = 'Provider=SQLNCLI10; DataTypeCompatibility=80; Server=localhost; Database=' + DB_NAME() + '; Uid=sqlverLogger; Pwd=sqlverLoggerPW;'

    DECLARE @SQLCommand varchar(MAX)
    SET @SQLCommand = 'EXEC sqlver.spinsSysRTLog @PersistAfterRollback=0' + 
                      ISNULL(', @Msg=''' + REPLACE(@Msg, CHAR(39), CHAR(39) + CHAR(39)) + '''', '') + 
                      ISNULL(', @ThreadGUID = ''' + CAST(@ThreadGUID AS varchar(100)) + '''', '') + 
                      ISNULL(', @MsgXML = ''' + REPLACE(CAST(@MsgXML AS varchar(MAX)), CHAR(39), CHAR(39) + CHAR(39)) + '''', '') +                      
                      ISNULL(', @SPID = ''' + CAST(@SPID AS varchar(100)) + '''', '') 
                      
    DECLARE @ObjCn int 
      --ADO Connection object  
    DECLARE @ObjRS int    
      --ADO Recordset object returned
      
    DECLARE @RecordCount int   
      --Maximum records to be returned
    SET @RecordCount = 0
     
    DECLARE @ExecOptions int
      --Execute options:  0x80 means to return no records (adExecuteNoRecords) + 0x01 means CommandText is to be evaluted as text
    SET @ExecOptions = 0x81
        
    DECLARE @LastResultCode int = NULL 
       --Last result code returned by an sp_OAxxx procedure.  Will be 0 unless an error code was encountered.
    DECLARE @ErrSource varchar(512)
      --Returned if a COM error is encounterd
    DECLARE @ErrMsg varchar(512)
      --Returned if a COM error is encountered
    
    DECLARE @ErrorMessage varchar(MAX) = NULL
      --our formatted error message


    SET @ErrorMessage = NULL
    SET @LastResultCode = 0
        
      
    BEGIN TRY
      EXEC @LastResultCode = sp_OACreate 'ADODB.Connection', @ObjCn OUT 
      IF @LastResultCode <> 0 BEGIN
        EXEC sp_OAGetErrorInfo @ObjCn, @ErrSource OUTPUT, @ErrMsg OUTPUT 
      END
    END TRY
    BEGIN CATCH
      SET @ErrorMessage = ERROR_MESSAGE()
    END CATCH
    
    
     BEGIN TRY  
      IF @LastResultCode = 0 BEGIN
       
        EXEC @LastResultCode = sp_OAMethod @ObjCn, 'Open', NULL, @ConnStr
        IF @LastResultCode <> 0 BEGIN
          EXEC sp_OAGetErrorInfo @ObjCn, @ErrSource OUTPUT, @ErrMsg OUTPUT 
        END                
      END  
    END TRY
    BEGIN CATCH
      SET @ErrorMessage = ERROR_MESSAGE()
    END CATCH

      
    IF @LastResultCode = 0 BEGIN
      EXEC @LastResultCode = sp_OAMethod @ObjCn, 'Execute', @ObjRS OUTPUT, @SQLCommand, @ExecOptions
      IF @LastResultCode <> 0 BEGIN
        EXEC sp_OAGetErrorInfo @ObjCn, @ErrSource OUTPUT, @ErrMsg OUTPUT 
      END                
    END
      
    IF @ObjRS IS NOT NULL BEGIN
      BEGIN TRY
        EXEC sp_OADestroy @ObjCn  
      END TRY
      BEGIN CATCH
        --not much we can do...
        SET @LastResultCode = 0
      END CATCH
    END
      
    IF @ObjCn= 1 BEGIN
      BEGIN TRY
        EXEC sp_OADestroy @ObjCn
      END TRY
      BEGIN CATCH
        --not much we can do...
        SET @LastResultCode = 0
      END CATCH
    END    
      
    IF ((@LastResultCode <> 0) OR (@ErrorMessage IS NOT NULL)) BEGIN
      SET @ErrorMessage = 'Error in sqlver.spinsSysRTLog' + ISNULL(': ' + @ErrMsg, '')
      RAISERROR(@ErrorMessage, 16, 1)
    END
  
  END
  
END
GO
/****** Object:  StoredProcedure [sqlver].[spBuildManifest]    Script Date: 11/20/2014 17:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[spBuildManifest]
AS
BEGIN
  SET NOCOUNT ON 
  
  INSERT INTO sqlver.tblSchemaManifest(  
    ObjectName,
    SchemaName,
    DatabaseName,  
    OrigDefinition,
    DateAppeared,
    CreatedByLoginName,
    DateUpdated,
    OrigHash,
    CurrentHash,
    IsEncrypted,
    StillExists,
    SkipLogging,
    Comments
  )
  SELECT
    so.name,
    sch.name,
    DB_NAME(),
    CASE 
      WHEN so.type_desc = 'USER_TABLE' THEN sqlver.udfScriptTable(sch.name, so.name)
      ELSE OBJECT_DEFINITION(so.object_id)
    END AS OrigDefinition,
    so.create_date,
    'Before SQLVer',
    so.modify_date,
    sqlver.udfHashBytesNMax('SHA1',
      CASE 
        WHEN so.type_desc = 'USER_TABLE' THEN sqlver.udfScriptTable(sch.name, so.name)
        ELSE OBJECT_DEFINITION(so.object_id)
      END
    ) AS OrigHash,
    
    sqlver.udfHashBytesNMax('SHA1',
      CASE 
        WHEN so.type_desc = 'USER_TABLE' THEN sqlver.udfScriptTable(sch.name, so.name)
        ELSE OBJECT_DEFINITION(so.object_id)
      END
    ) AS CurrentHash,    
        
    0 AS IsEnrypted,
    1 AS StillExists,
    0 AS SkipLogging,
    'Found on ' + CAST(GETDATE() AS varchar(100)) + ' by sqlver.spBuildManifest'    
  FROM
    sys.objects so
    JOIN sys.schemas sch ON
      sch.schema_ID = so.schema_ID
    LEFT JOIN sqlver.tblSchemaManifest m ON
      sch.name = m.SchemaName AND
      so.name = m.ObjectName
    WHERE so.type_desc IN (
        'SQL_SCALAR_FUNCTION',
        'SQL_STORED_PROCEDURE',
        'SQL_TABLE_VALUED_FUNCTION',
        'SQL_TRIGGER',
        'USER_TABLE',
        'VIEW',
        'SYNONYM') AND
      m.SchemaManifestId IS NULL    
    ORDER BY 
      sch.name,
      so.name  
END
GO
/****** Object:  StoredProcedure [sqlver].[sputilFindInCode]    Script Date: 11/20/2014 17:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sqlver].[sputilFindInCode]
@TargetString varchar(254),
@TargetSchema sysname = NULL
AS 
BEGIN
  SET NOCOUNT ON
  
  DECLARE @Msg varchar(MAX)
  
  DECLARE @PreLen int
  SET @PreLen = 40
  
  DECLARE @PostLen int
  SET @PostLen = 40
  
  SELECT DISTINCT
    sch.name AS SchemaName,
    so.name AS ObjectName, 
    SUBSTRING(sysmod.definition, 
      CASE WHEN PATINDEX('%' + @TargetString + '%', sysmod.definition) - @PreLen < 1 
        THEN 1 
        ELSE PATINDEX('%' + @TargetString + '%', sysmod.definition) - @PreLen
      END,
       
      CASE WHEN PATINDEX('%' + @TargetString + '%', sysmod.definition) + LEN(@TargetString + 'x') - 1 + @PreLen + @PostLen > LEN(sysmod.definition + 'x') - 1
        THEN LEN(sysmod.definition + 'x') - 1 - PATINDEX('%' + @TargetString + '%', sysmod.definition) + 1
        ELSE LEN(@TargetString + 'x') - 1 + @PreLen + @PostLen
      END) AS Context
  INTO #Results
  FROM
    sys.objects so
    JOIN sys.schemas sch ON so.schema_id = sch.schema_id
    JOIN sys.sql_modules  sysmod ON so.object_id = sysmod.object_id
  WHERE 
    ((@TargetSchema IS NULL) OR (sch.name = @TargetSchema)) AND
    (PATINDEX('%' + @TargetString + '%', sysmod.definition) > 0) 
    
  BEGIN TRY 
  INSERT INTO #Results (
    SchemaName,
    ObjectName,
    Context
  )
  SELECT DISTINCT
    CAST('**SQL Agent Job***' AS sysname)  collate database_default AS SchemaName,
    CAST(sysj.name + ' | Step: ' +  sysjs.step_name + ' (' + CAST(sysjs.step_id AS varchar(100)) + ')' AS sysname) collate database_default AS ObjectName,
    
    SUBSTRING(sysjs.command, 
      CASE WHEN PATINDEX('%' + @TargetString + '%', sysjs.command) - @PreLen < 1 
        THEN 1 
        ELSE PATINDEX('%' + @TargetString + '%', sysjs.command) - @PreLen
      END,
       
      CASE WHEN PATINDEX('%' + @TargetString + '%', sysjs.command) + LEN(@TargetString + 'x') - 1 + @PreLen + @PostLen > LEN(sysjs.command + 'x') - 1
        THEN LEN(sysjs.command + 'x') - 1 - PATINDEX('%' + @TargetString + '%', sysjs.command) + 1
        ELSE LEN(@TargetString + 'x') - 1 + @PreLen + @PostLen
      END) collate database_default AS Context     
  FROM
    msdb.dbo.sysjobs sysj
    JOIN msdb.dbo.sysjobsteps sysjs ON
      sysj.job_id = sysjs.job_id      
  WHERE 
    (PATINDEX('%' + @TargetString + '%', sysjs.command) > 0)
  END TRY
  BEGIN CATCH
    SET @Msg='sqlver.sputilFindInCode could not search SQL Agent jobs: ' + ERROR_MESSAGE() 
  END CATCH
        
  SELECT
    SchemaName,
    ObjectName,
    Context
  FROM
    #Results
  ORDER BY
    SchemaName,
    ObjectName
END
GO
/****** Object:  Synonym [sqlver].[printStr]    Script Date: 11/20/2014 17:16:18 ******/
CREATE SYNONYM [sqlver].[printStr] FOR [sqlver].[sputilPrintString]
GO
/****** Object:  Synonym [sqlver].[uninstall]    Script Date: 11/20/2014 17:16:18 ******/
CREATE SYNONYM [sqlver].[uninstall] FOR [sqlver].[spUninstall]
GO
/****** Object:  Synonym [sqlver].[ver]    Script Date: 11/20/2014 17:16:18 ******/
CREATE SYNONYM [sqlver].[ver] FOR [sqlver].[spVersion]
GO
/****** Object:  Synonym [sqlver].[find]    Script Date: 11/20/2014 17:16:18 ******/
CREATE SYNONYM [sqlver].[find] FOR [sqlver].[sputilFindInCode]
GO
/****** Object:  Synonym [sqlver].[buildManifest]    Script Date: 11/20/2014 17:16:18 ******/
CREATE SYNONYM [sqlver].[buildManifest] FOR [sqlver].[spBuildManifest]
GO
/****** Object:  Synonym [sqlver].[RTLog]    Script Date: 11/20/2014 17:16:18 ******/
CREATE SYNONYM [sqlver].[RTLog] FOR [sqlver].[spinsSysRTLog]
GO
/****** Object:  Default [dftblSysRTLog_DateLogged]    Script Date: 11/20/2014 17:16:10 ******/
ALTER TABLE [sqlver].[tblSysRTLog] ADD  CONSTRAINT [dftblSysRTLog_DateLogged]  DEFAULT (getdate()) FOR [DateLogged]
GO
/****** Object:  DdlTrigger [dtgLogSchemaChanges]    Script Date: 11/20/2014 17:16:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dtgLogSchemaChanges] ON DATABASE
FOR
  create_procedure, alter_procedure, drop_procedure,
  create_table, alter_table, drop_table,
  create_view, alter_view, drop_view,
  create_function, alter_function, drop_function,
  create_index, alter_index, drop_index,
  create_trigger, alter_trigger, drop_trigger,
  create_synonym, drop_synonym
AS
BEGIN
  --Logs schema changes to sqlver.tblSchemaLog
  SET NOCOUNT ON
  
  DECLARE @Debug bit
  SET @Debug = 0
  
  DECLARE @Visible bit
  SET @Visible = 1
  
  IF @Debug = 1 BEGIN
    PRINT 'dtgLogSchemaChanges: Starting'
  END
  
  BEGIN TRY
    --retrieve trigger event data
    DECLARE @EventData xml
    SET @EventData = EVENTDATA()
    
    DECLARE @SkipLogging bit
    DECLARE @IsEncrypted bit
    
    DECLARE @DatabaseName sysname
    DECLARE @SchemaName sysname
    DECLARE @ObjectName sysname
    DECLARE @EventType varchar(50)
    DECLARE @ObjectType varchar(25)
    DECLARE @QualifiedName varchar(775)
    DECLARE @ObjectId int
    DECLARE @SQLFromEvent nvarchar(MAX)
    DECLARE @SQLForHash nvarchar(MAX)
    DECLARE @SQLWithStrippedComment nvarchar(MAX)
    
    DECLARE @SPID smallint
    DECLARE @LoginName sysname
    DECLARE @EventDate datetime
    
    DECLARE @Comments nvarchar(MAX)
    
    DECLARE @HasEmbeddedComment bit
    SET @HasEmbeddedComment = 0
    
    DECLARE @NeedExec bit
    SET @NeedExec = 0
    
    DECLARE @Buf nvarchar(MAX)
    DECLARE @P int
    
    --grab values from event XML
    SET @ObjectType = @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)')
    SET @DatabaseName = @EventData.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'sysname')
    SET @SchemaName = @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]', 'sysname')
    SET @SPID = @EventData.value('(/EVENT_INSTANCE/SPID)[1]', 'smallint');
    
    SET @ObjectName = CASE
                        WHEN @ObjectType = 'INDEX' THEN @EventData.value('(/EVENT_INSTANCE/TargetObjectName)[1]', 'sysname')
                        ELSE @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'sysname')
                      END

    SET @EventType = @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)')
    SET @LoginName = @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'sysname')
    SET @EventDate = COALESCE(@EventData.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime'), GETDATE())
    
    SET @SQLFromEvent = @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(MAX)')
    SET @QualifiedName = QUOTENAME(@DatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@ObjectName)
    SET @ObjectId = OBJECT_ID(@QualifiedName) 
    
    IF @SQLFromEvent LIKE 'ALTER INDEX%' AND
       PATINDEX('%REBUILD WITH%', @SQLFromEvent) > 0 BEGIN
      SET @SkipLogging = 1
      --We don't want to log index rebuilds
    END                   
    
    IF @ObjectName = 'dtgLogSchemaChanges' BEGIN
      IF @Debug = 1 PRINT 'Exiting dtgLogSchemaChanges ON ' + @SchemaName + '.' + @ObjectName + ' because @SkipLogging = 1'
      RETURN
    END
   
    SET @IsEncrypted = CASE WHEN @SQLFromEvent = '--ENCRYPTED--' THEN 1 ELSE 0 END
    IF @IsEncrypted = 1 BEGIN
      --We will assume that the DDL for the object is being updated.
      --Since we can't calculate a hash on the actual statement, we'll calculate a
      --hash on a new GUID to force a unique hash.  This way this event will
      --be treated as a new update that needs to be logged.
      SET @SQLFromEvent = CAST(NEWID() AS nvarchar(MAX))
    END
    
    SET @P = PATINDEX('%/*/%', @SQLFromEvent)
     
    IF @P > 0 BEGIN      
      DECLARE @SQLLen int
      SET @SQLLen = LEN(@SQLFromEvent + 'x') - 1 
      SET @Buf = RIGHT(@SQLFromEvent, @SQLLen - @P + 1 - LEN('/*/'))   
      SET @Buf = LEFT(@Buf, PATINDEX('%*/%', @Buf) - 1)
      SET @Comments = ISNULL(@Comments + ' | ', '') + ISNULL(NULLIF(RTRIM(@Buf), ''), '')

      SET @HasEmbeddedComment = 1
      
      SET @SQLWithStrippedComment = LEFT(@SQLFromEvent, @P - 1) + SUBSTRING(@SQLFromEvent, @P + LEN(@Buf) +  7, @SQLLen)        
    END
        
         
    IF @ObjectType = 'TABLE' BEGIN
      --Retrieve the complete definition of the table
      SET @SQLForHash = sqlver.udfScriptTable(@SchemaName, @ObjectName)
    END
    ELSE BEGIN
      --Use the SQL that was in the statement
      IF @HasEmbeddedComment = 1 BEGIN
        SET @SQLForHash = @SQLWithStrippedComment
      END
      ELSE BEGIN
        SET @SQLForHash = @SQLFromEvent
      END
    END
    SET @SQLForHash = sqlver.udfRTRIMSuper(sqlver.udfLTRIMSuper(
      REPLACE(
        REPLACE(@SQLForHash, 'ALTER ' + @ObjectType, 'CREATE ' + @ObjectType), --always base hash on the create statement
        'CREATE ' + @ObjectType, 'CREATE ' + @ObjectType   --to ensure case of object type is consistent
      )
    ))
    
    
    DECLARE @LastSchemaLogId int
    DECLARE @SchemaLogId int
    
    DECLARE @ManifestId int

    DECLARE @CalculatedHash varbinary(128)
    DECLARE @StoredHash varbinary(128)
    DECLARE @StoredHashManifest varbinary(128)
    
    
    SET @IsEncrypted = CASE WHEN @SQLFromEvent = '--ENCRYPTED--' THEN 1 ELSE 0 END
    
    
    --Retrieve manifest data
    IF @Debug = 1 BEGIN
      PRINT 'dtgLogSchemaChanges: Retrieving from sqlver.tblSchemaManifest'
    END
  
    SELECT
      @ManifestId = m.SchemaManifestId,
      @StoredHashManifest = m.CurrentHash,
      @SkipLogging = m.SkipLogging
    FROM
      sqlver.tblSchemaManifest m
    WHERE
      m.SchemaName = @SchemaName AND
      m.ObjectName = @ObjectName
      

    SET @SkipLogging = ISNULL(@SkipLogging, 0)
    
    SELECT
      @LastSchemaLogId = MAX(schl.SchemaLogId)
    FROM
      sqlver.tblSchemaLog schl
    WHERE
      schl.SchemaName = @SchemaName AND
      schl.ObjectName = @ObjectName        
    
    
    IF @SkipLogging = 0 BEGIN    
      IF @SQLWithStrippedComment IS NOT NULL AND @ObjectType <> 'TABLE' BEGIN
        SET @NeedExec = 1
      END
          
      SELECT @StoredHash = schl.Hash
      FROM
        sqlver.tblSchemaLog schl
      WHERE
        @LastSchemaLogId = schl.SchemaLogId
        
      SET @StoredHash = COALESCE(@StoredHash, @StoredHashManifest)
      
      
      IF @Debug = 1 BEGIN
        PRINT 'dtgLogSchemaChanges: Calculating hash'
      END
      
      SET @CalculatedHash =  sqlver.udfHashBytesNMax('SHA1', @SQLForHash)
      
      IF (@CalculatedHash = @StoredHash) BEGIN
        --Hash matches.  Nothing has changed.
        IF @Debug = 1 BEGIN
          PRINT 'dtgLogSchemaChanges: Hash matches.  Nothing has changed.'
        END
        
        IF @Comments IS NOT NULL BEGIN
          UPDATE sqlver.tblSchemaLog
          SET
            Comments = Comments + ' | ' + @Comments
          WHERE
            SchemaLogId = @LastSchemaLogId
        END      
                    
        SET @SkipLogging = 1
      END


      IF @ManifestId IS NULL BEGIN
        IF @Debug = 1 BEGIN
          PRINT 'dtgLogSchemaChanges: Inserting into sqlver.tblSchemaManifest'
        END
        
        INSERT INTO sqlver.tblSchemaManifest(  
          ObjectName,
          SchemaName,
          DatabaseName,  
          OrigDefinition,
          DateAppeared,
          CreatedByLoginName,
          DateUpdated,
          OrigHash,
          CurrentHash,
          IsEncrypted,
          StillExists,
          SkipLogging,
          Comments             
        )
        VALUES (
          @ObjectName,
          @SchemaName,
          @DatabaseName,  
          @SQLForHash,
          @EventDate,
          @LoginName,
          @EventDate,
          @CalculatedHash,
          @CalculatedHash,
          @IsEncrypted,
          1,
          @NeedExec,
          @Comments 
        )
        
        SET @ManifestId = SCOPE_IDENTITY()  
      END
      ELSE BEGIN
        IF @Debug = 1 BEGIN
          PRINT 'dtgLogSchemaChanges: Updating sqlver.tblSchemaManifest'
        END
        
        UPDATE sqlver.tblSchemaManifest
        SET
          DateUpdated = @EventDate,
          CurrentHash = @CalculatedHash,
          IsEncrypted = @IsEncrypted,
          StillExists = CASE WHEN OBJECT_ID(@SchemaName + '.' + @ObjectName) IS NOT NULL THEN 1 ELSE 0 END,
          SkipLogging = @NeedExec
        WHERE
          SchemaManifestId = @ManifestId               
      END            
    
      
      IF @SkipLogging = 0 BEGIN
        IF @Debug = 1 BEGIN
          PRINT 'dtgLogSchemaChanges: Inserting into sqlver.tblSchemaLog'
        END      
        
        INSERT INTO sqlver.tblSchemaLog (
          SPID,
          EventType,
          ObjectName,
          SchemaName,
          DatabaseName, 
          ObjectType,
          SQLCommand,
          EventDate,
          LoginName,
          EventData,
          Comments,
          Hash
        )
        VALUES (
          COALESCE(@SPID, @@SPID),
          @EventType,
          @ObjectName,
          @SchemaName,
          @DatabaseName, 
          @ObjectType,
          @SQLFromEvent,
          @EventDate,
          @LoginName,
          @EventData,
          @Comments,
          @CalculatedHash                
        )
    
        SET @SchemaLogId = SCOPE_IDENTITY()
        SET @StoredHash = @CalculatedHash            
        
      END    
      
      IF @NeedExec = 1 BEGIN        
        SET @SQLFromEvent = REPLACE(@SQLFromEvent, 'CREATE ' + @ObjectType, 'ALTER ' + @ObjectType)
        EXEC (@SQLFromEvent)   
        
        UPDATE sqlver.tblSchemaManifest
        SET
          SkipLogging = 0
        WHERE
          SchemaManifestId = @ManifestId             
      END      
    END  
    
    
    IF @Visible = 1 BEGIN      
      PRINT 'Changes to ' + @DatabaseName + '.' + @SchemaName + '.' + @ObjectName + ' successfully logged by SQLVer'      
    END
  END TRY
  BEGIN CATCH
    PRINT 'Error logging DDL changes in database trigger dtgLogSchemaChanges: ' + ERROR_MESSAGE()
    PRINT 'Your DDL statement may have been successfully processed, but changes were not logged by the version tracking system.'
  END CATCH
  
  IF @Debug = 1 BEGIN
    PRINT 'dtgLogSchemaChanges: Finished'
  END  
  
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
DISABLE TRIGGER [dtgLogSchemaChanges] ON DATABASE
GO
/****** Object:  DdlTrigger [dtgLogSchemaChanges]    Script Date: 11/20/2014 17:16:18 ******/
Enable Trigger [dtgLogSchemaChanges] ON Database
GO

EXEC sqlver.buildManifest

PRINT 'SQLVer has been installed.  All DDL changes will now be automatically logged.'
PRINT ''
PRINT 'At any time you can run EXEC sqlver.ver to obtain a list of objects and the current version information.'
PRINT 'You can also run EXEC sqlver.ver @ObjectName = ''tblXYZ'', @MaxVersions = 5'
PRINT 'to get a list of the most recent 5 versions of the specified object.'
PRINT ''
PRINT 'If you need to permenantely uninstall you can run EXEC sqlver.spUninstall'
PRINT ''
PRINT 'There is a lot more that SQLVer does too: arbitrary run-time logging, identification of slow queries and connections hogging resources, and more.'
PRINT ''
PRINT 'See the resultset for a list of your current objects and versions.'

