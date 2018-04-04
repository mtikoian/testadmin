[Cmdletbinding()]
param
(
	[Parameter(mandatory=$true)]
	$BackupFilePath,
	[Parameter(mandatory=$true)]
	$PostRestoreScriptPath,
	[Parameter(mandatory=$true)]
	$ServerName,
  [Parameter(mandatory=$false)]
  $WarningDays = 3
)

$ErrorActionPreference = "Stop"

try
{

  Import-Module SQLServer
  Import-Module adoLib
  Import-Module sqlbackuphelper
  
  $hadWarnings = $false
  
  # Instantiate process object
  $sqlcmdProcess = New-Object System.Diagnostics.Process;
  $sqlcmdProcess.StartInfo.FileName = "sqlcmd.exe";
  $sqlcmdProcess.StartInfo.UseShellExecute = $false;
  $sqlcmdProcess.StartInfo.RedirectStandardError = $true;
  $sqlcmdProcess.StartInfo.RedirectStandardOutput = $true;
  $sqlcmdProcess.StartInfo.WorkingDirectory = $scriptPath;
  
  $filesToProcess = Get-ChildItem "$BackupFilePath\*.bak*" -Exclude "*IT_MASTER*"
  $postRestoreScripts = Get-ChildItem $PostRestoreScriptPath
  
  foreach ($fileToProcess in $filesToProcess)
  {
    try
    {
      Write-Host "Restoring backup $($fileToProcess.FullName)`n"
      $backupInfo = Get-SqlBackupInfo -FullName $fileToProcess.FullName -ServerName $ServerName
      if ([DateTime]$backupInfo.BackupFinishDate.ToShortDateString() -le [DateTime]::Today.AddDays(-3))
      {
        Write-Warning "Backup file $($fileToProcess.FullName) contains outdated backup data ($($backupInfo.BackupFinishDate)) and will be skipped."
      }
      else
      {
        $restoreOut = $backupInfo | Restore-SqlDatabase -Replace -SingleUser -GenerateNewFileName
        Write-Host "File $($fileToProcess.FullName) restored to database $($restoreOut.DatabaseName).`n"
  
        Write-Host "Executing post restore scripts on database $($restoreOut.DatabaseName).`n"
        foreach ($PostRestoreScript in $postRestoreScripts)
        {
          Write-Host "Executing script $($PostRestoreScript.Name)"
          $sqlcmdProcess.StartInfo.Arguments = "-i `"$($PostRestoreScript.FullName)`" -b -S $ServerName -E -d $($restoreOut.DatabaseName) -v DatabaseName=`"$($restoreOut.DatabaseName)`""
          $sqlcmdProcess.Start() | Out-Null
          $sqlcmdProcess.WaitForExit();
          Write-Host $sqlcmdProcess.StandardOutput.ReadToEnd()
          if ($sqlCmdProcess.ExitCode -ne 0) 
          {
            Throw "Error occurred executing post restore script on database $($restoreOut.Databasename): $($sqlCmdProcess.StandardError.ReadToEnd())`n"
          }
        }
      }
      Write-Host "Moving file $($fileToProcess.FullName) to 'Processed' folder."
      Move-Item "$($fileToProcess.FullName)" "$BackupFilePath\Processed\$($fileToProcess.Name)"
    }
    catch
    {
      Write-Warning "Error processing file $($fileToProcess.FullName)."
      Write-Warning $_.Exception.Message
      $hadWarnings = $true
    }
  }
  
  if ($hadWarnings)
  {
    throw 'Error occurred during script execution.'
  }
}
catch
{
  Write-Warning $_.Exception.Message
  Exit 1
}