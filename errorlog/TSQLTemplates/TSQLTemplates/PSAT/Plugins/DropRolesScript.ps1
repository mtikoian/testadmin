foreach ($role in $smoroles)
{
    if ($role.IsFixedRole)
    {
        Write-Warning "role '$($role.Name)' is a system object and is being skipped."
        continue
    }

    $fileContent = @"
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
   WHERE    name = '$($role.Name)' 
            AND type = 'R')
   DROP ROLE $($role.Name)
GO

"@
    $outputObj = New-Object PSObject -Property @{
        FileName = "Cleanup\$($role.Name).role.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}