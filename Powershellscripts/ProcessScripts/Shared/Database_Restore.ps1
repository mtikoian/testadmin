param
(       
    [Parameter(Mandatory=$true)]
    [string]$serverName,
    
    [Parameter(Mandatory=$true)]
    [string]$backupFilePath,

    [bool]$deleteBackupFile = $true,
    
    [string]$databaseName = $null,    

    [string]$ldfPhysicalFilePath = $null,

    [string]$mdfPhysicalFilePath = $null,

    [bool]$confirmOverwrite = $true
)

. ..\Shared\Ref\Function_Misc.ps1

function DeleteBackupFile() 
{
    if($deleteBackupFile)
    {
        Write-Host "Deleting $backupFilePath"
        Remove-Item $backupFilePath
        Write-Host "$backupFilePath deleted"
        Write-Host
    }
}

try
{
    if([string]::IsNullOrWhiteSpace($ldfPhysicalFilePath) -and ![string]::IsNullOrWhiteSpace($mdfPhysicalFilePath))
    {
        Throw "ldf physical path should be provided"
    }
    elseif(![string]::IsNullOrWhiteSpace($ldfPhysicalFilePath) -and [string]::IsNullOrWhiteSpace($mdfPhysicalFilePath))
    {
        Throw "mdf physical path should be provided"
    }
    elseif(![string]::IsNullOrWhiteSpace($ldfPhysicalFilePath) -and ![string]::IsNullOrWhiteSpace($mdfPhysicalFilePath) -and [string]::IsNullOrWhiteSpace($databaseName))
    {
        Throw "Database name should not be empty when ldf and mdf files are provided"
    }         
    
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null

    [Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $serverName
    [Microsoft.SqlServer.Management.Smo.BackupDeviceItem]$smoBackupDevice = New-Object -TypeName Microsoft.SqlServer.Management.Smo.BackupDeviceItem $backupFilePath, "File"

    [Microsoft.SqlServer.Management.Smo.Restore]$smoRestore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore
    $smoRestore.FileNumber = 1
    $smoRestore.Action = [Microsoft.SqlServer.Management.Smo.RestoreActionType]::Database
    $smoRestore.PercentCompleteNotification = 10
    $smoRestore.Devices.Add($smoBackupDevice)

    if([string]::IsNullOrWhiteSpace($databaseName))
    {
        $header = $smoRestore.ReadBackupHeader($smoServer)
        if($header.Rows.Count -ge 1)
        {
            $databaseName = $header.Rows[0]["DatabaseName"]
        }
    }

    if([string]::IsNullOrWhiteSpace($databaseName))
    {
        throw "Database name could not be retrieved from backup file: $backupFilePath"
    }

    $smoServer.KillAllprocesses($databaseName)

    $existingDbNames = $smoServer.Databases | Select-Object -ExpandProperty Name
    $dbNameRegex = [regex]::Escape($databaseName)

    if ($confirmOverwrite -and $existingDbNames -imatch $dbNameRegex) 
    { 
        Write-Host "$databaseName database already exists in $serverName"

        [string]$continue = PromptForYesNoValue -displayMessage "Do you want to overwrite $databaseName database?"
    
        if ($continue -ieq "Y") 
        {
            Write-Host
            Write-Host "$databaseName database will be restored to the current state of the backup."
            Write-Host
        }
        else 
        {
            Write-Host        
            Write-Warning "Terminating restore process for $databaseName database."
            return
        }
    }    

    $smoRestore.Database = $databaseName
    $smoRestore.NoRecovery = $false
    $smoRestore.ReplaceDatabase = $true     

    if(![string]::IsNullOrWhiteSpace($ldfPhysicalFilePath) -and ![string]::IsNullOrWhiteSpace($mdfPhysicalFilePath))
    {
        $restoreFileList = $null
        try
        {
            $restoreFileList = $smoRestore.ReadFileList($smoServer)
        }
        catch
        {
            throw "Restore file details could not be found from the backup file. $($_.Exception.GetBaseException().Message)"
        }

        [string]$dataFileLogicalName = $null
        [string]$logFileLogicalName = $null

        foreach($restoreFile in $restoreFileList)
        {
	        $restoreFileType = $restoreFile["Type"]
	
	        if ($restoreFileType -ieq "D") {
		        $dataFileLogicalName = $restoreFile["LogicalName"]
	        }
	        elseif ($restoreFileType -ieq "L") {
		        $logFileLogicalName = $restoreFile["LogicalName"]	
	        }
        }

        if ([string]::IsNullOrWhiteSpace($dataFileLogicalName)) 
        {
            throw "Restore data file logical name not found."
        }
        elseif ([string]::IsNullOrWhiteSpace($logFileLogicalName)) 
        {
            throw "Restore log file logical name not found."
        }

        [Microsoft.SqlServer.Management.Smo.RelocateFile]$smoRestoreDataFile = New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile
        $smoRestoreDataFile.LogicalFileName = $dataFileLogicalName
        $smoRestoreDataFile.PhysicalFileName = $mdfPhysicalFilePath

        [Microsoft.SqlServer.Management.Smo.RelocateFile]$smoRestoreLogFile = New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile
        $smoRestoreLogFile.LogicalFileName = $logFileLogicalName
        $smoRestoreLogFile.PhysicalFileName = $ldfPhysicalFilePath

        #Actually registers the desired file targets for the restore
        $smoRestore.RelocateFiles.Add($smoRestoreDataFile) | Out-Null
        $smoRestore.RelocateFiles.Add($smoRestoreLogFile) | Out-Null
    }

    Write-Host "Attempting to restore $databaseName from $backupFilePath"

    $percentRestoreEventHandler = [Microsoft.SqlServer.Management.Smo.PercentCompleteEventHandler] { Write-Host "Restored" $smoRestore.Database $_.Percent "%" }
    $completedRestoreEventHandler = [Microsoft.SqlServer.Management.Common.ServerMessageEventHandler] { Write-Host "Database" $smoRestore.Database "restored successfully!" }

    try
    {
        $smoRestore.add_PercentComplete($percentRestoreEventHandler)
        $smoRestore.add_Complete($completedRestoreEventHandler)
        $smoRestore.SqlRestore($smoServer)
        Write-Host
    }
    catch{
        throw "The database restore failed. $($_.Exception.GetBaseException().Message)"
    }
    finally
    {
        $smoRestore.remove_PercentComplete($percentRestoreEventHandler)
        $smoRestore.remove_Complete($completedRestoreEventHandler)
    }
}
catch{
    Throw $Error[0]
}
finally{
    DeleteBackupFile
}
Write-Host "$databaseName database has been restored."