
declare		@OutValue	varchar(8000)

set @OutValue = ''

begin try

	select @OutValue =  coalesce(@OutValue + 
						case when @OutValue = '' then '' else ',' end, '') + 
						ea.Email_Dist_Grp_Id
	from dbo.Email_Dist_Grp ea	
	order by ea.Email_Dist_Grp_Id  
	
	select datalength(@OutValue)

end try
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch	                