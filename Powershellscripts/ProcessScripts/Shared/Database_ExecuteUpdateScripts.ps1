Param(
    [Parameter(Mandatory=$true)]
    [string]$versionNumber,

    [Parameter(Mandatory=$true)]
    [string]$serverName,

    [string]$dbInstanceName = $null,

    [Parameter(Mandatory=$true)]
    [string]$primaryDbName,

    [bool]$isDbBackedUp = $false, 

    [Parameter(Mandatory=$true)]
    [string]$dbDeployScriptPath = $null
)

. ..\Shared\Ref\Function_Misc.ps1
. ..\Shared\Ref\Version_Management.ps1

if(!$isDbBackedUp){
    throw "A backup should be taken prior to running the scripts." 
}

$versionNumberObject = GetVersionObject -versionNumberText $versionNumber
[string]$paddedVersionNumber = GetPaddedVersionText -versionObject $versionNumberObject

[string]$dateTimeStamp = Get-Date -Format yyyyMMddHHmmss

[string]$externalLogText = $null

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Smo.Server") | Out-Null

[string]$dbServerInstance = $null

if([string]::IsNullOrWhiteSpace($dbInstanceName)){
    $dbServerInstance = $serverName
}
else{
    $dbServerInstance = "$serverName\$dbInstanceName"
}

[string]$writeHostPrefix = $dbServerInstance + ":{0} ->"

[Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $dbServerInstance

# DbDeployScripts table is only loaded on the primary database
[Microsoft.SqlServer.Management.Smo.Database]$primaryDatabase = $smoServer.Databases[$primaryDbName]

$scriptTableExistsSql = "SELECT Count(1) FROM sys.tables WHERE name = 'ApplicationVersion'"
[int]$scriptCount = $primaryDatabase.ExecuteWithResults($scriptTableExistsSql).Tables[0].Rows[0].Column1

if($scriptCount -eq 0){
    [string]$architectureException = "The ApplicationVersion table has not been created"
    Write-Warning "$architectureException. It must exist to execute scripts. This step must be accomplished at this time then the scripts run."
    Write-Host

    Throw $architectureException
}

$scriptTableExistsSql = "SELECT Count(1) FROM sys.tables WHERE name = 'SqlDeployScript'"
$scriptCount = $primaryDatabase.ExecuteWithResults($scriptTableExistsSql).Tables[0].Rows[0].Column1

if($scriptCount -eq 0){
    $createSqlDeployScriptTbl = "CREATE TABLE [dbo].[SqlDeployScript](  [Id] [int] IDENTITY(10000,1) NOT NULL, [FileNumber] [int] NOT NULL, [FileName] [nvarchar](100) NOT NULL, 
        [SqlText] [nvarchar](max) NOT NULL,  [ApplicationVersionId] [int] NOT NULL,  CONSTRAINT [PK_SqlDeployScript] PRIMARY KEY CLUSTERED 
         (  [Id] ASC )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],  
         CONSTRAINT [IX_U_FileNumber] UNIQUE NONCLUSTERED  (  [FileNumber] ASC )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, 
         ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] ) ON [PRIMARY] "
    $createFkCheck = "ALTER TABLE [dbo].[SqlDeployScript]  WITH CHECK ADD  CONSTRAINT [FK_ApplicationVersion_Id] FOREIGN KEY([ApplicationVersionId]) 
        REFERENCES [dbo].[ApplicationVersion] ([Id])"
    $addFkCheck = "ALTER TABLE [dbo].[SqlDeployScript] CHECK CONSTRAINT [FK_ApplicationVersion_Id]"
        try
        {
           $primaryDatabase.ExecuteNonQuery($createSqlDeployScriptTbl)
           $primaryDatabase.ExecuteNonQuery($createFkCheck)
           $primaryDatabase.ExecuteNonQuery($addFkCheck)
        }
        catch
        {
            $sqlException = GetSqlException -exception $Error[0].Exception
            Write-Warning "$($writeHostPrefix -f $($primaryDbName)) Creation of the SqlDeployScript table failed."
            Write-Host        

            throw $sqlException
        }

    Write-Host "$($writeHostPrefix -f $($primaryDbName))  The SqlDeployScript table has been created."
    Write-Host
} 

$scriptText = "SELECT Id FROM [$primaryDbName].[dbo].[ApplicationVersion] WHERE Version = '$paddedVersionNumber'"
[System.Data.DataSet]$dsMaxId = $null

try{
    $dsMaxId = $primaryDatabase.ExecuteWithResults($scriptText)
}
catch
{
    $sqlException = GetSqlException -exception $Error[0].Exception

    Write-Warning "$($writeHostPrefix -f $($primaryDbName)) Retrieving the current ID from the ApplicationVersion table failed."
    Write-Host    
        
    throw $sqlException
}

[Int32]$AppVerId = $dsMaxId.Tables[0].Rows[0]["Id"]

[string]$getFileNameQuery = "SELECT FileName FROM [$primaryDbName].[dbo].[SqlDeployScript]" 
[string[]]$executedFiles = @()
    
