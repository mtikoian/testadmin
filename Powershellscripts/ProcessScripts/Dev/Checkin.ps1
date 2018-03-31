param
(
    [string]$checkinServerPath ="$/",

    [int[]]$workItemNumbers = $null,

    [Nullable[bool]]$areWorkItemsResolved = $null,

    [string]$comment = $null,

    [string]$codeReviewerUserName = $null,

    [bool]$displayPendingChanges = $true,

    [bool]$skipWorkItem = $false,

    [bool]$skipCodeReview = $false,

    [bool]$skipConfirmations = $false
)

. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1

[Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.WorkItemTracking.Client") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.VersionControl.Client")  | Out-Null

$workspace = Get-TfsWorkspace $checkinServerPath

#Gets pending changes to check-in.
[Microsoft.TeamFoundation.VersionControl.Client.PendingChange[]]$pendingChanges = $workspace.GetPendingChanges($checkinServerPath,[Microsoft.TeamFoundation.VersionControl.Client.RecursionType]::Full)

[hashtable]$workItemDetails = @{}

if($pendingChanges.Length -le 0)
{
    Write-Warning "Skipping check-in, no pending changes detected."
    return
}

function DisplayPendingChanges()
{
    if($pendingChanges.Length -le $DevConfigData.MaxPendingChangesToDisplay)
    {
        Write-Host "Files ready for check-in:"  
        
        foreach($change in $pendingChanges)
        {
            write-host $change.LocalItem 
        }        
    }
    else
    {
        Write-Host "You are about to check-in $($pendingChanges.Length) files"         
    } 
}


if($displayPendingChanges)
{
    DisplayPendingChanges   
}

Write-Host

function PopulateWorkItemDetails
{
    [bool]$populationSucceeded = $false

    if($workItemNumbers.Length -le 0)
    {
        return $populationSucceeded
    }

    [string]$displayMessage = $null
    $script:workItemDetails = $null
       
    $script:workItemDetails = ..\Dev\Ref\WorkItem_GetDetails.ps1 $workItemNumbers -returnWorkItemObject $true
    
    $populationSucceeded =  $script:workItemDetails.Count -gt 0 -and $workItemNumbers.Length -eq $script:workItemDetails.Count

    return $populationSucceeded
}

[string] $reviewMessage = $null

if(!$skipWorkItem)
{
    while(!(PopulateWorkItemDetails))
    {   
        $workItemNumbers = @()
        $workItems = Read-Host "Enter work item number(s) (separate multiple by comma)"

        if(![string]::IsNullOrWhiteSpace($workItems.Replace(",",""))) 
        {    
            $workItemsSplit = $workItems.Split(",")          
           
            try
            {
                 foreach($item in $workItemsSplit)
                 {
                     if(![string]::IsNullOrWhiteSpace($item))
                     {                                    
                        $workItemNumbers += [int]::parse($item)                                    
                     }                           
                 }
            }
            catch
            {
                Write-Warning "Error occurred while casting one or more work item number(s) to integer."
            }
    
            Write-Host
        }     
    }

    foreach($workItemId in $workItemDetails.Keys)
    {
        [Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItem]$workItemInfo = $workItemDetails[$workItemId]
        Write-Host "Work item(s) attached to this check-in:"
        Write-Host "$($workItemInfo.Id): $($workItemInfo.Title) [Assigned To: $($workItemInfo.Fields["Assigned To"].Value)]"
        $reviewMessage = $reviewMessage + $workItemId +", "
    }
    Write-Host
    
    #Temporarily desabled as work items are not resolving properly.
    $areWorkItemsResolved = $false

    <#if($areWorkItemsResolved -eq $null)
    {
        [hashtable] $checkinActionAllowedValues = @{"&Association" = "A"; "&Resolution" = "R"}
        $checkInAction = ..\Shared\Ref\ReadHostWithAllowedValues.ps1 -message "What affect will check-in have on the work item(s)?" -allowedValues $checkinActionAllowedValues -defaultValue "A"
        $areWorkItemsResolved = $checkInAction -ieq "R"
        Write-Host
    }#>
}

#Sets checkin action type to associate.
[Microsoft.TeamFoundation.VersionControl.Client.WorkItemCheckinAction]$workItemCheckinAction =[Microsoft.TeamFoundation.VersionControl.Client.WorkItemCheckinAction]::Associate

if($areWorkItemsResolved)
{
    $workItemCheckinAction = [Microsoft.TeamFoundation.VersionControl.Client.WorkItemCheckinAction]::Resolve
}


if(!$skipWorkItem)
{
    $reviewMessage = "This check-in will $($workItemCheckinAction.ToString()) work item(s) " + $reviewMessage.TrimEnd(", ") +"."
}
else
{
    $reviewMessage = "Work item is not attached to this check-in."
}

if(!$skipConfirmations)
{
    [string]$workItemConfirmation = PromptForYesNoValue -displayMessage "$reviewMessage Do you wish to continue?"

    if($workItemConfirmation -ine "y")
    {
        throw "Resolve issues and try check-in process again"
    }

    Write-Host
}

while([string]::IsNullOrWhiteSpace($comment))
{
    $comment = Read-Host "Enter check-in comments"    
}

$comment = $comment.Trim()
Write-Host

if($skipWorkItem)
{
    $comment = $comment.TrimEnd(".") + ". [Developer chose not to associate a work item to this check-in]" 
}

$devBranchRegex = [regex]::Escape($DevConfigData.DevBranchesServerDirPath)

[string]$codeReviewer = $null
$codeReviewApprovers = $null

