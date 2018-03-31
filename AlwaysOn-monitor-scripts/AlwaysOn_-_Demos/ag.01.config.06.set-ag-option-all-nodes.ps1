Import-Module “sqlps” -DisableNameChecking;

"SQL01", "SQL02", "SQL03" | % {
    Write-Output "Enabling AlwaysOn AG on instance $($_)";
    Enable-sqlAlwaysOn -ServerInstance $_ -Force;
        
    Write-Output "Starting SQL Server Agent on server $($_)";
    if ((Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Status -ne "Running")
        { (Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Start(); }
    while ((Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Status -ne "Running")
        { sleep -Seconds 1; }

}