<#
    .SYNOPSIS
    Gets the column names and datatypes of the specified index.
    .PARAMETER Index
    The Index object to retrieve metadata for.
    .PARAMETER Included
    If specified, will include any "Included", non-key columns in the output.
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>

function Get-SQLIndexColumns
{
    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true)]
        [Microsoft.SqlServer.Management.Smo.Index]$Index,
        [parameter(mandatory=$false)]
        [Switch]$Included
    )

    $cols = @()

    foreach ($col in $Index.IndexedColumns)
    {
        if (($Included -and $col.IsIncluded -eq $true) -or ((-not $Included) -and $col.IsIncluded -eq $false))
        {
            
            $colName = $col.Name
            $colType = $Index.Parent.Columns[$colName].DataType.Name
            $colLength = $Index.Parent.Columns[$colName].DataType.MaximumLength
            $colPrecision = $Index.Parent.Columns[$colName].DataType.NumericPrecision
            $colScale = $Index.Parent.Columns[$colName].DataType.NumericScale
            $colDocumentConstraint = $Index.Parent.Columns[$colName].DataType.XmlDocumentConstraint
            $colSchema = $Index.Parent.Columns[$colName].DataType.Schema

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
    }

    Write-Output $cols


}