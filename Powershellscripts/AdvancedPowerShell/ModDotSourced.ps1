Import-Module umd_application

Invoke-UdfAddNumber 5 10

Get-Module umd_application 

#  Using a module as an object..

$mymathobject = Import-Module umd_application -AsCustomObject -Force

$mymathobject.'Invoke-UdfMultiplyNumber'(5, 10)
