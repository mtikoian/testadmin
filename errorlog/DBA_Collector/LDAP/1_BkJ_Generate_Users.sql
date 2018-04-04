select distinct ','+''''+u.userid+''''   from usersroles  ur 
join users u
on u.id = ur.userid
where ur.modifieddate > '2016-01-16 15:54:22.187'
and ur.modifiedby  <> 'Initial Load'
and  (
			CASE 
				WHEN CHARINDEX('0', CompanyID, 1) = 1
					THEN 'ICP'
				ELSE 'CBP'
				END
			) = 'cbp'
union
select distinct ','+''''+u.userid+''''  from usersfeatures uf
join users u
on u.id = uf.userid
where  uf.modifieddate > '2016-01-16 15:54:22.187'
and uf.modifiedby <>'CBP Load'
and  (
			CASE 
				WHEN CHARINDEX('0', CompanyID, 1) = 1
					THEN 'ICP'
				ELSE 'CBP'
				END
			) = 'cbp'





