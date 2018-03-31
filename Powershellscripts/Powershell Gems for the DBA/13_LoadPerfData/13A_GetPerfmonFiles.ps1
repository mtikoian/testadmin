
$ImportDir = "C:\APresentation\SQLSat382PowershellGems\13_LoadPerfData"
$i = 0
$fileList = get-childitem "$ImportDir" -r | where {$_.extension -eq ".blg"} 
	foreach ($file in $fileList)
	{
          $i = ++$i
	      $PMFile = $file.fullname
          #$Date = $file.creationtime
	      Write-Host "--> Copying file -> $PMFile -> fileno $i"   
          Copy-Item $PMFile $ImportDir\SQLDiag_$i.blg   #seed name with sequence no
	}