

;with V (Nm) as 
(
select t.name 
from sys.Views t
   inner join sys.objects o on o.object_id = t.object_id
   inner join sys.schemas sch on sch.schema_id = o.schema_id
where sch.name = 'DBApp'   
),
Trg (Nm) as 
(
select o.name 
from sys.triggers t
   inner join sys.objects o on o.object_id = t.parent_id
   inner join sys.schemas sch on sch.schema_id = o.schema_id
where sch.name = 'DBApp'
)
select  v.Nm,
        o.Nm
from V v
    full outer join Trg o on o.Nm = v.Nm