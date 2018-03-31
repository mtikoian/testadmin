$servers = @("server1","server2","server3","server4")

foreach ($server in $servers)
{
    $drives = Get-WmiObject win32_logicaldisk -Computername $server
    foreach ($drive in $drives)
    {
        if ($drive.Name -ne 'D:' -and $drive.Name -ne 'A:')
        {
            $drv = $server + ',' + $drive.Name + ',' + $drive.VolumeName
            Write-Host $drv
        }
    }
}