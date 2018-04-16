foreach ($procedure in $smoprocedures)
{
    if ($procedure.IsSystemObject)
    {
        Write-Warning "procedure '$($procedure.Name)' is a system object and is being skipped."
        continue
    }

    $fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($procedure.Schema).$($procedure.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.ROUTINES
   WHERE    ROUTINE_NAME = '$($procedure.Name)' 
            AND ROUTINE_SCHEMA = '$($procedure.schema)')
   DROP procedure $($procedure.Schema).$($procedure.Name)
GO

"@
    $outputObj = New-Object PSObject -Property @{
        FileName = "Cleanup\$($procedure.Schema).$($procedure.Name).StoredProcedure.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}