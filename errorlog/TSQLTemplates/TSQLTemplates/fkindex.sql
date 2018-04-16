/* 
FK Index script
Paul Nielsen
www.sqlserverbible.com

----------------------------------
version 1.00 - Feb 8, 2007

This script creates a (composite) nonclustered index 
  for every Foreign Key without a complete matching (composite) index 

*/

CREATE 
-- alter 
Function FKCol (@Object_ID INT)
RETURNS VARCHAR(8000)
as 
Begin 
	DECLARE @SQL VARCHAR(max)
	SET @SQL = ''
	select @SQL = @SQL + pc.name + ',' 
	  from sys.foreign_key_columns fk
		join sys.columns pc  
		  on fk.parent_object_id = pc.object_id
			and fk.parent_column_id = pc.column_id
	  where fk.constraint_object_id = @Object_ID; 
      set @SQL = left(@SQL, len(@SQL)-1);
Return @SQL
End 

-- Dynamic SQL 
DECLARE @SQL VARCHAR(max); SET @SQL = ''
SELECT @SQL = @SQL + ' CREATE INDEX Ix' + FK_Name + ' ON ' + FK_Table + '(' + FK_Columns + ');'
  FROM (
    -- FK w/o complete (composite) index
	select distinct fko.name as FK_Name, fks.name + '.' + fkt.name as FK_table, dbo.FKCol(fk.constraint_object_id) as FK_Columns
	  from sys.foreign_key_columns fk
		join sys.objects fkt
		  on fk.parent_object_id = fkt.object_id
		join sys.schemas as fks
		  on fks.schema_id = fkt.schema_id
		join sys.objects fko  
		  on fk.constraint_object_id = fko.object_id
		left join sys.index_columns ic
		  on ic.object_id = fk.parent_object_id  -- same table
			and ic.column_id = fk.parent_column_id  -- same column
			and ic.index_column_id = fk.constraint_column_id -- column position in the index and FK 
	  where ic.object_id IS NULL) sq
SELECT @SQL
EXEC (@SQL)






