if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_of_Prior_Qtr'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_End_of_Prior_Qtr
end
go

create function dbo.f_End_of_Prior_Qtr
	( @DAY datetime )
returns  datetime
as
/**

Filename: f_End_of_Prior_Qtr.sql
Author: Patrick W. O'Brien
Created: 5/30/2013

$Author: pobrien $
$Date: 2013-05-30 12:50:57 -0400 (Thu, 30 May 2013) $
$Rev: 357 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_End_of_Prior_Qtr.sql $

Object: f_End_of_Prior_Qtr
ObjectType: Scalar function

Description:    Finds the end of prior quarter at 00:00:00.000
	              for input datetime, @DAY.
	              Valid for all SQL Server datetimes.

Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
@Day                 datetime      Date to be processed

Returns:
----------------------------------------------------------------------------
EndOfPriorQtr        datetime

Notes:
----------------------------------------------------------------------------


Revisions:
----------------------------------------------------------------------------

UserID    |    Date     | Description
----------------------------------------------------------------------------
POBrien     05/30/2013    Initial version
*/

begin

  return   dateadd(dd, -1, dateadd (qq, datediff (qq, 0, @Day) , 0) );

end
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_of_Prior_Qtr'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'Finds the end of the prior quarter at 00:00:00.000' +
	                          'for input datetime, @DAY. ' +
	                          'Valid for all SQL Server datetimes.';

        exec sys.sp_addextendedproperty
                @name       = N'MS_Description',
                @value      = @Description,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_End_of_Prior_Qtr'

        exec sys.sp_addextendedproperty
                @name       = N'SVN Revision',
                @value      = N'$Rev: 357 $' ,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_End_of_Prior_Qtr';

end else begin
    print 'Function dbo.f_End_of_Prior_Qtr does not exist, create failed'
end
go
