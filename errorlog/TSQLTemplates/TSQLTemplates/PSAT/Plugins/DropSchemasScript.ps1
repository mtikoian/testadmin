foreach ($schema in $smoschemas)
{
    if ($schema.IsSystemObject)
    {
        Write-Warning "Schema '$($schema.Name)' is a system object and is being skipped."
        continue
    }

    $fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($schema.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.schemas
   WHERE    name = '$($schema.Name)' )
   DROP SCHEMA $($schema.Name)
GO

"@
    $outputObj = New-Object PSObject -Property @{
        FileName = "Cleanup\$($schema.Name).sch.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}