param
(
    [string] $branchServerPath = $null
)

#references
. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1
. ..\Shared\Ref\Version_Management.ps1

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.VersionControl.Client.ItemSpec") | Out-Null

[string]$trunkServerPath = "$($DevConfigData.ReleaseBranchesServerDirPath)/$($DevConfigData.TrunkName)"

if([string]::IsNullOrWhiteSpace($branchServerPath))
{
    $branchServerPath =  ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Dev -returnFullServerPath $true -branchState $BranchStateEnum.Existing
}

[string]$branchName = $branchServerPath | Split-Path -Leaf

$workItemId = GetWorkItemNumberFromBranchName -branchName $branchName

$workspace = Get-TfsWorkspace "$"

Write-Host "Updating trunk: $trunkServerPath"
Write-Host
..\Dev\AppInstance_Update.ps1 -appInstanceServerPath $trunkServerPath
Write-Host
Write-Host "Trunk update complete"
Write-Host

[string]$mergePreview = $null

try
{
    $mergePreview = tf merge "$trunkServerPath" "$branchServerPath" /recursive /preview /format:detailed
}
catch
{
    #Addresses merge conflicts, which cause the command to throw an error
    $mergePreview = $_.Exception.Message
}

[bool]$hasMergeChanges = $mergePreview -ine "There are no changes to merge."

Write-Host "Updating branch: $branchServerPath"
Write-Host
..\Dev\AppInstance_Update.ps1 -appInstanceServerPath $branchServerPath
Write-Host "Branch $branchServerPath update complete"
Write-Host

AssertNoPendingChanges -serverPath ($trunkServerPath)
AssertNoPendingChanges -serverPath ($branchServerPath)

function FileOrignatedFromTheTrunk([string]$fileName)
{
    [string]$fileServerPath = $branchServerPath + "/" + $DevConfigData.DbDeployRelativeDirPathSuffix + "/" + $fileName
    $fileSpec= New-Object Microsoft.TeamFoundation.VersionControl.Client.ItemSpec -ArgumentList @($fileServerPath, [Microsoft.TeamFoundation.VersionControl.Client.RecursionType]::None)
    $branchHistoryTree = $workspace.VersionControlServer.GetBranchHistory(@($fileSpec),$null)
    $historyRoot = $branchHistoryTree[0][0]
    
    #If the history has children, then this file has been branched. Branches originate from the trunk so this file is from the trunk.
    if($historyRoot.Children.Count -ge 1){
        return $true
    }
    else {
        return $false
    }
}

function GetSqlScriptsHashTable([string]$serverPath)
{
    [string]$scriptNameRegEx = "(?<scriptNumberText>$($DevConfigData.DbScriptNumberRegEx))(?<suffix>.+)"
    [hashtable]$sqlScriptsHashTable = @{}
    
    [object[]]$tfsItems = Get-TfsItemProperty ($serverPath + "/*.sql") -Recurse

    foreach($tfsItem in $tfsItems |where {$_.DeletionId -eq 0})
    {
        $scriptName = $tfsItem.SourceServerItem | Split-Path -Leaf

        $scriptName -imatch $scriptNameRegEx |Out-Null

        if($matches["scriptNumberText"] -eq $null){
            throw $scriptName + " do not contain a numeric execution sequence."
        }
        
        [int]$scriptNumber = [int]$matches["scriptNumberText"]

        if($sqlScriptsHashTable.ContainsKey($scriptNumber)){
            throw "Multiple scripts exist with the script number $($scriptNumber). Please adjust script numbers before proceeding."
        }       

        $UpdateFromTrunkObject=[PsCustomObject] @{
            BranchServerPath = $branchServerPath
            BranchServerSearchPath = $branchServerPath + "/" + $DevConfigData.DbDeployRelativeDirPathSuffix + "/*.sql"
            BranchDBDeployServerPath = $branchServerPath + "/" + $DevConfigData.DbDeployRelativeDirPathSuffix 
            IsDeleted = $tfsItem.DeletionId -ne 0
            TrunkServerPath = $trunkServerPath
            TrunkServerSearchPath = $trunkServerPath + "/" + $DevConfigData.DbDeployRelativeDirPathSuffix + "/*.sql"
            ScriptNameSuffix = $matches["suffix"]
            ScriptNumberText = $matches["scriptNumberText"]
            ScriptName = $scriptName
        }

        $sqlScriptsHashTable.Add($scriptNumber, $UpdateFromTrunkObject)
    }

    return $sqlScriptsHashTable
}

