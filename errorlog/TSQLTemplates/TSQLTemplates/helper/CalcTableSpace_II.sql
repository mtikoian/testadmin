


if exists (select 1 from TEMPDB..SYSOBJECTS where NAME like '%#TableSize%')
begin
		drop table #TableSize
end
go

declare @TotalData  int
declare @TotalIdx   int

create table #TableSize 
(
    name        sysname,
    RCount      int,
    reserved    varchar (200),
    data        varchar (200),
    index_size  varchar (200),
    unused      varchar (200),
    DatabaseName sysname default(db_name())
)

create table #TableSizeNumeric 
(
    name        sysname,
    RCount      int,
    reserved    int,
    data        int,
    index_size  int,
    unused      int,
    DatabaseName sysname default(db_name())
)

execute sp_msforeachtable 'INSERT INTO #TableSize (name,RCount,reserved,data,index_size,unused) EXECUTE sp_spaceused [?] '

--SELECT  TS.[name],
--        (cast (substring(TS.reserved,0,len(TS.reserved)-2) as INT)/1024) AS TableSizeInMB,
--        cast( substring(TS.index_size,0,len(TS.index_size)-2) as INT)/1024 as IDXSize
--FROM #TableSize TS
--ORDER BY TS.[name]
--WHERE TS.[rows]>1000

set @TotalData = (select sum(cast(substring(data, 0, len(rtrim(data)) - 2) as int)) from #TableSize)
set @TotalIdx  = (select sum(cast(substring(index_size, 0, len(index_size) - 2) as int)) from #TableSize)

insert into #TableSizeNumeric 
select  name,
        RCount,
        cast(substring(reserved, 0, len(rtrim(reserved)) - 2) as int),
        cast(substring(data, 0, len(rtrim(data)) - 2) as int),
        cast(substring(index_size, 0, len(rtrim(index_size)) - 2) as int),
        cast(substring(unused, 0, len(rtrim(unused)) - 2) as int),
        DatabaseName
from #TableSize

select  name,
        RCount,
        DatabaseName,
        data as DataSizeKB,
        index_size as IndexSizeKB,
        cast(round(cast(data as decimal(18,12)) / cast(@TotalData as decimal(18, 12)), 5) as decimal(4,3)) * 100 as PctOfTotal
from  #TableSizeNumeric 
order by name         
           
drop table #TableSizeNumeric
drop table #TableSize          