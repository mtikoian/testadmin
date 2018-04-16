IF EXISTS
       (SELECT *
          FROM INFORMATION_SCHEMA.ROUTINES
         WHERE SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'Upd_All_Access_Flag')
    BEGIN
        DROP PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_All_Access_Flag;
        PRINT '<<< DROPPED PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_All_Access_Flag >>>';
    END;
GO

CREATE PROCEDURE $(BIS_SECURITY_SCHEMA).[Upd_All_Access_Flag] 
		@pi_Secured_User_ID int = NULL,
		@pi_All_Access_Flag bit,
		@pi_Update_User_ID INT,
		@po_Error_Reason_Cd INT OUTPUT
    
as
    
/*
=pod

=begin text

   ================================================================================
   Name : Upd_All_Access_Flag
   Author : HJones 02/29/2012 
   Description : Grants or Revokes All Access to the specified user.

   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Secured_User_ID                  INPUT  Secured_User_ID       
   @pi_All_Access_Flag					INPUT  Switch to indicate if all access should be granted or revoked.     
   @pi_Update_User_ID					INPUT  User Id of user updating the user rules.  
   @po_Error_Reason_Cd                  OUTPUT Error reason code               
   
   --------------------------------------------------------------------------------
   Error Reason codes: 

       1 - No rows qualified for the select
      10 - @pi_Secured_User_ID is not valued.
      11 - @pi_Secured_User_ID does not exist.
      12 - @pi_All_Access_Flag is not valued.

   --------------------------------------------------------------------------------
   Return Value: 
		Success : 0
		Failure : Non zero

   Revisions :
   --------------------------------------------------------------------------------
   Ini    | Date          | Description
   --------------------------------------------------------------------------------
   HJones  02/29/2012        Initial version.
   ================================================================================

=end text

=cut
*/
DECLARE @sql_error   INT;

DECLARE @RC INT 

DECLARE @ReturnCode INT 

DECLARE @User_Rule_ID INT

DECLARE @Counter INT

SET @ReturnCode = 0;
SET @po_Error_Reason_Cd = 0;

BEGIN TRY
    -- Make sure the secured user is valued and exists
    IF (@pi_Secured_User_ID is null)
    BEGIN
       SET @po_Error_Reason_Cd = 10;
       SET @ReturnCode         = 1;
    END;
	
	IF (@pi_Secured_User_ID is not null)
	SELECT @Counter = count(*) 
            FROM BISSec.SECURED_USER
            WHERE Secured_User_ID = @pi_Secured_User_ID;
            IF (@Counter <> 1)
            BEGIN
               SET @po_Error_Reason_Cd = 11;
               SET @ReturnCode         = 1;
            END;
	
	-- Make sure the all access switch is valued
    IF (@pi_All_Access_Flag is null)
    BEGIN
       SET @po_Error_Reason_Cd = 12;
       SET @ReturnCode         = 1;
    END;
	
   -- If we did not pass validation of the parameters, set the reason code and return value.
    IF ((@po_Error_Reason_Cd <> 0) OR (@ReturnCode <> 0))
    BEGIN
        RETURN @ReturnCode;
    END;

    -- Start the transaction
    BEGIN TRANSACTION;

	DELETE FROM BISSec.USER_RULE WHERE Secured_User_ID = @pi_Secured_User_ID;

	IF (@pi_All_Access_Flag = 1)
	BEGIN
        EXECUTE @RC = BISSec.Add_USER_RULE @pi_Secured_User_ID, 1, NULL, NULL, 1, @pi_Update_User_ID, @User_Rule_ID OUTPUT, @po_Error_Reason_Cd OUTPUT 
	END;  
	
	-- Commit the transaction
    COMMIT TRANSACTION;
	
END TRY
BEGIN CATCH
    -- Capture the sql error number to return to the caller
    SET @ReturnCode = ERROR_NUMBER();

        -- Roll back any active or uncommittable transactions before
        -- inserting information in the ErrorLog.
        -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
        -- XACT_STATE = -1 The transaction is in an uncommittable state
        IF XACT_STATE () <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
END CATCH

        RETURN @ReturnCode;
 

GO

IF EXISTS
       (SELECT *
          FROM INFORMATION_SCHEMA.ROUTINES
         WHERE SPECIFIC_SCHEMA = '$(BIS_SECURITY_SCHEMA)' AND ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'Upd_All_Access_Flag')
    BEGIN
        PRINT '<<< CREATED PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_All_Access_Flag >>>';
    END
ELSE
    BEGIN
        PRINT '<<< FAILED CREATING PROCEDURE $(BIS_SECURITY_SCHEMA).Upd_All_Access_Flag >>>';
    END;
GO
