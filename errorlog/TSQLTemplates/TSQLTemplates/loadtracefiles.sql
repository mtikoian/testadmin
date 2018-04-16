-- Load all TRC files in a given folder into a single trace table. 
set nocount on

-- Set these values. 

declare @TrcFolderName nvarchar(260)      set @TrcFolderName = 'D:\Trace\Tracefiles\'
declare @TrcFilePrefix nvarchar(260)      set @TrcFilePrefix = 'internal2'

-- Load the TRC filenames into temp table. 
declare @DosCmd nvarchar(4000)
set @DosCmd = 'dir /b ' + @TrcFolderName + @TrcFilePrefix + '*.trc'
select @DosCmd
if object_id('tempdb..#TrcFiles') is not null
    drop table #TrcFiles

create table #TrcFiles (TrcFileName nvarchar(260))

insert #TrcFiles
    exec master..xp_cmdshell @DosCmd 
	select * from #TrcFiles
delete #TrcFiles
 where TrcFileName is null

-- Iterate the trace files and read them into the trace table. 
declare @TrcFileName  nvarchar(260)
declare @TrcPathName  nvarchar(260)
declare @RowsAffected int

if object_id('dbo.trace_table') is not null
    drop table dbo.trace_table

declare cur cursor for
    select TrcFileName from #TrcFiles 
     
open cur
fetch next from cur into @TrcFileName

while @@fetch_status = 0
begin
    set @TrcPathName = @TrcFolderName + @TrcFileName
    raiserror('%s', 10, 1, @TrcPathName) with nowait

    if object_id('dbo.trace_table') is null
        select * into dbo.trace_table from ::fn_trace_gettable (@TrcPathName, /* number_files */ 1)
    else
        insert dbo.trace_table
            select * from  ::fn_trace_gettable (@TrcPathName, /* number_files */ 1)

    set @RowsAffected = @@rowcount
    raiserror('   %9d rows inserted', 10, 1, @RowsAffected) with nowait
    
    fetch next from cur into @TrcFileName
end

close cur
deallocate cur

-- Quirk in trace: update NULL DatabaseName's from their ID's. 
update dbo.trace_table
   set DatabaseName = db_name(DatabaseID)
 where isnull(DatabaseName, '')  = ''

set @RowsAffected = @@rowcount
raiserror('   %9d NULL DatabaseNames updated from their IDs', 10, 1, @RowsAffected) with nowait

-- Example cleanup: delete all rows that don't show their database. 
--delete dbo.trace_table
-- where DatabaseName is null

set @RowsAffected = @@rowcount
raiserror('   %9d NULL DatabaseNames deleted', 10, 1, @RowsAffected) with nowait

-- Example results: find unique logins per database per day. 
  select dateadd(dd, 0, datediff(dd, 0, StartTime))   as 'LoginDate'
       , LoginName
       , DatabaseName
    from dbo.trace_table
group by dateadd(dd, 0, datediff(dd, 0, StartTime))
       , LoginName
       , DatabaseName
order by LoginDate desc
       , LoginName
       , DatabaseName