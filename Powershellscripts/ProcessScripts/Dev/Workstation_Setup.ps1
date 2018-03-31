. ..\Dev\Ref\DevConfigData.ps1

$restartExplorer = $false

#region Powershell version

[string]$psVersion = $Host.Version.Major.ToString() + "." + $Host.Version.Minor.ToString()
[string]$psVersionExpected = "4.0"

if($psVersion -eq $psVersionExpected){
    Write-Host "PowerShell Version is correct: $psVersion" 
} 
else{
    throw "PowerShell Version is incorrect: $psVersion instead of $psVersionExpected"
}
Write-Host

#endregion

#region Product version

function CheckProductVersion([string]$productName, [string]$currentVersionExePath, [string]$currentProductVersion)
{
    [string]$productVersion = $null

    if(!(Test-Path $currentVersionExePath)){
        throw "$productName is not installed at $currentVersionExePath"
    }
    elseif(($productVersion = (Get-ItemProperty -Path $currentVersionExePath).VersionInfo.ProductVersion) -ine $currentProductVersion){
        throw "Expected $productName version $currentProductVersion, found $productVersion. Please update your copy or update the config data script."
    }
    else{
        Write-Host "$productName version is correct: $productVersion"
    }
    Write-Host
}

CheckProductVersion -productName "Visual Studio" -currentVersionExePath $DevConfigData.VsCurrentVersionExePath -currentProductVersion $DevConfigData.VsCurrentProductVersion

CheckProductVersion -productName "SQL Server" -currentVersionExePath $DevConfigData.SqlServerCurrentVersionExePath -currentProductVersion $DevConfigData.SqlServerCurrentProductVersion

#endregion

#region Visual Studio Old Products 

foreach($productRegPath in $DevConfigData.VsOldProductRegPathAndName.Keys)
{
    [string]$productName = $DevConfigData.VsOldProductRegPathAndName[$productRegPath]
    
    if((Test-Path -LiteralPath $productRegPath)){
        
        Write-Host "Please follow below instructions: "
        Write-Host "1. Uninstall $productName"
        Write-Host "2. Reopen and close corresponding visual studio"
        Write-Host "3. Run script again"
        Write-Host
        throw "Detected outdated product '$productName', follow above instructions"
    }    
}

#endregion

#region Visual Studio Installed Products (Per VS Help > About)

foreach($productRegPath in $DevConfigData.VsInstalledProductRegPathAndVersion.Keys)
{
    [string]$productName = Split-Path $productRegPath -Leaf
    [string]$expectedVersion = $DevConfigData.VsInstalledProductRegPathAndVersion[$productRegPath]
    
    if(!(Test-Path -LiteralPath $productRegPath)){
        throw "Could not find entry in registry: $productName"
    }

    [string]$installedVersion = (Get-ItemProperty -Path $productRegPath).PID

    if([string]::IsNullOrWhiteSpace($installedVersion)){
        throw "Registry path does not contain a version (PID entry): $productName"
    }

    if($installedVersion -ine $expectedVersion){
        throw "Expected version $expectedVersion but found $installedVersion for: $productName"
    }
    else{
        Write-Host "$productName version is correct: $expectedVersion"
        Write-Host ""
    }
}

#endregion

#region Powershell Cmdlets installation

foreach($oldPath in $DevConfigData.TfsPowerToolsOldVersionDirPaths)
{
    if(Test-Path $oldPath)
    {
        Write-Host "Outdated TFS Powershell Cmdlets are installed, which" -ForegroundColor Red
        Write-Host "can cause unexpected issues in a Visual Studio $($DevConfigData.VsCurrentProductVersion) development environment." -ForegroundColor Red
        throw "Please uninstall the TFS Powershell Cmdlets from $oldPath"
    }
}

