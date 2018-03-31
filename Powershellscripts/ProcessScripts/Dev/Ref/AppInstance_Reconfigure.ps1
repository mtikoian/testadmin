param
(
    [Parameter(Mandatory=$true)]
    [string] $sourceInstanceServerPath,

    [Parameter(Mandatory=$true)]
    [string] $targetInstanceServerPath,

    [Parameter(Mandatory=$false)]
    [string[]] $fileServerPaths=$null
)

. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1

#Key = Original Text, Value = Replacement Text
[hashtable]$reconfigureMappings = @{}

$keyValueTypeEnum = [PsCustomObject] @{
	Database=1;
    FilePath=2;
    Url=3;
}

[string[]]$dbNames = @()

function BuildMapping([string] $sourceText, [string]$targetText, [string]$keyValueType){

    [string]$key =$null

    if($sourceText -ne $targetText -and ![string]::IsNullOrWhiteSpace($sourceText))
    {
        $key = [Regex]::Escape($sourceText)
    
        [string] $regExKey = $null

        if($keyValueType -ieq $keyValueTypeEnum.Database)
        {
            $Script:dbNames += $key

            foreach($sepratorPair  in $DevConfigData.DbNameReconfigSeprator)
            {
                $startingSeparator = ([regex]::Escape($sepratorPair[0]))
                $endingSeparator = ([regex]::Escape($sepratorPair[1]))
                $regExKeyTemp = "(?<=[$startingSeparator])" + $key + "(?=[$endingSeparator])"
                $regExKey += $regExKeyTemp + "|"
            }
        }
        elseif($keyValueType -eq $keyValueTypeEnum.Url)
        {
            $regExKey = $key
        }
        elseif($keyValueType -eq $keyValueTypeEnum.FilePath)
        {
            foreach($sepratorPair in $DevConfigData.FilePathReconfigSeprator)
            {
                $startingSeparator = [regex]::Escape($sepratorPair[0])
                $endingSeparator = [regex]::Escape($sepratorPair[1])
                $regExKeyTemp = "(?<=[$startingSeparator])" + $key + "(?=.*?$endingSeparator)"
                $regExKey += $regExKeyTemp + "|"
            }
        }
        else
        {
            $regExKey = $key
        }

        $regExKey = $regExKey.TrimEnd("|")#removing extra | at the end

        #Add key and value to the reconfigure mapping hashtable
        if(!$reconfigureMappings.ContainsKey($regExKey))
        {
            $reconfigureMappings.Add($regExKey, $targetText)
        }
    }
}

$workspace = Get-TfsWorkspace "$"

