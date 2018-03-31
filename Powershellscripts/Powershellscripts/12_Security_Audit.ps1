﻿<#
.SYNOPSIS
    Gets SQL Server Security Information from the target server
	
.DESCRIPTION
   Writes out the results of 5 SQL Queries to a sub folder of the Server Name (C0SQL1)
   One HTML file for each Query
   
.EXAMPLE
    SQLSecurityAudit.ps1 localhost
	
.EXAMPLE
    SQLSecurityAudit.ps1 server01 sa password

.Inputs
    ServerName, [SQLUser], [SQLPassword]

.Outputs
	HTML Files
	
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
Write-Host  -f Yellow -b Black "12 - Security Audit"


# Load SMO Assemblies
Import-Module ".\LoadSQLSmo.psm1"
LoadSQLSMO


# Usage Check
if ($SQLInstance.Length -eq 0) 
{
    Write-host -f yellow -b black "Usage: ./12_Security_Audit.ps1 `"SQLServerName`" ([`"Username`"] [`"Password`"] if DMZ machine)"
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
    Write-Host -f red "$SQLInstance appears offline - Try Windows Auth?"
    Set-Location $BaseFolder
	exit
}


# Set Local Vars
$server = $SQLInstance

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

# Create Output Folder
$fullfolderPath = "$BaseFolder\$sqlinstance\12 - Security Audit"
if(!(test-path -path $fullfolderPath))
{
	mkdir $fullfolderPath | Out-Null
}


# Export Security Information:
# 1) SQL Logins

$sql1 = 
"
--- Server Logins
--- Q1 Logins, Default DB,  Auth Type, and FixedServerRole Memberships
SELECT 
	name as 'Login', 
	dbname as 'DefaultDB',
	[language],  
	CONVERT(CHAR(10),CASE denylogin WHEN 1 THEN 'X' ELSE '--' END) AS IsDenied, 
	CONVERT(CHAR(10),CASE isntname WHEN 1 THEN 'X' ELSE '--' END) AS IsWinAuthentication, 
	CONVERT(CHAR(10),CASE isntgroup WHEN 1 THEN 'X' ELSE '--' END) AS IsWinGroup, 
	Createdate,
	Updatedate, 
	CONVERT(VARCHAR(2000), 
	CASE sysadmin WHEN 1 THEN 'sysadmin,' ELSE '' END + 
	CASE securityadmin WHEN 1 THEN 'securityadmin,' ELSE '' END + 
	CASE serveradmin WHEN 1 THEN 'serveradmin,' ELSE '' END + 
	CASE setupadmin WHEN 1 THEN 'setupadmin,' ELSE '' END + 
	CASE processadmin WHEN 1 THEN 'processadmin,' ELSE '' END + 
	CASE diskadmin WHEN 1 THEN 'diskadmin,' ELSE '' END + 
	CASE dbcreator WHEN 1 THEN 'dbcreator,' ELSE '' END + 
	CASE bulkadmin WHEN 1 THEN 'bulkadmin' ELSE '' END ) AS ServerRoles,
	CASE sysadmin WHEN 1 THEN '1' ELSE '0' END as IsSysAdmin
INTO 
	#syslogins 
FROM 
	master..syslogins WITH (nolock) 

UPDATE 
	#syslogins 
SET 
	ServerRoles = SUBSTRING(ServerRoles,1,LEN(ServerRoles)-1) 
WHERE 
	SUBSTRING(ServerRoles,LEN(ServerRoles),1) = ',' 

UPDATE 
	#syslogins SET ServerRoles = '--' 
WHERE 
	LTRIM(RTRIM(ServerRoles)) = '' 

select * from #syslogins order by IsSysAdmin desc, Login

drop table #syslogins

"


# Create some CSS for help in column formatting
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

$myCSS | out-file "$fullfolderPath\HTMLReport.css" -Encoding ascii


Write-Output "Server Logins..."
# Run Query 1
if ($serverauth -ne "win")
{
	#Write-Output "Using Sql Auth"
	$results = Invoke-SqlCmd -query $sql1 -Server $SQLInstance –Username $myuser –Password $mypass 
}
else
{
	#Write-Output "Using Windows Auth"	
	$results = Invoke-SqlCmd -query $sql1 -Server $SQLInstance      
}

