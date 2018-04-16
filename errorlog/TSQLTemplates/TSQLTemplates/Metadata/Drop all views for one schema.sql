set nocount on
declare @TriggerList table (
    TriggerName varchar(128) primary key clustered,
    SchemaName  varchar(128)
)
declare @CrLf   char(2) = char(13) + char(10)


insert into @TriggerList
select  t.name, 
        sch.name
--select *         
from sys.views t
    inner join sys.objects o on o.object_id = t.object_id
    inner join sys.schemas sch on sch.schema_id = o.schema_id
where t.type = 'V'    
  and sch.name = 'DBApp'  
order by t.name                

select  'if exists (' + @CrLf + 
        '       select * ' + @CrLf +
        '       from sys.Views t' + @CrLf +
        '           inner join sys.objects o on o.object_id = t.object_id' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = o.schema_id' + @CrLf +
        '       where t.Name = ''' + TriggerName + '''' + @CrLf +
        '         and sch.name = ''DBApp''' + @CrLf +
        '           ) begin' + @CrLf + 
        '   print ''Dropping view dbApp.' + TriggerName + '''' + @CrLf +
        '   drop view ' + SchemaName + '.' + TriggerName + @CrLf + 
        '   print ''''' + @CrLf +
        'end;' + @CrLf + 'go' + @CrLf + @CrLf
from @TriggerList