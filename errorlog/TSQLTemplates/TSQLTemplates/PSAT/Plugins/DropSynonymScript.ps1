foreach ($synonym in $smosynonyms)
{
    $fileContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($synonym.Schema).$($synonym.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.synonyms
   WHERE    name = '$($synonym.Name)' 
            AND SCHEMA_NAME(schema_id) = '$($synonym.Schema)')
   DROP SYNONYM $($synonym.Schema).$($synonym.Name);
GO

"@
    $outputObj = New-Object PSObject -Property @{
        FileName = "Cleanup\$($synonym.Schema).$($synonym.Name).synonym.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}