set nocount on

declare @Schema     varchar(128)
declare @CrLf       char(2) = char(13) + char(10)

set @Schema = 'DBApp'


select  'if exists (' + @CrLf +
        '       select *' + @CrLf +
        '       from sys.foreign_keys fk' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = fk.schema_id' + @CrLf +
        '       where sch.Name = ''' + @Schema + '''' + @CrLf +
        '         and fk.Name = ''' + fk.name + '''' + @CrLf +
        '          ) begin' + @CrLf  +
        '   print ''dropping foreign key ' + fk.name + ' on table ' + @Schema + '.' + t.name + '''' + @CrLf  +
        '   alter table ' + @Schema + '.' + t.name + @CrLf +
        '       drop constraint ' + fk.name + @CrLf +
        'end' + @CrLf + @CrLf
from sys.foreign_keys fk
    inner join sys.tables t on t.object_id = fk.parent_object_id
    inner join sys.schemas sch on sch.schema_id = fk.schema_id
where sch.name = @Schema

