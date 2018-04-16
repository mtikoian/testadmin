/* 
Name:			Tables\cds.TransactionStatusType.Table.sql              
Author:			Rob McKenna    
Description:	Rollback to DROP the TransactionStatusType table
History:
				20140227	Initial Version 
*/

BEGIN TRY
	--TransactionStatusType
	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_TransactionStatusType_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[TransactionStatusType] DROP CONSTRAINT [DF_TransactionStatusType_Created]
			PRINT 'cds.DF_TransactionStatusType_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_TransactionStatusType_Created NOT DROPPED'
		
	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_TransactionStatusType_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[TransactionStatusType] DROP CONSTRAINT [DF_TransactionStatusType_LastUpdate]
			PRINT 'cds.DF_TransactionStatusType_LastUpdat DROPPED'
		END
	ELSE
		PRINT 'cds.DF_TransactionStatusType_LastUpdat NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.TransactionStatusType') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[TransactionStatusType]
			PRINT 'TABLE cds.TransactionStatusType DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.TransactionStatusType DOES NOT EXIST'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error dropping objects' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO