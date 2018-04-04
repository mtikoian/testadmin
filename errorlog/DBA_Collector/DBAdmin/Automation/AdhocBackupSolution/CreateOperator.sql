USE [msdb];
IF NOT EXISTS (SELECT 1 FROM dbo.sysoperators WHERE name = '$(DatabaseName)_AdhocBackupRestoreOperator')
  EXEC dbo.sp_add_operator @name = '$(DatabaseName)_AdhocBackupRestoreOperator', @email_address = '$(NotificationEMail)';

