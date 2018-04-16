--this file contains a set of utility objects that I use from time to time to drop various objects.
--use however you desire, but please 
--
--
begin try
drop procedure utility.relationships$remove
end try begin catch end catch
begin try
drop procedure utility.computedColumns$remove
end try begin catch end catch
begin try
drop procedure utility.checkConstraints$remove
end try begin catch end catch
begin try
drop procedure utility.defaultConstraints$remove
end try begin catch end catch
begin try
drop procedure utility.indexes$remove 
end try begin catch end catch
begin try
drop procedure utility.primaryKeyConstraints$remove
end try begin catch end catch
begin try
drop procedure utility.uniqueConstraints$remove
end try begin catch end catch
begin try
drop procedure utility.codedObjects$remove
end try begin catch end catch
begin try
drop procedure utility.columns$changeCollation
end try begin catch end catch
begin try
drop procedure utility.synonyms$remove
end try begin catch end catch

begin try
drop procedure utility.indexes$disableAllExceptPK
end try begin catch end catch

go

if schema_id('utility') is null
	exec ('create schema utility')
go


create  procedure utility.relationships$remove
(
	 @table_schema  sysname = '%', 
	 @parent_table_name sysname = '%', --it is the parrent when it is being referred to
	 @child_table_name sysname = '%', --it is the child table when it is the table referring 
		  --to another
	 @constraint_name sysname = '%'  --can be used to drop only a single constraint
) as 
-- ----------------------------------------------------------------
-- Drop all of the foreign key contraints on and or to a table
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
 begin
	 set nocount on
	 declare @statements cursor 
	 set @statements = cursor static for 
	 select  'alter table ' + quotename(ctu.table_schema) + '.' + quotename(ctu.table_name) +
			 ' drop constraint ' + quotename(cc.constraint_name)
	 from  information_schema.referential_constraints as cc
			  join information_schema.constraint_table_usage as ctu
			   on cc.constraint_catalog = ctu.constraint_catalog
				  and cc.constraint_schema = ctu.constraint_schema
				  and cc.constraint_name = ctu.constraint_name
	 where   ctu.table_schema like @table_schema  
	   and ctu.table_name like @child_table_name
	   and cc.constraint_name like @constraint_name
	   and   exists (  select *
					   from information_schema.constraint_table_usage ctu2
					   where cc.unique_constraint_catalog = ctu2.constraint_catalog
						  and  cc.unique_constraint_schema = ctu2.constraint_schema
						  and  cc.unique_constraint_name = ctu2.constraint_name
                          and ctu2.table_schema like @table_schema
						  and ctu2.table_name like @parent_table_name)
		  
	 open @statements
	 declare @statement nvarchar(1000)
	 While  (1=1)
	  begin
                fetch from @statements into @statement
                if @@fetch_status <> 0
                 break

                begin try
                    exec (@statement)
                end try
                begin catch
                    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                            'Statement executed: ' +  @statement
                end catch

	     end
 end
go
create procedure utility.checkConstraints$remove
(
	@table_schema		sysname = '%', 
	@table_name		sysname = '%',
	@constraint_name	sysname = '%' 
) as 
-- ----------------------------------------------------------------
-- Drop all of the check contraints on a table
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
 begin
	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
	select 	'alter table ' + quotename(ctu.table_schema) + '.' + quotename(ctu.table_name) +
		' drop constraint ' + quotename(cc.constraint_name)

	from 	information_schema.check_constraints as cc
		  join information_schema.constraint_table_usage as ctu
			on cc.constraint_catalog = ctu.constraint_catalog
			   and cc.constraint_schema = ctu.constraint_schema
			   and cc.constraint_name = ctu.constraint_name

	where   ctu.table_schema like @table_schema 	
	  and	ctu.table_name like @table_name
	  and	cc.constraint_name like @constraint_name

	open @statements

	declare @statement varchar(1000)
	
	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch
	 end


 end

go

