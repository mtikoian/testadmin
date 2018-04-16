set nocount on

--Test to assess the perf difference between string method vs DATEADD method   
--to set time portion to zero.  
use tempdb  
go  

--load lots of rows  
if object_id('dbo.date_table') is not null drop table dbo.date_table  
go  

--10000000 rows will blow up tempdb data file to about 200MB  
select top 10000000 getdate() as date_time  
into dbo.date_table  
from master.dbo.spt_values t1  
cross join master.dbo.spt_values t2  
cross join master.dbo.spt_values t3  
where t1.name is not null  
   and t2.name is not null   
   and t3.name is not null;  
go  

declare @t datetime  

--1, Pure string manipulation alternative  
set @t = getdate()  

select   
 convert(char(8), date_time, 112)  
,count(*)  
from dbo.date_table  
group by convert(char(8), date_time, 112)  
option (maxdop 1);  

select datediff(ms, @t, getdate()) as "String alternative"


--2, DATEADD alternative, with both 0 and '' as reference date 
set @t = getdate()  

select   
 dateadd(day, 0, datediff(day, '', date_time))  
,count(*)  
from dbo.date_table  
group by dateadd(day, 0, datediff(day, '', date_time))  
option (maxdop 1);  

select datediff(ms, @t, getdate()) as "dateadd alternative 1"


--DATEADD alternative, with '20040101' consistently as reference date 
set @t = getdate()  

select   
 dateadd(day, datediff(day, '20040101', date_time), '20040101')  
,count(*)  
from dbo.date_table  
group by dateadd(day, datediff(day, '20040101', date_time), '20040101')   
option (maxdop 1);  

select datediff(ms, @t, getdate()) as "dateadd alternative 2"


--DATEADD alternative, with 0 consistently as reference date 
set @t = getdate()  

select   
 dateadd(day, 0, datediff(day, 0, date_time))  
,count(*)  
from dbo.date_table  
group by dateadd(day, 0, datediff(day, 0, date_time))  
option (maxdop 1);  

select datediff(ms, @t, getdate()) as "dateadd alternative 3"
 
-- Get rid of the table 
if object_id('dbo.date_table') is not null drop table dbo.date_table  
go  

             