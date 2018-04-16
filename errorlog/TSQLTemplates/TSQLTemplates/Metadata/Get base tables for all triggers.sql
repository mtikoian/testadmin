
select  --tr.name,
        o.name        
from sys.triggers tr
    inner join sys.objects o on o.object_id = tr.parent_id
    inner join sys.schemas s on s.schema_id = o.schema_id
where s.name = 'aga'

print cast(@@rowcount as varchar(10)) + ' rows whacked';