Get-ChildItem './Reports' -Filter *.rdl | 
Foreach-Object{
    
  $byteArray = gc $rdlFile -encoding byte
        
  Write-Host "Uploading $reportName to $reportFolder"
 
  $ssrsProxy.CreateReport($reportName,$reportFolder,$force,$byteArray,$null)
}