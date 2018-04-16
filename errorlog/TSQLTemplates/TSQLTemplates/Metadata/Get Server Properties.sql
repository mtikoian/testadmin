

declare @PropName table (
    PropertyName    varchar(50)
)

insert into @PropName
select 'BuildClrVersion' union 			    -- Base data type: nvarchar(128)
select 'Collation' union 					-- Base data type: nvarchar(128)
select 'CollationID' union 				    -- Base data type: int
select 'ComparisonStyle' union 			    -- Base data type: int
select 'ComputerNamePhysicalNetBIOS' union	-- Base data type: nvarchar(128)
select 'Edition' union 					    -- Base data type: nvarchar(128)
select 'EditionID' union 					-- Base data type: int
select 'EngineEdition' union 				-- Base data type: int
select 'InstanceName' union 				-- Base data type: nvarchar(128)
select 'IsClustered' union 				    -- Base data type: int
select 'IsFullTextInstalled' union 		    -- Base data type: int
select 'IsIntegratedSecurityOnly' union 	-- Base data type: int
select 'IsSingleUser' union 				-- Base data type: int
select 'LCID' union						    -- Base data type: int
select 'LicenseType' union 				    -- Base data type: nvarchar(128)
select 'MachineName' union 				    -- Base data type: nvarchar(128)
select 'NumLicenses' union 				    -- Base data type: int
select 'ProcessID' union 					-- Base data type: int
select 'ProductVersion' union 				-- Base data type: nvarchar(128)
select 'ProductLevel' union 				-- Base data type: nvarchar(128)
select 'ResourceLastUpdateDateTime' union 	-- Base data type: datetime
select 'ResourceVersion' union 			    -- Base data type: nvarchar(128)
select 'ServerName' union					-- Base data type: nvarchar(128) 
select 'SqlCharSet' union 					-- Base data type: tinyint
select 'SqlCharSetName' union 				-- Base data type: nvarchar(128)
select 'SqlSortOrder' union 				-- Base data type: tinyint
select 'SqlSortOrderName' union 			-- Base data type: nvarchar(128)
select 'FilestreamShareName' union 
select 'FilestreamConfiguredLevel' union 
select 'FilestreamEffectiveLevel'                 

select  PropertyName,
        serverproperty(PropertyName)
from @PropName