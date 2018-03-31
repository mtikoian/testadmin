############################################################################################################
# This script works in conjunction with some .sql files (that should exist in the sme folder
#   to generate scripts that will recreate 
#   principles and permissions for those principles as they are currently defined for a named 
#   principle on a named server in a named database.
#
# The output file is placed into a folder at:
# .\[ProjectName]\Scripts\Post-Deployment\SecurityAdditions\PermissionSets\
# .\[ProjectName]\Scripts\Post-Deployment\SecurityAdditions\Users\
#
# Execute using> .\GeneratePermissions.ps1 -SQLInstance instanceName -Environment XXX
#  e.g.        > .\GeneratePermissions.ps1 -SQLInstance "localhost" -Environment DEV
#
# by Jamie Thomson
# 21st July 2010
#
#
# Peter Schott - 2011-02-17
# Created a section to handle the Role Permissions
# Tweaked script to appropriately handle Principle.Name property
#  (prior version pointed to a non-existent/set $DatabasePrinciple variable of some sort)
############################################################################################################

#####PARAMETERS#####
Param($SQLInstance,$Environment)

#####Add all the SQL goodies (including Invoke-Sqlcmd)#####
add-pssnapin sqlserverprovidersnapin100 -ErrorAction SilentlyContinue
add-pssnapin sqlservercmdletsnapin100 -ErrorAction SilentlyContinue

#####Prepare array of Databases to work over#####
###Add a new element to the array for every database
###It allows you to define the name of the database and the name of the datadude project
###that the files will be added to
$DBobjArray = @()
$tmpObject = New-Object PSObject
$tmpObject | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value "Audit"
$tmpObject | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value "Audit"
$DBobjArray += $tmpObject

# $tmpObject2 = New-Object PSObject
# $tmpObject2 | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value "DB2"
# $tmpObject2 | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value "DB2"
# $DBobjArray += $tmpObject2

# $tmpObject3 = New-Object PSObject
# $tmpObject3 | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value "DB3"
# $tmpObject3 | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value "DB3"
# $DBobjArray += $tmpObject3
# $tmpObject4 = New-Object PSObject
# $tmpObject4 | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value "DB4"
# $tmpObject4 | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value "DB4"
# $DBobjArray += $tmpObject4
# $tmpObject5 = New-Object PSObject
# $tmpObject5 | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value "DB5"
# $tmpObject5 | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value "DB5"
# $DBobjArray += $tmpObject5
# $tmpObject6 = New-Object PSObject
# $tmpObject6 | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value "DB6"
# $tmpObject6 | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value "DB6"
# $DBobjArray += $tmpObject6
# $tmpObject7 = New-Object PSObject
# $tmpObject7 | Add-Member -MemberType NoteProperty -Name "DatabaseName" -Value "DB7"
# $tmpObject7 | Add-Member -MemberType NoteProperty -Name "ProjectName" -Value "DB7"
# $DBobjArray += $tmpObject7




$Root = resolve-path .		#returns location of this script - hence enables relative paths
							#apparently another way to do this is       Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent
							#See http://powershellcommunity.org/Forums/tabid/54/aff/1/aft/5419/afv/topic/afpg/1/Default.aspx for more on relative paths
$Root = $Root.Path + "\"

