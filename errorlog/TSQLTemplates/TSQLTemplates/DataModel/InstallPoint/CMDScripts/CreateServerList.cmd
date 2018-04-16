
@echo off

rem ---------------------------------------------------------------------------
rem Project        : XXXX
rem Business Unit  : XXXX
rem Author         : XXXX
rem Release        :
rem Created        : 08/31/2012
rem
rem Description    : Script to create list of database information.
rem        
rem ---------------------------------------------------------------------------
    
rem ==============================================
rem Setup the environment variables
rem ==============================================
        
rem Set all the configuration environment variables
set ErrMsg="Calling DBBuild_Config.cmd"
call DBBuild_Config.cmd
if not %ERRORLEVEL%==0 goto ABORT    

 
sqlcmd.exe -S <DB_SERVER_NAME> -E -d master -i %ROOTDIR%\sqlscripts\CreateServerList.sql -o %ROOTDIR%\docs\DBBuild_Server_List.txt -h-1 -b -w 2000
