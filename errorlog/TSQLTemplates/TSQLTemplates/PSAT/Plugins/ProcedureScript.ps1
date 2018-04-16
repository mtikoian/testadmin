$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
$scriptOptions.ExtendedProperties = $true
$scriptOptions.Permissions = $true

foreach ($procedure in $smoProcedures)
{
    if ($procedure.IsSystemObject)
    {
        Write-Warning "Procedure '$($procedure.Name)' is a system object and will be skipped."
        continue
    }
    $fileContent = $procedure.Script($scriptOptions)

    $headerContent = @"
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
            AND ROUTINE_SCHEMA = '$($procedure.Schema)')
   DROP PROCEDURE $($procedure.Schema).$($procedure.Name);
GO
"@
    
    $fileContent.Insert(0,$headerContent)

    $fileContent = [String]::Join("`r`nGO`r`n",($fileContent | %{$_}))
    
    # Replace delimiters
    #$fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

    $outputObj = New-Object PSObject -Property @{
        FileName = "Procedures\$($procedure.Schema).$($procedure.Name).StoredProcedure.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}