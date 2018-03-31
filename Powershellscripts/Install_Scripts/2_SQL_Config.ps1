<#
.SYNOPSIS 
Default setup configuration for SQL Server 2012 Std

.DESCRIPTION
Full Description

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $SQLServiceAcct
SQL Server Database Engine Service Account, use Domain\user syntax.

.PARAMETER $BackupPath
UNC or local path for Default Backup Location, use "G:\folder" or "\\backup_server\backup_share" syntax.

.PARAMETER $SQLAdmin
Email account for server alerts to be sent to, use "user@domain" syntax.  Used in the "SQL_Admin" Operator account.

.PARAMETER $SSISDBpwd
Encryption password for SSISDB database.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\SQL_Config.ps1 -SQLServer "SQL01" -SQLServiceAcct "Mydomain\sql_svc_acct" -BackupPath "\\backup_server\backup_share\SQLServername" -SQLAdmin "SQL_Admins@domain" -SSISDBpwd "encryption_pwd"

#>

Param ([string]$SQLServer = $env:COMPUTERNAME,
		[string]$SQLServiceAcct = "domain\username",
		[string]$SQLAgent = "domain\username",
		[string]$BackupPath = "H:\Backups",
		[string]$SQLAdmin = "SQLAdmins@domain",
		[string]$SSISDBpwd = "asdf1234!@#$",
		[string]$MasterKeyPwd = "ASDF1234!@#$",
		[string]$BackupKeyPwd = "ASDF1234!@#$",
		[string]$BackupKeyEncPwd = "asdf1234!@#$"
)

###############################################################################################
# Notes:                                                                                      #
# 1. Modify account & server information in the Database Mail section where needed            #
# 2. Use actual server name if registering SPNs.  '.' does not translate for SPN registration #
# 3. Modify SPN information below if installing SSRS or SSAS                                  #
###############################################################################################

$installStart = Get-Date -Format g

# Set path location of script files 
[string]$BasePath = "C:\Temp";
$ScriptPath = "C:\Temp\Config_Scripts";

Import-Module SQLPS

#################################
# Configure default backup path #
#################################
$continue = Read-Host "Verify SQL Service Acct has permissions to default backup path.
Press ENTER to Continue"
write-output "Configure default backup path";
$query = @"
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory', REG_SZ, N'$BackupPath'
GO
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

