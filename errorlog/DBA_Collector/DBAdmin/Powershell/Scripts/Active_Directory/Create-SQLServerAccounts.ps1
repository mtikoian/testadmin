<#
.SYNOPSIS
   Used to automate various parts of setting up accounts for SQL Server services.
.DESCRIPTION
   The script creates the service accounts for both SQL Server and SQL Agent processes.
   
   The script will present the user with a basic GUI to input the name of the server on
   which SQL Server is to be installed.
   
   *Note: this has not been tested to work with virtual cluster names.
   
   The script uses the following logic in the account creation:
   
   1. The account name should be determined as:
    "svc" + <The ServerName parameter value> + "sql" - for SQL Server service
    "svc" + <The ServerName parameter value> + "agt" - for SQL Agent service
   2. The accounts should be placed in the OU in AD as specified by the "$script:OU" variable set
      in the "Configuration Variables" section.
   3. Passwords are randomly generated 12 character strings.
   4. The accounts should only be allowed to log on to the machine specified by the 
      ServerName input parameter.
   
#>

[Cmdletbinding()]
param
(
	[parameter(mandatory=$true)]
	[string]$SQLServerName
)

Set-StrictMode -Version 2.0;

#############################
# Configuration Variables   #
#############################

# The path to the OU to place the accounts in
$script:SQLServiceOU = "OU=SQL Service Accounts,OU=Users,OU=EDEV,DC=CTC,DC=SEIC,DC=COM";
$script:SQLAgentOU = "OU=SQL Agent Service Accounts,OU=Users,OU=EDEV,DC=CTC,DC=SEIC,DC=COM";

#region Internal functions

function Create-Account
{

	[Cmdletbinding()]
	param
	(
	[parameter(mandatory=$true)]
	[string]$SQLServerName
	)

	# Variable declaration
	$sqlServerAccountName = "";
	$sqlServerAccountPassword = "";
	$sqlAgentAccountName = "";
	$sqlAgentAccountPassword = "";
	$script:AccountInformation = @{};
	$createUserParams = @{};
  	$outputMessage = "";


	try
	{

		# Load required assembly
		[System.Reflection.Assembly]::LoadWithPartialName("System.Web");

		# Initialize variables
		$sqlServerAccountName = "svc" + $SQLServerName + "sql";
		$sqlServerAccountPassword = [System.Guid]::NewGuid();
		$sqlAgentAccountName = "svc" + $SQLServerName + "agt";
		$sqlAgentAccountPassword = [System.GUID]::NewGuid();

		# Add the generated information to the script level variable to hold the information
		$script:AccountInformation.Add("sqlServerAccountName",$sqlServerAccountName);
		$script:AccountInformation.Add("sqlAgentAccountName",$sqlAgentAccountName);
		$script:AccountInformation.Add("sqlServerAccountPassword",$sqlServerAccountPassword);
		$script:AccountInformation.Add("sqlAgentAccountPassword",$sqlAgentAccountPassword);

		# Create the SQL Server account
		Write-Verbose "Password for SQL Server account is $sqlServerAccountPassword;";
    #$sqlServerAccountPassword = ConvertTo-SecureString -AsPlainText -Force -String $sqlServerAccountPassword;
		$createUserParams = @{
			"ADAccountName" = $sqlServerAccountName
			"ADAccountPassword" = $sqlServerAccountPassword
			"LogonWorkstations" = $SQLServerName
      		"ADOUPath" = $script:SQLServiceOU
			"ADAccountDisplayName" = "$SQLServerName SQL Service Account"
		};
    	New-ADAccount @createUserParams;
		
		#Add it to the SQL Server Account group
		$sqlServerGroup = [ADSI]"LDAP://CN=SQL Service Accounts,$script:SQLServiceOU"
		$sqlServerGroup.Add("LDAP://CN=$sqlServerAccountName,$script:SQLServiceOU")


		# Create the SQL Agent account
		Write-Verbose "Password for SQL Agent account is $sqlAgentAccountPassword;"
		#$sqlAgentAccountPassword = ConvertTo-SecureString -AsPlainText -Force -String $sqlServerAccountPassword;
		$createUserParams = @{
			"ADAccountName" = $sqlAgentAccountName
			"ADAccountPassword" = $sqlAgentAccountPassword
			"LogonWorkstations" = $SQLServerName
      		"ADOUPath" = $script:SQLAgentOU
			"ADAccountDisplayName" = "$SQLServerName SQL Agent Account for"
		};
    	New-ADAccount @createUserParams;
		
		#Add it to the SQL Agent Account group
		$sqlAgentGroup = [ADSI]"LDAP://CN=SQL Agent Service Accounts,$script:SQLAgentOU"
		$sqlAgentGroup.Add("LDAP://CN=$sqlAgentAccountName,$script:SQLAgentOU")


		# Return zero exit
		return 0;

	}
	catch
	{
		$script:errorMessage = $_;
		return 1
	}
}

#endregion

function New-ADAccount
{
	[Cmdletbinding()]
	param
	(
		[parameter(mandatory=$true)]
		[string]$ADAccountName,
		[parameter(mandatory=$true)]
		[string]$ADAccountPassword,
		[parameter(mandatory=$true)]
		[string]$ADAccountDisplayName,
		[parameter(mandatory=$true)]
		[string]$ADOUPath,
		[parameter(mandatory=$true)]
		[string[]]$LogonWorkstations

	)
	
	$de = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$ADOUPath"
	
	$user = $de.children.Add("CN=$ADAccountName","user")
	$user.put("SAMAccountName","$ADAccountName")
	$user.CommitChanges()
	
	$user.userWorkstations = [String]::Join(",",$LogonWorkstations)
	$user.userAccountControl = 0x10200
	$user.DisplayName = $ADAccountDisplayName
	$user.Invoke("SetPassword","$ADAccountPassword")
	
	$user.CommitChanges()
	
}

# $vals = New-Grid -Show -Rows Auto,* -Columns 2 {
# 	New-Label -Column 0 -Row 0 -Content "SQL Server Name";
# 	New-TextBox -Column 1 -Row 0 -Name SQLServerName -Width 200;
# 
# 	New-Button -Column 0 -Row 1 -ColumnSpan 2 -Content "Create Accounts" -On_Click {
# 		Get-ParentControl | Set-UIValue -passThru | Close-Control;
# 	};
# };

$return = Create-Account -SQLServerName $SQLServerName
if ($return -eq 1)
{
  Write-Warning "Error occurred during processing."
  Write-Warning $script:ErrorMessage.Exception.Message
}