---------------------------------------------------------------------------
 ---------------------------------------------------------------------------



SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
declare @ErrMsg                 varchar(1000) ;
declare @ErrNum                 int;
declare @CrLf                   char(2);

DECLARE  @RC INT;
set nocount on;
use [$(DBNAME)]    ;
    set @ErrMsg = '';
    set @ErrNum = 0;
    set @CrLf   = char(13) + char(10);
    
     
    print 'SQL Start Time: ' +  + convert(varchar(30), getdate(), 121);   
    print '';
begin try
	begin transaction;
	print 'Transaction is started';
    print ''
  /** check if role exists . If not create the role **/
  IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'$(ROLE_NAME)' )
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
	  
	 /* by now user and role should exist . No need to check again. Add user to the role */
		-- Add the user to the role (we do not need to check if it already is a member since sp_addrolemember handles that
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