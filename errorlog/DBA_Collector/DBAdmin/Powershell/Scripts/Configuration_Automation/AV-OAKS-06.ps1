[Cmdletbinding()]
param
(
  [parameter(mandatory=$true)]
  [String[]]$Computer
)
begin
{
  
}
process
{
  foreach ($curComputer in $computer)
  {
    Copy-Item \\av-oaks-06\client_mover\64Bit\IpXfer_x64.exe "\\$curComputer\d$\"
    
    & "C:\PSTools\psexec.exe \\$curComputer D:\IPXfer_x64.exe -s AV-OAKS-06 -p 8080 -c 50041"
    $LASTEXITCODE
  }
}