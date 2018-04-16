foreach ($function in $smofunctions)
{
    if ($function.IsSystemObject)
    {
        Write-Warning "function '$($function.Name)' is a system object and is being skipped."
        continue
    }

    $fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($function.Schema).$($function.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.ROUTINES
   WHERE    ROUTINE_NAME = '$($function.Name)' 
            AND ROUTINE_SCHEMA = '$($function.schema)')
   DROP FUNCTION $($function.Schema).$($function.Name)
GO

"@
    $outputObj = New-Object PSObject -Property @{
        FileName = "Cleanup\$($function.Schema).$($function.Name).function.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}