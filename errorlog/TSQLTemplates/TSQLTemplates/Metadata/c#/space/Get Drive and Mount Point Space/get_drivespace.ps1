$col = @()
$logfile = "C:\Users\ab75155ad\Documents\drivespaceinfo.csv"
$InputFile = "C:\Users\ab75155ad\Documents\Servers.txt"
$strComputer = Get-Content $InputFile
ForEach($strComputer in $strComputer)
{
$rec = Get-WmiObject win32_volume -computer $strcomputer | Select-Object SystemName,name,driveletter,capacity,freespace
$col += $rec
}

$col | export-csv $logfile -NoTypeInformation

