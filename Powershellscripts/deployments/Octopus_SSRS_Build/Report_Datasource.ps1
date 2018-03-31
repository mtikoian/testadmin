$dsPath = [string]::Concat($reportFolder, "/", $reportName)
$ds = $ssrsProxy.GetItemDataSources($dsPath)
$ds | ForEach-Object {
    # Embedded Datasource
    if($_.Name -eq "dsDynamic") {
        if ($reportCredentialsUsername -ne "") {
            Write-Host "Datasource dsDynamic found. Setting credentials" 
            $_.Item.CredentialRetrieval = "Store"
            $_.Item.UserName = $reportCredentialsUsername
            $_.Item.Password = $reportCredentialsPassword
            $found = 1
        }
    # Shared Datasource
    } elseif ($_.Name -eq "dsTAS") {
        if ($SSRSSharedDataSourcePath -ne $null){
            $proxyNamespace = $ssrsProxy.GetType().Namespace
            $_.Item = New-Object("$proxyNamespace.DataSourceReference")
            $_.Item.Reference = $SSRSSharedDataSourcePath
            $found = 1
        }
    }
}
if ($found -eq 1){
    $ssrsProxy.SetItemDataSources($dsPath, $ds)
}