

if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_Of_Day'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Start_Of_Day
end
go

create function dbo.f_Start_Of_Day 
	(@i_Today datetime)

returns datetime -- 20130722 JFEIERMAN: changed to DATETIME for SQL 2005 compatibility
 
as
-- =pod
/**
$Filename:f_Start_Of_Day.sql
$Author: Stephen R. McLarnon Sr.

SCM
$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Start_Of_Day.sql $

$Object: f_Start_Of_Day
$ObjectType: Scalar function

$Description: This function takes any valid data as a parameter and returns
a date value for that same day at midnight.

$Param1: @i_Today - This is the date for which we want the midnight datetime 
value returned.

$OutputType: date

$Output1: The date only for the datetime passed. 

$$Revisions:
 Ini |    Date     | Description 
---------------------------------
JFEIERMAN | 07/22/2013 | Changed return data type to DATETIME for SQL 2005 compatibility.
**/
-- =cut

begin
   return dateadd(day, 0, datediff(d, 0, @i_Today));
end;      

go
if exists (
    select 1
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_Of_Day'
      and ROUTINE_TYPE = 'Function'
        ) begin

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = N'This function takes any valid data as a parameter and returns a date value for that same day at midnight.' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_Start_Of_Day';

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 394 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_Start_Of_Day';
        
    
    
end else begin
    print 'Function dbo.f_Start_Of_Day does not exist, create failed'
end
go
