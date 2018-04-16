
IF OBJECT_ID(N'dbo.csp_GetFKsByTable') IS NOT NULL DROP PROCEDURE dbo.csp_GetFKsByTable
GO

CREATE PROCEDURE dbo.csp_GetFKsByTable (
	@SchemaName	SYSNAME,
	@TableName	SYSNAME )
AS
/*
	csp_GetFKsByTable
	
	by MByrd, 20111221
	
	Stored proc puts drop and create dependency Foreign Key (FK) statements into following table 
		(build by calling script):
	
	CREATE TABLE #tFK (SchemaName	SysName, TableName	SysName, DropStatement	NVARCHAR(4000), CreateStatement	NVARCHAR(4000))

	Requires input parameter of @SchemaName,@TableName.

	Test:  
		IF OBJECT_ID(N'tempdb..#tFK') IS NOT NULL DROP TABLE #tFK
		CREATE TABLE #tFK (SchemaName	SysName, TableName	SysName, DropStatement	NVARCHAR(4000), CreateStatement	NVARCHAR(4000))
		EXEC dbo.csp_GetFKsByTable 'Sales','Customer'
		SELECT * FROM #tFK
*/

	DECLARE @FKName				SysName,
			@ParentSchema		SysName,
			@ParentTable		SysName,
			@ParentColumn		SysName,
			@RefSchema			SysName,
			@RefTable			SysName,
			@RefColumn			SysName,
			@Is_Disabled		bit,
			@FKDropSQL			NVARCHAR(4000),
			@FKCreateSQL		NVARCHAR(4000);


		SELECT DISTINCT fk.name FKName, s.name ParentSchema, o.name ParentTable, c.name ParentColumn,s2.name RefSchema,o2.name RefTable,c2.name RefColumn, fk.is_disabled, c2.column_id RefTableColumnID
			INTO #t
			FROM sys.foreign_keys fk
			JOIN sys.objects o
			  ON o.object_id = fk.parent_object_id
			JOIN sys.schemas s
			  on s.schema_id = o.schema_id
			JOIN sys.objects o2
			  on o2.object_id = fk.referenced_object_id
			JOIN sys.schemas s2
			  on s2.schema_id = o2.schema_id
			JOIN sys.foreign_key_columns fkc
			  ON fkc.parent_object_id = fk.parent_object_id
			  AND fkc.referenced_object_id = fk.referenced_object_id
			JOIN [INFORMATION_SCHEMA].[CONSTRAINT_COLUMN_USAGE] ccu
			  ON  ccu.TABLE_NAME = o.name
			  AND ccu.CONSTRAINT_NAME = fk.name
			JOIN sys.columns c
			  ON  c.column_id = fkc.parent_column_id
			  AND c.object_id = o.object_id
			  AND c.column_id = fkc.parent_column_id
			  AND c.name	= ccu.COLUMN_NAME
			 JOIN sys.columns c2
			  ON  c2.column_id = fkc.referenced_column_id
			  AND c2.object_id = o2.object_id
			  AND c2.column_id = fkc.referenced_column_id
			WHERE s2.name = @SchemaName
			  AND o2.name = @TableName 
			ORDER BY 1,2,RefTableColumnID

	DECLARE cFK CURSOR FOR
		select FKName,ParentSchema,ParentTable,
				SUBSTRING( ( SELECT ( ',' + ParentColumn)
							FROM #t t2
							WHERE t1.FKName = t2.FKName
							  AND t1.ParentSchema = t2.ParentSchema
							  AND t1.ParentTable = t2.ParentTable
							ORDER BY FKName,ParentSchema,ParentTable,/*ParentColumn,*/RefTableColumnID
							FOR XML PATH ('')),2,1000 ) ParentColumn,
				RefSchema,RefTable,
				SUBSTRING( ( SELECT ( ',' + RefColumn)
							FROM #t t4
							WHERE t1.FKName = t4.FKName
							  AND t1.RefSchema = t4.RefSchema
							  AND t1.RefTable = t4.RefTable
							  AND t1.ParentSchema = t4.ParentSchema
							ORDER BY FKName,RefSchema,RefTable,/*RefColumn,*/RefTableColumnID
							FOR XML PATH ('')),2,1000 ) RefColumn,
				is_disabled
			FROM #t t1
			GROUP BY FKName,ParentSchema,ParentTable,RefSchema,RefTable,is_disabled

	OPEN cFK
	FETCH NEXT FROM CFK INTO @FKName,@ParentSchema,@ParentTable,@ParentColumn,@RefSchema,@RefTable,@RefColumn,@Is_Disabled	
	WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @FKDropSQL = N'ALTER TABLE ' + @ParentSchema + '.' + @ParentTable + N' DROP CONSTRAINT [' + @FKName + '];';

			IF @Is_Disabled = 1
				BEGIN
			SET @FKCreateSQL = N'ALTER TABLE ' + @ParentSchema + '.' + @ParentTable + N' WITH NOCHECK ADD CONSTRAINT [' + @FKName + '] FOREIGN KEY (' + @ParentColumn + ')
	REFERENCES [' + @RefSchema + '].[' + @RefTable + '] (' + @RefColumn + ')
ALTER TABLE ' + @ParentSchema + '.' + @ParentTable + N' NOCHECK CONSTRAINT [' + @FKName + '];';
				END
			ELSE
				BEGIN
			SET @FKCreateSQL = N'ALTER TABLE ' + @ParentSchema + '.' + @ParentTable + N' WITH CHECK ADD CONSTRAINT [' + @FKName + '] FOREIGN KEY (' + @ParentColumn + ')
	REFERENCES [' + @RefSchema + '].[' + @RefTable + '] (' + @RefColumn + ')
ALTER TABLE ' + @ParentSchema + '.' + @ParentTable + N' CHECK CONSTRAINT [' + @FKName + '];';
				END
			

			--PRINT @FKDropSQL;
			--PRINT @FKCreateSQL;
			INSERT #tFK
				SELECT @SchemaName,@TableName,@FKDropSQL,@FKCreateSQL;
			FETCH NEXT FROM CFK INTO @FKName,@ParentSchema,@ParentTable,@ParentColumn,@RefSchema,@RefTable,@RefColumn,@Is_Disabled;
		END
	CLOSE cFK;
	DEALLOCATE cFK;
RETURN 0;
GO
