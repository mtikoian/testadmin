@echo off

rem ---------------------------------------------------------------------------
rem Project         : xxx 
rem Business Unit   : xxx
rem Author          : xxx
rem Created         : xxx
rem
rem     Description :     This command file calls sqlcmd twice, once to test the connection and once 
rem                        for the real call to execute the rollback script. This file should not need to 
rem                        change.             
rem
rem    In case of any questions or problems, please contact anyone from the
rem    following list:
rem
rem        John Doe    X0001
rem
rem ---------------------------------------------------------------------------
    
rem Execute a connection test to the database
sqlcmd.exe -S %DBServer% -E -d %DBName% -Q"if exists (select top 1 TABLE_NAME from INFORMATION_SCHEMA.TABLES) print 'Connection to ' + @@servername + '.' + db_name() + ' succeeded'" -b -e -w 2000 >> %LogFile% 2>&1
if not !ERRORLEVEL!==0 GOTO ABORT

rem Process the files in the input file list skipping blank lines and lines starting with a pound sign
rem and execute each input file via SQLCMD.exe
for /F "eol=#" %%g in (%Rollback_Input_File_List%) do (

    rem For the error message handling
    set Script=%%g
    set ErrMSg="Executing file %%g"

    rem Status the user
    echo Executing %%g
    echo Executing %ROOTDIR%\RollbackSQLScripts\%%g >> %LogFile%

    rem Execute the SQL script
    SQLCMD.exe -S %DBServer% -E -d %DBName% -i %ROOTDIR%\RollbackSQLScripts\%%g -b -w 2000 >> %LogFile% 2>&1
    if not !ERRORLEVEL!==0 GOTO ABORT
    echo ERRORLEVEL=!ERRORLEVEL! >> %LogFile%
    echo. >> %LogFile%
)    

rem Finished sucessfully
rem --------------------
:FINISH
    echo Rollback_SQLCmd finished on %CURRENT_DT% >>%LogFile%
    echo Rollback_SQLCmd finished on %CURRENT_DT% 
    GOTO:EOF

rem Aborted for some reason
rem -----------------------
:ABORT
    echo *** Aborted on error message %ErrMsg% script %Script% %CURRENT_DT% *** 
    echo *** Aborted on error message %ErrMsg% script %Script% %CURRENT_DT% *** >>%LogFile%
    echo *** See log file %LogFile%

:EOF