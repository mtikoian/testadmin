/*********************************************************************************
 Script Title: Add_New_Login
 Author: Josh Feierman 10/7/2011
 ---------------------------------------------------------------------------------
 
 This script is for creating a new server level login.
 
 This script makes use of SQLCMD variables, and is designed to be executed in batch mode.
 Please see MSFT documentation at http://msdn.microsoft.com/en-us/library/ms188714.aspx.
 
 Parameters are as follows:
 
 $(LoginName) - the name of the login to create (either the Windows credential or 
                SQL Server login name.
 $(LoginType) - The type of login being created. Should be "WINDOWS" for a Windows user,
                or "SQL" for a SQL user.
 $(LoginPassword) - The password for the login, if a SQL login (will be ignore if
                    a Windows login).
 $(LoginDefaultDB) - The default database for the login.
 
 *********************************************************************************/
 
DECLARE  @Login_Name SYSNAME;
DECLARE  @Login_Password SYSNAME;
DECLARE  @Login_Type CHAR(8);
DECLARE  @Login_Default_DB SYSNAME;
DECLARE  @SQL NVARCHAR(400);
DECLARE  @RC INT;
DECLARE  @Error_Message NVARCHAR(4000);
DECLARE  @Error_Severity TINYINT;

SET @Login_Name = '$(LoginName)';
SET @Login_Type = '$(LoginType)';
SET @Login_Password = '$(LoginPassword)';
SET @Login_Default_DB = '$(LoginDefaultDB)';

-- Begin Validation logic --

-- Check if a password was provided for a SQL login
IF (@Login_Type = 'SQL' AND ISNULL(@Login_Password,'') = '') BEGIN
  RAISERROR ('You must provide a password for a SQL Server login type.',16,1);
  RETURN;
END

-- Check if the database specified for the default is valid
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @Login_Default_DB) BEGIN
  RAISERROR ('Database name provided for default (%s) does not exist.',16,1,@Login_Default_DB);
  RETURN;
END
-- following is changed for the strataweb requirements. commenting the below line. @vkotian 4/2/2012
--USE @Login_Default_DB;

BEGIN TRY

-- Check if the login exists
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @Login_Name)
BEGIN

  RAISERROR('Login %s does not exist on the server, will create it.',10,1,@Login_Name) WITH NOWAIT;
  
  -- Begin branching for Windows versus SQL login
  IF @Login_Type = 'SQL' BEGIN
    
    SET @SQL = 'CREATE LOGIN ' + QUOTENAME(@Login_Name) 
                + ' WITH PASSWORD = ' + QUOTENAME(@Login_Password,'''') 
                + ', CHECK_EXPIRATION = OFF' 
                + ', DEFAULT_DATABASE = ' + QUOTENAME(@Login_Default_DB)
    EXEC @RC = sp_executesql @SQL;
    IF @RC <> 0 BEGIN
      RAISERROR ('Error creating server level login. Aborting.',16,1);
    END
  END
  ELSE BEGIN
    
    SET @SQL = 'CREATE LOGIN ' + QUOTENAME(@Login_Name) + ' FROM WINDOWS ' 
                + 'WITH DEFAULT_DATABASE = ' + QUOTENAME(@Login_Default_DB);
    EXEC @RC = sp_executesql @SQL;
    IF @RC <> 0 BEGIN
      RAISERROR ('Error creating server level login. Aborting.',16,1);
    END 
  END                
  
  RAISERROR('Login %s created successfully.',10,1,@Login_Name) WITH NOWAIT;
END
ELSE
  RAISERROR('Login %s already exists, nothing to do.',10,1,@Login_Name) WITH NOWAIT;

END TRY
BEGIN CATCH

  SET @Error_Message = ERROR_MESSAGE();
  SET @Error_Severity = ERROR_SEVERITY();
  
  RAISERROR('Operation did not complete successfully, please see the following errors.',10,1) WITH NOWAIT;
  RAISERROR(@Error_Message,@Error_Severity,1);
  
END CATCH
 