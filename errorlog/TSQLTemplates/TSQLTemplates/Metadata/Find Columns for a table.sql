
select	*
from information_Schema.Columns c
	inner join information_schema.Tables t on 
		(t.Table_Schema = c.Table_Schema)
		and
		(t.Table_Name = c.Table_Name) 
where t.Table_Schema = 'aga'
  --and t.Table_Name like '%Security%'
  and t.Table_Name = 'Audit_Trail'
  --and Column_Name like '%Val%'	                