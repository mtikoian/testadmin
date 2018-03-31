<#
.SYNOPSIS 
Creates additional tempdb data files based on server core count

.DESCRIPTION
Creates 1 additional tempdb data file for each cpu core (Min 2 data files, Max 8).
http://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-1230-tempdb-should-always-have-one-data-file-per-processor-core/

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Create_Tempdb_Files.ps1 -SqlServer "SQL01" 

#>

Param ([string]$SQLServer = $env:COMPUTERNAME
)

[int]$corecount = 0;
[int]$filecount = 0;

# get cpu core count
$procs = get-wmiobject -computername $SQLServer win32_processor;
ForEach ($cpu in $procs) {
    $corecount = ($corecount + $cpu.NumberOfCores);
}
$filecount = $corecount;
    # http://www.sqlskills.com/blogs/paul/a-sql-server-dba-myth-a-day-1230-tempdb-should-always-have-one-data-file-per-processor-core/
IF ($filecount -lt 2) {
    $filecount = 2
}

IF ($filecount -gt 8) {
    $filecount = 8
}

# If running script on the sql server, set location to sql instance root
If ($SQLServer -eq $env:COMPUTERNAME) {
Set-Location SQLServer:\SQL\$env:COMPUTERNAME\Default
};

# get path for tempdb data file
$filepath = Invoke-sqlcmd -ServerInstance $SQLServer -Query "SELECT REPLACE([physical_name], '.mdf', '') AS [path] FROM tempdb.sys.database_files WHERE name = 'tempdev'";

# get file size
$filesize = Invoke-sqlcmd -ServerInstance $SQLServer -Query "SELECT [size] * 8 AS [fs] FROM tempdb.sys.database_files WHERE name = 'tempdev'";

# get file growth increment
$growthsize = Invoke-sqlcmd -ServerInstance $SQLServer -Query "SELECT [growth] * 8 AS [gs] FROM tempdb.sys.database_files WHERE name = 'tempdev'";

# create an additional tempdb data file for every 2 cpu cores (minimum 2 data files)
For ($i = 2; $i -le $filecount; $i++) {
$sqlquery = 'ALTER DATABASE [tempdb] ADD FILE (Name = N''tempdev' + $i + ''', FILENAME = ''' + $filepath.path + $i + '.ndf'', SIZE = ' + $filesize.fs + 'KB , FILEGROWTH = ' + $growthsize.gs + 'KB);'
$sqlquery;
Invoke-sqlcmd -ServerInstance $SQLServer -Query $sqlquery;
}



