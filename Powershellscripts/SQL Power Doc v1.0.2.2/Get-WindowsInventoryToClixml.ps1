<#
	.SYNOPSIS
		Collects comprehensive information about hosts running Microsoft Windows and saves the result to a file.

	.DESCRIPTION
		This script leverages the NetworkScan and WindowsInventory modules along with Windows Management Instrumentation (WMI) to scan for and collect comprehensive information about hosts running a Windows Operating System and save the results to a file in PowerShell's CLIXML format.
		
		This script can can find, verify, and collect information by Computer Name, Subnet Scan, or Active Directory DNS query.
		
		This script collects information from Windows 2000 or higher.
						
	.PARAMETER  DnsServer
		'Automatic', or the Name or IP address of an Active Directory DNS server to query for a list of hosts to inventory.
		
		When 'Automatic' is specified the function will use WMI queries to discover the current computer's DNS server(s) to query.

	.PARAMETER  DnsDomain
		'Automatic' or the Active Directory domain name to use when querying DNS for a list of hosts.
		
		When 'Automatic' is specified the function will use the current computer's AD domain.
		
		'Automatic' will be used by default if DnsServer is specified but DnsDomain is not provided.
		
	.PARAMETER  Subnet
		'Automatic' or a comma delimited list of subnets (in CIDR notation) to scan for hosts to inventory.
		
		When 'Automatic' is specified the function will use the current computer's IP configuration to determine subnets to scan. 
		
		A quick refresher on CIDR notation:

			BITS	SUBNET MASK			USABLE HOSTS PER SUBNET
			----	---------------		-----------------------
			/20		255.255.240.0		4094
			/21		255.255.248.0		2046 
			/22		255.255.252.0		1022
			/23		255.255.254.0		510 
			/24		255.255.255.0		254 
			/25		255.255.255.128		126 
			/26		255.255.255.192		62
			/27		255.255.255.224		30
			/28		255.255.255.240		14
			/29		255.255.255.248		6
			/30		255.255.255.252		2
			/32		255.255.255.255		1		

	.PARAMETER  ComputerName
		A comma delimited list of computer names to inventory.
	
	.PARAMETER  ExcludeSubnet
		A comma delimited list of subnets (in CIDR notation) to exclude when testing for connectivity.
		
	.PARAMETER  LimitSubnet
		A comma delimited list of subnets (in CIDR notation) to limit the scope of connectivity tests. Only hosts with IP Addresses that fall within the specified subnet(s) will be included in the results.

	.PARAMETER  ExcludeComputerName
		A comma delimited list of computer names to exclude when testing for connectivity. Wildcards are accepted.
		
		An attempt will be made to resolve the IP Address(es) for each computer in this list and those addresses will also be used when determining if a host should be included or excluded when testing for connectivity.		

	.PARAMETER  MaxConcurrencyThrottle
		Number between 1-100 to indicate how many instances to collect information from concurrently.

		If not provided then the number of logical CPUs present to your session will be used.

	.PARAMETER  PrivateOnly
		Restrict inventory to instances on private class A, B, or C IP addresses

	.PARAMETER  AdditionalData
		A comma delimited list of additional data to collect as part of the Inventory.
		
		Valid values include: AdditionalHardware, BIOS, DesktopSessions, EventLog, FullyQualifiedDomainName, InstalledApplications, InstalledPatches, IPRoutes, LastLoggedOnUser, LocalGroups, LocalUserAccounts, None, PowerPlans, Printers, PrintSpoolerLocation, Processes, ProductKeys, RegistrySize, Services, Shares, StartupCommands, WindowsComponents
		
		Use "None" to bypass collecting all additional information.
		
		The default value is all listed values excluding "None"	

	.PARAMETER  DirectoryPath
		Specifies the literal path to the directory where the inventory file and log file will be written.
		
		If not specified then the script defaults to your "My Documents" folder.		

	.PARAMETER  LoggingPreference
		Specifies the logging verbosity to use when writing log entries.
		
		Valid values include: None, Standard, Verbose, and Debug.
		
		The default value is "None"

	.PARAMETER  Zip
		Combine the Inventory and Log files into a single compressed ZIP file. This is useful for transferring the output of an inventory to another machine for further analysis.

		
	.EXAMPLE
		.\Get-WindowsInventoryToClixml.psm1 -DNSServer automatic -DNSDomain automatic -PrivateOnly
		
		Description
		-----------
		Collect an inventory by querying Active Directory for a list of hosts to scan for Windows machines. The list of hosts will be restricted to private IP addresses only.
		
		The Inventory file will be written to your "My Documents" folder.
		
		No Log file will be written.
		
	.EXAMPLE
		.\Get-WindowsInventoryToClixml.psm1 -Subnet 172.20.40.0/28 -LoggingPreference Standard
		
		Description
		-----------
		Collect an inventory by scanning all hosts in the subnet 172.20.40.0/28 for Windows machines.
		
		The Inventory and Log files will be written to your "My Documents" folder.
		
		Standard logging will be used.		
		
	.EXAMPLE
		.\Get-WindowsInventoryToClixml.psm1 -Computername Server1,Server2,Server3
		
		Description
		-----------
		Collect an inventory by scanning Server1, Server2, and Server3 for Windows machines.

		The Inventory file will be written to your "My Documents" folder.
		
		No Log file will be written.
		
	.EXAMPLE
		.\Get-WindowsInventoryToClixml.psm1 -Computername $env:COMPUTERNAME -AdditionalData None -LoggingPreference Verbose
		
		Description
		-----------
		Collect an inventory by scanning the local machine for Windows machines.
		
		Do not collect any data beyond the core set of information.

		The Inventory and Log files will be written to your "My Documents" folder.
		
		Verbose logging will be used.
		

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES

	.LINK
		.\Convert-WindowsInventoryClixmlToExcel.ps1

