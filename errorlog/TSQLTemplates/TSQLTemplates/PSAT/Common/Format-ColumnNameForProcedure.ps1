<#
    .SYNOPSIS
    Formats a set of column metadata, replacing some characters to make
    the name more readable for stored procedure names.
    .PARAMETER Name
    The name of the column
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>
function Format-ColumnNameForProcedure
{

    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name
    )
    process
    {
        $Name = [System.Text.RegularExpressions.Regex]::Replace($Name,"_([a-zA-z])",{param ($m) $m.Groups[1].Value.ToUpper()})
        $Name = [System.Text.RegularExpressions.Regex]::Replace($Name,"^([a-zA-z])",{param ($m) $m.Value.ToUpper()})
        Write-Output $Name
    }

}