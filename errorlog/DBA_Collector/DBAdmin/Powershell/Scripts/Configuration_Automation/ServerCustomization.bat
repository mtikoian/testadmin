@ECHO OFF
REM Set the execution policy
powershell -command "Set-ExecutionPolicy Unrestricted"

REM Run the config script
powershell %~dp0ServerCustomization.ps1