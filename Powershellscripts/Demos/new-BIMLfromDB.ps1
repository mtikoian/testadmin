<#
.Synopsis
   Generates BIML script to create SSIS packages from source to destination database
.DESCRIPTION
   This script will generate a BIML (Business Intelligence Markup Language) to create
   SSIS packages for each table in the source database to corresponding staging tables
   in the destination database.  Using the BIDSHelper add-on to SQL Server Data Tools,
   the BIML script will then generate a separate package for each table which will move
   updates from the source database into the destination database.
.EXAMPLE
   ./new-BIMLfromDB.ps1 $srcinst=WS12SQL $srcdb=Northwind $dstinst=WS12SQL\TEST01 $destdb=NorthwindDW $file=c:\Workdir\NorthwindDW.biml
#>
# Get the parameters from the command line
[CmdletBinding()]
param(
  # srcinst is the source SQL Server instance
  [Parameter(Mandatory=$true)]
  [string]$srcinst=$null,
  # srcdb is the source database name
  [Parameter(Mandatory=$true)]
  [string]$srcdb=$null,
  # dstinst is the destination SQL Server instance
  [Parameter(Mandatory=$true)]
  [string]$dstinst=$null,
  # dstdb is the destination database name
  [Parameter(Mandatory=$true)]
  [string]$dstdb=$null,
  # file is the fully qualified BIML file name
  [Parameter(Mandatory=$true)]
  [string]$file=$null
  )

# Handle any errors that occur
Trap {
  # Handle the error
  $err = $_.Exception
  write-output $err.Message
  while( $err.InnerException ) {
  	$err = $err.InnerException
  	write-output $err.Message
  	};
  # End the script.
  break
  }

# Test to see if the SQLPS module is loaded, and if not, load it
if (-not(Get-Module -name 'SQLPS')) {
  if (Get-Module -ListAvailable | Where-Object {$_.Name -eq 'SQLPS' }) {
    Push-Location # The SQLPS module load changes location to the Provider, so save the current location
	Import-Module -Name 'SQLPS' -DisableNameChecking
	Pop-Location # Now go back to the original location
    }
  }

# Connect to the source instance and connect to the source database
$srv = new-object ('Microsoft.SqlServer.Management.Smo.Server') $srcinst
$sdb = $srv.Databases[$srcdb]

# Connect to the destination instance and destination to the source database
$dst = new-object ('Microsoft.SqlServer.Management.Smo.Server') $dstinst
$ddb = $srv.Databases[$dstdb]

# Get the table dependencies from the destination database
$q = @'
SELECT [SourceSchema]
      ,[SourceTable]
      ,[DestSchema]
      ,[DestTable]
      ,[KeyColumn]
  FROM [dbo].[Dependencies]
'@
$dep = Invoke-Sqlcmd -ServerInstance $dstinst -Database $dstdb -Query $q

# Initialize the BIML file and set its properties
$biml = New-Object System.Xml.XmlTextWriter($file,$null)
$biml.Formatting = 'Indented'
$biml.Indentation = 1
$biml.IndentChar = "`t"
$biml.WriteStartElement('Biml')
$biml.WriteAttributeString('xmlns',"http://schemas.varigence.com/biml.xsd")

# Add the connections for the source and destination instances and databases
$srcconn = "Data Source=$srcinst;Initial Catalog=$srcdb;Provider=SQLNCLI11.1;Integrated Security=SSPI;"
$dstconn = "Data Source=$dstinst;Initial Catalog=$dstdb;Provider=SQLNCLI11.1;Integrated Security=SSPI;"

$biml.WriteStartElement('Connections')	# Start the Connections tag
$biml.WriteStartElement('Connection')	# Start the source database connection
$biml.WriteAttributeString('Name',$srcdb)
$biml.WriteAttributeString('ConnectionString',$srcconn)
$biml.WriteEndElement()			# End source database connection

$biml.WriteStartElement('Connection')	# Start the destination database connection
$biml.WriteAttributeString('Name',$dstdb)
$biml.WriteAttributeString('ConnectionString',$dstconn)
$biml.WriteEndElement()			# End destination database connection
$biml.WriteEndElement()			# End Connections

