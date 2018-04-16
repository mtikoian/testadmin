@echo off

rem ---------------------------------------------------------------------------
rem Project         : xxx 
rem Business Unit   : xxx
rem Author          : xxx
rem Created         : xxx
rem
rem     Description : 
rem  
rem  
rem
rem    In case of any questions or problems, please contact anyone from the
rem    following list:
rem
rem        John Doe    X0001
rem
rem ---------------------------------------------------------------------------


rem ==============================================
rem Setup the environment variables
rem ==============================================
    
rem Set all the configuration environment variables
set ErrMsg="Calling DBBuild_Config.cmd"
call DBBuild_Config.cmd
if not %ERRORLEVEL%==0 goto ABORT    

rem ==============================================
rem Validate all the environment variables needed.
rem ==============================================

rem RootDir
rem ------------------------------------------
set ErrMsg="Invalid RootDir variable"
if %RootDir%zip==zip goto ABORT
if not exist %RootDir% goto ABORT

rem LogDir
rem ------------------------------------------
set ErrMsg="Invalid LogDir variable"
if %LogDir%zip==zip goto ABORT
if not exist %LogDir% (md %LogDir%) 

rem Rollback_Input_File_List
rem ------------------------------------------
set ErrMsg="Invalid Rollback_Input_File_List variable"
if %Rollback_Input_File_List%zip==zip goto ABORT
if not exist %Rollback_Input_File_List% goto ABORT    

rem ==============================================
rem Start of processing
rem ==============================================

rem Set the log filename
set LogFile=%LogDir%\Rollback_DBBuild_%Current_Dt%.log

rem Delete the log file
del %LogFile%

rem Start the log file
echo DBBuild starting on %CURRENT_DT%
echo DBBuild starting on %CURRENT_DT% >>%LogFile%

rem Capture the envirornment variables
echo. >>%LogFile%
set   >>%LogFile%
echo. >>%LogFile%

rem Expand variables at execution time, not parse.
SETLOCAL ENABLEDELAYEDEXPANSION

rem Process the files in the input file list skipping blank lines and lines starting with a pound sign
rem and make sure that each file name exists.
rem We want to do this before we start executing any of the scripts.
for /F "eol=#" %%g in (%Rollback_Input_File_List%) do (
    set Script=%%g
    set ErrMsg="%ROOTDIR%\RollbackSQLScripts\%%g does not exist!"
    if not exist %ROOTDIR%\RollbackSQLScripts\%%g goto ABORT
)

rem     Read the server list file to get server name, database name and schema name
rem     This is done by iterating through the lines and splitting each line 
rem        into 3 variables 
echo %DBBuild_Server_List%
for /F "eol=# tokens=1-3* delims= " %%A IN (%DBBuild_Server_List%) DO (
    set DBServer=%%A
    set DBName=%%B
    set DBSchema=%%C
    echo Server is %%A,  Database is %%B, Schema is %%C >> %LogFile%
        
    call Rollback_SQLCmd.cmd
    if not !ERRORLEVEL!==0 GOTO ABORT
    echo ERRORLEVEL=!ERRORLEVEL! >> %LogFile%
    echo. >> %LogFile%
)    

rem Finished sucessfully
rem --------------------
:FINISH
echo DBBuild finished on %CURRENT_DT% >>%LogFile%
echo DBBuild finished on %CURRENT_DT% 
GOTO:EOF

rem Aborted for some reason
rem -----------------------
:ABORT
echo *** Aborted on error message %ErrMsg% script %Script% %CURRENT_DT% *** 
echo *** Aborted on error message %ErrMsg% script %Script% %CURRENT_DT% *** >>%LogFile%
echo *** See log file %LogFile%

:EOF
