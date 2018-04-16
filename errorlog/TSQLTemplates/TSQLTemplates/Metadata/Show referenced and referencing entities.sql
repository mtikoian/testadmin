
select *
from sys.dm_sql_referenced_entities('MxSec.SecType', 'object')    


select *
from sys.dm_sql_referencing_entities('MxSec.SecType', 'object')   

              