#>
[cmdletBinding(SupportsShouldProcess=$false, DefaultParametersetName='dns')]
param(
	[Parameter(
		Mandatory=$true,
		ParameterSetName='dns',
		HelpMessage='DNS Server(s)'
	)] 
	[alias('dns')]
	[ValidatePattern('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$|^auto$|^automatic$')]
	[string[]]
	$DnsServer = 'automatic'
	,
	[Parameter(
		Mandatory=$false,
		ParameterSetName='dns',
		HelpMessage='DNS Domain Name'
	)] 
	[alias("domain")]
	[string]
	$DnsDomain = 'automatic'
	,
	[Parameter(
		Mandatory=$true,
		ParameterSetName='subnet',
		HelpMessage='Subnet (in CIDR notation)'
	)]
	[ValidatePattern('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)[\\/]\d{1,2}$|^auto$|^automatic$')]
	[string[]]
	$Subnet = 'automatic'
	,
	[Parameter(
		Mandatory=$true,
		ParameterSetName='computername',
		HelpMessage='Computer Name(s)'
	)] 
	[alias('computer')]
	[string[]]
	$ComputerName
	,
	[Parameter(Mandatory=$false, ParameterSetName='dns')]
	[Parameter(Mandatory=$false, ParameterSetName='subnet')]
	[ValidatePattern('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)[\\/]\d{1,2}$')]
	[string[]]
	$ExcludeSubnet
	,
	[Parameter(Mandatory=$false, ParameterSetName='dns')]
	[ValidatePattern('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)[\\/]\d{1,2}$')]
	[string[]]
	$LimitSubnet
	,
	[Parameter(Mandatory=$false, ParameterSetName='dns')]
	[Parameter(Mandatory=$false, ParameterSetName='subnet')]
	[string[]]
	$ExcludeComputerName
	,
	[Parameter(Mandatory=$false)] 
	[ValidateRange(1,100)]
	[byte]
	$MaxConcurrencyThrottle = $env:NUMBER_OF_PROCESSORS
	,
	[Parameter(Mandatory=$false)] 
	[switch]
	$PrivateOnly = $false
	,
	[Parameter(Mandatory=$false)] 
	[alias('data')]
	[ValidateSet('AdditionalHardware','All','BIOS','DesktopSessions','EventLog','FullyQualifiedDomainName','InstalledApplications','InstalledPatches','IPRoutes', `
		'LastLoggedOnUser','LocalGroups','LocalUserAccounts','None','PowerPlans','Printers','PrintSpoolerLocation','Processes', `
		'ProductKeys','RegistrySize','Services','Shares','StartupCommands','WindowsComponents')]
	[string[]]
	$AdditionalData = @('None')
	,
	[Parameter(Mandatory=$false)] 
	[alias('Directory','Path')]
	[ValidateNotNullOrEmpty()]
	[string]
	$DirectoryPath = ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments))
	,
	[Parameter(Mandatory=$false)] 
	[alias('LogLevel')]
	[ValidateSet('none','standard','verbose','debug')]
	[string]
	$LoggingPreference = 'none'
	,
	[Parameter(Mandatory=$false)] 
	[switch]
	$Zip = $false 
)


######################
# FUNCTIONS
######################

function Write-LogMessage {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Message
		,
		[Parameter(Position=1, Mandatory=$true)] 
		[alias('level')]
		[ValidateSet('information','verbose','debug','error','warning')]
		[System.String]
		$MessageLevel
	)
	try {
		if ((Test-Path -Path 'function:Write-Log') -eq $true) {
			Write-Log -Message $Message -MessageLevel $MessageLevel
		} else {
			Write-Host $Message
		}
	}
	catch {
		Throw
	}
}


