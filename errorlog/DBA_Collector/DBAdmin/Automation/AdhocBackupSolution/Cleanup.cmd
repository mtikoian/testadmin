@ECHO OFF

CALL Config.cmd

ECHO Executing cleanup script > logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i Cleanup.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

GOTO ExitCmd

:ErrExit
ECHO ***** Error occurred, check log file ******

:ExitCmd
PAUSE
