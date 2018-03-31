#  ptp  20150812  Demo for PASS PowerShell for the Reluctant Administrator presentation

#  First navigate to where the demo files are
cd 'C:\wip\PASS\PPPresentations\PowerShell for the Reluctant Administrator'

#  Then load the functions
. .\Get-Elapsed.ps1
. .\Get-VolumeInfo.ps1
. .\PS-ADO.ps1

#  Load the SQL PowerShell (aka SMO) module
Push-Location
Import-Module sqlps
Pop-Location

#  Gee, what was that thing complaining about???
Get-Verb


#  Shorten up the prompt a bit!
cd \wip

#  Demo some variable tricks

3.14

3..14

3e14


'Hello, world'

$Demo = 'Hello, world'

'This is a $Demo'

"This is a $Demo"

$FileDemo = "This is my filename $(Get-Date -Format yyyyMMdd_HHmmss)"


#  Demo some cmdletes

Get-VolumeInfo

Get-VolumeInfo | Out-Gridview -PassThru

Get-VolumeInfo | Export-Csv 'C:\wip\Demo.csv'
$DemoTab = $psise.CurrentPowerShellTab.Files.add('C:\wip\Demo.csv')

#  Now let's play with SQL Server!

$SQLInstance = 'ltp0434\SQL2012'
$DBBackups = 'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\Backup'

#  Now let's demo some ADO

$cn = Open-ADOConnection -Instance $SQLInstance -Catalog master

$Query = @"
SELECT dbid, name
   FROM master.dbo.sysdatabases
"@

$rs = Get-ADOQueryResult -cn $cn -QueryStmt $Query

$dbinfo = $rs | Select-Object dbid, name

$dbinfo | Out-GridView

$cn.Close()

#  Now we use SQLPS (aka SMO)

SQLServer:

#  Ooo...  SQL Server is a drive???  What's in it?

dir

#  Shazam Batman, that's cool stuff!  Let's poke around!

cd "\SQL\$SQLInstance"
dir

#  Oh my, what fun!
cd databases
dir

#  What can we do with these database toys???
dir "$DBBackups\*"
del "$DBBackups\*"
dir "$DBBackups\*"

dir | Backup-SqlDatabase

dir "$DBBackups\*"
