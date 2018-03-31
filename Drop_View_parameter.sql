set nocount on
declare @Schema     varchar(128)
declare @ViewList table (
    ViewName varchar(128) primary key clustered,
    SchemaName  varchar(128)
)
declare @CrLf   char(2) = char(13) + char(10)
declare @ObjectList  table (
    SchemaNm    varchar(128),
    ObjectNm     varchar(128)
);

insert into @ObjectList
values  ('cmdb', 'vw_CUser1'),
        ('dbo', 'vw_CUser');

set @Schema = 'dbo'

begin try

    if exists (
        select *
        from @ObjectList
              ) BEGIN
select  'if exists (' + @CrLf + 
        '       select 1 ' + @CrLf +
        '       from sys.Views t' + @CrLf +
        '           inner join sys.objects o on o.object_id = t.object_id' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = o.schema_id' + @CrLf +
        '       where t.Name = '''+v.ObjectNm + '''' + @CrLf +
        '         and sch.name ='''+v.SchemaNm+ '''' + @CrLf +
        '           ) begin' + @CrLf + 
        '   print ''Dropping view ' + SchemaNm +'.'+ v.ObjectNm + '''' + @CrLf +
        '   drop view ' + SchemaNm + '.' + ObjectNm + @CrLf + 
        '   print ''''' + @CrLf +
        'end;' + @CrLf + 'go' + @CrLf + @CrLf
from @ObjectList v
end else 
begin
insert into @ViewList
select  t.name, 
        sch.name         
from sys.views t
    inner join sys.objects o on o.object_id = t.object_id
    inner join sys.schemas sch on sch.schema_id = o.schema_id
where t.type = 'V'    
  and sch.name = @Schema 
order by t.name   
    if exists (     -- or else if the user has supplied schema names
        select *
        from @ViewList
              ) 
    begin              

select  'if exists (' + @CrLf + 
        '       select 1 ' + @CrLf +
        '       from sys.Views t' + @CrLf +
        '           inner join sys.objects o on o.object_id = t.object_id' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = o.schema_id' + @CrLf +
        '       where t.Name = '''+v.ViewName + '''' + @CrLf +
        '         and sch.name ='''+v.SchemaName+ '''' + @CrLf +
        '           ) begin' + @CrLf + 
        '   print ''Dropping view ' + SchemaName +'.'+ v.ViewName + '''' + @CrLf +
        '   drop view ' + SchemaName + '.' + ViewName + @CrLf + 
        '   print ''''' + @CrLf +
        'end;' + @CrLf + 'go' + @CrLf + @CrLf
from @ViewList v
end
end
end try
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch