
@echo off
rem ================================================================================================
rem            NewBuild.cmd
rem
rem        Author: Stephen R. McLarnon Sr.
rem        Date  :    2012-07-30
rem        
rem        This command file creates the folders needed to create a sql build.
rem
rem ================================================================================================

set TEMPLATE_DIR=C:\A\Workspace\SQL_Library\SQL_Deploy\SQL_Deploy2

set MODE=%1

if %MODE%ZIP==ZIP (
    set MODE=Specify
)

md App
md SQLScripts
md RollbackSQLScripts
md CMDScripts
md Docs
md Logs

copy %TEMPLATE_DIR%\ReadMeFirst.txt
copy %TEMPLATE_DIR%\Whatsnew.txt

cd Docs
copy %TEMPLATE_DIR%\docs\DBBuild_Input_File_List.txt
copy %TEMPLATE_DIR%\docs\Rollback_DBBuild_Input_File_List.txt
copy %TEMPLATE_DIR%\docs\SVN_Input_File_List.txt
copy %TEMPLATE_DIR%\docs\SVN_Rollback_File_List.txt
copy %TEMPLATE_DIR%\docs\DBBuild_Server_List.txt
cd ..

cd CMDScripts
copy %TEMPLATE_DIR%\CmdScripts\DBBuild_Config.cmd
copy %TEMPLATE_DIR%\CmdScripts\DBBuild.cmd
copy %TEMPLATE_DIR%\CmdScripts\SVNCodePull.cmd
copy %TEMPLATE_DIR%\CmdScripts\RootNode.cmd
copy %TEMPLATE_DIR%\CmdScripts\Current_Dt.cmd
copy %TEMPLATE_DIR%\CmdScripts\Rollback_DBBuild.cmd
copy %TEMPLATE_DIR%\CmdScripts\DBBuild_SQLCmd.cmd
copy %TEMPLATE_DIR%\CmdScripts\Rollback_SQLCmd.cmd
copy %TEMPLATE_DIR%\CmdScripts\CreateServerList.cmd
cd ..

cd SQLScripts
copy %TEMPLATE_DIR%\SQLScripts\CreateServerList.sql
cd ..


rem Finished sucessfully
rem --------------------
:FINISH
echo Finished on %DATE% %TIME% 
GOTO:EOF

rem Aborted for some reason
rem -----------------------
:ABORT
echo *** Aborted on %DATE% %TIME% ***

:EOF
