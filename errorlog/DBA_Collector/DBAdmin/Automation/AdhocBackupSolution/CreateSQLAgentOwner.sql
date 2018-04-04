/*******************************************************
 * This script creates a login to be used as a proxy   *
 * to allow the end user to execute the specific job   *
 * but not hold the higher SQL Agent Operator role.    *
 *******************************************************/

BEGIN TRY

  USE [master]
  
  -- Begin creation of proxy login that will own the job
  IF NOT EXISTS(SELECT 1 FROM sys.server_principals WHERE name = '$(DatabaseName)_ProxyAgentOwner')
  BEGIN
    CREATE LOGIN [$(DatabaseName)_ProxyAgentOwner] WITH PASSWORD='5%$%#@TGBT#Y^%#@$%', DEFAULT_DATABASE=tempdb;
  END
  ALTER LOGIN [$(DatabaseName)_ProxyAgentOwner] DISABLE;
  
  -- Create the user in MSDB
  USE [msdb];
  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$(DatabaseName)_ProxyAgentOwner')
  BEGIN
    CREATE USER [$(DatabaseName)_ProxyAgentOwner] FOR LOGIN [$(DatabaseName)_ProxyAgentOwner];
  END
  
  -- Create the role for the Adhoc Backup process
  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'urole_AdhocBackup' AND type = 'R')
    CREATE ROLE [urole_AdhocBackup] AUTHORIZATION [dbo];
  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'prole_AdhocBackup' AND type = 'R')
    CREATE ROLE [prole_AdhocBackup] AUTHORIZATION [dbo];
  EXEC sp_addrolemember @rolename='SQLAgentUserRole',@membername='prole_AdhocBackup';
  EXEC sp_addrolemember @rolename='prole_AdhocBackup',@membername='urole_AdhocBackup';
    
  -- Deny rights on sp_update_job and sp_update_jobstep
  -- This prevents updating or modifying the job, or creating new jobs
  DENY EXECUTE ON sp_update_job TO [$(DatabaseName)_ProxyAgentOwner];
  DENY EXECUTE ON sp_update_jobstep TO [$(DatabaseName)_ProxyAgentOwner];
  DENY EXECUTE ON sp_add_job TO [$(DatabaseName)_ProxyAgentOwner];
  DENY EXECUTE ON sp_add_jobstep TO [$(DatabaseName)_ProxyAgentOwner];
  DENY EXECUTE ON sp_delete_job TO [$(DatabaseName)_ProxyAgentOwner];
  DENY EXECUTE ON sp_delete_jobstep TO [$(DatabaseName)_ProxyAgentOwner];
  
  -- Add the login to the Adhoc Backup role
  EXEC sp_addrolemember @rolename='urole_AdhocBackup',@membername='$(DatabaseName)_ProxyAgentOwner';
  
  -- Give the user rights on the proxy
  EXEC msdb.dbo.sp_grant_login_to_proxy @login_name = '$(DatabaseName)_ProxyAgentOwner', @proxy_name = '$(DatabaseName)_AdhocBackupProxy';

END TRY
BEGIN CATCH

  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  
  SET @ErrorMessage = ERROR_MESSAGE();
  SET @ErrorSeverity = ERROR_SEVERITY();
  
  RAISERROR(@ErrorMessage,@ErrorSeverity,1);
  
END CATCH
