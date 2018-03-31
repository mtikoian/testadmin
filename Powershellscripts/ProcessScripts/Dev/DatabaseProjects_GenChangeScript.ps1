Param
(
    [string]$appInstanceServerPath = $null
)

. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1

[string]$startScriptMarker = "/*START SCRIPT GENERATION*/"
[string]$endScriptMarker = "/*END SCRIPT GENERATION*/"

if([string]::IsNullOrEmpty($appInstanceServerPath))
{
    $appInstanceServerPath = ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Dev -branchState $BranchStateEnum.Existing
}

$workspace = Get-TfsWorkspace "$"

[string]$appInstanceLocalPath = $workspace.GetLocalItemForServerItem($appInstanceServerPath)
[string]$deployScriptDirLocalPath = $workspace.GetLocalItemForServerItem($appInstanceServerPath + "/" + $DevConfigData.DbDeployRelativeDirPathSuffix)

function BuildProject([Parameter(Mandatory=$true)][string]$projectPath)
{        
    [string]$logFilePath = $projectPath + ".BuildLog.txt"
    $projectFileInfo = Get-Item $projectPath
       
    Write-Host "Build Starting: $($projectFileInfo.Name)"

    if(Test-Path $logFilePath){
        Remove-Item $logFilePath
    }

    Write-Host "Please wait..."
    
    $buildProcess = Start-Process -FilePath $DevConfigData.VsCurrentVersionExePath `
        -ArgumentList @("`"$projectPath`"", "/rebuild `"Debug`"", "/out `"$logFilePath`"") `
        -PassThru

    $buildProcess.WaitForExit()

    if($buildProcess.ExitCode -eq 0)
    {
        Write-Host "Build Successful: $($projectFileInfo.Name)"
        Write-Host "Build log: $logFilePath"
    }
    else
    {
        Write-Host "Build log: $logFilePath"
        Invoke-Expression $logFilePath
        throw "Build Failure (please open Visual Studio for more details): $($projectFileInfo.Name)"
    }
}

function CleanupDeployScript
(
    [Parameter(Mandatory=$true)]
    [AllowEmptyString()]
    [string[]]$scriptContent
)
{
    [string]$newlinePlaceHolder = '[-n-]'
    [string]$newlineEscaped = [RegEx]::Escape($newlinePlaceHolder)
    [string]$scriptContentsRegex = "(?<=" + [RegEx]::Escape($startScriptMarker) + ").*(?=" + [RegEx]::Escape($endScriptMarker) + ")"

    [string]$contentAsString = $scriptContent -join "$newlinePlaceHolder" 

    if(-not ($contentAsString -cmatch $scriptContentsRegex)){
        throw "ERROR: Could not separate the script parts."
    }
    else
    {        
        [string]$contentAsString = $Matches[0]

        #Remove print statements
        $contentAsString = $contentAsString -creplace "PRINT\s+N?'.*?';", ""

        #Reformat GO statements
        $contentAsString = $contentAsString -creplace ("(?:$newlineEscaped)+GO(?:(?:$newlineEscaped)+GO|$newlineEscaped)+"), "$($newlinePlaceHolder)GO$newlinePlaceHolder$newlinePlaceHolder"
        
        #Remove starting GO's
        $contentAsString = $contentAsString -creplace ("^($newlineEscaped|GO)+"), ""

        #Remove ending new lines
        $contentAsString = $contentAsString -creplace ("($newlineEscaped)+$"), ""

        #Flag unsupported goto statements 
        $contentAsString = $contentAsString -creplace ("(?<=\w|\t)*goto.+?(?=$newlineEscaped)"), "RAISERROR('Unsupported GOTO statement found: $&', 10, 1)"
        
        #Flag unsupported labels (address before goto statements otherwise the error text can be picked up by regex)
        $contentAsString = $contentAsString -creplace ("(?<=$newlineEscaped[\s\t\r\f]*)(?:[^\s\t\r\f](?<!$newlineEscaped)(?!$newlineEscaped))+?:(?=[\s\t\r\f]*$newlineEscaped)"), "RAISERROR('Unsupported label found: $&', 10, 1)" 
        
        $contentAsString = $contentAsString.Trim()

        if($contentAsString.Length -eq 0){            
            return @()
        }

        return $contentAsString.Split([string[]]@($newlinePlaceHolder),[System.StringSplitOptions]::None)
    }
}

