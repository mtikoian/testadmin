. ..\Shared\Ref\MultiThreading.ps1
try {   # Wrap in a try-catch in case we try to add this type twice.
# Create a class to hold an IIS Application Service's Information.
Add-Type -TypeDefinition @"
    using System;
     
    public class ApplicationServiceInformation
    {
        public string ComputerName { get; set; }

        public string ApplicationPool { get; set;}
         
        public string MsDeployDirPath {get;set;} 
 
        // Implicit Constructor.
        public ApplicationServiceInformation() { }
 
        // Explicit constructor.
        public ApplicationServiceInformation(string computerName, string applicationPool, string msDeployDirPath)
        {
            this.ComputerName = computerName;
            this.MsDeployDirPath = msDeployDirPath;
            this.ApplicationPool = applicationPool;
        }
    }
"@
} catch {}

$Script:stopWebAppPool = {
    Import-Module WebAdministration
    $webAppPoolName = "{webAppPool}" 
    $state = Get-WebAppPoolState $webAppPoolName

    [string]$writeHostPrefix = "$($env:COMPUTERNAME):$($webAppPoolName) ->"

    Write-Host "$writeHostPrefix Stopping Application Pool"

    if($state.Value -ieq "started")
    {
        Stop-WebAppPool $webAppPoolName
        Write-Host "$writeHostPrefix Application pool stopped"
    }
    else
    {
        Write-Host "$writeHostPrefix Application pool already stopped"
    }

}

$Script:startWebAppPool = {
    Import-Module WebAdministration
    $webAppPoolName = "{webAppPool}" 
    $state = Get-WebAppPoolState $webAppPoolName

    [string]$writeHostPrefix = "$($env:COMPUTERNAME):$($webAppPoolName) ->"

    Write-Host "$writeHostPrefix Starting Application Pool"

    if($state.Value -ieq "stopped")
    {
        Start-WebAppPool $webAppPoolName
        Write-Host "$writeHostPrefix Application pool started"
    }
    else
    {
        Write-Host "$writeHostPrefix Application pool already started"
    }

}

$Script:stopWebsite = {
    Import-Module WebAdministration
    $websiteName = "{websiteName}" 
    $state = Get-WebsiteState $websiteName

    [string]$writeHostPrefix = "$($env:COMPUTERNAME):$($websiteName) ->"

    Write-Host "$writeHostPrefix Stopping Website"

    if($state.Value -ieq "started")
    {
        Stop-Website $websiteName
        Write-Host "$writeHostPrefix Website stopped"
    }
    else
    {
        Write-Host "$writeHostPrefix Website already stopped"
    }

}

$Script:startWebsite = {
    Import-Module WebAdministration
    $websiteName = "{websiteName}" 
    $state = Get-WebsiteState $websiteName

    [string]$writeHostPrefix = "$($env:COMPUTERNAME):$($webAppPoolName) ->"

    Write-Host "$writeHostPrefix Starting Website"

    if($state.Value -ieq "stopped")
    {
        Start-Website $websiteName
        Write-Host "$writeHostPrefix Website started"
    }
    else
    {
        Write-Host "$writeHostPrefix Website already started"
    }

}

function StartWebsite([Parameter(Mandatory=$true)][string]$computerName, [Parameter(Mandatory=$true)][PSCredential]$credential, [Parameter(Mandatory=$true)][string]$websiteName)
{
    [ScriptBlock]$script = [ScriptBlock]::Create($Script:startWebAppPool.ToString().Replace("{webAppPool}",$websiteName)  `
                                            + $Script:startWebsite.ToString().Replace("{websiteName}",$websiteName))

    Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $script
}

function StopWebsite([Parameter(Mandatory=$true)][string]$computerName, [Parameter(Mandatory=$true)][PSCredential]$credential, [Parameter(Mandatory=$true)][string]$websiteName)
{
    [ScriptBlock]$script = [ScriptBlock]::Create( $Script:stopWebsite.ToString().Replace("{websiteName}",$websiteName) `
                                            + $Script:stopWebAppPool.ToString().Replace("{webAppPool}",$websiteName))

    Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $script
}

function StartApplicationPool([Parameter(Mandatory=$true)][string]$computerName, [Parameter(Mandatory=$true)][PSCredential]$credential, [Parameter(Mandatory=$true)][string]$applicationPool)
{
    [ScriptBlock]$script = [ScriptBlock]::Create($Script:startWebAppPool.ToString().Replace("{webAppPool}",$applicationPool))

    Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $script
}

function StopApplicationPool([Parameter(Mandatory=$true)][string]$computerName, [Parameter(Mandatory=$true)][PSCredential]$credential, [Parameter(Mandatory=$true)][string]$applicationPool)
{
    [ScriptBlock]$script = [ScriptBlock]::Create($Script:stopWebAppPool.ToString().Replace("{webAppPool}",$applicationPool))

    Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock $script
}

function StartApplication([Parameter(Mandatory=$true)][ApplicationServiceInformation]$applicationInfo, [Parameter(Mandatory=$true)][PSCredential]$credential)
{
    $password = $credential.GetNetworkCredential().Password     
    Write-Host $($applicationInfo.ComputerName):$($applicationInfo.ApplicationPool) "-> Starting Application"
    $process = StartExecutionAsync -exeName "$($applicationInfo.MsDeployDirPath)\msdeploy.exe" -exeArguments "-verb:Sync -source:recycleApp -dest:recycleApp=`"$($applicationInfo.ApplicationPool)`",wmsvc=$($applicationInfo.ComputerName),userName=$($credential.UserName),Password=$password,recycleMode=`"StartAppPool`" -allowUntrusted"
    WaitForExecution -processes $process    
    Write-Host $($applicationInfo.ComputerName):$($applicationInfo.ApplicationPool) "-> Application Started"
}

function StopApplication([Parameter(Mandatory=$true)][ApplicationServiceInformation]$applicationInfo, [Parameter(Mandatory=$true)][PSCredential]$credential)
{
    $password = $credential.GetNetworkCredential().Password     
    Write-Host $($applicationInfo.ComputerName):$($applicationInfo.ApplicationPool) "-> Stopping Application"
    $process = StartExecutionAsync -exeName "$($applicationInfo.MsDeployDirPath)\msdeploy.exe" -exeArguments "-verb:Sync -source:recycleApp -dest:recycleApp=`"$($applicationInfo.ApplicationPool)`",wmsvc=$($applicationInfo.ComputerName),userName=$($credential.UserName),Password=$password,recycleMode=`"StopAppPool`" -allowUntrusted"
    WaitForExecution -processes $process
    Write-Host $($applicationInfo.ComputerName):$($applicationInfo.ApplicationPool) "-> Application stopped"
}