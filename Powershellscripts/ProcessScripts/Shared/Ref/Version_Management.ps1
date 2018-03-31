. ..\Shared\Ref\SharedConfigData.ps1
. ..\Shared\Ref\Function_Misc.ps1

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.Smo.Server") | Out-Null

function GetPaddedVersionText([Parameter(Mandatory=$true)][PsCustomObject]$versionObject)
{
    [string]$paddedVersionText = "{0:D$($SharedConfigData.MajorVersionDigitCount)}" -f $versionObject.Major
        $paddedVersionText += ".{0:D$($SharedConfigData.MinorVersionDigitCount)}" -f $versionObject.Minor
        $paddedVersionText += ".{0:D$($SharedConfigData.BuildVersionDigitCount)}" -f $versionObject.Build
        $paddedVersionText += ".{0:D$($SharedConfigData.RevisionVersionDigitCount)}" -f $versionObject.Revision

    return $paddedVersionText
}

function GetVersionObject([Parameter(Mandatory=$true)][string]$versionNumberText)
{
    if($versionNumberText -imatch $SharedConfigData.VersionNumberRegex)
    {
        $parsedVersion = [PsCustomObject] @{
                Major = [int]$Matches["major"]
                Minor = [int]$Matches["minor"]
                Build = [int]$Matches["build"]
                Revision = [int]$Matches["revision"]
        }
        return $parsedVersion
    }
    else{
        throw "Incorrect version number format supplied. Version number must be in X.X.X.X format."
    }
}

function RecordInstallStart
(
    [Parameter(Mandatory=$true)]
    [string]$serverName, 
    
    [string]$instanceName = $null,
     
    [Parameter(Mandatory=$true)]
    [string[]]$databaseNames, 

    [Parameter(Mandatory=$true)]
    [string]$versionNumber
)
{    
    $versionNumberObject = GetVersionObject -versionNumberText $versionNumber
    [string]$paddedVersionNumber = GetPaddedVersionText -versionObject $versionNumberObject

    [string]$dbServerInstance = $null

    if(![string]::IsNullOrWhiteSpace($instanceName)){
        $dbServerInstance ="$serverName\$instanceName"    
    }
    else{
        $dbServerInstance ="$serverName"    
    }

     
    [string]$writeHostPrefix = $dbServerInstance +":{0} ->"

    [Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $dbServerInstance

    foreach($dbName in $databaseNames)
    {
        $database = $smoServer.Databases[$dbName]

        $scriptTableExistsSql = "SELECT Count(1) FROM sys.tables WHERE name = 'ApplicationVersion'"
        [int]$scriptCount = $database.ExecuteWithResults($scriptTableExistsSql).Tables[0].Rows[0].Column1

       if($scriptCount -eq 0)
        {
            $createApplicationVersion = "CREATE TABLE [dbo].[ApplicationVersion](
	                [Id] [int] IDENTITY(10000,1) NOT NULL PRIMARY KEY,
	                [Version] [varchar](25) NOT NULL,
	                [DeploymentDate] [datetime] NOT NULL,
	                [IsSuccessful] [bit] NOT NULL DEFAULT 0)"

            Write-Host "$($writeHostPrefix -f $dbName) ApplicationVersion table does not exist.  Being created now."

            try
            {
                $database.ExecuteNonQuery($createApplicationVersion);
            }
            catch
            {
                $sqlException = GetSqlException -exception $Error[0].Exception
                Write-Warning "$($writeHostPrefix -f $dbName) Creation of the ApplicationVersion table failed."
                Write-Host
                throw $sqlException
            }      

            Write-Host "$($writeHostPrefix -f $dbName) ApplicationVersion table created."
            Write-Host
        }

        [string]$scriptText = "INSERT INTO [$($database.Name)].[dbo].[ApplicationVersion]([Version], [DeploymentDate], [IsSuccessful]) VALUES('$paddedVersionNumber', GetDate(), 0)"
    
        try
        {
            $database.ExecuteNonQuery($scriptText)
        }
        catch
        {             
            $sqlException = GetSqlException -exception $Error[0].Exception
            Write-Warning "$($writeHostPrefix -f $dbName) Logging to the ApplicationVersion table failed."
            Write-Host

            if($sqlException -imatch "Violation of UNIQUE KEY constraint 'IX_U_Version'.")
            {
                Write-Warning "$($writeHostPrefix -f $dbName) The Version passed in has already been logged in the ApplicationVersion table"
                Write-Host
            }            
        
            throw $sqlException
        }
    }    
}

function RecordInstallEnd
(
    [Parameter(Mandatory=$true)]
    [string]$serverName, 

    [string]$instanceName = $null, 

    [Parameter(Mandatory=$true)]
    [string[]]$databaseNames, 

    [Parameter(Mandatory=$true)]
    [string]$versionNumber
)
{
    $versionNumberObject = GetVersionObject -versionNumberText $versionNumber
    [string]$paddedVersionNumber = GetPaddedVersionText -versionObject $versionNumberObject

    [string]$dbServerInstance = $null 
    
    if(![string]::IsNullOrWhiteSpace($instanceName)){
        $dbServerInstance ="$serverName\$instanceName"    
    }
    else{
        $dbServerInstance ="$serverName"    
    }
        
    [string]$writeHostPrefix = $dbServerInstance +":{0} ->"

    [Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $dbServerInstance

    foreach($databaseName in $envDatabaseNames)
    {
        [Microsoft.SqlServer.Management.Smo.Database]$database = $smoServer.Databases[$databaseName]

         $scriptTableExistsSql = "SELECT Count(1) FROM sys.tables WHERE name = 'ApplicationVersion'"
        [int]$scriptCount = $database.ExecuteWithResults($scriptTableExistsSql).Tables[0].Rows[0].Column1

        if($scriptCount -eq 0)
        {
            throw "$($writeHostPrefix -f $databaseName) ApplicationVersion table is not present"
        }

        [string]$scriptText = "UPDATE [$($database.Name)].[dbo].[ApplicationVersion] SET IsSuccessful = '1' WHERE Version = '$paddedVersionNumber'"    
        
        try
        {
            $database.ExecuteNonQuery($scriptText)
            Write-Host "$($writeHostPrefix -f $databaseName) Successful installation is marked in ApplicationVersion table"
        }
        catch
        {             
            $sqlException = GetSqlException -exception $Error[0].Exception
            Write-Warning "$($writeHostPrefix -f $databaseName) Could not update IsSuccessful flag in ApplicationVersion table."
            Write-Host
        
            throw $sqlException
        }        
    }
}