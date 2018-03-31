@echo off
color 1F
echo.
echo Starting database health check. Please wait...

C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -Command "./DB_Pull_TFS_Changes.ps1

