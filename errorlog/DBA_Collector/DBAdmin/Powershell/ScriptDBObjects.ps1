param 
(
	$Server = "EDEVSQL2K8R2-02.ctc.seic.com",
	$Database = "DBAREPOS",
	$Path = "C:\Users\JFEIER~1\AppData\Local\Temp\DBARepos",
	$Schema = 'dba'
)

#Load the SMO assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null;

#Connect to the server
$SMOServer = New-Object Microsoft.SqlServer.Management.Smo.Server $Server;
$db = $SMOServer.Databases[$Database];

#Initialise the Scripter object
$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter $SMOServer;

function Script-Schema()
{

	#Retrieve schema in question
	$schemaObj = $db.Schemas[$Schema]

	#Set Script options
	$scripter.Options.Default = $true;
	$scripter.Options.ScriptOwner = $true;
	
	#Script the object
	$scripter.Options.FileName = "$Path\$Schema.sql";
	$scripter.Script($schemaObj);
}

function Script-ForeignKeys()
{
	#Retrieve all tables
	$tables = $db.Tables;

	#Set table specific scripter options
	$scripter.Options.Default = $false;
	$scripter.Options.IncludeIfNotExists = $true;
	$scripter.Options.DriChecks = $false;
	$scripter.Options.DriClustered = $false;
	$scripter.Options.DriDefaults = $false;
	$scripter.Options.DriForeignKeys = $true;
	$scripter.Options.DriIndexes = $false;
	$scripter.Options.DriUniqueKeys = $false;
	$scripter.Options.DriPrimaryKey = $false;
	$scripter.Options.DriNonClustered = $false;
	$scripter.Options.Indexes = $false;

	#Script all tables
	if ((Test-Path "$Path\FK") -eq $false)
	{
		New-Item -ItemType "Directory" -Path "$Path\FK";
	}
	foreach ($table in $tables)
	{
		if (($table.Schema -eq $Schema) -and ($table.ForeignKeys.Count -gt 0))
		{
			$fileName = $Path + "\FK\" + $table.Schema + "_" + $table.Name + ".sql";
			$scripter.Options.FileName = $fileName;
			$scripter.Script($table);
		}
	}
	
	$tables = $null;
}

function Script-Tables()
{
	#Retrieve all tables
	$tables = $db.Tables;

	#Set table specific scripter options
	$scripter.Options.Default = $true;
	$scripter.Options.IncludeIfNotExists = $true;
	$scripter.Options.DriChecks = $true;
	$scripter.Options.DriClustered = $true;
	$scripter.Options.DriDefaults = $false;
	$scripter.Options.DriForeignKeys = $false;
	$scripter.Options.DriIndexes = $true;
	$scripter.Options.DriUniqueKeys = $true;
	$scripter.Options.DriPrimaryKey = $true;
	$scripter.Options.DriNonClustered = $true;
	$scripter.Options.Indexes = $true;

	#Script all tables
	if ((Test-Path "$Path\Tables") -eq $false)
	{
		New-Item -ItemType "Directory" -Path "$Path\Tables";
	}
	foreach ($table in $tables)
	{
		if ($table.Schema -eq $Schema)
		{
			$fileName = $Path + "\Tables\" + $table.Schema + "_" + $table.Name + ".sql";
			$scripter.Options.FileName = $fileName;
			$scripter.Script($table);
		}
	}
	
	$tables = $null;
}

function Script-Procs()
{
	
	#Retrieve all procedures
	$procs = $db.StoredProcedures;
	
	#Set scripter options
	$scripter.Options.Default = $true;
	
	#Script the objects
	if ((Test-Path -Path "$Path\Procedures") -eq $false)
	{
		New-Item "$Path\Procedures" -ItemType "Directory";
	}
	
	foreach ($proc in $procs)
	{
	
		if ($proc.Schema -eq $Schema)
		{
			$scripter.Options.FileName = "$Path\Procedures\" + $proc.Schema + "_" + $proc.Name + ".sql";
			$scripter.Script($proc);
		}
	}
	
	$procs = $null;
	
}


Script-Schema;
Script-Tables;
Script-Procs;
Script-ForeignKeys;

$db = $null;
$SMOServer = $null;
#$scripter = $null;