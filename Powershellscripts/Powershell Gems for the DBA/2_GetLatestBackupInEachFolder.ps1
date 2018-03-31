   #Get lastest full database backup in each folder

  Get-ChildItem "c:\sqlbackupdb" | Where-Object {$_.PsIsContainer} |  # get all directories under c:\sqlbackupdb
      Foreach-object {Get-ChildItem $_.fullname -Recurse | Where-Object {!$_.PsIsContainer -and $_.extension -eq ".bak" } |   #recurse through and get bak files
	  Select Name, DirectoryName, LastWriteTime |   
	  sort -property LastWriteTime -Descending |  # sort on LastWrite time descending
	  select -first 1 | format-table }    # get the first file from the sorted listed for the iteration
	   
	   


