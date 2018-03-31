Param
(
    [int]$secondsToPause = 60
)

. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1
. ..\Shared\Ref\Version_Management.ps1

[int]$workItemNumber = ..\Dev\Ref\WorkItem_PromptForNumber.ps1

[string]$emailSenderAddress = $null
[PSCredential]$myCreds = $null

function SendEmail([string]$emailSubject, [string]$emailBody)
{
    if(($DevConfigData.TrunkPromoteEmailActiveDirGroups -eq $null) -or ($DevConfigData.TrunkPromoteEmailActiveDirGroups.Count -eq 0)){
        return
    }

    if([string]::IsNullOrWhiteSpace($emailSenderAddress))
    {
        $senderDetails = GetUserDetails -userName $env:USERNAME

        if($senderDetails -ne $null)
        {
            $emailSenderAddress = $senderDetails.Email
        }
    }

    if($myCreds -eq $null){
        $Script:myCreds = $Host.UI.PromptForCredential("Invalid Credentials", "Please supply your email address and password.", $emailSenderAddress, "")
    }
    
    ..\Shared\Email_Send.ps1 -emailBody $emailBody -emailToAdGroupNames $DevConfigData.TrunkPromoteEmailActiveDirGroups -emailSubject $emailSubject -myCreds $myCreds
}

[string[]]$releaseBranchServerPaths = Get-TfsChildItem -Item ($DevConfigData.ReleaseBranchesServerDirPath + "/*") -Folders | Select-Object -ExpandProperty ServerItem
[PsCustomObject[]]$branchInfos = @()
[PsCustomObject]$trunkInfo = $null

foreach($serverPath in $releaseBranchServerPaths)
{
    $branchName = Split-Path $serverPath -Leaf

    [bool]$isReleaseBranch = $branchName -imatch ($DevConfigData.ReleaseBranchNameFormat -f "(?<branchNumber>\d+)")

    $branchInfo = [PsCustomObject] @{
        Name = $branchName
        ServerPath = $serverPath        
        BranchNumber = if(!$isReleaseBranch) {0} else {[int]$Matches["branchNumber"]}
    }

    $branchInfos += $branchInfo

    if(!$isReleaseBranch){
        $trunkInfo = $branchInfo
    }
}

$workspace = Get-TfsWorkspace "$"

#Promote in order of higher branches to lower branches
$branchInfos = $branchInfos | Sort-Object -Property BranchNumber -Descending

SendEmail -emailBody "Please do not check-in code to the release area until further notice." -emailSubject "Source Code Promotion Started"

[int]$branchesCompleted = 0

