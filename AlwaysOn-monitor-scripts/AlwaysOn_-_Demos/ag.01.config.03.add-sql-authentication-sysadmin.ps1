"SQL01", "SQL02", "SQL03" | % {
    Invoke-Sqlcmd -ServerInstance $_ -Query "CREATE LOGIN ghotz WITH PASSWORD = 'Passw0rd!', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;"
    Invoke-Sqlcmd -ServerInstance $_ -Query "ALTER SERVER ROLE sysadmin ADD MEMBER ghotz;"
}
