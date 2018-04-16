<#
    .SYNOPSIS
    Gets the column names and datatypes of the specified table.
    .PARAMETER Table
    The Table object to retrieve metadata for.
    .PARAMETER NoIdentityColumns
    If specified, identity columns will be skipped.
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>

function Get-SQLTableColumns
{
    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true)]
        [Microsoft.SqlServer.Management.Smo.Table]$Table,
        [parameter(mandatory=$false)]
        [Switch]$NoIdentityColumns
    )

    $cols = @()

    foreach ($col in $Table.Columns)
    {

        # Skip identity columns if specified
        if (($NoIdentityColumns) -and ($col.Identity))
        {
          continue
        }
        $colName = $col.Name
        $colType = $col.DataType.SQLDataType
        $colLength = $col.DataType.MaximumLength
        $colPrecision = $col.DataType.NumericPrecision
        $colScale = $col.DataType.NumericScale
        $colDocumentConstraint = $col.DataType.XmlDocumentConstraint
        $colSchema = $col.DataType.Schema
        $colDef = New-Object PSObject -Property @{
            Name = $colName
            DataType = $colType
            Length = $colLength
            Precision = $colPrecision
            Scale = $colScale
            DocumentConstraint =$colDocumentConstraint
            Schema = $colSchema
        }

        $cols += $colDef
    }

    Write-Output $cols


}