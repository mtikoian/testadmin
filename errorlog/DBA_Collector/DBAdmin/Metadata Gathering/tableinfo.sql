set nocount on

create table #spaceused
(
	name varchar(128),
	rows varchar(11),
	reserved varchar(128),
	data varchar(128),
	index_size varchar(128),
	unused varchar(128)
)

declare tablecursor cursor for 
	select name, schema_name(schema_id) from sys.objects where type = 'u'
declare @tablename varchar(255), @schemaname varchar(255)
declare @sql varchar(5000)
open tablecursor
fetch tablecursor into @tablename, @schemaname
while @@fetch_status=0 begin
	
	set @tablename = '[' + @schemaname + '].[' + @tablename + ']'
	
	insert #spaceused
	exec sp_spaceused @tablename
	if not @@error = 0 break

	fetch tablecursor into @tablename, @schemaname

end
close tablecursor
deallocate tablecursor

select * from #spaceused order by cast(substring(reserved,1,charindex(' ', reserved)) as int) desc

drop table #spaceused
