
select	*
from information_Schema.Columns c
	inner join information_schema.Tables t on 
		(t.Table_Schema = c.Table_Schema)
		and
		(t.Table_Name = c.Table_Name) 
where t.Table_Schema = 'dbo'
  --and t.Table_Name like '%Security%'
  and t.Table_Name = 'brand'
  --and Column_Name like '%Val%'	                


  select * from DealerDistributorRelationships
  where ECC_HVPId is not null 


  SELECT * FROM cc_company_history


