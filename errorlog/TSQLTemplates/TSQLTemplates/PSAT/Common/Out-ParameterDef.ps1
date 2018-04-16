<#
    .SYNOPSIS
    Formats a set of column metadata as a parameter definition
    .PARAMETER Name
    The name of the column
    .PARAMETER DataType
    The datatype of the column
    .PARAMETER Scale
    The scale of the column
    .PARAMETER Preceision
    The precision of the column
    .PARAMETER Length
    The length of the column
    .PARAMETER DocumentConstraint
    The constraint parameter of the column (for XML columns)
    .PARAMETER Schema
    The bound XML schema of the column (for XML columns only)
    .PARAMETER Prefix
    A piece of text to prefix parameter names with, such as "pi_".
    .PARAMETER NoTypeInfo
    If specified, no type information will be included (i.e. no "VARCHAR(10)" after definition).
    .PARAMETER PadLength
    The amount of spaces to pad the definition with on the right. Useful for documentation.
    .NOTES
        Author - Josh Feierman
        Date   - 9/18/2012
#>
function Out-ParameterDef
{

    [Cmdletbinding()]
    param
    (
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$DataType,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$Scale,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$Precision,
        [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$Length,
        [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [String]$DocumentConstraint,
        [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [String]$Schema,
        [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [String]$Prefix,
        [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [Switch]$NoTypeInfo,
        [parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)]
        [int]$PadLength = 30
    )
    process
    {
        $paramText = switch ($Prefix)
                     {
                        $Null {"@$Name"}
                        Default {"@$Prefix$Name"}
                     }
        if (-not $NoTypeInfo)
        {
          $paramText += switch ($DataType)
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
        }
        Write-Output $paramText.PadRight($PadLength)
    }

}