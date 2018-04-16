$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
$scriptOptions.ClusteredIndexes = $true
$scriptOptions.DriChecks = $true
$scriptOptions.DriDefaults = $true
$scriptOptions.DriPrimaryKey = $true
$scriptOptions.ExtendedProperties = $true
$scriptOptions.Permissions = $true


foreach ($table in $smoTables)
{
    if ($table.IsSystemObject)
    {
        Write-Warning "Table '$($table.Name)' is a system object and will be skipped."
        continue
    }
    
    $fileContent = $table.Script($scriptOptions)

    $headerContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($table.Schema).$($table.Name)

 Revisions
 -------------------------------------------------------------------------------
 Ini    | Date      | Description
 -------------------------------------------------------------------------------

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.TABLES
   WHERE    TABLE_NAME = '$($table.Name)' 
            AND TABLE_SCHEMA = '$($table.Schema)')
   DROP TABLE $($table.Schema).$($table.Name);
GO


"@
    $fileContent.Insert(0,$headerContent)

    $fileContent = [String]::Join("`r`n",($fileContent | %{$_}))

    # Replace delimiters
    $fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

    $outputObj = New-Object PSObject -Property @{
        FileName = "Tables\$($table.Schema).$($table.Name).table.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}