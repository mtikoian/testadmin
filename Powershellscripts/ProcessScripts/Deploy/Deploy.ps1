Param(
    [string]$releaseEnvironmentName = $null
)

. ..\Deploy\Ref\Iis_Management.ps1
. ..\Deploy\Ref\WinService_Management.ps1
. ..\Shared\Ref\Function_Misc.ps1
. ..\Shared\Ref\MultiThreading.ps1
. ..\Shared\Ref\Version_Management.ps1

function GetErrorDetails()
{
    [string]$errorDetails = $Error[0].Exception
    $errorDetails += GetInnerException($Error[0].Exception.InnerException)

    return $errorDetails
}

function GetInnerException([SystemException]$exception)
{
    [string]$innerException = [string]::Empty

    if($exception -ne $null)
    {
        $innerException += $exception.Message
        $innerException += GetInnerException -exception $exception.InnerException
    }

    return $innerException
}

$componentNames = [PsCustomObject] @{
    DatabaseServer = "databaseServer"
    Executable = "executable"
	Website = "website"
    WebService = "webService"
    WinService = "winService"
}

[int]$secondsToPause = 15

[bool]$isDeploymentSuccessful = $false

#Gets the name of the script and replaces .exetension with .config and .xsd respectively
[string]$scriptName = $MyInvocation.MyCommand.Name
[string]$configFileName = $scriptName -ireplace "\..+$",".config"
[string]$xsdFilePath = $scriptName -ireplace "\..+$",".xsd"

$xmlAddinsPath = (Resolve-Path "..\Deploy\Ref\XmlAddins.dll").Path
$assemblyBytes = [io.file]::ReadAllBytes($xmlAddinsPath)

[System.Reflection.Assembly]::Load($assemblyBytes) | Out-Null

$configFileName = (Resolve-Path $configFileName).Path
$xsdFilePath = (Resolve-Path $xsdFilePath).Path

$validateXml = [XmlAddins.XmlValidator]::ValidateXmlAgainstXsd($configFileName, $xsdFilePath)

if($validateXml.HasWarnings)
{
    Write-Warning $validateXml.WarningMessages
}

if($validateXml.HasErrors)
{
    throw $validateXml.ErrorMessages
}

. ..\Deploy\Ref\Reconfigure.ps1 -deployConfigFilePath $configFileName

[xml]$deploymentConfiguration = Get-Content $configFileName

$environmentNodes = $deploymentConfiguration.SelectNodes("configuration/environments/environment")

if([string]::IsNullOrWhiteSpace($releaseEnvironmentName))
{
    [hashtable]$readHostValues = @{}
    [int]$count = 0

    foreach($environmentNode in $environmentNodes)
    {
        $readHostValues.Add($environmentNode.name, $environmentNode.name)
    }

    $releaseEnvironmentName = ..\Shared\Ref\ReadHostWithAllowedValues.ps1 -message "Please select the release environemnt" -allowedValues $readHostValues
}

$envConfiguration =  $environmentNodes | Where-Object {$_.name -ieq $releaseEnvironmentName}
$packageDirectories = $deploymentConfiguration.SelectNodes("configuration/package/directories")

if($envConfiguration -eq $null)
{
    throw "Environment name '$releaseEnvironmentName'  does not exist in $configFileName file"
}

if($envConfiguration.Count -gt 1)
{
    throw "Duplicate environment nodes exists in config file"
}    

$logFileDirtPath = $envConfiguration.log.dirPath

if([string]::IsNullOrWhiteSpace($logFileDirtPath))
{
    throw "Log file directory path is empty"
}

