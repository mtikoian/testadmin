
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_Of_Year'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Start_Of_Year
end
go

create function dbo.f_Start_Of_Year
	( @Day datetime )
returns  datetime
as
/**

Filename: f_Start_Of_Year.sql
Author: Stephen R. McLarnon Sr.

Object: f_Start_Of_Year
ObjectType: Scalar function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Start_Of_Year.sql $

Description:    Finds start of first day of year at 00:00:00.000
	            for input datetime, @DAY.
	            Valid for all SQL Server datetimes.

Param1: @Day - The date for which we wish to get the first day of the year.

OutputType: datetime

Output1: datetime

Revisions:
 Ini |    Date     | Description
---------------------------------

*/
begin
	return  dateadd(yy,datediff(yy, 0, @Day), 0)
end


go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_Of_Year'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'Finds start of first day of year at 00:00:00.000 ' +
	                        'for input datetime, @DAY. ' +
	                        'Valid for all SQL Server datetimes.';

        exec sys.sp_addextendedproperty
                @name       = N'MS_Description',
                @value      = @Description,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_Start_Of_Year'

        exec sys.sp_addextendedproperty
                @name       = N'SVN Revision',
                @value      = N'$Rev: 394 $' ,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_Start_Of_Year';
    
end else begin
    print 'Function dbo.f_Start_Of_Year does not exist, create failed'
end

go

/*
-- Test
declare	@d	date

set @d = getdate()

select dbo.f_Start_Of_Year (@d)

*/
