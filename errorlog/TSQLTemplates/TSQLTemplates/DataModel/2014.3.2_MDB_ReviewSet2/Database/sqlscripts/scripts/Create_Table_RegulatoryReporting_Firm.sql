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
			   CUST_ID CHAR(12) not null	    - Customer Id, refernce to CUST table; user pick from drop down
			   Client_Firm_Id		 int not null		- User Input firm Id 
			   Firm_Nm varchar(200)  not null - Firm Name user input.
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

	CREATE TABLE dbo.RegulatoryReporting_Firm
	(
		RegulatoryReporting_Firm_Id INT identity (1,1) not null,
		CUST_ID				  CHAR(12)		  NOT NULL,
		Client_Firm_Id		  int			  NOT NULL,
		Firm_Nm				  varchar(200)	  NOT NULL,	
        Create_User_Id        varchar(30)     NOT NULL, --Created user id
        Create_Dt             datetime        NOT NULL, --Created date and time               
        Update_User_Id        varchar(30)     NOT NULL, --updated userid
        Update_Dt             datetime        NOT NULL  --updated date and time

		CONSTRAINT PK_RegulatoryReporting_Firm__RegulatoryReporting_Firm_Id PRIMARY KEY CLUSTERED 
		(
			RegulatoryReporting_Firm_Id ASC
		),
		CONSTRAINT UQ__RegulatoryReporting_Firm__CUST_ID_Client_Firm_Id UNIQUE NONCLUSTERED(CUST_ID,Client_Firm_Id),
		
		

	)

	PRINT 'Adding constraints to TABLE dbo.RegulatoryReporting_Firm'
    ALTER TABLE dbo.RegulatoryReporting_Firm ADD
	    CONSTRAINT DF__RegulatoryReporting_Firm__Create_User_Id default SYSTEM_USER for Create_User_Id,
		CONSTRAINT DF__RegulatoryReporting_Firm__Create_Dt default GETDATE() for Create_Dt,    
        CONSTRAINT DF__RegulatoryReporting_Firm__Update_User_Id default SYSTEM_USER for Update_User_Id,
        CONSTRAINT DF__RegulatoryReporting_Firm__Update_Dt default GETDATE() for Update_Dt
                                                
                                              

		
   
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
			   AND Table_name = 'RegulatoryReporting_Firm'  
	)
	BEGIN		
		PRINT 'Table dbo.RegulatoryReporting_Firm has been created.'
	END
ELSE
	BEGIN		
		PRINT 'Table dbo.RegulatoryReporting_Firm has not been created.'
	END
GO

































 



