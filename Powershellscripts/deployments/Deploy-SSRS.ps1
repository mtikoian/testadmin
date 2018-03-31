$DeployedPath = $OctopusParameters["Octopus.Action[$NugetPackageStepName].Output.Package.InstallationDirectoryPath"]
$ReleaseNumber = $OctopusParameters["Octopus.Release.Number"]


#region Upload-Item
Function Upload-Item
{
    # parameters
    param ([string] $Item, [string]$ItemType, [string] $ItemFolder)

    Write-Host "Loading data from $Item"
    $ItemData = [System.IO.File]::ReadAllBytes($Item)

    # Create local variables
    $Warnings = $null
    $ItemName = $Item.SubString($Item.LastIndexOf("\") + 1)
    $ItemName = $ItemName.SubString(0, $ItemName.IndexOf("."))
   
	# upload item
    if ($IsReportService2005) {
        if($ItemType -eq "Report")
        {
	        [void]$ReportServerProxy.CreateReport($ItemName, $ItemFolder, $true, $ItemData, $null)
        }
        else
        {
            # error
            Write-Error "$ItemType is not supported in ReportService2005"
        }
	}
	elseif ($IsReportService2010) {
		[void]$ReportServerProxy.CreateCatalogItem($ItemType, $ItemName, $ItemFolder, $true, $ItemData, $null, [ref] $Warnings);
	}
	else { Write-Warning 'Report Service Unknown in Upload-Item method. Use ReportService2005 or ReportService2010.' }
}
#endregion

#region Get-ItemDataSourceNames()
Function Get-ItemDataSourceNames
{
    # Parameters
    Param ($ItemFile, $DataSourceName)

    # declare working variables
    $DataSourceNames = @()
    
    # load the xml
    [xml]$Xml = Get-Content $ItemFile

    # retrieve the datasource nodes
    $DataSourceReferenceNodes = $Xml.GetElementsByTagName("DataSource")

    # loop through returned results
    foreach($Node in $DataSourceReferenceNodes)
    {
        # check to see if we're looking for a specific one
        if($DataSourceName -ne $null)
        {
            # check to see if it's the current node
            if($DataSourceName -eq $Node.Name)
            {
                # add
                $DataSourceNames += $Node.DataSourceReference
            }
        }
        else
        {
            # store the name
            $DataSourceNames += $Node.DataSourceReference
        }
    }

    # return the results
    return ,$DataSourceNames # Apparently using the , in front of the variable is how you return explicit arrays in PowerShell ... could you be more obsure?
}
#endregion

#region Get-ItemDataSourceReferenceNames
Function Get-ItemDataSourceReferenceNames
{
    # Parameters
    Param ($ItemFile)

    # declare working variables
    $DataSourceNames = @()
    
    # load the xml
    [xml]$Xml = Get-Content $ItemFile

    # retrieve the datasource nodes
    $DataSourceReferenceNodes = $Xml.GetElementsByTagName("DataSourceReference")

    # loop through returned results
    foreach($Node in $DataSourceReferenceNodes)
    {
        # get the data
        $DataSourceNames += $Node.InnerText
    }

    # return the results
    return ,$DataSourceNames # Apparently using the , in front of the variable is how you return explicit arrays in PowerShell ... could you be more obsure?
}
#endregion

#region Get-DataSetSharedReferenceName
Function Get-DataSetSharedReferenceName
{
    # parameters
    param($ReportFile, $DataSetName)

    # load the xml
    [xml]$ReportXml = Get-Content $ReportFile

    # Get the DataSet nodes
    $DataSetNode = $ReportXml.GetElementsByTagName("DataSet") | Where-Object {$_.Name -eq $DataSetName}

    # return the name
    $DataSetNode.SharedDataSet.SharedDataSetReference
}
#endregion

#region Item-Exists()
Function Item-Exists($ItemFolderPath, $ItemName)
{
    # declare search condition
    $SearchCondition = New-Object "$ReportServerProxyNamespace.SearchCondition";

    # fill in properties
    $SearchCondition.Condition = Get-SpecificEnumValue -EnumNamespace "$ReportServerProxyNamespace.ConditionEnum" -EnumName "Equals"
    $SearchCondition.ConditionSpecified = $true
    $SearchCondition.Name = "Name"

	if ($IsReportService2005) {
		$SearchCondition.Value = $ItemName
		# search
	    $items = $ReportServerProxy.FindItems($ItemFolderPath, (Get-SpecificEnumValue -EnumNamespace "$ReportServerProxyNamespace.BooleanOperatorEnum" -EnumName "And"), $SearchCondition)
	}
	elseif ($IsReportService2010) {
		$SearchCondition.Values = @($ItemName)
		# search
	    $items = $ReportServerProxy.FindItems($ItemFolderPath, (Get-SpecificEnumValue -EnumNamespace "$ReportServerProxyNamespace.BooleanOperatorEnum" -EnumName "And"), $null, $SearchCondition)
	}
	else { Write-Warning 'Report Service Unknown in Item-Exists method. Use ReportService2005 or ReportService2010.' }    

    # check to see if anything was returned
    if($items.Length -gt 0)
    {
        # loop through returned items
        foreach($item in $items)
        {
            # check the path
            if($item.Path -eq "$ItemFolderPath/$ItemName")
            {
                # return true
                return $true
            }
            else
            {
                # warn
                Write-Warning "Unexpected path for $($item.Name); path is $($item.Path) exepected $ItemFolderPath/$ItemName"
            }
        }

        # items were found, but the path doesn't match
        
        return $false
    }
    else
    {
        return $false
    }
}
#endregion

#region Set-ItemDataSources()
Function Set-ItemDataSources
{
    # parameters
    Param($ItemFile, $ItemFolder)

    # declare local variables
    $ItemName = $ItemFile.SubString($ItemFile.LastIndexOf("\") + 1)
    $ItemName = $ItemName.SubString(0, $ItemName.IndexOf("."))
    $AllDataSourcesFound = $true
    
    # get the datasources
    $DataSources = $ReportServerProxy.GetItemDataSources([string]::Format("{0}/{1}", $ItemFolder, $ItemName))

    #loop through retrieved datasources
    foreach($DataSource in $DataSources)
    {
        # check to see if it's a dataset
        if([System.IO.Path]::GetExtension($ItemFile).ToLower() -eq ".rsd")
        {
            # datasets can have one and only one datasource
            # The method GetItemDataSources does not return the name of the datasource for datasets like it does for reports
            # instead, it alaways returns DataSetDataSource.  This made the call to Get-ItemDataSourceNames necessary,
            # otherwise it would not link correctly
            $DataSourceName = (Get-ItemDataSourceReferenceNames -ItemFile $ItemFile)[0]
        }
        else
        {
            # get the anme from teh source itself
            $DataSourceName = (Get-ItemDataSourceNames -ItemFile $ItemFile -DataSourceName $DataSource.Name)[0]
        }        
        
        # check to make sure the datasource exists in the location specified
        if((Item-Exists -ItemFolderPath $ReportDatasourceFolder -ItemName $DataSourceName) -eq $true)
        {
            # create datasource reference variable
            $DataSourceReference = New-Object "$ReportServerProxyNamespace.DataSourceReference";

            # assign
            $DataSourceReference.Reference = "$ReportDatasourceFolder/" + $DataSourceName
            $DataSource.Item = $DataSourceReference            
        }
        else
        {
            # display warning
            Write-Warning "Unable to find datasource $($DataSourceName) in $ReportDataSourceFolder"

            # update to false
            $AllDataSourcesFound = $false
        }        
    }

    # check to see if found all datasources
    if($AllDataSourcesFound -eq $true)
    {
        Write-Host "Linking datasources to $ItemFolder/$ItemName"
        
        # save the references
        $ReportServerProxy.SetItemDataSources("$ItemFolder/$ItemName", $DataSources)
    }
}
#endregion

#region Set-ReportDataSets()
Function Set-ReportDataSets
{
    # parameters
    param($ReportFile)

    # declare local variables
    $ReportName = $ReportFile.SubString($ReportFile.LastIndexOf("\") + 1)
    $ReportName = $ReportName.SubString(0, $ReportName.IndexOf("."))
    $AllDataSetsFound = $true

    # get the datasources
    $DataSets = $ReportServerProxy.GetItemReferences([string]::Format("{0}/{1}", $ReportFolder, $ReportName), "DataSet")

    # loop through returned values
    foreach($DataSet in $DataSets)
    {
        # get the name of the shared data set reference
        $SharedDataSetReferenceName = Get-DataSetSharedReferenceName -ReportFile $ReportFile -DataSetName $DataSet.Name
        
        # check to make sure the datasource exists in the location specified
        if((Item-Exists -ItemFolderPath $ReportDataSetFolder -ItemName $SharedDataSetReferenceName) -eq $true)
        {
            # create datasource reference variable
            $DataSetReference = New-Object "$ReportServerProxyNamespace.ItemReference";

            # assign
            $DataSetReference.Reference = "$ReportDataSetFolder/" + $SharedDataSetReferenceName
            $DataSetReference.Name = $DataSet.Name

            # log
            Write-Host "Linking Shared Data Set $($DataSet.Name) to $ReportName"
            
            # update reference
            $ReportServerProxy.SetItemReferences("$ReportFolder/$ReportName", @($DataSetReference))
        }
        else
        {
            # get the datasource name to include in warning message -- I know there must be a way to use the property in a string literal, but I wasn't able to figure it out while trying
            # to solve a reported bug so I took the easy way.
            $DataSetName = $DataSet.Name
            
            # display warning
            Write-Warning "Unable to find dataset $DataSetName in $ReportDataSetFolder"

            # update to false
            $AllDataSetsFound = $false
        }            
    }

    # check to see if all datsets were found
    if($AllDataSetsFound -eq $False)
    {
        Write-Warning "Not all datasets found"

        # save the references
        #$ReportServerProxy.SetItemReferences("$ReportFolder/$ReportName", @($DataSets))
    }
}

#endregion

#region Get-ObjectNamespace()
Function Get-ObjectNamespace($Object)
{
    # return the value
    ($Object).GetType().ToString().SubString(0, ($Object).GetType().ToString().LastIndexOf("."))
}
#endregion

#region Get-SpecificEnumValue()
Function Get-SpecificEnumValue($EnumNamespace, $EnumName)
{
    # get the enum values
    $EnumValues = [Enum]::GetValues($EnumNamespace)

    # Loop through to find the specific value
    foreach($EnumValue in $EnumValues)
    {
        # check current
        if($EnumValue -eq $EnumName)
        {
            # return it
            return $EnumValue
        }
    }

    # nothing was found
    return $null
}
#endregion

#region Update-ReportParamters()
Function Update-ReportParameters($ReportFile)
{
    # declare local variables
    $ReportParameters = @();

    # necessary so that when attempting to use the report execution service, it doesn't puke on you when it can't find the data source
    $ReportData = (Remove-SharedReferences -ReportFile $ReportFile)

    # get just the report name
    $ReportName = $ReportFile.SubString($ReportFile.LastIndexOf("\") + 1)
    $ReportName = $ReportName.SubString(0, $ReportName.IndexOf("."))
    
    # create warnings object
    $ReportExecutionWarnings = $null

    # load the report definition
    $ExecutionInfo = $ReportExecutionProxy.LoadReportDefinition($ReportData, [ref] $ReportExecutionWarnings);

    # loop through the report execution parameters
    foreach($Parameter in $ExecutionInfo.Parameters)
    {
        # create new item parameter object
        $ItemParameter = New-Object "$ReportServerProxyNamespace.ItemParameter";

        # fill in the properties except valid values, that one needs special processing
        Copy-ObjectProperties -SourceObject $Parameter -TargetObject $ItemParameter;

        # fill in the valid values
        $ItemParameter.ValidValues = Convert-ValidValues -SourceValidValues $Parameter.ValidValues;

        # add to list
        $ReportParameters += $ItemParameter;
    }

    # force the parameters to update
    Write-Host "Updating report parameters for $ReportFolder/$ReportName"
	if ($IsReportService2005) {
		$ReportServerProxy.SetReportParameters("$ReportFolder/$ReportName", $ReportParameters);
	}
	elseif ($IsReportService2010) {
		$ReportServerProxy.SetItemParameters("$ReportFolder/$ReportName", $ReportParameters);
	}
	else { Write-Warning 'Report Service Unknown in Update-ReportParameters method. Use ReportService2005 or ReportService2010.' }
}
#endregion

#region Remove-ShareReferences()
Function Remove-SharedReferences($ReportFile)
{
    ######################################################################################################
    #You'll notice that I've used the keywrod of [void] in front of some of these method calls, this is so
    #that the operation isn't captured as output of the function
    ######################################################################################################

    # read xml
    [xml]$ReportXml = Get-Content $ReportFile;
    
    # create new memory stream object
    $MemoryStream = New-Object System.IO.MemoryStream

    try
    {

        # declare array of nodes to remove
        $NodesToRemove = @();

        # get datasource names
        $DataSourceNames = Get-ItemDataSourceNames -ItemFile $ReportFile

        # check to see if report has datasourcenames
        if($DataSourceNames.Count -eq 0)
        {
            # Get reference to reportnode
            $ReportNode = $ReportXml.FirstChild.NextSibling # Kind of a funky way of getting it, but the SelectSingleNode("//Report") wasn't working due to Namespaces in the node

            # create new DataSources node
            $DataSourcesNode = $ReportXml.CreateNode($ReportNode.NodeType, "DataSources", $null)

            # create new datasource node
            $DataSourceNode = $ReportXml.CreateNode($ReportNode.NodeType, "DataSource", $null)

            # create new datasourcereference node
            $DataSourceReferenceNode = $ReportXml.CreateNode($ReportNode.NodeType, "DataSourceReference", $null)

            # create new attribute
            $DataSourceNameAttribute = $ReportXml.CreateAttribute("Name")
            $DataSourceNameAttribute.Value = "DataSource1"
            $dataSourceReferenceNode.InnerText = "DataSource1"

            # add attribute to datasource node
            [void]$DataSourceNode.Attributes.Append($DataSourceNameAttribute)
            [void]$DataSourceNode.AppendChild($DataSourceReferenceNode)

            # add nodes
            [void]$ReportNode.AppendChild($DataSourcesNode)
            [void]$DataSourcesNode.AppendChild($DataSourceNode)

            # add fake datasource name to array
            $DataSourceNames += "DataSource1"
        }

        # get all datasource nodes
        $DatasourceNodes = $ReportXml.GetElementsByTagName("DataSourceReference");

        # loop through returned nodes
        foreach($DataSourceNode in $DatasourceNodes)
        {
            # create a new connection properties node
            $ConnectionProperties = $ReportXml.CreateNode($DataSourceNode.NodeType, "ConnectionProperties", $null);

            # create a new dataprovider node
            $DataProvider = $ReportXml.CreateNode($DataSourceNode.NodeType, "DataProvider", $null);
            $DataProvider.InnerText = "SQL";

            # create new connection string node
            $ConnectString = $ReportXml.CreateNode($DataSourceNode.NodeType, "ConnectString", $null);
            $ConnectString.InnerText = "Data Source=Server Name Here;Initial Catalog=database name here";

            # add new node to parent node
            [void] $DataSourceNode.ParentNode.AppendChild($ConnectionProperties);

            # append childeren
            [void] $ConnectionProperties.AppendChild($DataProvider);
            [void] $ConnectionProperties.AppendChild($ConnectString);

            # Add to remove list 
            $NodesToRemove += $DataSourceNode;
        }

        # get all shareddataset nodes
        $SharedDataSetNodes = $ReportXml.GetElementsByTagName("SharedDataSet")

        #loop through the returned nodes
        foreach($SharedDataSetNode in $SharedDataSetNodes)
        {
            # create holder nodes so it won't error
            $QueryNode = $ReportXml.CreateNode($SharedDataSetNode.NodeType, "Query", $null);
            $DataSourceNameNode = $ReportXml.CreateNode($QueryNode.NodeType, "DataSourceName", $null);
            $CommandTextNode = $ReportXml.CreateNode($QueryNode.NodeType, "CommandText", $null);

            # add valid datasource name, just get the first in the list
            $DataSourceNameNode.InnerText = $DataSourceNames[0]
            
            # add node to parent
            [void] $SharedDataSetNode.ParentNode.Appendchild($QueryNode)
            
            # add datasourcename and commandtext to query node
            [void]$QueryNode.AppendChild($DataSourceNameNode)
            [void]$QueryNode.AppendChild($CommandTextNode)

            # add node to removelist
            $NodesToRemove += $SharedDataSetNode
        }


        # loop through nodes to remove
        foreach($Node in $NodesToRemove)
        {
            # remove from parent
            [void] $Node.ParentNode.RemoveChild($Node);
        }
    
        $ReportXml.InnerXml = $ReportXml.InnerXml.Replace("xmlns=`"`"", "")

        # save altered xml to memory stream
        $ReportXml.Save($MemoryStream);

        # return the altered xml as byte array
        return $MemoryStream.ToArray();
    }
    finally
    {
        # close and dispose
        $MemoryStream.Close();
        $MemoryStream.Dispose();
    }
}
#endregion

#region Copy-ObjectProperties()
Function Copy-ObjectProperties($SourceObject, $TargetObject)
{
    # Get source object property array
    $SourcePropertyCollection = $SourceObject.GetType().GetProperties();

    # get the destination
    $TargetPropertyCollection = $TargetObject.GetType().GetProperties();

    # loop through source property collection
    for($i = 0; $i -lt $SourcePropertyCollection.Length; $i++)
    {
        # get the target property
        $TargetProperty = $TargetPropertyCollection | Where {$_.Name -eq $SourcePropertyCollection[$i].Name}
        
        # check to see if it's null
        if($TargetProperty -ne $null)
        {
            # check to see if it's the valid values property
            if($TargetProperty.Name -ne "ValidValues")
            {
                 # set the value
                $TargetProperty.SetValue($TargetObject, $SourcePropertyCollection[$i].GetValue($SourceObject));
            }
        }
    }
}
#endregion

#region ConvertValidValues()
Function Convert-ValidValues($SourceValidValues)
{
    # declare local values
    $TargetValidValues = @();
    
    # loop through source values
    foreach($SourceValidValue in $SourceValidValues)
    {
        # create target valid value object
        $TargetValidValue = New-Object "$ReportServerProxyNamespace.ValidValue";

        # copy properties
        Copy-ObjectProperties -SourceObject $SourceValidValue -TargetObject $TargetValidValue

        # add to list
        $TargetValidValues += $TargetValidValue
    }

    # return the values
    return ,$TargetValidValues
}
#endregion

#region Backup-ExistingItem()
Function Backup-ExistingItem
{
    # parameters
    Param($ItemFile, $ItemFolder)

    # declare local variables
    $ItemName = $ItemFile.SubString($ItemFile.LastIndexOf("\") + 1)
    $ItemName = $ItemName.SubString(0, $ItemName.IndexOf("."))

    # check to see if the item exists
    if((Item-Exists -ItemFolderPath $ItemFolder -ItemName $ItemName) -eq $true)
    {
        # get file extension
        $FileExtension = [System.IO.Path]::GetExtension($ItemFile)
    
        # check backuplocation
        if($BackupLocation.EndsWith("\") -ne $true)
        {
            # append ending slash
            $BackupLocation = $BackupLocation + "\"
        }
		
		# add the release number to the backup location
		$BackupLocation = $BackupLocation + $ReleaseNumber + "\"

        # ensure the backup location actually exists
        if((Test-Path $BackupLocation) -ne $true)
        {
            # create it
            New-Item -ItemType Directory -Path $BackupLocation
        }

        # download the item
        $Item = $ReportServerProxy.GetItemDefinition("$ItemFolder/$ItemName")

        # form the backup path
        $BackupPath = "{0}{1}{2}" -f $BackupLocation, $ItemName, $FileExtension;

        # write to disk
        [System.IO.File]::WriteAllBytes("$BackupPath", $Item);

        # write to screen
        Write-Host "Backed up $ItemFolder/$ItemName to $BackupPath";
    }
}
#endregion

#region Normalize-SSRSFolder()
function Normalize-SSRSFolder ([string]$Folder) {
    if (-not $Folder.StartsWith('/')) {
        $Folder = '/' + $Folder
    }
    
    return $Folder
}
#endregion

#region New-SSRSFolder()
function New-SSRSFolder ([string] $Name) {
    Write-Verbose "New-SSRSFolder -Name $Name"
 
    $Name = Normalize-SSRSFolder -Folder $Name
 
    if ($ReportServerProxy.GetItemType($Name) -ne 'Folder') {
        $Parts = $Name -split '/'
        $Leaf = $Parts[-1]
        $Parent = $Parts[0..($Parts.Length-2)] -join '/'
 
        if ($Parent) {
            New-SSRSFolder -Name $Parent
        } else {
            $Parent = '/'
        }
        
        $ReportServerProxy.CreateFolder($Leaf, $Parent, $null)
    }
}
#endregion

#region New-SSRSDataSource()
function New-SSRSDataSource ([string]$RdsPath, [string]$Folder, [bool]$OverwriteDataSources) {
    Write-Verbose "New-SSRSDataSource -RdsPath $RdsPath -Folder $Folder"

    $Folder = Normalize-SSRSFolder -Folder $Folder
    
    [xml]$Rds = Get-Content -Path $RdsPath
    $dsName = $Rds.RptDataSource.Name
    $ConnProps = $Rds.RptDataSource.ConnectionProperties
    
	$type = $ReportServerProxy.GetType().Namespace #Get proxy type
	$DSDdatatype = ($type + '.DataSourceDefinition')
	 
	$Definition = new-object ($DSDdatatype)
	if($Definition -eq $null){
	 Write-Error Failed to create data source definition object
	}
	
	$dsConnectionString = $($OctopusParameters["$($dsName).ConnectionString"])
	
	# replace the connection string variable that is configured in the octopus project
	if ($dsConnectionString) {
	    $Definition.ConnectString = $dsConnectionString
	} else {
	    $Definition.ConnectString = $ConnProps.ConnectString
	}
	
    $Definition.Extension = $ConnProps.Extension 

	if ([Convert]::ToBoolean($ConnProps.IntegratedSecurity)) {
		$Definition.CredentialRetrieval = 'Integrated'
	}
	else {
		$Definition.CredentialRetrieval = 'Store'
		
		$dsUsername = $($OctopusParameters["$($dsName).Username"])
		Write-Host "$($dsName).Username = '$dsUsername'"
		
		$dsPassword = $($OctopusParameters["$($dsName).Password"])
		Write-Host "$($dsName).Password = '$dsPassword'"
		
		$Definition.UserName = $dsUsername;
        $Definition.Password = $dsPassword;
	}

    $DataSource = New-Object -TypeName PSObject -Property @{
        Name = $Rds.RptDataSource.Name
        Path =  $Folder + '/' + $Rds.RptDataSource.Name
    }
    
    if ($OverwriteDataSources -or $ReportServerProxy.GetItemType($DataSource.Path) -eq 'Unknown') {
        Write-Host "Overwriting datasource $($DataSource.Name)"
        $ReportServerProxy.CreateDataSource($DataSource.Name, $Folder, $OverwriteDataSources, $Definition, $null)
    }
    
    return $DataSource 
}
#endregion

#region Main

try
{
    # declare array for reports
    $ReportFiles = @()
	$ReportDataSourceFiles = @()
    $ReportDataSetFiles = @()
	
	$IsReportService2005 = $false
	$IsReportService2010 = $false
	
	if ($ReportServiceUrl.ToLower().Contains('reportservice2005.asmx')) {
		$IsReportService2005 = $true
		Write-Host "2005 Report Service found."
	}
	elseif ($ReportServiceUrl.ToLower().Contains('reportservice2010.asmx')) {
		$IsReportService2010 = $true
		Write-Host "2010 Report Service found."
	}
	
	Write-Host "Deploy Path: $DeployedPath"
	
    # get all report files for deployment
    Write-Host "Getting all .rdl files"
    Get-ChildItem $DeployedPath -Recurse -Filter "*.rdl" | ForEach-Object { If(($ReportFiles -contains $_.FullName) -eq $false) {$ReportFiles += $_.FullName}}
    Write-Host "# of rdl files found: $($ReportFiles.Count)"

    # get all report datasource files for deployment
    Write-Host "Getting all .rds files"
    Get-ChildItem $DeployedPath -Recurse -Filter "*.rds" | ForEach-Object { If(($ReportDataSourceFiles -contains $_.FullName) -eq $false) {$ReportDataSourceFiles += $_.FullName}}
    Write-Host "# of rds files found: $($ReportDataSourceFiles.Count)"

    # get all report datset files for deployment
    Write-Host "Getting all .rsd files"
    Get-ChildItem $DeployedPath -Recurse -Filter "*.rsd" | ForEach-Object { If(($ReportDataSetFiles -contains $_.FullName) -eq $false) {$ReportDataSetFiles += $_.FullName}}
    Write-Host "# of rsd files found: $($ReportDataSetFiles.Count)"


    # set the report proxies
    Write-Host "Creating SSRS Web Service proxies"

    # check to see if credentials were supplied for the services
    if(([string]::IsNullOrEmpty($ServiceUserDomain) -ne $true) -and ([string]::IsNullOrEmpty($ServiceUserName) -ne $true) -and ([string]::IsNullOrEmpty($ServicePassword) -ne $true))
    {
        # secure the password
        $secpasswd = ConvertTo-SecureString "$ServicePassword" -AsPlainText -Force

        # create credential object
        $ServiceCredential = New-Object System.Management.Automation.PSCredential ("$ServiceUserDomain\$ServiceUserName", $secpasswd)

        # create proxies
        $ReportServerProxy = New-WebServiceProxy -Uri $ReportServiceUrl -Credential $ServiceCredential
        $ReportExecutionProxy = New-WebServiceProxy -Uri $ReportExecutionUrl -Credential $ServiceCredential
    }
    else
    {
        # create proxies using current identity
        $ReportServerProxy = New-WebServiceProxy -Uri $ReportServiceUrl -UseDefaultCredential 
        $ReportExecutionProxy = New-WebServiceProxy -Uri $ReportExecutionUrl -UseDefaultCredential 
    }



	#Create folder information for DataSource and Report
	New-SSRSFolder -Name $ReportFolder
	New-SSRSFolder -Name $ReportDatasourceFolder
    New-SSRSFolder -Name $ReportDataSetFolder
	 
	#Create DataSource
    foreach($RDSFile in $ReportDataSourceFiles) {
        Write-Host "New-SSRSDataSource $RdsFile"
        
		$DataSource = New-SSRSDataSource -RdsPath $RdsFile -Folder $ReportDatasourceFolder -Overwrite ([System.Convert]::ToBoolean("$OverwriteDataSources"))
	}

    # get the service proxy namespaces - this is necessary because of a bug documented here http://stackoverflow.com/questions/7921040/error-calling-reportingservice2005-finditems-specifically-concerning-the-bool and http://www.vistax64.com/powershell/273120-bug-when-using-namespace-parameter-new-webserviceproxy.html
    $ReportServerProxyNamespace = Get-ObjectNamespace -Object $ReportServerProxy
    $ReportExecutionProxyNamespace = Get-ObjectNamespace -Object $ReportExecutionProxy

    # Create dat sets
    foreach($DataSet in $ReportDataSetFiles)
    {
        # check to see if we need to back up
        if($BackupLocation -ne $null -and $BackupLocation -ne "")
        {
            # backup the item
            Backup-ExistingItem -ItemFile $DataSet -ItemFolder $ReportDataSetFolder
        }

        # upload the dataset
        Upload-Item -Item $DataSet -ItemType "DataSet" -ItemFolder $ReportDataSetFolder

        # update the dataset datasource
        Set-ItemDataSources -ItemFile $DataSet -ItemFolder $ReportDataSetFolder
    }

    # get the proxy auto generated name spaces

    # loop through array
    foreach($ReportFile in $ReportFiles)
    {
        # check to see if we need to back up
        if($BackupLocation -ne $null -and $BackupLocation -ne "")
        {
            # backup the item
            Backup-ExistingItem -ItemFile $ReportFile -ItemFolder $ReportFolder
        }
        
        # upload report
        Upload-Item -Item $ReportFile -ItemType "Report" -ItemFolder $ReportFolder

        # extract datasources
        #Write-Host "Extracting datasource names for $ReportFile"
        #$ReportDataSourceNames = Get-ReportDataSourceNames $ReportFile

        # set the datasources
        Set-ItemDataSources -ItemFile $ReportFile -ItemFolder $ReportFolder

        # set the datasets
        Set-ReportDataSets -ReportFile $ReportFile

        # update the report parameters
        Update-ReportParameters -ReportFile $ReportFile
    }
}
finally
{
    # check to see if the proxies are null
    if($ReportServerProxy -ne $null)
    {
        # dispose
        $ReportServerProxy.Dispose();
    }

    if($ReportExecutionProxy -ne $null)
    {
        # dispose
        $ReportExecutionProxy.Dispose();
    }
}

#endregion