function UpdateProgress() 
{    
    Write-Progress -activity "Promoting/Merging code" -status "$branchesCompleted/$($branchInfos.Length) Completed" `
                   -PercentComplete (($branchesCompleted / $branchInfos.Length)  * 100)    
}

DisplayWaitTimeProgressBar -secondsToPause $secondsToPause -activityMessage "Starting code promotion/merge"
UpdateProgress

[bool]$isVersionIncremented = $true
$tfsModifiedIdentities = @()
[string]$trunkServerPath = $DevConfigData.ReleaseBranchesServerDirPath + "/" + $DevConfigData.TrunkName
try
{

    #Lock trunk during promotion

    $tfsPermissions = GetTfsPermission -instanceServerPath $trunkServerPath

    foreach($tfspermissionIdentity in $tfsPermissions.Identities)
    {
        if($tfspermissionIdentity.Allow.Contains("Checkin") -or $tfspermissionIdentity.InheritedAllow.Contains("Checkin"))
        {
            tf permission /deny:Checkin /group:$($tfspermissionIdentity.Identity) $trunkServerPath | Out-Null

            $tfsModifiedIdentities += $tfspermissionIdentity
        }
    }
    
    Write-Host "Check-in is locked for $trunkServerPath"
    Write-Host

    foreach($branchInfo in $branchInfos)
    {
        [int]$targetBranchNumber = $branchInfo.BranchNumber + 1
        [string]$targetBranchServerPath = $DevConfigData.ReleaseBranchesServerDirPath + "/" + ($DevConfigData.ReleaseBranchNameFormat -f ("{0:D2}" -f $targetBranchNumber))

        if($targetBranchNumber -gt $DevConfigData.MaxReleaseBranches)
        {
            Write-Host "Skipping promotion/merge of $($branchInfo.ServerPath) into $targetBranchServerPath (max release branches is $($DevConfigData.MaxReleaseBranches))"
        }
        else
        {
            Write-Host "Promoting/merging $($branchInfo.ServerPath) into $targetBranchServerPath" 
            Write-Host "------------------------------------------------------------------------"
    
            ..\Dev\AppInstance_Update.ps1 -appInstanceServerPath $branchInfo.ServerPath
            Write-Host       

            if($releaseBranchServerPaths -notcontains $targetBranchServerPath)
            {     
                Write-Host "$($targetBranchServerPath): does not exist" 
                Write-Host

                ..\Dev\Ref\Branch_Create.ps1 -sourceServerPath $branchInfo.ServerPath -serverPathForNewBranch $targetBranchServerPath

                Write-Host
            }
            else
            {       
                ..\Dev\AppInstance_Update.ps1 -appInstanceServerPath $targetBranchServerPath
                Write-Host

                #intentionally not using Cmd_ExecuteCommand in order to avoid dialogs
                tf merge "$($branchInfo.ServerPath)" "$targetBranchServerPath" /recursive /format:detailed
                tf resolve "$targetBranchServerPath" /recursive /auto:TakeTheirs      
            }

            Write-Host "$($targetBranchServerPath): checking in promotion/merge" 

            ..\Dev\Checkin.ps1 -workItemNumbers @($workItemNumber) -checkinServerPath $targetBranchServerPath -comment "Promoted $($branchInfo.ServerPath) to $($targetBranchServerPath)." -displayPendingChanges $false -skipCodeReview $true -skipConfirmations $true  | Out-Null

            Write-Host "$($targetBranchServerPath): promotion/merge checked-in" 
            Write-Host

            #region Reconfigure
            ..\Dev\Ref\AppInstance_Reconfigure.ps1 -sourceInstanceServerPath $branchInfo.ServerPath -targetInstanceServerPath $targetBranchServerPath
            #endregion

            ..\Dev\Checkin.ps1 -workItemNumbers @($workItemNumber) -checkinServerPath $targetBranchServerPath -comment "Reconfigured $($targetBranchServerPath)." -displayPendingChanges $false -skipCodeReview $true -skipConfirmations $true  | Out-Null

            Write-Host "$($targetBranchServerPath): reconfigure checked-in" 
            Write-Host

            #region DB Update        
            ..\Dev\Ref\AppInstance_ExecuteUpdateScripts.ps1 -databaseNames $DevConfigData.TrunkDatabaseNames -appInstanceServerPath $targetBranchServerPath 
            #endregion

            Write-Host "Promoted/merged $($branchInfo.ServerPath) into $targetBranchServerPath" 
        }

        $Script:branchesCompleted++;
        Write-Host
        Write-Host
    
        UpdateProgress
    }

    Write-Host "Starting version number increment in trunk"
    Write-Host

    #region Increment version number
    [hashtable]$fileAndVersionRegexes = $DevConfigData.FileAndVersionRegexes

    foreach($fileNameKey in $fileAndVersionRegexes.Keys)
    {   
        [string]$fileLocalPath = $workspace.GetLocalItemForServerItem($trunkInfo.ServerPath +  "/" + $fileNameKey)     
        [string[]]$fileContents = Get-Content -LiteralPath $fileLocalPath

        [string[]]$versionNumberRegexes = $fileAndVersionRegexes[$fileNameKey]

        foreach($versionNumberRegex in $versionNumberRegexes)
        {
            for([int]$i=0; $i -lt $fileContents.Length; $i++)
            {
                $match = [regex]::Match($fileContents[$i], $versionNumberRegex)
                [string]$matchGroupName = $SharedConfigData.IncrementVersionNumberGroupName

                if($match.Success)
                {
                    [int]$incrementNumber = 0

                    if(![int]::TryParse($match.Groups[$matchGroupName].Value, [ref]$incrementNumber))
                    {
                        $isVersionIncremented = $false

                        Write-Host "Version number regex returned a non-integer value of `"$($match.Groups[0].Value)`". Please correct the regex: $versionNumberRegex for file: $fileNameKey" -ForegroundColor Red
                        Write-Host

                        continue
                    }
                
                    $incrementNumber += 1
                    [string]$incrementNumberText = $incrementNumber

                    $fileContents[$i] = $fileContents[$i].Insert($match.Groups[$matchGroupName].Index, $incrementNumber)
                    $fileContents[$i] = $fileContents[$i].Remove($match.Groups[$matchGroupName].Index + $incrementNumberText.Length, $match.Groups[$matchGroupName].Length)                
                }
            }
        
            tf checkout $fileLocalPath | Out-Null
            Set-Content $fileLocalPath $fileContents
        }
    }

	Write-Host

    if($isVersionIncremented){

        #region unlock trunk
        foreach($tfsModifiedIdentity in $tfsModifiedIdentities)
        {
            tf permission /Allow:Checkin /group:$($tfsModifiedIdentity.Identity) $trunkServerPath | Out-Null
        }

        ..\Dev\Checkin.ps1 -workItemNumbers @($workItemNumber) -checkinServerPath $trunknfo.ServerPath -comment "Incremented version number for $($trunknfo.ServerPath)" -displayPendingChanges $false -skipCodeReview $true -skipConfirmations $true  | Out-Null
    
        Write-Host
        Write-Host "Version number increment in trunk complete"

        SendEmail -emailBody "Code check-in may now resume." -emailSubject "Source Code Promotion Completed"
    }
    else{
        throw "Due to issue in regular expression (see above). Cannot proceed with version number increment check-in"
    }
    #endregion 
}
catch
{
    throw
}
finally
{
    #region unlock trunk
    foreach($tfsModifiedIdentity in $tfsModifiedIdentities)
    {
        tf permission /Allow:Checkin /group:$($tfsModifiedIdentity.Identity) $trunkServerPath | Out-Null
    }

    Write-Host "Check-in is unlocked for $trunkServerPath"
    Write-Host
}