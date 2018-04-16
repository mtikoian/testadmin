/*********************************************************************************
 Script Title: Add_New_DBUser
 Author: Josh Feierman 10/7/2011
 ---------------------------------------------------------------------------------
 
 This script is for creating a new database level user and adding it to a role.
 
 This script makes use of SQLCMD variables, and is designed to be executed in batch mode.
 Please see MSFT documentation at http://msdn.microsoft.com/en-us/library/ms188714.aspx.
 
 Parameters are as follows:
 
 $(LoginName) - the name of the login to link the user to.
 $(DatabaseName) - The name of the database to add the user to.
 $(RoleName) - The name of the role to add the user to.
 
 *********************************************************************************/
 
DECLARE  @Login_Name SYSNAME;
DECLARE  @Database_Name SYSNAME;
DECLARE  @Role_Name SYSNAME;
DECLARE  @SQL NVARCHAR(400);
DECLARE  @RC INT;
DECLARE  @Error_Message NVARCHAR(4000);
DECLARE  @Error_Severity TINYINT;

SET @Login_Name = '$(LoginName)';
SET @Database_Name = '$(DatabaseName)';
SET @Role_Name = '$(RoleName)';

-- Begin Validation logic --

-- Check if the login specified exists --
USE MASTER;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @Login_Name) BEGIN
  RAISERROR('Login specified (%s) does not exist.',16,1,@Login_Name);
  RETURN;
END

-- Check if the database specified is valid
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = @Database_Name) BEGIN
  RAISERROR ('Database name provided for user (%s) does not exist.',16,1,@Database_Name);
  RETURN;
END

-- Check if the specified role exists
USE [$(DatabaseName)];
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE type_desc = 'DATABASE_ROLE' AND name = @Role_Name)
BEGIN
  RAISERROR ('Database role specified (%s) does not exist in database %s.',16,1,@Role_Name,@Database_Name);
  RETURN;
END

BEGIN TRY

-- Check if the user exists
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @Login_Name)
BEGIN

  RAISERROR('User %s does not exist in database %s, will create it.',10,1,@Login_Name,@Database_Name) WITH NOWAIT;
  
  SET @SQL = 'CREATE USER ' + QUOTENAME(@Login_Name) + 'FOR LOGIN ' + QUOTENAME(@Login_Name);
  EXEC @RC = sp_executesql @SQL;
  IF @RC <> 0 BEGIN
    RAISERROR ('Error creating database user. Aborting.',16,1);
  END 
  
  RAISERROR('User %s created successfully in database %s.',10,1,@Login_Name,@Database_Name) WITH NOWAIT;
  
END
ELSE
  RAISERROR('User %s already exists in database %s, moving on.',10,1,@Login_Name,@Database_Name) WITH NOWAIT;

-- Add the user to the role (we do not need to check if it already is a member since sp_addrolemember handles that
EXEC @RC = sp_addrolemember @rolename = @Role_Name, @membername = @Login_Name;
IF @RC <> 0 BEGIN
  RAISERROR ('Error adding user %s to role %s in database %s. Aborting.',16,1,@Login_Name,@Role_Name,@Database_Name);
END 

RAISERROR('User %s added successfully to role %s in database %s.',10,1,@Login_Name,@Role_Name,@Database_Name) WITH NOWAIT;


END TRY
BEGIN CATCH

  SET @Error_Message = ERROR_MESSAGE();
  SET @Error_Severity = ERROR_SEVERITY();
  
  RAISERROR('Operation did not complete successfully, please see the following errors.',10,1) WITH NOWAIT;
  RAISERROR(@Error_Message,@Error_Severity,1);
  
END CATCH
 