#######################
#  Set Server Memory  #
#######################
write-output "Setting min/max server memory";
Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile $ScriptPath`\SQL_Memory.sql -Verbose

#######################
#  Rename SA Account  #
#######################
# Note: Appending 'sa' to variable $SQLServer directly in sqlcmd results in a positional parameter error.
write-output "Updating SA login";
$query = '"ALTER LOGIN sa WITH NAME = [' + $SQLServer + 'sa]"'; 
$P_query = "sqlps  -Command {
	Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query
	}";
Invoke-expression $P_query;

####################################
# Create additional login accounts #
####################################
write-output "Create SQL Login Accounts" # monitoring accounts, backup operators, etc.
Invoke-Sqlcmd -ServerInstance $SQLServer -Query "CREATE LOGIN [domain\group] FROM WINDOWS;"
Invoke-Sqlcmd -ServerInstance $SQLServer -Query "ALTER SERVER ROLE [sysadmin] ADD MEMBER [domain\group];"

##############################
#  Start SQL Agent Services  #
##############################
write-output "Start SQL Agent";
Invoke-Command -ComputerName $SQLServer -ScriptBlock {
	$agentservice = get-service "SQL Server Agent (MSSQLSERVER)" -ErrorAction SilentlyContinue 
		if ( $agentservice.status -eq "Stopped" )
		 {
				 "Restarting Service…"
				 start-service $agentservice.name
				 "Service Started"
		 }
};

################################# 
#  Create SQL Server Operators  #
#################################
write-output "Create Operators";
$SQLOperator = @"
EXEC msdb.dbo.sp_add_operator @name=N'SQLServerAdmins', 
	@enabled=1, 
	@weekday_pager_start_time=90000, 
	@weekday_pager_end_time=180000, 
	@saturday_pager_start_time=90000, 
	@saturday_pager_end_time=180000, 
	@sunday_pager_start_time=90000, 
	@sunday_pager_end_time=180000, 
	@pager_days=0, 
	@email_address=N'$SQLAdmin', 
	@category_name=N'[Uncategorized]'
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $SQLOperator -Verbose;

##########################
#  Enable Database Mail  #
##########################
write-output "Enable DBMail";
$query = @"
sp_configure 'show advanced options',1
go
reconfigure with override
go
sp_configure 'Database Mail XPs',1
 go
reconfigure
 
 -- Create a Database Mail accounts
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'SQL_Admin (SMTP)',
    @description = 'Mail account for administrative e-mail.',
    @email_address = 'SQL_Admin@domain',
    @display_name = '$SQLServer Admin',
    @mailserver_name = 'smtp.domain' ;

	-- Create a Database Mail profile
EXECUTE msdb.dbo.sysmail_add_profile_sp
    @profile_name = 'SQL_Admin',
    @description = 'Profile used for administrative mail.' ;

-- Add the accounts to the profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'SQL_Admin',
    @account_name = 'SQL_Admin (SMTP)',
    @sequence_number =1 ;

-- Grant access to the profile to all users in the msdb database
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'SQL_Admin',
    @principal_name = 'public',
    @is_default = 1 ;
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

##############################################
#  Enable Contained Database Authentication  #
##############################################
write-output "Enable Contained DB Authentication";
$query = @"
EXEC sys.sp_configure N'contained database authentication', N'1'
GO
RECONFIGURE WITH OVERRIDE;
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

#########################
#  Configure SQL Agent  #
#########################
write-output "Configure SQL Agent";
$query = @"
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N'SQLServerAdmins', @notificationmethod=1;
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1, @databasemail_profile=N'SQL_Admin', @use_databasemail=1;
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;
        
##############################
#  Create SQL Server Alerts  #
##############################
write-output "Create SQL Server Alerts";
Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile "$ScriptPath\Alerts_Triggers.sql" -Verbose;

# Create Index & Stats Maintenance Job
write-output "Create Disk Space Alert Job";
$path = Join-Path $ScriptPath "\Disk_Space_Alert.ps1";
. $path -SQLServer $SQLServer;
# Create VLF Count Alert
write-output "Create VLF Alert";
$path = Join-Path $ScriptPath "\VLF_Alert.ps1";
. $path -SQLServer $SQLServer;

####################################################################
#  Import Ola Hallengren's Maintenance Procs to MSDB & Create Jobs #
####################################################################
# download the SQL Maintenance Solution scripts at http://ola.hallengren.com

write-output "Import Ola Hallengren's SPs";
Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile "$ScriptPath\CommandExecute.sql" -Verbose;
Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile "$ScriptPath\DatabaseIntegrityCheck.sql" -Verbose;
Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile "$ScriptPath\IndexOptimize.sql" -Verbose;
Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile "$ScriptPath\DatabaseBackup.sql" -Verbose;

# Create Database Integrity Job
write-output "Create Database Integrity Job";
$path = Join-Path $ScriptPath "\Database_Integrity_Job.ps1";
 . $path -SQLServer $SQLServer ;
# Create Index & Stats Maintenance Job
write-output "Create Index & Stats Maintenance Job";
$path = Join-Path $ScriptPath "\Index_Maintenance_Job.ps1";
. $path -SQLServer $SQLServer;

######################
# Create Backup Jobs #
######################
write-output "Create Full Backup Job";
$path = Join-Path $ScriptPath "\Full_Backup_Job.ps1";
. $path -SQLServer $SQLServer;

write-output "Create Log Backup Job";
$path = Join-Path $ScriptPath "\Log_Backup_Job.ps1";
. $path -SQLServer $SQLServer;

##############
# Custom SPs #
##############
write-output "Import Custom SPs";
# Import any custom Stored Procedures that should be on all servers;

########################### 
#  Modify Model Database  #
###########################
write-output "Set Model DB Size";
$query = @"
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', SIZE = 51200KB , FILEGROWTH = 51200KB );
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modellog', SIZE = 51200KB , FILEGROWTH = 10240KB );
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

########################## 
#  Modify Temp Database  #
##########################
write-output "Set Temp DB File Size";
$query = @"
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', SIZE = 512000KB , FILEGROWTH = 512000KB );
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'templog', SIZE = 102400KB , FILEGROWTH = 102400KB );
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

write-output "Create Additional Temp DB Data Files";
$path = Join-Path $ScriptPath "\Create_TempDB_Files.ps1";
. $path -SQLServer $SQLServer;

#############################################################
# Create Security Audit for Password and Permission Changes #
#############################################################
write-output "Configure Auditing to Security Log";
Invoke-Sqlcmd -ServerInstance $SQLServer -InputFile "$ScriptPath\Audit.sql" -Verbose;

#################
# Register SPNs #
#################

# Check domain membership
If ($SQLServer -eq $env:COMPUTERNAME) {
If ((gwmi win32_computersystem).partofdomain -eq $true) {
write-output "Register SPN";

$P_query = 'setspn -S MSSQLSvc/' + $SQLServer + '.' + $env:userdnsdomain +':1433 -U ' + $SQLServiceAcct + ';
setspn -S MSSQLSvc/' + $SQLServer + '.' + $env:userdnsdomain + ' -U ' + $SQLServiceAcct + ';
setspn -S MSSQLSvc/' + $SQLServer + ':1433 -U ' + $SQLServiceAcct + ';
setspn -S MSSQLSvc/' + $SQLServer + ' -U ' + $SQLServiceAcct + ';';
Invoke-Expression $P_query;

## SSRS SPNs
#write-output "Register SSRS SPN"
#$P_query = 'setspn -S HTTP/' + $SQLServer + '.' + $env:userdnsdomain +':1433 ' + $SQLServiceAcct + '
#setspn -S HTTP/' + $SQLServer + '.' + $env:userdnsdomain + ' ' + $SQLServiceAcct + ''
#Invoke-Expression $P_query;
## Set service account as trusted for delegation in AD
# Import-Module ActiveDirectory;
## Remove domain from username
# $TrustAcct = $SQLServiceAcct.split("\")[1]
# Set-ADAccountControl -Identity $TrustAcct -TrustedForDelegation $true;

# SSAS SPNs
#write-output "Register SSAS SPN";
#$P_query = 'setspn -S MSOLAPSvc.3/' + $SQLServer + '.' + $env:userdnsdomain +':1433 ' + $SQLServiceAcct + '
#setspn -S MSOLAPSvc.3/' + $SQLServer + '.' + $env:userdnsdomain + ' ' + $SQLServiceAcct + ''
#Invoke-Expression $P_query;
} 
else {
    write-host "Skipping SPN registration.  SQL Server is not joined to a domain."
}
}

########################################################
# Set Error Log Count to 40 & Create Job to cycle logs #
########################################################
write-output "Configure Error Logs";
$query = "EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 40";
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

# Create Cycle Error Log Job
$path = Join-Path $ScriptPath "\Configure_SQL_Error_Logs.ps1";
. $path -SQLServer $SQLServer;

#####################################
# Increase Max rows for Job History #
#####################################
write-output "Increase max rows for job history";
$query = 'EXEC msdb.dbo.sp_set_sqlagent_properties @jobhistory_max_rows_per_job=300';
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

###############################################
# Create SSISDB & Import Maintenance Projects #
###############################################
write-output "Enable CLR";
$query = @"
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

write-output "Creating SSISDB Catalog";
# Load the IntegrationServices Assembly
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices")
# Store the IntegrationServices Assembly namespace
$ISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"
# Create a connection to the server
$sqlConnectionString = "Data Source=" + $SQLServer + ";Initial Catalog=master;Integrated Security=SSPI;"
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString
# Create the Integration Services object
$integrationServices = New-Object $ISNamespace".IntegrationServices" $sqlConnection
# Create a new SSISDB Catalog
$catalog = New-Object $ISNamespace".Catalog" ($integrationServices, "SSISDB", "$SSISDBpwd")
$catalog.Create()
# Create Maintenance Packages folder
$folder = New-Object $ISNamespace".CatalogFolder" ($catalog, "Maintenance Packages", "SQL Server Maintenance Packages")
$folder.Create()

### Import Cleanup History Project & Create Job
write-output "Import Cleanup History Project & Create Job";
$Script = $ScriptPath + "\Cleanup History.ispac"
[byte[]] $ProjectFile = [System.IO.File]::ReadAllBytes($Script)            
$folder.DeployProject("Cleanup History", $ProjectFile) 
# Configure server name in package
$query = @"
DECLARE @var sql_variant = N'Data Source= $SQLServer;Integrated Security=SSPI;Connect Timeout=30;'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'Server_ConnectionString', @object_name=N'Package.dtsx', @folder_name=N'Maintenance Packages', @project_name=N'Cleanup History', @value_type=V, @parameter_value=@var
GO
DECLARE @var sql_variant = N'$SQLServer'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=30, @parameter_name=N'Server_ServerName', @object_name=N'Package.dtsx', @folder_name=N'Maintenance Packages', @project_name=N'Cleanup History', @value_type=V, @parameter_value=@var
"@;
Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose;

# Create Job
$path = Join-Path $ScriptPath "\Cleanup_History_Job.ps1";
. $path -SQLServer $SQLServer;

######################################
# Enable Instant File Initialization #
######################################
# download function at:																								   
# http://www.sqlservercentral.com/blogs/kyle-neier/2012/03/27/powershell-adding-accounts-to-local-security-policy/     
# adds SQL Service Acct to: Secpol.msc -> Local Policies -> User Rights Assignment -> Perform volume maintenance tasks 

write-output "Enable Instant File Initialization";
$path = Join-Path $ScriptPath "\Add-LoginToLocalPrivilege.ps1";
. $path Add-LoginToLocalPrivilege -DomainAccount $SQLServiceAcct -Privilege "SeManageVolumePrivilege" -Verbose;

##############################
# Create Cleanup_Backups Job #
##############################
$path = Join-Path $ScriptPath "\Delete_SQL_Backups_Job.ps1";
. $path  -SqlServer $SQLServer -Log "L:\SQLAgentLogs\Backups_Deleted.txt" -Owner "" -BackupUser $SQLAgent -BackupPath "$BackupPath\$SQLServer\*" -TLogDaysToKeep 4 -DiffDaysToKeep 14 -FullDaysToKeep 14 -FullWeeksToKeep 8 -WeekdayToKeep "Friday" -FullMonthsToKeep 6;

##############################
# Import Management Policies #
##############################
write-output "Import Management Policies";
$path = Join-Path $ScriptPath "\Import_Policy.ps1";

# Import Guest Permissions policy
write-output "Import Guest Policy";
$Policy = Join-Path $BasePath "\Policies\Guest Permissions.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

# Import Backup and Data File Location policy
write-output "Import Backup Location Policy";
$Policy = Join-Path $BasePath "\Policies\Backup and Data File Location.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

# Import Data and Log File Location policy
write-output "Import Data and Log File Location Policy";
$Policy = Join-Path $BasePath "\Policies\Data and Log File Location.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

# Import Database Auto Shrink policy
write-output "Import Database Auto Shrink Policy";
$Policy = Join-Path $BasePath "\Policies\Database Auto Shrink.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

# Import Database Page Verification policy
write-output "Import Database Page Verification Policy";
$Policy = Join-Path $BasePath "\Policies\Database Page Verification.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

# Import Last Log Backup Date policy
write-output "Import Last Log Backup Date Policy";
$Policy = Join-Path $BasePath "\Policies\Last Log Backup Date.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

# Import Last Successful Backup Date for System Databases policy
write-output "Import Last Successful Backup Date for System Databases Policy";
$Policy = Join-Path $BasePath "\Policies\Last Successful Backup Date for System Databases.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

# Import Last Successful Backup Date for non-DAG User Databases policy
write-output "Import Last Successful Backup Date for non-DAG User Databases Policy";
$Policy = Join-Path $BasePath "\Policies\Last Successful Backup Date for non-DAG User Databases.xml";
. $path  -SqlServer $SQLServer -PolicyPath $Policy;

#####################
# Backup Encryption #
#####################

write-output "Create Backup Encryption Key"
$masterKey = "CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$MasterKeyPwd';";
Invoke-sqlcmd -ServerInstance . -Query $masterKey

$serverCert = "CREATE CERTIFICATE $SQLServer`_DBBackupCert WITH SUBJECT = '$SQLServer Database Backup Certificate';";
Invoke-sqlcmd -ServerInstance . -Query $serverCert

