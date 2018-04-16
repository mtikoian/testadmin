
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Get_Session_Properties'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Get_Session_Properties
end
go

create function dbo.f_Get_Session_Properties ()

    returns table

as
-- =pod
/**

$Filename   : f_Get_Session_Properties.sql
$Author     : Stephen R. McLarnon Sr.
$Created    : 8/29/2011 8:49:06 AM

SCM
$Author: smclarnon $
$Date: 2013-01-17 08:20:23 -0500 (Thu, 17 Jan 2013) $
$Rev: 241 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Get_Session_Properties.sql $

$Object: dbo.f_Get_Session_Properties
$ObjectType : Table valued function

$Description: Returns a table of session property values.

$Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------
none

$ResultSet:
----------------------------------------------------------------------------
PropertyName    This is the identifier for the session value.
PropertyValue   This is the session value.


$$Revisions:
 Ini |    Date     | Description
---------------------------------

**/
-- =cut
return (

    select  'ANSI_NULLS' as PropertyName,
            case cast(sessionproperty('ANSI_NULLS') as bit)
                when 0 then 'No'
                when 1 then 'Yes'
            end as PropertyValue
    union all
    select  'ANSI_PADDING',
            case cast(sessionproperty('ANSI_PADDING') as bit)
                when 0 then 'No'
                when 1 then 'Yes'
            end
    union all
    select  'ANSI_WARNINGS',
            case cast(sessionproperty('ANSI_WARNINGS') as bit)
                when 0 then 'No'
                when 1 then 'Yes'
            end
    union all
    select  'ARITHABORT',
            case cast(sessionproperty('ARITHABORT') as bit)
                when 0 then 'No'
                when 1 then 'Yes'
            end
    union all
    select  'CONCAT_NULL_YIELDS_NULL',
            case cast(sessionproperty('CONCAT_NULL_YIELDS_NULL') as bit)
                when 0 then 'No'
                when 1 then 'Yes'
            end
    union all
    select  'NUMERIC_ROUNDABORT',
            case cast(sessionproperty('NUMERIC_ROUNDABORT') as bit)
                when 0 then 'No'
                when 1 then 'Yes'
            end
    union all
    select  'QUOTED_IDENTIFIER',
            case cast(sessionproperty('QUOTED_IDENTIFIER') as bit)
                when 0 then 'No'
                when 1 then 'Yes'
            end  

    );
go

if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Get_Session_Properties'
      and ROUTINE_TYPE = 'Function'
        ) begin

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = N'Returns a table of session properties.' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_Get_Session_Properties';

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 241 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_Get_Session_Properties';
        
    
end else begin
    print 'Function dbo.f_Get_Session_Properties does not exist, create failed';
end
go

/*
-- Test

select *
from dbo.f_Get_Session_Properties()

*/

