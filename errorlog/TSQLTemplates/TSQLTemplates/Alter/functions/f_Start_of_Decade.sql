
if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Decade'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Start_of_Decade
end
go


create function dbo.f_Start_of_Decade
	( @Day date )
returns  date
as
/**

Filename: f_Start_of_Decade.sql
Author: Stephen R. McLarnon Sr.

Object: f_Start_of_Decade
ObjectType: Scalar function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Start_of_Decade.sql $

Description:    Finds start of first day of decade at 00:00:00.000
	            for input datetime, @DAY.
	            Valid for all SQL Server datetimes >= 1760-01-01 00:00:00.000
	            Returns null if @DAY < 1760-01-01 00:00:00.000 

Param1: @Day - The date which is the seed date.
Param2:

OutputType: date

Output1: date 

Revisions:
 Ini |    Date     | Description 
---------------------------------

*/
/*
Function: F_START_OF_DECADE
	
*/
begin

	declare @Base_Day datetime
	select  @Base_Day = '17600101'
	
	return 	(
		case
			when @Day >= @Base_Day then
				dateadd(yy, (datediff(yy, @Base_Day, @Day) / 10) * 10, @Base_Day)
			else null 
		end
			)
end

go
if exists (
    select 1
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Decade'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'Finds start of first day of decade at 00:00:00.000 ' +
	                        'for input datetime, @DAY. ' +
	                        'Valid for all SQL Server datetimes >= 1760-01-01 00:00:00.000 ' +
	                        'Returns null if @DAY < 1760-01-01 00:00:00.000 ';

            exec sys.sp_addextendedproperty
                    @name       = N'MS_Description',
                    @value      = @Description,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Start_of_Decade'

            exec sys.sp_addextendedproperty
                    @name       = N'SVN Revision',
                    @value      = N'$Rev: 394 $' ,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Start_of_Decade';
   
end else begin
    print 'Function dbo.f_Start_of_Decade does not exist, create failed'
end

go

/*
-- Test
declare	@d	date

set @d = getdate()

select dbo.f_Start_of_Decade (@d)	

*/

