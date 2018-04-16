USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS 
	(
		SELECT 1 
		FROM   information_schema.Tables 
		WHERE  Table_schema   = 'dbo' 
			   AND Table_name = 'RegulatoryReporting_Firm'  
	)
	BEGIN
		DROP Table dbo.RegulatoryReporting_Firm
		PRINT 'Table dbo.RegulatoryReporting_Firm has been dropped.'
	END
GO

/*
================================================================================
 Name        : RegulatoryReporting_Firm 
 Author      : Venu Perala  - 02/24/2014
 Description : Table used for store to Regulatory Reporting firm Data for each client.
			   Data will inserted from Regulatory Reporting applciation(Form PF).
			   RegulatoryReporting_Firm_Id INT	- Identity Column
			   Project_Id smallint not nul		- Project Id reference to RegulatoryReporting_Lookup table; User pick from dropdown
			   CUST_ID CHAR(12) not null	    - Customer Id, refernce to CUST table; user pick from drop down
			   Firm_Id char(20) not null		- User Input firm Id 
			   Firm_Name varchar(200)  not null - Firm Name user input.
===============================================================================
		
 Revisions    :
--------------------------------------------------------------------------------
 Ini		    |   Date		|	 Description
 vperala		|	02/24/2014	|	 Initial Version
--------------------------------------------------------------------------------

================================================================================
*/ 

BEGIN   
  SET NOCOUNT ON

  BEGIN TRY

	CREATE TABLE dbo.RegulatoryReporting_Firm
	(
		RegulatoryReporting_Firm_Id INT identity (1,1) not null,
		Project_Id smallint not null,
		CUST_ID CHAR(12) not null,
		Firm_Id varchar(20) not null,
		Firm_Name varchar(200)  not null,	
		CONSTRAINT [PK_RegulatoryReporting_Firm__RegulatoryReporting_Firm_Id] PRIMARY KEY CLUSTERED 
		(
		RegulatoryReporting_Firm_Id ASC
		),

		CONSTRAINT [UQ__RegulatoryReporting_Firm__Project_Id_CUST_ID_Firm_Id] UNIQUE NONCLUSTERED 
		(Project_Id,CUST_ID,Firm_Id)
	)

	--FK CUST_ID to CUST
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm__CUST_ID_CUST') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm WITH CHECK ADD CONSTRAINT FK__RegulatoryReporting_Firm__CUST_ID_CUST FOREIGN KEY(CUST_ID)
			REFERENCES dbo.CUST(CUST_ID)

			PRINT 'dbo.FK__RegulatoryReporting_Firm__CUST_ID_CUST created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm__CUST_ID_CUST NOT created'

	--FK FundInvestor to FundInvestor
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm__CUST_ID_CUST') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm CHECK CONSTRAINT FK__RegulatoryReporting_Firm__CUST_ID_CUST

			PRINT 'dbo.FK__RegulatoryReporting_Firm__CUST_ID_CUST created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm__CUST_ID_CUST NOT created'


	--FK Project_Id to dbo.RegulatoryReporting_Lookup
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm WITH CHECK ADD CONSTRAINT FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup FOREIGN KEY(Project_Id)
			REFERENCES dbo.RegulatoryReporting_Lookup(Project_Id)

			PRINT 'dbo.FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup NOT created'

	--FK Project_Id to dbo.RegulatoryReporting_Lookup
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm CHECK CONSTRAINT FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup

			PRINT 'dbo.FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm__Project_Id__RegulatoryReporting_Lookup NOT created'



	

END TRY          
                                                 
BEGIN CATCH   

	DECLARE @ErrNum			INT          
	DECLARE @ErrMsg			NVARCHAR(2100)
	DECLARE @ErrSeverity	INT
	DECLARE @ErrState		INT      
   
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrSeverity = ERROR_SEVERITY()  
	SET @ErrState   =  ERROR_STATE()
	RAISERROR(@ErrMsg, @ErrSeverity, @ErrState) 
                                            
END CATCH  

END 

GO

IF  EXISTS 
	(
		SELECT 1 
		FROM   information_schema.Tables 
		WHERE  Table_schema   = 'dbo' 
			   AND Table_name = 'FormPFFirmData'  
	)
	BEGIN		
		PRINT 'Table dbo.FormPFFirmData has been created.'
	END
ELSE
	BEGIN		
		PRINT 'Table dbo.FormPFFirmData has not been created.'
	END


GO

































 



