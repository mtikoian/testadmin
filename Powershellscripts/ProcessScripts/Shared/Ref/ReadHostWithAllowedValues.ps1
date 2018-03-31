Param(
        [Parameter(Mandatory = $true)]
		[string]$message, 
		
        #Key is the display text, value is the return value for the selection
		[Parameter(Mandatory = $true)]		
		[hashtable]$allowedValues, 		
		
		[string]$defaultValue = $null,

        [string]$title = $null
	)

[object]$selectedValue = $null

if(![string]::IsNullOrWhiteSpace($defaultValue) -and !$allowedValues.ContainsValue($defaultValue))
{
    Write-Warning "Default value is not set, as the value supplied does not exist in allowed values."
}

[System.Management.Automation.Host.ChoiceDescription[]]$choiceDescriptions = @() 

[object[]]$allowedValueKeys = @()
[int]$count = 0
[int]$defaultSelectedIndex = -1

foreach($key in $($allowedValues.Keys | Sort-Object))
{
    if($defaultValue -ieq $allowedValues[$key])
    {
        $defaultSelectedIndex = $count
    }
             
	$choiceDescriptions += New-Object System.Management.Automation.Host.ChoiceDescription "$key", "Sets $($key.ToString().Replace("&",`"")) as the answer"
    $allowedValueKeys += $key
    $count ++
} 
      
[int]$result = $Host.UI.PromptForChoice( $title, $Message, $choiceDescriptions, $defaultSelectedIndex )  

$selectedValue = $allowedValues[$allowedValueKeys[$result]]

return $selectedValue