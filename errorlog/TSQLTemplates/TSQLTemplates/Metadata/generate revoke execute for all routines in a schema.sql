declare @SchemaName varchar(128)
declare @Principal  varchar(128)

set @SchemaName = 'aga'
set @Principal = 'ActGrpUser'
    

select  'revoke execute on object::' +  @SchemaName + '.' + Specific_Name + ' from ' + @Principal + ';
go'  
from information_schema.Routines
where Specific_Schema = 'aga'               