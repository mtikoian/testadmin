<#
.SYNOPSIS
    Gets the SQL Server Logins on the target server
	
.DESCRIPTION
   Writes the SQL Server Logins out to the "01 - Server Logins" folder
   One file for each login      
   
.EXAMPLE
    01_Server_Logins.ps1 localhost
	
.EXAMPLE
    01_Server_Logins.ps1 server01 sa password

.Inputs
    ServerName\instance, [SQLUser], [SQLPassword]

.Outputs

	
.NOTES

    # First, install the Powershell AD Module
    # 8.1
    http://www.microsoft.com/en-us/download/details.aspx?id=39296

    # 8.0
    http://www.microsoft.com/en-us/download/details.aspx?id=28972

    # 7
    http://www.microsoft.com/en-us/download/details.aspx?id=7887
	

.LINK

	
	
#>

Param(
  [string]$SQLInstance="localhost",
  [string]$myuser,
  [string]$mypass
)

Set-StrictMode -Version latest;

[string]$BaseFolder = (Get-Item -Path ".\" -Verbose).FullName

# Load SMO Assemblies
Import-Module ".\LoadSQLSmo.psm1"
LoadSQLSMO

# Load More Assemblies


# First, test for Domain Membership 
$OnDomain = $false
if ((gwmi win32_computersystem).partofdomain -eq $true) 
{
    $OnDomain = $true
}

# If we are part of a Domain, Load the AD Module if it is installed on the user's system
if ($OnDomain -eq $true)
{
    $ADModuleExists = $false
    try
    {
        $old_ErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
    
        Import-Module ActiveDirectory
    
        # Test if Im on a windows Domain, If so and we find Windows Group SQL Logins, resolve all related Windows AD Users
        $MyDCs = Get-ADDomainController -Filter * | Select-Object name
    
        if ($MyDCs -ne $null)
        {
            Write-Output "Domain Controller found - Resolving of AD Group User Memberships Enabled"
            $ADModuleExists = $true
        }
        else
        {
            Write-Output "Domain Controller NOT found - Resolving of AD Group User Memberships Disabled - are you in a Workgroup?"
        }
    
        # Reset default PS error handler
        $ErrorActionPreference = $old_ErrorActionPreference 	
    
    }
    catch
    {
        # Reset default PS error handler
        $ErrorActionPreference = $old_ErrorActionPreference 
    
        # PS AD Module not installed
        Write-Output "AD Module Not Found - AD Group User Resolution not attempted"
    }
}
else
{
    Write-Output "NOT on a Domain - Resolving of AD Group User Memberships Disabled"
}

#  Script Name
Write-Host  -f Yellow -b Black "01 - Server Logins"


# Usage Check
if ($SQLInstance.Length -eq 0) 
{
    Write-host -f yellow "Usage: ./01_Server_Logins.ps1 `"SQLServerName`" ([`"Username`"] [`"Password`"] if DMZ machine)"
    Set-Location $BaseFolder
    exit
}

# Working
Write-Output "Server $SQLInstance"

# Server connection check
try
{
    $old_ErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'

    if ($mypass.Length -ge 1 -and $myuser.Length -ge 1) 
    {
        Write-Output "Testing SQL Auth"
        $results = Invoke-SqlCmd -ServerInstance $SQLInstance -Query "select serverproperty('productversion')" -Username $myuser -Password $mypass -QueryTimeout 10 -erroraction SilentlyContinue
        $serverauth="sql"
    }
    else
    {
        Write-Output "Testing Windows Auth"
    	$results = Invoke-SqlCmd -ServerInstance $SQLInstance -Query "select serverproperty('productversion')" -QueryTimeout 10 -erroraction SilentlyContinue
        $serverauth = "win"
    }

    if($results -ne $null)
    {
        Write-Output ("SQL Version: {0}" -f $results.Column1)
    }

    # Reset default PS error handler
    $ErrorActionPreference = $old_ErrorActionPreference 	

}
catch
{
    Write-Host -f red "$SQLInstance appears offline - Try Windows Authorization."
    Set-Location $BaseFolder
	exit
}


function CopyObjectsToFiles($objects, $outDir) {
	
	if (-not (Test-Path $outDir)) {
		[System.IO.Directory]::CreateDirectory($outDir) | out-null
	}
	
	foreach ($o in $objects) { 
	
		if ($o -ne $null) {
			
			$schemaPrefix = ""
			
            try
            {
			if ($o.Schema -ne $null -and $o.Schema -ne "") {
				$schemaPrefix = $o.Schema + "."
			}
            }
            catch {}
		
			$fixedOName = $o.name.replace('\','_')			
			$scripter.Options.FileName = $outDir + $schemaPrefix + $fixedOName + ".sql"
			$scripter.EnumScript($o)
		}
	}
}

# Set Local Vars
$server = $SQLInstance

if ($serverauth -eq "win")
{
    $srv        = New-Object "Microsoft.SqlServer.Management.SMO.Server" $server
    $scripter 	= New-Object "Microsoft.SqlServer.Management.SMO.Scripter" $server
}
else
{
    $srv        = New-Object "Microsoft.SqlServer.Management.SMO.Server" $server
    $srv.ConnectionContext.LoginSecure=$false
    $srv.ConnectionContext.set_Login($myuser)
    $srv.ConnectionContext.set_Password($mypass)    
    $scripter   = New-Object ("Microsoft.SqlServer.Management.SMO.Scripter") ($srv)
}


# Set scripter options to ensure only schema is scripted
$scripter.Options.ScriptSchema 	        = $true;
$scripter.Options.ScriptData 	        = $false;
$scripter.Options.ToFileOnly 			= $true;


# Create base output folder
$output_path = "$BaseFolder\$SQLInstance\01 - Server Logins\"
if(!(test-path -path $output_path))
    {
        mkdir $output_path | Out-Null
    }

# Create Windows Groups output folder
$WinGroupsPath = "$BaseFolder\$SQLInstance\01 - Server Logins\WindowsGroups\"
if(!(test-path -path $WinGroupsPath))
    {
        mkdir $WinGroupsPath | Out-Null
    }

# Create Windows Users output folder
$WinUsersPath = "$BaseFolder\$SQLInstance\01 - Server Logins\WindowsUsers\"
if(!(test-path -path $WinUsersPath))
    {
        mkdir $WinUsersPath | Out-Null
    }

# Create SQLAuth Users output folder
$SQLAuthUsersPath = "$BaseFolder\$SQLInstance\01 - Server Logins\SQLAuthUsers\"
if(!(test-path -path $SQLAuthUsersPath))
    {
        mkdir $SQLAuthUsersPath | Out-Null
    }


# Export Logins
$logins_path  = "$BaseFolder\$SQLInstance\01 - Server Logins\"
$logins = $srv.Logins

foreach ($Login in $Logins)
{

    # Skip non-Domain logins that look like Domain Logins (contain "\")
    if ($Login.Name -like "NT SERVICE\*") {continue}
    if ($Login.Name -like "NT AUTHORITY\*") {continue}    
    if ($Login.Name -like "IIS AppPool\*") {continue} 
    if ($Login.Name -eq "BUILTIN\Administrators") {continue}   
    if ($Login.Name -eq "##MS_PolicyEventProcessingLogin##") {continue}
    if ($Login.Name -eq "##MS_PolicyTsqlExecutionLogin##") {continue}
    if ($Login.Name -eq "##MS_SQLEnableSystemAssemblyLoadingUser##") {continue}
    if ($Login.Name -eq "##MS_SSISServerCleanupJobLogin##") {continue}


    # Windows Domain Groups
    if ($OnDomain -eq $true -and $ADModuleExists -eq $true -and $Login.LoginType -eq "WindowsGroup")
    {

        # For this SQL Login, resolve all Windows Users in this AD Group and below in the AD Tree - recursive
        Write-Output ("Scripting out: {0}" -f $Login.Name)

        # Strip the Domain part off the SQL Login
        $ADName = ($Login.Name -split {$_ -eq "," -or $_ -eq "\"})[1]
        $ADDomain = ($Login.Name -split {$_ -eq "," -or $_ -eq "\"})[0]

        $myFixedGroupName = $ADName.replace('\','_')
	    $myFixedGroupName = $myFixedGroupName.replace('/', '-')
	    $myFixedGroupName = $myFixedGroupName.replace('[','(')
	    $myFixedGroupName = $myFixedGroupName.replace(']',')')
	    $myFixedGroupName = $myFixedGroupName.replace('&', '-')
	    $myFixedGroupName = $myFixedGroupName.replace(':', '-')

        # One output folder per Windows Group        
        $WinGroupSinglePath = $WinGroupsPath+$myFixedGroupName+"\"
        if(!(test-path -path $WinGroupSinglePath))
        {
            mkdir $WinGroupSinglePath | Out-Null
        }
        
        # Get all Users of this AD Group
        $ADGroupUsers = Get-AdGroupMember -identity $ADName -recursive | sort name

        # Export Users for this AD Group
        $myoutputfile = $WinGroupSinglePath+"Users in "+$myFixedGroupName+".sql"
        $myoutputstring = "-- These Domain Users are members of the SQL Login and Windows Group ["+$ADName+ "]`n"
        $myoutputstring | out-file -FilePath $myoutputfile -encoding ascii
       
        # Create the Group Itself
        CopyObjectsToFiles $login $WinGroupSinglePath

        # Create the Users of this Group
        foreach($ADUser in $ADGroupUsers)
        {   

            $CreateObjectName = "CREATE LOGIN ["+$ADDomain+"\"+$ADUser.SamAccountName+"] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english] "
            $CreateObjectName | out-file -FilePath $myoutputfile -append -Encoding ascii
        }
    }


    # Windows Domain Users
    if ($Login.LoginType -eq "WindowsUser")
    {
        Write-Output ("Scripting out: {0}" -f $Login.Name)
        CopyObjectsToFiles $login $WinUsersPath
    }

    # SQL Auth
    if ($Login.LoginType -eq "SQLLogin")
    {
        Write-Output ("Scripting out: {0}" -f $Login.Name)
        CopyObjectsToFiles $login $SQLAuthUsersPath
    }

}
 

set-location $BaseFolder