if(-not (Test-Path $DevConfigData.TfsPowerToolsCurrentVersionDirPath))
{
    Start-Process $DevConfigData.TfsPowerToolsDownloadUrl -WindowStyle Normal

    Write-Host "Powershell Cmdlets NOT installed."
    Write-Host "1) Download the Powershell Cmdlets from: $($DevConfigData.TfsPowerToolsDownloadUrl)"
    Write-Host "2) Open properties on file and select `"Unblock`" (if applicable)"
    Write-Host "3) Run the installation and make sure to select Custom installation."
    Write-Host "4) Change PowerShell Cmdlets to `“This feature will be installed on local hard drive.`”"
    Write-Host "5) Finish the installation"
	Write-Host "6) Restart computer"
    Write-Host ""
    throw "Please re-run the process after the installation steps (SEE ABOVE) are finished"
}
else{
    Write-Host "Powershell Cmdlets are installed."
}
Write-Host

#endregion

#region Powershell Cmdlets

$cmdletRegistryPath = "HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\Microsoft.TeamFoundation.PowerShell"

if(Test-Path $cmdletRegistryPath){
    Write-Host "TFS Cmdlets are available in PowerShell."
}
else{
    Write-Host "Making TFS Cmdlets available in PowerShell..."

    #Make the TFS Powershell Cmdlets Available to 64 bit powershell - http://social.msdn.microsoft.com/Forums/en-US/a116799a-0476-4c42-aa3e-45d8ba23739e/tfs-power-tools-2008-powershell-snapin-wont-run-in-on-64bit-in-windows-2008-r2?forum=tfspowertools
    copy HKLM:\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\PowerShellSnapIns\Microsoft.TeamFoundation.PowerShell $cmdletRegistryPath -r

    Write-Host "TFS Cmdlets are available in PowerShell."

    $restartExplorer = $true
}
Write-Host

#endregion

#region Powershell Execution Policy

$executionPolicy = Get-ExecutionPolicy -Scope LocalMachine

if($executionPolicy -eq [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned){
    Write-Host "PowerShell Execution Policy is Correct: $($executionPolicy.ToString())"
}
else{
    Write-Host "Update PowerShell Execution Policy From: $($executionPolicy.ToString())"
    
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
    Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser,Process -Force

    Write-Host "Updated PowerShell Execution Policy To: $((Get-ExecutionPolicy -Scope LocalMachine).ToString())"

    $restartExplorer = $true
}
Write-Host

#endregion

#region Powershell Profile setup

$profilePath = $profile.CurrentUserAllHosts

if(Test-Path $profilePath){
    del $profilePath -Force
    Write-Host "Old Powershell Profile deleted."
}

$profileContents = @"
`$ErrorActionPreference = "stop"
if ((Get-PSSnapin -Name Microsoft.TeamFoundation.PowerShell -ErrorAction SilentlyContinue) -eq `$null )
{
    Add-PsSnapin Microsoft.TeamFoundation.PowerShell
}

`$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent())

if(!`$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Warning "Script NOT running as administrator. This could cause unexpected behavior."
    Write-Host
}
"@

New-Item -Path $profilePath -ItemType file -Force -Value $profileContents | Out-Null
&"$profilePath" #execute profile script

Write-Host "Powershell Profile created."
Write-Host

#endregion

#region Powershell Context Menu

function PropertyExistsAndValueMatches
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$registryPath,

        [Parameter(Mandatory=$true)]
        [string]$propertyName,

        [Parameter(Mandatory=$true)]
        [string]$propertyValue
    )

    if(!(Test-Path $registryPath)){
        return $false
    }

    $registryProperty = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

    return ($registryProperty -ne $null) -and ($registryProperty."$propertyName" -eq $propertyValue)
}

[string]$powershellEmptyCommand = @"
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoExit "-Command" "{0}"
"@

[string]$desiredRunWithPowershellCommand = $powershellEmptyCommand -f @"
if((Get-ExecutionPolicy ) -ne 'RemoteSigned') { Set-ExecutionPolicy -Scope Process Bypass }; cd (Split-Path "%1" -Parent); & '%1'
"@

[string]$openHerePowershellCommand = $powershellEmptyCommand -f @"
Set-Location -LiteralPath '%V'
"@

[hashtable]$openPowershellHereContextsAndRegistryPaths = @{
    "Open PowerShell Window: Folder"="Registry::HKEY_CLASSES_ROOT\Directory\shell";
    "Open PowerShell Window: Folder Background"="Registry::HKEY_CLASSES_ROOT\Directory\background\shell"
}

[string]$openHerePowershellText = "Open PowerShell window here"

foreach($openContext in $openPowershellHereContextsAndRegistryPaths.Keys)
{
    [string]$openHereRegistryPath = $openPowershellHereContextsAndRegistryPaths[$openContext]
    [string]$powershellFolderRegistryPath = "$openHereRegistryPath\powershell"
    [string]$commandRegistryPath = "$powershellFolderRegistryPath\command"

    if(!(Test-Path $powershellFolderRegistryPath)){
        New-Item -Path $openHereRegistryPath -Name "powershell" -Force | Out-Null    
    }

    if(!(Test-Path $commandRegistryPath)){
        New-Item -Path $powershellFolderRegistryPath -Name "command" -Force | Out-Null
    }

    if(!(PropertyExistsAndValueMatches -registryPath $powershellFolderRegistryPath -propertyName "(Default)" -propertyValue $openHerePowershellText))
    {
        Write-Host "Configuring `"$openContext`" text..."
        Write-Host

        New-Item -Path $powershellFolderRegistryPath -Force -Name "" -Value $openHerePowershellText | Out-Null

        Write-Host "`"$openContext`" text configured."        
    }
    else{
        Write-Host "`"$openContext`" text is correct."
    }
    Write-Host

    if(!(PropertyExistsAndValueMatches -registryPath $commandRegistryPath -propertyName "(Default)" -propertyValue $openHerePowershellCommand))
    {
        Write-Host "Configuring `"$openContext`" command..."
        Write-Host

        New-Item -Path $commandRegistryPath -Force -Name "" -Value $openHerePowershellCommand | Out-Null

        Write-Host "`"$openContext`" command configured."
    }
    else{
        Write-Host "`"$openContext`" command is correct."
    }
    Write-Host
}

[hashtable]$runPowershellCommandsAndRegistryPaths = @{
    "Run with PowerShell"="Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\0\Command\";
    "Run as administrator (PowerShell)"="Registry::HKEY_CLASSES_ROOT\Microsoft.PowershellScript.1\Shell\runas\command"
}

foreach($runCommandName in $runPowershellCommandsAndRegistryPaths.Keys)
{
    [string]$runRegistryPath = $runPowershellCommandsAndRegistryPaths[$runCommandName]

    if(!(PropertyExistsAndValueMatches -registryPath $runRegistryPath -propertyName "(Default)" -propertyValue $desiredRunWithPowershellCommand))
    {
        Write-Host "Configuring `"$runCommandName`" command..."
        Write-Host

        New-Item -Path $runRegistryPath -Force -Name "" -Value $desiredRunWithPowershellCommand | Out-Null

        Write-Host "`"$runCommandName`" command configured."
    }
    else{
        Write-Host "`"$runCommandName`" command is correct."
    }

    Write-Host
}

#endregion

#region Workspace local path

$workspace = Get-TfsWorkspace "$"
$localFolders = $workspace.Folders

if($localFolders.Length -ne 1)
{
    Write-Host "1 and ONLY 1 local directory should be mapped for the workspace"
}
else
{
    if($localFolders.LocalItem -cne $DevConfigData.WorkspaceLocalDirPath){
        Write-Host "Local workspace path should be $($DevConfigData.WorkspaceLocalDirPath), not $($localFolders.LocalItem)"
    }
    else{
        Write-Host "Local workspace path is correct: $($localFolders.LocalItem)"
    }
}
Write-Host

#endregion

#region Restart Explorer

if($restartExplorer){
    ..\Dev\Ref\WindowsExplorer_Restart.ps1
}

#endregion