@echo off

	rem ---------------------------------------------------------------------------
	rem 	Project		 :	NETIK
	rem	Business Unit	 :	IMS	
	rem
	rem ---------------------------------------------------------------------------

	
	rem ==============================================
	rem Setup the environment variables
	rem ==============================================
		
	rem Set all the configuration environment variables
	set ErrMsg="Calling DBBuild_Config_SpecifyRoot.cmd"
	call DBBuild_Config_SpecifyRoot.cmd
	if not %ERRORLEVEL%==0 goto ABORT	
	
	rem ==============================================
	rem Validate all the environment variables needed.
	rem ==============================================
	
	rem RootDir
	rem ------------------------------------------
	set ErrMsg="Invalid RootDir variable"
	if %RootDir%zip==zip goto ABORT
	if not exist %RootDir% goto ABORT
	
	rem DBServer
	rem ------------------------------------------
	set ErrMsg="Invalid DBServer variable"
	if %DBServer%zip==zip goto ABORT
	
	rem DBName
	rem ------------------------------------------
	set ErrMsg="Invalid DBName variable"
	if %DBName%zip==zip goto ABORT
	
	rem DBSchema
	rem ------------------------------------------
	set ErrMsg="Invalid DBSchema variable"
	if %DBSchema%zip==zip goto ABORT
	
	rem LogDir
	rem ------------------------------------------
	set ErrMsg="Invalid LogDir variable"
	if %LogDir%zip==zip goto ABORT
	if not exist %LogDir% (md %LogDir%) 
	
	rem Input_File_List
	rem ------------------------------------------
	set ErrMsg="Invalid Input_File_List variable"
	if %Input_File_List%zip==zip goto ABORT
	if not exist %Input_File_List% goto ABORT	
	
	rem ==============================================
	rem Start of processing
	rem ==============================================
	
	rem Set the log filename
	set LogFile=%LogDir%\DBBuild_%Current_Dt%.log
	
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
	for /F "eol=#" %%g in (%Input_File_List%) do (
		set Script=%%g
		set ErrMsg="%ROOTDIR%\scripts\%%g does not exist!"
		if not exist %ROOTDIR%\scripts\%%g goto ABORT
	)
	
	rem Execute a connection test to the database
	sqlcmd.exe -S %DBServer% -E -d %DBName% -Q"if exists (select top 1 TABLE_NAME from INFORMATION_SCHEMA.TABLES) print 'Connection to ' + @@servername + '.' + db_name() + ' succeeded'" -b -e -w 2000
	if not !ERRORLEVEL!==0 GOTO ABORT
	
	rem Process the files in the input file list skipping blank lines and lines starting with a pound sign
	rem and execute each input file via SQLCMD.exe
	for /F "eol=#" %%g in (%Input_File_List%) do (

		rem For the error message handling
		set Script=%%g
		set ErrMSg="Executing file %%g"

		rem Status the user
		echo Executing %ROOTDIR%\scripts\%%g
		echo Executing %ROOTDIR%\scripts\%%g >> %LogFile%

		rem Execute the SQL script
		SQLCMD.exe -S %DBServer% -E -d %DBName% -i %ROOTDIR%\scripts\%%g -b -w 2000 >> %LogFile% 2>&1
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
