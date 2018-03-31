<#
.SYNOPSIS
    Gets the SQL Server Resource Governor Pools and Workgroups on the target server
	
.DESCRIPTION
   Writes the SQL Server Roles out to the "01 - Resource Governor" folder
   One file for each Pool
   
.EXAMPLE
    01_Server_Resource_Governor.ps1 localhost
	
.EXAMPLE
    01_Server_Resource_Governor.ps1 server01 sa password

.Inputs
    ServerName, [SQLUser], [SQLPassword]

.Outputs

	
.NOTES

	
.LINK

	
#>

Param(
  [string]$SQLInstance='localhost',
  [string]$myuser,
  [string]$mypass
)

Set-StrictMode -Version latest;

[string]$BaseFolder = (Get-Item -Path ".\" -Verbose).FullName

#  Script Name
Write-Host  -f Yellow -b Black "01 - Server Resource Governor"


# Usage Check
if ($SQLInstance.Length -eq 0) 
{
    Write-host -f yellow "Usage: ./01_Server_Resource_Governor.ps1 `"SQLServerName`" ([`"Username`"] [`"Password`"] if DMZ machine)"
    Set-Location $BaseFolder
    exit
}

# Working
Write-Output "Server $SQLInstance"

# Load SMO Assemblies
Import-Module ".\LoadSQLSmo.psm1"
LoadSQLSMO



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
    Write-Host -f red "$SQLInstance appears offline - Try Windows Auth?"
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
$server	= $SQLInstance

if ($serverauth -eq "win")
{
    $srv    = New-Object "Microsoft.SqlServer.Management.SMO.Server" $server
    $scripter 	= New-Object ("Microsoft.SqlServer.Management.SMO.Scripter") ($server)
}
else
{
    $srv = New-Object "Microsoft.SqlServer.Management.SMO.Server" $server
    $srv.ConnectionContext.LoginSecure=$false
    $srv.ConnectionContext.set_Login($myuser)
    $srv.ConnectionContext.set_Password($mypass)    
    $scripter = New-Object ("Microsoft.SqlServer.Management.SMO.Scripter") ($srv)
}


# Set scripter options to ensure only data is scripted
$scripter.Options.ScriptSchema 	        = $true;
$scripter.Options.ScriptData 	        = $false;

# Add your favorite options
# https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.scriptingoptions.aspx
$scripter.Options.AllowSystemObjects 	= $false
$scripter.Options.AnsiFile 				= $true

$scripter.Options.ClusteredIndexes 		= $true

$scripter.Options.DriAllKeys            = $true
$scripter.Options.DriForeignKeys        = $true
$scripter.Options.DriChecks             = $true
$scripter.Options.DriPrimaryKey         = $true
$scripter.Options.DriUniqueKeys         = $true
$scripter.Options.DriWithNoCheck        = $true
$scripter.Options.DriAllConstraints 	= $true
$scripter.Options.DriIndexes 			= $true
$scripter.Options.DriClustered 			= $true
$scripter.Options.DriNonClustered 		= $true

$scripter.Options.EnforceScriptingOptions 	= $true
$scripter.Options.ExtendedProperties    = $true

$scripter.Options.FullTextCatalogs      = $true
$scripter.Options.FullTextIndexes 		= $true
$scripter.Options.FullTextStopLists     = $true
$scripter.Options.IncludeFullTextCatalogRootPath= $true


$scripter.Options.IncludeHeaders        = $false
$scripter.Options.IncludeDatabaseRoleMemberships= $true
$scripter.Options.Indexes 				= $true

$scripter.Options.NoCommandTerminator 	= $false;
$scripter.Options.NonClusteredIndexes 	= $true

$scripter.Options.NoTablePartitioningSchemes = $false

$scripter.Options.Permissions 			= $true

$scripter.Options.SchemaQualify 		= $true
$scripter.Options.SchemaQualifyForeignKeysReferences = $true

$scripter.Options.ToFileOnly 			= $true


# With Dependencies create one huge file for all tables in the order needed to maintain RefIntegrity
$scripter.Options.WithDependencies		= $false
$scripter.Options.XmlIndexes            = $true

# Output Folder
Set-Location $BaseFolder
$output_path = "$BaseFolder\$SQLInstance\01 - Server Resource Governor\"
if(!(test-path -path $output_path))
    {
        mkdir $output_path | Out-Null
    }

try
{
    # Pools
    $pools = $srv.ResourceGovernor.ResourcePools | where-object -FilterScript {$_.Name -notin "internal","default"}
    CopyObjectsToFiles $pools $output_path


    # Workgroups
    foreach ($pool in $pools)
    {
        
        #Put Workgroups in parent pool's folder
        $pool_path = "$BaseFolder\$SQLInstance\01 - Server Resource Governor\"+$pool.Name+"\"
        if(!(test-path -path $pool_path))
            {
                mkdir $pool_path | Out-Null
            }
        
        #Workgroup
        $workloadgroups = $pool.WorkloadGroups
        foreach ($workloadgroup in $workloadgroups)
        {
            CopyObjectsToFiles $workloadgroup $pool_path
        }
        
    } 
}
catch
{
    $fullfolderpath = "$BaseFolder\$SQLInstance\"
    echo null > "$fullfolderpath\01 - Server Resource Governor - not setup or enabled.txt"
}

set-location $BaseFolder
