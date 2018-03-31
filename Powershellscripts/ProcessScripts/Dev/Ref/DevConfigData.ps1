. ..\Shared\Ref\SharedConfigData.ps1

[string]$Script:devSqlServerName = "S4000PC-D-SQE01"

[string]$Script:sqlServer2008ExePath= ${env:ProgramFiles(x86)} + "\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\Ssms.exe"
[string]$Script:sqlServer2008SqlPackageExePath = ${env:ProgramFiles(x86)} + "\Microsoft SQL Server\110\DAC\bin\SqlPackage.exe"

[string]$Script:tf2010ExePath = ${env:ProgramFiles(x86)} + "\Microsoft Visual Studio 10.0\Common7\IDE\TF.exe"
[string]$Script:tf2012ExePath = ${env:ProgramFiles(x86)} + "\Microsoft Visual Studio 11.0\Common7\IDE\TF.exe"
[string]$Script:tf2013ExePath = ${env:ProgramFiles(x86)} + "\Microsoft Visual Studio 12.0\Common7\IDE\TF.exe"

[string]$Script:tfsPowerTools2010DirPath = ${env:ProgramFiles(x86)} + "\Microsoft Team Foundation Server 2010 Power Tools"
[string]$Script:tfsPowerTools2012DirPath = ${env:ProgramFiles(x86)} + "\Microsoft Team Foundation Server 2012 Power Tools"
[string]$Script:tfsPowerTools2013DirPath = ${env:ProgramFiles(x86)} + "\Microsoft Team Foundation Server 2013 Power Tools"

[string[]]$Script:versionNumberRegexes = @(("(?<=AssemblyVersion\(`")" + $SharedConfigData.VersionNumberRegex) , ("(?<=AssemblyFileVersion\(`")" + $SharedConfigData.VersionNumberRegex))

[string]$Script:vs2010ExePath = ${env:ProgramFiles(x86)} + "\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
[string]$Script:vs2012ExePath = ${env:ProgramFiles(x86)} + "\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe"
[string]$Script:vs2013ExePath = ${env:ProgramFiles(x86)} + "\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"

$DevConfigData = [PsCustomObject] @{  

    #region Branching
        AppCurrentVersionFilePathAndRegex = @{"$/Sdnh/Release/Main/SolutionInfo.cs"= "(?<=AssemblyVersion\(`")" + $SharedConfigData.VersionNumberRegex}

        BranchNameWorkItemFormat = "WorkItem_{0}"

        #Two dimensional array to hold seprator start and end value
        DbNameReconfigSeprator = @(("=", ";"), ("[","]"))

        DevBranchesServerDirPath = "$/Sdnh/DevBranches"
        DoNotMergeStatement = "[DoNotMerge]"

        #Key is a server file path relative to application instance root and value is a regex array where the regexes match only the portion of a version number that needs to be incremented
        FileAndVersionRegexes = @{"SolutionInfo.cs"=$Script:versionNumberRegexes}

        #Two dimensional array to hold seprator start and end value
        FilePathReconfigSeprator = @(("'","'"), ('"','"'))

        MaxReleaseBranches = 2

        #Any file in the application that may require re-configuration. Ex: web.config, app.config, etc.
        ReconfigFileNameRegexs = @('*.csproj', '*.config', '*.sql', '*.tt')

        ReconfigUrlReplaceText = "localhost/Sdnh-Main"
        ReleaseBranchesServerDirPath = "$/Sdnh/Release"

        #{0} represents where the release branch number should be placed
        ReleaseBranchNameFormat = "MaturityLevel{0}"
        ReleaseBranchSqlServerInstanceNameFormat = "MaturityLevel{0}"

        TrunkName = "Main"
        TrunkPromoteEmailActiveDirGroups = @("DL_CSES_Developers")
        WebsiteNameFormat = "Sdnh-WI{0}"
    #endregion

    #region Code Review & Check-in
        MaxPendingChangesToDisplay = 30
    #endregion

    #region Database
        #Application instance folder is the root of the relative path. Application instance root example: Release/Dev. 
        DbDeployRelativeDirPathSuffix = "Database/Deploy"

        DbScriptNumberOfDigits = 6
        DbScriptNumberRegEx = "^\d+"

        #Contains mdf and ldf files
        DevSqlDataFileDirPath = "F:\DataSdnhDev"

        DevSqlLogFileDirPath = "L:\LogSdnhDev"
        DevSqlServerBackupDirPath = "\\$Script:devSqlServerName\B\Backup"       
        DevSqlServerInstanceName = "SdnhDev"
        DevSqlServerName = $Script:devSqlServerName
        SqlServerCurrentProductVersion = "10.50.1600.1"
        SqlServerCurrentVersionExePath = $Script:sqlServer2008ExePath
        SqlServerSqlPackageExePath = $Script:sqlServer2008SqlPackageExePath

        #First database name should be the primary database.
        TrunkDatabaseNames = @("Sdnh")
    #endregion

    #region Misc File Locations
        #Key is relative paths to launch, value is the wait time in seconds for the executable to launch
        ExeToLaunchRelativePathAndWaitTimeMapping = @{}

        ProcessScriptsServerPath = "$/Sdnh/ProcessScripts"

        #Path is relative to application instance root. Application instance root example: Release/Main.    
        RelativeDirPathsToScorch = @{}

        SolutionsToBuildRelativePaths = @("Sdnh.sln")
        WebAppToLaunchRelativePaths = @("Web\Dss.Sdnh.Web.WebUi\Dss.Sdnh.Web.WebUi.csproj")  
           
        #Path is relative to application instance root. Application instance root example: Release/Main.    
        WebConfigFileRelativePath = "Web\Dss.Sdnh.Web.WebUi\Web.config"  

        WorkspaceLocalDirPath = "C:\CfsWorkspace"
    #endregion

    #region TFS
        TfCurrentVersionExePath = $Script:tf2013ExePath
        TfOldVersionExePaths = @($Script:tf2010ExePath ,$Script:tf2012ExePath)
        TfsPowerToolsCurrentVersionDirPath = $Script:tfsPowerTools2013DirPath
        TfsPowerToolsDownloadUrl = "http://visualstudiogallery.msdn.microsoft.com/f017b10c-02b4-4d6d-9845-58a06545627f"
        TfsPowerToolsOldVersionDirPaths = @($Script:tfsPowerTools2010DirPath,$Script:tfsPowerTools2012DirPath)
        TfsWorkItemPerfIssueType="Task"
    #endregion

    #region Visual Studio
        VsCurrentProductVersion = "12.0.31101.0"
        VsCurrentVersionExePath = $Script:vs2013ExePath
         
        VsInstalledProductRegPathAndVersion = @{
            "Registry::HKEY_CURRENT_USER\Software\Microsoft\VisualStudio\12.0_Config\InstalledProducts\Microsoft SQL Server Data Tools"="12.0.50318.0";
            "Registry::HKEY_CURRENT_USER\Software\Microsoft\VisualStudio\12.0_Config\InstalledProducts\TfptPackage"="12.0";
        }

        VsOldProductRegPathAndName = @{
            "Registry::HKEY_CURRENT_USER\Software\Microsoft\VisualStudio\11.0_Config\InstalledProducts\Microsoft SQL Server Data Tools"="Microsoft SQL Server Data Tools 2012";
            "Registry::HKEY_CURRENT_USER\Software\Microsoft\VisualStudio\11.0_Config\InstalledProducts\TfptPackage"="TFS 2012 Power tools";
        }

        VsOldVersionExePaths = @($Script:vs2010ExePath, $Script:vs2012ExePath)
    #endregion
}