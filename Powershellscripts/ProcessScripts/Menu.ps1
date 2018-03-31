$scriptOriginalLocation = Get-Location
$Invocation = (Get-Variable MyInvocation -Scope 0).Value

[string]$scriptPath = Split-Path $Invocation.MyCommand.Path

Set-Location $scriptPath

. .\Shared\Ref\Function_Misc.ps1

function ResetLocation
{
    Set-Location  $scriptOriginalLocation.Path
}

function GetErrorDetails()
{
    [string]$errorDetails = $Error[0].Exception
    $errorDetails += GetInnerException($Error[0].Exception.InnerException)

    return $errorDetails
}

function GetInnerException([SystemException]$exception)
{
    [string]$innerException = [string]::Empty

    if($exception -ne $null)
    {
        $innerException += $exception.Message
        $innerException += GetInnerException -exception $exception.InnerException
    }

    return $innerException
}

function SelectMenu
(
    [Parameter(Mandatory = $true)]
    [string[]]$menuOptions,

    [Parameter(Mandatory = $true)]
    [string]$promptText
)
{
    [string]$choice = $null    
    [int]$selectedOption = 0

    Do
    {
        [int]$optionNumber = 1

        Write-Host "------------------MENU OPTION--------------------" -ForegroundColor Yellow
        Write-Host
        
        [string]$arrayCount = $menuOptions.Count

        foreach($menuOption in $menuOptions)
        {
            [string]$optionNumberText = $optionNumber
            $optionNumberText = $optionNumberText.PadLeft(($arrayCount.Length - $optionNumberText.Length) + 1, ' ')

            Write-Host $($optionNumberText + ". " + $menuOption) -ForegroundColor Green
            $optionNumber++
        }

        Write-Host "-------------------------------------------------" -ForegroundColor Yellow

        $choice = read-host -prompt $promptText

        if(![int]::TryParse($choice, [ref]$selectedOption))
        {
            Write-Host
            Write-Warning "Value entered is not in the provided menu options. Please re-enter valid menu option."
        }
        
        Write-Host
    }
    until ($selectedOption -gt 0 -and $selectedOption -le $menuOptions.Count)

    return $selectedOption - 1 #Index of array
}

try
{
    [bool]$displayMenu = $true

    while($displayMenu -eq $true)
    {
        [string[]]$scriptsMenuOptions = @()
        [int]$menuSelectedIndex = 0 

        try
        {
            [string[]]$foldersList = Get-ChildItem ".\*" -Directory | Select-Object -ExpandProperty Name

            $scripts = get-childitem $scriptPath -Filter "*.ps1" -Recurse

            [hashtable]$folderAndScripts = @{}

            foreach($script in $scripts)
            {
                if($foldersList.Contains($script.Directory.Name))
                {
                    if($folderAndScripts.ContainsKey($script.Directory.Name)){
                        $folderAndScripts[$script.Directory.Name] +=  $script.FullName
                    }
                    else{
                        $folderAndScripts.Add($script.Directory.Name, @($script.FullName))
                    }
                }
            }

            if($folderAndScripts.Count -gt 0)
            {
                [string[]]$mainMenuOptions = $folderAndScripts.Keys | Sort-Object
                
                $menuSelectedIndex = SelectMenu -menuOptions $mainMenuOptions -promptText "Enter Directory Number"

                $scriptsMenuOptions = $folderAndScripts[$mainMenuOptions[$menuSelectedIndex]] | Sort-Object

                $scriptsMenuOptions += "Go Back"

                $menuSelectedIndex = SelectMenu -menuOptions (Split-Path $scriptsMenuOptions -Leaf) -promptText "Enter Script Number" 

                if($menuSelectedIndex -eq $scriptsMenuOptions.Count -1){
                    
                    continue
                }
                else
                {
                    [string]$selectedScript = $scriptsMenuOptions[$menuSelectedIndex]
        
                    Set-Location  (Split-Path $selectedScript -Parent)

                    Invoke-Expression $selectedScript
                }
            }
        }
        catch
        {
            Write-Host 
            Write-Host $(GetErrorDetails) -ForegroundColor Red
            Write-Host            
        }
        finally
        {            
            if($menuSelectedIndex -ne $scriptsMenuOptions.Count -1)
            {
                Write-Host
                [string]$exitConfirmation = PromptForYesNoValue -displayMessage "Do you want to execute another script?" 
                Write-Host
        
                $displayMenu = ($exitConfirmation -ine "n")
                Set-Location $scriptPath
            }
        }
    }    
}
catch
{
    throw
}
finally
{
    ResetLocation 
}