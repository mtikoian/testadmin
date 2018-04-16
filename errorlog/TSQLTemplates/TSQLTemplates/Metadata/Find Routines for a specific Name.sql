declare @ProcName   varchar(128)

set @ProcName = 'sei_FindBadImportOrdersBLOCK'
set @ProcName = 'validate'

select  *        
from Information_Schema.Routines
where SPECIFIC_NAME like '%' + @ProcName + '%'
  and SPECIFIC_NAME like 'PMx%'
order by Specific_Name
