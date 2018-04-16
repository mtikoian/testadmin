
DECLARE @schema_to_empty SYSNAME = N'dbo',   
		@sql			NVARCHAR(MAX) = N'';
		
-- drop all references to tables in the blat schema,
-- even FKs on tables in other schemas.

SELECT	@sql += N'	ALTER TABLE '   
		+ QUOTENAME(OBJECT_SCHEMA_NAME(k.parent_object_id)) + 
		'.' + 
		QUOTENAME(OBJECT_NAME(k.parent_object_id)) + 
		' DROP CONSTRAINT ' + QUOTENAME(k.[name]) + ';'
		+ char(13) + char(10)
FROM sys.foreign_keys AS k
	INNER JOIN sys.tables AS t ON k.referenced_object_id = t.[object_id]
WHERE t.[schema_id] = SCHEMA_ID(@schema_to_empty);
-- then drop all the tables.

SELECT @sql += N'	DROP TABLE '    + 
		QUOTENAME(@schema_to_empty) + 
		'.'   + 
		QUOTENAME([name]) + 
		';' + char(13) + char(10)
FROM sys.tables   
WHERE [schema_id] = SCHEMA_ID(@schema_to_empty);

-- if the output is < 8K, you can inspect it using PRINT:
--PRINT @sql;

-- in case it's too big for PRINT (> 8K), but still less than 64K
-- you can run this in grid mode, click on the output, and copy the
-- script from the new window that is created:
 SELECT CONVERT(XML, @sql);
-- or you can just trust me and run it, MWAHAHAHAHA!:
-- EXEC sp_executeSQL @sql;
                