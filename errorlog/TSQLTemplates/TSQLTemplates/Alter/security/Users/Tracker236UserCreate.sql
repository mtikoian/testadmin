 /*
 *
 * Tracker#236 Vijendra Kotian 03/06/2012 - Created: 03/06/2012 Vijendra Kotian -Tracker 236.User 'iag_strataweb_user' is created. Role 'iag_strataweb_role' is created. 
 * User 'iag_strataweb_user' is added to Role 'iag_strataweb_role'.	SELECT permission is granted to the role 'iag_strataweb_role'
 * Note: This script assumes that the login name 'iag_strataweb_user' is already created for SQL login for use and it is granted with 'use any database' permission.
 *  
*/
declare @ErrMsg                 varchar(1000) ;
declare @ErrNum                 int;
declare @CrLf                   char(2);
set nocount on;
    
    set @ErrMsg = '';
    set @ErrNum = 0;
    set @CrLf   = char(13) + char(10);
begin try    
 IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$(USER_NAME)')
 	BEGIN
 		
	 		PRINT 'User [$(USER_NAME)] does exist ';
			-- DROP USER [$(USER_NAME)]
			-- CREATE USER [$(USER_NAME)] FOR LOGIN [$(USER_NAME)] 
			-- PRINT 'User [$(USER_NAME)] creation successful.'; 
		
	END
ELSE
  BEGIN
    PRINT 'User [$(USER_NAME)] does not exist, creating the user...';
    CREATE USER [$(USER_NAME)] FOR LOGIN [$(USER_NAME)] 
    PRINT 'User [$(USER_NAME)] creation successful.';    
  END;
end try
begin catch
	select  @ErrMsg =   'An error has occurred' + @CrLf +
                    'Error Number is      : ' + cast(error_number() + @ErrNum as varchar(10)) + @CrLf +
                'Error Message is     : ' + case when @ErrMsg <> '' then @ErrMsg else error_message() end + @CrLf +
                'Error Line Number is : ' + cast(error_line() as varchar(10)) + @CrLf + 
                'Error State is       : ' + cast(error_state() as varchar(10)) + @CrLf + 
                'Error Severity is    : ' + cast(error_severity() as varchar(10));
                    
 select @ErrMsg;
  SET @ErrMsg = ERROR_MESSAGE();
  	SET @ErrNum = ERROR_SEVERITY();
    RAISERROR(@ErrMsg,@ErrNum,1);
	
end catch	
begin try 
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$(ROLE_NAME)')
 	BEGIN
 		PRINT 'Role [$(ROLE_NAME)] does exist ';
		-- DROP ROLE [$(ROLE_NAME)]
		-- CREATE ROLE [$(ROLE_NAME)] authorization [$(USER_NAME)]
		-- PRINT 'Role [$(ROLE_NAME)] creation successful.'; 
	END
ELSE
  BEGIN
    PRINT 'Role [$(ROLE_NAME)] does not exist, creating the role...';
    CREATE ROLE [$(ROLE_NAME)] authorization [$(USER_NAME)]
    PRINT 'Role [$(ROLE_NAME)] creation successful.';    
  END;
end try
begin catch
	select  @ErrMsg =   'An error has occurred' + @CrLf +
                    'Error Number is      : ' + cast(error_number() + @ErrNum as varchar(10)) + @CrLf +
                'Error Message is     : ' + case when @ErrMsg <> '' then @ErrMsg else error_message() end + @CrLf +
                'Error Line Number is : ' + cast(error_line() as varchar(10)) + @CrLf + 
                'Error State is       : ' + cast(error_state() as varchar(10)) + @CrLf + 
                'Error Severity is    : ' + cast(error_severity() as varchar(10));
                    
 select @ErrMsg;
  SET @ErrMsg = ERROR_MESSAGE();
  	SET @ErrNum = ERROR_SEVERITY();
    RAISERROR(@ErrMsg,@ErrNum,1);
	
end catch	

--Add the created user to the role.

PRINT ' Assigning User [$(USER_NAME)] Role [$(ROLE_NAME)] ...';
begin try
	EXEC sp_addrolemember [$(ROLE_NAME)], [$(USER_NAME)];
end try
begin catch
	print 'User [$(USER_NAME)] already assigned to Role [$(ROLE_NAME)] ';
	select  @ErrMsg =   'An error has occurred' + @CrLf +
                        'Error Number is      : ' + cast(error_number() + @ErrNum as varchar(10)) + @CrLf +
		                'Error Message is     : ' + case when @ErrMsg <> '' then @ErrMsg else error_message() end + @CrLf +
		                'Error Line Number is : ' + cast(error_line() as varchar(10)) + @CrLf + 
		                'Error State is       : ' + cast(error_state() as varchar(10)) + @CrLf + 
		                'Error Severity is    : ' + cast(error_severity() as varchar(10));
                        
     select @ErrMsg;
     -- no error thrown since [$(USER_NAME)] already assigned to Role [$(ROLE_NAME)]
			
end catch

