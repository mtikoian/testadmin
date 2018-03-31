$environment = $OctopusParameters["Octopus.Environment.Name"] 

# create proxy object to http://ssrs/reportserver/reportservice2005.asmx
$ssrsProxy = New-WebServiceProxy -Uri $ssrsreportserverurl -UseDefaultCredential

# create top level (project) folder
$ssrsProxy.CreateFolder($SSRSReportFolder, $reportPath, $null)

# create the environment sub folder.
$reportPath = [string]::Concat($reportPath, $SSRSReportFolder)
$ssrsProxy.CreateFolder($environment, $reportPath, $null)