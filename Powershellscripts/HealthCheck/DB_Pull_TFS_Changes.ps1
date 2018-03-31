###############################################################
#                                                             
# Search for all unique file changes in TFS 
# for a given date/time range and collection location. 
# Write results to a manifest file.                                              
#                                                             
# Author:  Gary A. Stafford
# Created: 2012-04-18
# Revised: 2012-08-11                          
#                                                             
###############################################################
 
# Clear Output Pane
clear
 
# Enforce coding rules
Set-StrictMode -version 2.0
 
# Loads Windows PowerShell snap-in if not already loaded
if ( (Get-PSSnapin -Name Microsoft.TeamFoundation.PowerShell -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PSSnapin Microsoft.TeamFoundation.PowerShell
}
 
# Variables - CHECK EACH TIME
#[string] $tfsCollectionPath = "http://tfs2010/tfsCollection"
[string] $tfsCollectionPath = "http://svn.ccs.utc.com:8080/tfs/utcccscollection"
[string] $locationToSearch = "$/Blackjack/UTC.CCS.DPG/UTC.CCS.DPG.DB/SQL/DataBaseBuild/"
[string] $outputFile = "c:\ChangesToTFS.txt"
[string] $dateRange = "D2012-11-20 00:00:00Z~"
[bool]   $openOutputFile = $true # Accepts $false or $true
 
# For a date/time range: 'D2012-08-06 00:00:00Z~D2012-08-09 23:59:59Z'
# For everything including and after a date/time: 'D2012-07-21 00:00:00Z~'
 
[Microsoft.TeamFoundation.Client.TfsTeamProjectCollection] $tfs = get-tfsserver $tfsCollectionPath
 
# Add informational header to file manifest
[string] $outputHeader =
    "TFS Collection: " + $tfsCollectionPath + "`r`n" + 
    "Source Location: " + $locationToSearch + "`r`n" + 
    "Date Range: " + $dateRange + "`r`n" +
    "Created: " + (Get-Date).ToString() + "`r`n" +
    "======================================================================"
 
$outputHeader | Out-File $outputFile
 
Get-TfsItemHistory $locationToSearch -Server $tfs -Version $dateRange `
-Recurse -IncludeItems | 
 
Select-Object -Expand "Changes" | 
    Where-Object { $_.ChangeType -notlike '*Delete*'} | 
    Where-Object { $_.ChangeType -notlike '*Rename*'} | 
 
Select-Object -Expand "Item" | 
    Where-Object { $_.ContentLength -gt 0} | 
 
    Where-Object { $_.ServerItem -notlike '*/sql/*' } | 
    Where-Object { $_.ServerItem -notlike '*/documentation/*' } | 
    Where-Object { $_.ServerItem -notlike '*/buildtargets/*' } | 
 
    Where-Object { $_.ServerItem -notlike 'build.xml'} | 
    Where-Object { $_.ServerItem -notlike '*.proj'} | 
    Where-Object { $_.ServerItem -notlike '*.publish.xml'} | 
 
Select -Unique ServerItem | Sort ServerItem | 
Format-Table -Property * -AutoSize | Out-String -Width 4096 | 
Out-File $outputFile -append
 
Write-Host `n`r**** Script complete and file written ****
 
If ($openOutputFile) { Invoke-Item $outputFile }