$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions

foreach ($function in $smoFunctions)
{
    if ($function.IsSystemObject)
    {
        Write-Warning "Funtion '$($function.Name)' is a system object and will be skipped."
        continue
    }
    $fileContent = $function.Script($scriptOptions)

    $headerContent = @"
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
            AND ROUTINE_SCHEMA = '$($function.Schema)')
   DROP FUNCTION $($function.Schema).$($function.Name);
GO


"@
    
    $fileContent.Insert(0,$headerContent)

    $fileContent = [String]::Join("`r`nGO`r`n",($fileContent | %{$_}))

    # Replace delimiters
    #$fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

    $outputObj = New-Object PSObject -Property @{
        FileName = "Functions\$($function.Schema).$($function.Name).UserDefinedFunction.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}