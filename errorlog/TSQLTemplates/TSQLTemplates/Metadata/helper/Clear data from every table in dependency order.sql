
/*
This script clears all data from a database without requiring you to disable 
foreign keys Basically, it orders all the tables according to FKs so that it 
deletes from them in the correct order.
*/

set nocount on;
declare    @schemaName SYSNAME;
declare    @tableName  SYSNAME;
declare    @level      int;
declare t_cur cursor for
with fk_tables as (
    select  s1.name as from_schema,
            o1.Name as from_table,
            s2.name as to_schema,
            o2.Name as to_table    
    from    sys.foreign_keys fk    
        inner join sys.objects o1 on fk.parent_object_id = o1.OBJECT_ID    
        inner join sys.schemas s1 on o1.schema_id = s1.schema_id    
        inner join sys.objects o2 on fk.referenced_object_id = o2.OBJECT_ID    
        inner join sys.schemas s2 on o2.schema_id = s2.schema_id    
    /*For the purposes of finding dependency hierarchy we're not worried about self-referencing tables*/
    where not ( s1.name = s2.name                 
                and
                o1.name = o2.name
              )
)
,ordered_tables as
(        
    select s.name as schemaName,
           t.name as tableName,
           0 as level    
    from (
        select  *                
        from sys.tables                 
        where name <> 'sysdiagrams'
         ) t    
        inner join sys.schemas s on t.schema_id = s.schema_id    
        left outer join fk_tables fk on s.name = fk.from_schema    
                                        and t.name = fk.from_table    
    where    fk.from_schema is null
        
    union all
        
    select  fk.from_schema,
            fk.from_table,
            ot.LEVEL + 1    
    from fk_tables fk    
        inner join ordered_tables ot on fk.to_schema = ot.schemaName    
                                        and fk.to_table = ot.tableName
)
select  distinct ot.schemaName,
        ot.tableName,
        ot.LEVEL
from ordered_tables ot
    inner join (
            select  schemaName,
                    tableName,
                    max(level) as maxLevel        
            from ordered_tables        
            group    by schemaName,tableName
                ) mx on ot.schemaName = mx.schemaName
                    and ot.tableName = mx.tableName
                    and mx.maxLevel = ot.LEVEL
order by level desc; 

open t_cur;

fetch next from t_cur into @schemaName,@tableName,@level;
while @@fetch_status = 0
begin
       declare @ParmDefinition nvarchar(500)   ;
       declare @vSQL           nvarchar(max)   ;
       declare @vRowCount      int             ;
       
       set @vSQL            = 'DELETE FROM [' + @schemaName + '].[' + @tableName + '];';
       set @vSQL            = @vSQL + 'SET @vRowCount_OUT = @@ROWCOUNT;'
       set @ParmDefinition  = '@vRowCount_OUT INT OUTPUT';
       
       exec sp_executesql @vSQL,@ParmDefinition,@vRowCount_OUT=@vRowCount output;
       
       print   convert(nvarchar(100),@vRowCount) + ' rows deleted from [' +  @schemaName + '].[' + @tableName + ']';
       
       fetch next from t_cur into @schemaName,@tableName,@level;
end

close t_cur;
deallocate t_cur; 
                