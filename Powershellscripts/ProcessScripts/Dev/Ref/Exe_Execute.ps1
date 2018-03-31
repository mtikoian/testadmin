param(
    [Parameter(Mandatory=$true)]
    [string]$exeCommand
)

Invoke-Expression $exeCommand

if($LASTEXITCODE -ne 0){
    throw "Command failed: $exeCommand"
}