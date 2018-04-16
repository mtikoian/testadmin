$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions

foreach ($table in $smoTables)
{
    foreach ($foreignKey in $table.ForeignKeys)
    {
        $headerContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$($table.Name).$($foreignKey.Name)

 Revisions
 -------------------------------------------------------------------------------
 Ini    | Date      | Description
 -------------------------------------------------------------------------------
 
 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.foreign_keys
   WHERE    name = '$($foreignKey.Name)')
   ALTER TABLE $($table.Schema).$($table.Name) DROP CONSTRAINT $($foreignKey.Name);
GO

"@
        $fileContent = $foreignKey.Script($scriptOptions)
        $fileContent.Insert(0,$headerContent)

	    $fileContent = [String]::Join("`r`n",($fileContent | %{$_}))
        
        # Replace delimiters
        $fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")


        $outputObj = New-Object PSObject -Property @{
            FileName = "ForeignKeys\$($table.Schema).$($table.Name).$($foreignKey.Name).fk.sql"
            FileContent = $fileContent
        }
        Write-Output $outputObj
    }
}