. ..\Dev\Ref\DevConfigData.ps1
. ..\Shared\Ref\Function_Misc.ps1

[string]$updatedSystemPath = [Environment]::GetEnvironmentVariable("Path")

[string[]]$dirPathsToUnregister = ($DevConfigData.TfOldVersionExePaths | Split-Path -Parent) + `
    ($DevConfigData.VsOldVersionExePaths | Split-Path -Parent) `
    | Sort-Object | Get-Unique

[bool]$pathRemoved = $false

foreach($dirPath in $dirPathsToUnregister)
{
    [string]$pathRegex = [RegEx]::Escape($dirPath) + "\\?(?:;|$)"

    if($updatedSystemPath -imatch $pathRegex)
    {
        Write-Host "$dirPath is included in the system paths and could cause unexpected behavior."

        if((PromptForYesNoValue -displayMessage "Is it OK to proceed with its removal?" -isYesDefaultValue $true) -ine "y"){
            throw "Permission was not given to remove $dirPath from the paths."
        }
        Write-Host  

        $updatedSystemPath = $updatedSystemPath -ireplace $pathRegex, ""

        Write-Host "Path isolated for removal: $dirPath"
        Write-Host
        $pathRemoved = $true
    }
}

if($pathRemoved)
{
    [Environment]::SetEnvironmentVariable("Path", $updatedSystemPath, [System.EnvironmentVariableTarget]::Machine)
    
    #updates the current powershell session
    $env:Path = $updatedSystemPath 

    Write-Host "System path updated"
    Write-Host
    
    ..\Dev\Ref\WindowsExplorer_Restart.ps1
}