<#
    .SYNOPSIS
    Formats a set of column metadata as a select / insert definition
    .PARAMETER Name
    The name of the column
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>
function Out-ColumnDoc
{

    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$DataType,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$Length,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$Precision,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$Scale
    )
    process
    {
        $colDocText = "$Name".PadRight(32)

        $colDocText += switch ($DataType)
                      {
                        "varchar" {" $DataType($Length)"}
                        "char" {" $DataType($Length)"}
                        "varbinary" {" $DataType($Length)"}
                        "binary" {" $DataType($Length)"}
                        "nvarchar" {" $DataType($Length)"}
                        "nchar" {" $DataType($Length)"}
                        "decimal" {" $DataType($Precision,$Scale)"}
                        "numeric" {" $DataType($Precision,$Scale)"}
                        "XML" { switch ($DocumentConstraint)
                                {
                                    $null { switch ($Schema)
                                            {
                                                $null {" XML"}
                                                default {" XML($Schema)"}
                                            }
                                          }
                                    default {" XML($DocumentConstraint)"}
                                }
                              }
                        default {" $DataType"}
                      }
        $colDocText = $colDocText.PadRight(64)                      
        Write-Output $colDocText
    }

}