function Test-FileIsOpen {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param(
		[Parameter(Position=0, Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[System.String]
		$Path
	)
	process {
		$FileIsOpen = $false
		$Filestream = $null

		try {
			$Filestream = [System.IO.File]::Open($ZipFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
			$Filestream.Close()
			Write-Output $false
		}
		catch {
			Write-Output $true
		}
	}
}


######################
# VARIABLES
######################

$Inventory = $null
$ParameterHash = $null
[String]$ZipFilePath = $null
$ZipFile = $null

$BasePath = (Join-Path -Path $DirectoryPath -ChildPath ('Windows Inventory - ' + (Get-Date -Format 'yyyy-MM-dd-HH-mm')))
$CliXmlPath = [System.IO.Path]::ChangeExtension($BasePath, 'xml')
$LogPath = [System.IO.Path]::ChangeExtension($BasePath, 'log')
$ZipFilePath = [System.IO.Path]::ChangeExtension($BasePath,'zip')

# Fallback in case value isn't supplied or somehow missing from the environment variables
if (-not $MaxConcurrencyThrottle) { $MaxConcurrencyThrottle = 1 }

######################
# BEGIN SCRIPT
######################

# Import Modules that we need
Import-Module -Name LogHelper, WindowsInventory


# Set logging variables
Set-LogFile -Path $LogPath
Set-LoggingPreference -Preference $LoggingPreference

Write-LogMessage -Message "Starting Script: $($MyInvocation.MyCommand.Path)" -MessageLevel Information


# Build inventory collection command parameters
$ParameterHash = @{
	MaxConcurrencyThrottle = $MaxConcurrencyThrottle
	PrivateOnly = $PrivateOnly
	AdditionalData = $AdditionalData
}

switch ($PsCmdlet.ParameterSetName) {
	'dns' {
		$ParameterHash.Add('DnsServer',$DnsServer)
		$ParameterHash.Add('DnsDomain',$DnsDomain)
		if ($ExcludeSubnet) { $ParameterHash.Add('ExcludeSubnet',$ExcludeSubnet) }
		if ($LimitSubnet) { $ParameterHash.Add('IncludeSubnet',$LimitSubnet) }
		if ($ExcludeComputerName) { $ParameterHash.Add('ExcludeComputerName',$ExcludeComputerName) }
	}
	'subnet' {
		$ParameterHash.Add('Subnet',$Subnet)
		if ($ExcludeSubnet) { $ParameterHash.Add('ExcludeSubnet',$ExcludeSubnet) }
		if ($ExcludeComputerName) { $ParameterHash.Add('ExcludeComputerName',$ExcludeComputerName) }
	}
	'computername' {
		$ParameterHash.Add('ComputerName',$ComputerName)
	}
}


# Collect inventory and export results to Excel (if there are results in the inventory collection)
$Inventory = Get-WindowsInventory @ParameterHash

if ($Inventory.ScanSuccessCount -gt 0) {
	$Inventory | Export-Clixml -Path $CliXmlPath -Force -Depth 100 -Encoding UTF8
} else {
	Write-LogMessage -Message 'No machines found!' -MessageLevel Warning
}

Write-LogMessage -Message "End Script: $($MyInvocation.MyCommand.Path)" -MessageLevel Information


# Try to create compressed file if the option was specified and a log or CliXml file was created
if (($Zip -eq $true) -and ((Test-Path -Path $LogPath) -or (Test-Path -Path $CliXmlPath))) {

	# Create the zip file; if it already exists write a message to the console and skip this part
	if ((Test-Path -Path $ZipFilePath) -ne $true) {

		Set-Content -Path $ZipFilePath -Value ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		$ZipFile = (New-Object -ComObject Shell.Application).NameSpace($ZipFilePath)

		# Add log file if it exists
		if (($LoggingPreference -ine 'none') -and (Test-Path -Path $LogPath)) { 
			$ZipFile.CopyHere($LogPath)

			Start-Sleep -Milliseconds 500
			while (Test-FileIsOpen -Path $ZipFilePath) {
				Start-Sleep -Seconds 1
			}
		}

		# Add CliXml file if it exists
		if (Test-Path -Path $CliXmlPath) { 
			$ZipFile.CopyHere($CliXmlPath) 

			Start-Sleep -Milliseconds 500
			while (Test-FileIsOpen -Path $ZipFilePath) {
				Start-Sleep -Seconds 1
			} 
		}

		# Remove reference to zip file
		$ZipFile = $null

	} else {
		Write-LogMessage -Message "Unable to compress files - '$ZipFilePath' already exists" -MessageLevel Error
	}
}


# Remove Variables
Remove-Variable -Name Inventory, ParameterHash, ZipFilePath, ZipFile, BasePath, CliXmlPath, LogPath

# Remove Modules
Remove-Module -Name WindowsInventory, LogHelper

# Call garbage collector
[System.GC]::Collect()
