USE NetikIP
GO
/*

 File Name				: CREATE_ROLLBACK_FOR_UPDATE_GRID_WIDTH_NUM_FOR_FLD_IN_QRY.sql
 Description   			: Create Rollback script for UPDATE_GRID_WIDTH_NUM_FOR_FLD_IN_QRY.sql
 Created By    			: SVashistha
 Created Date  			: 03/21/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
*/

PRINT ''
PRINT '----------------------------------------'
PRINT 'START CREATE_ROLLBACK_SCRIPT_UPDATE_GRID_WIDTH_NUM_FOR_FLD_IN_QRY SCRIPT FOR FLD_IN_QRY'
PRINT '----------------------------------------'

BEGIN TRY
	
	BEGIN TRAN
		--FLD_IN_QRY
			
SELECT 
	'UPDATE 
			DBO.FLD_IN_QRY 
		SET 
			GRID_WIDTH_NUM=0  
		WHERE 
			RTRIM(LTRIM(INTERNL_NME)) =''FOF_Pricing_Stmt_DocPop_URL'' 
		AND 
			ENTITY_NUM = 10600 
		AND 
			GRID_WIDTH_NUM=15 
		AND 
			INQ_NUM='+CAST(INQ_NUM AS VARCHAR(20))+'' 

FROM  FLD_IN_QRY
WHERE 
	INTERNL_NME='FOF_Pricing_Stmt_DocPop_URL'
		AND 
			ENTITY_NUM=10600
		AND
			FLD_NUM=4029
		AND
			GRID_WIDTH_NUM=0

	COMMIT TRAN	
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	SELECT	ERROR_NUMBER()		as ErrorNumber,
			ERROR_MESSAGE()		as ErrorMEssage,
			ERROR_LINE()		as ErrorLine,
			ERROR_STATE()		as ErrorState,
			ERROR_SEVERITY()	as ErrorSeverity,
			ERROR_PROCEDURE()	as ErrorProcedure;
END CATCH;
PRINT '';
PRINT 'END OF CREATE_ROLLBACK_FOR_UPDATE_GRID_WIDTH_NUM_FOR_FLD_IN_QRY SCRIPT FOR FLD_IN_QRY';
PRINT '----------------------------------------';