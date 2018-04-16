<#
    .SYNOPSIS
    Prepends the given text to a given string.
    .PARAMETER PrependText
    The text to prepend.
    .PARAMETER Text
    The text to which to prepend the given string.
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>
function Add-PreText
{
    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true)]
        [String]$PrependText,
        [parameter(mandatory=$true,ValueFromPipeline=$true)]
        [String]$Text
    )
    process
    {
        $Text = "$PrependText$Text"
        Write-Output $Text
    }
}