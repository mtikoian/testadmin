cd $PSScriptRoot

$workspace = Get-TfsWorkspace $PSScriptRoot
$solutionPath = $workspace.GetLocalItemForServerItem("$/CSES/Release/Dev/Framework/Saber.Framework.sln")
$msBuildFullName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0").MSBuildToolsPath + "\MsBuild.exe"

function Build{
    Invoke-Expression "$msBuildFullName $solutionPath /NoLogo /ConsoleLoggerParameters:ErrorsOnly" 
}

function CopyDlls{
    .\SourceCode_CopyDirectoryContents.ps1 -sourceServerPath "$/CSES/Release/Dev/Framework/Library/Ref/Saber.Framework.BusinessDate.*" -targetServerPath "$/CSES/Release/Dev/Framework/Library"
    .\SourceCode_CopyDirectoryContents.ps1 -sourceServerPath "$/CSES/Release/Dev/Framework/Library/Ref/Saber.Framework.Domain.Base.*" -targetServerPath "$/CSES/Release/Dev/Framework/Library"
}

#1
Build
Write-Host "First compile complete"
Write-Host ""

CopyDlls
Write-Host "First Dll copy from Ref to Library complete"
Write-Host ""

#2
Build
Write-Host "Second compile complete"
Write-Host ""

CopyDlls
Write-Host "Second Dll copy from Ref to Library complete"
Write-Host ""

#3
Build
Write-Host "Third compile complete"
Write-Host ""

CopyDlls
Write-Host "Third Dll copy from Ref to Library complete"
Write-Host ""

Write-Host "Circular build completed."