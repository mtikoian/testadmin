function Invoke-SqlPlusWithFile($connectionString, $file) {
  Write-Output "$file";

  # Wrap script to make sqlplus stop on errors (because Oracle doesn't do this
  # by default). Also exit the prompt after the script has run.
  $lines = Get-Content $file;
  $lines = ,'whenever sqlerror exit sql.sqlcode rollback;' + $lines;
  $lines += 'exit';

  Invoke-SqlPlusCommand $connectionString $lines
}

function Invoke-SqlPlusCommand($connectionString, $command) {

  $command | sqlplus $connectionString | Tee-Object -Variable output | out-default;

    if (!$? -or # Stop on non-zero exit codes.
        # Stop on script errors. Have to detect them from output
        # unfortunately, as I couldn't find a way to make SQL*Plus halt on
        # warnings.
    $output -match "compilation errors" -or 
    $output -match "unknown command" -or 
    $output -match "Input is too long" -or
    $output -match "unable to open file") { 
    throw "Script failed: $fileNameOnly"; 
  }
}

$environment = $OctopusParameters["Octopus.Environment.Name"] ;
$version = $OctopusParameters["Octopus.Release.Number"];

$versionCommand = "
INSERT INTO VersionInfo VALUES ('$environment','$version', sysdate);
COMMIT;
/";

foreach ($connection in $nEDRMappingConnectionStrings.Split(","))
{
  Write-Host "Executing scripts for Connection $connection"

  $files = Get-ChildItem "./SQL/Scripts/Dependencies"  -Filter *.sql | Sort-Object
  foreach ($file in $files) {
    Invoke-SqlPlusWithFile $connection $file.FullName
  }

  $files = Get-ChildItem "./SQL/Scripts"  -Filter *.sql | Sort-Object
  foreach ($file in $files) {
    Invoke-SqlPlusWithFile $connection $file.FullName
  }

  Invoke-SqlPlusCommand $connection $versionCommand
}