[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null

$deploymentVersion = $null

$assemblyNode = $deploymentConfiguration.SelectSingleNode("/configuration/package/assembly")

[string]$assemblyRelativePath = $assemblyNode.pathRelativeToScript

if(!(Test-Path -LiteralPath $assemblyRelativePath))
{
    throw "Could not load assembly $assemblyRelativePath"
}

$assemblyFilePath = Resolve-Path -LiteralPath $assemblyRelativePath

$versionNumber = ([Reflection.AssemblyName]::GetAssemblyName($assemblyFilePath)).Version
$versionObject = GetVersionObject -versionNumberText $versionNumber
$deploymentVersion = GetPaddedVersionText -versionObject $versionObject

if([string]::IsNullOrWhiteSpace($deploymentVersion))
{
    throw "Version number does not exist for assembly $(Split-Path $assemblyFilePath -Leaf)"
}

[string]$logFilePath = $logFileDirtPath + "\DeploymentLog_V" + $deploymentVersion.Replace(".","_") + ".txt"

if(!(Test-Path -Path $logFilePath))
{
    New-Item $logFilePath -Type file | Out-Null
}

Start-Transcript -Path $logFilePath -Append

$credential = Get-Credential -Message "Enter domain username and password"

Write-Host
Write-Host "Deployment process started by: $($credential.UserName)"
Write-Host

[PSCustomObject[]]$componentDetails = @()
[string[]]$envDatabaseNames = $null
[string]$primaryDbName = $null


Write-Host "Name of deployment environment: $($envConfiguration.name)"
Write-Host

Write-Host "Application version: $deploymentVersion"
Write-Host
$backupFileName = "BackupBeforeDeployOf_V" + $($deploymentVersion.Replace(".","_"))

foreach($componentXmlNode in $envConfiguration.components.ChildNodes)
{    
    [int]$deployOrder = 0
    [string]$serviceNameFormat = $null

    $deploymentPackageDirectory = $packageDirectories.ChildNodes | Where-Object {$_.name -ieq $componentXmlNode.packageDirName}    
                     
    if($componentXmlNode.LocalName -ieq $componentNames.DatabaseServer)
    {        
        $deployOrder = 1

        foreach($databaseNode in $componentXmlNode.databases.ChildNodes)
        {
            if($envDatabaseNames -eq $null){
                $envDatabaseNames = @()
            }

            if([System.Convert]::ToBoolean($databaseNode.isPrimary))
            {
                $primaryDbName = $databaseNode.name
            }            

            $envDatabaseNames += $databaseNode.name
        }
    }
    elseif($componentXmlNode.LocalName -ieq $componentNames.WinService -or $componentXmlNode.LocalName -ieq $componentNames.WebService)
    {
        $deployOrder = 2      
    }    
    elseif($componentXmlNode.LocalName -ieq $componentNames.Website)
    {
        $deployOrder = 3         
    }
    elseif($componentXmlNode.LocalName -ieq $componentNames.Executable)
    {
        $deployOrder = 4        
    }
    else
    {
        continue
    }

    $componentDetails += [PSCustomObject]@{ 
                            Type = $componentXmlNode.LocalName
                            Name = $componentXmlNode.name
                            Server = $componentXmlNode.server                         
                            DeployDirPath = $componentXmlNode.deployDirPath
                            BackupDirPath = $componentXmlNode.backupDirPath
                            BackupFileName = $backupFileName
                            DeployOrder = $deployOrder
                            DeploymentPackageDirectory = $deploymentPackageDirectory.pathRelativeToScript
                            ReconfigureMapping = (GetReconfigureMapping -xmlComponentNode $componentXmlNode)
                         }                       
}

$componentDetails = $componentDetails | Sort-Object -Property DeployOrder, Server

Write-Host "Component details: "
Write-Host

foreach($component in $componentDetails)
{
    Write-Host "Type `t`t: $($component.Type)"

    if(![string]::IsNullOrWhiteSpace($($component.Name)))
    {
        Write-Host "Name `t`t: $($component.Name)" 
    }

    Write-Host "Server `t`t: $($component.Server)"    

    if(![string]::IsNullOrWhiteSpace($($component.DeployDirPath)))
    {
        Write-Host "DeployDirPath `t: $($component.DeployDirPath)" 
    }

    Write-Host "BackupDirPath `t: $($component.BackupDirPath)"
    Write-Host "BackupFileName `t: $($component.BackupFileName)"
    Write-Host "DeployOrder `t: $($component.DeployOrder)"
    
    if($component.Type -ieq $componentNames.DatabaseServer)
    {
        Write-Host "Database Names `t: $($envDatabaseNames -join ", ")"
    }

    Write-Host
}

Write-Host "Log file name: $logFilePath"
Write-Host

$confirmation = PromptForYesNoValue "Please review above environment details. Do you wish to continue?" -isYesDefaultValue $false
Write-Host

if($confirmation -ieq "N")
{
    Write-warning "Aborting deployment, as user could not confirm the environment details."
    Write-Host
    Stop-Transcript

    return
}

$notifyNode = $envConfiguration.SelectSingleNode("notify")

$emailCredential = Get-Credential -Message "Please enter your email address and password. Example: john.doe@dss.sc.gov"

[string[]]$nonTechAdGroups = @()
[string[]]$nonTechEmails = @()
[string[]]$techAdGroups = @()
[string[]]$techEmails = @()

foreach($childNode in $notifyNode.SelectNodes("*"))
{    
    if($childNode.LocalName -ieq "activeDirGroup")
    {
        if([System.Convert]::ToBoolean($childNode.includeTechDetails))
        {
            $techAdGroups += $childNode.value
        }
        else
        {
            $nonTechAdGroups += $childNode.value
        }
    }
    elseif($childNode.LocalName -ieq "email")
    {
        if([System.Convert]::ToBoolean($childNode.includeTechDetails))
        {
            $techEmails += $childNode.value
        }
        else
        {
            $nonTechEmails += $childNode.value
        }
    }    
}

function SendEmail([string[]]$recipientAdGroups, [string[]]$recipientEmails, [string]$emailSubject = $null, [string]$emailContent = $null, [string[]]$attachments)
{
    ..\Shared\Email_Send.ps1 -emailToAddrs $recipientEmails -emailToAdGroupNames $recipientAdGroups -emailSubject $emailSubject `
        -emailBody $emailContent -myCreds $emailCredential -attachmentFilePaths $attachments
}

[int]$deploymentWaitTime = $envConfiguration.deploymentWaitTimeInSeconds

$siteName = $deploymentConfiguration.configuration.productName + " ($($envConfiguration.name))"

if($deploymentWaitTime -gt 0)
{
    $deploymentTime = (Get-Date).AddSeconds($deploymentWaitTime).ToShortTimeString()
    
    SendEmail -emailSubject "$siteName Software Update Planned At $deploymentTime" `
              -emailContent "$siteName software update will start at $deploymentTime. The site will be unavailable during the update so please save all work and exit before $deploymentTime." `
              -recipientAdGroups ($nonTechAdGroups + $techAdGroups) -recipientEmails ($nonTechEmails + $techEmails)

    DisplayWaitTimeProgressBar -activityMessage "$siteName software update is about to start" -secondsToPause $deploymentWaitTime
}


SendEmail -emailSubject "$siteName Software Update Starting..." `
          -emailContent "$siteName will be down during this time. A follow-up email will be sent when the update is complete." `
          -recipientAdGroups ($nonTechAdGroups + $techAdGroups) -recipientEmails ($nonTechEmails + $techEmails)

[hashtable]$dbBackupMapping = @{}

function GetApplicationInfo([PsCustomObject] $component,[string] $applicationPool)
{
    $applicationInfo = New-Object -TypeName ApplicationServiceInformation $component.Server, $applicationPool, $envConfiguration.msDeployDirPath
	return $applicationInfo
}

function StartServicesAndWebsites([ConsoleColor]$foregroundColor)
{
    Write-Host "-------------------------- BEGINING START SERVICE(S) ------------------------------" -ForegroundColor $foregroundColor
    Write-Host

    $serviceComponents = $componentDetails | Where-Object { $_.Type -ieq $componentNames.WinService -or $_.Type -ieq $componentNames.WebService }

    foreach($serviceComponent in $serviceComponents)
    {
        $application = GetApplicationInfo -component $serviceComponent -applicationPool $serviceComponent.Name
        StartApplication -applicationInfo $application -credential $credential
        Write-Host
    }     

    Write-Host "-------------------------- COMPLETED START SERVICE(S) ------------------------------" -ForegroundColor $foregroundColor
    Write-Host

    Start-Sleep -Seconds $secondsToPause
    
    Write-Host "-------------------------- BEGINING START WEBSITE(S) ------------------------------" -ForegroundColor $foregroundColor
    Write-Host
    
    $websiteComponents = $componentDetails | Where-Object { $_.Type -ieq $componentNames.Website }

    foreach($websiteComponent in $websiteComponents)
    {
        $application = GetApplicationInfo -component $websiteComponent -applicationPool $websiteComponent.Name
        StartApplication -applicationInfo $application -credential $credential        
        Write-Host
    }

    Write-Host "-------------------------- COMPLETED START WEBSITE(S) ------------------------------" -ForegroundColor $foregroundColor    
}

try
{ 
    Write-Host "-------------------------- BEGINING STOP WEBSITE(S) ------------------------------" -ForegroundColor Cyan
    Write-Host

    $websiteComponents = $componentDetails | Where-Object { $_.Type -ieq $componentNames.Website }

    foreach($websiteComponent in $websiteComponents)
    {
        $application = GetApplicationInfo -component $websiteComponent -applicationPool $websiteComponent.Name
        StopApplication -applicationInfo $application -credential $credential        
        Write-Host
    }

    Write-Host "-------------------------- COMPLETED STOP WEBSITE(S) ------------------------------" -ForegroundColor Cyan
    Write-Host

    Start-Sleep -Seconds $secondsToPause
    
    Write-Host "-------------------------- BEGINING STOP SERVICE(S) ------------------------------" -ForegroundColor Cyan
    Write-Host

    $serviceComponents = $componentDetails | Where-Object { $_.Type -ieq $componentNames.WinService -or $_.Type -ieq $componentNames.WebService}

    foreach($serviceComponent in $serviceComponents)
    {
        $application = GetApplicationInfo -component $serviceComponent -applicationPool $serviceComponent.Name
        StopApplication -applicationInfo $application -credential $credential
        Write-Host
    }     

    Write-Host "-------------------------- COMPLETED STOP SERVICE(S) ------------------------------" -ForegroundColor Cyan
    Write-Host
    
    #region Backup
    try
    {
        Write-Host "------------------------- BEGINING PRE-DEPLOYMENT BACKUP -------------------------" -ForegroundColor Cyan
        Write-Host

        foreach($component in $componentDetails)
        {
            [string]$writeHostPrefix = $component.Server + ":" + $component.Name + " ->"

            if($component.Type -ieq $componentNames.DatabaseServer)
            {
                $writeHostPrefix = $component.Server + "\" + $component.Name + ":{0} ->"
                [System.Diagnostics.Process[]]$databaseBackupProcesses = @()    

                Write-Host "$($writeHostPrefix -f ($envDatabaseNames -join ",")) Starting pre-deployment backup of databases"
                Write-Host

                foreach($databaseName in $envDatabaseNames)
                {
                    [string]$backupFilePath = $component.BackupDirPath + "\" + $component.BackupFileName + "__$databaseName.bak" 
                           
                    $dbBackupMapping.Add($databaseName, $backupFilePath)                

                    [string]$serverName = "$($component.Server)\$($component.Name)"

                    $databaseBackupProcesses += StartPowershellAsync -scriptFilePath "..\Shared\Database_Backup.ps1" -arguments "-backupDbName $databaseName -serverName $serverName -backupFilePath $backupFilePath"
                }
    
                if($databaseBackupProcesses.Length -gt 0)
                {
                    WaitForExecution -processes $databaseBackupProcesses              
                }    
            
                Write-Host

                foreach($databaseName in $dbBackupMapping.Keys)
                {
                    Write-Host "$($writeHostPrefix -f $databaseName) Pre-deployment database backup: $($dbBackupMapping[$databaseName])"
                }

                Write-Host
                Write-Host "$($writeHostPrefix -f ($envDatabaseNames -join ",")) Pre-deployment backup of databases completed"
                Write-Host
            }
            else
            {
                $component.BackupFileName +=".zip"
                $deployDirPath = $component.DeployDirPath
                $backupFilePath = $component.BackupDirPath + "\" + $component.BackupFileName

                if(Test-Path $deployDirPath)
                {   
                    Write-Host "$writeHostPrefix Starting pre-deployment backup of $($component.Type) to: $backupFilePath"    

                    if(Test-Path $backupFilePath)
                    {
                        Remove-Item $backupFilePath
                    }
                                
                    $compressionLevel = [System.IO.Compression.CompressionLevel]::Fastest
                    [bool]$includeBaseFolder = $false
                    
                    [System.IO.Compression.ZipFile]::CreateFromDirectory($deployDirPath, $backupFilePath, $compressionLevel, $includeBaseFolder);

                    Write-Host "$writeHostPrefix Pre-deployment backup of $($component.Type) completed"
                    Write-Host               
                }            
            }
        }

        Write-Host "---------------------------- COMPLETED PRE-DEPLOYMENT BACKUP ----------------------------" -ForegroundColor Cyan
        Write-Host
    }
    catch
    {
        Write-Host
        Write-Warning "Error occurred during backup"
        Write-Host $(GetErrorDetails) -ForegroundColor Yellow
        Write-Host
        Write-Host "--------------- BEGINING DELETE PRE-DEPLOYMENT BACKUP FILES ---------------" -ForegroundColor Red
    
        Write-Host

        foreach($component in $componentDetails)
        {
            [string]$writeHostPrefix = $component.Server + ":" + $component.Name + " ->"

            if($component.Type -ieq $componentNames.DatabaseServer)
            {
                $writeHostPrefix = $component.Server + "\" + $component.Name + ":{0} ->"

                Write-Host "$($writeHostPrefix -f ($envDatabaseNames -join ",")) Deleting database backup files"

                foreach($databaseName in $dbBackupMapping.Keys)
                {
                    $backupFilePath = $dbBackupMapping[$databaseName]

                    if(Test-Path $backupFilePath)
                    {
                        Remove-Item $backupFilePath -Force
                        Write-Host "$($writeHostPrefix -f $databaseName) Deleted pre-deployment backup file: $backupFilePath"
                    }
                }

                Write-Host "$($writeHostPrefix -f ($envDatabaseNames -join ",")) Database backup files deleted"
            }
            else
            {
                $backupFilepath = $component.BackupDirPath + "\" + $component.BackupFileName
            
                if(Test-Path $backupFilePath)
                {
                     Remove-Item $backupFilePath -Force
                     Write-Host "$writeHostPrefix Deleted pre-deployment backup file: $backupFilePath"
                }
            }
        }
    
        Write-Host
        Write-Host "--------------- COMPLETED DELETE PRE-DEPLOYMENT BACKUP FILES ---------------" -ForegroundColor Red
        Write-Host        
        Write-Host
            
        throw  
    }
    
    #endregion  

    #region Deploy Code  
     
    try
    {
        Write-Host "-------------------------------- BEGINING DEPLOYMENT -------------------------------" -ForegroundColor Green
        Write-Host

        $databaseComponent = $componentDetails | Where-Object {$_.Type -ieq $componentNames.DatabaseServer}

        RecordInstallStart -databaseNames $envDatabaseNames -serverName $databaseComponent.Server -instanceName $databaseComponent.Name -versionNumber $deploymentVersion 

        foreach($component in $componentDetails)
        {        
            [string]$writeHostPrefix = $component.Server + ":" + $component.Name + " ->"        

            if($component.Type -ieq $componentNames.DatabaseServer)
            {
                $writeHostPrefix = $writeHostPrefix.Replace(":", "\")

                Write-Host "$writeHostPrefix Deploying database scripts"      
                Write-Host      

                ..\Shared\Database_ExecuteUpdateScripts.ps1 -versionNumber $deploymentVersion -serverName $component.Server -dbInstanceName $component.Name `
                    -primaryDbName $primaryDbName -isDbBackedUp $true -dbDeployScriptPath $(Resolve-Path "..\Database").Path
            
                Write-Host
                Write-Host "$writeHostPrefix Database deployment completed"            
            }
            elseif($component.Type -ieq $componentNames.WinService -or $component.Type -ieq $componentNames.Website -or $component.Type -ieq $componentNames.Executable `
                    -or $component.Type -ieq $componentNames.WebService)
            {
                Write-Host "$writeHostPrefix Deploying code"
                
                $destination = $component.DeployDirPath
                $source = $component.DeploymentPackageDirectory

                Write-Host "$writeHostPrefix Deleting existing files in $destination directory."
            
                Remove-Item "$destination\*" -Recurse -Force
            
                Write-Host "$writeHostPrefix Deleted files."       

                Write-Host "$writeHostPrefix Copying files from $source to $destination"

                Copy-Item "$source\*" -Destination $destination -Recurse 

                Write-Host "$writeHostPrefix Copying files completed"
                
                Write-Host "$writeHostPrefix Deploying code completed"                                        
            }
            else
            {
                throw "Invalid component type specified in Deploy.config"
            }     

            Write-Host
            Write-Host "$writeHostPrefix Reconfiguring files"

            if($component.ReconfigureMapping.Count -gt 0)
            {
                ReconfigureComponent -reconfigureMapping $component.ReconfigureMapping       
            }
            else
            {
                Write-Host "$writeHostPrefix No files to reconfigure "
            }
            
            Write-Host "$writeHostPrefix Reconfiguring files completed"
        }   

        StartServicesAndWebsites -foregroundColor Green
        Write-Host 
            
        RecordInstallEnd -databaseNames $envDatabaseNames -serverName $databaseComponent.Server -instanceName $databaseComponent.Name -versionNumber $deploymentVersion        
        
        $isDeploymentSuccessful = $true     
            
        Write-Host
        Write-Host "------------------------------- COMPLETED DEPLOYMENT --------------------------------" -ForegroundColor Green
        Write-Host      
    }
    catch
    {        
        Write-Warning "Error occurred while deploying"

        Write-Host $(GetErrorDetails) -ForegroundColor Yellow

        Write-Host

        Write-Host "----------------------- BEGINING RESTORE TO PREVIOUS VERSION -----------------------" -ForegroundColor Red
        Write-Host
        
        foreach($component in $componentDetails)
        {
            [string]$writeHostPrefix = $component.Server + ":" + $component.Name + " ->"

            if($component.Type -ieq $componentNames.DatabaseServer)
            {
                $writeHostPrefix = $writeHostPrefix.Replace(":", "\")

                Write-Host "$writeHostPrefix Restoring databases..."            

                [System.Diagnostics.Process[]]$restoreProcesses = @()

                $serverName = "$($component.Server)\$($component.Name)"
    
                foreach($databaseBackupFilePath in $dbBackupMapping.Values)
                {
                    $restoreProcesses += StartPowershellAsync -scriptFilePath "..\Shared\Database_Restore.ps1" -arguments "-serverName $serverName -backupFilePath $databaseBackupFilePath -deleteBackupFile `$false -confirmOverwrite `$false"
                }

                if($restoreProcesses.Length -gt 0)
                {
                    WaitForExecution -processes $restoreProcesses
                }

                Write-Host "$writeHostPrefix Database restore completed."
            }
            else
            {
                [string]$backupFilePath = $component.BackupDirPath + "\" + $component.BackupFileName
            
                if(Test-Path $backupFilePath)
                {
                    Write-Host "$writeHostPrefix Restoring code for $($component.Type) on $($component.Server)"

                    if(Test-Path $($component.DeployDirPath))
                    {
                        remove-item $($component.DeployDirPath) -Recurse -Force
                    }

                    [System.IO.Compression.ZipFile]::ExtractToDirectory($backupFilePath, $($component.DeployDirPath));

                    Write-Host "$writeHostPrefix Restoring code complete."
                    Write-Host
                }
            }
        }
        
        Write-Host "----------------------- COMPLETED RESTORE TO PREVIOUS VERSION ----------------------" -ForegroundColor Red
        Write-Host
        
        throw  
    }
    #endregion
}
catch
{
    Write-Host
    Write-Warning "Error Occurred during deployment"
    #writing to host so that error appears in transcript
	Write-Host  $(GetErrorDetails) -ForegroundColor Yellow  

    StartServicesAndWebsites -foregroundColor Red
    
    Write-Host
   
    throw 
}
finally
{   
    Write-Host
    Stop-Transcript

    [string]$emailSubject = $null
    [string]$emailContent = $null

    if($isDeploymentSuccessful)
    {
        $emailSubject = "$siteName Software Update Complete"
        $emailContent = "$siteName software update is complete. You may resume use of the site."
    }
    else
    {        
        $emailSubject = "$siteName Software Update Failed"
        $emailContent = "$siteName software update failed. The software has been rolled back to the previous version. You may resume use of the site."
    }

    if($nonTechAdGroups.Length -gt 0 -or $nonTechEmails.Length -gt 0){
        SendEmail -emailSubject $emailSubject -emailContent $emailContent -recipientAdGroups $nonTechAdGroups -recipientEmails $nonTechEmails
    }
    
    if($techAdGroups.Length -gt 0 -or $techEmails.Length -gt 0 ){
        SendEmail -emailSubject $emailSubject -emailContent $emailContent -recipientAdGroups $techAdGroups -recipientEmails $techEmails `
                  -attachments $logFilePath
    }
    Write-Host "------------------------------ DEPLOYMENT PROCESS COMPLETE ----------------------------------"
}