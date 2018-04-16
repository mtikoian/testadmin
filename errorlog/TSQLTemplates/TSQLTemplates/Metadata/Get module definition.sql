
select  --sch.name as SchemaName,
        --obj.name as TableName,
        sqm.definition as SQLCode
from sys.sql_modules sqm
    inner join sys.objects obj on obj.object_id = sqm.object_id
    inner join sys.schemas sch on sch.schema_id = obj.schema_id
where sch.name = 'dbo'
  and obj.name = 'f_Start_of_Month'
    
    