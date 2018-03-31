#serverstatus.ps1
#Pings a list of servers contained in the text file servers.txt and if the server responds, returns WMI and SQL Server information from each server
#
# Change log:
# January 29, 2009: Allen White
#   Initial Version
# September 22, 2010: Allen White
#   Add DiskPartition info to getwmiinfo function
# October 31, 2010: Allen White
#   Load server data directly to destination database
#
param(
	[string]$sqlsrv=$null,
	[string]$destdb=$null
	)

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SqlWmiManagement') | out-null

$box_id = 0;

function getinfo {
	param(
		[string]$svr,
		[string]$inst
		)
	# Get ComputerSystem info and write it to a CSV file
	$cs = gwmi -query "select * from
		Win32_ComputerSystem" -computername $svr | select Name,
		Model, Manufacturer, Description, DNSHostName,
		Domain, DomainRole, PartOfDomain, NumberOfProcessors,
		SystemType, TotalPhysicalMemory, UserName, Workgroup
	$cs | foreach {
		$compsys = $_

		$q = "declare @box_id int; exec [Analysis].[insComputerSystem]"
		$q = $q + " @box_id OUTPUT"
		$q = $q + ", @Name='" + $compsys.Name + "'"
		if ($compsys.Model.length -ne 0) {
			$q = $q + ", @Model='" + $compsys.Model + "'"
			}
		if ($compsys.Manufacturer.length -ne 0) {
			$q = $q + ", @Manufacturer='" + $compsys.Manufacturer + "'"
			}
		if ($compsys.Description.length -ne 0) {
			$q = $q + ", @Description='" + $compsys.Description + "'"
			}
		if ($compsys.DNSHostName.length -ne 0) {
			$q = $q + ", @DNSHostName='" + $compsys.DNSHostName + "'"
			}
		if ($compsys.Domain.length -ne 0) {
			$q = $q + ", @Domain='" + $compsys.Domain + "'"
			}
		if ($compsys.DomainRole.length -ne 0) {
			$q = $q + ", @DomainRole=" + [string]$compsys.DomainRole
			}
		if ($compsys.PartOfDomain.length -ne 0) {
			$q = $q + ", @PartOfDomain='" + $compsys.PartOfDomain + "'"
			}
		if ($compsys.NumberOfProcessors.length -ne 0) {
			$q = $q + ", @NumberOfProcessors=" + [string]$compsys.NumberOfProcessors
			}
		if ($compsys.SystemType.length -ne 0) {
			$q = $q + ", @SystemType='" + $compsys.SystemType + "'"
			}
		if ($compsys.TotalPhysicalMemory.length -ne 0) {
			$q = $q + ", @TotalPhysicalMemory=" + [string]$compsys.TotalPhysicalMemory
			}
		if ($compsys.UserName.length -ne 0) {
			$q = $q + ", @UserName='" + $compsys.UserName + "'"
			}
		if ($compsys.Workgroup.length -ne 0) {
			$q = $q + ", @Workgroup='" + $compsys.Workgroup + "'"
			}
		$q = $q + "; select @box_id as box_id"	

		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		$boxid = $res.box_id

		}
		 
	# Get OperatingSystem info and write it to a CSV file
	$os = gwmi -query "select * from
		 Win32_OperatingSystem" -computername $svr | select Name,
		 Version, FreePhysicalMemory, OSLanguage, OSProductSuite,
		 OSType, ServicePackMajorVersion, ServicePackMinorVersion
	$os | foreach {
		$opersys = $_

		$q = "exec [Analysis].[insOperatingSystem]"
		$q = $q + " @box_id=" + [string]$boxid
		if ($opersys.Name.length -ne 0) {
			$q = $q + ", @Name='" + $opersys.Name + "'"
			}
		if ($opersys.Version.length -ne 0) {
			$q = $q + ", @Version='" + $opersys.Version + "'"
			}
		if ($opersys.FreePhysicalMemory.length -ne 0) {
			$q = $q + ", @FreePhysicalMemory=" + [string]$opersys.FreePhysicalMemory
			}
		if ($opersys.OSLanguage.length -ne 0) {
			$q = $q + ", @OSLanguage=" + [string]$opersys.OSLanguage
			}
		if ($opersys.OSProductSuite.length -ne 0) {
			$q = $q + ", @OSProductSuite=" + [string]$opersys.OSProductSuite
			}
		if ($opersys.OSType.length -ne 0) {
			$q = $q + ", @OSType=" + [string]$opersys.OSType
			}
		if ($opersys.ServicePackMajorVersion.length -ne 0) {
			$q = $q + ", @ServicePackMajorVersion=" + [string]$opersys.ServicePackMajorVersion
			}
		if ($opersys.ServicePackMinorVersion.length -ne 0) {
			$q = $q + ", @ServicePackMinorVersion=" + [string]$opersys.ServicePackMinorVersion
			}
		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q

		}

	# Get PhysicalMemory info and write it to a CSV file
	$pm = gwmi -query "select * from
		 Win32_PhysicalMemory" -computername $svr | select Name, Capacity, DeviceLocator,
		 Tag
	$pm | foreach {
		$physmem = $_

		$q = "exec [Analysis].[insPhysicalMemory]"
		$q = $q + " @box_id=" + [string]$boxid
		if ($physmem.Name.length -ne 0) {
			$q = $q + ", @Name='" + $physmem.Name + "'"
			}
		if ($physmem.Capacity.length -ne 0) {
			$q = $q + ", @Capacity=" + [string]$physmem.Capacity
			}
		if ($physmem.DeviceLocator.length -ne 0) {
			$q = $q + ", @DeviceLocator='" + $physmem.DeviceLocator + "'"
			}
		if ($physmem.Tag.length -ne 0) {
			$q = $q + ", @Tag='" + $physmem.Tag + "'"
			}
		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q

		}

	# Get LogicalDisk info and write it to a CSV file
	$ld = gwmi -query "select * from Win32_LogicalDisk
		 where DriveType=3" -computername $svr | select Name, FreeSpace,
		 Size
	$ld | foreach {
		$logdisk = $_

		$q = "exec [Analysis].[insLogicalDisk]"
		$q = $q + " @box_id=" + [string]$boxid
		if ($logdisk.Name.length -ne 0) {
			$q = $q + ", @Name='" + $logdisk.Name + "'"
			}
		if ($logdisk.FreeSpace.length -ne 0) {
			$q = $q + ", @FreeSpace=" + [string]$logdisk.FreeSpace
			}
		if ($logdisk.Size.length -ne 0) {
			$q = $q + ", @Size=" + [string]$logdisk.Size
			}
		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		}

	# Create an ADO.Net connection to the instance
	$cn = new-object system.data.SqlClient.SqlConnection("Data Source=$inst;Integrated Security=SSPI;Initial Catalog=master");
	$cn.Open()
	
	# Create an SMO connection to the instance
	$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $inst

	# Extract the specific instance name, and set it to MSSQLSERVER if it's the default instance
	$nm = $inst.Split("\")
	if ($nm.Length -eq 1) {
		$instnm = "MSSQLSERVER"
	} else {
		$instnm = $nm[1]
	}

	# Set the CSV output file name and pipe the instances Information collection to it
	$s.Information | foreach {
		$instinfo = $_
		
		$q = "declare @instance_id int; exec [Analysis].[insInstance]"
		$q = $q + " @instance_id OUTPUT"
		$q = $q + ", @box_id=" + [string]$boxid
		if ($instinfo.Parent.length -ne 0) {
			$q = $q + ", @Parent='" + $instinfo.Parent + "'"
			}
		if ($instinfo.Version.length -ne 0) {
			$q = $q + ", @Version='" + $instinfo.Version + "'"
			}
		if ($instinfo.EngineEdition.length -ne 0) {
			$q = $q + ", @EngineEdition='" + $instinfo.EngineEdition + "'"
			}
		if ($instinfo.Collation.length -ne 0) {
			$q = $q + ", @Collation='" + $instinfo.Collation + "'"
			}
		if ($instinfo.Edition.length -ne 0) {
			$q = $q + ", @Edition='" + $instinfo.Edition + "'"
			}
		if ($instinfo.ErrorLogPath.length -ne 0) {
			$q = $q + ", @ErrorLogPath='" + $instinfo.ErrorLogPath + "'"
			}
		if ($instinfo.IsCaseSensitive.length -ne 0) {
			$q = $q + ", @IsCaseSensitive='" + $instinfo.IsCaseSensitive + "'"
			}
		if ($instinfo.IsClustered.length -ne 0) {
			$q = $q + ", @IsClustered='" + $instinfo.IsClustered + "'"
			}
		if ($instinfo.IsFullTextInstalled.length -ne 0) {
			$q = $q + ", @IsFullTextInstalled='" + $instinfo.IsFullTextInstalled + "'"
			}
		if ($instinfo.IsSingleUser.length -ne 0) {
			$q = $q + ", @IsSingleUser='" + $instinfo.IsSingleUser + "'"
			}
		if ($instinfo.Language.length -ne 0) {
			$q = $q + ", @Language='" + $instinfo.Language + "'"
			}
		if ($instinfo.MasterDBLogPath.length -ne 0) {
			$q = $q + ", @MasterDBLogPath='" + $instinfo.MasterDBLogPath + "'"
			}
		if ($instinfo.MasterDBPath.length -ne 0) {
			$q = $q + ", @MasterDBPath='" + $instinfo.MasterDBPath + "'"
			}
		if ($instinfo.MaxPrecision.length -ne 0) {
			$q = $q + ", @MaxPrecision=" + [string]$instinfo.MaxPrecision
			}
		if ($instinfo.NetName.length -ne 0) {
			$q = $q + ", @NetName='" + $instinfo.NetName + "'"
			}
		if ($instinfo.OSVersion.length -ne 0) {
			$q = $q + ", @OSVersion='" + $instinfo.OSVersion + "'"
			}
		if ($instinfo.PhysicalMemory.length -ne 0) {
			$q = $q + ", @PhysicalMemory=" + [string]$instinfo.PhysicalMemory
			}
		if ($instinfo.Platform.length -ne 0) {
			$q = $q + ", @Platform='" + $instinfo.Platform + "'"
			}
		if ($instinfo.Processors.length -ne 0) {
			$q = $q + ", @Processors=" + [string]$instinfo.Processors
			}
		if ($instinfo.Product.length -ne 0) {
			$q = $q + ", @Product='" + $instinfo.Product + "'"
			}
		if ($instinfo.ProductLevel.length -ne 0) {
			$q = $q + ", @ProductLevel='" + $instinfo.ProductLevel + "'"
			}
		if ($instinfo.RootDirectory.length -ne 0) {
			$q = $q + ", @RootDirectory='" + $instinfo.RootDirectory + "'"
			}
		if ($instinfo.VersionString.length -ne 0) {
			$q = $q + ", @VersionString='" + $instinfo.VersionString + "'"
			}
		if ($instinfo.Urn.length -ne 0) {
			[string]$urn = $instinfo.Urn
			$q = $q + ", @Urn='" + $urn.Replace("'","''") + "'"
			}
		if ($instinfo.Properties.length -ne 0) {
			$q = $q + ", @Properties='" + $instinfo.Properties + "'"
			}
		if ($instinfo.UserData.length -ne 0) {
			$q = $q + ", @UserData='" + $instinfo.UserData + "'"
			}
		if ($instinfo.State.length -ne 0) {
			$q = $q + ", @State='" + $instinfo.State + "'"
			}
		$q = $q + "; select @instance_id as instance_id"	
		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		$instance_id = $res.instance_id
		}
	
	# Create a DataSet for our configuration information
	$ds = new-object "System.Data.DataSet" "dsConfigData"

	# Set ShowAdvancedOptions ON for the query
	$s.Configuration.ShowAdvancedOptions.ConfigValue = 1
	$s.Configuration.Alter($true)

	# Build our query to get configuration, session and lock info, and execute it
	$q = "exec sp_configure;"
	$da = new-object "System.Data.SqlClient.SqlDataAdapter" ($q, $cn)
	$da.Fill($ds)
	$cn.Close()

	# Build datatable for the config data, load from the query results
	$dtConfig = $ds.Tables[0]
	$cnfg = $dtConfig | select name, minimum, maximum, config_value, run_value
	$cnfg | foreach {
		$conf = $_
	
		$q = "exec [Analysis].[insConfiguration]"
		$q = $q + " @instance_id=" + [string]$instance_id
		if ($conf.Name.length -ne 0) {
			$q = $q + ", @Name='" + $conf.Name + "'"
			}
		if ($conf.Minimum.length -ne 0) {
			$q = $q + ", @Minimum=" + [string]$conf.Minimum
			}
		if ($conf.Maximum.length -ne 0) {
			$q = $q + ", @Maximum=" + [string]$conf.Maximum
			}
		if ($conf.Config_Value.length -ne 0) {
			$q = $q + ", @Config_Value=" + [string]$conf.Config_Value
			}
		if ($conf.Run_Value.length -ne 0) {
			$q = $q + ", @Run_Value=" + [string]$conf.Run_Value
			}
		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		}

	# Set ShowAdvancedOptions OFF now that we're done with Config
	$s.Configuration.ShowAdvancedOptions.ConfigValue = 0
	$s.Configuration.Alter($true)

	# Write the login name and default database for SQL Logins only to a CSV file
	$s.Logins | foreach {
		$login = $_
	
		$q = "exec [Analysis].[insLogins]"
		$q = $q + " @instance_id=" + [string]$instance_id
		if ($login.Name.length -ne 0) {
			$nm = $login.Name
			$q = $q + ", @Name='" + $nm.Replace("'","''") + "'"
			}
		if ($login.DefaultDatabase.length -ne 0) {
			$q = $q + ", @DefaultDatabase='" + $login.DefaultDatabase + "'"
			}
		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		}

	# Write information about the databases to a CSV file
	$dbs = $s.Databases
	
	$dbs | foreach {
		$db = $_
		if ($db.IsAccessible -eq $True) {
			$q = "declare @dbid int; exec [Analysis].[insDatabases]"
			$q = $q + " @dbid OUTPUT"
			$q = $q + ", @instance_id=" + [string]$instance_id
			if ($db.Name.length -ne 0) {
				$q = $q + ", @Name='" + $db.Name + "'"
				}
			if ($db.Collation.length -ne 0) {
				$q = $q + ", @Collation='" + $db.Collation + "'"
				}
			if ($db.CompatibilityLevel.length -ne 0) {
				$q = $q + ", @CompatibilityLevel='" + $db.CompatibilityLevel + "'"
				}
			if ($db.AutoShrink.length -ne 0) {
				$q = $q + ", @AutoShrink='" + $db.AutoShrink + "'"
				}
			if ($db.RecoveryModel.length -ne 0) {
				$q = $q + ", @RecoveryModel='" + $db.RecoveryModel + "'"
				}
			if ($db.Size.length -ne 0) {
				$q = $q + ", @Size=" + [string]$db.Size
				}
			if ($db.SpaceAvailable.length -ne 0) {
				$q = $q + ", @SpaceAvailable=" + [string]($db.SpaceAvailable / 1024)
				}
			$q = $q + "; select @dbid as dbid"	

			$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
			$dbid = $res.dbid
			}
		}
	
	
	# Create CSV files for each ErrorLog file
	# $outnm = ".\" + $svr + "\" + $instnm + "_ERL_ErrorLog.csv"
	# $s.ReadErrorLog() | export-csv -path $outnm -noType
	# $outnm = ".\" + $svr + "\" + $instnm + "_ERL_ErrorLog_1.csv"
	# $s.ReadErrorLog(1) | export-csv -path $outnm -noType
	# $outnm = ".\" + $svr + "\" + $instnm + "_ERL_ErrorLog_2.csv"
	# $s.ReadErrorLog(2) | export-csv -path $outnm -noType
	# $outnm = ".\" + $svr + "\" + $instnm + "_ERL_ErrorLog_3.csv"
	# $s.ReadErrorLog(3) | export-csv -path $outnm -noType
	# $outnm = ".\" + $svr + "\" + $instnm + "_ERL_ErrorLog_4.csv"
	# $s.ReadErrorLog(4) | export-csv -path $outnm -noType
	# $outnm = ".\" + $svr + "\" + $instnm + "_ERL_ErrorLog_5.csv"
	# $s.ReadErrorLog(5) | export-csv -path $outnm -noType
	# $outnm = ".\" + $svr + "\" + $instnm + "_ERL_ErrorLog_6.csv"
	# $s.ReadErrorLog(6) | export-csv -path $outnm -noType
}

# Get our list of target servers from the local servers.txt file
$ds = new-object "System.Data.DataSet" "dsServers"
$ds.ReadXml("C:\Demos\Module8\servers.xml")
$dtServer = new-object "System.Data.DataTable" "dtServers"
$dtServer = $ds.Tables[0]
$dtServer | foreach {
	$srv = $_
	
	# From the XML file, the Server property has the machine name and the Name property has the Instance name
	$server = $srv.Server
	$instance = $srv.Name
	
	# Ping the machine to see if it's on the network
	$results = gwmi -query "select StatusCode from Win32_PingStatus where Address = '$server'" 
	$responds = $false	
	foreach ($result in $results) {
		# If the machine responds break out of the result loop and indicate success
		if ($result.statuscode -eq 0) {
			$responds = $true
			break
		}
	}

	if ($responds) {
		# Get the server and the instance info
		getinfo $server $instance
	} else {
		# Let the user know we couldn't connect to the server
		Write-Output "$server does not respond"
	}
}
