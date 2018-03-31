#DO NOT CURRENTLY SUPPORT WEB SERVICES.
param(
    [string]$appInstanceServerPath = $null
)

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent())

if(!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    throw "This script cannot execute unless running as administrator."    
}

. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1

if([string]::IsNullOrWhiteSpace($appInstanceServerPath))
{
    $appInstanceServerPath = ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Any -branchState $BranchStateEnum.Existing -returnFullServerPath $true
}

..\Dev\AppInstance_Update.ps1 -appInstanceServerPath $appInstanceServerPath
Write-Host

$workspace = Get-TfsWorkspace "$"

[string]$appInstanceLocalPath = $workspace.GetLocalItemForServerItem($appInstanceServerPath)
[string[]]$solutionFileRelativePaths = $DevConfigData.SolutionsToBuildRelativePaths

for($i=0; $i -lt $solutionFileRelativePaths.Count; $i++)
{
    [string]$solutionPath = $appInstanceLocalPath + "\" + $solutionFileRelativePaths[$i]

    if(Test-Path -LiteralPath $solutionPath)
    {
        BuildSolutionOrProject -solutionOrProjectFilePath $solutionPath -buildConfiguration "debug"
    }
    else
    {
        throw "Solution file could not be located: $solutionPath"
    }    
}

Write-Host "Launching Application(s). Please wait ..."
Write-Host

$workItemNumber = GetWorkItemNumberFromBranchName (Split-Path $appInstanceServerPath -Leaf)

[string[]]$urlsToLaunch = @()
[string]$urlFormat = "http://localhost/{0}"

foreach($webAppToLaunchRelativePath in $DevConfigData.WebAppToLaunchRelativePaths)
{   
    [string]$webAppPath = $appInstanceLocalPath +"\" + $webAppToLaunchRelativePath    

    if(!(Test-Path -LiteralPath $webAppPath))
    {
        throw "Could not locate web application: $webAppPath"
    }

    [string]$content = Get-Content -LiteralPath $webAppPath
        
    if($content -imatch "(?<=<IISUrl>\s*http://localhost/).+(?=\s*</IISUrl>)")
    {
        [string]$webAppName = $Matches[0]

        New-WebApplication -Name $webAppName -Site 'Default Web Site' -PhysicalPath (Split-Path $webAppPath -Parent) -ApplicationPool DefaultAppPool -Force | Out-Null
        
        Write-Host "Configured web application '$webAppName' in IIS"

        $urlsToLaunch += $urlFormat -f $webAppName 
    }
    else
    {
        throw "Local host IIS url does not exists in project file: $(Split-path $webAppPath -Leaf)"
    }       
}

Write-Host
Write-Host "Starting console application(s)"

foreach($exeToLaunchRelativePath in $DevConfigData.ExeToLaunchRelativePathAndWaitTimeMapping.Keys) 
{ 
    [string]$exeFilePath = $appInstanceLocalPath + "\" + $exeToLaunchRelativePath
    [string]$exeDirPath = Split-Path $exeFilePath -Parent
    [string]$exeName = Split-Path $exeFilePath -Leaf

    Start-Process cmd -ArgumentList "/C cd $exeDirPath & $exeName" 

    Write-Host "Started console application: $exeName"
    Start-Sleep -Seconds $DevConfigData.ExeToLaunchRelativePathAndWaitTimeMapping[$exeToLaunchRelativePath]
}

Write-Host "Starting console application(s) complete"
Write-Host

Write-Host "Opening Web application(s)"
$urlsToLaunch | ForEach-Object { start $_; Write-Host "Opened url: $_ in browser" }
Write-Host "Opening web application(s) complete"
Write-Host

Write-Host "Launching Application(s) complete"