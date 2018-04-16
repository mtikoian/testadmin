---------------------------------------------------------------------------
-- Project: AGA 12.1 Release- Grant initial Permissions
-- @owner vkotian
--Created: 04/03/2012
--
-- Description:
-- This script creates/modifies role AccountGroup and grants all the required permissions
-- needed for running AGA   
--    
-- NOTE:
--	Updated : vkotian 4/5/2012-role is created if it does not exist
--
--  3/5/2013  HJones  added 5 additional grants required by the AGA Loader.
-- ---------------------------------------------------------------------------


USE [$(DBNAME)]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
declare @ErrMsg                 varchar(1000) ;
declare @ErrNum                 int;
declare @CrLf                   char(2);
set nocount on;
    
    set @ErrMsg = '';
    set @ErrNum = 0;
    set @CrLf   = char(13) + char(10);
    
    print '***** Project: AGA 12.1 Release- Grant initial Permissions *****';
    print 'SQL Start Time: ' +  + convert(varchar(30), getdate(), 121);   
    print '';
begin try
	begin transaction;
	print 'Transaction is started';
    print ''
  /** check if role exists . If not create the role **/
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
	/**** assigning permissions starts here ********/
	 grant execute on schema::aga to [$(ROLE_NAME)];
	 grant select on schema::dbo to [$(ROLE_NAME)];
	 GRANT EXECUTE ON OBJECT::BISSec.GetEntitledAccounts TO [$(ROLE_NAME)]
	 GRANT EXECUTE ON OBJECT::BISSec.ValidateAccountEntitlement TO [$(ROLE_NAME)]
--3/5/2013 begin  hjones
	GRANT SELECT ON OBJECT::BISSEC.Organization TO [$(ROLE_NAME)]   
	GRANT SELECT ON SCHEMA::aga TO [$(ROLE_NAME)]
	GRANT INSERT ON SCHEMA::aga TO [$(ROLE_NAME)]
	GRANT UPDATE ON SCHEMA::aga TO [$(ROLE_NAME)]
	GRANT DELETE ON SCHEMA::aga TO [$(ROLE_NAME)]
--3/5/2013 end  hjones	
	
	
	/**** assigning permissions  ends here ********/	
	commit transaction;
    print '';
    print 'Transaction is committed'    ;
    
    print '';

end try
begin catch
    if @@trancount > 0 begin
        rollback transaction;
        print 'Transaction is rolled back';
    end
        
    
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
GO