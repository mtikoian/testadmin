
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Quarter'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Start_of_Quarter
end
go

create function dbo.f_Start_of_Quarter
	( @Day datetime )
returns  datetime
as
-- =pod
/**

Filename: f_Start_of_Quarter.sql
Author: Stephen R. McLarnon Sr.
Created: 6/30/2011 8:04:32 AM

Object: f_Start_of_Quarter
ObjectType: Scalar function

Description:    Finds start of first day of quarter at 00:00:00.000
                for input datetime, @DAY.
                Valid for all SQL Server datetimes.

Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
@Day

OutputParams:
----------------------------------------------------------------------------
First day of quarter  datetime

Revisions:
 Ini |    Date     | Description
---------------------------------

--**/

begin

return   dateadd(qq,datediff(qq,0,@Day),0)

end

go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Start_of_Quarter'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'Finds start of first day of quarter at 00:00:00.000
                            for input datetime, @DAY.
                            Valid for all SQL Server datetimes.';

        exec sys.sp_addextendedproperty
                @name       = N'MS_Description',
                @value      = @Description,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_Start_of_Quarter'

        exec sys.sp_addextendedproperty
                @name       = N'SVN Revision',
                @value      = N'$Rev: 250 $' ,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_Start_of_Quarter';

end else begin
    print 'Function dbo.f_Start_of_Quarter does not exist, create failed'
end

go
