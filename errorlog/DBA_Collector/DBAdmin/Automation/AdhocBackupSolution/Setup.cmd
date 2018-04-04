@ECHO OFF

CALL Config.cmd

ECHO. > logfile.txt
ECHO Setup backup proxy for SQL Agent >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateSQLAgentProxy.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

IF NOT %UseLitespeed%==TRUE GOTO CreateSQLAgentOperator

ECHO. >> logfile.txt
ECHO Setup backup proxy for SQL Agent >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateSQLAgentProxy_Litespeed.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

:CreateSQLAgentOperator
ECHO. >> logfile.txt
ECHO Setup proxy for agent job owner >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateSQLAgentOwner.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

ECHO. >> logfile.txt
ECHO Setup operator for agent job notifications >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateOperator.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

IF NOT %UseLitespeed%==TRUE GOTO CreateSQLAgentJob

ECHO. >> logfile.txt
ECHO Setup Backup SQL Agent Job >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateBackupSQLAgentJob_Litespeed.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit
ECHO. >> logfile.txt

ECHO Setup Restore SQL Agent Job >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateRestoreSQLAgentJob_Litespeed.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

GOTO UserSecurity

:CreateSQLAgentJob
ECHO. >> logfile.txt
ECHO Setup Backup SQL Agent Job >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateBackupSQLAgentJob.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit
ECHO. >> logfile.txt

ECHO Setup Restore SQL Agent Job >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateRestoreSQLAgentJob.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

:UserSecurity
ECHO. >> logfile.txt
ECHO Setup of security for end user group >> logfile.txt
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i UserSecurity.sql >> logfile.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit

ECHO. >> logfile.txt
ECHO Creating README file
ECHO ---------------------------------- >> logfile.txt
sqlcmd -S %ServerName% -E -b -i CreateInstructions.sql -o README.txt
IF NOT %ERRORLEVEL%==0 GOTO ErrExit


GOTO ExitCmd

:ErrExit
ECHO ***** Error occurred, check log file ******

:ExitCmd
PAUSE