$biml.WriteStartElement('Packages')	# Start the Packages tag

# Because not every table is updated, get those that are from the Dependencies table
Foreach ($d in $dep) {
	$srcnm = $d.SourceTable
	$srcsch = $d.SourceSchema
	$dstnm = $d.DestTable
	$dstsch = $d.DestSchema
	$keycol = $d.KeyColumn
	$pkgnm = $srcdb + '_' + $srcnm
	
	# Get the table objects for the source and destination tables
	$stbl = $sdb.Tables | where-object {$_.Name -eq $srcnm -and $_.Schema -eq $srcsch}
	$dtbl = $ddb.Tables | where-object {$_.Name -eq $dstnm -and $_.Schema -eq $dstsch}

	# Build a collection of the columns that exist in both source and destination tables
	$col = @()	# Empty Collection to store matching column names
	foreach ($c in $stbl.Columns) {
		$colnm = $c.Name
		$dcol = $dtbl.Columns[$colnm]	# Verify that the destination column exists
		if ($dcol.Count -gt 0) {
			$mcol = New-Object System.Object
			$mcol | Add-Member -type NoteProperty -name Name -value $colnm
			$col += $mcol
			}
		}
	
	# Build the query to pull the data from the source table
	$srcq = 'SELECT '
	$ccnt = $col.Count
	$cctr = 0
	foreach ($c in $col) {
		$srcq += $c.Name
		$cctr++
		if ($cctr -ne $ccnt) {
			$srcq += ', '
			}
		}
	$srcq += ' FROM [' + $dstsch + '].[' + $dstnm + ']'

	$biml.WriteStartElement('Package')	# Start the source table package
	$biml.WriteAttributeString('Name',$pkgnm)
	$biml.WriteAttributeString('ConstraintMode','Parallel')
	$biml.WriteAttributeString('ProtectionLevel','EncryptSensitiveWithUserKey')
	$biml.WriteStartElement('Tasks')	# Start the Tasks tag

	# Clear the Staging table for the source table	
	$biml.WriteStartElement('ExecuteSQL')	# Start the ExecuteSQL tag
	$biml.WriteAttributeString('Name','Truncate Staging_' + $srcnm)
	$biml.WriteAttributeString('ConnectionName',$dstdb)
	$biml.WriteStartElement('DirectInput')	# Start the DirectInput tag
	$biml.WriteValue("TRUNCATE TABLE [Staging].[$dstnm]")
	$biml.WriteEndElement()			# End DirectInput
	$biml.WriteEndElement()			# End ExecuteSQL
	
	# Start the DataFlow Task
	$biml.WriteStartElement('Dataflow')	# Start the Dataflow tag
	$biml.WriteAttributeString('Name','Load ' + $srcnm)
	$biml.WriteStartElement('PrecedenceConstraints')	# Start the PrecedenceConstraints tag
	$biml.WriteStartElement('Inputs')	# Start the Inputs tag
	$biml.WriteStartElement('Input')	# Start the Input tag
	$biml.WriteAttributeString('OutputPathName','Truncate Staging_' + $srcnm + '.Output')
	$biml.WriteEndElement()			# End Input
	$biml.WriteEndElement()			# End Inputs
	$biml.WriteEndElement()			# End PrecedenceConstraints
	
	$biml.WriteStartElement('Transformations')	# Start the Transformations tag
	$biml.WriteStartElement('OleDbSource')	# Start the OleDbSource tag
	$biml.WriteAttributeString('Name',"$srcnm Source")
	$biml.WriteAttributeString('ConnectionName',$srcdb)
	$biml.WriteStartElement('ExternalTableInput')	# Start the ExternalTableInput tag
	$biml.WriteAttributeString('Table',"[$srcsch].[$srcnm]")
	$biml.WriteEndElement()			# End ExternalTableInput
	$biml.WriteEndElement()			# End OleDbSource

	$biml.WriteStartElement('Lookup')	# Start the Lookup tag
	$biml.WriteAttributeString('Name','Correlate')
	$biml.WriteAttributeString('OleDbConnectionName',$dstdb)
	$biml.WriteAttributeString('NoMatchBehavior','RedirectRowsToNoMatchOutput')
	$biml.WriteStartElement('InputPath')	# Start the InputPath tag
	$biml.WriteAttributeString('OutputPathName',"$srcnm Source.Output")
	$biml.WriteEndElement()			# End InputPath
	$biml.WriteStartElement('DirectInput')	# Start the DirectInput tag
	
	# Include the query from the source table we built earlier
	$biml.WriteValue($srcq)
	$biml.WriteEndElement()			# End DirectInput
	$biml.WriteStartElement('Inputs')	# Identify the Key Column
	$biml.WriteStartElement('Column')	# Identify the Key Column Attributes
	$biml.WriteAttributeString('SourceColumn',$keycol)
	$biml.WriteAttributeString('TargetColumn',$keycol)
	$biml.WriteEndElement()			# End Column
	$biml.WriteEndElement()			# End Inputs
	$biml.WriteStartElement('Outputs')	# Identify the rest of the columns
	Foreach ($c in $col) {
		if ($c.Name -ne $keycol) {
			$cnm = $c.Name
			$biml.WriteStartElement('Column')	# Identify the Column Attributes
			$biml.WriteAttributeString('SourceColumn',$cnm)
			$biml.WriteAttributeString('TargetColumn',"Dest_$cnm")
			$biml.WriteEndElement()			# End Column
			}
		}
	$biml.WriteEndElement()			# End Outputs
	$biml.WriteEndElement()			# End Lookup

	$biml.WriteStartElement('OleDbDestination')	# Start the OleDbDestination tag
	$biml.WriteAttributeString('Name',"$srcnm Destination")
	$biml.WriteAttributeString('ConnectionName',$dstdb)
	$biml.WriteStartElement('InputPath')	# Start the InputPath tag
	$biml.WriteAttributeString('OutputPathName','Correlate.NoMatch')
	$biml.WriteEndElement()			# End InputPath
	$biml.WriteStartElement('ExternalTableOutput')	# Start the InputPath tag
	$biml.WriteAttributeString('Table',"$dstsch.$dstnm")
	$biml.WriteEndElement()			# End ExternalTableOutput
	$biml.WriteEndElement()			# End OleDbDestination
	$biml.WriteStartElement('ConditionalSplit')	# Start the ConditionalSplit tag
	$biml.WriteAttributeString('Name','Filter')
	$biml.WriteStartElement('InputPath')	# Start the InputPath tag
	$biml.WriteAttributeString('OutputPathName','Correlate.Match')
	$biml.WriteEndElement()			# End InputPath
	$biml.WriteStartElement('OutputPaths')	# Start the OutputPaths tag
	$biml.WriteStartElement('OutputPath')	# Start the OutputPath tag
	$biml.WriteAttributeString('Name','Changed Rows')
	$biml.WriteStartElement('Expression')	# Start the Expression tag
	
	# The expression tests each non-key column for inequality from destination table
	$exp = '('
	$ccnt = $col.Count
	$cctr = 0
	foreach ($c in $col) {
		$cctr++
		if ($c.Name -ne $keycol) {
			$cnm = $c.Name
			$exp += $cnm + ' != Dest_' + $cnm
			if ($cctr -ne $ccnt) {
				$exp += ') || ('
				}
			}
		}
	$exp += ')'
	
	$biml.WriteValue($exp)
	$biml.WriteEndElement()			# End Expression
	$biml.WriteEndElement()			# End OutputPath
	$biml.WriteEndElement()			# End OutputPaths
	$biml.WriteEndElement()			# End ConditionalSplit

	# Send the rows that are different to the staging table
	$biml.WriteStartElement('OleDbDestination')	# Start the OleDbDestination tag
	$biml.WriteAttributeString('Name',"Staging Updates")
	$biml.WriteAttributeString('ConnectionName',$dstdb)
	$biml.WriteStartElement('InputPath')	# Start the InputPath tag
	$biml.WriteAttributeString('OutputPathName','Filter.Changed Rows')
	$biml.WriteEndElement()			# End InputPath
	$biml.WriteStartElement('ExternalTableOutput')	# Start the InputPath tag
	$biml.WriteAttributeString('Table',"Staging.$dstnm")
	$biml.WriteEndElement()			# End ExternalTableOutput
	$biml.WriteEndElement()			# End OleDbDestination

	$biml.WriteEndElement()			# End Transformations
	
	$biml.WriteEndElement()			# End Dataflow
	
	# Set up the Execute SQL task to batch update from the Staging table
	$biml.WriteStartElement('ExecuteSQL')	# Start the ExecuteSQL tag
	$biml.WriteAttributeString('Name','Apply Staging Updates')
	$biml.WriteAttributeString('ConnectionName',$dstdb)

	$biml.WriteStartElement('PrecedenceConstraints')	# Start the PrecedenceConstraints tag
	$biml.WriteStartElement('Inputs')	# Start the Inputs tag
	$biml.WriteStartElement('Input')	# Start the Input tag
	$biml.WriteAttributeString('OutputPathName','Load ' + $srcnm + '.Output')
	$biml.WriteEndElement()			# End Input
	$biml.WriteEndElement()			# End Inputs
	$biml.WriteEndElement()			# End PrecedenceConstraints

	$biml.WriteStartElement('DirectInput')	# Start the DirectInput tag
	
	# Build the batch update query from the Staging table to the destination
	$dstq = @'
UPDATE d SET 

'@
	$ccnt = $col.Count
	$cctr = 0
	foreach ($c in $col) {
		$cctr++
		if ($c.Name -ne $keycol) {
			$cnm = $c.Name
			$dq = @"
d.$cnm = s.$cnm

"@
			$dstq += $dq
			if ($cctr -ne $ccnt) {
				$dstq += ', '
				}
			}
		}
	$dstq += @"
FROM $dstsch.$dstnm d
INNER JOIN Staging.$dstnm s ON d.$keycol = s.$keycol

"@
	$biml.WriteValue($dstq)
	
	$biml.WriteEndElement()			# End DirectInput
	$biml.WriteEndElement()			# End ExecuteSQL
	
	
	$biml.WriteEndElement()			# End Tasks
	$biml.WriteEndElement()			# End Package
	}

