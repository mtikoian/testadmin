DECLARE @Txt VARCHAR(MAX);

SET @Txt = '

The following SQL Agent jobs have been created:

AdhocBackup_$(DatabaseName) - used to take an adhoc backup of the database. This will overwrite any existing adhoc backup.
AdhocRestore_$(DatabaseName) - used to restore the database from the last adhoc backup taken.

To take an adhoc backup of the database, execute the following query is SQL Server Management Studio

  EXECUTE AS LOGIN = ''$(DatabaseName)_ProxyAgentOwner'';
  EXEC msdb.dbo.sp_start_job @job_name = ''AdhocBackup_$(DatabaseName)'';
  REVERT;
  
To restore the adhoc backup, execute the following:

  EXECUTE AS LOGIN = ''$(DatabaseName)_ProxyAgentOwner'';
  EXEC msdb.dbo.sp_start_job @job_name = ''AdhocRestore_$(DatabaseName)'';
  REVERT;
  
 When the jobs complete an e-mail will be sent to "$(NotificationEMail)".
 
 Please note that if you restore an adhoc backup that was taken before the most recent Saturday,
 you will break the differential backup chain of the regular DBA backups. This means that no point
 in time recovery will be possible until the next Saturday backup is taken.';
 
 PRINT @Txt;
