@echo off

	rem ---------------------------------------------------------------------------
	rem 	Project		 :	NETIK
	rem	Business Unit	 :	IMS	
	rem	Author		 :	ppremkumar
	rem 	Release		 :	MT #3593042, MT# 3591443 
	rem	Created		 :	06/19/2013
	rem
	rem 	Description	 : 	These stored-procedures have been created as per enhancement requested by business with Netik Prod Deployment.  Jira MDB - 671,MDB - 1445	
	rem		
	rem			
	rem
	rem	In case of any questions or problems, please contact anyone from the
	rem	following list:
	rem
	rem	ppremkumar@seic.com
	rem
	rem ---------------------------------------------------------------------------

	rem Start by setting the current date
	call Current_Dt.cmd
	
	rem Set the starting folder as the current directory
	set STARTDIR=%~dp0
		
	rem now set the parent directory as the root
	call :RESOLVEROOT "%STARTDIR%\" ROOTDIR

	rem Set the MS SQL Server instance to use when executing SQLCMD.exe
	set DBServer=seinetikqadb02

	rem Set the name of the database in the MS SQL Server instance
	set DBName=NETIKIP

	rem Set the database schema name
	set DBSchema=dbo

	rem Set the log directory
	set LogDir=%RootDir%\Logs
	
	rem Set the name of the file that contains the script file names to pull using SVN.EXE
	rem set SVN_File_List=%ROOTDIR%\Docs\SVN_Input_File_List.txt

	rem Set the name of the file that contains the script file names to execute in SQLCMD.exe
	set Input_File_List=%ROOTDIR%\Docs\DBBuild_Input_File_List.Txt

	rem Initialize the error message variable
	set ErrMsg=EMPTY

	rem Initialize the script name variable
	set Script=EMPTY
	
	rem ***********************************************************************
	rem Add any additional variables here
	
	
	rem ***********************************************************************
	
	goto :eof

:RESOLVEROOT
	set %2=%~f1
	goto :eof
	
