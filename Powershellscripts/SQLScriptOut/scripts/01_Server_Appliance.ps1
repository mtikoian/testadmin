﻿<#
.SYNOPSIS
    Gets the Hardware/Software config of the targeted SQL server
	
.DESCRIPTION
    This script lists the Hardware and Software installed on the targeted SQL Server
    CPU, RAM, DISK, Installation and Backup folders, SQL Version, Edition, Patch Levels, Cluster/HA
	
.EXAMPLE
    01_Server_Appliance.ps1 localhost
	
.EXAMPLE
    01_Server_Appliance.ps1 server01 sa password

.Inputs
    ServerName, [SQLUser], [SQLPassword]

.Outputs

	
.NOTES

	
.LINK

	
#>

Param(
    [parameter(Position=0,mandatory=$false,ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string]$SQLInstance='localhost',

    [parameter(Position=1,mandatory=$false,ValueFromPipeline)]
    [ValidateLength(0,20)]
    [string]$myuser,

    [parameter(Position=2,mandatory=$false,ValueFromPipeline)]
    [ValidateLength(0,35)]
    [string]$mypass
)

Set-StrictMode -Version latest;

[string]$BaseFolder = (Get-Item -Path ".\" -Verbose).FullName

# Import-Module "sqlps" -DisableNameChecking -erroraction SilentlyContinue
Import-Module ".\LoadSQLSMO"
LoadSQLSMO


#  Script Name
Write-Host -f Yellow -b Black "01 - Server Appliance"

# Usage Check
if ($SQLInstance.Length -eq 0) 
{
    Write-host -f yellow "Usage: ./01_Server_Appliance.ps1 `"SQLServerName`" ([`"Username`"] [`"Password`"] if DMZ machine)"
    Set-Location $BaseFolder
    exit
}

# Working
Write-Output "Server $SQLInstance"

# fix target servername if given a SQL named instance
$WinServer = ($SQLInstance -split {$_ -eq "," -or $_ -eq "\"})[0]


# Server connection check
[string]$serverauth = "win"
if ($mypass.Length -ge 1 -and $myuser.Length -ge 1) 
{
	Write-Output "Testing SQL Auth"
	try
    {
        $results = Invoke-SqlCmd -ServerInstance $SQLInstance -Query "select serverproperty('productversion')" -Username $myuser -Password $mypass -QueryTimeout 10 -erroraction SilentlyContinue
        if($results -ne $null)
        {
            $myver = $results.Column1
            Write-Output $myver
            $serverauth="sql"
        }	
	}
	catch
    {
		Write-Host -f red "$SQLInstance appears offline - Try Windows Auth?"
        Set-Location $BaseFolder
		exit
	}
}
else
{
	Write-Output "Testing Windows Auth"
 	Try
    {
        $results = Invoke-SqlCmd -ServerInstance $SQLInstance -Query "select serverproperty('productversion')" -QueryTimeout 10 -erroraction SilentlyContinue
        if($results -ne $null)
        {
            $myver = $results.Column1
            Write-Output $myver
        }
	}
	catch
    {
	    Write-Host -f red "$SQLInstance appears offline - Try SQL Auth?" 
        set-location $BaseFolder
	    exit
	}
}

# Create folder
$fullfolderPath = "$BaseFolder\$sqlinstance\01 - Server Appliance"
if(!(test-path -path $fullfolderPath))
{
	mkdir $fullfolderPath | Out-Null
}


# Set Local Vars
[string]$server = $SQLInstance

if ($serverauth -eq "win")
{
    $srv = New-Object "Microsoft.SqlServer.Management.SMO.Server" $server
}
else
{
    $srv = New-Object "Microsoft.SqlServer.Management.SMO.Server" $server
    $srv.ConnectionContext.LoginSecure=$false
    $srv.ConnectionContext.set_Login($myuser)
    $srv.ConnectionContext.set_Password($mypass)    
}


# Dump info to output file
$fullFileName = $fullfolderPath+"\Server_Appliance.txt"
New-Item $fullFileName -type file -force  |Out-Null
Add-Content -Value "Server Hardware and Software Capabilities for $SQLInstance `r`n" -Path $fullFileName -Encoding Ascii

# SQL
$mySQLQuery1 = 
"SELECT @@SERVERNAME AS [Server Name], create_date AS 'column1' 
FROM sys.server_principals WITH (NOLOCK)
WHERE name = N'NT AUTHORITY\SYSTEM'
OR name = N'NT AUTHORITY\NETWORK SERVICE' OPTION (RECOMPILE);
"

# connect correctly
if ($serverauth -eq "win")
{
    $sqlresults = Invoke-SqlCmd -ServerInstance $SQLInstance -Query $mySQLquery1 -QueryTimeout 10 -erroraction SilentlyContinue
}
else
{
    $sqlresults = Invoke-SqlCmd -ServerInstance $SQLInstance -Query $mySQLquery1 -Username $myuser -Password $mypass -QueryTimeout 10 -erroraction SilentlyContinue
}

$myCreateDate = $sqlresults.column1
$mystring =  "Server Create Date: " +$MyCreateDate
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "Server Name: " +$srv.Name 
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Version: " +$srv.Version 
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Edition: " +$srv.EngineEdition
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Build Number: " +$srv.BuildNumber
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Product: " +$srv.Product
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Product Level: " +$srv.ProductLevel
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Processors: " +$srv.Processors
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Max Physical Memory MB: " +$srv.PhysicalMemory
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Physical Memory in Use MB: " +$srv.PhysicalMemoryUsageinKB
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL MasterDB Path: " +$srv.MasterDBPath
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL MasterDB LogPath: " +$srv.MasterDBLogPath
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Backup Directory: " +$srv.BackupDirectory
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Install Shared Dir: " +$srv.InstallSharedDirectory
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Install Data Dir: " +$srv.InstallDataDirectory
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "SQL Service Account: " +$srv.ServiceAccount
$mystring | out-file $fullFileName -Encoding ascii -Append

" " | out-file $fullFileName -Encoding ascii -Append

# Windows
$mystring =  "OS Version: " +$srv.OSVersion
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "OS Is Clustered: " +$srv.IsClustered
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "OS Is HADR: " +$srv.IsHadrEnabled
$mystring | out-file $fullFileName -Encoding ascii -Append

$mystring =  "OS Platform: " +$srv.Platform
$mystring | out-file $fullFileName -Encoding ascii -Append


# Turn off default Error Handler for WMI
$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$mystring2 = Get-WmiObject –class Win32_OperatingSystem -ComputerName $server | select Name, BuildNumber, BuildType, CurrentTimeZone, InstallDate, SystemDrive, SystemDevice, SystemDirectory

# Reset default PS error handler
$ErrorActionPreference = $old_ErrorActionPreference

try
{
    Write-output ("OS Host Name: {0} " -f $mystring2.Name)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("OS BuildNumber: {0} " -f $mystring2.BuildNumber)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("OS Buildtype: {0} " -f $mystring2.BuildType)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("OS CurrentTimeZone: {0}" -f $mystring2.CurrentTimeZone)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("OS InstallDate: {0} " -f $mystring2.InstallDate)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("OS SystemDrive: {0} " -f $mystring2.SystemDrive)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("OS SystemDevice: {0} " -f $mystring2.SystemDevice)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("OS SystemDirectory: {0} " -f $mystring2.SystemDirectory)| out-file $fullFileName -Encoding ascii -Append
}
catch
{
    Write-output "Error getting OS specs via WMI - WMI/firewall issue?"| out-file $fullFileName -Encoding ascii -Append
    Write-output "Error getting OS specs via WMI - WMI/firewall issue?"
}

" " | out-file $fullFileName -Encoding ascii -Append

# Hardware
# Turn off default Error Handler for WMI
$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$mystring3 = Get-WmiObject -class Win32_Computersystem -ComputerName $server | select manufacturer

# Reset default PS error handler
$ErrorActionPreference = $old_ErrorActionPreference

try
{
    Write-output ("HW Manufacturer: {0} " -f $mystring3.Manufacturer)| out-file $fullFileName -Encoding ascii -Append
}
catch
{
    Write-output "Error getting Hardware specs via WMI - WMI/firewall issue? "| out-file $fullFileName -Encoding ascii -Append
    Write-output "Error getting Hardware specs via WMI - WMI/firewall issue? "
}

" " | out-file $fullFileName -Encoding ascii -Append

# Turn off default Error Handler for WMI
$old_ErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'

$mystring4 = Get-WmiObject –class Win32_processor -ComputerName $server | select Name,NumberOfCores,NumberOfLogicalProcessors

# Reset default PS error handler
$ErrorActionPreference = $old_ErrorActionPreference

try
{
    Write-output ("HW Processor: {0} " -f $mystring4.Name)| out-file $fullFileName -Encoding ascii -Append
    Write-Output ("HW CPUs: {0}" -f $mystring4.NumberOfLogicalProcessors)| out-file $fullFileName -Encoding ascii -Append
    Write-output ("HW Cores: {0}" -f $mystring4.NumberOfCores)| out-file $fullFileName -Encoding ascii -Append
}
catch
{
    Write-output "Error getting CPU specs via WMI - WMI/Firewall issue? "| out-file $fullFileName -Encoding ascii -Append
    Write-output "Error getting CPU specs via WMI - WMI/Firewall issue? "
}

" " | out-file $fullFileName -Encoding ascii -Append

$mystring5 =  "`r`nSQL Build reference: http://sqlserverbuilds.blogspot.com/ "
$mystring5| out-file $fullFileName -Encoding ascii -Append

$mystring5 =  "`r`nSQL Build reference: http://sqlserverupdates.com/ "
$mystring5| out-file $fullFileName -Encoding ascii -Append


$mystring5 = "`r`nMore Detailed Diagnostic Queries here:`r`nhttp://www.sqlskills.com/blogs/glenn/sql-server-diagnostic-information-queries-for-september-2015"
$mystring5| out-file $fullFileName -Encoding ascii -Append

# Dump out loaded DLLs
$mySQLquery = "select * from sys.dm_os_loaded_modules order by name"

# connect correctly
if ($serverauth -eq "win")
{
    $sqlresults2 = Invoke-SqlCmd -ServerInstance $SQLInstance -Query $mySQLquery -QueryTimeout 10 -erroraction SilentlyContinue
}
else
{
    $sqlresults2 = Invoke-SqlCmd -ServerInstance $SQLInstance -Query $mySQLquery -Username $myuser -Password $mypass -QueryTimeout 10 -erroraction SilentlyContinue
}

# Create some CSS for help in column formatting during HTML exports
$myCSS = 
"
table
    {
        Margin: 0px 0px 0px 4px;
        Border: 1px solid rgb(190, 190, 190);
        Font-Family: Tahoma;
        Font-Size: 9pt;
        Background-Color: rgb(252, 252, 252);
    }
tr:hover td
    {
        Background-Color: rgb(150, 150, 220);
        Color: rgb(255, 255, 255);
    }
tr:nth-child(even)
    {
        Background-Color: rgb(242, 242, 242);
    }
th
    {
        Text-Align: Left;
        Color: rgb(150, 150, 220);
        Padding: 1px 4px 1px 4px;
    }
td
    {
        Vertical-Align: Top;
        Padding: 1px 4px 1px 4px;
    }
"
# CSS file
if(!(test-path -path "$fullfolderPath\HTMLReport.css"))
{
    $myCSS | out-file "$fullfolderPath\HTMLReport.css" -Encoding ascii    
}

$RunTime = Get-date
$sqlresults2 | select file_version, product_version, debug, patched, prerelease, private_build, special_build, language, company, description, name `
| ConvertTo-Html    -PostContent "<h3>Ran on : $RunTime</h3>" -PreContent "<h1>$SqlInstance</H1><H2>Loaded DLLs</h2>" -CSSUri "HtmlReport.css" | Set-Content "$fullfolderPath\02_Loaded_Dlls.html"


# Dump Trace Flags
$mySQLquery2= "dbcc tracestatus()"

# connect correctly
if ($serverauth -eq "win")
{
    $sqlresults3 = Invoke-SqlCmd -ServerInstance $SQLInstance -Query $mySQLquery2 -QueryTimeout 10 -erroraction SilentlyContinue
}
else
{
    $sqlresults3 = Invoke-SqlCmd -ServerInstance $SQLInstance -Query $mySQLquery2 -Username $myuser -Password $mypass -QueryTimeout 10 -erroraction SilentlyContinue
}

if ($sqlresults3 -ne  $null)
{
    $sqlresults3 | select TraceFlag, Status, Global, Session | ConvertTo-Html   -PostContent "<h3>Ran on : $RunTime</h3>" -PreContent "<h1>$SqlInstance</H1><H2>Trace Flags</h2>"  -CSSUri "HtmlReport.css" | Set-Content "$fullfolderPath\03_Trace_Flags.html"
}


# Return to Base
set-location $BaseFolder
