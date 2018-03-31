cls

$connectionString = "Provider=SQLOLEDB.1;Integrated Security=SSPI;PersistSecurity Info=False;Initial Catalog=AdventureWorks2014;Data Source=localhost"
$query = "EXEC dbo.GetSalesSalesOrderHeaderSlow 282"

$OLEDBConnection = New-Object System.Data.OleDb.OleDbConnection($connectionString)
$OLEDBConnection.open()

$readcmd = New-Object system.Data.OleDb.OleDbCommand($query,$OLEDBConnection)
#$readcmd.CommandTimeout = '300'
$readcmd.CommandTimeout = '5'

$da = New-Object system.Data.OleDb.OleDbDataAdapter($readcmd)
$dataTable = New-Object system.Data.datatable
[void]$da.fill($dataTable)

$dataTable.Rows.Count

$OLEDBConnection.close()

