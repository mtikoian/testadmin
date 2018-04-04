IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'prole_config_read' AND type = 'R')
  DROP ROLE [prole_config_read];
GO

CREATE ROLE [prole_config_read] AUTHORIZATION [dbo];

EXEC sp_addrolemember @rolename='prole_config_read',@membername='urole_config_read';