# Create a master package to call the others
$biml.WriteStartElement('Package')	# Start the source table package
$biml.WriteAttributeString('Name',$srcdb + '_Master')
$biml.WriteAttributeString('ConstraintMode','Parallel')
$biml.WriteAttributeString('ProtectionLevel','EncryptSensitiveWithUserKey')
$biml.WriteStartElement('Tasks')	# Start the Tasks tag
$biml.WriteStartElement('Container')	# Start the Container tag
$biml.WriteAttributeString('Name',$srcdb + '_ETL')
$biml.WriteAttributeString('ConstraintMode','Parallel')
$biml.WriteStartElement('Tasks')	# Start the Tasks tag

# Now cycle through the tables to execute the table package
foreach ($d in $dep) {
	$srcnm = $d.SourceTable
	$biml.WriteStartElement('ExecutePackage')	# Start the ExecutePackage tag
	$biml.WriteAttributeString('Name',"$srcnm")
	$biml.WriteStartElement('ExternalProjectPackage')	# Start the ExternalProjectPackage tag
	$biml.WriteAttributeString('Package',$srcdb + '_' + $srcnm + '.dtsx')
	$biml.WriteEndElement()			# End ExternalProjectPackage
	$biml.WriteEndElement()			# End ExecutePackage
	}

$biml.WriteEndElement()			# End Tasks
$biml.WriteEndElement()			# End Container
$biml.WriteEndElement()			# End Tasks
$biml.WriteEndElement()			# End Package
$biml.WriteEndElement()			# End Packages
$biml.WriteEndElement()			# End Biml
$biml.Flush()
$biml.Close()
