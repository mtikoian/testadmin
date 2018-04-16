/* 
Name:			cds.FundType.Table.sql              
Author:			Rob McKenna    
Description:	Rollback to DROP the FundType table
History:
				20140227	Initial Version 
*/

BEGIN TRY

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_FundType_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[FundType] DROP CONSTRAINT [DF_FundType_Created]
			PRINT 'cds.DF_FundType_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_FundType_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_FundType_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[FundType] DROP CONSTRAINT [DF_FundType_LastUpdate]
			PRINT 'cds.DF_FundType_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_FundType_Created NOT DROPPED'
		
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.FundType') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[FundType]
			PRINT 'TABLE cds.FundType DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.FundType DOES NOT EXIST'

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