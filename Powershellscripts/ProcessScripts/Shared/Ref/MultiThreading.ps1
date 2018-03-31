function StartExecutionAsync([Parameter(Mandatory = $true)][string]$exeName, [string]$exeArguments = $null)
{
    $processStartInfo = New-Object -TypeName System.Diagnostics.ProcessStartInfo 
    $processStartInfo.FileName = $exeName
    $processStartInfo.RedirectStandardError = $true    
    $processStartInfo.UseShellExecute = $false
    $processStartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal

    if(![string]::IsNullOrWhiteSpace($exeArguments))  
    {
        $processStartInfo.Arguments = $exeArguments     
    }    

    [System.Diagnostics.Process]$process = New-Object -TypeName System.Diagnostics.Process
    $process.StartInfo = $processStartInfo    
    $process.Start() | Out-Null
    
    return $process
}

function StartPowershellAsync([Parameter(Mandatory = $true)][string]$scriptFilePath, [string]$arguments)
{
    $scriptPath = (Resolve-Path $scriptFilePath).Path
    $scriptDirectory = Split-Path $scriptPath -Parent    

   return StartExecutionAsync -exeName "Powershell.exe" -exeArguments "-Command &{cd $scriptDirectory; $scriptPath $arguments}" 
}

function WaitForExecution([Parameter(Mandatory = $true)][System.Diagnostics.Process[]]$processes)
{
    foreach($process in $processes)
    {
        $process.WaitForExit()
    }

    $errors = $processes | Where-Object {$_.StandardError -ne $null} | ForEach-Object {$_.StandardError.ReadToEnd()} 

    if(![string]::IsNullOrWhiteSpace($errors))
    {
        Write-Host $errors -ForegroundColor Red        
        Throw "See above errors"
    }
}