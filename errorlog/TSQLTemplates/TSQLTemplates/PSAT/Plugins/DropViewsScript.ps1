foreach ($view in $smoViews)
{
    if ($view.IsSystemObject)
    {
        Write-Warning "View '$($view.Name)' is a system object and is being skipped."
        continue
    }

    $fileContent = @"
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
            AND TABLE_SCHEMA = '$($view.schema)')
   DROP view $($view.Schema).$($view.Name)
GO

"@
    $outputObj = New-Object PSObject -Property @{
        FileName = "Cleanup\$($view.Schema).$($view.Name).view.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}