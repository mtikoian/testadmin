
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_NumberOfDaysInMonth'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_NumberOfDaysInMonth
end
go

create function dbo.f_NumberofDaysInMonth
	(
		@i_day datetime
	)
returns int

as
/**

Filename: f_NumberOfDaysInMonth.sql
Author: Stephen R. McLarnon Sr.

Object: f_NumberOfDaysInMonth
ObjectType: Scalar function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_NumberOfDaysInMonth.sql $

Description:    Returns the number of days in the month of the date
                in the passed parameter.

Param1: @i_Day - The date for which we need the number of days.

OutputType: int

Output1: Number of days in month

Revisions:
 Ini |    Date     | Description
---------------------------------

*/
begin

	return
		case
			when month(@i_day) in (1, 3, 5, 7, 8, 10, 12) then 31
			when month(@i_day) in (4, 6, 9, 11) then 30
			else case
					when (
							year(@i_day) % 4 = 0
							and --Leap Year
							year(@i_day) % 100 <> 0
						 )
						 or
						year(@i_day) % 400 = 0
						then 29
					else 28
				 end
		end

end


go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_NumberOfDaysInMonth'
      and ROUTINE_TYPE = 'Function'
        ) begin

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = N'Returns the number of days for the year passed.' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_NumberOfDaysInMonth';

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 394 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_NumberOfDaysInMonth';
   
end else begin
    print 'Function dbo.f_NumberOfDaysInMonth does not exist, create failed'
end
go

/*
-- Test Section

declare @InputDate  date

set @InputDate = '2011-06-14'

select dbo.f_NumberOfDaysInMonth (@InputDate)

*/
