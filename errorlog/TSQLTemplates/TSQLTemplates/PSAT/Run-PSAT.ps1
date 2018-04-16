<#
    .SYNOPSIS
    Executes the Powershell SQL Auto Template system against the specified database and server.
    .PARAMETER ServerName
    The name of the server to execute against.
    .PARAMETER DatabaseName
    The name of the database to execute against.
    .NOTES
        Author     - Josh Feierman 
        Date       - 9/17/2012
#>
[Cmdletbinding()]
param
(
    [parameter(mandatory=$true)]
    [string]$ServerName,
    [parameter(mandatory=$true)]
    [string]$DatabaseName
)

Set-StrictMode -Version "Latest"

# Import required assemblies
try
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.SMO")
}
catch
{
    Write-Warning "Unable to load required assemblies!"
    Write-Warning $_.Exception.Message
    Write-Warning "Script will now exit."
    return
}

$scriptPath = Split-Path $MyInvocation.MyCommand.Path

# Load common functions
foreach ($script in (Get-ChildItem "$scriptPath\Common" -Filter "*.ps1"))
{
    try
    {
        Write-Verbose "Loading common script '$script'."
        . $script.FullName
    }
    catch
    {
        Write-Warning "Unable to load common script '$script'!"
        Write-Warning $_.Exception.Message
        Write-Warning "Script will now exit."
        return
    }
}

# Begin populating global variables
try 
{
    # Server and database
	$smoSynonyms = @()
	$smoTables = @()
	$smoProcedures = @()
	$smoFunctions = @()
	$smoViews = @()
	$smoSchemas = @()
	$smoRoles = @()

	$smoServer = new-object Microsoft.SQLServer.Management.Smo.Server $ServerName
    $smoDatabase = $smoServer.Databases[$DatabaseName]
    $smoDatabase.Tables | 
        Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $smoDatabase.Name -PassThru |
		ForEach-Object {$smoTables += $_}
    $smoDatabase.Synonyms | 
        Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $smoDatabase.Name -PassThru |
		ForEach-Object {$smoSynonyms += $_}
    $smoDatabase.StoredProcedures | 
        Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $smoDatabase.Name -PassThru |
		ForEach-Object {$smoProcedures += $_}
    $smoDatabase.UserDefinedFunctions | 
        Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $smoDatabase.Name -PassThru |
		ForEach-Object {$smoFunctions += $_}
    $smoDatabase.Views | 
        Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $smoDatabase.Name -PassThru |
		ForEach-Object {$smoViews += $_}
    $smoDatabase.Schemas | 
        Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $smoDatabase.Name -PassThru |
		ForEach-Object {$smoSchemas += $_}
    $smoDatabase.Roles | 
        Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value $smoDatabase.Name -PassThru |
		ForEach-Object {$smoRoles += $_}
}
catch
{
    Write-Warning "Unable to collect global variable data!"
    Write-Warning $_.Exception.Message
    Write-Warning "Script will now exit."
    return
}

# Begin executing plugins
foreach ($plugin in (Get-ChildItem -Path "$scriptPath\Plugins" -Filter "*.ps1" | where-object {-not ($_.Name -match "^_")}))
{
    Write-Verbose "Executing plugin '$plugin'."
    try
    {
        #Get the output from the plugins. The regex replace is to clean up line endings.
        $outputObjs = . $plugin.FullName
        
        foreach ($output in $outputObjs)
        {
            if ($output -ne $null)
			{
				$fileName = "$scriptPath\Output\$($output.FileName)"
	            if (-not (Test-Path (Split-Path $fileName)))
	            {
	                New-Item -Path (Split-Path $fileName) -ItemType "Directory"
	            }
	            Set-Content -Path $fileName -Value $output.FileContent
			}
        }
    }
    catch
    {
        Write-Warning "Unable to execute plugin!"
        Write-Warning $_.Exception.Message
        Write-Warning "Script will now exit."
        return
    }
}