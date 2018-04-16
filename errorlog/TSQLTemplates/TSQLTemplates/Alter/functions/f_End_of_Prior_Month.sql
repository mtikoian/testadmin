
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_of_Prior_Month'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_End_of_Prior_Month
end
go

create function dbo.f_End_of_Prior_Month
	( @DAY datetime )
returns  datetime
as
/**

Filename: f_End_of_Prior_Month.sql
Author: Stephen R. McLarnon Sr.
Created: 8/31/2011 9:08:19 AM

$Author: smclarnon $
$Date: 2013-01-17 08:18:58 -0500 (Thu, 17 Jan 2013) $
$Rev: 239 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_End_of_Prior_Month.sql $

Object: f_End_of_Prior_Month
ObjectType: Scalar function

Description:    Finds start of last day of prior month at 00:00:00.000
	            for input datetime, @DAY.
	            Valid for all SQL Server datetimes.

Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
@Day                 datetimes    Date to be processed


OutputParams:
----------------------------------------------------------------------------
EndOfMonth           datetime

Revisions:
 Ini |    Date     | Description
---------------------------------

*/

/*
Function: f_End_of_Prior_Month
	Finds start of last day of prior month at 00:00:00.000
	for input datetime, @DAY.
	Valid for all SQL Server datetimes.
*/
begin

return  dateadd(dd, -1, dateadd(mm,datediff(mm,0,@Day),0))

end
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_of_Prior_Month'
      and ROUTINE_TYPE = 'Function'
        ) begin

    declare @Description    varchar(7500);

    set @Description =  'Finds start of last day of prior month at 00:00:00.000 ' +
                        'for input datetime, @DAY. ' +
                        'Valid for all SQL Server datetimes.;'

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = @Description,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_End_of_Prior_Month'

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 239 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_End_of_Prior_Month';


end else begin
    print 'Function dbo.f_End_of_Prior_Month does not exist, create failed'
end
go
