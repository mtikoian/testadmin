$servers = @("server1","server2","server3","server4")

foreach ($server in $servers)
{
    $result = Get-WmiObject win32_service -ComputerName  $server | Where-Object {$_.Name -like "MSSQL$*" -or $_.Name -like "SQLAgent$*" -or $_.Name -like "MSOLAP$*" -or $_.Name -eq "SQLBrowser" -or $_.Name -eq "MsDtsServer120" -or $_.Name -eq "SQLWriter"} | Select name, ',', startname
    foreach ($srv in $result)
    {
        $line = $server + ',' + $srv.startname + ',' + $srv.name
        Write-Host $line 
    }
}