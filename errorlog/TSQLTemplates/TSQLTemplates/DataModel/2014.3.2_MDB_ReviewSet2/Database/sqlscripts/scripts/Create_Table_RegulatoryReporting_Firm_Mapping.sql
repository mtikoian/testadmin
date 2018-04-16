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
			   AND Table_name = 'RegulatoryReporting_Firm_Mapping'  
	)
	BEGIN
		DROP Table dbo.RegulatoryReporting_Firm_Mapping
		PRINT 'Table dbo.RegulatoryReporting_Firm_Mapping has been dropped.'
	END
GO

/*
================================================================================
 Name        : RegulatoryReporting_Firm_Mapping 
 Author      : Venu Perala  - 02/24/2014
 Description : Table used for store to Regulatory Reporting firm Data for each client.
			   Data will inserted from Regulatory Reporting applciation(Form PF).
			   RegulatoryReporting_Firm_Mapping_Id INT	- Identity Column
			   RegulatoryReporting_Firm_Id INT	- FK to RegulatoryReporting_Firm table
			   Project_Id smallint not nul		- Project Id reference to RegulatoryReporting_Lookup table; User pick from dropdown
			   Create_User_Id        varchar(30)     NOT NULL, --Created user id
               Create_Dt             datetime        NOT NULL, --Created date and time               
               Update_User_Id        varchar(30)     NOT NULL, --updated userid
               Update_Dt             datetime        NOT NULL  --updated date and time
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

	CREATE TABLE dbo.RegulatoryReporting_Firm_Mapping
	(
		RegulatoryReporting_Firm_Mapping_Id INT identity (1,1) not null,
		RegulatoryReporting_Firm_Id int not null,
		Project_Id smallint not null,
        Create_User_Id        varchar(30)     NOT NULL, --Created user id
        Create_Dt             datetime        NOT NULL, --Created date and time               
        Update_User_Id        varchar(30)     NOT NULL, --updated userid
        Update_Dt             datetime        NOT NULL  --updated date and time
		CONSTRAINT [PK_RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm_Mapping_Id] PRIMARY KEY CLUSTERED 
		(
		RegulatoryReporting_Firm_Mapping_Id ASC
		),

		CONSTRAINT [UQ__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm_Id_Project_Id] UNIQUE NONCLUSTERED 
		(RegulatoryReporting_Firm_Id,Project_Id)
	)



	PRINT 'Adding constraints to TABLE dbo.RegulatoryReporting_Firm_Mapping'
    ALTER TABLE dbo.RegulatoryReporting_Firm_Mapping ADD
	    CONSTRAINT DF__RegulatoryReporting_Firm_Mapping__Create_User_Id default SYSTEM_USER for Create_User_Id,
		CONSTRAINT DF__RegulatoryReporting_Firm_Mapping__Create_Dt default GETDATE() for Create_Dt,    
        CONSTRAINT DF__RegulatoryReporting_Firm_Mapping__Update_User_Id default SYSTEM_USER for Update_User_Id,
        CONSTRAINT DF__RegulatoryReporting_Firm_Mapping__Update_Dt default GETDATE() for Update_Dt
                                                
    

	--FK CUST_ID to CUST
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm_Mapping'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm_Mapping WITH CHECK ADD CONSTRAINT FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm FOREIGN KEY(RegulatoryReporting_Firm_Id)
			REFERENCES dbo.RegulatoryReporting_Firm(RegulatoryReporting_Firm_Id)

			PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm NOT created'

	--FK FundInvestor to FundInvestor
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm_Mapping'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm_Mapping CHECK CONSTRAINT FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm

			PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__RegulatoryReporting_Firm NOT created'


	--FK Project_Id to dbo.RegulatoryReporting_Lookup
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm_Mapping'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm_Mapping WITH CHECK ADD CONSTRAINT FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup FOREIGN KEY(Project_Id)
			REFERENCES dbo.RegulatoryReporting_Lookup(Project_Id)

			PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup NOT created'

	--FK Project_Id to dbo.RegulatoryReporting_Lookup
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'dbo.FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup') 
		AND parent_object_id = OBJECT_ID(N'dbo.RegulatoryReporting_Firm_Mapping'))
		
		BEGIN
			ALTER TABLE dbo.RegulatoryReporting_Firm_Mapping CHECK CONSTRAINT FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup

			PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup created'
		END
	ELSE
		PRINT 'dbo.FK__RegulatoryReporting_Firm_Mapping__Project_Id__RegulatoryReporting_Lookup NOT created'



	  PRINT 'TABLE dbo.RegulatoryReporting_Firm Created successfully' 

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

































 



