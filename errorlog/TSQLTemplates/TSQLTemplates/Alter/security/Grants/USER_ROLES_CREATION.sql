--Author name: PJoshi
--Date of origination: 12/04/2012
--Description of object: Creation of USER and ROLES
--Purpose of object: Creation of USER and ROLES 

USE $(DBName) 
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'CRMRepUser')
CREATE USER CRMRepUser FOR LOGIN CRMRepUser 
WITH DEFAULT_SCHEMA= DBO
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'urole_SEI_Investments_MSCRM' AND TYPE = 'R')
CREATE ROLE urole_SEI_Investments_MSCRM
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'prole_SEI_Investments_MSCRM' AND TYPE = 'R')
CREATE ROLE prole_SEI_Investments_MSCRM
GO

EXEC sys.sp_addrolemember @rolename=N'urole_SEI_Investments_MSCRM', @membername=N'CRMRepUser'
GO
EXEC sys.sp_addrolemember @rolename=N'prole_SEI_Investments_MSCRM', @membername=N'urole_SEI_Investments_MSCRM'
GO

