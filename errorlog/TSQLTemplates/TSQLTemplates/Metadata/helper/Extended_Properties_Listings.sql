

begin try
	
	-- Database object
    select *
    from fn_listextendedproperty(NULL, default, default, default, default, default, default)	
	
	-- schemas
    select *
    from fn_listextendedproperty(NULL, 'schema', default, default, default, default, default)		
	
	-- schemas
    select *
    from fn_listextendedproperty(NULL, 'schema', 'gwp', 'table', default, default, default)

end try
begin catch
	select  error_number(),
		    error_message()
end catch          
