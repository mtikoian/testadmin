

if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Century'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Start_of_Century
end
go

create function dbo.f_Start_of_Century
		( @Day date )
returns  date
as

/**

Filename: f_Start_of_Century.sql
Author: Stephen R. McLarnon Sr.

Object: f_Start_of_Century
ObjectType: Scalar function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Start_of_Century.sql $

Description:    This function returns the first day of the century to which 
                the passed parameter belongs. Valid for all SQL Server 
                datetimes >= 1800-01-01 00:00:00.000 Returns null if @DAY < 1800-01-01 00:00:00.000

Param1: @Day - date that is the start date.

OutputType: date

Output1: Date - the first day of the century for the year passed. 

Revisions:
Ini |    Date     | Description 
---------------------------------

*/
begin
	declare @Base_Day date

	set  @Base_Day = '18000101'

	return	(
		case
			when @Day < @Base_Day then null
			else dateadd(yy, (datediff(yy, @Base_Day, @Day) / 100) * 100, @Base_Day)
		end
			)
end
go
if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Century'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'This function returns the first day of the century to which ' + 
                            'the passed parameter belongs. Valid for all SQL Server ' + 
                            'datetimes >= 1800-01-01 00:00:00.000 Returns null if @DAY < 1800-01-01 00:00:00.000';

            exec sys.sp_addextendedproperty
                    @name       = N'MS_Description',
                    @value      = @Description,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Start_of_Century'

            exec sys.sp_addextendedproperty
                    @name       = N'SVN Revision',
                    @value      = N'$Rev: 394 $' ,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Start_of_Century';
    
end else begin
    print 'Function dbo.f_Start_of_Century does not exist, create failed'
end
go
/*
-- Test
declare	@d	date

set @d = getdate()

select dbo.f_Start_of_Century (@d)	


*/
