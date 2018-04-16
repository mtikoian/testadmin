@echo off

rem ---------------------------------------------------------------------------
rem Project        : InstallPoint Metabase
rem Business Unit  : TSU
rem Author         : POBRIEN
rem Created        : 01/16/2013
rem
rem Description: 
rem        
rem    Build and Rollback configuration settings script.
rem
rem    In case of any questions or problems, please contact anyone from the
rem    following list:
rem
rem        Patrick W. O'Brien x1437
rem
rem ---------------------------------------------------------------------------

	set enabledelayedexpansion

    rem Start by setting the current date
    call Current_DT.Cmd
    
    rem Set the starting folder as the current directory
    set ROOTDIR=D:\ODR\InstallPoint

    rem Set the log directory
    set LogDir=%RootDir%\Logs
    
    rem Set the name of the file that contains the script file names to pull using SVN.EXE
    set SVN_File_List=%ROOTDIR%\Docs\SVN_Input_File_List.txt
 
    rem Set the name of the file that contains the rollback script file names to pull using SVN.EXE
    set SVN_Rollback_List=%ROOTDIR%\Docs\SVN_Rollback_File_List.txt
    
    rem Set the root URL of the SVN repository where the code should be pulled from.
    rem It is suggested to specify either the trunk or a tag, with no subfolders.
    set SVN_URL=
    
    rem Set the root URL of the SVN repository where the rollbackcode should be pulled from.
    rem It is suggested to specify either the trunk or a tag, with no subfolders.
    set SVN_ROLLBACK_URL=
    
    rem Set the name of the file that contains the server, database and schema on which
    rem the input file list will be executed.
    set DBBuild_Server_List=%ROOTDIR%\Docs\DBBuild_Server_List.txt

    rem Set the name of the file that contains the script file names to execute in SQLCMD.exe
    set Input_File_List=%ROOTDIR%\Docs\DBBuild_Input_File_List.Txt

    rem Set the name of the file that contains the rollback script file names to execute in SQLCMD.exe
    set Rollback_Input_File_List=%ROOTDIR%\Docs\Rollback_Input_File_List.Txt

    rem Initialize the error message variable
    set ErrMsg=EMPTY

    rem Initialize the script name variable
    set Script=EMPTY
    
    rem ***********************************************************************
    rem Add any additional variables here
    
    
    rem ***********************************************************************
    
    goto :eof
    
:CurrentDate
    rem This sets the Current_Dt variable 
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c%%a%%b)
    for /f "tokens=1-3 delims=/:." %%a in ("%TIME%") do (set mytime=%%a%%b%%c)
    
    rem if the time < 10:00:00, prepend a 0 and strip out the space 
    set mytime=0%mytime: =%
    set mytime=%mytime:~-6%
    set CURRENT_DT=%mydate%_%mytime%
    goto :eof
        
