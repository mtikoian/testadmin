. ..\Shared\Ref\Function_Misc.ps1

if((PromptForYesNoValue -displayMessage "Would you like to restart Windows Explorer now?") -ieq "y")
{
    Write-Host ""
    Stop-Process -Name explorer
    Start-Process -FilePath explorer.exe
    Read-Host "Explorer.exe has been restarted. Please re-run your process. Press enter to exit..."

    Stop-Process -Id $pid
}