Foreach($DBObj in $DBobjArray)
{
	$DBName = $DBObj.DatabaseName
	$ProjectName = $DBObj.ProjectName
	"DB: " + $DBName + "   Project: " + $ProjectName
	$RootPath = $Root + $ProjectName + "\Scripts\Post-Deployment\SecurityAdditions\"
	$EnvironmentWrapperFile = $RootPath + "SecurityAdditions$Environment.sql"
	
	#####CREATE FOLDERS (IF NOT EXIST)#####
	$UsersFolder = $RootPath + "Users\"
	If(!(Test-Path -path $UsersFolder)){   
		mkdir $UsersFolder | out-null  #One way of making sure no output makes it to the console.
		"   Created folder " + $UsersFolder
		}
	$RolesFolder = $RootPath + "RolePermissions\"
	If(!(Test-Path -path $RolesFolder)){   
		mkdir $RolesFolder | out-null  #One way of making sure no output makes it to the console.
		"   Created folder " + $RolesFolder
		}
	$PermissionsFolder = $RootPath + "PermissionSets\"
	If(!(Test-Path -path $PermissionsFolder)){
		[void](mkdir $PermissionsFolder)   #Another way of making sure no output makes it to the console.
		"   Created folder " + $PermissionsFolder
		}

	$RoleList = Invoke-Sqlcmd -ServerInstance $SQLInstance -database $DBName -InputFile "$Root\GetDatabaseRoleList.sql"
	"PRINT 'Create role permissions for " + '$(DeployType)' + "';" | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile
	Foreach ($Role in $RoleList)
	{
		"   " + $Role.Name
		$VariableArray = "PrincipleName='" + $Role.Name + "'"
		$OutPath = $RolesFolder + $Role.name + "____" + $Environment + ".sql"
		Invoke-Sqlcmd -ServerInstance $SqlInstance -database $DBName -Variable $VariableArray -InputFile "$Root\CreateDDLForAssigningPermissionsPerPrinciple.sql" | Out-File -encoding ascii -FilePath $OutPath #ascii encoding is important if committing to Subversion
		
		":r .\RolePermissions\" + $Role.name + "___$Environment.sql" | Out-File -append -FilePath $EnvironmentWrapperFile -encoding ascii
	}

	$PrincipleList = Invoke-Sqlcmd -ServerInstance $SQLInstance -database $DBName -InputFile "$Root\GetDatabasePrincipalList.sql"
	"" | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile -append #Empty line
	"PRINT 'Create users for " + '$(DeployType)' + "';" | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile -append
	Foreach ($Principle in $PrincipleList)
	{
		"   " + $Principle.Name
		$ReplacedPrinciple = $Principle.name.replace('\','_') #Stripping out backslashes so we can use in a filename

		#####CREATE USER#####
		$StmtCheckIfUserExists = "IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '" + $Principle.name + "') AND EXISTS (select 'x' from master.dbo.syslogins where name = '" + $Principle.Login + "')
		" 
		$StmtCreateUser = 'CREATE USER ['
		$StmtForLogin = '] FOR LOGIN ['
		$StmtDefaultSchema = '] WITH DEFAULT_SCHEMA=['
		$StmtEnd = '];'
		$WholeStmt = $StmtCheckIfUserExists + $StmtCreateUser + $Principle.name + $StmtForLogin + $Principle.Login
		If ($Principle.default_schema_name.Length -gt 0 )  #If there is a default schema, include it!
		{
			$WholeStmt = $WholeStmt + $StmtDefaultSchema + $Principle.default_schema_name
		}
		$WholeStmt = $WholeStmt + $StmtEnd
		$OutPath = $UsersFolder + $ReplacedPrinciple + ".user.sql"
		$WholeStmt | Out-File -encoding ascii -FilePath $OutPath
		":r .\Users\$ReplacedPrinciple.user.sql" | Out-File -append -FilePath $EnvironmentWrapperFile -encoding ascii
	}
	
	"" | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile -append #Empty line
	"PRINT 'Create permissions for " + '$(DeployType)' + "';" | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile -append
	Foreach ($Principle in $PrincipleList)
	{
		$ReplacedPrinciple = $Principle.name.replace('\','_') #Stripping out backslashes so we can use in a filename
		#####SCRIPT PERMISSIONS#####
		$VariableArray = "PrincipleName='" + $Principle.name + "'"
		$OutPath = $PermissionsFolder + $ReplacedPrinciple + "____" + $Environment + ".sql"
		Invoke-Sqlcmd -ServerInstance $SqlInstance -database $DBName -Variable $VariableArray -InputFile "$Root\CreateDDLForAssigningPermissionsPerPrinciple.sql" | Out-File -encoding ascii -FilePath $OutPath #ascii encoding is important if committing to Subversion
		
		":r .\PermissionSets\" + $ReplacedPrinciple + "___$Environment.sql" | Out-File -append -FilePath $EnvironmentWrapperFile -encoding ascii
	}
	
	"" | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile -append #Empty line
	"PRINT 'Create role memberships for " + '$(DeployType)' + "';" | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile -append
	$RoleMembershipList = Invoke-Sqlcmd -ServerInstance $SQLInstance -database $DBName -InputFile "$Root\Generate sp_addrolemember statements.sql"
	Foreach ($RoleMembership in $RoleMembershipList)
	{
		$RoleMembership.Stmt | Out-File -encoding ascii -FilePath $EnvironmentWrapperFile -append #Empty line
	}
}