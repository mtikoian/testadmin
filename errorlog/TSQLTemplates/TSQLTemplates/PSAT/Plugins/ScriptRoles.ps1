$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
$scriptOptions.ExtendedProperties = $true
$scriptOptions.Permissions = $true
$scriptOptions.ScriptOwner = $true
$scriptOptions.IncludeDatabaseRoleMemberships = $true

foreach ($role in $smoroles)
{
    if ($role.IsFixedRole)
    {
        Write-Warning "Role '$($role.Name)' is a system object and will be skipped."
        continue
    }

    if ($role.Name -eq "Public")
    {
        continue
    }

    $fileContent = $role.Script($scriptOptions)

    $headerContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($role.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.database_principals
   WHERE   name = '$($role.Name)'
           AND type = 'R')
   DROP ROLE $($role.Name);
GO
"@
    $fileContent.Insert(0,$headerContent)

    $fileContent = [String]::Join("`r`n",($fileContent | %{$_}))

    # Replace delimiters
    $fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

    $outputObj = New-Object PSObject -Property @{
        FileName = "Roles\$($role.Name).role.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}