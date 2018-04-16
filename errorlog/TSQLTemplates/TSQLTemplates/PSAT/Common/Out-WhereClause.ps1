<#
    .SYNOPSIS
    Formats a set of column metadata as a WHERE clause
    .PARAMETER Name
    The name of the column
    .PARAMETER Prefix
    A piece of text to prefix parameter names with, such as "pi_".
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>
function Out-WhereClause
{

    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name,
        [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [String]$Prefix
    )
    process
    {
        $paramText = switch ($Prefix)
                     {
                        $Null {"$Name = @$Name"}
                        Default {"$Name = @$Prefix$Name"}
                     }
        Write-Output $paramText
    }

}