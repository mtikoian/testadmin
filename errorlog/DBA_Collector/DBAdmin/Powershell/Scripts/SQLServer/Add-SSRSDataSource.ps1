<#
.SYNOPSIS
   Used to automate various parts of setting up accounts for SSRS Data Connections.
.DESCRIPTION
   The script creates accounts to be used for SSRS data connections.
   
   The script uses the following logic in the account creation:
   
   1. The account is created in the OU designated in the '$script:ConfigSettings[$Environment]["OUPath"]' variable.
   2. The account is locked down to only log into the computers designated in the '$script:ConfigSettings[$Environment]["LogonServer"]' variable.
   3. The account is added to the security group designated in the '$script:ConfigSettings[$Environment]["SecurityGroup"]' variable.
.PARAMETER AccountName
    The name of the account to create, which will be used as the data source connection account.
.PARAMETER Environment
    The key name of the environment to create the data source in. For possible options, open the script and look at the "$script:ConfigSettings" variable.
.PARAMETER DataSourceName
    The name of the data source to create.
.PARAMETER ServerName
    The name of the SQL Server to connect the data source to.
.PARAMETER DatabaseName
    The name of the database to connect the data source to.
   
#>

[Cmdletbinding()]
param
(
	[parameter(mandatory=$true)]
	[string]$AccountName,
  [parameter(mandatory=$true)]
  [string]$Environment,
  [parameter(mandatory=$true)]
  [string]$DataSourceName,
  [parameter(mandatory=$true)]
  [string]$ServerName,
  [parameter(mandatory=$true)]
  [string]$DatabaseName
)

Set-StrictMode -Version 2.0;

#region Configuration Settings
#############################
# Configuration Variables   #
#############################

# A series of configuration settings that can be changed based on environment setups.
$script:ConfigSettings = @{
  "2008" = @{
    "LogonServer" = "seivmedevrs01","seivmedevrs02"
    "OUPath" = "OU=SSRS Data Connection Accounts,OU=Users,OU=EDEV,DC=ctc,DC=seic,DC=com"
    "SecurityGroup" = "CN=SSRS_DC_Accounts,OU=SSRS Data Connection Accounts,OU=Users,OU=EDEV,DC=ctc,DC=seic,DC=com"
    "URL" = "ssrsdev.ctc.seic.com"
    "DSPath" = "/Data Sources"
  }
  "2008R2 Dev" = @{
    "LogonServer" = "seivmedevdb03"
    "OUPath" = "OU=SSRS Data Connection Accounts,OU=Users,OU=EDEV,DC=ctc,DC=seic,DC=com"
    "SecurityGroup" = "CN=SSRS_R2_Dev_DC_Accounts,OU=SSRS Data Connection Accounts,OU=Users,OU=EDEV,DC=ctc,DC=seic,DC=com"
    "URL" = "10.52.71.13"
    "DSPath" = "/Data Sources"
  }
  "2008R2 UAT" = @{
    "LogonServer" = "edevrs2k8r2-01","edevrs2k8r2-02"
    "OUPath" = "OU=SSRS Data Connection Accounts,OU=Users,OU=EDEV,DC=ctc,DC=seic,DC=com"
    "SecurityGroup" = "CN=SSRS_R2_UAT_DC_Accounts,OU=SSRS Data Connection Accounts,OU=Users,OU=EDEV,DC=ctc,DC=seic,DC=com"
    "URL" = "10.52.71.20"
    "DSPath" = "/Data Sources"
  }
}
#endregion
#region Internal functions

