set nocount on

declare @Schema     varchar(128)
declare @CrLf       char(2)
set  @CrLf = char(13) + char(10)

set @Schema = 'dbo'

declare @ObjectList  table (
    SchemaNm    varchar(128),
    ObjectNm     varchar(128)
);

insert into @ObjectList
values  ('cmdb', 'cc_company'),
        ('dbo', 'EmployeeIDList');

begin try

    -- If the user has supplied table names, use them
    if exists (
        select *
        from @ObjectList
              )
    begin

select  'if exists (' + @CrLf +
        '       select *' + @CrLf +
        '       from sys.table_types sm' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = sm.schema_id' + @CrLf +
        '       where sch.Name = ''' + @Schema + '''' + @CrLf +
        '         and sm.Name = ''' + sm.name + '''' + @CrLf +
        '          ) begin' + @CrLf  +
        '    print ''dropping module ' + sm.name + '''' +@CrLf  +
        '    drop type ' + @Schema + '.' + sm.name + @CrLf +
        'end' + @CrLf + @CrLf  
--select *                    
from sys.table_types  sm
    inner join sys.schemas sch on sch.schema_id = sm.schema_id
where sch.name = @Schema
  --and t.type in ('FN', 'TF', 'IF', 'P', 'TR')
  end else 
  begin
        select  'if exists (' + @CrLf +
        '       select *' + @CrLf +
        '       from sys.table_types sm' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = sm.schema_id' + @CrLf +
        '       where sch.Name = ''' + @Schema + '''' + @CrLf +
        '         and sm.Name = ''' + sm.name + '''' + @CrLf +
        '          ) begin' + @CrLf  +
        '    print ''dropping module ' + sm.name + '''' +@CrLf  +
        '    drop type ' + @Schema + '.' + sm.name + @CrLf +
        'end' + @CrLf + @CrLf  
--select *                    
from sys.table_types  sm
    inner join sys.schemas sch on sch.schema_id = sm.schema_id
where sch.name = @Schema
  --and t.type in ('FN', 'TF', 'IF', 'P', 'TR')
     end

end try
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch