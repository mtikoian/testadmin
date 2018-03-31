[System.Reflection.Assembly]::LoadWithPartialName("System.ServiceProcess") | Out-Null

function StartService([Parameter(Mandatory=$true)][string]$computerName, [Parameter(Mandatory=$true)][string]$serviceName)
{
    [string]$writeHostPrefix = "$($computerName):$serviceName ->"

    Write-Host "$writeHostPrefix Starting service"

    $serviceController = New-Object -TypeName System.ServiceProcess.ServiceController $serviceName, $computerName

    if(!$serviceController.CanStop)
    {
        $serviceController.Start()

        Write-Host "$writeHostPrefix Service started"
    }
    else
    {
        Write-Warning "$writeHostPrefix Service is started already"
    }
}

function StopService([Parameter(Mandatory=$true)][string]$computerName, [Parameter(Mandatory=$true)][string]$serviceName)
{
    [string]$writeHostPrefix = "$($computerName):$serviceName ->"

    Write-Host "$writeHostPrefix Stopping service" 

    $serviceController = New-Object -TypeName System.ServiceProcess.ServiceController $serviceName, $computerName

    if($serviceController.CanStop)
    {
        $serviceController.Stop()

        Write-Host "$writeHostPrefix Service stopped"    
    }
    else
    {
        Write-Warning "$writeHostPrefix Service is stopped already"
    }
}