
declare	@Term1	varchar(128)
declare	@Term2	varchar(128)
--set @Term = 'CURRENCY_OF_OPERATION_ISO_ID'
set @Term1 = 'locator'
set @Term2 = ''

select	isc.*, ist.*,Table_Type
from Information_schema.columns isc
	inner join information_schema.Tables ist on ist.Table_Catalog = isc.Table_Catalog
											and ist.Table_Schema = isc.Table_Schema
											and ist.Table_Name = isc.Table_Name
where isc.Column_Name like '%' + @Term1 + '%'
  --and isc.Column_Name like '%' + @Term2 + '%'
  and ist.Table_Type = 'Base Table'	
  --and ist.Table_Name in ('Account')	
order by ist.Table_Name,  
		isc.Column_Name