foreach ($table in $smoTables)
{
    Write-Verbose "Starting table $($table.Name)"
	if ($table.IsSystemObject)
    {
        Write-Warning "Table '$($table.Name)' is a system object and is being skipped."
        continue
    }

    foreach ($key in $table.ForeignKeys)
    {
        $fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$($table.Name).$($key.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.foreign_keys
   WHERE    name = '$($key.Name)' )
   ALTER TABLE $($table.Schema).$($table.Name) DROP CONSTRAINT $($key.Name)
GO

"@
        $outputObj = New-Object PSObject -Property @{
            FileName = "Cleanup\$($table.Schema).$($table.Name).$($key.Name).fk.sql"
            FileContent = $fileContent
        }
        Write-Output $outputObj
	}

}