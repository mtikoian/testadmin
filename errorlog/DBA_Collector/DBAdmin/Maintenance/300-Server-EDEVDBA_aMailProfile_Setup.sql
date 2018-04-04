/* 2005,2008,2008R2,2012 */

/*****************************************************************************************************
 * Auto-Install Script Template
 *----------------------------------------------------------------------------------------------------
 *
 * Instructions:
 * The top line of this document must contain a commented comma seperated list of the versions of SQL 
 * that this script applies to.  Example: "/* 2000,2005,2008,2008R2 */"
 * 
 * This script template is only suitable for statements that are to be executed as part of the 
 * auto-install process and must run only against the server instance being installed.
 *
 * The script must terminate each statement using the ";" operator and must not contain the keyword 
 * "GO". 
 *
 * This template does not support scripts that need to be called with parameters.  If your script 
 * requires parameters please use the PowerShell Script template.
 *
 * Scripts must be named using the following pattern:
 * level-level name-script name
 *
 * level: The numeric level of the script.  This controls the order in which scripts are applied to
 *		  ensure that dependancies are not broken.  See Level list for the possible values.
 *
 * level name: The friendly name of the level.  This is meant to makes the scripts more easily
 *			   identifiable.  See Level list for the possible values.
 *
 * script name: The friendly name of the script.  This should be short, but detailed enought to tell
 *				what the script will accomplish.
 *
 * Example: "300-Server-AddExtendedProperty.sql" - Server level script that adds the DBA Extended
 *			property to the master and model databases
 *
 * Level List:
 * ---------------
 * 300 - Server - Scripts that create/alter/drop server level objects and settings
 * 400 - Database - Scripts that create/alter/drop databases and settings
 * 500 - Table - Scripts that create/alter/drop tables, schemas, users, roles
 * 600 - View - Scripts that create/alter/drop views, indexes, or other objects with table dependancies
 * 700 - Procedure - Scripts that create/alter/drop objects with table/view dependancies
 * 800 - Agent - Scripts that create/alter/drop agent jobs, job steps, job schedules, notifications, etc
 * 900 - Management - Scripts that are run last that pertain to management of the instance
 *****************************************************************************************************/
 
/*****************************************************************************************************
 * Script Information
 *----------------------------------------------------------------------------------------------------
 *		Author: Josh Feierman
 *		  Date: 3/14/2012
 * Description: Sets up the standard EDEV DBA mail profile.
 *	   History:
 *****************************************************************************************************/
-- Setup eDev DB Mail profile --
BEGIN TRY

    EXEC sp_configure 'Show Advanced Options',1;
    RECONFIGURE WITH OVERRIDE;
    EXEC sp_configure 'Database Mail XPs', 1;
    RECONFIGURE WITH OVERRIDE;
    
    DECLARE @profile_name sysname,
        @account_name sysname,
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
	    @display_name NVARCHAR(128);

    -- Profile name. Replace with the name for your profile
    SET @profile_name = 'EDEV_DBA_Profile';

    -- Account information. Replace with the information for your account.

    SET @account_name = 'EDEV_DBA_Account';
    SET @SMTP_servername = 'smtp.corp.seic.com';
    SET @email_address = 'EDEV-DBA-Alerts@seic.com';
    SET @display_name = 'EDEV DBA Alerts';


    -- Verify the specified account and profile do not already exist.
    IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profile_name)
    BEGIN
      RAISERROR('The specified Database Mail profile (EDEV_DBA_Profile) already exists.', 16, 1);
    END;

    IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @account_name )
    BEGIN
     RAISERROR('The specified Database Mail account (EDEV_DBA_Account) already exists.', 16, 1) ;
    END;

    -- Start a transaction before adding the account and the profile
    BEGIN TRANSACTION ;

    DECLARE @rv INT;

    -- Add the account
    EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
        @account_name = @account_name,
        @email_address = @email_address,
        @display_name = @display_name,
        @mailserver_name = @SMTP_servername;

    IF @rv<>0
    BEGIN
        RAISERROR('Failed to create the specified Database Mail account (EDEV_DBA_Account).', 16, 1) ;
    END

    -- Add the profile
    EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
        @profile_name = @profile_name ;

    IF @rv<>0
    BEGIN
        RAISERROR('Failed to create the specified Database Mail profile (EDEV_DBA_Profile).', 16, 1);
    END;

    -- Associate the account with the profile.
    EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
        @profile_name = @profile_name,
        @account_name = @account_name,
        @sequence_number = 1 ;

    IF @rv<>0
    BEGIN
        RAISERROR('Failed to associate the speficied profile with the specified account (EDEV_DBA_Account).', 16, 1) ;
    END;

    COMMIT TRANSACTION;
    
END TRY
BEGIN CATCH

    RAISERROR('Error occurred setting up database mail options.',16,1)
    
    DECLARE @errno INT,
                @errmsg VARCHAR(100),
                @errsev INT,
                @errstate INT ;

    SELECT   @errno = ERROR_NUMBER(),
             @errmsg = ERROR_MESSAGE(),
             @errsev = ERROR_SEVERITY(),
             @errstate = ERROR_STATE() ;
             
    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH
