 /*
 *
 * Tracker#236 Vijendra Kotian 03/06/2012 - Created: 03/06/2012 Vijendra Kotian -Tracker 236.
 * SELECT permission is granted to the role 'iag_strataweb_role'
 * Note: This script assumes that the login name 'iag_strataweb_user' is already created.User 'iag_strataweb_user' is already created. Role 'iag_strataweb_role' is already created. 
 * updated:04/03/2012 Vijendra Kotian -added try catch block to display error message.
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
 
	--execute 'select' grant on the role

	PRINT 'Granting SELECT permission to Role [$(ROLE_NAME)] ...';
	grant select on aga.vw_ActGrpFlattened to [$(ROLE_NAME)];
	PRINT 'Granting SELECT permission on view aga.vw_ActGrpFlattened  to Role [$(ROLE_NAME)] is successful.';
	grant select on  bisAdmin.ADMIN_COMMAND_LOG to [$(ROLE_NAME)];
	PRINT 'Granting SELECT permission on table bisAdmin.ADMIN_COMMAND_LOG  to Role [$(ROLE_NAME)] is successful.';
	grant select on schema::dbo to [$(ROLE_NAME)];	 		
	PRINT 'Granting SELECT permission on dbo schema to Role [$(ROLE_NAME)] is successful.';
	grant execute on aga.ActGrpFlattened to [$(ROLE_NAME)];
	PRINT 'Granting EXECUTE permission on aga.ActGrpFlattened to Role [$(ROLE_NAME)] is successful.';
	grant select on schema::BISSec to [$(ROLE_NAME)];
	PRINT 'Granting SELECT permission on BISSec schema to Role [$(ROLE_NAME)] is successful.';
	grant execute on aga.GetEntitledGroups to [$(ROLE_NAME)];
	PRINT 'Granting EXECUTE permission on aga.GetEntitledGroups to Role [$(ROLE_NAME)] is successful.';

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
    SET @ErrMsg = ERROR_MESSAGE();
  	SET @ErrNum = ERROR_SEVERITY();
    RAISERROR(@ErrMsg,@ErrNum,1);
			
end catch