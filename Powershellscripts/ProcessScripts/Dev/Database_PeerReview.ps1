param
(
    [string]$branchServerPath = $null,

    [string]$codeReviewerName = $null,

    [bool]$displayPendingDbChanges = $true
)

. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Dev\Ref\WorkItem_Management.ps1
. ..\Shared\Ref\Function_Misc.ps1

[Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.WorkItemTracking.Client") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.VersionControl.Client")  | Out-Null

if ([string]::IsNullOrWhiteSpace($branchServerPath))
{
    $branchServerPath =  ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Dev -branchState $BranchStateEnum.Existing 
    Write-Host
}

[int]$workItemNumber = GetWorkItemNumberFromBranchName -branchName (Split-Path $branchServerPath -Leaf)

$workspace = Get-TfsWorkspace "$" 

$pendingDbChanges = $workspace.GetPendingChanges() | Where-Object {$_.ServerItem -like "$branchServerPath/*.sql"} 

if($pendingDbChanges -eq $null -or $pendingDBChanges.Count -le 0)
{
    return
}

$codeReviewerDetails = GetUserDetails -userName $codeReviewerName -promptMessage "Enter the database code reviewer user name" -allowCurrentUser $false
$codeReviewerEmail = $codeReviewerDetails.Email
Write-Host

$developerDetails = GetUserDetails -userName $env:USERNAME 
$developerDisplayName = $developerDetails.DisplayName
$developerCommonName = $developerDetails.FullName
$developerEmail = $developerDetails.Email

$codeReviewPassed =  PromptForYesNoValue -displayMessage "Did the database code review for $(Split-Path $branchServerPath -Leaf) pass?"
$reviewPassed = $codeReviewPassed -eq "Y"
Write-Host

[bool]$reviewPassed = $false
[bool]$perfTuningIssues = $false

if($reviewPassed -eq $true)
{
    [string]$codePerfTuningIssues = PromptForYesNoValue -displayMessage "Were there minor performance/tuning issues in $(Split-Path $branchServerPath -Leaf)?"
    $perfTuningIssues = $codePerfTuningIssues -eq "Y"
    Write-Host
}

[string]$scriptWrapupText = $null

if($reviewPassed -eq $true){
    $scriptWrapupText = "The following scripts have passed code review:"
}
else{
    $scriptWrapupText = "The following scripts have failed code review:"
}

[string]$emailSubject = "Database Code Review Complete"
[string]$emailBody = $null

if($perfTuningIssues -eq $true)
{
    [string]$newWorkItemTitle = Read-Host "What TFS title will you assign to the task created to handle the performance/tuning issue?"
    [string]$newWorkItemDescription = Read-Host "What is the TFS description for $newWorkItemTitle`?"
    [string]$workItemVerification = $null
    Write-Host

    try
    {
        $newWorkItem = CreateChildWorkItem -parentWorkItemNumber $workItemNumber -newItemAssignedTo $developerDisplayName -newItemTitle $newWorkItemTitle -newItemDescription $newWorkItemDescription
        $workItemVerification = "Work Item $($newWorkItem.Id): `"$newWorkItemTitle`" has been successfully created."
    }
    catch
    {
        $workItemVerification = $Error[0].Message
    }

    $emailBody = "$workItemVerification <br><br>"
    
    Write-Host
    Write-Host $workItemVerification
    Write-Host
}

foreach($pendingDbChange in $pendingDbChanges)
{
    $scriptWrapupText = "$scriptWrapupText `n`r $(Split-Path $pendingDbChange.ServerItem -Leaf)"
}   

if($displayPendingDbChanges = $true)
{
    Write-Host $scriptWrapupText
}

$emailBody = "<font face=`"verdana`">$($emailBody)You have successfully reviewed database code for $developerCommonName. <br><br>$($scriptWrapupText.Replace("`n`r", "<br>"))</font>"

. ..\Shared\Email_Send.ps1 -emailToAddrs $codeReviewerEmail -emailCcs $developerEmail -emailSubject $emailSubject -emailBody $emailBody -isBodyHtml $true

Write-Host
Write-Host "An email has been sent to the database code reviewer."
