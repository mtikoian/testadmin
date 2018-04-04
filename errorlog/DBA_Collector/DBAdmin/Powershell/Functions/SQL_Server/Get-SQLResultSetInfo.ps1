<#

#>

function Get-SQLResultSetInfo
{

  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    [String]$Server,
    [parameter(mandatory=$true)]
    [String]$DatabaseName,
    [parameter(mandatory=$true)]
    [String]$Statement
  )
  
  $sqlDS = New-Object system.Data.DataSet
  $sqlDA = New-Object system.Data.SqlClient.SqlDataAdapter
  $sqlCMD = New-Object system.Data.SqlClient.SqlCommand
  $sqlConn = New-Object system.Data.SqlClient.SqlConnection
  
  $sqlConn.ConnectionString = "Data Source=$Server;Initial Catalog=$DatabaseName;Integrated Security=SSPI"
  
  $sqlCMD.Connection = $sqlConn
  $sqlCMD.CommandText = $Statement
  
  $sqlDA.SelectCommand = $sqlCMD
  
  
  
  try
  {
    $sqlConn.Open()
    $sqlDA.Fill($sqlDS)
   
  }
  catch
  {
    Write-Warning $_.Exception.Message
  }
  finally
  {
    if ($sqlConn.State -ne "Closed") { $sqlConn.Close() }
    $sqlConn.Dispose()
    $sqlCMD.Dispose()
    $sqlDA.Dispose()
  }
  
}