param
(
    [Parameter(Mandatory=$true)]
    [object[]]$fileContent,

    [Parameter(Mandatory=$true)]
    #Key = Original Text Regex, Value = Replacement Text
    [hashtable] $mappingKeyValuePair
)

[bool]$filesReconfigured = $false

foreach($orignalTextRegex in $mappingKeyValuePair.Keys)
{
    if($fileContent -imatch $orignalTextRegex){
        $fileContent = $fileContent -ireplace $orignalTextRegex, $mappingKeyValuePair[$orignalTextRegex]
    }
}        

return $fileContent