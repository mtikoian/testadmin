. ..\Dev\Ref\DevConfigData.ps1

#Executes the command in a separate process. This will ensure prompts in case of conflits.
function Cmd_ExecuteCommand([string]$command)
{
    if(![string]::IsNullOrWhiteSpace($command))
    {
        Start-Process cmd -ArgumentList "/C $command" -NoNewWindow -Wait
    }
}

function GetWorkItemNumberFromBranchName([string]$branchName)
{
    $matchResult = [regex]::Match($branchName, $DevConfigData.BranchNameWorkItemFormat -f  "(?<WorkItemNumber>\d+)")

    return  $matchResult.Groups["WorkItemNumber"].Value
}

function AssertNoPendingChanges([Parameter(Mandatory = $true)][string]$serverPath)
{
    [object[]]$pendingChanges = Get-TfsPendingChange $serverPath -recurse

    if($pendingChanges -ne $null)
    {
        throw "Pending changes exist in $serverPath. Please check-in or undo pending changes."
    }    
}

function GetFilesFromChangesetId([Parameter(Mandatory = $true)][int]$changesetId)
{
    $changeset = Get-TfsChangeset -ChangesetNumber $changesetId

    [string[]]$fileServerPaths = $null

    if($changeset -ne $null)
    {
        $fileServerPaths = $changeset.changes | ForEach-Object{$_.Item.ServerItem}
    }
    return $fileServerPaths
}

function GetFileServerPathsFromPendingChanges([Parameter(Mandatory = $true)][string]$serverPath)
{
    [object[]]$pendingChanges = Get-TfsPendingChange $serverPath -recurse

    [string[]]$fileServerPaths = $null
    
    if($pendingChanges -ne $null)
    {
         $fileServerPaths = $pendingChanges | Select-Object -ExpandProperty ServerItem
    }
    return $fileServerPaths
}

function DeleteToRecycleBin([Parameter(Mandatory = $true)][string[]]$filePaths)
{
    $shell = new-object -comobject "Shell.Application"

    Write-Host "Deleted to recycle bin:"

    foreach($path in $filePaths)
    {
        $shellItem = $shell.Namespace(0).ParseName($path)
        $shellItem.InvokeVerb("delete")  
        
        Write-Host $path 
    }
}

function BuildSolutionOrProject
{
    param(
        [Parameter(Mandatory=$true)][string]$solutionOrProjectFilePath,
        [Parameter(Mandatory=$true)][string]$buildConfiguration,
        [string]$buildPlatform = $null,
        [string]$logFilePath = $null
    )

    if(!(Test-Path -LiteralPath $solutionOrProjectFilePath))
    {
        throw "Could not locate file: $solutionOrProjectFilePath"
    }

    if(![string]::IsNullOrWhiteSpace($buildPlatform))
    {
        $buildConfiguration += "|$buildPlatform"
    }

    if([string]::IsNullOrWhiteSpace($logFilePath))
    {
        $logFilePath = $solutionOrProjectFilePath + ".BuildLog.txt"    
    }
    
    $fileInfo = Get-Item $solutionOrProjectFilePath
       
    Write-Host "Build Starting: $($fileInfo.Name)"

    if(Test-Path $logFilePath){
        Remove-Item $logFilePath
    }

    [string[]]$argumentList = @("`"$solutionOrProjectFilePath`"", "/build $buildConfiguration","/Safemode", "/Out `"$logFilePath`"")        
    
    Write-Host "Please wait..."
    Write-Host
    
    $buildProcess = Start-Process -FilePath $DevConfigData.VsCurrentVersionExePath -ArgumentList $argumentList -Verb "runas" -PassThru

    $buildProcess.WaitForExit()

    if($buildProcess.ExitCode -eq 0)
    {
        Write-Host "Build Successful: $($fileInfo.Name)"
        Write-Host
    }
    else
    {
        if(![string]::IsNullOrWhiteSpace($logFilePath))
        {
            Invoke-Expression $logFilePath
        }

        throw "Build Failure (please open Visual Studio for more details): $($fileInfo.Name)"
    }
}

function GetTfsPermission([Parameter(Mandatory=$true)][string]$instanceServerPath)
{          
    # Look at each line of TF PERMISSION output and use a regex to determine 
    # what the data for the line is.
    switch -regex (tf permission $instanceServerPath)
    {
        '^Server item:\s+(\S+)\s+\(Inherit:\s+(\w+)\)'
        { 
            $item = [PSCustomObject] @{
                ServerItem = $matches[1]
                Inherits   = $matches[2] -eq 'yes'
                Identities = @()
            }
            $item.psobject.TypeNames[0] = "TfsTools.VersionControl.ItemPermissions"
        }
                
        '\bIdentity:\s+(.*)$'
        {
            $identityName = $matches[1] 
            $currentIdentity = [PSCustomObject] @{
                Identity = $identityName
                Allow = ''
                Deny ='' 
                InheritedAllow = ''
                InheritedDeny = ''
            }
            $item.Identities += $currentIdentity
        }
                
        '\bAllow:\s*(.*)$'
        { 
            $currentIdentity.Allow = $matches[1]
        }
                
        '\bDeny:\s*(.*)$'
        { 
            $currentIdentity.Deny = $matches[1]
        }
                
        '\bAllow\s+\(Inherited\)\s*:\s*(.*)$'
        { 
            $currentIdentity.InheritedAllow = $matches[1]
        }
                
        '\bDeny\s+\(Inherited\)\s*:\s*(.*)$'
        { 
            $currentIdentity.InheritedDeny = $matches[1]
        }    
    }      

    return $item
}

function ShelveAndUndoPendingChanges([string]$appInstanceServerPath, [string] $shelvesetDetails, [string]$shelvesetTitle)
{
    $workspace = Get-TfsWorkspace "$"
    
    $appInstanceLocalPath = $workspace.GetLocalItemForServerItem($appInstanceServerPath)

    Write-Host
    Write-Host "Shelving pending changes ..."
    tf shelve $shelvesetTitle "$appInstanceLocalPath\*.*" /recursive /replace /comment:"Shelving pending changes - $shelvesetDetails" | Out-Null
    Write-Host "Pending changes shelved. Shelveset name: $shelvesetTitle"
    Write-Host
    Write-Warning "Do not unshelve this shelveset in trunk. Return to branch to make corrections."

    Write-Host
    Write-Host "Rolling back changes ..."
    tf undo $appInstanceServerPath /recursive | Out-Null
    Write-Host "Changes rolled back."
}