
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Calendar_One_Month'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Calendar_One_Month
end

go

create function dbo.f_Calendar_One_Month
        (
            @i_Working_Dt   date
        )

returns @MonthOfDates table (
	Calendar_Dt	date,
	Date_Nm		varchar(10)
)

as
/*

Filename: f_Calendar_One_Month.sql
Author: Stephen R. McLarnon Sr.
Created: 7/7/2011 12:55:58 PM

Object: f_Calendar_One_Month
ObjectType: Table valued function

$Author: smclarnon $
$Date: 2013-01-17 07:37:14 -0500 (Thu, 17 Jan 2013) $
$Rev: 234 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Date_Tbl_One_Month.sql $

Description:   This function returns a table that represents one calendar
                 month consisting of 2 columns. The first is the date (1..31) and the second
                 is the day of week name (Sunday .. Saturday).

Params:
Name               | Datatype  | Description
----------------------------------------------------------------------------
@i_Working_Dt       date        The date that will be the basis for the
                                table that will be returned. The function
                                examines this parameter, determines the
                                month for this date and builds a table with
                                one row for each day of the month


ResultSet:
----------------------------------------------------------------------------
Calendar_Dt - The date
Date_Nm     - The day of week name

Revisions:
 Ini |    Date     | Description
---------------------------------

*/
begin

declare	@DaysinMonth_Cnt	tinyint
declare	@FirstOfMonth_Dt	date

set @FirstOfMonth_Dt = dateadd(mm, datediff(mm, 0, @i_Working_Dt), 0);

set @DaysinMonth_Cnt =          --dbo.f_NumberofDaysInMonth(@BaseDate);
		case
			when month(@i_Working_Dt) in (1, 3, 5, 7, 8, 10, 12) then 31
			when month(@i_Working_Dt) in (4, 6, 9, 11) then 30
			else case
					when (
							year(@i_Working_Dt) % 4 = 0
							and --Leap Year
							year(@i_Working_Dt) % 100 <> 0
						 )
						 or
						year(@i_Working_Dt) % 400 = 0
						then 29
					else 28
				 end
		end;


	;with E1(N) as
    (
        select 1 union all select 1 union all select 1 union all
        select 1 union all select 1 union all select 1
    ),
    E2(N) as
    (
        select 1
        from E1 a
			cross join E1 b -- cross join yields 36 rows
    ),
    cteTally(DayOfMonth_Num) as
    (   -- This provides the "zero base" and limits the number of rows right up front
        -- for both a performance gain and prevention of accidental "overruns"

        select top (@DaysinMonth_Cnt) row_number() over (order by (select null))
        from E2
    ),
    Calendar(Date_Num, Date_Nm) as
    (
		select	dateadd(dd, (DayOfMonth_Num - 1), @FirstOfMonth_Dt),
				datename(dw, dateadd(dd, (DayOfMonth_Num - 1), @FirstOfMonth_Dt))
		from cteTally
    )
    insert into @MonthOfDates
    select	Date_Num,
            Date_Nm
    from Calendar;

	return;

end


go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Calendar_One_Month'
      and ROUTINE_TYPE = 'Function'
        ) begin
        declare @Description    varchar(7500);

        set @Description =  'This function returns a table that represents one calendar ' +
                            'month consisting of 2 columns. The first is the date (1..31) and the second ' +
                            'is the day of week name (Sunday .. Saturday).';

            exec sys.sp_addextendedproperty
                    @name       = N'MS_Description',
                    @value      = @Description,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Calendar_One_Month'

            exec sys.sp_addextendedproperty
                    @name       = N'SVN Revision',
                    @value      = N'$Rev: 234 $' ,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Calendar_One_Month';

end else begin
    print 'Function dbo.f_Calendar_One_Month does not exist, create failed'
end
go
/* Test Code

select *
from dbo.f_Calendar_One_Month ('2011-08-12')

*/