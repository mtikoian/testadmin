@echo off

rem ---------------------------------------------------------------------------
rem Project         :   xxx 
rem Business Unit   :   xxx
rem Author          :   xxx
rem Created         :   xxx
rem
rem Description     :   xxx 
rem        
rem        xxx    
rem
rem    In case of any questions or problems, please contact anyone from the
rem    following list:
rem
rem        John Doe    X0001
rem
rem ---------------------------------------------------------------------------


rem ==============================================
rem Setup the enviornment variables
rem ==============================================

rem This first command gets the config variables that we need
set ErrMsg="Calling DBBuild_Config.cmd"
call DBBuild_Config.cmd
if not %ERRORLEVEL% == 0 goto ABORT    

rem ==============================================
rem Validate all the enviornment variables needed.
rem ==============================================
 
rem RootDir
rem ------------------------------------------
set ErrMsg="Invalid RootDir variable"
if %RootDir%zip==zip goto ABORT
if not exist %RootDir% goto ABORT

rem Input_File_List
rem ------------------------------------------
set ErrMsg="Invalid Input_File_List variable"
if %SVN_File_List%zip==zip goto ABORT
if not exist %SVN_File_List% goto ABORT

rem Rollback_File_List
rem ------------------------------------------
set ErrMsg="Invalid Rollback_File_List variable"
if %SVN_Rollback_List%zip==zip goto ABORT
if not exist %SVN_Rollback_List% goto ABORT

rem LogDir
rem ------------------------------------------
set ErrMsg="Invalid LogDir variable"
if %LogDir%zip==zip goto ABORT
if not exist %LogDir% (md %LogDir%) 

rem SVN_URL
rem ------------------------------------------
set ErrMsg="Invalid SVN_URL variable"
if %SVN_URL%zip==zip goto ABORT

rem SVN_ROLLBACK_URL
rem ------------------------------------------
set ErrMsg="Invalid SVN_ROLLBACK_URL variable"
if %SVN_ROLLBACK_URL%zip==zip goto ABORT

rem ==============================================
rem Start of processing
rem ==============================================

rem Set the log filename
set LogFile=%LogDir%\SVNPull_%Current_Dt%.log

rem Delete the log file
del %LOGFILE%

rem Start the log file
echo SVN Pull starting on %CURRENT_DT%
echo SVN Pull starting on %CURRENT_DT% >>%LogFile%

rem Capture the envirornment variables
echo. >>%LogFile%
set   >>%LogFile%
echo. >>%LogFile%


rem Expand variables at execution time, not parse.
SETLOCAL ENABLEDELAYEDEXPANSION

rem get the files from the source control system
for /F "eol=#" %%g in (%SVN_File_List%) do (

    rem For the error message handling
    set Script=%%g
    set ErrMSg="Executing file %%g"
    
    rem Status the user
    echo Getting %%g >> %LOGFILE%
    echo Getting %%g
    
    rem Execute the svn command
    svn export %SVN_URL%%%g  %ROOTDIR%\sqlscripts --force >> %LOGFILE% 2>&1
    if not !ERRORLEVEL!==0 goto ABORT
    echo ERRORLEVEL=!ERRORLEVEL! >> %LogFile%
    echo. >> %LOGFILE%
    echo --------------------------------- >> %LOGFILE%
) 

rem get the rollback files
for /F "eol=#" %%g in (%SVN_Rollback_List%) do (

    rem For the error message handling
    set Script=%%g
    set ErrMSg="Executing file %%g"
    
    rem Status the user
    echo Getting %%g >> %LOGFILE%
    echo Getting %%g
    
    rem Execute the svn command
    svn export %SVN_ROLLBACK_URL%%%g  %ROOTDIR%\RollbackSQLScripts --force >> %LOGFILE% 2>&1
    if not !ERRORLEVEL!==0 goto ABORT
    echo ERRORLEVEL=!ERRORLEVEL! >> %LogFile%
    echo. >> %LOGFILE%
    echo --------------------------------- >> %LOGFILE%
) 


rem Finished sucessfully
rem --------------------
:FINISH
    echo Finished on %DATE% %TIME% >>%LOGFILE%
    echo Finished on %DATE% %TIME% 
    GOTO:EOF

rem Aborted for some reason
rem -----------------------
:ABORT
    echo *** Aborted on error message %ErrMsg% file %Script% %CURRENT_DT% *** 
    echo *** Aborted on error message %ErrMsg% file %Script% %CURRENT_DT% *** >>%LogFile%
    echo *** See log file %LogFile%

:EOF