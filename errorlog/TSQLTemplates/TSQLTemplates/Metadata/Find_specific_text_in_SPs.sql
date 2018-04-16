

select sc.id, so.Name  
from syscomments sc
    inner join sysobjects so on so.id = sc.id
where sc.text like '%cc_companyGroupType%'   
order by so.Name               