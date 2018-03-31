param
(
    [string]$branchServerPath =  $null
)

#region References.
. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Shared\Ref\Function_Misc.ps1
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
#end region

if([string]::IsNullOrWhiteSpace($branchServerPath))
{
    $branchServerPath = ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Any -returnFullServerPath $true -branchState $BranchStateEnum.Existing
    Write-Host
} 

[string]$continue = PromptForYesNoValue -displayMessage "Are you sure that you want to delete `"$branchServerPath`"?" -isYesDefaultValue $true

if ($continue -ine "Y")
{
    Write-Warning "Deletion Aborted."
    return
}

#Get the root folder (NOT RECURSIVE) in case the branch is not locally present.
tf get $branchServerPath 

Write-Host
Write-Host "Deleting branch."
Write-Host "Please wait ....."
tf delete /lock:checkout $branchServerPath | Out-Null
Write-Host "Branch deleted."
Write-Host

Write-Host "Checking in branch deletion."
.\Checkin.ps1 -checkinServerPath $branchServerPath -comment "Post branch-deletion checkin" -skipWorkItem $true -skipConfirmations $true | Out-Null
Write-Host "Checkin complete."
Write-Host

[string]$instanceName = $DevConfigData.DevSqlServerName + "\" + $DevConfigData.DevSqlServerInstanceName
[Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $instanceName

[string]$branchName = Split-Path $branchServerPath -Leaf
[string[]]$databasesToDelete = @()

foreach ($trunkDBName in $DevConfigData.TrunkDatabaseNames){
    $databasesToDelete += $branchName + "_$trunkDBName"
}

[string[]]$smoDbNames = $null
foreach($database in $smoServer.Databases){
    $smoDbNames += $database.Name
}

foreach ($dbName in $databasesToDelete)
{
    if($smoDbNames -ccontains $dbName)
    {
        try {
            $smoServer.databases[$dbName].Drop()
        }
        catch{
            Write-Warning "Dropping $dbName could not be accomplished. $($_.Exception.GetBaseException().Message)"
        }
        Write-Host "$dbName has been dropped."
    }
    else {
        Write-Host "$dbName does not exist on the server($instanceName)."
    }
}