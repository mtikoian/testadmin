foreach ($table in $smoTables)
{
    if ($table.IsSystemObject)
    {
        Write-Warning "Table '$($table.Name)' is a system object and will be skipped."
        continue
    }
    $fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$($table.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.TABLES
   WHERE    TABLE_NAME = '$($table.Name)' 
            AND TABLE_SCHEMA = '$($table.Schema)')
   DROP TABLE $($table.Schema).$($table.Name);
GO

"@
    $outputObj = New-Object PSObject -Property @{
        FileName = "Cleanup\$($table.Schema).$($table.Name).table.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}