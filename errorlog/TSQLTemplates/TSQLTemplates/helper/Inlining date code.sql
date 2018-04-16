set nocount on

/*
This script is intended to show how you can put date conversions inline
rather than in a udf. I see many functions written to get dates like
Start_of_Day, First_Day_of_Month, Last_Day of_Quarter etc.

Putting code inline in a query is typically faster than a function call.

This code was specifically designed to avoid the use of string to datetime and 
datetine to string conversions 
*/

-- Starting point
declare @Business_Dt			datetime;
declare	@Business_Dt_2k8		date;		-- <-- all versions
declare	@Business_Dtm			datetime2;	-- <-- 2008 and up

-- Start of day variables
declare @Business_Dt_Start		datetime;	-- <-- all versions
declare	@Business_Dt_Start8		date;		-- <-- 2008 and up
declare @Business_Dtm_Start		datetime2;	-- <-- 2008 and up

-- End of day variables
declare @Business_Dt_End1		datetime;	-- <-- for all versions
declare @Business_Dt_End2		datetime;	-- <-- for all versions
declare @Business_Dtm_End		datetime2;	-- <-- 2008 and up

-- Others
declare @StartofWeek_Dt         date;
declare @StartOfWorkWeek_Dt     date;
declare @EndOfWorkWeek_Dtm      datetime2;
declare @EndOfWeek_Dt           date;
declare @EndOfWeek_Dtm          datetime2;
declare @OneYearAgo_Dt			date;	-- <-- for all versions
declare	@StartOfMonth_Dt		date;	-- <-- for all versions
declare	@StartOfQuarter_Dt		date;	-- <-- for all versions
declare	@StartOfYear_Dt			date;	-- <-- for all versions
declare	@DaysInMonth_Cnt		tinyint;

-- 2005 and older	---------------------------------------------------------------------------------
-- get current date and time
set @Business_Dt		= getdate();	-- <-- Old school, still works thru 2008

-- get start of day
-- This next line of code is the fastest way to get the date at midnight only from a datetime datatype
set @Business_Dt_Start = dateadd(day, 0, datediff(d, 0, @Business_Dt)); -- This sets to start of day

-- get the end of the day
set @Business_Dt_End1   = dateadd(ms, -3, dateadd(day, 1, @Business_Dt_Start)); -- for standard datetime data types

------------------------------------------------------------------------------------------------------

-- 2008 and up
-- get current date and time
set @Business_Dt_2k8	= getdate();	-- <-- 2K8 and up only, sets the date, throws out the time
set @Business_Dtm		= getdate();	-- <-- 2K8 and up only, Date and time

-- get start of day (only needed if you cannot use a date data type)
set @Business_Dtm_Start = dateadd(day, 0, datediff(d, 0, @Business_Dtm)); -- This sets to start of day
set @Business_Dt_Start8 = @Business_Dt_2k8  -- <-- no conversion needed as we are using date data type

-- get the end of the day
set @Business_Dtm_End  = dateadd(ns, -100, dateadd(day, 1, @Business_Dtm_Start));

-- get date one year ago
set @OneYearAgo_Dt = dateadd(yy, -1, dateadd(day, 0, datediff(d, 0, @Business_Dt)));

-- get the start of week (Sunday)
select @StartOfWeek_Dt = dateadd(day, 1 - (datepart(dw, @Business_Dt)), datediff(d, 0, @Business_Dt))

-- get the start of work week (Monday)
select @StartOfWorkWeek_Dt = dateadd(day, 2 - (datepart(dw, @Business_Dt)), datediff(d, 0, @Business_Dt))  

-- get the end of week date only (Saturday)
select @EndOfWeek_Dt = dateadd(day, 1 - (datepart(dw, @Business_Dt)), datediff(d, 0, @Business_Dt)) 

-- get the end of work week (Friday at 11:59:59.9999999)
select @EndOfWorkWeek_Dtm = dateadd(ns, -100, cast(dateadd(day, (-1 - (datepart(dw, @Business_Dt))) + 8, datediff(d, 0, @Business_Dt)) as datetime2)) 

-- get the end of calendar week (Friday at 11:59:59.9999999)
select @EndOfWeek_Dtm = dateadd(ns, -100, cast(dateadd(day, (-1 - (datepart(dw, @Business_Dt))) + 9, datediff(d, 0, @Business_Dt)) as datetime2))  

-- get start of month
set @StartOfMonth_Dt = dateadd(mm, datediff(mm, 0, @Business_Dt), 0);

-- get start of quarter
set @StartOfQuarter_Dt = dateadd(qq, datediff(qq, 0, @Business_Dt),0);

-- get the start of year
set @StartOfYear_Dt = dateadd(yy, datediff(yy, 0, @Business_Dt), 0);


print '2005 and older'
print 'Current day'
select	@Business_Dt as CurrentDatetime, 
		@Business_Dt_Start as BusinessDateStart,
		@Business_Dt_End1 as BusinessDateEnd; 
		
print 'Misc other dates'
select	@StartOfYear_Dt as StartOfYear,
		@StartOfMonth_Dt as StartOfMonth,
		@StartOfQuarter_Dt as StartOfQuarter,
		@OneYearAgo_Dt as OneYearAgo;
		
print '********************************************************************************'		
print '2K8 data types'
print 'Current day stuff'
select	convert(varchar(30), @Business_Dtm, 121) as BaseDateTime,
		@Business_Dt_2k8 as DateOnly,
		convert(varchar(30), @Business_Dtm_Start, 121) as BusinessDateStart,
		convert(varchar(30), @Business_Dtm_End, 121) as BusinessDateEnd
		
print 'Weekly'		
select	@StartofWeek_Dt as StartOfWeek,
		@StartOfWorkWeek_Dt as StartOfWorkWeek,
		convert(varchar(30), @EndofWeek_Dtm, 121) as EndofWeek,
		convert(varchar(30), @EndOfWorkWeek_Dtm, 121) as EndOfWorkWeek
