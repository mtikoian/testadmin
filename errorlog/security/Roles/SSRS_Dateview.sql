create view [V_DATE_RANGE] as
select 
 convert(varchar(100), 'Year To Date') as [Period]
 , dateadd(year, datediff(year, 0, getdate()), 0) BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Today') as [Period]
 , convert(datetime, convert(date, getdate())) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Yesterday') as [Period]
 , convert(datetime, convert(date, dateadd(day, -1, getdate()))) as BeginDate
 , convert(datetime, convert(date, dateadd(day, -1, getdate()))) as EndDate
union all
select 
 convert(varchar(100), 'Fiscal Year To Date') as [Period]
 , dateadd(month, -3, dateadd(year,datediff(year, 0, dateadd(month, 3, getdate())), 0)) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Month To Date') as [Period]
 , dateadd(month, datediff(month, 0, getdate()), 0) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last Month') as [Period]
 , dateadd(month, datediff(month, 0, getdate()) - 1, 0) as BeginDate
 , dateadd(day, -1, dateadd(month, datediff(month, 0, getdate()), 0)) as EndDate
union all
select 
 convert(varchar(100), 'Last Month to Date') as [Period]
 , dateadd(month, datediff(month, 0, getdate()) - 1, 0) as BeginDate
 , dateadd(month, -1, convert(datetime, convert(date, getdate()))) as EndDate
union all
select 
 convert(varchar(100), 'Last Year') as [Period]
 , dateadd(year, datediff(year, 0, getdate()) - 1, 0) as BeginDate
  , dateadd(year, datediff(year, 0, getdate()), -1) as EndDate
union all
select 
 convert(varchar(100), 'Last Year to Date') as [Period]
 , dateadd(year, datediff(year, 0, getdate()) - 1, 0) as BeginDate
 , dateadd(year, -1, convert(datetime, convert(date, getdate()))) as EndDate
union all
select 
 convert(varchar(100), 'Last 7 days') as [Period]
 , convert(datetime, convert(date, dateadd(day, -7, getdate()))) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last 14 days') as [Period]
 , convert(datetime, convert(date, dateadd(day, -14, getdate()))) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last 21 days') as [Period]
 , convert(datetime, convert(date, dateadd(day, -21, getdate()))) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last 28 days') as [Period]
 , convert(datetime, convert(date, dateadd(day, -28, getdate()))) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last 30 days') as [Period]
 , convert(datetime, convert(date, dateadd(day, -30, getdate()))) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last 60 days') as [Period]
 , convert(datetime, convert(date, dateadd(day, -60, getdate()))) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last 90 days') as [Period]
 , convert(datetime, convert(date, dateadd(day, -90, getdate()))) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'This Calendar Quarter') as [Period]
 , dateadd(quarter, datediff(quarter,0, getdate()),0) as BeginDate
 , dateadd(quarter, datediff(quarter,0, getdate()) + 1, -1) as EndDate
union all
select 
 convert(varchar(100), 'This Calendar Quarter to Date') as [Period]
 , dateadd(quarter, datediff(quarter, 0, getdate()), 0) as BeginDate
 , convert(datetime, convert(date, getdate())) as EndDate
union all
select 
 convert(varchar(100), 'Last Calendar Quarter') as [Period]
 , dateadd(quarter, datediff(quarter, 0, getdate()) - 1, 0) BeginDate
 , dateadd(quarter, datediff(quarter, 0, getdate()), -1) EndDate
union all
select 
 convert(varchar(100), 'Last Calendar Quarter to Date') as [Period]
 , dateadd(quarter, datediff(quarter, 0, getdate()) - 1, 0) BeginDate
 , dateadd(quarter, -1, convert(datetime, convert(date, getdate()))) as EndDate
union all
select 
 convert(varchar(100), 'Last Year Calendar Quarter') as [Period]
 , dateadd(year, -1, dateadd(quarter, datediff(quarter, 0, getdate()), 0)) as BeginDate
 , dateadd(year, -1, dateadd(quarter, datediff(quarter, 0, getdate()) + 1, -1)) as EndDateunion
union all
select 
 convert(varchar(100), 'Last Year Calendar Quarter to Date') as [Period]
 , dateadd(year, -1, dateadd(quarter, datediff(quarter, 0, getdate()), 0)) as BeginDate
 , dateadd(year, -1, convert(datetime, convert(date, getdate()))) as EndDate
union all
select 
 convert(varchar(100), 'Next Year') as [Period]
 , dateadd(year, datediff(year, 0, getdate()) + 1, 0) BeginDate
 , dateadd(year, datediff(year, 0, getdate()) + 2, -1) EndDate
union all
select 
 convert(varchar(100), 'Next Year to Date') as [Period]
 , dateadd(year, datediff(year, 0, getdate()) + 1, 0) BeginDate
 , dateadd(year, 1, cast(cast(getdate() as date) as datetime)) EndDate
GO