$backupKey = "BACKUP SERVICE MASTER KEY TO FILE = 'C:\Temp\$SQLServer`_service_master.key' ENCRYPTION BY PASSWORD = '$BackupKeyPwd';"
Invoke-sqlcmd -ServerInstance . -Query $backupKey

$backupCert = "BACKUP CERTIFICATE $SQLServer`_DBBackupCert TO FILE = 'C:\Temp\$SQLServer`_DBBackupCert.cer' WITH PRIVATE KEY ( FILE = 'C:\Temp\$SQLServer`_DBBackupCertKey.key', ENCRYPTION BY PASSWORD = '$BackupKeyEncPwd');"
Invoke-sqlcmd -ServerInstance . -Query $backupCert

#######################################
# Enable Encrypted Client Connections #
#######################################

    write-output "Enable SSL encryption for SQL client connections using Self-Signed Certificate.";
    $regkey = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server" -Recurse | Where-Object {$_.Name -like "*SuperSocketNetLib"}
    Set-ItemProperty -path $regKey.PSPath -Name ForceEncryption -value "1";
    write-output "SQL service must be restarted before setting will take effect."
    Restart-Service MSSQLSERVER -Force;
    Write-Output "SQL Service restarted.";

###################################

$installEnd = Get-Date -Format g
$installElapsed = NEW-TIMESPAN –Start $installStart –End $installEnd
write-output "Elapsed Install Time: "
$installElapsed

#################
# Closing Notes #
#################
$continue = Read-Host "
Automated Setup Complete.
1. Add Backup Encryption Key to Password Vault.
2. Copy Backup Key and Certificate to Windump.
3. Import SSL Cert for client connections.
Press Enter to Close"
