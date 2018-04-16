@echo off

rem ---------------------------------------------------------------------------
rem Project        : Know Your Client (kyc), Client Data Services (cds)
rem Business Unit  : IMS
rem Author         : Sam Page (fpageiv)
rem Created        : 20131007
rem
rem     Description: Initial
rem        
rem            
rem
rem    In case of any questions or problems, please contact anyone from the
rem    following list:
rem
rem        Sam Page    484 639 1761
rem
rem ---------------------------------------------------------------------------

	set enabledelayedexpansion

    rem Start by setting the current date
    call Current_DT.Cmd
    
    rem Set the starting folder as the current directory
    set ROOTDIR=C:\Projects\knowyourclient\databasescripts\deployments\CDSUpdatePackage_PendingTransaction
	
    rem Set the name of the file that contains the names needed to create the database
    set DBCreate_Server_List=%ROOTDIR%\Docs\Create_Server_List.txt
	
    rem Set the name of the file that contains the create script files to run.
    set DBCreate_Input_File_List=%ROOTDIR%\DBCreate_Input_File_List.txt

    rem Set the name of the file that contains the server, database and schema on which
    rem the input file list will be executed.
    set DBBuild_Server_List=%ROOTDIR%\Docs\DBBuild_Server_List.txt

    rem Set the log directory
    set LogDir=%RootDir%\Logs
    
    rem Set the name of the file that contains the script file names to pull using SVN.EXE
    set SVN_File_List=%ROOTDIR%\Docs\SVN_Input_File_List.txt
 
    rem Set the name of the file that contains the rollback script file names to pull using SVN.EXE
    set SVN_Rollback_List=%ROOTDIR%\Docs\SVN_Rollback_File_List.txt

    rem Set the name of the file that contains the script file names to execute in SQLCMD.exe
    set Input_File_List=%ROOTDIR%\Docs\DBBuild_Input_File_List.Txt

    rem Set the name of the file that contains the rollback script file names to execute in SQLCMD.exe
    set Rollback_Input_File_List=%ROOTDIR%\Docs\Rollback_DBBuild_Input_File_List.Txt

    rem Initialize the error message variable
    set ErrMsg=EMPTY

    rem Initialize the script name variable
    set Script=EMPTY
    
    rem ***********************************************************************
    rem Add any additional variables here
    
    
    rem ***********************************************************************
    goto :eof
        
