##################################################################
### The following parameters are provided by Octopus Deploy.  ###
###    Uncomment these with default values for testing.       ###
#################################################################

#$SSRSReportServerUrl = "http://ssrs/reportserver/reportservice2005.asmx"
#$SSRSDynamicDataSourceCredentialsUsername = ""
#$SSRSDynamicDataSourceCredentialsPassword = ""
#$SSRSReportFolder = "Project Folder"
#$SSRSSharedDataSourcePath = "/Data Sources/dsShared"
#$environment = "Environment Folder";

# This value is also supplied by Octopus Deploy. But we are aliasing the variable
# here to make testing the script easier.
$environment = $OctopusParameters["Octopus.Environment.Name"] 

$reportPath = "/"

Write-Host -fore Green "Deploying reports to " $ssrsreportserverurl

# If the Reporting Services Root (destination) directory does not exist - create it.
$ssrsProxy = New-WebServiceProxy -Uri $ssrsreportserverurl -UseDefaultCredential

try
{
	$ssrsProxy.CreateFolder($SSRSReportFolder, $reportPath, $null)
	Write-Host "Created new folder: $SSRSReportFolder"
}
catch [System.Web.Services.Protocols.SoapException]
{
	if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]")
	{
		Write-Host -fore Yellow "Folder: $SSRSReportFolder already exists."
	}
	else
	{
		$msg = "Error creating folder: $SSRSReportFolder. Msg: '{0}'" -f $_.Exception.Detail.InnerText
		Write-Error $msg
	}
}

# If the Reporting Services Subfolder (destination) directory does not exist - create it.
$reportPath = [string]::Concat($reportPath, $SSRSReportFolder)

#Check if folder is existing, create if not found
try
{
	$ssrsProxy.CreateFolder($environment, $reportPath, $null)
	Write-Host -fore Green "Created new folder: $environment"
}
catch [System.Web.Services.Protocols.SoapException]
{
	if ($_.Exception.Detail.InnerText -match "[^rsItemAlreadyExists400]")
	{
		Write-Host -fore Yellow "Folder: $environment already exists."
	}
	else
	{
		$msg = "Error creating folder: $environment. Msg: '{0}'" -f $_.Exception.Detail.InnerText
		Write-Error $msg
	}
}

function Install-SSRSRDL
(
    [ValidateScript({Test-Path $_})]
    [Parameter(Position=0,Mandatory=$true)]
    [Alias("rdl")]
    [string]$rdlFile,
 
    [Parameter(Position=1)]
    [Alias("folder")]
    [string]$reportFolder="",
 
    [Parameter(Position=2)]
    [Alias("name")]
    [string]$reportName="",
 
    [Parameter(Position=3)]
    [string]$reportCredentialsUsername="",

    [Parameter(Position=4)]
    [string]$reportCredentialsPassword="",

    [switch]$force
)
{
    #Set reportname if blank, default will be the filename without extension
    if($reportName -ne "") {
        $reportName = [System.IO.Path]::GetFileNameWithoutExtension($rdlFile);
    }
    
    try
    {
        #Get Report content in bytes
        $byteArray = gc $rdlFile -encoding byte
        
        Write-Host "Uploading $reportName to $reportFolder"
 
        $warnings = $ssrsProxy.CreateReport($reportName,$reportFolder,$force,$byteArray,$null)
        if($warnings -eq $null) { 
            Write-Host "Report uploaded" 
        }
        else { 
            $warnings | % { Write-Warning $_ }
        }

        $found = 0

        $dsPath = [string]::Concat($reportFolder, "/", $reportName)
        $ds = $ssrsProxy.GetItemDataSources($dsPath)
        $ds | ForEach-Object {
            if($_.Name -eq "dsDynamic") {
                if ($reportCredentialsUsername -ne "") {
                    Write-Host "Datasource dsDynamic found. Setting credentials" 
                    $_.Item.CredentialRetrieval = "Store"
                    $_.Item.UserName = $reportCredentialsUsername
                    $_.Item.Password = $reportCredentialsPassword
                    $found = 1
                }
                else {
                    Write-Error ("Report $reportName had dynamic data source dsDynamic but no reportCredentialsUsername variable provided")
                }
            } elseif ($_.Name -eq "dsTAS") {
                Write-Host "Shared datasource found. setting path" 
                
                if ($SSRSSharedDataSourcePath -ne $null){
                    $proxyNamespace = $ssrsProxy.GetType().Namespace
                    $_.Item = New-Object("$proxyNamespace.DataSourceReference")
                    $_.Item.Reference = $SSRSSharedDataSourcePath
                    $found = 1
                }
                else{
                    Write-Error ("Report $reportName had shared data source reference dsTAS but no SSRSdsTASSharedDataSourcePath variable provided")
                }
            }
        }
        if ($found -eq 1){
            $ssrsProxy.SetItemDataSources($dsPath, $ds)
        }
    }
    catch [System.IO.IOException]
    {
        Write-Error ("Error while reading rdl file : '{0}', Message: '{1}'" -f $rdlFile, $_.Exception.Message)
    }
    catch [System.Web.Services.Protocols.SoapException]
    {
        Write-Error ("Error while uploading rdl file : '{0}', Message: '{1}'" -f $rdlFile, $_.Exception.Detail.InnerText)
    }
}

$reportPath = [string]::Concat($reportPath, "/", $environment)
Get-ChildItem './Reports' -Filter *.rdl | 
Foreach-Object{
    Install-SSRSRDL $_.FullName -force -reportFolder $reportPath -reportName $_.Name -reportCredentialsUsername $ssrsDynamicdatasourceCredentialsUsername  -reportCredentialsPassword $ssrsDynamicDatasourceCredentialsPassword
}