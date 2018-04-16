set nocount on

declare @Schema     varchar(128)
declare @CrLf       char(2) = char(13) + char(10)

set @Schema = 'dbo'


select  'if exists (' + @CrLf +
        '       select *' + @CrLf +
        '       from sys.sql_modules sm' + @CrLf +
        '           inner join sys.objects t on t.object_id = sm.object_id' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = t.schema_id' + @CrLf +
        '       where sch.Name = ''' + @Schema + '''' + @CrLf +
        '         and t.Name = ''' + t.name + '''' + @CrLf +
        '          ) begin' + @CrLf  +
        '    print ''dropping module ' + t.name + '''' +@CrLf  +
        '    drop ' +  
                case t.type 
                    when 'FN' then 'function '
                    when 'TF' then 'function '
                    when 'IF' then 'function '
                    when 'P' then 'procedure '
                    when 'TR' then 'trigger '
                end + @Schema + '.' +t.name + @CrLf +
        'end' + @CrLf + @CrLf              
from sys.sql_modules sm
    inner join sys.objects t on t.object_id = sm.object_id
    inner join sys.schemas sch on sch.schema_id = t.schema_id
where sch.name = @Schema
  and t.type in ('FN', 'TF', 'IF', 'P', 'TR')

        