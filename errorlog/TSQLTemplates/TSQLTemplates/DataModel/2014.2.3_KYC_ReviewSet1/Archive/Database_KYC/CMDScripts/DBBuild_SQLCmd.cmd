@echo off

rem ---------------------------------------------------------------------------
rem Project         : xxx
rem Business Unit   : xxx
rem Author          : xxx
rem Created         : xxx
rem
rem     Description:  This command file calls sqlcmd twice, once to test the connection and once 
rem                   for the real call to execute the script. This file should not need to 
rem                   change. 
rem
rem    In case of any questions or problems, please contact anyone from the
rem    following list:
rem
rem        John Doe    X0001
rem
rem
rem     Updated: 08/15/2012 pobrien
rem		 Added log file for the script file being execute to the logs directory.
rem		 Removed echo of connection test sql.
rem		 Added additional error message information on ABORT.
rem ---------------------------------------------------------------------------


rem Process the files in the input file list skipping blank lines and lines starting with a pound sign
rem and execute each input file via SQLCMD.exe
    
rem Execute a connection test to the database
set ErrMsg="SQLCMD.exe Unable to connect to server %DBServer% database %DBName%"
sqlcmd.exe -S %DBServer% -E -d %DBName% -Q"if exists (select top 1 TABLE_NAME from INFORMATION_SCHEMA.TABLES) print 'Connection to ' + @@servername + '.' + db_name() + ' succeeded'" -b -w 2000 >> %LogFile% 2>&1
if not !ERRORLEVEL!==0 GOTO ABORT


for /F "eol=#" %%g in (%Input_File_List%) do (

    rem For the error message handling
    set Script=%%g
    set ErrMSg="Executing file %%g"

    rem Status the user
    echo Executing %%g
    echo Executing %ROOTDIR%\sqlscripts\%%g >> %LogFile%
    
    rem If the file is a CMD file then execute it
    IF %%~xg==.cmd (
    	CALL %ROOTDIR%\sqlscripts\%%g >> %LogDir%\%%g.out 2>&1
    	if not !ERRORLEVEL!==0 GOTO ABORT
    	echo ERRORLEVEL=!ERRORLEVEL! >> %LogFile%
    	echo. >> %LogFile%
    ) else IF %%~xg==.sql (
    	rem Execute the SQL scriptS
    	SQLCMD.exe -S %DBServer% -E -d %DBName% -i %ROOTDIR%\sqlscripts\%%g -b -w 2000 -o %LogDir%\%%g.out >> %LogFile% 2>&1
    	if not !ERRORLEVEL!==0 GOTO ABORT
    	echo ERRORLEVEL=!ERRORLEVEL! >> %LogFile%
    	echo. >> %LogFile%
    ) else (
    	set ErrMsg="File %%g is of an unknown type and cannot be executed. Aborting."
    	GOTO ABORT
    )
    
    
)    

rem Finished sucessfully
rem --------------------
:FINISH
    echo DBBuild_SQLCmd finished on %CURRENT_DT% >>%LogFile%
    echo DBBuild_SQLCmd finished on %CURRENT_DT% 
    GOTO:EOF

rem Aborted for some reason
rem -----------------------
:ABORT
    echo *** Aborted on error message %ErrMsg% script %Script% %CURRENT_DT% *** 
    echo *** Aborted on error message %ErrMsg% script %Script% %CURRENT_DT% *** >>%LogFile%
    echo *** See log file %LogFile%
    echo *** See log file %LogDir%\%Script%.out >>%LogFile%
    echo *** See log file %LogDir%\%Script%.out
    exit /B 1


:EOF