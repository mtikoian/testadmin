

if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_Of_Day'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_End_Of_Day
end
go

create function dbo.f_End_Of_Day 
	(@i_Today datetime)

returns datetime
 
as
-- =pod
/**
$Filename:f_End_Of_Day.sql
$Author: Stephen R. McLarnon Sr.

SCM
$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_End_Of_Day.sql $

$Object: f_get_today_start
$ObjectType: Scalar function

$Description: This function takes any valid data as a parameter and returns
a datetime value for that same day at 23:59:59.997.

Param1:	@i_Today - This is the date for which we want the midnight datetime 
		value returned.

OutputType:	datetime

Description:The max datetime value for the date passed. 

$$Revisions:
 Ini |    Date     | Description 
---------------------------------
**/
-- =cut

begin
   return dateadd(ms, -3, dateadd(day, datediff(day, 0, @i_Today) + 1, 0));
end;      

go
if exists (
    select 1
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_Of_Day'
      and ROUTINE_TYPE = 'Function'
        ) begin

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = N'This function takes any valid data as a parameter and returns a date value for that same day at 23:59:59.997 .' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_End_Of_Day';

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 394 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_End_Of_Day';
        
    
    
end else begin
    print 'Function dbo.f_End_Of_Day does not exist, create failed'
end
go
