param (
       [string] $SQLServer = "$env:computername", 
	   [string] $Database = "master"  ,
       [string] $SQLDataDir = "c:\temp"
)


Function ExportData ([Object] $SQLConnection, [Object] $SQLCmd, [string] $SQLQuery, [string] $ExportFile, [string] $TableHeader, $a )
{
# Setup table header formatting
$body = @"
<p style="font-size:25px;family:calibri;color:#7AAEEA">
$TableHeader
</p>
"@

$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SQLCmd.commandtimeout = 3600
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$nRecs = $SqlAdapter.Fill($DataSet)
$nRecs | Out-Null
#Populate Hash Table
$objTable = $DataSet.Tables[0]

#export out to html 
$objTable | select * -exclude RowError, RowState, Table, ItemArray, HasErrors | ConvertTo-HTML -head $a –body $body | Out-File $ExportFile
$SqlAdapter.dispose()
$DataSet.Dispose()

#show file
$exportfile

}


#########################################################################
## MAIN

##set HTML formatting
$a = @"
<style>
BODY{background-color:white;}
TABLE{border-width: 1px;
  border-style: solid;
  border-color: black;
  border-collapse: collapse;
}
TH{border-width: 1px;
  padding: 0px;
  border-style: solid;
  border-color: black;
  background-color:#7AAEEA
}
TD{border-width: 1px;
  padding: 0px;
  border-style: solid;
  border-color: black;
  background-color:white
}
</style>
"@

##Connection Setup
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source=$SQLServer;Initial Catalog=$Database;Integrated Security = True"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand

#############
Write-Host "--> Processing Missing Index List"

$ExportFile = "$SQLDataDir\Missing Indexes List.htm" 
$TableHeader = "Missing Indexes List"    	##The title of the HTML page

$SqlQuery = "SELECT 
  migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) AS [Improvement Measure], 
  'CREATE INDEX [missing_index_' + CONVERT (varchar, mig.index_group_handle) + '_' + CONVERT (varchar, mid.index_handle) 
  + '_' + LEFT (PARSENAME(mid.statement, 1), 32) + ']'
  + ' ON ' + mid.statement 
  + ' (' + ISNULL (mid.equality_columns,'') 
    + CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END 
    + ISNULL (mid.inequality_columns, '')
  + ')' 
  + ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS [Create Index Statement], 
  migs.user_seeks [User Seek Count], migs.avg_user_impact [Avg User Impact], avg_total_user_cost [Avg Total User Cost]
FROM sys.dm_db_missing_index_groups mig
    INNER JOIN sys.dm_db_missing_index_group_stats migs 
        ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details mid 
        ON mig.index_handle = mid.index_handle
WHERE migs.avg_total_user_cost * (migs.avg_user_impact / 100.0) * (migs.user_seeks + migs.user_scans) > 10
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) DESC"

ExportData $SQLConnection $SQLCmd $SQLQuery $ExportFile $TableHeader $a

#############
Write-Host "--> Cached Adhoc Plan With Single Use"

$ExportFile = "$SQLDataDir\Cached Adhoc Plan With Single Use.htm" 
$TableHeader = "Cached Adhoc Plan With Single Use"    	##The title of the HTML page

$SqlQuery =
"SELECT TOP(20) [text] AS [QueryText], cp.size_in_bytes [SizeInBytes] FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK) CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
WHERE cp.cacheobjtype = N'Compiled Plan' AND cp.objtype = N'Adhoc' AND cp.usecounts = 1 ORDER BY cp.size_in_bytes DESC OPTION (RECOMPILE);"  

ExportData $SQLConnection $SQLCmd $SQLQuery $ExportFile $TableHeader $a

#############

Write-Host "--> Processing SQL Statements By Top Avg CPU"

$ExportFile = "$SQLDataDir\SQL Statements By Top Avg CPU.htm" 
$TableHeader = "SQL Statements By Top Avg CPU"    	##The title of the HTML page

$SqlQuery = 
"SELECT TOP 50 
                  DB_NAME(CAST(pa.value AS INT)) 
  AS [Database Name]  ,
        qs.total_worker_time/1000 [Total CPU ms],
        qs.total_worker_time/1000/qs.execution_count as [Avg CPU Time ms], qs.execution_count as Executions,
        qs.total_elapsed_time/1000/qs.execution_count as [Avg Elapsed Time ms],
        SUBSTRING(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as [SQL Statement]
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS QueryPlans
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa 
WHERE attribute = 'dbid'
ORDER BY 
        [Avg CPU Time ms] DESC"

ExportData $SQLConnection $SQLCmd $SQLQuery $ExportFile $TableHeader $a

#############

Write-Host "--> Processing SQL Statements By Total CPU Accumulated"

$ExportFile = "$SQLDataDir\SQL Statements By Total CPU Accumulated.htm" 
$TableHeader = "SQL Statements By Total CPU Accumulated"    	##The title of the HTML page

$SqlQuery = 
"SELECT TOP 50 
                  DB_NAME(CAST(pa.value AS INT)) 
  AS [Database Name]  ,
        qs.total_worker_time/1000 [Total CPU ms],
        qs.total_worker_time/1000/qs.execution_count as [Avg CPU Time], qs.execution_count as Executions,
        qs.total_elapsed_time/1000/qs.execution_count as [Avg Elapsed Time ms],
        SUBSTRING(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as [SQL Statement]
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS QueryPlans
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa 
WHERE attribute = 'dbid'
ORDER BY 
        [Total CPU ms] DESC"

ExportData $SQLConnection $SQLCmd $SQLQuery $ExportFile $TableHeader $a

#############
Write-Host "--> Processing SQL Statements By Avg IO"

$ExportFile = "$SQLDataDir\SQL Statements By Avg IO.htm" 
$TableHeader = "SQL Statements By Average IO"    	##The title of the HTML page

$SqlQuery =  
"SELECT TOP 50 DB_NAME(CAST(pa.value AS INT)) 
  AS [Database]  , (qs.total_logical_reads + qs.total_logical_writes) [Total IOs],
        (qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count as [Avg IO], qs.execution_count as Executions, 
                qs.total_elapsed_time/1000/qs.execution_count as [Avg Elapsed Time ms],
            SUBSTRING(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as [SQL Statement]
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS QueryPlans
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa 
WHERE attribute = 'dbid'
ORDER BY 
       [Avg IO] DESC" 
ExportData $SQLConnection $SQLCmd $SQLQuery $ExportFile $TableHeader $a

#############
Write-Host "--> Processing SQL Statements By Total IO Accumulated"

$ExportFile = "$SQLDataDir\SQL Statements By Total IO Accumulated.htm" 
$TableHeader = "SQL Statements By Total Read IO Accumulated"    	##The title of the HTML page

$SqlQuery =  
"SELECT TOP 50 DB_NAME(CAST(pa.value AS INT)) 
  AS [Database Name]  , (qs.total_logical_reads + qs.total_logical_writes) [Total IOs],
        (qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count as [Avg IO], qs.execution_count as Executions, 
                qs.total_elapsed_time/1000/qs.execution_count as [Avg Elapsed Time ms],
            SUBSTRING(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as [SQL Statement] 
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS QueryPlans
OUTER APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa 
WHERE attribute = 'dbid'
ORDER BY 
      [Total IOs] DESC"

ExportData $SQLConnection $SQLCmd $SQLQuery $ExportFile $TableHeader $a
#############



#############

## Cleanup
$SqlCmd.Dispose()
$SqlConnection.Close()
$SqlConnection.Dispose()