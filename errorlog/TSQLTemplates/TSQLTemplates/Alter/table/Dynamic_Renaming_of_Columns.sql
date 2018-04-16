/*
	Author		:	Jayakumaur R
	Date		:	2014-03-21 12:48:07.510
	Description	:	Script to dynamically rename the columns of a table.
*/

--Sample table
create table abc
(
	[dbo.abc.sno] int,
	[dbo.abc.sname] varchar(255),
	[dbo.abc.dept] varchar(255)
)
insert abc select 1,'jk','IT'
insert abc select 99,'jay','CSE'

--Actual Script starts
select 
	identity(int,1,1) as id
	,object_name(object_id) as table_name
	,name as old_name
	/*below mentioned expression to be built as per need. This one,
	converts 'dbo.abc.sno' to 'sno'*/
	,right(name,charindex('.',reverse(name))-1) as new_name 
into #temp
from sys.columns 
where object_id=object_id('abc') --Provide your table_name here

declare @i int,@n int,@sql nvarchar(max)
set @i=1
set @n=(select count(*) from #temp)

while(@i<=@n)
begin
	select @sql='EXEC sp_rename '''+table_name+'.['+old_name+']'','''+new_name+''',''column'''
	from #temp
	where id=@i
--	print @sql
	EXEC(@sql)
	set @i=@i+1
end

--cleanup
drop table #temp
drop table abc