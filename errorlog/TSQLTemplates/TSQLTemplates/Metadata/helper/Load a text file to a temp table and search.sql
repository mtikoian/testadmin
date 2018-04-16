
create table #ImportText (
    Row_Id      int identity(1,1) primary key clustered,
    Row_Data    varchar(8000) 
)                
declare @SqlCmd varchar(1000)

begin try

    set @SqlCmd = 'type C:\A\Workspace\CodeReview\2011_08\20110822_2874003\p_SAMREP_GetLogTransactionData.sql'

    insert into #ImportText (Row_Data)
    exec xp_CmdShell @sqlCmd
    
    select ltrim(Row_Data) 
    from #ImportText
    where Row_Data like '%declare %'
      and Row_Data like '% cursor%'
      and left(ltrim(replace(Row_Data, char(9), '    ')), 2) <> '--'

end try
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch


drop table #ImportText