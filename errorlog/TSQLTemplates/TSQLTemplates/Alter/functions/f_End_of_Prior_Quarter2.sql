set nocount on
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_of_Prior_Quarter2'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_End_of_Prior_Quarter2
end
go

create function dbo.f_End_of_Prior_Quarter2
	( @Day datetime )

returns  datetime2

as
/**

Filename:   f_End_of_Prior_Quarter2.sql
Author  :   Stephen R. McLarnon Sr.
Created :   2013-06-04 9:32 AM

Object  :   f_End_of_Prior_Quarter2
Type    :   Scalar function

Desc.   :   Returns the end of the prior quarter relative to the date passed.
	        This is valid for all SQL Server datetimes but will work only with
            SQL Server 2008 and newer.   

Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
@Day                 datetime       Date that is the basis for the calculation.
 

Note:

Revisions:
 Ini |    Date     | Description
---------------------------------

**/


begin

return  dateadd(ms, -1, cast(dateadd(qq, datediff(qq, 0, @Day), 0) as datetime2))

end
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_End_of_Prior_Quarter2'
      and ROUTINE_TYPE = 'Function'
        ) begin


    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 362 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_End_of_Prior_Quarter2';

end else begin
    print 'Function dbo.f_End_of_Prior_Quarter2 does not exist, create failed';
end
go
