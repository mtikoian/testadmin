$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions

foreach ($table in $smoTables)
{
    foreach ($index in $table.Indexes)
    {
        if (-not ($index.IndexKeyType -eq [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriPrimaryKey))
        {
            $headerContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$($table.Name).$($index.Name)

 Revisions
 -------------------------------------------------------------------------------
 Ini    | Date      | Description
 -------------------------------------------------------------------------------
 
 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.indexes
   WHERE    name = '$($index.Name)')
   DROP INDEX $($index.Name) ON $($table.Schema).$($table.Name);
GO

"@
            $fileContent = $index.Script($scriptOptions)
            $fileContent.Insert(0,$headerContent)
        
            $fileContent = [String]::Join("`r`n",($fileContent | %{$_}))

             # Replace delimiters
            $fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

            $outputObj = New-Object PSObject -Property @{
                FileName = "Indexes\$($table.Schema).$($table.Name).$($index.Name).idx.sql"
                FileContent = $fileContent
            }
            Write-Output $outputObj
        }
    }
}