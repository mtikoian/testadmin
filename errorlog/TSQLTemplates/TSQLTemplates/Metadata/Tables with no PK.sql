
            
with TablesNoPk (ObjectId) as
(
    select  Object_Id 
    from sys.Tables
    
    except
    
    select  Parent_Object_Id
    from sys.key_constraints
    where Type = 'PK'
)
select  Name,
        *
from sys.Tables t
    inner join TablesNoPk tn on tn.ObjectId = t.Object_Id  
                       