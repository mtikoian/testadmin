set nocount on
declare @TriggerList table (
    TriggerName varchar(128) primary key clustered,
    SchemaName  varchar(128)
)
declare @CrLf   char(2) = char(13) + char(10)


insert into @TriggerList
select  t.name, 
        sch.name 
from sys.triggers t
    inner join sys.objects o on o.object_id = t.parent_id
    inner join sys.schemas sch on sch.schema_id = o.schema_id
where t.type = 'tr'    
  and sch.name = 'DBApp'  
order by t.name                  

select  'if exists (' + @CrLf + 
        '       select * ' + @CrLf +
        '       from sys.triggers t' + @CrLf +
        '           inner join sys.objects o on o.object_id = t.parent_id' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = o.schema_id' + @CrLf +
        '       where t.Name = ''' + TriggerName + '''' + @CrLf +
        '         and sch.name = ''DBApp''' + @CrLf +
        '           ) begin' + @CrLf + 
        '   print ''Dropping trigger dbApp.' + TriggerName + '''' + @CrLf +
        '   drop trigger ' + SchemaName + '.' + TriggerName + @CrLf + 
        '   print ''''' + @CrLf +
        'end;' + @CrLf + 'go' + @CrLf + @CrLf
from @TriggerList              

--select  'drop trigger ' + SchemaName + '.' + TriggerName + ';' +  @CrLf + 'go' + @CrLf
--from @TriggerList