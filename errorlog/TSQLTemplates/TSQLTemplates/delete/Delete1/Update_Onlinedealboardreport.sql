USE NetikIP
GO
/***********************************************************************************
Author:          VBANDI
Description:	 Update records for KYC Online Dealboard report
Scripted Date:   04.14.2014
************************************************************************************/
BEGIN
	BEGIN TRY
		UPDATE FLD_IN_QRY
		SET data_typ_num = 4
		WHERE internl_nme = 'nav_date'

		UPDATE fld_def
		SET data_typ_num = 4
		WHERE internl_name = 'nav_date'

		IF @@rowcount > 0
		BEGIN
			PRINT 'Updated records successfully.'
		END
	END TRY

	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(2100)
			,@errsev INT
			,@errstate INT
			,@errno INT;

		SET @errno = Error_number()
		SET @errmsg = 'Error while updating records ' + Error_message()
		SET @errsev = Error_severity()
		SET @errstate = Error_state();

		RAISERROR (
				@errmsg
				,@errsev
				,@errstate
				);
	END CATCH
END