if($hasMergeChanges)
{
    [hashtable]$trunkSqlScriptsHashTable = GetSqlScriptsHashTable -serverPath "$trunkServerPath/$($DevConfigData.DbDeployRelativeDirPathSuffix)"
    [hashtable]$branchSqlScriptsHashTable = GetSqlScriptsHashTable -serverPath "$branchServerPath/$($DevConfigData.DbDeployRelativeDirPathSuffix)"

    [Nullable[int]]$firstScriptNumberNotInTrunk = $null

    foreach($branchKeyValuePair in $branchSqlScriptsHashTable.GetEnumerator() | Sort-Object Key)
    {
        if(!$branchKeyValuePair.Value.IsDeleted -and !(FileOrignatedFromTheTrunk -fileName $branchKeyValuePair.Value.ScriptName))
        {
            $firstScriptNumberNotInTrunk = $branchKeyValuePair.Key
            break
        }
    }

    if($firstScriptNumberNotInTrunk -ne $null)
    {
        [int]$largestScriptNumberInTrunk = ($trunkSqlScriptsHashTable.Keys | Sort-Object -Descending)[0]
        [int]$branchScriptSequenceAdjustment = $largestScriptNumberInTrunk - $firstScriptNumberNotInTrunk + 1

        foreach($scriptNumberAndObjectPair in $branchSqlScriptsHashTable.GetEnumerator() | Sort-Object Key -Descending)
        {
            $scriptNumber = $scriptNumberAndObjectPair.Key
            $scriptDetails = $scriptNumberAndObjectPair.Value

            if($scriptDetails.IsDeleted){
                continue
            }

            if($scriptNumber -lt $firstScriptNumberNotInTrunk){
                continue
            }

            [string]$modifiedScriptNumberText = ($scriptNumber + $branchScriptSequenceAdjustment).ToString()
            $modifiedScriptNumberText = ("0" * ($scriptDetails.ScriptNumberText.Length - $modifiedScriptNumberText.Length)) + $modifiedScriptNumberText

            [string]$renamedScriptPath = $scriptDetails.BranchDBDeployServerPath + "/" + ($modifiedScriptNumberText + $scriptDetails.ScriptNameSuffix)
        
            Cmd_ExecuteCommand "tf rename $($scriptDetails.BranchDBDeployServerPath + "/" + $scriptDetails.ScriptName) $renamedScriptPath"
        }

        Write-Host "Checking in $branchServerPath"
        ..\Dev\Checkin.ps1 -checkinServerPath $branchServerPath -comment "Adjusted script numbers to align with trunk" -workItemNumbers $workItemId -areWorkItemsResolved $false -skipConfirmation $true | Out-Null
        Write-Host "Checking in complete"
        Write-Host
    }


    Write-Host
    Write-Host "Merging from Trunk: $trunkServerPath to Branch: $branchServerPath"
    Cmd_ExecuteCommand "tf merge `"$trunkServerPath`" `"$branchServerPath`" /recursive /format:detailed"
    Write-Host
    Write-Host "Merge complete"

    Write-Host "Checking in $branchServerPath"
    [int]$changesetId = ..\Dev\Checkin.ps1 -checkinServerPath $branchServerPath -workItemNumbers $workItemId -comment "Merged from trunk" -areWorkItemsResolved $false -skipConfirmation $true 
    Write-Host "Check-in complete"
    Write-Host

    Write-Host "Reconfiguring: $branchServerPath"
    Write-Host
    [string[]]$fileServerPaths = GetFilesFromChangesetId -changesetId $changesetId

    if($fileServerPaths -ne $null)
    {
        ..\Dev\Ref\AppInstance_Reconfigure.ps1 -sourceInstanceServerPath $trunkServerPath -targetInstanceServerPath $branchServerPath -fileServerPaths $fileServerPaths

        Write-Host
        Write-Host "Checking in reconfigured files."
        Write-Host
        ..\Dev\Checkin.ps1 -checkinServerPath $branchServerPath -workItemNumbers $workItemId -comment "$($DevConfigData.DoNotMergeStatement) Reconfigured $branchName branch" -areWorkItemsResolved $false -skipConfirmation $true | Out-Null
        Write-Host "Configured: $branchServerPath"
        Write-Host
    }
    else
    {
        Write-Host
        Write-Host "No files to reconfigure."
        Write-Host
    }

    if($firstScriptNumberNotInTrunk -ne $null)
    {
        #create database
        Write-Host "Restoring database: $branchName to align with the trunk"
        Write-Host "Please wait...."
        Write-Host
        ..\Dev\Database_CloneTrunk.ps1 -dbNamePrefix $branchName
        Write-Host "Restore completed"

        #DB Update

        [string[]]$trunkDbNames = $DevConfigData.TrunkDatabaseNames
        [string[]]$branchDbNames = @()

        foreach($trunkDbName in $trunkDbNames){
            $branchDbNames += ($branchName + "_" + $trunkDbName)
        }

        ..\Dev\Ref\AppInstance_ExecuteUpdateScripts.ps1 -databaseNames $branchDbNames -appInstanceServerPath $branchServerPath    
    }
}
return $hasMergeChanges