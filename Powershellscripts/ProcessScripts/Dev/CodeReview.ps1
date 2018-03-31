param
(
    [Parameter(Mandatory = $true)]
    [string]$appInstanceServerPath,

    [Nullable[int]]$workItemNumber = $null
)

. ..\Shared\Ref\Function_Misc.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Dev\Ref\WorkItem_Management.ps1

if (!("PeerReviewApprover" -as [type])) 
{
Add-Type -Language CSharp @"
public class PeerReviewApprover
{
    public string CodeReviewerFormattedName;
    public string CodeReviewerEmail;
    public string DbReviewerFormattedName;
    public string DbReviewerEmail;
}
"@;
}

[PeerReviewApprover]$peerReviewApprover = New-Object -TypeName PeerReviewApprover

$workspace = Get-TfsWorkspace "$" 

[bool]$codeChangesExist = $false
[bool]$dbChangesExist = $false

$pendingChanges = $workspace.GetPendingChanges($appInstanceServerPath, [Microsoft.TeamFoundation.VersionControl.Client.RecursionType]::Full)

foreach($pendingChange in $pendingChanges)
{
    if($pendingChange -imatch "\w*\.sql")
    {
        $dbChangesExist = $true
    }
    else
    {
        $codeChangesExist = $true
    }
}

#region developer/reviewer
$developerDetails = GetUserDetails -userName $env:USERNAME 
$developerDisplayName = $developerDetails.DisplayName
$developerCommonName = $developerDetails.FullName
$developerEmail = $developerDetails.Email
#endregion

#region code peer review
if($codeChangesExist)
{   
    $pendingCodeChanges = $pendingChanges | Where-Object{$_.ServerItem -inotmatch "\w*\.sql"}

    Write-Host
    Write-Host "The following code scripts are being reviewed:"

    foreach($pendingCodeChange in $pendingCodeChanges)
    {
        Write-Host $pendingCodeChange.ServerItem
    }
    
    Write-Host                                                                                                                                             
    $codePeerReviewerDetails = GetUserDetails -userName $null -promptMessage "Enter the code reviewer user name" -allowCurrentUser $false
    $codePeerReviewerEmail = $codePeerReviewerDetails.Email
    $codePeerReviewerFormattedName = $codePeerReviewerDetails.FormattedName
    
    [bool]$codeReviewPassed = $false

    Write-Host
    $codePeerReviewPassed =  PromptForYesNoValue -displayMessage "Did the code peer review for $(Split-Path $appInstanceServerPath -Leaf) pass?"

    if($codePeerReviewPassed -ieq "Y")
    {
        $peerReviewApprover.CodeReviewerFormattedName = $codePeerReviewerDetails.FormattedName
        $peerReviewApprover.CodeReviewerEmail = $codePeerReviewerDetails.Email
    }
    else
    {
        $peerReviewApprover = $null

        $shelfsetTitle = "$(Split-Path $appInstanceServerPath -Leaf) - failed code review [reference only]"
        $shelfsetDetails = "Code review failed for $(Split-Path $appInstanceServerPath -Leaf)."

        ShelveAndUndoPendingChanges -appInstanceServerPath $appInstanceServerPath -shelvesetDetails $shelfsetDetails -shelvesetTitle $shelfsetTitle

        throw "Please fix the issues and try the process again."
    }
}
#endregion

#region db peer review
if($peerReviewApprover -ne $null -and $dbChangesExist)
{   
    $pendingDbChanges = $pendingChanges | Where-Object{$_.ServerItem -imatch "\w*\.sql"}

    Write-Host
    Write-Host "The following database scripts are being reviewed:"

    foreach($pendingDbChange in $pendingDbChanges)
    {
        Write-Host $pendingDbChange.FileName
    }
                       
    Write-Host                                                                                                                                                                                                                                      
    $dbPeerReviewerDetails = GetUserDetails -userName $codeReviewerName -promptMessage "Enter the database code reviewer user name" -allowCurrentUser $false
    $dbPeerReviewerFormattedName = $dbPeerReviewerDetails.FormattedName
    
    Write-Host
    $dbPeerReviewPassed =  PromptForYesNoValue -displayMessage "Did the database code review for $(Split-Path $appInstanceServerPath -Leaf) pass?"
    
    [string]$hasPerfTuningIssues = $null

    if($dbPeerReviewPassed -ieq "Y")
    {
        Write-Host
        $hasPerfTuningIssues = PromptForYesNoValue -displayMessage "Were there minor performance/tuning issues in $(Split-Path $appInstanceServerPath -Leaf)?"

        $peerReviewApprover.DbReviewerFormattedName = $dbPeerReviewerDetails.FormattedName
        $peerReviewApprover.DbReviewerEmail = $dbPeerReviewerDetails.Email
    }
    else
    {
        $peerReviewApprover = $null
                
        $shelfsetTitle = "$(Split-Path $appInstanceServerPath -Leaf) - failed database peer review [reference only]"
        $shelfsetDetails = "Database peer review failed for $(Split-Path $appInstanceServerPath -Leaf)."

        ShelveAndUndoPendingChanges -appInstanceServerPath $appInstanceServerPath -shelvesetDetails $shelfsetDetails -shelvesetTitle $shelfsetTitle

        throw "Please fix the issues and try the process again."
    }

    [string]$hostResultMessage = $null

    if($hasPerfTuningIssues -ieq "Y")
    {
        Write-Host
        Write-Host "Creating TFS work item to handle the performance/tuning issues"

        if($workItemNumber -eq $null -or $workItemNumber -eq 0)
        {
            $workItemNumber = ..\Dev\Ref\WorkItem_PromptForNumber.ps1
        }
        
        [string]$newWorkItemTitle = $null

        while([string]::IsNullOrWhiteSpace($newWorkItemTitle))
        {
            $newWorkItemTitle = Read-Host "Please provide the title"
        }

        [string]$newWorkItemDescription = Read-Host "Please provide the description"
        Write-Host

        try
        {
            $newWorkItem = CreateChildWorkItem -parentWorkItemNumber $workItemNumber -newItemAssignedTo $developerDisplayName -newItemTitle $newWorkItemTitle -newItemDescription $newWorkItemDescription
            $hostResultMessage = "Work Item $($newWorkItem.Id): `"$newWorkItemTitle`" has been successfully created."            
            Write-Host $hostResultMessage

#            ..\Shared\Email_Send.ps1 -emailToAddrs $dbPeerReviewerDetails.Email -emailCcs $developerDetails.Email -emailSubject $dbReviewEmailSubject -emailBody $hostResultMessage -isBodyHtml $true

        }
        catch
        {
            $hostResultMessage = $Error[0].Message            
            Write-Warning $hostResultMessage
        }
    }
}
#endregion

return $peerReviewApprover