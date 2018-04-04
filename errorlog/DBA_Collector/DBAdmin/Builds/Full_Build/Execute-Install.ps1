# Get the current location of the script
$scriptPath = Split-Path $MyInvocation.MyCommand.Path;

# Set common variables
$logPath = "$scriptPath\log.txt";

# Load configuration variables
if (-not (Test-Path "$scriptPath\Config.txt"))
{
  Write-Warning "Configuration text file 'Config.txt' not found. Exiting."
  return
}

$Configs = Get-Content "$scriptPath\Config.txt" |
            Where-Object {-not ($_ -match "^#") -and ($_ -ne "")}

foreach ($config in $Configs)
{
  $splitConfig = $config.split("=")
  $expression = "`$env:$($splitConfig[0]) = `"$($splitConfig[1])`""
  Write-Verbose $expression
  Invoke-Expression $expression
}

# Instantiate process object
$sqlcmdProcess = New-Object System.Diagnostics.Process;
$sqlcmdProcess.StartInfo.FileName = "sqlcmd.exe";
$sqlcmdProcess.StartInfo.UseShellExecute = $false;
$sqlcmdProcess.StartInfo.RedirectStandardError = $true;
$sqlcmdProcess.StartInfo.RedirectStandardOutput = $true;
$sqlcmdProcess.StartInfo.WorkingDirectory = $scriptPath;

# Check if log file exists, and if so, delete it
if (Test-Path $logPath) {Remove-Item $logPath -force;}

# Initialize log file
Add-Content $logPath "----------------------------------------------------------------------`n";
Add-Content $logPath " Beginning script execution.`n" -PassThru
Add-Content $logPath " Date: $(Get-Date)`n" -PassThru
Add-Content $logPath "----------------------------------------------------------------------`n";
Add-Content $logPath "`n";

# Execute the fille to create the database
$file = "..\..\SchemaObjects\CreateDB.sql"
Add-Content $logPath "----------------------------------------------------------------------`n" -PassThru
Add-Content $logPath "Beginning execution of script '$scriptPath\$file'." -PassThru
$sqlcmdProcess.StartInfo.Arguments = "-i `"$scriptPath\$file`" -d master -b -S $env:DBServer -E"
$sqlcmdProcess.Start() | Out-Null;
$sqlcmdProcess.WaitForExit();
Add-Content $logPath $sqlcmdProcess.StandardOutput.ReadToEnd()
if ($sqlCmdProcess.ExitCode -ne 0) 
{ 
  Add-Content $logPath $sqlcmdProcess.StandardError.ReadToEnd(); 
  Throw "Error occurred executing script '$scriptPath\$file', please check log.txt file for details."; 
}
Add-Content $logPath " Finished execution of script '$scriptPath\$file'." -PassThru


# Get the list of files to execute
$filesToExecute = Get-Content "$scriptPath\BuildInput.Txt" |
                    Where-Object {-not ($_ -match "^#")}

# Loop over files and execute
foreach ($file in $filesToExecute)
{
  # Check if the file exists
  if (-not (Test-Path "$scriptPath\$file"))
  {
    Write-Warning "Script file '$scriptPath\$file' does not exist. Exiting."
    return
  }
  
  # Execute the file
  Add-Content $logPath "----------------------------------------------------------------------`n" -PassThru
  Add-Content $logPath "Beginning execution of script '$scriptPath\$file'." -PassThru
  $sqlcmdProcess.StartInfo.Arguments = "-i `"$scriptPath\$file`" -d $env:DBName -b -S $env:DBServer -E"
  $sqlcmdProcess.Start() | Out-Null;
  $sqlcmdProcess.WaitForExit();
  Add-Content $logPath $sqlcmdProcess.StandardOutput.ReadToEnd()
  if ($sqlCmdProcess.ExitCode -ne 0) 
  { 
    Add-Content $logPath $sqlcmdProcess.StandardError.ReadToEnd(); 
    Throw "Error occurred executing script '$scriptPath\$file', please check log.txt file for details."; 
  }
  Add-Content $logPath " Finished execution of script '$scriptPath\$file'." -PassThru
}