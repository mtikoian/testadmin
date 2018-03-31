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
[Microsoft.SqlServer.Management.Smo.Database]$database = $smoServer.Databases[$primaryDbName]

if($database -eq $null)
{
    throw "$primaryDbName does not exist in $serverName."
}

# DbDeployScripts table is only loaded on the primary database
[Microsoft.SqlServer.Management.Smo.Database]$primaryDatabase = $smoServer.Databases[$primaryDbName]
[Microsoft.SqlServer.Management.Smo.Table]$deployScriptTable = $primaryDatabase.Tables.Item("SqlDeployScript")

if ($deployScriptTable -eq $null)
{
    $deployScriptTable = new-object Microsoft.SqlServer.Management.Smo.Table($primaryDatabase, "SqlDeployScript")
    [Microsoft.SqlServer.Management.Smo.Column]$id = new-object Microsoft.SqlServer.Management.Smo.Column($deployScriptTable, "Id", [Microsoft.SqlServer.Management.Smo.DataType]::Int)
    $id.Identity = $true
    $id.IdentitySeed = 10000
    $id.IdentityIncrement = 1

    [Microsoft.SqlServer.Management.Smo.Column]$fileNumber = new-object Microsoft.SqlServer.Management.Smo.Column($deployScriptTable, "FileNumber", [Microsoft.SqlServer.Management.Smo.DataType]::Int)
    $fileNumber.Nullable = $false

    [Microsoft.SqlServer.Management.Smo.Column]$fileName = new-object Microsoft.SqlServer.Management.Smo.Column($deployScriptTable, "FileName", [Microsoft.SqlServer.Management.Smo.DataType]::NVarchar(100))
    $fileName.Nullable = $false

    [Microsoft.SqlServer.Management.Smo.Column]$sqlText = new-object Microsoft.SqlServer.Management.Smo.Column($deployScriptTable, "SqlText", [Microsoft.SqlServer.Management.Smo.DataType]::NVarcharMax)
    $sqlText.Nullable = $false

    [Microsoft.SqlServer.Management.Smo.Column]$appVersionId = new-object Microsoft.SqlServer.Management.Smo.Column($deployScriptTable, "ApplicationVersionId", [Microsoft.SqlServer.Management.Smo.DataType]::Int)
    $appVersionId.Nullable = $false

    $deployScriptTable.Columns.Add($id)
    $deployScriptTable.Columns.Add($fileNumber)
    $deployScriptTable.Columns.Add($fileName)
    $deployScriptTable.Columns.Add($sqlText)
    $deployScriptTable.Columns.Add($appVersionId)

    #Define the Primary Key and add to Deploy Script Table
    [Microsoft.SqlServer.Management.Smo.Index]$pk_SqlDeployScript = new-object Microsoft.SqlServer.Management.Smo.Index($deployScriptTable, "PK_SqlDeployScript")
    $pk_SqlDeployScript.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriPrimaryKey
    $pk_SqlDeployScript.IsClustered = $true
    [Microsoft.SqlServer.Management.Smo.IndexedColumn]$pk_SqlDeployScriptId = new-object Microsoft.SqlServer.Management.Smo.IndexedColumn($pk_SqlDeployScript, "Id")
    $pk_SqlDeployScript.IndexedColumns.Add($pk_SqlDeployScriptId)
    $deployScriptTable.Indexes.Add($pk_SqlDeployScript)

    #Define the Foreign Key on the ApplicationVersionId Column
    [Microsoft.SqlServer.Management.Smo.Table]$fkRefTable = $primaryDatabase.Tables.Item("ApplicationVersion")
    [Microsoft.SqlServer.Management.Smo.ForeignKey]$fkAppVerId = new-object Microsoft.SqlServer.Management.Smo.ForeignKey($deployScriptTable, "FK_ApplicationVersion_Id")
    [Microsoft.SqlServer.Management.Smo.Column]$fkRefCol = $deployScriptTable.Columns.Item("ApplicationVersionId")
    [Microsoft.SqlServer.Management.Smo.ForeignKeyColumn]$fkAppVerIdCol = New-Object Microsoft.SqlServer.Management.Smo.ForeignKeyColumn($fkAppVerId, "ApplicationVersionId", "Id")
    $fkAppVerId.Columns.Add($fkAppVerIdCol)
    $fkAppVerId.ReferencedTable = $fkRefTable.Name
    $fkAppVerId.ReferencedTableSchema = $fkRefTable.Schema
              
    #Define Unique Constraint Index on FileNumber column
    [Microsoft.SqlServer.Management.Smo.Index]$fileNoUniqueIndex = new-object Microsoft.SqlServer.Management.Smo.Index($deployScriptTable, "IX_U_FileNumber")
    $fileNoUniqueIndex.IndexKeyType = [Microsoft.SqlServer.Management.Smo.IndexKeyType]::DriUniqueKey
    $fileNoUniqueIndex.IsClustered = $false
    [Microsoft.SqlServer.Management.Smo.IndexedColumn]$fileNoIndexCol = new-object Microsoft.SqlServer.Management.Smo.IndexedColumn($fileNoUniqueIndex, "FileNumber")
    $fileNoUniqueIndex.IndexedColumns.Add($fileNoIndexCol)
    $fileNoUniqueIndex.IsUnique = $true

    Write-Host "$($writeHostPrefix -f $($primaryDbName)) The SqlDeployScript table does not exist.  Being created now."

    try
    {
        $deployScriptTable.Create()
        $fkAppVerId.Create()
        $fileNoUniqueIndex.Create()
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