#Code reviewer's are not necessary when checking into development branches
if(!$skipCodeReview -and $checkinServerPath -inotmatch $devBranchRegex)
{
    $codeReviewApprovers = ..\Dev\CodeReview.ps1 -appInstanceServerPath $checkinServerPath

    if(![string]::IsNullOrWhiteSpace($codeReviewApprovers.CodeReviewerFormattedName))
    {
        $codeReviewer = $codeReviewApprovers.CodeReviewerFormattedName+", "
    }

    if(![string]::IsNullOrWhiteSpace($codeReviewApprovers.DbReviewerFormattedName) -and $codeReviewApprovers.DbReviewerFormattedName -ine $codeReviewApprovers.CodeReviewerFormattedName)
    {
        $codeReviewer += $($codeReviewApprovers.DbReviewerFormattedName)
    }

    $codeReviewer = $codeReviewer.TrimEnd(", ")
}

[Microsoft.TeamFoundation.VersionControl.Client.CheckinNote] $checkinNote = $null

if(![string]::IsNullOrWhiteSpace($codeReviewer))
{
    #Preparing check in notes to include code reviewer.
    $checkinNoteFieldValue = New-Object -TypeName Microsoft.TeamFoundation.VersionControl.Client.CheckinNoteFieldValue  "Code Reviewer", $codeReviewer
    $checkinNoteFieldValues =  [Array]::CreateInstance($checkinNoteFieldValue.GetType(), 1)
    $checkinNoteFieldValues[0] = $checkinNoteFieldValue
    $checkinNote = New-Object -TypeName Microsoft.TeamFoundation.VersionControl.Client.CheckinNote $checkinNoteFieldValues
}

#Prepares work item array to associate with changeset.
[Microsoft.TeamFoundation.VersionControl.Client.WorkItemCheckinInfo[]]$workItemCheckinInfos = $null

foreach($workItemId in $workItemDetails.Keys)
{   
    $workItemCheckinInfos += New-Object -TypeName  Microsoft.TeamFoundation.VersionControl.Client.WorkItemCheckinInfo $workItemDetails[$workItemId], $workItemCheckinAction
}

#Code to check-in pending changes

Write-Host "******************************** CHECK-IN DETAILS ********************************" -ForegroundColor Green
Write-Host

DisplayPendingChanges
Write-Host

Write-Host "Work item Details:" 

if($workItemDetails.Count -gt 0)
{
    foreach($workItemInfo in $workItemDetails.Values)
    {
        Write-Host "$($workItemInfo.Id): $($workItemInfo.Title) [Assigned To: $($workItemInfo.Fields["Assigned To"].Value)]"
    }
}
else
{
    Write-Host "No work items attached" -ForegroundColor Red
}

Write-Host

Write-Host "Code reviewer(s): " -NoNewline

if(![string]::IsNullOrWhiteSpace($codeReviewer))
{
    Write-Host $codeReviewer
}
else
{
    Write-Host "None" -ForegroundColor Red
}

Write-Host

Write-Host "Check-in comments: $comment"
Write-Host

if(!$skipConfirmations)
{
    [string]$checkinConfirmation = PromptForYesNoValue -displayMessage "Review the above check-in details. Do you wish to check-in?" 
    Write-Host

    if($checkinConfirmation -ine "y")
    {
        Write-Warning "Check-in aborted by user"
        return
    }
}

Write-Host

[int]$changesetNumber = $workspace.CheckIn($pendingChanges, $comment, $checkinNote, $workItemCheckinInfos, $null)

if($changesetNumber -le 0)
{
    throw "Possible error situation during check-in. Returned changeset number: $changeSetNumber"
}
else
{
    Write-Host "Check-in successful with changeset #: " $changesetNumber
    Write-Host
}

$changesetDetail = Get-TfsChangeset $changesetNumber

[string]$workItemsNotAssociated = $null

foreach($workItem in $workItemNumbers)
{
    $changesetWorkItems = $($changesetDetail.WorkItems.Id -join ", ")
    $regEx = [regex]::Escape($workItem)

    if($changesetWorkItems -inotmatch $regEx)
    {
        $workItemsNotAssociated = $workItemsNotAssociated + $workItem + ", "
    }        
}

if(![string]::IsNullOrWhiteSpace($workItemsNotAssociated))
{
    Write-Warning "Work item number(s) $($workItemsNotAssociated.TrimEnd(", ")) is/are not associated to changeset ($changesetNumber) during check-in. Associate these manually."
}

if(![string]::IsNullOrEmpty($codeReviewer))
{
    [string[]]$emailToAddr = @()

    if(![string]::IsNullOrWhiteSpace($codeReviewApprovers.CodeReviewerEmail))
    {
        $emailToAddr += $codeReviewApprovers.CodeReviewerEmail
    }

    if(![string]::IsNullOrWhiteSpace($codeReviewApprovers.DbReviewerEmail) -and $codeReviewApprovers.DbReviewerEmail -ine $codeReviewApprovers.CodeReviewerEmail)
    {
        $emailToAddr += $codeReviewApprovers.DbReviewerEmail
    }
     
    $developerDetails = GetUserDetails -userName $env:USERNAME -promptMessage "Enter user name"
    [string]$emailSubject = "Code Review Acknowledgement for $($developerDetails.FullName)'s code"
    [string]$emailBody = "Changeset $changesetNumber was checked in by $($developerDetails.FullName). $codeReviewer was listed as the code reviewer for this changeset."

    ..\Shared\Email_Send.ps1 -emailToAddrs $emailToAddr -emailCcs $developerDetails.Email -emailSubject $emailSubject -emailBody $emailBody

    Write-Host "Changeset $changesetNumber check-in confirmation email sent to code reviewer."
}

return $changesetNumber