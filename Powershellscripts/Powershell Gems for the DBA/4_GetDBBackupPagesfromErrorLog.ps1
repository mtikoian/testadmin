# Error log directory 
$ErrorlogDir = "C:\APresentation\SQLSat382PowershellGems\errorlogs"

# Get Errorlog files in $ErrorlogDir
$ErrorLogs =  Get-ChildItem $ErrorlogDir | Where-Object {$_.name -like "*errorlog*" }  

foreach ($File in $ErrorLogs)
{
  $ErrFile = $File.fullname   # get the file full name
  Write-Host "--> Processing $ErrFile"

  # Parse the error log file, get the dumped pages, each page is 8K in size
  get-content $ErrFile | foreach-object {if ($_ -like "*Database backed up. Database: *")     # lines with "Database backed up. Database:"
            {$_.substring($_.indexof("Database backed up. Database: ")+30, $_.indexof("creation date(time): ")-$_.indexof("Database backed up. Database: ")-32) + "," `
			+ $_.substring($_.indexof("pages dumped: ")+14, $_.indexof("first LSN:")-$_.indexof("pages dumped: ")-16) } } | add-content "C:\temp\backupinfo.csv"
			
}

notepad C:\temp\backupinfo.csv