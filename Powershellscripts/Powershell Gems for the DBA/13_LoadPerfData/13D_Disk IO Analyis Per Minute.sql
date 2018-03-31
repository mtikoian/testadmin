declare @counter1 varchar(200), @counter2 varchar(200), @counter3 varchar(200), @counter4 varchar(200), @counter5 varchar(200)
declare @Threshold1 int, @Threshold2 int, @Scale1 int, @Scale2 int
declare @logId varchar(10)
declare @starttime datetime
declare @endtime datetime
set @starttime = '2015-02-11 00:00'
set @endtime = '2015-02-12 00:00'
--set @starttime = '2008-09-16 10:30'
--set @endtime = '2008-09-16 11:15'
set @counter1 = 'PhysicalDisk Disk Transfers/sec 2 M:'
set @counter2 = 'PhysicalDisk Disk Reads/sec 2 M:'
set @counter3 = 'PhysicalDisk Disk Writes/sec 2 M:'
set @counter4 = 'PhysicalDisk Avg. Disk Queue Length 2 M:'
set @counter5 = 'PhysicalDisk Avg. Disk sec/Transfer 2 M:'
set @Threshold1 = 0
set @Threshold2 = 0
set @Scale1 = 1
set @Scale2 = 1

set @Logid = 'Log1'

--select 
--  CounterTime,ReadIO, WriteIO, QueLen, Latency
--from
--(
select   
substring(convert(varchar(24),p1.counterdatetime,121),12,5) CounterTime, 
case when round(avg(countervalue),3) * @Scale1 = 0 then 1 else round(avg(countervalue),3) * @Scale1 end TotalIIO ,
 (
  select round(avg(p2.countervalue),3) * @Scale1 avgCounterValue 
   from dbo.Perfsummary p2 where p2.counter = @counter2  and p2.LogId = @LogId and 
                                    substring(convert(varchar(24),p2.counterdatetime,121),12,5) = substring(convert(varchar(24),p1.counterdatetime,121),12,5)
   group by LogId + ' - ' + p2.counter ,  
   substring(convert(varchar(24),p2.counterdatetime,121),12,5)
 ) ReadIO ,
 (
  select round(avg(p3.countervalue),3) * @Scale1 avgCounterValue 
   from dbo.Perfsummary p3 where p3.counter = @counter3  and p3.LogId = @LogId and 
                                    substring(convert(varchar(24),p3.counterdatetime,121),12,5) = substring(convert(varchar(24),p1.counterdatetime,121),12,5)
   group by LogId + ' - ' + p3.counter ,  
   substring(convert(varchar(24),p3.counterdatetime,121),12,5)
 ) WriteIO,
 (
 select round(avg(p4.countervalue),3) * @Scale1 avgCounterValue 
   from dbo.Perfsummary p4 where p4.counter = @counter4  and p4.LogId = @LogId and 
                                    substring(convert(varchar(24),p4.counterdatetime,121),12,5) = substring(convert(varchar(24),p1.counterdatetime,121),12,5)
   group by LogId + ' - ' + p4.counter ,  
   substring(convert(varchar(24),p4.counterdatetime,121),12,5)
 ) QueLen,
 (
 select round(avg(p5.countervalue),3) * @Scale1 avgCounterValue 
   from dbo.Perfsummary p5 where p5.counter = @counter5  and p5.LogId = @LogId and 
                                    substring(convert(varchar(24),p5.counterdatetime,121),12,5) = substring(convert(varchar(24),p1.counterdatetime,121),12,5)
   group by LogId + ' - ' + p5.counter ,  
   substring(convert(varchar(24),p5.counterdatetime,121),12,5)
 ) Latency

 from dbo.Perfsummary p1 where p1.counter = @Counter1   and p1.LogId = @LogId
and p1.counterdatetime between  @Starttime and @EndTime
group by LogId + ' - ' + p1.counter ,  
substring(convert(varchar(24),p1.counterdatetime,121),12,5)
--) as d where Latency> .02 and Quelen > 8