function Create-Account
{

	[Cmdletbinding()]
	param()

	# Variable declaration
	$AccountPassword = "";
	$AccountInformation = @{};
	$createUserParams = @{};
  $outputMessage = "";


	try
	{
		# Initialize variables
		$AccountPassword = [System.Guid]::NewGuid().ToString().Substring(0,12);
    Write-Verbose "Account password is '$AccountPassword'"

		# Add the generated information to the script level variable to hold the information
        $AccountInformation.Add("AccountName",$AccountName);
		$AccountInformation.Add("AccountPassword",$AccountPassword);

		# Create the SQL Server account
		Write-Verbose "Password for SQL Server account is '$AccountPassword'";
        #$sqlServerAccountPassword = ConvertTo-SecureString -AsPlainText -Force -String $sqlServerAccountPassword;
		$createUserParams = @{
			"ADAccountName" = $AccountName
			"ADAccountPassword" = $AccountPassword
			"LogonWorkstations" = $script:ConfigSettings[$Environment]["LogonServer"]
            "ADOUPath" = $script:ConfigSettings[$Environment]["OUPath"]
			"ADAccountDisplayName" = "SSRS Data Source account for server $ServerName, $Environment"
		};
    Write-Verbose "Creating account $AccountName"
    New-ADAccount @createUserParams;
		
	#Add it to the SQL Server Account group
    Write-Verbose "Adding $AccountName to group."
	$sqlServerGroup = [ADSI]"LDAP://$($script:ConfigSettings[$Environment][`"SecurityGroup`"])"
	if (-not $sqlServerGroup.member -contains "CN=$AccountName,$($script:ConfigSettings[$Environment][`"OUPath`"])")
    {
      $return = $sqlServerGroup.Add("LDAP://CN=$AccountName,$($script:ConfigSettings[$Environment][`"OUPath`"])")
    }

	Write-Output $AccountInformation
  
  }
	catch
	{
		throw $_.Exception.Message
	}
}

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
	$ds = New-Object System.DirectoryServices.DirectorySearcher $de
  $ds.Filter = "CN=$ADAccountName"
  
  $user = $ds.FindOne()
	
  if ($user -eq $null)
  {
    Write-Verbose "Adding user '$ADAccountName' to domain"
    $user = $de.children.Add("CN=$ADAccountName","user")
  	$return = $user.put("SAMAccountName","$ADAccountName")
  	$return = $user.CommitChanges()
  }
  else
  {
    Write-Verbose "User '$AdAccountName' already exists. Password will be reset."
    $user = $user.GetDirectoryEntry()
  }
	
  Write-Verbose "Setting additional account parameters."
	$user.userWorkstations = [String]::Join(",",$LogonWorkstations)
  $user.userPrincipalName = $ADAccountName + "@" + [String]::Join(".",([Regex]::Matches($ADOUPath,"DC=([^,]+)")| %{ $_.Value.Replace("DC=","")}))
	$user.userAccountControl = 0x10200
	$user.DisplayName = $ADAccountDisplayName
	$return = $user.Invoke("SetPassword","$ADAccountPassword")
	
  Write-Verbose "Committing user changes."
	$return = $user.CommitChanges()
	
}

<#
.SYNOPSIS
 Gets a ReportServer web service object.
.PARAMETER ServerName
 The name of the server to create the web service proxy against. Can also be an existing 
 proxy object, in which case nothing is done. This is to allow for easier downstream use.
#>
function Get-RSServer
{

  param
  (
    [parameter(mandatory=$true)][Object]$ReportServer
  )

  Set-StrictMode -Version "Latest";
  
  switch -wildcard ($ReportServer.GetType().Name)
  {
    "ReportingServ*" {}
    "String"{
      $uri = "http://$ReportServer/ReportServer/ReportService2005.asmx";
      $ReportServer = New-WebServiceProxy -Uri $uri -UseDefaultCredential;
    }
  }
  
  #Yes, we are adding the object to itself as a property. This is to allow for downstream compatibility
  #with other functions for pipeline calls.
  $reportServer | Add-Member -MemberType "NoteProperty" -Name "ReportServer" -Value $reportServer -Force;
  
  Write-Output $reportServer;
  
}

<#
.SYNOPSIS
  Creates a new Report Server data source.
.PARAMETER ReportServer
  The name of the report server to connect to. Can also be passed as a property of a pipeline object.
.PARAMETER Path
  The path at which to create the data source. Can also be passed as a property of a pipeline object.
.PARAMETER Name
  The name of the data source to be created.
.PARAMETER ConnectionString
  The connection string of the data source. Reference http://connectionstrings.com/ for examples.
.PARAMETER Extension
  The name of the extension to use for the data source. Defaults to "SQL".
.PARAMTEER UserName
  The user name of the stored credential.
.PARAMETER Password
  The password of the stored credenital.
.PARAMETER WindowsCredentials
  If specified the credentials passed in will be set as Windows credentials.
.PARAMETER Force
  If specified the function will over-write an existing data source if one exists.

#>
function New-RSDataSource 
{

  [CmdletBinding()]
  param
  (
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [object]$ReportServer,
    [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [string]$Path = "/",
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Name,
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$ConnectionString,
    [parameter(mandatory=$false)]
    [string]$Extension = "SQL",
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$UserName,
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$Password,
    [parameter(mandatory=$false)]
    [switch]$WindowsCredentials,
    [parameter(mandatory=$false)]
    [switch]$Force
  )
  process
  {
    #Pass the ReportServer object to through the Get-ReportServer function.
    #This is so that even if a string is passed, a ReportServer proxy object will be generated.
    Write-Verbose "Getting Report Server connection to $ReportServer"
    $ReportServer = Get-RSServer -ReportServer $ReportServer;
  
    #Create the datastore definition object
    $Namespace = $ReportServer.GetType().Namespace
    $dsDef = New-Object "$Namespace.DataSourceDefinition"
    $dsDef.ConnectString = $ConnectionString
    $dsDef.Extension = $Extension
    $dsDef.ImpersonateUserSpecified = $false
    $dsDef.UserName = $UserName
    $dsDef.Password = $Password
    $dsDef.WindowsCredentials = $WindowsCredentials
    $dsDef.CredentialRetrieval = "Store"
    
    #Create the datasource
    Write-Verbose "Creating data source"
    $ReportServer.CreateDataSource($Name,$Path,$Force,$dsDef,$null)
  }
  
}

#endregion

try
{
  $AccountInfo = Create-Account
  
  # Workaround for mysterious null value in pipeline
  if ($AccountInfo.Count -gt 2)
  {
    $AccountInfo = $AccountInfo[1]
  }

  $ConnectionString = "Data Source=$ServerName;Initial Catalog=$DatabaseName"
  
  $newDSParams = @{
    "ReportServer" = $ConfigSettings[$Environment]["URL"]
    "Path" = $ConfigSettings[$Environment]["DSPath"]
    "Name" = $DataSourceName
    "ConnectionString" = $ConnectionString
    "UserName" = $AccountInfo["AccountName"]
    "Password" = $AccountInfo["AccountPassword"]
    "WindowsCredentials" = $true
  }
  
  New-RSDataSource @newDSParams
}
catch
{
  Write-Warning $_.Exception.Message
}

