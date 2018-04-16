$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
$scriptOptions.Permissions = $true


foreach ($synonym in $smosynonyms)
{
   
    $fileContent = $synonym.Script($scriptOptions)

    $headerContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($synonym.Schema).$($synonym.Name)

 Revisions
 -------------------------------------------------------------------------------
 Ini    | Date      | Description
 -------------------------------------------------------------------------------

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.synonyms
   WHERE    name = '$($synonym.Name)' 
            AND SCHEMA_NAME(schema_id) = '$($synonym.Schema)')
   DROP SYNONYM $($synonym.Schema).$($synonym.Name);
GO

"@
    $fileContent.Insert(0,$headerContent)
    
    $fileContent = [String]::Join("`r`n",($fileContent | %{$_}))

    # Replace delimiters
    $fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

    $outputObj = New-Object PSObject -Property @{
        FileName = "Synonyms\$($synonym.Schema).$($synonym.Name).synonym.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}