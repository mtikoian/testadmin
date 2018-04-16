$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions

foreach ($view in $smoViews)
{
    if ($view.IsSystemObject)
    {
        Write-Warning "Procedure '$($view.Name)' is a system object and will be skipped."
        continue
    }
    $fileContent = $view.Script($scriptOptions)

    $headerContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($view.Schema).$($view.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     INFORMATION_SCHEMA.VIEWS
   WHERE    TABLE_NAME = '$($view.Name)' 
            AND TABLE_SCHEMA = '$($view.Schema)')
   DROP VIEW $($view.Schema).$($view.Name);
GO


"@
    $fileContent.Insert(0,$headerContent)
    
    $fileContent = [String]::Join("`r`nGO`r`n",($fileContent | %{$_}))

    # Replace delimiters
    #$fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

    $outputObj = New-Object PSObject -Property @{
        FileName = "Views\$($view.Schema).$($view.Name).view.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}