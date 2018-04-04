BEGIN TRY

  -- SQL Agent Job --
  USE [msdb];
  
  IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'AdhocBackup_$(DatabaseName)')
    EXEC sp_delete_job @job_name = 'AdhocBackup_$(DatabaseName)';
  IF EXISTS (SELECT 1 FROM dbo.sysjobs WHERE name = 'AdhocRestore_$(DatabaseName)')
    EXEC sp_delete_job @job_name = 'AdhocRestore_$(DatabaseName)';
  
  -- SQL Agent Proxy --
  IF EXISTS (SELECT 1 FROM dbo.sysproxies WHERE name = '$(DatabaseName)_AdhocBackupProxy')
    EXEC sp_delete_proxy @proxy_name = '$(DatabaseName)_AdhocBackupProxy';
  
  -- Job owner --
  IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$(DatabaseName)_ProxyAgentOwner')
    DROP USER [$(DatabaseName)_ProxyAgentOwner];
    
  -- Operator --
  IF EXISTS (SELECT 1 FROM dbo.sysoperators WHERE name = '$(DatabaseName)_AdhocBackupRestoreOperator')
    EXEC dbo.sp_delete_operator @name = '$(DatabaseName)_AdhocBackupRestoreOperator';
  
  USE [master];
    
  -- Credential --
  IF EXISTS(SELECT 1 FROM sys.credentials WHERE name = '$(DatabaseName)_AdhocBackupCredential')
    DROP CREDENTIAL [$(DatabaseName)_AdhocBackupCredential];
    
  -- Agent proxy login --
  IF EXISTS(SELECT 1 FROM sys.server_principals WHERE name = '$(ProxyUser)')
  BEGIN
    DROP LOGIN [$(ProxyUser)];
  END
  
  IF EXISTS(SELECT 1 FROM sys.database_principals WHERE name = '$(ProxyUser)')
  BEGIN
    DROP USER [$(ProxyUser)];
  END
  
  -- Agent job owner login --
  IF EXISTS(SELECT 1 FROM sys.server_principals WHERE name = '$(DatabaseName)_ProxyAgentOwner')
  BEGIN
    REVOKE IMPERSONATE ON LOGIN::[$(DatabaseName)_ProxyAgentOwner] FROM [$(EndUserLogin)];
    DROP LOGIN [$(DatabaseName)_ProxyAgentOwner];
  END
  
END TRY
BEGIN CATCH

  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  
  SET @ErrorMessage = ERROR_MESSAGE();
  SET @ErrorSeverity = ERROR_SEVERITY();
  
  RAISERROR(@ErrorMessage,@ErrorSeverity,1);
  
END CATCH
