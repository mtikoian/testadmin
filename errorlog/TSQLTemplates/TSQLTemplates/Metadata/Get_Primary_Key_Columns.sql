



select  c.Table_Schema,
        c.Table_Name,
        c.Column_Name,
        c.Data_Type,
        kcu.Ordinal_Position
from INFORMATION_SCHEMA.COLUMNS c  
    inner join Information_Schema.Table_Constraints tc on tc.Table_Schema = c.Table_Schema
                                                      and tc.Table_Name = c.Table_Name 
    inner join Information_Schema.Key_Column_Usage kcu on kcu.Table_Schema = tc.Table_Schema
                                                      and kcu.Table_Name = tc.Table_Name
                                                      and kcu.Column_Name = c.Column_Name
                                                      and kcu.Constraint_Name = tc.Constraint_Name
where tc.Constraint_Type = 'Primary Key'   
  and Data_Type = 'uniqueidentifier' 
order by tc.Table_Schema,
        tc.Table_Name,
        kcu.Ordinal_Position                             