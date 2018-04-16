--generate a list of new and modified objects from all dbs except tempdb on server
--useful for checking work on deployments
--SQL 2005/2008


declare @check_dt	varchar(10)
select @check_dt = convert(varchar,GETDATE(),110) --set check dt to today's date, at 00:00:00 hours

create table #New_and_Modified_Objects
(dbname			nvarchar(128),
obj_name		sysname,
type_desc		nvarchar(60),
create_date		datetime,
modify_date		datetime)

declare		@cmd	varchar(2000)
select @cmd = 'use ? insert into #New_and_Modified_Objects select db_name() as dbname, name, type_desc, create_date, modify_date from sys.objects
where modify_date >= ''' + @check_dt + ''' or create_date >= ''' + @check_dt + ''''
exec sp_MSforeachdb @command1 = @cmd

select @@servername as Instance, dbname, type_desc, COUNT(*) as obj_count
from #New_and_Modified_Objects
where dbname <> 'tempdb'
group by dbname, type_desc
order by dbname, type_desc

select @@SERVERNAME as Instance, * 
from #New_and_Modified_Objects
where dbname <> 'tempdb'
order by dbname, type_desc, obj_name

drop table #New_and_Modified_Objects