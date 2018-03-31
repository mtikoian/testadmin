## Restore latest backups from backup folder.
## Db path is <drive>:\sqlbackupdb\<database>\full

# Get latest database backup files.
$BackupRootDir = "C:\sqlbackupdb"
$backupfiles = Get-ChildItem $BackupRootDir | Where-Object {$_.PsIsContainer} | 
  Foreach-object {Get-ChildItem $_.fullname -Recurse | Where-Object {!$_.PsIsContainer -and $_.extension -eq ".bak" } | 
  Select Name, DirectoryName, LastWriteTime | 
  sort -property LastWriteTime -Descending | 
  select -first 1 }

foreach ($i in $backupfiles) {    # for each backup file 
  $name = $i.name   ## file name.ext
  $dir = $i.DirectoryName    #full directory spec
  Write-Host "Dir is $dir"
  Write-Host "File is $name"
  $dbname = $dir.replace("C:\sqlbackupdb\","").replace("\full","")   #get the database name from the directory name
  Write-Host  "restore database $dbname from disk = '$dir\$name' with recovery;"   # write output to console
  add-content c:\temp\restoreDB.sql "restore database $dbname from disk = '$dir\$name' with recovery;"   # write output to output

}

notepad c:\temp\restoredb.sql