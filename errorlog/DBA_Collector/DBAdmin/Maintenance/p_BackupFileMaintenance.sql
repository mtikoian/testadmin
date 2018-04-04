USE master;
GO

IF OBJECT_ID('dbo.p_BackupFileMaintenance') IS NULL
  EXEC('CREATE PROCEDURE dbo.p_BackupFileMaintenance AS BEGIN PRINT ''STUB FOR REPLACEMENT'' END');
GO

ALTER PROCEDURE dbo.p_BackupFileMaintenance
  @pi_archive_warning_days TINYINT = 1,
  @pi_delete_file_days TINYINT = 7,
  @pi_backup_type NVARCHAR(4)
AS
SET NOCOUNT ON;

DECLARE @cmd_text NVARCHAR(4000),
        @cmd_return TINYINT,
        @default_backup_dir NVARCHAR(256),
        @reg_key NVARCHAR(256),
        @email_subject NVARCHAR(256),
        @email_body NVARCHAR(4000),
        @archive_warning_days TINYINT,
        @delete_file_days TINYINT,
        @error_message NVARCHAR(4000);
DECLARE @cmd_output TABLE (file_name NVARCHAR(1000));

SET @archive_warning_days = @pi_archive_warning_days;
SET @delete_file_days = @pi_delete_file_days;
                
SELECT @reg_key = 'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\';
EXEC master.sys.xp_instance_regread @rootkey = 'HKEY_LOCAL_MACHINE', @key = @reg_key, @value_name = 'BackupDirectory', @value = @default_backup_dir OUTPUT;
SET @default_backup_dir = REPLACE(REPLACE(@default_backup_dir,'\','\\'),'$','`$');

BEGIN -- Search for unarchived files
  SET @cmd_text = 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -Command "try{' +
                  '$files = Get-ChildItem -Recurse -Path \"' + @default_backup_dir + '\" -Include \"*' + @pi_backup_type + '*.bak\" ' + 
                    '| Where {($_.Attributes -like \"*Archive*\") -and ($_.CreationTime -le [System.DateTime]::Now.AddDays(-' + CAST(@archive_warning_days AS NVARCHAR(2)) + '))};' +
                  'if ($files.Count -gt 0) {$files | %{Write-Host $_.CreationTime `| $_.FullName}};' +
                  '} catch [System.Exception] { Write-Error $Error[0].Exception.ToString(); Exit 1;}"';

  --PRINT @cmd_text;
  
  INSERT @cmd_output
  EXEC @cmd_return = xp_cmdshell @cmd_text;

  IF @cmd_return <> 0 BEGIN
  
    SET @error_message = 'ERROR: Command to find unarchived files returned a non zero exit. Command output:' +
                         CHAR(10) +
                         (SELECT file_name + CHAR(10) FROM @cmd_output FOR XML PATH(''));
    RAISERROR(@error_message,16,1) WITH NOWAIT;
  
  END
  
  IF EXISTS (SELECT 1 FROM @cmd_output WHERE file_name IS NOT NULL) BEGIN
    SET @email_subject = 'WARNING: Files Not Archived On Server ' + CONVERT(NVARCHAR(256),SERVERPROPERTY('ServerName'));
    SET @email_body = 'The following files were detected that have not been archived and are older than the cutoff period:' +
                      CHAR(10) +
                      (SELECT file_name + CHAR(10) FROM @cmd_output FOR XML PATH(''));
    EXEC msdb.dbo.sp_notify_operator @profile_name = 'EDEV_DBA_Profile', @name = 'EDEV_DBA', @subject = @email_subject, @body = @email_body;
  END
  ELSE BEGIN
    SET @error_message = 'Check for un-archived files succeeded. None were found.';
    RAISERROR(@error_message,10,1) WITH NOWAIT;
  END
  
END

DELETE FROM @cmd_output;

BEGIN -- Deletion of archived files

  SET @cmd_text = 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -Command "try{' +
                  '$files = Get-ChildItem -Recurse -Path "' + @default_backup_dir + '" -Include "*' + @pi_backup_type + '*.bak" ' +
                    '| Where {$_.Attributes -notlike \"*Archive*\"};' +
                  'if (($files.Count -gt 0) -or ($files -ne $null)) {$files | %{Write-Host \"Deleting file \" $_.FullName; $_.Delete();}};' +
                  '} catch [System.Exception] {Write-Error $Error[0].Exception.ToString();Exit 1;}'
  
  --print @cmd_text;
  
  INSERT @cmd_output
  EXEC @cmd_return = xp_cmdshell @cmd_text;
  
  IF @cmd_return <> 0 BEGIN
  
    SET @error_message = 'ERROR: Command to delete archived files returned a non zero exit. Command output:' +
                         CHAR(10) +
                         REPLACE((SELECT file_name + CHAR(10) FROM @cmd_output FOR XML PATH('')),'%','%%');
    RAISERROR(@error_message,16,1) WITH NOWAIT;
  
  END
  ELSE BEGIN
  
    IF EXISTS(SELECT 1 FROM @cmd_output WHERE file_name IS NOT NULL) BEGIN
      SET @error_message = 'Command to delete archived files succeeded. Command output:' +
                           CHAR(10) +
                           REPLACE((SELECT file_name + CHAR(10) FROM @cmd_output FOR XML PATH('')),'%','%%');
      RAISERROR(@error_message,10,1) WITH NOWAIT;
    END
    ELSE BEGIN
      SET @error_message = 'Command to delete archived files succeeded. No files were deleted.';
      RAISERROR(@error_message,10,1) WITH NOWAIT;
    END
    
  END

END

DELETE FROM @cmd_output;

BEGIN -- Deletion of non-archived, older files

  SET @cmd_text = 'C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -Command "try{' +
                  '$files = Get-ChildItem -Recurse -Path "' + @default_backup_dir + '" -Include "*' + @pi_backup_type + '*.bak" ' +
                    '| Where {$_.CreationTime -le [System.DateTime]::Now.AddDays(-' + CAST(@delete_file_days AS NVARCHAR(2)) + ')};' +
                  'if ($files.Count -gt 0) {$files | %{Write-Host \"Deleting file \" $_.FullName; $_.Delete();}};' +
                  '} catch [System.Exception] {Write-Error $Error[0].Exception.ToString();Exit 1;}'
  
  --print @cmd_text;
  
  INSERT @cmd_output
  EXEC @cmd_return = xp_cmdshell @cmd_text;
  
  IF @cmd_return <> 0 BEGIN
  
    SET @error_message = 'ERROR: Command to delete old (un-archived) files returned a non zero exit. Command output:' +
                         CHAR(10) +
                         REPLACE((SELECT file_name + CHAR(10) FROM @cmd_output FOR XML PATH('')),'%','%%');
    RAISERROR(@error_message,16,1) WITH NOWAIT;
  
  END
  ELSE BEGIN
  
    IF EXISTS(SELECT 1 FROM @cmd_output WHERE file_name IS NOT NULL) BEGIN
      SET @error_message = 'Command to delete old (un-archived) files succeeded. Command output:' +
                           CHAR(10) +
                           REPLACE((SELECT file_name + CHAR(10) FROM @cmd_output FOR XML PATH('')),'%','%%');
      RAISERROR(@error_message,10,1) WITH NOWAIT;
    END
    ELSE BEGIN
      SET @error_message = 'Command to delete old (un-archived) files succeeded. No files were deleted.';
      RAISERROR(@error_message,10,1) WITH NOWAIT;
    END
    
  END

END