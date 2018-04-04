IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = 'prole_config_write' AND type = 'R')
  DROP ROLE [prole_config_write];
GO
CREATE ROLE [prole_config_write] AUTHORIZATION [dbo];

EXEC sp_addrolemember @rolename='prole_config_write',@membername='urole_config_write';