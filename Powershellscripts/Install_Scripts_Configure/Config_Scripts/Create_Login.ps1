<#
.SYNOPSIS 
Creates a server Login and adds to the designated server Role.

.DESCRIPTION

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $LoginType
WindowsUser or SqlLogin

.PARAMETER $LoginName
Domain or SQL account name.

.PARAMETER $LoginPwd
Login password.

.PARAMETER $Role
Server role for new login.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Create_Login.ps1 -SqlServer "SQL01" -LoginType "WindowsUser" -LoginName "Domain\Username" -LoginPwd = "" -Role "sysadmin"
 .\Create_Login.ps1 -SqlServer "SQL01" -LoginType "SqlLogin" -LoginName "Username" -LoginPwd = "Password" -Role "serveradmin"

#>

Param ([string]$SQLServer = $env:COMPUTERNAME,
       [string]$LoginType = "WindowsUser",
       [string]$LoginName = "",
       [string]$LoginPwd = "",
       [string]$Role = ""
)

# import sql cmdlets
Import-Module SQLPS

# If running script on the sql server, set location to sql instance root
If ($SQLServer -eq $env:COMPUTERNAME) {
Set-Location SQLServer:\SQL\$env:COMPUTERNAME\Default
};

# create server login
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer;
$login = new-object ('Microsoft.SqlServer.Management.Smo.Login') $svr, $LoginName;
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::$LoginType;
$login.Create($LoginPwd);

# add login to role
$svrperm = $svr.Roles[$Role]
$svrperm.AddMember($LoginName)