. ..\Shared\Ref\Function_Misc.ps1

[string]$workItemIdRegex = "^[0-9]\d{1,9}$";

[Nullable[int]]$workItemId = $null
        
while([string]::IsNullOrWhiteSpace($workItemId) -or ($workItemId -cnotmatch $workItemIdRegex))
{
    if($workItemId -ne $null){
        Write-Warning "Work item ID $workItemId is not valid"                                 
        Write-Host
    }
    $workItemId = Read-Host "Enter TFS work item ID (ex: 9999)"

    try
    {
        [int]$parsedWorkItemId = [int]::Parse($workItemId)                
        [hashtable]$workItemInfo = ..\Dev\Ref\WorkItem_GetDetails.ps1 -workItemNumbers $parsedWorkItemId
        
        if(($workItemInfo -eq $null) -or ($workItemInfo.Count -eq 0)){          
            $workItemId = $null
            Write-Host
        }
        else
        {
            Write-Host "$($workItemInfo[$parsedWorkItemId])"
            Write-Host
            [string]$consent = PromptForYesNoValue -displayMessage "Is this the desired work item? Y\N"

            if ($consent -ine "Y"){
                $workItemId = $null
            }
        }
    }
    catch{
        Write-Warning "Cannot parse $workItemId to an integer"
    }            
}

return $workItemId