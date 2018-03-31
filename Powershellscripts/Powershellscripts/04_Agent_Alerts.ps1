<#
.SYNOPSIS
    Gets the SQL Agent Alerts
	
.DESCRIPTION
   Writes the SQL Agent Alerts out to the "04 - Agent Alerts" folder, Agent_Alerts.sql file
   One file for all Alerts
   
.EXAMPLE
    04_Agent_Alerts.ps1 localhost
	
.EXAMPLE
    04_Agent_Alerts.ps1 server01 sa password

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
Write-Host  -f Yellow -b Black "04 - Agent Alerts"

# Load SMO Assemblies
Import-Module ".\LoadSQLSmo.psm1"
LoadSQLSMO

# Usage Check
if ($SQLInstance.Length -eq 0) 
{
    Write-host -f yellow "Usage: ./04_Agent_Alerts.ps1 `"SQLServerName`" ([`"Username`"] [`"Password`"] if DMZ machine)"
       Set-Location $BaseFolder
    exit
}


# Working
Write-Output "Server $SQLInstance"


 # Get the Alerts Themselves
$sql1 = 
"
SELECT 'EXEC msdb.dbo.sp_add_alert '+char(13)+char(10)+
' @name=N'+CHAR(39)+tsha.NAME+CHAR(39)+char(13)+char(10)+
',@message_id='+CONVERT(VARCHAR(6),tsha.message_id)+char(13)+char(10)+
',@severity='+CONVERT(VARCHAR(10),tsha.severity)+char(13)+char(10)+
',@enabled='+CONVERT(VARCHAR(10),tsha.[enabled])+char(13)+char(10)+
',@delay_between_responses='+convert(varchar(10),tsha.delay_between_responses)+char(13)+char(10)+
',@include_event_description_in='+CONVERT(VARCHAR(5),tsha.include_event_description)+char(13)+char(10)+
',@job_id=N'+char(39)+'00000000-0000-0000-0000-000000000000'+char(39)+char(13)+char(10)
FROM msdb.dbo.sysalerts tsha
"


# Get the Notifications for Each Alert (Typically Email)
$sql2 = 
"
select 
	'EXEC msdb.dbo.sp_add_notification '+char(13)+char(10)+
	' @alert_name =N'+CHAR(39)+A.[name]+CHAR(39)+CHAR(13)+CHAR(10)+
	' ,@operator_name = N'+CHAR(39)+O.[name]+CHAR(39)+CHAR(13)+CHAR(10)+	
	' ,@notification_method= 1'
from 
	[msdb].[dbo].[sysalerts] a
inner join 
	[msdb].[dbo].[sysnotifications] n
ON
	a.id = n.alert_id
inner join
	[msdb].[dbo].[sysoperators] o
on 
	n.operator_id = o.id
"

$fullfolderPath = "$BaseFolder\$sqlinstance\04 - Agent Alerts"
if(!(test-path -path $fullfolderPath))
{
	mkdir $fullfolderPath | Out-Null
}


	
# Test for Username/Password needed to connect - else assume WinAuth pass-through
if ($mypass.Length -ge 1 -and $myuser.Length -ge 1) 
{
	Write-Output "Using SQL Auth"

    $old_ErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'

    # Export Alerts
	$results1 = Invoke-SqlCmd -query $sql1  -Server $SQLInstance �Username $myuser �Password $mypass 

    if ($results1 -eq $null)
    {
        Write-Output "No Agent Alerts Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\04 - No Agent Alerts Found.txt"
        Set-Location $BaseFolder
        exit
    }

    New-Item "$fullfolderPath\Agent_Alerts.sql" -type file -force  |Out-Null
    Add-Content -Value "USE MSDB `r`nGO `r`n" -Path "$fullfolderPath\Agent_Alerts.sql" -Encoding Ascii
    Foreach ($row in $results1)
    {
        $row.column1 | out-file "$fullfolderPath\Agent_Alerts.sql" -Encoding ascii -Append
    }

    Write-Output ("Exported: {0} Alerts" -f $results1.count)

    # Export Alert Notifications
	$results2 = Invoke-SqlCmd -query $sql2  -Server $SQLInstance �Username $myuser �Password $mypass 

    if ($results2 -eq $null)
    {
        Write-Output "No Agent Alert Notifications Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\04 - No Agent Alert Notifications Found.txt"
        Set-Location $BaseFolder
        exit
    }

    # Reset default PS error handler
    $ErrorActionPreference = $old_ErrorActionPreference 

    # Export Alert Notifications
    New-Item "$fullfolderPath\Agent_Alert_Notifications.sql" -type file -force  |Out-Null
    Add-Content -Value "USE MSDB `r`nGO `r`n" -Path "$fullfolderPath\Agent_Alert_Notifications.sql" -Encoding Ascii
    Foreach ($row in $results2)
    {
        $row.column1 | out-file "$fullfolderPath\Agent_Alert_Notifications.sql" -Encoding ascii -Append
    }

    Write-Output ("Exported: {0} Alert Notifications" -f $results2.count)
}
else
{
	Write-Output "Using Windows Auth"

    $old_ErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'

    # Export Alerts
	$results1 = Invoke-SqlCmd -query $sql1  -Server $SQLInstance

    if ($results1 -eq $null)
    {
        Write-Output "No Agent Alerts Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\04 - No Agent Alerts Found.txt"
        Set-Location $BaseFolder
        exit
    }

    New-Item "$fullfolderPath\Agent_Alerts.sql" -type file -force  |Out-Null
    Add-Content -Value "USE MSDB `r`nGO `r`n" -Path "$fullfolderPath\Agent_Alerts.sql" -Encoding Ascii
    Foreach ($row in $results1)
    {
        $row.column1 | out-file "$fullfolderPath\Agent_Alerts.sql" -Encoding ascii -Append
    }
    Write-Output ("{0} Alerts Exported" -f $results1.count)


    # Export Alert Notifications
	$results2 = Invoke-SqlCmd -query $sql2  -Server $SQLInstance

    if ($results2 -eq $null)
    {
        Write-Output "No Agent Alert Notifications Found on $SQLInstance"        
        echo null > "$BaseFolder\$SQLInstance\04 - No Agent Alert Notifications Found.txt"
        Set-Location $BaseFolder
        exit
    }

    # Reset default PS error handler
    $ErrorActionPreference = $old_ErrorActionPreference 

    # Export Alert Notifications
    New-Item "$fullfolderPath\Agent_Alert_Notifications.sql" -type file -force  |Out-Null
    Add-Content -Value "USE MSDB `r`nGO `r`n" -Path "$fullfolderPath\Agent_Alert_Notifications.sql" -Encoding Ascii
    Foreach ($row in $results2)
    {
        $row.column1+"`r`n" | out-file "$fullfolderPath\Agent_Alert_Notifications.sql" -Encoding ascii -Append
    }

    Write-Output ("{0} Alert Notifications Exported" -f $results2.count)

}

set-location $BaseFolder


