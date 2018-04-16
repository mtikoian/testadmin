set nocount on

declare @Schema     varchar(128)
declare @CrLf       char(2) = char(13) + char(10)

set @Schema = 'dbo'


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

        