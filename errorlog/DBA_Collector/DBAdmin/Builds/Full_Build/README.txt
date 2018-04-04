INSTALLATION
-------------

Follow these steps to install the DBAdmin database.

WARNING: Do not complete these steps against as server with an existing installation as it will drop and 
recreate the entire database. This is for new installations or rebuilds only.

1. Open the Config.txt file in a text editor such as Notepad. The file contains a list of installation variables, 
   listed as "variable"="value". These should be set before running the install.
   
   At a minimum, the following ones should be set:
   
   DBServer - the name of the database server on which to install the database.
   DBName - the name of the database (can be left at the default DBAdmin).
   DATA_PATH - the path on which to create the data files. This must be set, as the install is unaware of default paths.
   LOG_PATH - the path on which to create the log file.
   DBDataSize - the size of the primary data file where all non system objects reside. Depending upon usage volume, the'
   		default of 1024 should be sufficient.
   		
   The file may also contain user defined variables, which are used for custom procedures or other work. These should 
   be set according to whatever custom code or procedures you are deploying in your environment.
   
2. Open a command prompt at the location where the build resides. The prompt does not need to be opened with admin rights.
3. Run the following command: powershell -file .\Execute-Install.ps1. If you receive a warning about the script not being signed,
   you need to set your Powershell execution policy to RemoteSigned or Unrestricted (the former is recommended).

   The build should execute and display a list of files being run. If an error occurs, a message will be printed to the screen
   directing the user to review the "log.txt" log file in the build directory. This will contain a more detailed error message.
   
AUTOMATION OF PROCEDURE SIGNING AND CERTIFICATE DEPLOYMENT
-----------------------------------------------------------

The DBAdmin framework automates the process of signing stored procedures and deploying a proxy certificate in the
Master database.

To mark a procedure as eligible for signing, a record must exist in the "Config.signed_procedures" table with the 
schema and procedure name.

To sign the procedures, execute the "Config.p_signProcedures" stored procedure. This may be done repeatedly as the 
procedure will simply skip any previously signed procedures. In general this procedure should be executed as part of 
deployment (the install process above does this) and whenever new procedures are added or existing ones modified.

To deploy the certificate to the Master database and create the proxy login, execute the "Config.p_deploySignedCertificate"
stored procedure.