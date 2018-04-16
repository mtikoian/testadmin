<#
    .SYNOPSIS
    Returns a collection of index objects for the given table.
    .PARAMETER Table
    The Microsoft.SQLServer.Management.SMO.Table object to retrieve indexes for.
    .NOTES
        Author     - Josh Feierman
        Date       - 9/17/2012

#>
function Get-SQLTableIndexes
{

    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true)]
        [Microsoft.SqlServer.Management.Smo.Table]$Table
    )

    Write-Output $Table.Indexes | Add-Member -MemberType NoteProperty -Name "TableName" -Value $Table.Name -PassThru
    
}