$scriptOptions = New-Object Microsoft.SqlServer.Management.Smo.ScriptingOptions
$scriptOptions.ExtendedProperties = $true
$scriptOptions.Permissions = $true
$scriptOptions.ScriptOwner = $true

foreach ($schema in $smoSchemas)
{
    if ($schema.IsSystemObject)
    {
        Write-Warning "Schema '$($schema.Name)' is a system object and will be skipped."
        continue
    }
    $fileContent = $schema.Script($scriptOptions)

    $headerContent = @"
/********************************************************************************
 Last Checked In By: `$Author`$
 Last Checked In On: `$Date`$
 URL               : `$URL`$
 Revision          : `$Rev`$
 
 Object: $($schema.Name)

 ********************************************************************************/

IF EXISTS (
   SELECT   1
   FROM     sys.schemas
   WHERE   name = '$($schema.Name)' 
   DROP SCHEMA $($schema.Name);
GO
"@
    
    $fileContent.Insert(0,$headerContent)

    $fileContent = [String]::Join("`r`n",($fileContent | %{$_}))

    # Replace delimiters
    $fileContent = [System.Text.RegularExpressions.regex]::Replace($fileContent,"(?<!ON\W+)\[([^[]+)\]","`$1")

    $outputObj = New-Object PSObject -Property @{
        FileName = "Schemas\$($schema.Name).sch.sql"
        FileContent = $fileContent
    }

    Write-Output $outputObj
}