try{
    [System.Data.DataSet]$fileNameDataSet = $primaryDatabase.ExecuteWithResults($getFileNameQuery)
}
catch
{
    $sqlException = GetSqlException -exception $Error[0].Exception
    Write-Warning "$($writeHostPrefix -f $($primaryDbName)) Gathering previously executed scripts failed."
    Write-Host
    
    throw $sqlException
}

foreach($rowScriptNames in $fileNameDataSet.Tables[0].Rows){
    $executedFiles += $rowScriptNames["FileName"]
}
Write-Host "$($writeHostPrefix -f $($primaryDbName)) Executed scripts of version $paddedVersionNumber"
Write-Host "------------------------------------------------------------------------------------------------------------------------"
$externalLogText = ("Deployment Date").PadRight(21) + ("Script Name").PadRight(65) + ("Successful Execution?").PadRight(25) + ("Exception Thrown")
Write-Host $externalLogText

[string[]]$allTfsSqlScripts = Get-ChildItem $dbDeployScriptPath -Name -Filter *.sql
[string[]]$scriptsToBeExecuted = @();

if($allTfsSqlScripts -ne $null)
{
    $scriptsToBeExecuted = (Compare-Object $executedFiles $allTfsSqlScripts).InputObject
}

If($scriptsToBeExecuted.Count -eq 0)
{
    Write-Host "$($writeHostPrefix -f $($primaryDbName)) There were no new scripts in the deployment directory to be executed." -ForegroundColor Yellow -BackgroundColor DarkMagenta
    Write-Host
    $externalLogText = $dateTimeStamp.PadRight(21) + ("No new scripts to run.").PadRight(65) + ("Yes").PadRight(25)     
    Write-Host $externalLogText
}

foreach($script in $scriptsToBeExecuted)
{
    [int]$fileNumber = 0

    try
    {
        $regexMatch = [regex]::Match($script, "(?<FileNumber>\d+)\s?-\s?.+")
        $fileNumber = [Convert]::ToInt32($regexMatch.Groups["FileNumber"].Value)
        [string]$scriptText = "SELECT COUNT(1) AS FileCount FROM [$primaryDbName].[dbo].[SqlDeployScript] WHERE FileNumber = $fileNumber"
        [System.Data.DataSet]$dsScriptExecutedRows = $primaryDatabase.ExecuteWithResults($scriptText)

        [System.Data.DataRow]$tblScriptExecutedRows = $dsScriptExecutedRows.Tables[0].Rows[0]
        [Int32]$execRows = $tblScriptExecutedRows.FileCount

        if($execRows -gt 0){
            throw "$writeHostPrefix Script Number $fileNumber has already been executed.  Check for duplication and rename in sequence if script is intened to be executed."
        }
    }
    catch
    {        
        $sqlException = GetSqlException -exception $Error[0].Exception
        $externalLogText = $dateTimeStamp.PadRight(21) + ("Scripts Not Run").PadRight(65) + ("No").PadRight(25) + ($sqlException.Replace("`n", ""))
		Write-Host $externalLogText

        throw $sqlException
    }
    
    $scriptText = Get-Content "$dbDeployScriptPath\$script"     

    $scriptText = $scriptText.Replace("GO", [char]10+"GO"+[char]10)

    try {
    $primaryDatabase.ExecuteNonQuery($scriptText)
    }
    catch
    {
        Write-Warning "$($writeHostPrefix -f $($primaryDbName)) $script could not be executed properly.  Restore the database to the previous version."
        Write-Host

        $sqlException = GetSqlException -exception $Error[0].Exception
        $externalLogText = $dateTimeStamp.PadRight(21) + ("Scripts Not Run").PadRight(65) + ("No").PadRight(25) + ($sqlException.Replace("`n", ""))
        Write-Host $externalLogText
                  
        throw "$($writeHostPrefix -f $($primaryDbName)) Exception occurred in $script. $($_.Exception.GetBaseException().Message)"
    }

	$externalLogText = $dateTimeStamp.PadRight(21) + $script.PadRight(65) + ("Yes").PadRight(25) 
	Write-Host $externalLogText

    [string]$logScript = "INSERT INTO [$($primaryDatabase.Name)].[dbo].[SqlDeployScript](FileNumber, FileName, SqlText, ApplicationVersionId) VALUES ( `
                                        $fileNumber , '$script', '" + $scriptText.Replace("'", "''") + "', $AppVerId)" 
        
    try{
        $primaryDatabase.ExecuteNonQuery($logScript)
    }
    catch
    {
        $sqlException = GetSqlException -exception $Error[0].Exception
        Write-Warning "$($writeHostPrefix -f $($primaryDbName)) Logging script '$script' to SqlDeployScript table failed."
        Write-Host

        $externalLogText = $dateTimeStamp.PadRight(21) + ("Scripts run but not logged to SqlDeployScript correctly").PadRight(65) + ("No").PadRight(25) + ($sqlException.Replace("`n", ""))
        Write-Host $externalLogText

        throw $sqlException
    }    
}