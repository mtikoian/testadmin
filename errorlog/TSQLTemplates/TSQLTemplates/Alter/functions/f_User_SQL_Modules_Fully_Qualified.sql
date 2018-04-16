
if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = N'dbo'
      and ROUTINE_NAME = 'f_User_SQL_Modules_Fully_Qualified'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_User_SQL_Modules_Fully_Qualified
end 
go

create function dbo.f_User_SQL_Modules_Fully_Qualified ()


    returns table

as
-- =pod
/**

Filename   : f_User_SQL_Modules_Fully_Qualified.sql
Author     : Stephen R. McLarnon
Created    : 2013-08-21 

SCM
$Author: smclarnon $
$Date: 2013-08-21 08:46:30 -0400 (Wed, 21 Aug 2013) $
$Rev: 396 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_User_SQL_Modules_Fully_Qualified.sql $

Object: dbo.f_User_SQL_Modules_Fully_Qualified
ObjectType : Table valued function

Description: This function returns a table of all user defined sql modules
             in the database. The name returned is fully qualified meaning
             that it is in the form schema.object. 

ResultSet:      datatype    description
----------------------------------------------------------------------------
FullModuleName  varchar     The fully qualified name of the sql module

*/
-- =cut
    return 

    select  s.name + '.' + o.name as FullModuleName
    from sys.sql_modules sm
        inner join sys.objects o on o.object_id = sm.object_id
        inner join sys.schemas s on s.schema_id = o.schema_id;

go


go
if not exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_User_SQL_Modules_Fully_Qualified'
      and ROUTINE_TYPE = 'Function'
        ) begin
    print 'Function dbo.f_User_SQL_Modules_Fully_Qualified does not exist, create failed'
end else begin
    grant select on dbo.f_User_SQL_Modules_Fully_Qualified to Public;

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description', 
            @value      = N'This function returns a table of user defined',
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'FUNCTION',
            @level1name = N'f_User_SQL_Modules_Fully_Qualified'; 

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 396 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'FUNCTION',
            @level1name = 'f_User_SQL_Modules_Fully_Qualified';
end;

go
