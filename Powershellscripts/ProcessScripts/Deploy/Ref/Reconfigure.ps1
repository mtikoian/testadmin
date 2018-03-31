param(
    [parameter(Mandatory=$true)]
    [string]$deployConfigFilePath
)

#This should match the keys defined in template node of Deploy.config
$matchTypes = [PsCustomObject] @{
    Regex = "regex"
    XPath = "xpath"
}

[System.Reflection.Assembly]::LoadWithPartialName("System.Xml") | Out-Null

[xml]$deploymentConfiguration = Get-Content $deployConfigFilePath

function GetReconfigureMapping([System.Xml.XmlElement]$xmlComponentNode)
{
    $reconfigureMapping = @{}

    $reconfigureNodes = $xmlComponentNode.SelectNodes("reconfigure")

    if($reconfigureNodes -ne $null)
    {
        foreach($reconfigureNode in $reconfigureNodes)
        {
            if([string]::IsNullOrWhiteSpace($reconfigureNode.filePathRelToComponent))
            {
                throw "FilePathRelToComponent does not exists for $($xmlComponentNode.name)"
            }
            
            $filePath = $xmlComponentNode.deployDirPath + "\" + $reconfigureNode.filePathRelToComponent
			
			[PSCustomObject[]]$reconfigureDetails = @()

            $template = $deploymentConfiguration.SelectSingleNode("/configuration/reconfigTemplates/template[@name='$($reconfigureNode.templateName)']")

            if($template -eq $null)
            {
                throw "Template $($reconfigureNode.templateName) does not exist in config file"
            }
            
            foreach($reconfigureValue in $reconfigureNode.values.ChildNodes)
            {
                $key = $template.Keys.ChildNodes | Where-Object { $_.name -ieq $reconfigureValue.keyName}

                if($key -eq $null)
                {
                    throw "Reconfigure value $($reconfigureValue.keyName) does not exist for $($reconfigureNode.filePathRelToComponent) in config file. "
                }

                if($key.Count -gt 1)
                {
                    throw "Invalid reconfigureValue node: $($key.name) in $($reconfigureNode.templateName)"
                }

                $attribute = $null
                $matchType = $null

                if($key.LocalName -ieq $matchTypes.XPath)
                {
                    $attribute = $key.reconfigAttribute

                    if($attribute -eq $null -or [string]::IsNullOrWhiteSpace($attribute))
                    {
                        $attribute = '#text'
                    }

                    $matchType = $matchTypes.XPath
                }
                elseif ($key.LocalName -ieq $matchTypes.Regex)
                {
                    $matchType = $matchTypes.Regex
                }

                if([string]::IsNullOrWhiteSpace($($reconfigureValue.'#text')))
                {
                    throw "Reconfig value ($($key.name)) is missing for $($reconfigureNode.filePathRelToComponent) in config file"
                }

                $reconfigureDetails += [PSCustomObject]@{ 
                                        MatchType = $matchType
                                        MatchValue = $key.value
                                        Attribute = $attribute
                                        ReplacementValue = $reconfigureValue.'#text'                                   
                                        }
            }

            

            $reconfigureMapping.Add($filePath, $reconfigureDetails)            
        }        
    }

    return $reconfigureMapping
}

function ReconfigureXmlFile([PSCustomObject[]]$reconfigureValues,[string]$reconfigFilePath)
{   
    [xml]$xml = $null
    [string[]]$fileContent = Get-Content -LiteralPath $reconfigFilePath

    $filecontent = $filecontent | Where {![string]::IsNullOrWhiteSpace($_.Trim()) }

    [string]$xmlRegEx = 'xmlns=".+?"'    

    [PSCustomObject[]]$xmlNamespaces = @()

    for($lineIndex=0; $lineIndex -lt $fileContent.Length; $lineIndex++)
    {
        [string]$line = $fileContent[$lineIndex]

        if($line -imatch $xmlRegEx)
        {
            $xmlNamespaces += [PSCustomObject]@{ 
                                    OriginalLineText = $line
                                    LineIndex = $lineIndex                                                                                    
                                }
                    
            $fileContent[$lineIndex] = $line -ireplace $xmlRegEx,""
        }
    }

    $xml = $fileContent    

    foreach($reconfigureValue in $reconfigureValues)
    {
        if($reconfigureValue.MatchType -ieq $matchTypes.XPath)
        {
            $nodeToReconfigure = $xml.SelectSingleNode($reconfigureValue.MatchValue)
            $attribute = $reconfigureValue.Attribute        
            $nodeToReconfigure.$attribute = $reconfigureValue.ReplacementValue
        }
        else
        {
            $xml.InnerXml = $xml.InnerXml -ireplace $reconfigureValue.MatchValue, $reconfigureValue.ReplacementValue
        }
    }

    $xml.Save($reconfigFilePath)

    $fileContent = Get-Content -LiteralPath $reconfigFilePath

    foreach($xmlNamespace in $xmlNamespaces)
    {
        $fileContent[$xmlNamespace.LineIndex] = $xmlNamespace.OriginalLineText
    }
            
    $xml = $fileContent
    $xml.Save($reconfigFilePath)
}

function ReconfigureComponent([hashtable]$reconfigureMapping)
{
    foreach($filePath in $reconfigureMapping.Keys)
    {
        $reconfigValues = $reconfigureMapping[$filePath]

        $reconfigMatchTypes = $reconfigValues | Select-Object -ExpandProperty MatchType

        [bool]$containsXPath = $reconfigMatchTypes -icontains $matchTypes.XPath

        if($containsXPath)
        {
            ReconfigureXmlFile -reconfigureValues $reconfigValues -reconfigFilePath $filePath
        }
        else
        {
            [string[]]$fileContent = Get-Content -LiteralPath $filePath

            foreach($reconfigValue in $reconfigValues)
            {
                $fileContent = $fileContent -ireplace $reconfigValue.MatchValue, $reconfigValue.ReplacementValue
            }

            Set-Content $filePath $fileContent
        }
            
        Write-Host "Reconfigured $filePath file"  
    }    
}