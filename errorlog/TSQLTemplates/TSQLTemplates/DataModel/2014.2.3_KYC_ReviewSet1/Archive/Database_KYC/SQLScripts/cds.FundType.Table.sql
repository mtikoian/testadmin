/* 
Name: Tables\cds.FundType.Table.sql
Author: Rob McKenna (rmckenna)
Description: Know Your Client Data Services (cds) Object Modify Script
History:
20140225  Create table FundType, a lookup table containg types of funds, ex: Fund, Class, Series
*/

BEGIN TRY

	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.FundType') AND type in (N'U'))
		BEGIN
			CREATE TABLE cds.FundType(
				FundTypeCode int NOT NULL,
				Value varchar(30) NOT NULL,
				SortOrder int NULL,
				Created datetime NOT NULL CONSTRAINT DF_FundType_Created  DEFAULT (getdate()),
				CreateUser varchar(30) NOT NULL,
				LastUpdate datetime NOT NULL CONSTRAINT DF_FundType_LastUpdate  DEFAULT (getdate()),
				UpdateUser varchar(30) NOT NULL,
				CONSTRAINT PK_FundType PRIMARY KEY CLUSTERED
				( FundTypeCode ASC )
					WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];
					
			PRINT 'cds.FundType table created'
		END
	ELSE
		PRINT 'cds.FundType table NOT created'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error creating table ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 