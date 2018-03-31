. ..\Dev\Ref\DevConfigData.ps1
. ..\Shared\Ref\Function_Misc.ps1

[string]$updatedSystemPath = [Environment]::GetEnvironmentVariable("Path")

[string[]]$exePathsToRegister = 
@(
    $DevConfigData.TfCurrentVersionExePath,
    $DevConfigData.VsCurrentVersionExePath
) | Sort-Object | Get-Unique

[string[]]$addedPaths = @()

foreach($exePath in $exePathsToRegister)
{
    [string]$exeName = $exePath | Split-Path -Leaf
    [string]$dirPathToRegister = $exePath | Split-Path -Parent

    [string]$pathRegex = [RegEx]::Escape($dirPathToRegister) + "\\?(?:;|$)"

    if($updatedSystemPath -inotmatch $pathRegex)
    {
        $updatedSystemPath = $updatedSystemPath + ";" + $dirPathToRegister
        $addedPaths += $dirPathToRegister

        Write-Host "Added to system path: $exePath"
        Write-Host ""
    }
    elseif((!$addedPaths.Contains($dirPathToRegister)) -and !(Get-Command $exeName -ErrorAction SilentlyContinue))
    {
        throw "Cannot access $exeName even though it's contained in the system path: $dirPathToRegister"
    }
}

if($addedPaths.Count -gt 0)
{
    [Environment]::SetEnvironmentVariable("Path", $updatedSystemPath, [System.EnvironmentVariableTarget]::Machine)
    
    #updates the current powershell session
    $env:Path = $updatedSystemPath 

    Write-Host "System path updated"
    Write-Host
    
    ..\Dev\Ref\WindowsExplorer_Restart.ps1
}