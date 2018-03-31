$schema = $OctopusParameters['Schema']
$table = $OctopusParameters['Table']
$varfilter = $OctopusParameters['Filter']

$SettingsSchema = "dbo"
$SettingsTable = "SSIS_Settings"
$Filter = "SSIS"

if ($schema) {
	$SettingsSchema = $schema
}
if ($table) {
	$SettingsTable = $table
}
if ($varfilter) {
	$Filter = $varfilter
}

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $DatabaseConnection
Register-ObjectEvent -inputobject $connection -eventname InfoMessage -action {
    write-host $event.SourceEventArgs
} | Out-Null

function Execute-SqlQuery($query) {          
    $queries = [System.Text.RegularExpressions.Regex]::Split($query, "^\s*GO\s*$$", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Multiline)

    $queries | ForEach-Object {
        $q = $_
        if ((-not [String]::IsNullOrEmpty($q)) -and ($q.Trim().ToLowerInvariant() -ne "go")) {            
            $command = $connection.CreateCommand()
            $command.CommandText = $q
            $command.ExecuteNonQuery() | Out-Null
        }
    }
}

Write-Host "Connecting"
try {
    $connection.Open()

    Write-Host "Executing"
    #Execute-SqlQuery -query $OctopusParameters['SqlScript']

    $paras = Get-Variable $filter_*
	
	$CheckTableExistsElseCreate = 	"DECLARE @SettingsSchama varchar(50) = '" + $SettingsSchema + "'`n"`
									+	"DECLARE @SettingsTable varchar(50) = '" + $SettingsTable + "'`n"`
									+	"`n"`
									+	"IF ((SELECT COUNT(1) FROM sys.tables WHERE schema_name(schema_id) = @SettingsSchama AND name = @SettingsTable) < 1)`n"`
									+	"BEGIN`n"`
									+	"	CREATE TABLE [" + $SettingsSchema + "].[" + $SettingsTable + "](`n"`
									+	"		[ConfigurationFilter]	[nvarchar](255)	NOT NULL`n"`
									+	"		,[ConfiguredValue]		[nvarchar](255)	NULL`n"`
									+	"		,[PackagePath]			[nvarchar](255)	NOT NULL`n"`
									+	"		,[ConfiguredValueType]	[nvarchar](20)	NOT NULL`n"`
									+	"	);`n"`
									+	"	EXECUTE sp_addextendedproperty @name = 'MS_Description', @value = N'Filter', @level0type = 'SCHEMA', @level0name = @SettingsSchama, @level1type = N'TABLE', @level1name = @SettingsTable, @level2type = N'COLUMN', @level2name = 'ConfigurationFilter';`n"`
									+	"	EXECUTE sp_addextendedproperty @name = 'MS_Description', @value = N'The actual value', @level0type = 'SCHEMA', @level0name = @SettingsSchama, @level1type = N'TABLE', @level1name = @SettingsTable, @level2type = N'COLUMN', @level2name = 'ConfiguredValue';`n"`
									+	"	EXECUTE sp_addextendedproperty @name = 'MS_Description', @value = N'Path within the package - such as \Package.Variables[User::CustomVar].Properties[Value]', @level0type = 'SCHEMA', @level0name = @SettingsSchama, @level1type = N'TABLE', @level1name = @SettingsTable, @level2type = N'COLUMN', @level2name = 'PackagePath';`n"`
									+	"	EXECUTE sp_addextendedproperty @name = 'MS_Description', @value = N'Field type - such as string', @level0type = 'SCHEMA', @level0name = @SettingsSchama, @level1type = N'TABLE', @level1name = @SettingsTable, @level2type = N'COLUMN', @level2name = 'ConfiguredValueType';`n"`
									+	"END`n"
									+	"GO`n"
	
	Execute-SqlQuery -query $CheckTableExistsElseCreate
	
    foreach ($para in $paras)
    {
        $name = $para.Name
        $namePts = $name -split "_"
      
        Write-Host "  - $name"

        $filter = $namePts[1]
        $value = $para.Value
        $path = "\Package.Variables[User::" + $namePts[2] + "].Properties[Value]"
        $type = "String"
    
        $InsertSetting = "INSERT INTO [" + $SettingsSchema + "].["+ $SettingsTable +"]`n"`
            + "(`n"`
            + "   [ConfigurationFilter],[ConfiguredValue],[PackagePath],[ConfiguredValueType]`n"`
            + ")`n"`
            + "VALUES`n"`
            + "(`n"`
            + "   '$filter','$value','$path','$type'`n"`
            + ")`n"`
            + "GO"
            
        Execute-SqlQuery -query $InsertSetting
    }

}
finally {
    Write-Host "Closing connection"
    $connection.Dispose()
}