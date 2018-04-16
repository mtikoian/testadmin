
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Month'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Start_of_Month
end
go

create function dbo.f_Start_of_Month
	( @Day datetime )
returns  datetime
as
/**

Filename: f_Start_of_Month.sql
Author: Stephen R. McLarnon Sr.
Created: 6/30/2011 7:56:01 AM

Object: f_Start_of_Month
ObjectType: Scalar Function

Description:    Finds start of first day of month at 00:00:00.000
	            for input datetime, @DAY.
	            Valid for all SQL Server datetimes.

Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
@Day                 datetime     The day for which we to determine the
                                   month start date
Output
----------------------------------------------------------------------------
First day of month      datetime

Revisions:
 Ini |    Date     | Description
---------------------------------

*/

begin

return  dateadd(mm,datediff(mm,0,@Day),0)

end
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Month'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'Finds start of first day of month at 00:00:00.000 ' +
	                        'for input datetime, @DAY. ' +
	                        'Valid for all SQL Server datetimes.';

            exec sys.sp_addextendedproperty
                    @name       = N'MS_Description',
                    @value      = @Description,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Start_of_Month'

            exec sys.sp_addextendedproperty
                    @name       = N'SVN Revision',
                    @value      = N'$Rev: 394 $' ,
                    @level0type = N'SCHEMA',
                    @level0name = N'dbo',
                    @level1type = N'FUNCTION',
                    @level1name = N'f_Start_of_Month';

end else begin
    print 'Function dbo.f_Start_of_Month does not exist, create failed'
end

go
