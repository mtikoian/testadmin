/*******************************************************
 * This script grants rigths to the end user group 
 * which will allow them to impersonate the job owner
 * and execute the SQL Agent job.
 *******************************************************/
 
USE [master];
 
-- Check if the login exists --
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = '$(EndUserLogin)')
BEGIN
  RAISERROR('The login specified ($(EndUserLogin)) does not exists on the server. Aborting.',16,1);
  RETURN
END

-- Grant IMPERSONATE rights --
GRANT IMPERSONATE ON LOGIN::[$(DatabaseName)_ProxyAgentOwner] TO [$(EndUserLogin)];
