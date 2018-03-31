. ..\Dev\Ref\DevConfigData.ps1
. ..\Shared\Ref\Version_Management.ps1

function Script:GetVersionNumber([parameter(Mandatory=$true)][string]$webConfigFilePath)
{
    [xml]$webConfigData = Get-Content $webConfigFilePath
    $webVersionNode = $webConfigData.Configuration.appSettings.SelectSingleNode("add[@key='WebVersion']")

    return $webVersionNode.value
}

function GetNextInstalledVersion([Parameter(Mandatory=$true)][string]$primaryDbName, [Parameter(Mandatory=$true)][string]$appInstanceServerPath)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Smo.Server") | Out-Null

    $branchName = Split-Path $appInstanceServerPath -Leaf

    [string]$sqlServerInstanceName = $DevConfigData.DevSqlServerInstanceName

    if($branchName -imatch ($DevConfigData.ReleaseBranchNameFormat -f "(?<branchNumber>\d+)")){
        $sqlServerInstanceName =  $DevConfigData.ReleaseBranchSqlServerInstanceNameFormat -f ([int]$Matches["branchNumber"])
    }

    [string]$serverName = $DevConfigData.DevSqlServerName + "\" + $sqlServerInstanceName

    [Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $serverName
    [Microsoft.SqlServer.Management.Smo.Database]$primaryDatabase = $smoServer.Databases[$primaryDbName]

    if($primaryDatabase -eq $null){
        throw "$primaryDbName does not exist in $serverName."
    }
    
    [System.Data.DataSet]$versionDataSet = $null

    try{
        $appVersionTable = $primaryDatabase.Tables.Item("ApplicationVersion")

        if($appVersionTable -ne $null)
        {
            $versionDataSet = $primaryDatabase.ExecuteWithResults("SELECT TOP 1 [version] FROM ApplicationVersion ORDER BY Id DESC")
        }
    }
    catch
    {
        Write-Warning "Retrieving the current version from the ApplicationVersion table failed."
        Write-Host
            
        throw $Error[0].Exception
    }

    [string]$dbVersion = "0.0.0.0"

    if(($versionDataSet -ne $null) -and ($versionDataSet.Tables[0].Rows.Count -gt 0)){
        $dbVersion = $versionDataSet.Tables[0].Rows[0]["Version"]
    }

    $workspace = Get-TfsWorkspace "$"

    [string]$fileContent = Get-Content -LiteralPath ($workspace.GetLocalItemForServerItem($DevConfigData.AppCurrentVersionFilePathAndRegex.Keys[0]))
    [PsCustomObject]$devVersionObject = $null

    if($fileContent -imatch $DevConfigData.AppCurrentVersionFilePathAndRegex.Values[0])
    {
        $devVersionObject = [PsCustomObject] @{
                Major = [int]$Matches["major"]
                Minor = [int]$Matches["minor"]
                Build = [int]$Matches["build"]
                Revision = [int]$Matches["revision"]
        }
    } 
    else
    {
        Write-Host 
        throw "Version number could not be retrieved from the specified file. Please correct the regex: $($DevConfigData.AppCurrentVersionFilePathAndRegex.Values[0]) for file: $($DevConfigData.AppCurrentVersionFilePathRegex.Keys[0])"
    }

    $dbVersionObject = GetVersionObject -versionNumberText $dbVersion
    $devVersionObject.Build = $dbVersionObject.Build + 1

    return $devVersionObject
}