create procedure utility.defaultConstraints$remove
(
	@table_schema		sysname = '%',
	@table_name		sysname = '%',
	@constraint_name	sysname = '%',
	@column_name 		sysname = '%'
) as 
-- ----------------------------------------------------------------
-- Drop all of the check contraints on a table
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
 begin

	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
	select 	'alter table ' + quoteName(schema_name(sob.schema_id)) + '.' + quoteName(object_name(col.object_id)) +
		' drop constraint ' + quoteName(dc.name )
	from sys.default_constraints as dc
		  join sys.columns as col
				on dc.parent_object_id = col.object_id
					and dc.parent_column_id = col.column_id
		  join sys.objects as sob
				on sob.object_id = col.object_id
	where object_name(col.object_id) like @table_name
	  and schema_name(sob.schema_id) like @table_schema
	  and dc.name like @constraint_name
      and col.name like @column_name
	
	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch

	 end


 end

go
create procedure utility.indexes$remove 
(
    @table_name sysname, --will accept a wildcard
    @index_name sysname ,--will accept a wildcard
    @schema_name sysname = '%',
    @index_type sysname = '%'
) as
-- ----------------------------------------------------------------
-- Drops indexes from a table
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
begin
	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
	    select 'drop index ' + quotename(indexes.name) + ' on ' + quotename(schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int))) + 
                        '.' + quotename(object_name(object_id))
	    from  sys.indexes as indexes
	    where object_name(indexes.object_id) like @table_name
	      and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) like @schema_name
	      and indexes.name like @index_name
              and objectpropertyex(object_id,'IsSystemTable') = 0
              and is_primary_key = 0
              and is_unique_constraint = 0
              and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) <> 'sys'

    	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch
	 end


 end
go

create procedure utility.uniqueConstraints$remove
(
    @table_name sysname, --will accept a wildcard 
    @index_name sysname, --will accept a wildcard
    @table_schema sysname = '%'

) as
-- ----------------------------------------------------------------
-- Drops unique constraints from a table
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
 begin

	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
	    select 'alter table  ' + schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) + '.' + object_name(object_id) + 
                        ' drop constraint ' + indexes.name 
	    from  sys.indexes as indexes
	    where object_name(indexes.object_id) like @table_name
	      and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) like @table_schema
	      and indexes.name like @index_name
              and is_unique_constraint = 1
	
	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch

	 end


 end
go

create procedure utility.primaryKeyConstraints$remove
(
    @table_name sysname, --will accept a wildcard 
    @index_name sysname, --will accept a wildcard
    @table_schema sysname = '%'

) as
-- ----------------------------------------------------------------
-- Drops unique constraints from a table
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
 begin

	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
	    select 'alter table  ' + schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) + '.' + object_name(object_id) + 
                        ' drop constraint ' + indexes.name 
	    from  sys.indexes as indexes
	    where object_name(indexes.object_id) like @table_name
	      and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) like @table_schema
	      and indexes.name like @index_name 
              and is_primary_key = 1
	
	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch

	 end


 end
go

create procedure utility.synonyms$remove
(
    @synonym_name sysname = '%'
) as
-- ----------------------------------------------------------------
-- Drops synonyms from a database
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
 begin

	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
            select 'drop synonym ' + name
            from sys.synonyms
            where name like @synonym_name
	
	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch

	 end


 end
go

create procedure utility.codedObjects$remove
(
    @object_name sysname, 
    @object_schema sysname = '%',
    @object_type_desc sysname = '%',
    @dropUtilityProcs bit = 0

) as
-- ----------------------------------------------------------------
-- Drops program code, from the database.
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------

 begin

	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
	    select 'drop '  
                           +  case when type_desc = 'VIEW' then 'view ' 
                                  when type_desc in ('SQL_STORED_PROCEDURE','CLR_STORED_PROCEDURE') then 'procedure '
                                  when type_desc in ('CLR_TRIGGER','SQL_TRIGGER') then 'trigger '
                                  else 'function ' end + schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int))+ '.'+ name
	    from  sys.objects
            where type_desc in ('VIEW',
                                'SQL_STORED_PROCEDURE',
                                'CLR_STORED_PROCEDURE',
                                'CLR_TRIGGER',
                                'SQL_TRIGGER',
                                'SQL_INLINE_TABLE_VALUED_FUNCTION',
                                'SQL_TABLE_VALUED_FUNCTION',
                                'SQL_SCALAR_FUNCTION',
                                'CLR_SCALAR_FUNCTION',
                                'CLR_TABLE_VALUED_FUNCTION',
                                'AGGREGATE_FUNCTION')
	      and name like @object_name
          and type_desc like @object_type_desc
	      and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) like @object_schema
                  and (schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) <> 'utility' or @dropUtilityProcs = 1)
          and object_id <> @@procid
	
	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch

	 end

 end
