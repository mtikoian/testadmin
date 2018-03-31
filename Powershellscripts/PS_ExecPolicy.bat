ECHO OFF
REM 
REM Set Powershell Execution Policy to RemoteSigned 
REM Default setting is Restricted - no scripts may execute 
REM This allows local .ps1 execution or they must be signed 
REM See Powershell "help about_signing" for more info
REM 
REM Ver. 1.0 - 13/03/2009 - Nancy Hidy Wilson, SQL SE

Set log=c:\temp\%~n0.out
ECHO ************ >> %log%
ECHO Starting %~f0 >> %log% 
date /T >> %log%
time /T >> %log%
ECHO .... >> %log%

PowerShell Set-ExecutionPolicy RemoteSigned 

ECHO End of %~f0 >> %log%
date /T >> %log%
time /T >> %log%
ECHO ************ >> %log%

Exit