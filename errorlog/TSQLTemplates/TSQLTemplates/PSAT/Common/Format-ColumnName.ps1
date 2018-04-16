<#
    .SYNOPSIS
    Formats a set of column metadata as a select / insert definition
    .PARAMETER Name
    The name of the column
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>
function Out-ColumnList
{

    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name
    )
    process
    {
        $Text = "$Name"
        Write-Output $Text
    }

}