function SequenceScriptGeneration([Parameter(Mandatory=$true)][string[]]$databaseProjectPaths)
{
    [string]$startingWorkingLocation = (Get-Location).Path

    [System.Collections.ArrayList]$dbProjectMaps = New-Object System.Collections.ArrayList
    $dbProjectMaps.AddRange(($databaseProjectPaths | ForEach-Object { New-Object psobject -Property @{Name=(Split-Path $_ -Leaf); Path=$_; Dependencies=New-Object System.Collections.ArrayList;} } | Sort-Object Name))
    
    foreach($dpProjectMap in $dbProjectMaps)
    {
        [string]$projectContent = Get-Content $dpProjectMap.Path

        foreach($possibleMapRef in $dbProjectMaps)
        {
            if($possibleMapRef -eq $dpProjectMap){
                continue
            }
            
            if($projectContent -imatch "<ProjectReference Include=`"(?<ProjectPath>.*?$([RegEx]::Escape($possibleMapRef.Name)).*?)`">")
            {
                try
                {
                    Set-Location (Split-Path $dpProjectMap.Path -Parent)

                    #Ensures its the right project when multiple projects share the same name 
                    if((Resolve-Path $Matches["ProjectPath"]).Path -eq $possibleMapRef.Path){
                        $dpProjectMap.Dependencies.Add($possibleMapRef) | Out-Null
                    }
                }
                finally{
                    Set-Location $startingWorkingLocation
                }
            }            
        } 
    }

    [string[]]$sequencedProjectPaths = @()

    while($dbProjectMaps.Count -gt 0)
    {
        [PsCustomObject[]]$zeroDependenciesMaps = $dbProjectMaps | Where-Object { $_.Dependencies.Count -eq 0 }        

        if($zeroDependenciesMaps.Count -eq 0){
            throw "Unable to resolve script generation sequence. There appears to be a cicurlar project reference: $([string]::Join(", ",($dbProjectMaps | Select-Object -ExpandProperty Path)))"
        }

        foreach($zeroDepMap in $zeroDependenciesMaps)
        { 
            $dbProjectMaps.Remove($zeroDepMap)
            $sequencedProjectPaths += $zeroDepMap.Path
        }

        foreach($dbProjectMap in $dbProjectMaps)
        {
            foreach($zeroDepMap in $zeroDependenciesMaps){ 
                $dbProjectMap.Dependencies.Remove($zeroDepMap) | Out-Null
            }
        }
    }

    return $sequencedProjectPaths
}

[string[]]$databaseProjectPaths =  SequenceScriptGeneration -databaseProjectPaths (Get-ChildItem -LiteralPath $appInstanceLocalPath -Recurse -Filter "*.sqlproj" | Select-Object -ExpandProperty FullName)
[PsCustomObject[]]$databaseProjectInfos = $databaseProjectPaths | ForEach-Object { [PsCustomObject]@{FileInfo=(Get-Item $_); PublishXmlFilePath=$null; DacpacFilePath=$null; TargetDatabaseName=$null;} }
   
[Nullable[int]]$lastScriptNumber = $null
    
foreach($script in (Get-ChildItem -Path "$deployScriptDirLocalPath\*.sql"))
{ 
    if(-not ($script.Name -imatch "(?<Number>\d{1,})-.+\.sql")){
        throw "Could not determine script number: $($scrip.Name)"
    }

    [int]$scriptNumber = $Matches["Number"]

    if(($lastScriptNumber -eq $null) -or ($lastScriptNumber -lt $scriptNumber)){
        $lastScriptNumber = $scriptNumber
    }
}
        
[int]$newScriptNumber = 1

if($lastScriptNumber -ne $null){
    $newScriptNumber = $lastScriptNumber + 1
}

[string]$acceptableNameRegex = "^([A-Z]{1}[a-z]+)+$"
[string]$newScriptName = $null
[string]$similarScriptNameExp = $null

while([string]::IsNullOrWhiteSpace($newScriptName))
{
    $newScriptName = Read-Host "Enter script description (pascal case starting with a capital, no spaces, no special chars)"
    
    if($newScriptName -cmatch $acceptableNameRegex)
    {
        [string]$paddedNumber = $newScriptNumber.ToString().PadLeft($DevConfigData.DbScriptNumberOfDigits).Replace(" ","0")
        $newScriptName = "$paddedNumber-$newScriptName.sql"
        $similarScriptNameExp = "$paddedNumber-*.sql*"
    }
    else
    {
        $newScriptName = $null
        Write-Host "Invalid name, please try again."
    }

    Write-Host
}

[string]$finalScriptFilePath = $deployScriptDirLocalPath + "\" + $newScriptName
$similarScriptNameExp = $deployScriptDirLocalPath + "\" + $similarScriptNameExp

function CleanupScriptFiles
{
    [string[]]$filesToDelete = Get-Item -Path $similarScriptNameExp | Select-Object -ExpandProperty FullName

    if($filesToDelete.Count -gt 0){
        DeleteToRecycleBin -filePaths $filesToDelete
        Write-Host
    }
}

CleanupScriptFiles

#Prep steps
foreach($projectInfo in $databaseProjectInfos)
{
    [string[]]$publishXmlFilePaths = Get-ChildItem $projectInfo.FileInfo.DirectoryName -Filter "*.publish.xml" | Select-Object -ExpandProperty FullName

    if($publishXmlFilePaths.Count -eq 0){
        throw "$($projectInfo.FileInfo.FullName) does not have a publish.xml file within the same directory, please create one"
    }
    elseif($publishXmlFilePaths.Count -gt 1){
        throw "$($projectInfo.FileInfo.FullName) has $($publishXmlFilePaths.Count) publish.xml files within the same directory, expected 1"
    }

    $projectInfo.PublishXmlFilePath = $publishXmlFilePaths[0]

    [string]$publishContent = Get-Content -LiteralPath $projectInfo.PublishXmlFilePath

    if(!($publishContent -imatch "(?<=<TargetDatabaseName>).*?(?=</TargetDatabaseName>)")){
        throw "$($projectInfo.FileInfo.FullName) does not specify the target database name"
    }

    $projectInfo.TargetDatabaseName = $Matches[0]
}

#Build
foreach($projectInfo in $databaseProjectInfos)
{
    BuildProject -projectPath $projectInfo.FileInfo.FullName
    Write-Host

    [string]$dacPathDirPath = "$($projectInfo.FileInfo.DirectoryName)\bin\Debug"
    
    [string[]]$dacpacFilePaths = Get-ChildItem $dacPathDirPath -Filter "$($projectInfo.FileInfo.BaseName).dacpac" | Select-Object -ExpandProperty FullName
    
    if($dacpacFilePaths.Count -eq 0){
        throw "$dacPathDirPath does not contain a dacpac"
    }
    elseif($dacpacFilePaths.Count -gt 1){
        throw "$dacPathDirPath contains $($dacpacFilePaths.Count) dacpac files, expected 1"
    }

    $projectInfo.DacpacFilePath = $dacpacFilePaths[0]
}

[int]$subscriptNumber = 0
[System.Collections.ArrayList]$combinedScriptContent = New-Object System.Collections.ArrayList #($null)

#Generate Script
foreach($projectInfo in $databaseProjectInfos)
{    
    [string]$deployScriptPath = $finalScriptFilePath + "_Temp" + $subscriptNumber + "_" + $projectInfo.FileInfo.BaseName
    $subscriptNumber++

    [string]$errorAction = $Script:ErrorActionPreference

    try
    {
        #During generation warnings are raised as errors
        $Script:ErrorActionPreference = "silentlycontinue"

        Write-Host "Processing changes: $($projectInfo.FileInfo.Name)"

        Invoke-Expression -Command "& `"$($DevConfigData.SqlServerSqlPackageExePath)`" /Action:Script /SourceFile:`"$($projectInfo.DacpacFilePath)`" /Profile:`"$($projectInfo.PublishXmlFilePath)`" /OutputPath:`"$deployScriptPath`"" `
            -ErrorVariable scriptingWarningsAndErrors | Out-Null

        Write-Host "Temp script file: $deployScriptPath"

        $Script:ErrorActionPreference = $errorAction
        
        if(![string]::IsNullOrWhiteSpace($scriptingWarningsAndErrors))
        {
			Write-Host

            Write-Warning "Warnings/Errors occured during script generation for $($projectInfo.FileInfo.FullName)"
            Write-Host
            Write-Warning ($scriptingWarningsAndErrors | Out-String).Trim()
            Write-Host

            if((PromptForYesNoValue -displayMessage "Is it OK to continue given these script generation warnings/errors?" -isYesDefaultValue $false) -ine "y")
            {
                throw "Unable to continue generation due to issues in $($projectInfo.FileInfo.FullName)" 
            }

            Write-Host
        }

        [string[]]$scriptContent = Get-Content -LiteralPath $deployScriptPath
        
        if(!$scriptContent.Contains($startScriptMarker)){
            throw("$($projectInfo.FileInfo.Name) is missing a BuildAction:PreDeploy SQL script that contains `"$startScriptMarker`"")
        }

        if(!$scriptContent.Contains($endScriptMarker)){
            throw("$($projectInfo.FileInfo.Name) is missing a BuildAction:PostDeploy SQL script that contains `"$endScriptMarker`"")
        }

        $scriptContent = CleanupDeployScript -scriptContent $scriptContent

        if($scriptContent.Count -eq 0){
            Write-Host "No changes found in project"
        }
        else{
            if($databaseProjectInfos.Count -gt 1){
                $combinedScriptContent.Add("/*START: $($projectInfo.FileInfo.BaseName)*/") | Out-Null
            }

            $combinedScriptContent.Add("USE [$($projectInfo.TargetDatabaseName)];") | Out-Null
            $combinedScriptContent.Add("GO") | Out-Null
            $combinedScriptContent.Add("") | Out-Null

            $combinedScriptContent.AddRange($scriptContent) | Out-Null

            if($databaseProjectInfos.Count -gt 1)       {
                $combinedScriptContent.Add("/*COMPLETED: $($projectInfo.FileInfo.BaseName)*/") | Out-Null
                
            }

            $combinedScriptContent.Add("") | Out-Null
        }

        Write-Host "Changes processed: $($projectInfo.FileInfo.Name)"
        Write-Host
    }
    finally
    {
        $Script:ErrorActionPreference = $errorAction
    }
}

CleanupScriptFiles

if($combinedScriptContent.Count -eq 0){
    Write-Host "No changes found in database project(s)"
    Write-Host "Generation complete"
}
else
{
    Set-Content -Value $combinedScriptContent.ToArray() -Path $finalScriptFilePath

    tf add $finalScriptFilePath | out-null
    Write-Host "Script added to source control: $finalScriptFilePath"
    Write-Host
    Write-Host "Generation complete"
    Write-Host "NOTE: This script has NOT been executed. Please review and then deploy script."
    Write-Host

    Invoke-Expression $finalScriptFilePath
}

pause