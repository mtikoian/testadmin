
-- sys.queries
-- Paul Nielsen 
-- Jan 2007

--- www.sqlserverbible.com

--------------------------------------------------------------------
-- databases and files
select * 
  from sys.databases

-- database files (for current database)
select *
  from sys.database_files

--------------------------------------------------------------------
-- Tables

Select s.name as [schema],  t.*
 from sys.tables t
    join sys.schemas as s
      on s.schema_id = t.schema_id
  order by [schema], t.name

select * from sys.objects 
  where type_desc = 'USER_TABLE'
    and objects.name <> 'sysdiagrams'
  order by objects.name

-- Schemas
select * from sys.schemas

-- columns per table
select s.name + '.' + t.name as [table], c.name as [column], ty.name as UserDataType, st.name as SystemDataType, 
  c.max_length, c.precision, c.scale, c.is_nullable, c.is_computed, c.is_identity
  from sys.tables as t
    join sys.columns as c
      on t.object_id = c.object_id
    join sys.schemas as s
      on s.schema_id = t.schema_id
    join sys.types as ty
      on ty.user_type_id = c.user_type_id
    join sys.types st
      on ty.system_type_id = st.user_type_id
  where t.name <> 'sysdiagrams'
  order by [table], c.column_id

--------------------------------------------------------------------
-- Primary Key columns per Table

select s.name + '.' + t.name as [table], i.name as [index], i.type_desc as [type], ic.index_column_id as [Col Order], c.name as [column]
  from sys.tables t
    join sys.schemas s
      on s.schema_id = t.schema_id
    join sys.indexes i
      on t.object_id = i.object_id
    join sys.index_columns ic
  	  on i.object_id = ic.object_id
      and i.index_id = ic.index_id
    join sys.columns c
      on ic.object_id = c.object_id
      and ic.column_id = c.column_id
  where is_primary_key = 1
  order by [table], [index], ic.index_column_id

--------------------------------------------------------------------
-- Foreign Keys w/columns

select fko.name as [FK Name], fk.constraint_column_id as [Col Order],  
fks.name + '.' + fkt.name as [FK table], pc.name as [FK column], rcs.name + '.' + rct.name as [PK table], rc.name as [PK column]
  from sys.foreign_key_columns fk
    -- FK columns
    join sys.columns pc  
      on fk.parent_object_id = pc.object_id
        and fk.parent_column_id = pc.column_id
    join sys.objects fkt
      on pc.object_id = fkt.object_id
    join sys.schemas as fks
      on fks.schema_id = fkt.schema_id
   -- referenced PK columns
    join sys.columns rc  
      on fk.referenced_object_id = rc.object_id
        and fk.referenced_column_id = rc.column_id
    join sys.objects rct
      on rc.object_id = rct.object_id
    join sys.schemas as rcs
      on rcs.schema_id = rct.schema_id
    -- foreign key constraint name
    join sys.objects fko  
      on fk.constraint_object_id = fko.object_id
        --and fk.referenced_column_id = rc.column_id
  order by fko.name, fk.constraint_column_id

-- Foreign Keys columns w/o indexes

select  * 
  from sys.foreign_key_columns fk
    left join sys.index_columns ic
      on fk.parent_object_id = ic.object_id
        and parent_column_id = ic.index_id
  where ic.object_id IS NULL

select * from sys.foreign_key_columns fk join sys.objects o on fk.parent_object_id = o.object_id
select * from sys.index_columns

select fko.name as [FK Name], fk.constraint_column_id as [Col Order],  
fks.name + '.' + fkt.name as [FK table], pc.name as [FK column]--, rcs.name + '.' + rct.name as [PK table], rc.name as [PK column]
  from sys.foreign_key_columns fk
    -- FK columns
    join sys.columns pc  
      on fk.parent_object_id = pc.object_id
        and fk.parent_column_id = pc.column_id
    join sys.objects fkt
      on pc.object_id = fkt.object_id
    join sys.schemas as fks
      on fks.schema_id = fkt.schema_id
    -- foreign key constraint name
    join sys.objects fko  
      on fk.constraint_object_id = fko.object_id
        --and fk.referenced_column_id = rc.column_id
  left join sys.index_columns ic
      on fk.parent_object_id = ic.object_id
        and parent_column_id = ic.index_id
  where ic.object_id IS NULL
order by fko.name, fk.constraint_column_id

--------------------------------------------------------------------
-- Indexes by table

select s.name + '.' + t.name as [table], i.name as [index], i.type_desc as [type], 
   is_unique, is_primary_key, is_disabled, 
  fill_factor, is_padded, ignore_dup_key, is_unique_constraint
  from sys.tables t
    join sys.indexes i
      on t.object_id = i.object_id
    join sys.schemas s
      on s.schema_id = t.schema_id
  where t.name <> 'sysdiagrams'
  order by [table], [index]

-- Indexes w/columns 
select s.name + '.' + t.name as [table], i.name as [index], i.type_desc as [type],
      ic.index_column_id as [Col Order], c.name as [column], is_primary_key, ic.is_descending_key, is_included_column
  from sys.tables t
    join sys.schemas s
      on s.schema_id = t.schema_id
    join sys.indexes i
      on t.object_id = i.object_id
    join sys.index_columns ic
  	  on i.object_id = ic.object_id
      and i.index_id = ic.index_id
    join sys.columns c
      on ic.object_id = c.object_id
      and ic.column_id = c.column_id
  order by [table], [index], ic.index_column_id

