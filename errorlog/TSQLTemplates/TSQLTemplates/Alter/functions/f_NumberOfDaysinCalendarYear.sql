
if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_NumberOfDaysinCalendarYear'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_NumberOfDaysinCalendarYear
end
go

create function dbo.f_NumberOfDaysinCalendarYear
    (
        @i_Year smallint
    )
returns int
as 
/**

Filename: f_NumberOfDaysinCalendarYear.sql
Author: Stephen R. McLarnon Sr.

Object: f_NumberOfDaysinCalendarYear
ObjectType: Scalar function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_NumberOfDaysinCalendarYear.sql $

Description: Returns the number of days for the year passed. 

Param1: @i_Year - The year for which we wish to count days.

OutputType: int

Output1: Number of days in the passed year

Revisions:
  Ini |    Date     | Description 
 ---------------------------------

*/

begin
    return 
        case 
    		when (
                    @i_Year % 4 = 0 
                    and 
                    @i_Year % 100 <> 0
                 ) 
                 or 
                 @i_Year % 400 = 0 
                 then 366
    		else 365
    	end
end
go

if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_NumberOfDaysinCalendarYear'
      and ROUTINE_TYPE = 'Function'
        ) begin

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = N'Returns the number of days in the month of the date in the passed parameter.' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_NumberOfDaysinCalendarYear';

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 394 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_NumberOfDaysinCalendarYear';
   

end else begin
    print 'Function dbo.f_NumberOfDaysinCalendarYear does not exist, create failed'
end
go

/*
--* Test:
declare @Year   smallint

set @Year = 2000

select dbo.f_NumberOfDaysinCalendarYear 

*/

