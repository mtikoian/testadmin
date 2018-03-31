function Invoke-UdfSQLStatement
{ 
 [CmdletBinding()]
        param (
              [string]$Server,
              [string]$Database,
              [string]$SQL,
              [switch]$IsSelect
          )

  Write-Verbose "open connecton"

  $conn = new-object System.Data.SqlClient.SqlConnection("Data Source=$Server;Integrated Security=SSPI;Initial Catalog=$Database");

  $conn.Open()

  $command = new-object system.data.sqlclient.Sqlcommand($SQL,$conn)

  if ($IsSelect) 
  { 
     
     $adapter = New-Object System.Data.sqlclient.SqlDataAdapter $command
     $dataset = New-Object System.Data.DataSet
     $adapter.Fill($dataset) | Out-Null
     $conn.Close()
     RETURN $dataset.tables[0] 
  }
  Else
  {
     $command.ExecuteNonQuery()
     $conn.Close()
  }
}

<# Example call 

Invoke-UdfSQLStatement -Server '(local)' -Database 'Development' -SQL 'select top 10 * from dbo.orders' -IsSelect 

Using Configurations...

Get-UdfConfiguation "EDWServer"

Invoke-UdfSQLStatement -Server (Get-UdfConfiguation "EDWServer") -Database 'Development' -SQL 'select top 10 * from dbo.orders' -IsSelect 


#>
