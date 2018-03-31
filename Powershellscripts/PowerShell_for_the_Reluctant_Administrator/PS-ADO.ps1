#  ptp  20150602  Involta ADO functions

Function Get-ADOQueryResult {
<#
.Synopsis
Get-ADOQueryResult executes an ADO command which returns the ADO result set

.Description
Get-ADOQueryResult gives PowerShell scripts easy access to retrieve the data 
stored in ADO data sources (primarily Microsoft SQL Server).  See the examples.

.Parameter cn
An open ADO connection that will be used to process this ADO command

.Parameter QueryStmt
An ADO query (usually SQL) to execute that will return a result set.

.Outputs
An un-named System.Data.DataTable object which contains the first result set
returned by the ADO query passed in via the QueryStmt parameter

.Example
$mydb = Open-ADOConnection -Instance '.\SQL2012'

$q = @"
SELECT TOP 3 object_id, name
   FROM sys.objects
"@

Get-ADOQueryResult -cn $mydb -QueryStmt $q |
   Select-Object object_id, name |
   Format-List

$mydb.close()

A simple script to get three object names and id values from a SQL Server
#>
   Param(
   [Parameter(Mandatory = $True,
   ValueFromPipelineByPropertyName = $True,
   HelpMessage = 'An open System.Data.SqlClient.SqlConnection .NET object')]
   [System.Data.SqlClient.SqlConnection]
   $cn,
   [String]
   [parameter(ValueFromPipelineByPropertyName = $True,
   HelpMessage = 'Query string that will return a result set')]
   $QueryStmt = 'SELECT ''Default query'' AS Default_Query'
   )
   Process {
   $dbcmd = New-Object System.Data.SqlClient.SqlCommand;
   $dbcmd.CommandText = $QueryStmt;
   $dbcmd.Connection = $cn;

   $dbsda = New-Object System.Data.SqlClient.SqlDataAdapter;
   $dbsda.SelectCommand = $dbcmd;
   $DataSet = New-Object System.Data.DataSet;

   $dbsda.Fill($DataSet);
   $DataSet.Tables[0];
   }
}

Function Invoke-ADOCommand {
<#
.Synopsis
Invoke-ADOCommand executes an ADO command which does not return any ADO result set

.Description
Get-ADOQueryResult gives PowerShell scripts easy access to manage the data 
stored in ADO data sources (primarily Microsoft SQL Server).  See the examples.

.Parameter cn
An open ADO connection that will be used to process this ADO command

.parameter CommandText
An ADO command that does not return any result set

.Outputs
System.Int32 which contains the number of rows affected. -1 if no rows were affected.

Note that this count includes any rows affected by triggers!

.Example
$mydb = Open-ADOConnection -Instance '.\SQL2012'

$q = @"
CREATE TABLE #foo (
   id           INT         NOT NULL
   CONSTRAINT XPK_foo PRIMARY KEY (id)
,  name         VARCHAR(50) NOT NULL
)
"@

Invoke-ADOCommand -CN $mydb -CommandText $q

$mydb.close()

A simple ADO/MSSQL script to create a temporary table named #foo
#>
   Param(
   [Parameter(Mandatory = $True,
   ValueFromPipelineByPropertyName = $True,
   HelpMessage = 'An open System.Data.SqlClient.SqlConnection .NET object')]
   [System.Data.SqlClient.SqlConnection]
   $cn,
   [String]
   [parameter(ValueFromPipelineByPropertyName = $True,
   HelpMessage = 'Query string that does not return any result set')]
   $CommandText
   )
   Process {
   $cmd = new-object System.Data.SqlClient.SqlCommand
   $cmd.CommandText = $CommandText;
   $cmd.Connection = $cn;
   $cmd.ExecuteNonQuery();
   }
}

Function Open-ADOConnection {
<#
.Synopsis
Open-ADOConnection creates, initializes, and opens a .NET System.Data.SqlClient.SqlConnection object

.Description
Open-ADOConnection wraps the .NET ADO framework in a PowerShell function/commandlette 
to make ADO connections feel more PowerShell-friendly

.Parameter Instance
A string with the name of the ADO (presumably MSSQL) Instance

.Parameter Catalog
The ADO catalog name.

.Outputs
An un-named System.Data.SqlClient.SqlConnection object that should be open and ready to use.
#>
   Param(
   [parameter(Mandatory=$True,
   ValueFromPipelineByPropertyName = $True,
   HelpMessage = 'Name of the SQL instance.')]
   [String]
   $Instance,
   [parameter(ValueFromPipelineByPropertyName = $True,
   HelpMessage = 'Name of the SQL instance.')]
   [String]
   $Catalog = 'master'
   )
   Process {
   $cn = new-object System.Data.SqlClient.SqlConnection("Data Source=$Instance;Integrated Security=SSPI;Initial Catalog=$Catalog");
   $cn.Open()
   $cn
   }
}
