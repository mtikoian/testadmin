
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_LastWeekDayDateOfMonth'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_LastWeekDayDateOfMonth
end
go

create function dbo.f_LastWeekDayDateOfMonth
    (@i_BaseDate    datetime)
    
    returns datetime

as
-- =pod
/**

Filename    : f_LastWeekDayDateOfMonth.sql
Created By  : SRMcLarnon
Created     : 4/28/2012 6:25:50 AM

SCC
---
$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_LastWeekDayDateOfMonth.sql $


Object: dbo.f_LastWeekDayDateOfMonth
ObjectType : Table valued function

Description:    This function returns the date that is the last weekday of the
                month for the date passed as a parameter..

Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
@i_BaseDate         datetime        This is the starting date. We will return
                                    the last weekday of the month in which the
                                    base date occurs.

Revisions:
  Ini |    Date     | Description
---------------------------------
End
*/
-- =cut
begin

    return
    dateadd(D, case datename(DW, dateadd(m, datediff(m, 0, @i_BaseDate)+1, 0)) 
					    when 'Sunday' then -2
					    when 'Monday' then -3
					    else -1
					  end, dateadd(m, datediff(m, 0, @i_BaseDate)+1, 0)
			)
;
end
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_LastWeekDayDateOfMonth'
      and ROUTINE_TYPE = 'Function'
        ) begin

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = N'This function returns the date that is the last weekday of the month for the date passed as a parameter.' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_LastWeekDayDateOfMonth';

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 394 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_LastWeekDayDateOfMonth';

end else begin
    print 'Function dbo.f_LastWeekDayDateOfMonth does not exist, create failed'

end
go

