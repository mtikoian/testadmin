<#
.SYNOPSIS
The script uses the free SQLIO tool to test a storage subsystem and outputs the results into a .csv file.
.PARAMETER Filepath
The path to place the test file at.
.PARAMETER Filesize
The size (in megabytes) of the test file.
.PARAMETER Outfile
The path to export the data as a .CSV file.
.PARAMETER TestLength
The time (in seconds) that each iteration of the IO test should last.
.PARAMETER MinBlockSize 
The minimum block size to test (the size will be incremented by a multiple of two per iteration).
.PARAMETER MaxBlockSize 
The maximum block size to test.
.PARAMETER MinThreads
The minimum number of threads to use (the number will be increased by a value of two per iteration).
.PARAMETER MaxThreads
The maximum number of threads to use.
.PARAMETER Async
If used, will execute the SQLIO runs in asynchronous fashion
#>
param
(
    [parameter(mandatory=$true)][String[]]$Filepath,
    [parameter(mandatory=$true)][Long]$Filesize,
    [parameter(mandatory=$true)][String]$Outfile,
    [parameter(mandatory=$false)][int]$TestLength = 30,
    [parameter(mandatory=$false)][int]$MinBlockSize = 8,
    [parameter(mandatory=$false)][int]$MaxBlockSize = 256,
    [parameter(mandatory=$false)][int]$MinThreads = 2,
    [parameter(mandatory=$false)][int]$MaxThreads = 24,
    [parameter(mandatory=$false)][Switch]$Async,
    [parameter(mandatory=$false)][int]$MaxConcurrentJobs = 2
)

# Set the path to the SQLIO.exe file and make sure it is there
$sqlio_path = "C:\Program Files (x86)\SQLIO\sqlio.exe";
if (-not (Test-Path $sqlio_path))
{
    $sqlio_path = "C:\Program Files\SQLIO\sqlio.exe";
}
if (-not (Test-Path $sqlio_path))
{
    Write-Error "SQLIO was not found, please verify that it is installed.";
    Exit 1;
}

# Initialize some variables for later use.
[String[]]$sqlio_output = $null;
[String]$joined_output = $null;
[String[]]$split_output = $null;
[String]$clear_line = "`r".PadLeft(40);

#Calculate the file size in bytes.
$Filesize = $Filesize * 1024 * 1024;

try
{
    foreach ($file in $Filepath)
    {
        Write-Host "Beginning file $file.";
        Write-Host -ForegroundColor Yellow "Press any key if you would like to cancel processing...";
        $counter = 0;
        $Host.UI.RawUI.FlushInputBuffer();
        while (!$Host.UI.RawUI.KeyAvailable -and ($counter++ -lt 10))
        {
            [Threading.Thread]::Sleep(1000);
            $remaining = 10 - $counter;
            Write-Host -ForegroundColor Yellow -NoNewline $clear_line;
            Write-Host -ForegroundColor Yellow -NoNewline "`r$remaining seconds until continue...";
        }
        if ($Host.UI.RawUI.KeyAvailable) {$Host.UI.RawUI.FlushInputBuffer();break;}
        Write-Host -NoNewline $clear_line;
        
        # Create the file using FSUTIL
        if (Test-Path $file) {Remove-Item $file;}
        fsutil file createnew $file $Filesize;
        
        for ($bs = $MinBlockSize;$bs -le $MaxBlockSize; $bs*=2)
        {
            Write-Host -ForegroundColor Yellow "Beginning run for block size of $bs KB.";
            for ($t = $MinThreads;$t -le $MaxThreads; $t*=2)
            {
                Write-Output "Press any key if you would like to cancel processing...";
                $counter = 0;
                $Host.UI.RawUI.FlushInputBuffer();
                while (!$Host.UI.RawUI.KeyAvailable -and ($counter++ -lt 10))
                {
                    [Threading.Thread]::Sleep(1000);
                    $remaining = 10 - $counter;
                    Write-Host -ForegroundColor Yellow -NoNewline "`t$clear_line";
                    Write-Host -ForegroundColor Yellow -NoNewline "`t$remaining seconds until continue...";
                }
                Write-Host -NoNewline "`t$clear_line";
                if ($Host.UI.RawUI.KeyAvailable) {$Host.UI.RawUI.FlushInputBuffer();break;}
                Write-Output "`tBeginning run for $t threads.";
                #Reading
                Write-Output "`t`tBeginning random reads...";
                $sqlio_opts = "-frandom -kR -t$t -s$TestLength -b$bs -BN -LS $file";
                $sqlio_cmd = "&`"$sqlio_path`" $sqlio_opts";
                $sqlio_output += Invoke-Expression $sqlio_cmd;
                Write-Output "`t`tBeginning sequential reads...";
                $sqlio_opts = "-fsequential -kR -t$t -s$TestLength -b$bs -BN -LS $file";
                $sqlio_cmd = "&`"$sqlio_path`" $sqlio_opts";
                $sqlio_output += Invoke-Expression $sqlio_cmd;
                #Writing
                Write-Output "`t`tBeginning random writes...";
                $sqlio_opts = "-frandom -kW -t$t -s$TestLength -b$bs -BN -LS $file";
                $sqlio_cmd = "&`"$sqlio_path`" $sqlio_opts";
                $sqlio_output += Invoke-Expression $sqlio_cmd;
                Write-Output "`t`tBeginning sequential writes...";
                $sqlio_opts = "-fsequential -kW -t$t -s$TestLength -b$bs -BN -LS $file";
                $sqlio_cmd = "&`"$sqlio_path`" $sqlio_opts";
                $sqlio_output += Invoke-Expression $sqlio_cmd;
            }
        }
    }
}
catch [System.Exception]
{
    Write-Error "Error has occurred.";
    $Error | Format-List | Out-String | Write-Error;
}
$joined_output = [string]::Join([Environment]::NewLine,$sqlio_output);
$split_output = $joined_output.Split([String[]]"sqlio v1.5.SG",[StringSplitOptions]::RemoveEmptyEntries);
$split_output | select @{name="FileName";expression={[regex]::Match($_,"file (.*\.dat)").Groups[1].Value}},
                 @{name="Operation";expression={[regex]::Match($_,"\d* threads ([^ ]+) for").Groups[1].Value}},
                 @{name="SeqOrRandom";expression={[regex]::Match($_,"using \d+KB ([^ ]+) IOs").Groups[1].Value}},
                 @{name="Threads";expression={[regex]::Match($_,"(\d*) thread").Groups[1].Value}},
                 @{name="BlkSize";expression={[regex]::Match($_,"using (\d*)KB .* IOs").Groups[1].Value}},
                 @{name="AvgLatency";expression={[regex]::Match($_,"Avg_Latency\(ms\)\: ([\d.]*)").Groups[1].Value}},
                 @{name="MinLatency";expression={[regex]::Match($_,"Min_Latency\(ms\)\: ([\d.]*)").Groups[1].Value}},
                 @{name="MaxLatency";expression={[regex]::Match($_,"Max_Latency\(ms\)\: ([\d.]*)").Groups[1].Value}},
                 @{name="IOPerSec";expression={[regex]::Match($_,"IOs\/sec\:\s+([\d.]*)").Groups[1].Value}},
                 @{name="MB/Sec";expression={[regex]::Match($_,"MBs\/sec\:\s+([\d.]*)").Groups[1].Value}} | 
                Export-Csv -NoTypeInformation -Path $Outfile;
