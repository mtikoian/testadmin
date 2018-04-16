USE NetikIP
GO

/*
 File Name				: Create_Table_Investor_Transaction_Workflow_Status.sql
 Description   			: This tables stored Investor_Transaction_Workflow_Status information
 Created By    			: VBANDI
 Created Date  			: 02/24/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
*/
PRINT ''
PRINT '----------------------------------------'
PRINT 'TABLE script for Investor_Transaction_Workflow_Status'
PRINT '----------------------------------------'

BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'Investor_Transaction_Workflow_Status'
			)
	BEGIN
		DROP TABLE dbo.Investor_Transaction_Workflow_Status;
		PRINT 'Table dbo.Investor_Transaction_Workflow_Status has been dropped.';
	END

	CREATE TABLE dbo.Investor_Transaction_Workflow_Status (
		Transaction_Id VARCHAR(15) NOT NULL			--Unique Id for each transaction in workflow
		,Client_Name VARCHAR(255) NOT NULL
		,Document_File_Path VARCHAR(255) NOT NULL
		,External_Investor_Id VARCHAR(12) NOT NULL
		,Institution_Type_ID INT NOT NULL   
		,Transaction_Status_Cd INT  NULL ----High Level Transaction Status For Managers  FK to Transaction_Status_Type table
		,Individual_Verification_Type_ID  INT  NULL		--Types of individual id FK to Verification_Type  table
		,Joint_Owner_Verification_Type_ID INT  NULL		--Types of join owner id FK to Verification_Type  table
		,POA_BO_Partner_Verification_Type_ID INT  NULL	--Types of Partner id FK to Verification_Type  table
		,Corporation_Type_ID INT  NULL		--Types of Corporation id FK to Corporation_Type table
		,AML_Due_Dt DATETIME NOT NULL			
		,AML_outstanding_Days INT NULL			--This will be a number between 0 and 999
		,ERISA_Status VARCHAR(50) NULL			-- Employee Retirement Income Security Act  Is the Investor ERISA/BPI Eligible?
		,Indemnification_Letter_FL char(2) NULL		--Verification check to see if Indemnification Letter was imported
		,W9_Document_FL char(2) NULL				--Vefification check to see if W-9 was imported
		,W8_Document_FL char(2) NULL				--Vefification check to see if W-8 was imported
		,Individual_ID_Verified_FL char(2) NULL		--Verification check to see if Individual ID from investor was imported
		,Joint_Owner_ID_Verified_FL char(2) NULL	--Verification check to see if Joint ID from investor was imported
		,POA_BO_Partner_ID_Verified_FL char(2) NULL	--Verification check to see if Partner ID was imported
		,Corporation_ID_Verified_FL char(2) NULL	--Verification check to see if Corporation ID was imported
		,Foreign_Bank_Certificate_Verified_FL char(2) NULL --Verification check to see if Foreign Bank Cert imported
		,Three_Year_Tax_Trust_Deed_Verified_FL char(2) NULL --Verification check to see if 3yr Tax-Trus Deed was imported
		,Trust_Beneficiary_List_Verified_FL char(2) NULL --Verification check to see if Trus Beneficiary List was imported
		,IRS_Letter_Verified_Verified_FL char(2) NULL --Verification check to see if IRS Letter was imported
		,Electronic_Delivery_Verified_FL char(7) NULL --Has SEI verified Electronic Delivery information?
		,Qualified_Purchaser_Verified_FL char(2) NULL  --Has SEI verified Qualified purchaser information?
		,Investor_Name_Verified_FL char(2) NULL		--Has SEI verified Name information?
		,Investor_Address_Verified_FL char(2) NULL		--Has SEI analyst received the investor address?
		,Investor_DOB_Verified_FL char(2) NULL		--Has SEI analyst received the investor DOB?
		,Investor_Signature_Verified_FL char(2) NULL		--Has SEI analyst received the investor Signature?
		,Investor_Wire_Instructions_Verified_FL char(2) NULL		--Has SEI analyst received the wire instructions?
		,Investor_Exempt_Verified_FL char(7) NULL
		,Investor_Tax_ID_Verified_FL char(2) NULL		--Has SEI verified Tax ID information?
		,Investor_Accredited_Verified_FL char(2) NULL		--Has SEI verified accredited investors?
		,Investor_Subscription_Compliance_Verified_FL char(2) NULL		--Has subscription compliance been verified by investor?
		,Investor_Enhanced_Name_Verified_FL char(2) NULL	--Is investor name consistent in documentation?
		,Investor_Wire_Info_FL char(2) NULL --Have investor wire instructions passed OFAC?
		,DOB_SSN_Verified_FL char(2) NULL
		,Enhanced_Employee_Benefit_Verified_FL char(2) NULL
		,Enhanced_Regulated_Verification_FL char(2) NULL--Securities1
		,Jurisdiction_Verified_FL char(2) NULL
		,Legal_Entity_Verfied_FL char(2) NULL
		,Taxable_Year_Verified_FL char(2) NULL
		,Taxable_Partner_Verified_FL char(7) NULL
		,Enhanced_Trading_Verification_FL char(2) NULL
		,Authorized_Signer_Verified_FL char(2) NULL --Has Authorized Signer passed OFAC?
		,Authorized_Signer_Name_Addr_Verified_FL char(2) NULL --Has Authorized Signer name and address passed OFAC?
		,Authorized_Signer_Info_Verified_FL char(2) NULL --Has SEI verified Authorized signer information(Address/DOB/Tax ID)?
		,OFAC_Screen_Investor_Name_Verified_FL char(2) NULL --Has Investor Name passed OFAC?
		,Authorized_Signature_Verified_FL char(2) NULL --(20)
		,Authorized_Name_Addr_FL char(2) NULL		--Has SEI verified Authorized signer information?
		,BO_Partner_Name_Addr_FL char(2) NULL	--Has BO/Partner Name and address passed OFAC?
		,BO_Partner_Info_Verified_FL char(2) NULL		--Has SEI verified BO/Partner  information?
		,POA_Name_Addr_FL char(2) NULL		--Has Power of Attorney name and address passed OFAC?
		,Security_Verification_FL char(2) NULL --Securities2
		)

	--If the investor is an entity that is engaged primarily in investing or trading securities, are the answers to either 12f (1) or 12f (2) yes?  (if Y, send notification to Client)
	--If the investor is not an entity that is engaged primarily in investing or trading securities, are either 12f (1) or 12f (2) answered? (if Y, send notification to Client)
	PRINT 'Adding constraints to TABLE dbo.Investor_Transaction_Workflow_Status'

	ALTER TABLE dbo.Investor_Transaction_Workflow_Status ADD CONSTRAINT PK__Investor_Transaction_Workflow_Status__Transaction_Id PRIMARY KEY CLUSTERED (Transaction_Id)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Transaction_Status_Cd FOREIGN KEY (Transaction_Status_Cd) REFERENCES dbo.Transaction_Status(Transaction_Status_Cd)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Individual_Verification_Type_ID  FOREIGN KEY (Individual_Verification_Type_ID ) REFERENCES dbo.Verification_Type (Verification_Type_ID)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Joint_Owner_Verification_Type_ID FOREIGN KEY (Joint_Owner_Verification_Type_ID) REFERENCES dbo.Verification_Type (Verification_Type_ID)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_POA_BO_Partner_Verification_Type_ID FOREIGN KEY (POA_BO_Partner_Verification_Type_ID) REFERENCES dbo.Verification_Type (Verification_Type_ID)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Corporation_Type_ID FOREIGN KEY (Corporation_Type_ID) REFERENCES dbo.Corporation_Type (Corporation_Type_ID)

	-- Validate if the table has been created.
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'Investor_Transaction_Workflow_Status'
			)
	BEGIN
		PRINT 'Table dbo.Investor_Transaction_Workflow_Status has been created.'
	END
	ELSE
	BEGIN
		PRINT 'Failed to create Table dbo.Investor_Transaction_Workflow_Status_Info!!!!!!!'
	END
END TRY

BEGIN CATCH
	DECLARE @error_Message VARCHAR(2100);
	DECLARE @error_Severity INT;
	DECLARE @error_State INT;

	SET @error_Message = Error_Message()
	SET @error_Severity = Error_Severity()
	SET @error_State = Error_State()

	RAISERROR (
			@error_Message
			,@error_Severity
			,@error_State
			);
END CATCH;

PRINT '';
PRINT 'End of TABLE script for Investor_Transaction_Workflow_Status';
PRINT '----------------------------------------';
