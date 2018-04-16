
declare @BusinessDate   datetime

declare @BusinessDateStart  datetime
declare @BusinessDateEnd    datetime  

set @BusinessDate = getdate() 
set @BusinessDateStart = dateadd(day, 0, datediff(d, 0, @businessdate)) -- This sets to start of day
set @BusinessDateEnd   = dateadd(ms, -3, dateadd(day, 1, @BusinessDateStart))


select @BusinessDate, @BusinessDateStart, @BusinessDateEnd
