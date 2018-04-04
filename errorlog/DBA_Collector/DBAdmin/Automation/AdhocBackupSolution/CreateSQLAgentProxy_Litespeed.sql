BEGIN TRY

  -- Grant login rights to execute to backup SP
  USE [master];
  IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '$(ProxyUser)')
  BEGIN
    CREATE USER [$(ProxyUser)] FOR LOGIN [$(ProxyUser)];
  END
  GRANT EXECUTE ON xp_backup_database TO [$(ProxyUser)];
  GRANT EXECUTE ON xp_restore_database TO [$(ProxyUser)];
  
END TRY
BEGIN CATCH

  DECLARE @ErrorMessage NVARCHAR(4000);
  DECLARE @ErrorSeverity INT;
  
  SET @ErrorMessage = ERROR_MESSAGE();
  SET @ErrorSeverity = ERROR_SEVERITY();
  
  RAISERROR(@ErrorMessage,@ErrorSeverity,1);
  
END CATCH
