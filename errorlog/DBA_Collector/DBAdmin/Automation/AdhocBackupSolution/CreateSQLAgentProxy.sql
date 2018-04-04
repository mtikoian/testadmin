BEGIN TRY

  USE [master]
  
  -- Begin creation of proxy login to take the backups
  IF NOT EXISTS(SELECT 1 FROM sys.server_principals WHERE name = '$(ProxyUser)')
  BEGIN
    CREATE LOGIN [$(ProxyUser)] FROM WINDOWS WITH DEFAULT_DATABASE=tempdb;
  END
  
  -- Grant login db_creator rights
  EXEC sp_addsrvrolemember @rolename='dbcreator',@loginame='$(ProxyUser)';
  
  -- Grant login backup rights on database
  USE [$(DatabaseName)];
  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$(ProxyUser)')
  BEGIN
    CREATE USER [$(ProxyUser)] FOR LOGIN [$(ProxyUser)];
  END
  EXEC sp_addrolemember @rolename='db_backupoperator',@membername='$(ProxyUser)';
  
  -- Create the credential for the SQLAgent proxy
  USE [Master];
  IF NOT EXISTS (SELECT 1 FROM sys.credentials WHERE name = '$(DatabaseName)_AdhocBackupCredential')
  BEGIN
    CREATE CREDENTIAL $(DatabaseName)_AdhocBackupCredential WITH IDENTITY = N'$(ProxyUser)', SECRET = N'$(ProxyUserPassword)';
  END
  
  -- Create the SQL Agent Proxy
  USE [msdb];
  IF NOT EXISTS (SELECT 1 FROM dbo.sysproxies WHERE name = '$(DatabaseName)_AdhocBackupProxy')
  BEGIN
    EXEC msdb.dbo.sp_add_proxy @proxy_name = '$(DatabaseName)_AdhocBackupProxy', @credential_name=N'$(DatabaseName)_AdhocBackupCredential';
  END
  EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'$(DatabaseName)_AdhocBackupProxy', @subsystem_id=3;

END TRY
BEGIN CATCH

  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  
  SET @ErrorMessage = ERROR_MESSAGE();
  SET @ErrorSeverity = ERROR_SEVERITY();
  
  RAISERROR(@ErrorMessage,@ErrorSeverity,1);
  
END CATCH