go

create procedure utility.columns$changeCollation
(
  @fromCollation sysname,
  @toCollation sysname
) as

-- ----------------------------------------------------------------
-- alters all columns in the database that have one collation and sets them to another collation.
--
-- note that you will need to drop all defaults, check constraints, indexes, etc.
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
 begin

    set nocount on
	declare @statements cursor 
	set @statements = cursor for 
                    SELECT 'ALTER TABLE ' + quotename(TABLE_NAME) +
                           '   ALTER COLUMN ' + quotename(COLUMN_NAME) + ' ' + quotename(DATA_TYPE) +
                           CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 then '(max)'
                                WHEN DATA_TYPE in ('text','ntext') then ''
                                WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL 
                                 THEN '('+(CONVERT(VARCHAR,CHARACTER_MAXIMUM_LENGTH)+')' )
                                ELSE isnull(CONVERT(VARCHAR,CHARACTER_MAXIMUM_LENGTH),' ') END 
                           +' COLLATE ' + @toCollation+ ' ' + CASE IS_NULLABLE
                                                               WHEN 'YES' THEN 'NULL'
                                                               WHEN 'No' THEN 'NOT NULL'
                    END
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE DATA_TYPE IN ('varchar' ,'char','nvarchar','nchar','text','ntext')
                      and COLLATION_NAME like @fromCollation
                    
            
	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
               begin catch
                    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                           'Statement executed: ' +  @statement
               end catch
	 end

        
 end
go

create procedure utility.computedColumns$remove
(
    @table_name sysname, 
    @column_name sysname,
    @table_schema sysname = '%'
) as
-- ----------------------------------------------------------------
-- Drops program code, from the database.
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------

 begin
	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
            select 'alter table ' + object_name(object_id) + ' drop column ' + name
            from   sys.columns 
            where  is_computed = 1
              and  object_name(object_id) like @table_name
	      and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) like @table_schema	
              and  name like @column_name

	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch

	 end

 end
go

create procedure utility.indexes$disableAllExceptPK
(
    @table_name sysname, --will accept a wildcard
    @index_name sysname ,--will accept a wildcard
    @schema_name sysname = '%',
    @index_type sysname = '%'
) as
-- ----------------------------------------------------------------
-- Drops indexes from a table
--
-- 2006 Louis Davidson - louis.davidson@compass.net - Compass Technology
-- ----------------------------------------------------------------
begin
	set nocount on
	declare @statements cursor 
	set @statements = cursor for 
	    select 'alter index ' + quotename(indexes.name) + ' on ' + quotename(schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int))) + 
                        '.' + quotename(object_name(object_id)) + ' disable '
	    from  sys.indexes as indexes
	    where object_name(indexes.object_id) like @table_name
	      and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) like @schema_name
	      and indexes.name like @index_name
              and objectpropertyex(object_id,'IsSystemTable') = 0
              and is_primary_key = 0
              and is_unique_constraint = 0
              and schema_name(cast(objectpropertyex(object_id, 'SchemaId') as int)) <> 'sys'

    	open @statements

	declare @statement varchar(1000)

	While 1=1
	 begin
	       fetch from @statements into @statement
               if @@fetch_status <> 0
                    break

               begin try
                exec (@statement)
               end try
	       begin catch
		    select 'Error occurred: ' + cast(error_number() as varchar(10))+ ':' + error_message() + char(13) + char(10) + 
                                        'Statement executed: ' +  @statement
	       end catch
	 end


 end
go
