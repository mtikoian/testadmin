
select *
from information_schema.Routines    



select distinct Routine_Schema, Routine_Name
from information_schema.Routines   


select top 100 *
from sys.Procedures

select *
from sys.Schemas ss
	inner join sys.database_Principals dp on dp.Principal_Id = ss.Principal_Id
	
select *
from sys.Views	


select * 
from sys.Check_Constraints

select	tr.name as TriggerName,
		so.name as ParentName,
		*		
from sys.triggers tr
	inner join sys.objects so on so.object_id = tr.parent_id
where parent_class = 1


select *
from sys.key_constraints kc
	inner join sys.tables so on so.object_id = kc.parent_object_id
	
select *
from sys.Tables st
	inner join sys.Schemas ss on ss.Schema_Id = st.Schema_Id	 
	

select	fk.Name as FKName,
		ss.Name as TableSchema,
		st.Name as TableName,
		ss2.name as RefShcemaName,
		st2.name as RefTableName,
		fk.delete_referential_action,
		fk.update_referential_action
from sys.foreign_keys  fk    
	inner join sys.tables st on st.object_id = fk.parent_object_id   -- <-- gets me the parent table data
	inner join sys.Schemas ss on ss.Schema_Id = st.Schema_Id
	inner join sys.tables st2 on st2.object_id = fk.referenced_object_id
	inner join sys.Schemas ss2 on ss2.Schema_Id = st2.Schema_Id	
	
-- FK COlumns	
select	so1.Name as FKName,
		ss.name as FKSchema,
		st1.name as ParentTable,
		sc1.name as ParentColumn,
		fkc.constraint_column_id as ColumnOrder,
		st2.name as ReferencedTable,
		sc2.name as ReferencedColumn
from sys.foreign_key_columns fkc
	inner join sys.objects so1 on so1.object_id = fkc.constraint_object_id
	inner join sys.Schemas ss on ss.Schema_Id = so1.Schema_Id
	inner join sys.tables st1 on st1.object_id = fkc.parent_object_id
	inner join sys.columns sc1 on sc1.object_id = st1.object_id
							 and sc1.column_id = fkc.parent_column_id
	inner join sys.tables st2 on st2.object_id = fkc.referenced_object_id
	inner join sys.columns sc2 on sc2.object_id = st2.object_id
							 and sc2.column_id = fkc.referenced_column_id
order by constraint_object_id	
	       
-- Indexes
select	ix.name as IndexName, 
		ss.name as SchemaName,
		so.name as TableName,
		ix.type_desc as IndexType,
		ix.fill_factor as Fill_Factor,
		ix.is_padded as isPadded,
		ix.allow_row_locks as AllowRowLocks,
		ix.allow_page_locks as AllowPageLocks,
		ix.has_filter as hasFilter
from sys.indexes ix
	inner join sys.objects so on so.object_id = ix.object_id
	inner join sys.Schemas ss on ss.Schema_Id = so.Schema_Id
where so.is_ms_shipped = 0	
  and ix.type_desc <> 'HEAP'    
  
-- Index columns

select	ix.name as IndexName,
		ss.name as SchemaName,
		st.name as TableName,
		sc.name as ColumnName,
		ixc.key_ordinal as ColumnOrder,
		ixc.is_descending_key as isDescending,
		ixc.is_included_column as IsIncluded
from sys.index_columns ixc
	inner join sys.indexes ix on ix.object_id = ixc.object_id	-- <-- Table object
							 and ix.index_id = ixc.index_id		-- <-- Index object
	inner join sys.objects so on so.object_id = ix.object_id
	inner join sys.Schemas ss on ss.Schema_Id = so.Schema_Id
	inner join sys.tables st on st.object_id = ix.object_id
	inner join sys.columns sc on sc.object_id = ix.object_id	-- <-- Column join
							 and sc.column_id = ixc.column_id
where st.is_ms_shipped = 0
  and ix.type_desc <> 'HEAP'				 