param
(
    [Parameter(Mandatory=$true)]    
    $branchType,

    [Parameter(Mandatory=$true)]
    $branchState,

    $returnFullServerPath = $true
)

#references
. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Shared\Ref\Function_Misc.ps1

function IsBranchValid([string] $branchName){   
    [bool] $branchValid = $false

    if([string]::IsNullOrWhiteSpace($branchName)){
        Write-Warning "Branch name is blank" 
        return $branchValid           
    }

    [string[]]$existingBranchNames = $null

    if($branchType -eq $BranchTypeEnum.Dev){
        $existingBranchNames = Get-TfsChildItem "$($DevConfigData.DevBranchesServerDirPath)/*" -Folders | ForEach-Object { $_.ServerItem.Replace("$($DevConfigData.DevBranchesServerDirPath)/", "") }
    }
    elseif($branchType -eq $BranchTypeEnum.Release){
        $existingBranchNames = Get-TfsChildItem "$($DevConfigData.ReleaseBranchesServerDirPath)/*" -Folders | ForEach-Object { $_.ServerItem.Replace("$($DevConfigData.ReleaseBranchesServerDirPath)/", "") }
    }
    else{
        throw "Branch type passed is unsupported: $branchType"
    } 

    if($branchState -eq $BranchStateEnum.Existing -and $existingBranchNames -inotcontains $branchName){
        Write-Warning "Branch $branchName does not exist"
    }
    elseif($branchState -eq $BranchStateEnum.New -and $existingBranchNames -icontains $branchName){
        Write-Warning "Branch $branchName already exists" 
    }
    else{
        $branchValid=$true
    }     

    return $branchValid
}

[string]$selectedBranchName = $null    

while([string]::IsNullOrWhiteSpace($selectedBranchName) )
{
    $serverDirPath = $null

    if($branchType -eq $BranchTypeEnum.Any)
    {
        $isWorkItemSpecific = Read-Host "Is the branch specific to a work item? Y/N"

        if($isWorkItemSpecific -ieq "y"){
            $branchType = $BranchTypeEnum.Dev
        }
        else{
            $branchType = $BranchTypeEnum.Release
        }

        Write-Host
    }

    if($branchType -eq $BranchTypeEnum.Dev)
    {   
        $selectedBranchName = ..\Dev\Ref\WorkItem_PromptForNumber.ps1
        $selectedBranchName = $DevConfigData.BranchNameWorkItemFormat -f $selectedBranchName
        $serverDirPath = $DevConfigData.DevBranchesServerDirPath
    }
    elseif($branchType -eq $BranchTypeEnum.Release)
    {
        if($branchState -ieq $BranchStateEnum.New)
        {
            $selectedBranchName = Read-Host "Enter release branch name"

            if($selectedBranchName -inotmatch ($DevConfigData.ReleaseBranchNameFormat -f "\d+"))
            {
                Write-Warning "$selectedBranchName is not a valid release branch name. Release branch name format is: $($DevConfigData.ReleaseBranchNameFormat -f "\d+")"
                $selectedBranchName = $null
                continue
            }
        }
        else
        {
            $releaseBranchNames = Get-TfsChildItem "$($DevConfigData.ReleaseBranchesServerDirPath)/*" -Folders | ForEach-Object { $_.ServerItem.Replace("$($DevConfigData.ReleaseBranchesServerDirPath)/", "") }

            [hashtable]$allowedValues = @{}

            for($i=1; $i -le $releaseBranchNames.Count; $i++)
            {
                $releaseBranchName = $releaseBranchNames[$i-1]
                $allowedValues.Add("&$i.$releaseBranchName","$releaseBranchName")
            }
            
            $selectedBranchName = ..\Shared\Ref\ReadHostWithAllowedValues.ps1 -message "Select release branch from the following" -allowedValues ($allowedValues | Sort-Object Name)
        }

        $serverDirPath = $($DevConfigData.ReleaseBranchesServerDirPath)
    }
    else{
        throw "Branch type passed is unsupported: $branchType"
    }  
    
    if(!(IsBranchValid $selectedBranchName))
    {
        $selectedBranchName = $null
        Write-Host
    }
    elseif($returnFullServerPath){
        $selectedBranchName = "$($serverDirPath)/$selectedBranchName"
    }            
}

Write-Host
Write-Host "Branch $selectedBranchName is selected."

return $selectedBranchName