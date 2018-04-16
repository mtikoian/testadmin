USE NetikIP
GO

/***
================================================================================
 Name        : dw_function_item
 Author      : Pkjha - 06/18/2013
 Description : Update statement for the dw_function_item Table.
===============================================================================
 Revisions    :
--------------------------------------------------------------------------------
 Initial			|   Date		|	 Description
 Pkjha		           06/18/2013		 Initial Version
 Pkjha		           07/18/2013		 Changes the prnt_fn_id,fn_seq_num for the fn_id 'ProjInc'
--------------------------------------------------------------------------------
================================================================================
***/

BEGIN
DECLARE @fn_id CHAR(10)

BEGIN TRY 
    
  
SET @fn_id = 'ProjInc'

     UPDATE dbo.dw_function_item
        SET prnt_fn_id = 'IPCTran',
            fn_seq_num = 50
      WHERE fn_id = @fn_id 

	IF @@rowcount > 0
	BEGIN
		PRINT 'Column prnt_fn_id and fn_seq_num of Table dw_function_item has updated.'
	END
END TRY

BEGIN CATCH 
	
DECLARE @errmsg   NVARCHAR(2100),   
		@errsev   INT,   
		@errstate INT,
        @errno    INT;    

	SET @errno    =  Error_number()   
	SET @errmsg   =  'Error in dbo.dw_function_item: ' + Error_message()   
	SET @errsev   =  Error_severity()   
	SET @errstate =  Error_state(); 
	RAISERROR(@errmsg,@errsev,@errstate);    
END CATCH
END

