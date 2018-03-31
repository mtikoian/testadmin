<#
.SYNOPSIS
    Generates a project change log file.
.LINK
    Script posted over:
    http://open.bekk.no/generating-a-project-change-log-with-teamcity-and-powershell
#>

# Where the changelog file will be created
$outputFile = "%system.teamcity.build.tempDir%\releasenotesfile_%teamcity.build.id%.txt"
# the url of teamcity server
$teamcityUrl = "%teamcity.serverUrl%"
# username/password to access Teamcity REST API
$authToken=[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("%system.teamcity.auth.userId%:%system.teamcity.auth.password%"))
# Build id for the release notes
$buildId = %teamcity.build.id%

# Get the commit messages for the specified change id
# Ignore messages containing #ignore
# Ignore empty lines
Function GetCommitMessages($changeid)
{
    $request = [System.Net.WebRequest]::Create("$teamcityUrl/httpAuth/app/rest/changes/id:$changeid")     
    $request.Headers.Add("AUTHORIZATION", "$authToken");
    $xml = [xml](new-object System.IO.StreamReader $request.GetResponse().GetResponseStream()).ReadToEnd()    
    Microsoft.PowerShell.Utility\Select-Xml $xml -XPath "/change" |
        where { ($_.Node["comment"].InnerText.Length -ne 0) -and (-Not $_.Node["comment"].InnerText.Contains('#ignore'))} |
        foreach {"+ $($_.Node["user"].username) : $($_.Node["comment"].InnerText.Trim().Replace("`n"," "))`n"}
}

# Grab all the changes
$request = [System.Net.WebRequest]::Create("$teamcityUrl/httpAuth/app/rest/changes?build=id:$($buildId)")
$request.Headers.Add("AUTHORIZATION", "$authToken");
$xml = [xml](new-object System.IO.StreamReader $request.GetResponse().GetResponseStream()).ReadToEnd()

# Then get all commit messages for each of them
$changelog = Microsoft.PowerShell.Utility\Select-Xml $xml -XPath "/changes/change" | Foreach {GetCommitMessages($_.Node.id)}
$changelog > $outputFile
Write-Host "Changelog saved to ${outputFile}:"
$changelog