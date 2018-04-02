#Load command-line parameters - if they exist
param ([string]$sqlserver, [string]$filename)

#Reference RMO Assembly
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Replication") | out-null
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Rmo") | out-null

$TableQuery = "SELECT DISTINCT @@servername as Server
	FROM sys.Databases
	WHERE Name LIKE '%distribution%'
	ORDER BY 1"

function Run-Query()
{
	param (
	$SqlQuery,
	$SqlServer,
	$SqlCatalog
	)
	
	$SqlConnection = New-Object System.Data.SqlClient.SqlConnection("Data Source=DBDEVACAN201\JDN;Integrated Security=SSPI;Initial Catalog=Status;");
	
	$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
	$SqlCmd.CommandText = $SqlQuery
	$SqlCmd.Connection = $SqlConnection
	
	$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
	$SqlAdapter.SelectCommand = $SqlCmd
	
	$DataSet = New-Object System.Data.DataSet
	$a = $SqlAdapter.Fill($DataSet)
	
	$SqlConnection.Close()
	
	$DataSet.Tables | Select-Object -ExpandProperty Rows
}

function errorhandler([string]$errormsg)
{
    writetofile ("Replication Script Generator run at: " + (date)) $filename 1
    writetofile ("[Replication Script ERROR] " + $errormsg) $filename 0
    write-host("[Replication Script ERROR] " + $errormsg) -Foregroundcolor Red
}

function writetofile([string]$text, [string]$myfilename, [int]$cr_prefix)
{
    if ($cr_prefix -eq 1) { "" >> $myfilename }
    $text >> $myfilename
}

function initializefile([string]$myfilename)
{
    "" > $myfilename
}

#trap {errorhandler($_); Break}

$Servers = Run-Query -SqlQuery $TableQuery | Select-Object -Property Server

Clear-host

foreach($server in $Servers)
{


	$filename = "D:\Scripts\ReplicationBackupScript_" + $($server.server) + ".sql"
	initializefile $filename
	
	$repsvr = New-Object "Microsoft.SqlServer.Replication.ReplicationServer" $($server.server)

	# if we don't have any replicated databases then there's no point in carrying on
	if ($repsvr.ReplicationDatabases.Count -eq 0)
	{
	    writetofile ("Replication Script Generator run at: " + (date)) $filename 0
	    writetofile "ZERO replicated databases on $($server.server)!!!" $filename 1
	}

	# similarly, if we don't have any publications then there's no point in carrying on
	[int] $Count_Tran_Pub = 0
	[int] $Count_Merge_Pub = 0

	foreach($replicateddatabase in $repsvr.ReplicationDatabases)
	{
	        $Count_Tran_Pub = $Count_Tran_Pub + $replicateddatabase.TransPublications.Count
	        $Count_Merge_Pub = $Count_Merge_Pub + $replicateddatabase.MergePublications.Count
	}

	if (($Count_Tran_Pub + $Count_Merge_Pub) -eq 0)
	{
	    writetofile ("Replication Script Generator run at: " + (date)) $filename 0
	    writetofile "ZERO Publications on $($server.server)!!!" $filename 1
	}

	# if we got this far we know that there are some publications so we'll script them out
	# the $scriptargs controls exactly what the script contains
	# for a full list of the $scriptargs see the end of this script
	$scriptargs = [Microsoft.SqlServer.Replication.scriptoptions]::Creation `
	-bor  [Microsoft.SqlServer.Replication.scriptoptions]::IncludeArticles `
	-bor  [Microsoft.SqlServer.Replication.scriptoptions]::IncludePublisherSideSubscriptions `
	-bor  [Microsoft.SqlServer.Replication.scriptoptions]::IncludeSubscriberSideSubscriptions

	writetofile ("Replication Script Generator run at: " + (date)) $filename 0
	writetofile " PUBLICATIONS ON $($server.server)" $filename 1
	writetofile " TRANSACTIONAL PUBLICATIONS ($Count_Tran_Pub)" $filename 1

	foreach($replicateddatabase in $repsvr.ReplicationDatabases)
	{
	    if ($replicateddatabase.TransPublications.Count -gt 0)
	    {
	        foreach($tranpub in $replicateddatabase.TransPublications)
	        {
	            write-host "********************************************************************************" -Foregroundcolor Blue
	            "***** Writing to file script for publication: " + $tranpub.Name
	            write-host "********************************************************************************" -Foregroundcolor Blue
	            writetofile "********************************************************************************" $filename 0
	            writetofile ("***** Writing to file script for publication: " + $tranpub.Name) $filename 0
	            writetofile "********************************************************************************" $filename 0
	            [string] $myscript=$tranpub.script($scriptargs) 
	            writetofile $myscript $filename 0
	        }
	    }
	}

	writetofile " MERGE PUBLICATIONS ($Count_Merge_Pub)" $filename 1
	writetofile "" $filename 0

	foreach($replicateddatabase in $repsvr.ReplicationDatabases)
	{
	    if ($replicateddatabase.MergePublications.Count -gt 0)
	    {
	        foreach($mergepub in $replicateddatabase.MergePublications)
	        {
	            write-host "********************************************************************************" -Foregroundcolor Blue
	            "***** Writing to file script for publication: " + $mergepub.Name
	            write-host "********************************************************************************" -Foregroundcolor Blue
	            writetofile "********************************************************************************" $filename 0
	            writetofile ("***** Writing to file script for publication: " + $mergepub.Name) $filename 0
	            writetofile "********************************************************************************" $filename 0
	            [string] $myscript=$mergepub.script($scriptargs) 
	            writetofile $myscript $filename 0
	        }
	    }
	}
}