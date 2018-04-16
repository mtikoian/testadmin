
select  *        
from Information_Schema.Routines
--where Routine_Schema = 'ecr'
--where SPECIFIC_NAME like '%BCalcUpdateBondTableYTMandDuration%'
where SPECIFIC_NAME like '%sei_FindBadImportOrdersBLOCK%'
order by Specific_Name

 -- pMxBCalcUpdateBondTableYTMandDuration