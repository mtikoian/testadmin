<#
.SYNOPSIS 
Creates SQL folder structure.
Configures Windows OS and Installs a default instance of SQL Server.

.DESCRIPTION
Full Description

.PARAMETER $SQLServer
SQL Server Instance Name, "." for local server.

.PARAMETER $SQLInstaller
Path to SQL Server install media

.PARAMETER $ScriptPath
Path to folder containing ConfigurationFile.ini

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\SQL_Config.ps1 -SQLServer "SQL01" -SQLInstaller = "D:\setup.exe" -ScriptPath = "C:\Install_Temp\Config_Scripts"

#>

Param ([string]$SQLServer = ".",
	[string]$SQLInstaller = "D:\setup.exe",
	[string]$ScriptPath = "C:\Temp\Config_Scripts"

)

$installStart = Get-Date -Format g

########################
#  Create SQL Folders  #
########################

New-Item -ItemType directory -Path E:\SQL
New-Item -ItemType directory -Path F:\SQL_Data
New-Item -ItemType directory -Path G:\SQL_Logs
New-Item -ItemType directory -Path H:\SQLAgentLogs
New-Item -ItemType directory -Path H:\Backups
New-Item -ItemType directory -Path I:\Temp_DB

#####################################
#  Enable Powershell Remote Access  #
#####################################

Enable-PSRemoting –force

######################################################
## Allow SQL Server To Write Audits To Security Log ##
######################################################
write-output "Enable auditing to Security Log";
auditpol /set /subcategory:"application generated" /success:enable /failure:enable;
$continue = Read-Host "Add SQL Engine Account to Secpol.msc.  User Rights Assignment -> Generate Security Audits
Press ENTER to Continue";

#########################
## OPEN FIREWALL PORTS ##
#########################
write-output "Configure Firewall";
netsh advfirewall firewall add rule name="SQL Instances" dir=in action=allow protocol=TCP localport=1433;
netsh advfirewall firewall add rule name="SQL Browser" dir=in action=allow protocol=UDP localport=1434;
netsh advfirewall firewall add rule name="SQL Filetable" dir=in action=allow protocol=TCP localport="139,445";
netsh advfirewall firewall add rule name="SSIS" dir=in action=allow protocol=TCP localport=135;
netsh advfirewall firewall add rule name="SSIS" dir=in action=allow program="%ProgramFiles%\Microsoft SQL Server\110\DTS\Binn\MsDtsSrvr.exe" security=notrequired;

############################
## INSTALL .NET Framework ##
############################
write-output "Install .NET 3.5.1 Feature";
Import-Module ServerManager;

# Get Windows Server Version
$WindowsVersion = [environment]::OSVersion.Version

# Add .NET 3.5 to Windows Server 2008R2 and earlier
If (($WindowsVersion.Major -eq 6) -And ($WindowsVersion.Minor -lt 2)) {
	Add-WindowsFeature AS-Net-Framework;}
# Add .NET 3.5 to Windows Server 2012 and later	
ElseIf (($WindowsVersion.Major -eq 6) -And ($WindowsVersion.Minor -ge 2)) {
	Add-WindowsFeature Net-Framework-Core -Source D:\Sources\SxS\;}
	
######################
## INSTALL INSTANCE ##
######################
write-output "Begin SQL install"
$install = 'Start-Process -verb runas -FilePath "' + $SQLInstaller + '" -ArgumentList /ConfigurationFile="' + $ScriptPath + '\ConfigurationFile.ini" -Wait'
$install
Invoke-Expression $install

$installEnd = Get-Date -Format g
$installElapsed = NEW-TIMESPAN –Start $installStart –End $installEnd
write-output "Elapsed Install Time: "
$installElapsed