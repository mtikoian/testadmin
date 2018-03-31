# Load SMO
[System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')  | out-null

$Server = 'dbinsight01'
$SMOServer = New-Object Microsoft.SQLServer.Management.SMO.Server $Server

# connection and query stuff        
$ConnectionStr = "Server=$Server;Integrated Security=True"
$Query = "SELECT TOP 50 DB_NAME(CAST(pa.value AS INT)) 
  AS [Database Name]  , (qs.total_logical_reads + qs.total_logical_writes) [Total IOs],
        (qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count as [Avg IO], qs.execution_count as Executions, 
                qs.total_elapsed_time/1000/qs.execution_count as [Avg Elapsed Time ms],
            SUBSTRING(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as [SQL Statement],
		qt.dbid, dbname=db_name(qt.dbid)

FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS QueryPlans
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa 
WHERE attribute = 'dbid'
ORDER BY 
      [Total IOs] DESC
"		

$Connection = new-object system.Data.SQLClient.SQLConnection
$Table = new-object "System.Data.DataTable"

$Connection.connectionstring = $ConnectionStr

$Connection.open()
$Command = $Connection.CreateCommand()
$Command.commandtext = $Query

$result = $Command.ExecuteReader()

$Table.Load($result)

## output to grid
$Title = "Top 20 SQL by Total IO  (" + $Table.Rows.Count + ")"
$Table | Out-GridView -Title $Title


$Connection.close()