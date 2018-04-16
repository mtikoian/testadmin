
set nocount on

declare @Schema     varchar(128)
declare @CrLf       char(2) = char(13) + char(10)

set @Schema = 'cmdb'


select  'if exists (' + @CrLf +
        '       select *' + @CrLf +
        '       from sys.Synonyms syn' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = syn.Schema_Id' + @CrLf +
        '       where sch.Name = ''' + @Schema + '''' + @CrLf +
        '         and syn.Name = ''' + syn.name + '''' + @CrLf +
        '          ) begin' + @CrLf  +
        '    drop synonym ' + @Schema + '.' + syn.name + @CrLf +
        'end' + @CrLf + @CrLf  
--select *                    
from sys.synonyms syn
    inner join sys.schemas sch on sch.schema_id = syn.schema_id
where sch.name = @Schema
  --and t.type in ('FN', 'TF', 'IF', 'P', 'TR')

                  