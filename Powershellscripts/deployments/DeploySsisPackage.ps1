$ErrorActionPreference = 'Stop'
$regKeyFormat = 'HKLM:\Software\Microsoft\Microsoft SQL Server\{0}0\DTS\Setup'
$vsVersions = @( '12' )

function Validate-Argument($name, $value) {
    if (!$value) {
        throw ('Missing required value for parameter ''{0}''.' -f $name)
    }
    return $value
}

function Load-Dts {
  Write-Verbose 'Attempting to discover install folder...' 
  $regKey = $vsVersions | foreach { $regKeyFormat -f $_ } | where { Test-Path $_ } | select -first 1
    
  if (!$regKey) {
    throw 'No usable SQL installation found.'
  }
	
	Write-Verbose 'SQL Server found. Attempting to discover DTS path...'
  $dtsDir = Get-ItemProperty -Path $regKey | select -ExpandProperty SQLPath
}

$ssisPackageStepName = Validate-Argument 'SSIS Package Step Name' $OctopusParameters['SsisPackageStepName']
$ssisServer = Validate-Argument 'SSIS server name' $OctopusParameters['SsisServer']
$ssisPackage = Validate-Argument 'SSIS package name' $OctopusParameters['SsisPackage']

Load-Dts

# Set .NET CurrentDirectory to package installation path
$installDirPathFormat = 'Octopus.Action[{0}].Output.Package.InstallationDirectoryPath' -f $ssisPackageStepName
$installDirPath = $OctopusParameters[$installDirPathFormat]

Write-Verbose ('Setting CurrentDirectory to ''{0}''' -f $installDirPath)
[System.Environment]::CurrentDirectory = $installDirPath

$exePath = $dtsDir + 'ISDeploymentWizard.exe'

foreach ($file in $installDirPath|where{$_.Name -like "*ispac"}) {
	$name = [IO.Path]::GetFileNameWithoutExtension($file)
  $arg = '/S /ST:File /SP:"' + $file + '" /DS:"' + $ssisServer + '" /DP:"/SSISDB/' + $ssisPackage + '/"' + $name + '"'
}