# Write out rows
$RunTime = Get-date
$results | select Login, DefaultDB, language, IsDenied, IsWinAuthentication, IsWinGroup, CreateDate, UpdateDate, ServerRoles, IsSysAdmin|`
ConvertTo-Html -PostContent "<h3>Ran on : $RunTime</h3>"  -PreContent "<h1>$SqlInstance</H1><H2>Server Logins</h2>" -CSSUri "HtmlReport.css"| Set-Content "$fullfolderPath\1_Server_Logins.html"


set-location $BaseFolder

# -----------------------
# iterate over each DB
# -----------------------
Write-Output "Database Objects..."
foreach($sqlDatabase in $srv.databases) 
{
    # Skip Certain System Databases
    if ($sqlDatabase.Name -in 'Model','TempDB','SSISDB','distribution','ReportServer','ReportServerTempDB') {continue}

    # Create Output Folders - One Per DataBase
    $db = $sqlDatabase
    $fixedDBName = $db.name.replace('[','')
    $fixedDBName = $fixedDBName.replace(']','')
    $output_path = "$fullfolderPath\Databases\$fixedDBname"
    
    if(!(test-path -path $output_path))
    {
        mkdir $output_path | Out-Null	
    }

    # Skip Offline Databases (SMO still enumerates them, but cant retrieve the objects)
    if ($sqlDatabase.Status -ne 'Normal')     
    {
        Write-Output ("Skipping Offline: {0}" -f $sqlDatabase.Name)
        continue
    }

    $sqlDatabase.Name
    
    # Run Query 2    
    # 2) Login_to_User_Mappings

    $sql2 = "
    Use ["+ $sqlDatabase.Name + "];"+
    "
    SELECT 
	    sp.name AS 'Login', 
	    dp.name AS 'User' 
    FROM 
    	sys.database_principals dp 
    INNER JOIN sys.server_principals sp 
        ON dp.sid = sp.sid 
    ORDER BY 
    	sp.name, 
    	dp.name;
    "
    #Write-Output $sql2

    # Run SQL
    if ($serverauth -ne "win")
    {
    	#Write-Output "Using Sql Auth"
    	$results2 = Invoke-SqlCmd -query $sql2 -Server $SQLInstance –Username $myuser –Password $mypass 
    }
    else
    {
    	#Write-Output "Using Windows Auth"	
    	$results2 = Invoke-SqlCmd -query $sql2 -Server $SQLInstance      
    }

    # Write out rows
    $myCSS | out-file "$output_path\HTMLReport.css" -Encoding ascii
    $results2 | select Login, User | ConvertTo-Html -PostContent "<h3>Ran on : $RunTime</h3>" -PreContent "<h1>$SqlInstance</H1><H2>Login-to-User Mappings</h2>" -CSSUri "HtmlReport.css"| Set-Content "$output_path\2_Login_to_User_Mapping.html"

    set-location $BaseFolder

    # Run Query 3
    # 3) Roles per User

    $sql3 = "
    Use ["+ $sqlDatabase.Name + "];"+
    "
    SELECT 
        a.name AS User_name,
	    b.name AS Role_name	   
    FROM 
    sysusers a 
    INNER JOIN sysmembers c 
    	on a.uid = c.memberuid
    INNER JOIN sysusers b 
    	ON c.groupuid = b.uid 
    	WHERE a.name <> 'dbo' 
    order by 
    	1,2
    "
    
    if ($serverauth -ne "win") 
    {
    	#Write-output "Using Sql Auth"
    	$results3 = Invoke-SqlCmd -query $sql3 -Server $SQLInstance –Username $myuser –Password $mypass 
    }
    else
    {
    	#Write-output "Using Windows Auth"	
    	$results3 = Invoke-SqlCmd -query $sql3 -Server $SQLInstance      
    }

    # Write out rows    
    $results3 | select User_Name,Role_Name | ConvertTo-Html -PostContent "<h3>Ran on : $RunTime</h3>" -PreContent "<h1>$SqlInstance</H1><H2>Roles Per User</h2>" -CSSUri "HtmlReport.css"| Set-Content "$output_path\3_Roles_Per_User.html"

    set-location $BaseFolder

    # Run Query 4
    # 4) Databse-Level Permissions
    $sql4 = "
    Use ["+ $sqlDatabase.Name + "];"+
    "
    SELECT 
	    usr.name as 'User', 
	    CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END as 'Operation', 
	    perm.permission_name,  
	    CASE WHEN perm.state <> 'W' THEN '--' ELSE 'X' END AS IsGrantOption 
    FROM 
    	sys.database_permissions AS perm 
    INNER JOIN 
    	sys.database_principals AS usr 
    ON 
    	perm.grantee_principal_id = usr.principal_id 
    WHERE 
    	perm.major_id = 0 
    ORDER BY 
    	usr.name, perm.permission_name ASC, perm.state_desc ASC
    "
    
    if ($serverauth -ne "win") 
    {
    	$results4 = Invoke-SqlCmd -query $sql4 -Server $SQLInstance –Username $myuser –Password $mypass 
    }
    else
    {
    	$results4 = Invoke-SqlCmd -query $sql4 -Server $SQLInstance      
    }

    # Write out rows    
    $results4 | select User, Operation, permission_name, IsGrantOption | ConvertTo-Html -PostContent "<h3>Ran on : $RunTime</h3>" -PreContent "<h1>$SqlInstance</H1><H2>DataBase-Level Permissions</h2>" -CSSUri "HtmlReport.css"| Set-Content "$output_path\4_DBLevel_Permissions.html"

    set-location $BaseFolder

    # Run Query 5
    # 5) Individual Database-Level Object Permissions
    $sql5 = "
    Use ["+ $sqlDatabase.Name + "];"+
    "
    SELECT 
	    usr.name AS 'User', 
	    CASE WHEN perm.state <> 'W' THEN perm.state_desc ELSE 'GRANT' END AS PermType, 
	    perm.permission_name,
	    USER_NAME(obj.schema_id) AS SchemaName, 
	    obj.name AS ObjectName, 
	    CASE obj.Type  
		    WHEN 'U' THEN 'Table'
		    WHEN 'V' THEN 'View'
		    WHEN 'P' THEN 'Stored Proc'
		    WHEN 'FN' THEN 'Function'
	    ELSE obj.Type END AS ObjectType, 
	    CASE WHEN cl.column_id IS NULL THEN '--' ELSE cl.name END AS ColumnName, 
	    CASE WHEN perm.state = 'W' THEN 'X' ELSE '--' END AS IsGrantOption 
    FROM
	    sys.database_permissions AS perm 
    INNER JOIN sys.objects AS obj 
	    ON perm.major_id = obj.[object_id] 
    INNER JOIN sys.database_principals AS usr 
	    ON perm.grantee_principal_id = usr.principal_id 
    LEFT JOIN sys.columns AS cl 
	    ON cl.column_id = perm.minor_id AND cl.[object_id] = perm.major_id 
    WHERE 
	    obj.Type <> 'S'
    ORDER BY 
	    usr.name, perm.state_desc ASC, perm.permission_name ASC

    "
    
    if ($serverauth -ne "win") 
    {
    	$results5 = Invoke-SqlCmd -query $sql5 -Server $SQLInstance –Username $myuser –Password $mypass
    }
    else
    {
    	$results5 = Invoke-SqlCmd -query $sql5 -Server $SQLInstance
    }

    # Write out rows    
    $results5 | select User, PermType, permission_name, SchemaName, ObjectName, ObjectType, ColumnName, IsGrantOption | `
    ConvertTo-Html -PostContent "<h3>Ran on : $RunTime</h3>" -PreContent "<h1>$SqlInstance</H1><H2>Object-Level Permissions</h2>" -CSSUri "HtmlReport.css"| Set-Content "$output_path\5_Object_Permissions.html"

    set-location $BaseFolder
        
}

set-location $BaseFolder