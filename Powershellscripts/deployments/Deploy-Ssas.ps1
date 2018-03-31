$ErrorActionPreference = 'Stop'
$regKeyFormat = 'HKLM:\Software\Wow6432Node\Microsoft\Microsoft SQL Server\{0}0\Tools\ClientSetup\'
$vsVersions = @( '12' )

function Validate-Argument($name, $value) {
    if (!$value) {
        throw ('Missing required value for parameter ''{0}''.' -f $name)
    }
    return $value
}

# Returns the Microsoft.AnalysisServices.Deployment.exe path
function Load-SsasDeploy {
  Write-Verbose 'Attempting to discover install folder...' 
  $regKey = $vsVersions | foreach { $regKeyFormat -f $_ } | where { Test-Path $_ } | select -first 1
    
  if (!$regKey) {
    throw 'No usable SQL installation found.'
  }
	
  Write-Verbose 'SQL Server found. Attempting to discover DTS path...'
  $dtsDir = Get-ItemProperty -Path $regKey | select -ExpandProperty SqlToolsPath
  $exePath = $dtsDir + 'Microsoft.AnalysisServices.Deployment.exe'
  if ( -not (Test-Path $exePath))
  {
      throw 'Missing: Cannot file Microsoft.AnalysisServices.Deployment.exe - ' + $exePath
  }
  Write-Verbose 'Microsoft.AnalysisServices.Deployment.exe found.'
  return '"'+$exePath+'"'
}

# Update Deploy xml (.deploymenttargets)
function Update-Deploy {
	[xml]$deployContent = Get-Content $file
	$deployContent.DeploymentTarget.Database = $ssasDatabase 
	$deployContent.DeploymentTarget.Server = $ssasServer
	$deployContent.DeploymentTarget.ConnectionString = 'DataSource=' + $ssasServer + ';Timeout=0'
	$deployContent.Save($file)
}
# Update Config xml (.configsettings)
function Update-Config {
	[xml]$configContent = Get-Content $file
    $configContent.ConfigurationSettings.Database.DataSources.DataSource.ConnectionString = 'Provider=SQLNCLI11.1;Data Source=' + $dbServer + ';Integrated Security=SSPI;Initial Catalog=' + $dbDatabase
	$configContent.Save($file)
}
# Update Config xml (.deploymentoptions)
function Update-Option {
	[xml]$optionContent = Get-Content $file
    $optionContent.DeploymentOptions.ProcessingOption = 'DoNotProcess'
	$optionContent.Save($file)
}

# Get arguments
$ssasPackageStepName = Validate-Argument 'SSAS Package Step Name' $OctopusParameters['SsasPackageStepName']
$ssasServer = Validate-Argument 'SSAS server name' $OctopusParameters['SsasServer']
$ssasDatabase = Validate-Argument 'SSAS database name' $OctopusParameters['SsasDatabase']
$dbServer = Validate-Argument 'SSAS source server' $OctopusParameters['SrcServer']
$dbDatabase = Validate-Argument 'SSAS source database' $OctopusParameters['SrcDatabase']

# Set .NET CurrentDirectory to package installation path
$installDirPathFormat = 'Octopus.Action[{0}].Output.Package.InstallationDirectoryPath' -f $ssasPackageStepName
$installDirPath = $OctopusParameters[$installDirPathFormat]

#$ssasServer     = 'server2\md_dev'
#$ssasDatabase   = 'BusinessIntelligence'
#$dbServer       = 'server1\dev'
#$dbDatabase     = 'Warehouse'
#$installDirPath = 'c:\packages\v1'

Write-Verbose ('Setting CurrentDirectory to ''{0}''' -f $installDirPath)
[System.Environment]::CurrentDirectory = $installDirPath

$exe = Load-SsasDeploy

$files = Get-ChildItem –Path $installDirPath\* -Include *.deploymenttargets
foreach ($file in $files) {
  $name = [IO.Path]::GetFileNameWithoutExtension($file)

  Write-Host 'Updating' $file
  Update-Deploy
  $file = $installDirPath + '\' + $name + '.configsettings'
  Write-Host 'Updating' $file
  Update-Config
  $file = $installDirPath + '\' + $name + '.deploymentoptions'
  Write-Host 'Updating' $file
  Update-Option

  $arg = '"' + $installDirPath + '\' + $name + '.asdatabase" /s:"' + $installDirPath + '\Log.txt"'
  Write-Host $exe $arg
  $execute = [scriptblock]::create('& ' + $exe + ' ' + $arg)
  Invoke-Command -ScriptBlock $execute
}