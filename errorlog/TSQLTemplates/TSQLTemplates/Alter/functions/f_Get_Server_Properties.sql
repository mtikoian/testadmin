if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Get_Server_Properties'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Get_Server_Properties
end
go

create function dbo.f_Get_Server_Properties ()


    returns table

as
-- =pod
/**

$Filename   : dbo.f_Get_Server_Properties.sql
$Author     : Stephen R. McLarnon Sr.
$Created    : 8/29/2011 7:43:13 AM

SCM
$Author: smclarnon $
$Date: 2013-01-17 08:19:34 -0500 (Thu, 17 Jan 2013) $
$Rev: 240 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Get_Server_Properties.sql $

$Object     : dbo.f_Get_Server_Properties
$ObjectType : Table Valued Function

$Description: Returns a table of server properties.

$Params:
Name                | Datatype   | Description
----------------------------------------------------------------------------



$ResultSet:
----------------------------------------------------------------------------
PropertyName    The identifier for the property value.
PropertyValue   The value associated with the PropertyName.

$Note:

$Revisions:
 Ini |    Date     | Description
---------------------------------

**/
-- =cut
return (
    select  'BuildClrVersion' as PropertyName,
            cast(serverproperty('BuildClrVersion') as varchar(128)) as PropertyValue
    union all
    select  'Collation',
            cast(serverproperty('Collation') as varchar(128))
    union all
    select  'CollationID',
            cast(serverproperty('CollationID') as varchar(128))
    union all
    select  'ComparisonStyle',
            cast(serverproperty('ComparisonStyle') as varchar(128))
    union all
    select  'ComputerNamePhysicalNetBIOS',
            cast(serverproperty('ComputerNamePhysicalNetBIOS') as varchar(128))
    union all
    select  'Edition',
            cast(serverproperty('Edition') as varchar(128))
    union all
    select  'EditionID',
            cast(serverproperty('EditionID') as varchar(128))
    union all
    select  'EngineEdition',
            cast(serverproperty('EngineEdition') as varchar(128))
    union all
    select  'InstanceName',
            cast(serverproperty('InstanceName') as varchar(128))
    union all
    select  'IsClustered',
            cast(serverproperty('IsClustered') as varchar(128))
    union all
    select  'IsFullTextInstalled',
            cast(serverproperty('IsFullTextInstalled') as varchar(128))
    union all
    select  'IsIntegratedSecurityOnly',
            cast(serverproperty('IsIntegratedSecurityOnly') as varchar(128))
    union all
    select  'IsSingleUser',
            cast(serverproperty('IsSingleUser') as varchar(128))
    union all
    select  'LCID',
            cast(serverproperty('LCID') as varchar(128))
    union all
    select  'LicenseType',
            cast(serverproperty('LicenseType') as varchar(128))
    union all
    select  'MachineName',
            cast(serverproperty('Collation') as varchar(128))
    union all
    select  'NumLicenses',
            cast(serverproperty('NumLicenses') as varchar(128))
    union all
    select  'ProcessID',
            cast(serverproperty('ProcessID') as varchar(128))
    union all
    select  'ProductVersion',
            cast(serverproperty('ProductVersion') as varchar(128))
    union all
    select  'ProductLevel',
            cast(serverproperty('ProductLevel') as varchar(128))
    union all
    select  'ResourceLastUpdateDateTime',
            cast(serverproperty('ResourceLastUpdateDateTime') as varchar(128))
    union all
    select  'ResourceVersion',
            cast(serverproperty('ResourceVersion') as varchar(128))
    union all
    select  'ServerName',
            cast(serverproperty('ServerName') as varchar(128))
    union all
    select  'SqlCharSet',
            cast(serverproperty('SqlCharSet') as varchar(128))
    union all
    select  'SqlCharSetName',
            cast(serverproperty('SqlCharSetName') as varchar(128))
    union all
    select  'SqlSortOrder',
            cast(serverproperty('SqlSortOrder') as varchar(128))
    union all
    select  'SqlSortOrderName',
            cast(serverproperty('SqlSortOrderName') as varchar(128))
    union all
    select  'FilestreamShareName',
            cast(serverproperty('FilestreamShareName') as varchar(128))
    union all
    select  'FilestreamConfiguredLevel',
            cast(serverproperty('FilestreamConfiguredLevel') as varchar(128))
    union all
    select  'FilestreamEffectiveLevel',
            cast(serverproperty('FilestreamEffectiveLevel') as varchar(128))
)

go
if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Get_Server_Properties'
      and ROUTINE_TYPE = 'Function'
        ) begin

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description',
            @value      = N'Returns a table of server properties.' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_Get_Server_Properties';

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 240 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'Function',
            @level1name = N'f_Get_Server_Properties';


end else begin
    print 'Function dbo.f_Get_Server_Properties does not exist, create failed'
end
go

/*
-- Test

select *
from dbo.f_Get_Server_Properties()

*/

