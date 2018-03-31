"SQL01", "SQL02", "SQL03" | % {
    $SQLInstance = new-object ('Microsoft.SqlServer.Management.Smo.Server') $_;
    if ($SQLInstance.Settings.LoginMode -eq "Integrated")
    {
        Write-Output "Changing autentication to mixed on instance $($_)";
        $SQLInstance.Settings.LoginMode = [Microsoft.SqlServer.Management.Smo.ServerLoginMode]::Mixed;
        $SQLInstance.Alter();
        
        Write-Output "Stopping SQL Server Agent on server $($_)";
        if ((Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Status -ne "Stopped")
            { (Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Stop(); }
        while ((Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Status -ne "Stopped")
            { sleep -Seconds 1; }
        
        Write-Output "Stopping SQL Server on server $($_)";
        if ((Get-Service -ComputerName $_ -Name "MSSQLSERVER").Status -ne "Stopped")
            { (Get-Service -ComputerName $_ -Name "MSSQLSERVER").Stop(); }
        while ((Get-Service -ComputerName $_ -Name "MSSQLSERVER").Status -ne "Stopped")
            { sleep -Seconds 1; }
        
        Write-Output "Starting SQL Server on server $($_)";
        if ((Get-Service -ComputerName $_ -Name "MSSQLSERVER").Status -ne "Running")
            { (Get-Service -ComputerName $_ -Name "MSSQLSERVER").Start(); }
        while ((Get-Service -ComputerName $_ -Name "MSSQLSERVER").Status -ne "Running")
            { sleep -Seconds 1; }

        Write-Output "Starting SQL Server Agent on server $($_)";
        if ((Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Status -ne "Running")
            { (Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Start(); }
        while ((Get-Service -ComputerName $_ -Name "SQLSERVERAGENT").Status -ne "Running")
            { sleep -Seconds 1; }

    }
}