[string]$sourceBranchName = split-path $sourceInstanceServerPath -Leaf
[string]$sourceInstanceLocalPathOneBackslash = @($workspace.GetLocalItemForServerItem($sourceInstanceServerPath))
[string]$sourceInstanceLocalPathTwoBackslash = $sourceInstanceLocalPathOneBackslash.Replace("\", "\\")

[string]$targetInstanceLocalPathOneBackslash = @($workspace.GetLocalItemForServerItem($targetInstanceServerPath))
[string]$targetInstanceLocalPathTwoBackslash = $targetInstanceLocalPathOneBackslash.Replace("\", "\\")

BuildMapping -sourceText $sourceInstanceLocalPathOneBackslash -targetText $targetInstanceLocalPathOneBackslash -keyValueType $keyValueTypeEnum.FilePath
BuildMapping -sourceText $sourceInstanceLocalPathTwoBackslash -targetText $targetInstanceLocalPathTwoBackslash -keyValueType $keyValueTypeEnum.FilePath

function GetDbName([string]$trunkDbName, [string]$instanceServerPath)
{
    [string]$instanceBranchName = Split-Path $instanceServerPath -Leaf

    if($instanceBranchName -imatch $DevConfigData.BranchNameWorkItemFormat)
    {
        return ($instanceBranchName + "_" + $trunkDbName) 
    }
    else
    {
        return $trunkDbName
    }
}

foreach($databaseName in $($DevConfigData.TrunkDatabaseNames)){

    $sourceDbName = GetDbName -trunkDbName $databaseName -instanceServerPath $sourceInstanceServerPath
    $targetDbName = GetDbName -trunkDbName $databaseName -instanceServerPath $targetInstanceServerPath

    BuildMapping -sourceText $sourceDbName -targetText $targetDbName -keyValueType $keyValueTypeEnum.Database
}

$targetBranchName = split-path $targetInstanceLocalPathOneBackslash -Leaf

#Mapping for Url should be done only during development branch

if($targetBranchName -imatch $DevConfigData.BranchNameWorkItemFormat -or $sourceBranchName -imatch $DevConfigData.BranchNameWorkItemFormat)
{
    [string]$workItemNumber = $null
    
    if($targetBranchName -imatch $DevConfigData.BranchNameWorkItemFormat)
    {
        $workItemNumber = GetWorkItemNumberFromBranchName -branchName $targetBranchName
        BuildMapping -sourceText $DevConfigData.ReconfigUrlReplaceText -targetText "localhost/$($DevConfigData.WebsiteNameFormat -f $workItemNumber)" -keyValueType $keyValueTypeEnum.Url
    }
    else
    {
        $workItemNumber = GetWorkItemNumberFromBranchName -branchName $sourceBranchName
        BuildMapping -sourceText "localhost/$($DevConfigData.WebsiteNameFormat -f $workItemNumber)" -targetText $DevConfigData.ReconfigUrlReplaceText -keyValueType $keyValueTypeEnum.Url
    }
}

if(($sourceBranchName -imatch $DevConfigData.ReleaseBranchNameFormat) -or ($targetBranchName -imatch $DevConfigData.ReleaseBranchNameFormat))
{
    [int]$sourceBranchNumber = 0

    if($sourceBranchName -imatch ($DevConfigData.ReleaseBranchNameFormat -f "(?<branchNumber>\d+)")){
        $sourceBranchNumber = [int]$Matches["branchNumber"]
    }

    [int]$targetBranchNumber = 0

    if($targetBranchName -imatch ($DevConfigData.ReleaseBranchNameFormat -f "(?<branchNumber>\d+)")){
        $targetBranchNumber = [int]$Matches["branchNumber"]
    }

    if($sourceBranchNumber -eq 0)
    {
        BuildMapping  -sourceText ($DevConfigData.DevSqlServerName + "/" + ($DevConfigData.DevSqlServerInstanceName)) `
                    -targetText ($DevConfigData.DevSqlServerName + "/" + ($DevConfigData.ReleaseBranchSqlServerInstanceNameFormat -f $targetBranchNumber))  
                    
    }
    elseif(($targetBranchNumber -gt $sourceBranchNumber) -or ($targetBranchNumber -ne 0 -and $targetBranchNumber -lt $sourceBranchNumber))
    {
        BuildMapping -sourceText ($DevConfigData.DevSqlServerName + "/" + ($DevConfigData.ReleaseBranchSqlServerInstanceNameFormat -f $sourceBranchNumber)) `
                 -targetText ($DevConfigData.DevSqlServerName + "/" + ($DevConfigData.ReleaseBranchSqlServerInstanceNameFormat -f $targetBranchNumber)) 
                    
    }
    else
    {
        BuildMapping -sourceText ($DevConfigData.DevSqlServerName + "/" + ($DevConfigData.ReleaseBranchSqlServerInstanceNameFormat -f $targetBranchNumber)) `
                    -targetText ($DevConfigData.DevSqlServerName + "/" + ($DevConfigData.DevSqlServerInstanceName)) 
    }
}

[string[]]$instanceFilePaths = $null

if($fileServerPaths -ne $null){
    $instanceFilePaths = $fileServerPaths | ForEach-Object{Get-TfsItemProperty $_} | where {$_.DeletionId -eq 0} | Select-Object -ExpandProperty LocalItem
    $instanceFilePaths = Get-Item -LiteralPath $instanceFilePaths |where {$_.Mode -inotmatch "d"} |Select-Object -ExpandProperty FullName
}

if($instanceFilePaths -eq $null){
    $instanceFilePaths = Get-ChildItem $targetInstanceLocalPathOneBackslash -Recurse -Include $DevConfigData.ReconfigFileNameRegexs | Select-Object -ExpandProperty FullName
}

Write-Host

[bool]$areFilesReconfigured = $false
[string[]]$allTfsSqlScripts = Get-ChildItem  $workspace.GetLocalItemForServerItem("$targetInstanceServerPath/$($DevConfigData.DbDeployRelativeDirPathSuffix)") -Name -Filter *.sql


foreach($instanceFilePath in $instanceFilePaths)
{
    if(Test-Path -LiteralPath $instanceFilePath)
    {
        $fileContent = Get-Content -LiteralPath $instanceFilePath -Force

        if($fileContent -ne $null)
        {
            $reconfiguredFileContent = ..\Dev\Ref\FindAndReplace.ps1 -fileContent $fileContent -mappingKeyValuePair $reconfigureMappings

            $difference = Compare-Object -ReferenceObject $reconfiguredFileContent -DifferenceObject $fileContent

            if($difference -ne $null)
            {
                $tfsDetails = Get-TfsItemProperty -Item $instanceFilePath

                if($tfsDetails.ChangeType -ieq "None")
                {
                    tf checkout $instanceFilePath | Out-Null
                }

                Set-Content $instanceFilePath $reconfiguredFileContent -Force
            
                $areFilesReconfigured = $true

                Write-Host "Reconfigured: $($instanceFilePath)" 
            }

            $fileName = Split-Path $instanceFilePath -Leaf

            if($allTfsSqlScripts -icontains $fileName)
            {
                foreach($dbName in $dbNames)
                {
                    if($reconfiguredFileContent -imatch "(?<=^|\s)" + $dbName + "(?=\.|\s)")
                    {
                        Write-Host
                        Write-Host "Found text $dbName in file $instanceFilePath which is not wrapped around square brackets. Please review the file and make appropriate changes." -ForegroundColor Red
                        Write-Host
                    }
                }
            }
        }   
    }  
}

if(!$areFilesReconfigured)
{
    Write-Host
    Write-Host "No file(s) were reconfigured."
}

#Undo check-out on unchanged files
tfpt uu $targetInstanceServerPath /recursive | Out-Null