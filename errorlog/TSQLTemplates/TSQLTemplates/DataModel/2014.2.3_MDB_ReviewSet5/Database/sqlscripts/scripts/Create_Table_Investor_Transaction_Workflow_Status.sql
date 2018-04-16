USE NetikIP;
GO

/*
 File Name				: Create_Table_Investor_Transaction_Workflow_Status.sql
 Description   			: This tables stored Investor_Transaction_Workflow_Status information
 Created By    			: VBANDI
 Created Date  			: 02/24/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
 VBANDI		03172014		Corrected column names Tag --VBANDI 03172014
*/
PRINT '';
PRINT '----------------------------------------';
PRINT 'TABLE script for Investor_Transaction_Workflow_Status';
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
		Transaction_Id								VARCHAR(15) NOT NULL	--Unique Id for each transaction in workflow
		,Client_Name								VARCHAR(255) NOT NULL
		,Document_File_Path							VARCHAR(255) NOT NULL
		,External_Investor_Id						VARCHAR(12) NOT NULL
		,Institution_Type_ID						INT  NULL   
		,Transaction_Status_Cd						INT  NULL			--High Level Transaction Status For Managers  FK to Transaction_Status_Type table
		,Individual_Verification_Type_ID			INT  NULL			--Types of individual id FK to Verification_Type  table
		,Joint_Owner_Verification_Type_ID			INT  NULL			--Types of join owner id FK to Verification_Type  table
		,POA_BO_Partner_Verification_Type_ID		INT  NULL			--Types of Partner id FK to Verification_Type  table
		,Corporation_Type_ID						INT  NULL			--Types of Corporation id FK to Corporation_Type table
		,AML_Due_Dt									DATETIME NOT NULL			
		,AML_outstanding_Days						INT NULL				--This will be a number between 0 and 999
		,ERISA_Status								VARCHAR(50) NULL		-- Employee Retirement Income Security Act  Is the Investor ERISA/BPI Eligible?
		,Indemnification_Letter_Tx					varchar(15) NOT NULL	--Verification check to see if Indemnification Letter was imported
		,W9_Document_Tx								varchar(15) NOT NULL	--Vefification check to see if W-9 was imported
		,W8_Document_Tx								varchar(15) NOT NULL	--Vefification check to see if W-8 was imported
		,Individual_ID_Verified_Tx					varchar(15) NOT NULL	--Verification check to see if Individual ID from investor was imported
		,Joint_Owner_ID_Verified_Tx					varchar(15) NOT NULL	--Verification check to see if Joint ID from investor was imported
		,POA_BO_Partner_ID_Verified_Tx				varchar(15) NOT NULL	--Verification check to see if Partner ID was imported
		,Corporation_ID_Verified_Tx					varchar(15) NOT NULL	--Verification check to see if Corporation ID was imported
		,Foreign_Bank_Certificate_Verified_Tx		varchar(15) NOT NULL	--Verification check to see if Foreign Bank Cert imported
		,Three_Year_Tax_Trust_Deed_Verified_Tx		varchar(15) NOT NULL	--Verification check to see if 3yr Tax-Trus Deed was imported
		,Trust_Beneficiary_List_Verified_Tx			varchar(15) NOT NULL	--Verification check to see if Trus Beneficiary List was imported
		,IRS_Letter_Verified_Tx			varchar(15) NOT NULL	--Verification check to see if IRS Letter was imported
		,Electronic_Delivery_Verified_Tx			varchar(15) NOT NULL	--Has SEI verified Electronic Delivery information?
		,Qualified_Purchaser_Verified_Tx			varchar(15) NOT NULL	--Has SEI verified Qualified purchaser information?
		,Investor_Name_Verified_Tx					varchar(15) NOT NULL	--Has SEI verified Name information?
		,Investor_Address_Verified_Tx				varchar(15) NOT NULL	--Has SEI analyst received the investor address?
		,Investor_DOB_Verified_Tx					varchar(15) NOT NULL	--Has SEI analyst received the investor DOB?
		,Investor_Signature_Verified_Tx				varchar(15) NOT NULL	--Has SEI analyst received the investor Signature?
		,Investor_Wire_Instructions_Verified_Tx		varchar(15) NOT NULL	--Has SEI analyst received the wire instructions?
		,Investor_Exempt_Verified_Tx				varchar(15) NOT NULL
		,Investor_Tax_ID_Verified_Tx				varchar(15) NOT NULL	--Has SEI verified Tax ID information?
		,Investor_Accredited_Verified_Tx			varchar(15) NOT NULL	--Has SEI verified accredited investors?
		,Investor_Subscription_Compliance_Verified_Tx varchar(15) NOT NULL	--Has subscription compliance been verified by investor?
		,Investor_Enhanced_Name_Verified_Tx			varchar(15) NOT NULL	--Is investor name consistent in documentation?
		,Investor_Wire_Info_Tx						varchar(15) NOT NULL	--Have investor wire instructions passed OFAC?
		,DOB_SSN_Verified_Tx						varchar(15) NOT NULL
		,Enhanced_Employee_Benefit_Verified_Tx		varchar(15) NOT NULL
		,Entity_Trading_Verification_Tx				varchar(15) NOT NULL	--Securities1 
		,Jurisdiction_Verified_Tx					varchar(15) NOT NULL
		,Legal_Entity_Verfied_Tx					varchar(15) NOT NULL
		,Taxable_Year_Verified_Tx					varchar(15) NOT NULL
		,Taxable_Partner_Verified_Tx				varchar(15) NOT NULL
		,Enhanced_Trading_Verification_Tx			varchar(15) NOT NULL
		,Authorized_Signer_Verified_Tx				varchar(15) NOT NULL	--Has Authorized Signer passed OFAC?
		,Authorized_Signer_Name_Addr_Verified_Tx	varchar(15) NOT NULL	--Has Authorized Signer name and address passed OFAC?
		,Authorized_Signer_Info_Verified_Tx			varchar(15) NOT NULL	--Has SEI verified Authorized signer information(Address/DOB/Tax ID)?
		,OFAC_Screen_Investor_Name_Verified_Tx		varchar(15) NOT NULL	--Has Investor Name passed OFAC?
		,Authorized_Signature_Verified_Tx			varchar(15) NOT NULL 
		,Authorized_Name_Addr_Verified_Tx			varchar(15) NOT NULL	--Has SEI verified Authorized signer information?
		,BO_Partner_Name_Addr_Verified_Tx			varchar(15) NOT NULL	--Has BO/Partner Name and address passed OFAC?
		,BO_Partner_Info_Verified_Tx				varchar(15) NOT NULL	--Has SEI verified BO/Partner  information?
		,POA_Name_Addr_Verified_Tx					varchar(15) NOT NULL	--Has Power of Attorney name and address passed OFAC?
		,NonEntity_Trading_Verification_Tx			varchar(15) NOT NULL	--Securities2  
		,Subdoc_Received_Verified_Tx				varchar(15) NOT NULL
		,Regulated_Institution_Verified_Tx			varchar(30) NOT NULL
		,Supplemental_Data_Consistency_Verified_Tx	varchar(15) NOT NULL		--VBANDI 03172014
		,Entity_Investment_Review_Verified_Tx		varchar(15) NOT NULL		--VBANDI 03172014
		,Partnership_Percent_Verified_Tx			varchar(15) NOT NULL
		--Audit information
		,Created_Usr_Id								VARCHAR(30) NOT NULL --Created user id
		,Created_Dt									DATETIME	NOT NULL --Created date and time		
		,Lst_Chg_Usr_Id								VARCHAR(30) NOT NULL --Last updated userid
		,Lst_Chg_Dt									DATETIME	NOT NULL --Last updated date and time
		);

	PRINT 'Adding constraints to TABLE dbo.Investor_Transaction_Workflow_Status';

	ALTER TABLE dbo.Investor_Transaction_Workflow_Status ADD CONSTRAINT PK__Investor_Transaction_Workflow_Status__Transaction_Id1 PRIMARY KEY CLUSTERED (Transaction_Id)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Transaction_Status_Cd FOREIGN KEY (Transaction_Status_Cd) REFERENCES dbo.Transaction_Status(Transaction_Status_Cd)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Individual_Verification_Type_ID  FOREIGN KEY (Individual_Verification_Type_ID ) REFERENCES dbo.Verification_Type (Verification_Type_ID)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Joint_Owner_Verification_Type_ID FOREIGN KEY (Joint_Owner_Verification_Type_ID) REFERENCES dbo.Verification_Type (Verification_Type_ID)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_POA_BO_Partner_Verification_Type_ID FOREIGN KEY (POA_BO_Partner_Verification_Type_ID) REFERENCES dbo.Verification_Type (Verification_Type_ID)
		,CONSTRAINT FK__Investor_Transaction_Workflow_Status_Corporation_Type_ID FOREIGN KEY (Corporation_Type_ID) REFERENCES dbo.Corporation_Type (Corporation_Type_ID)
		,CONSTRAINT CK_Indemnification_Letter_Tx CHECK (Indemnification_Letter_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_W9_Document_Tx CHECK (W9_Document_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_W8_Document_Tx CHECK (W8_Document_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Individual_ID_Verified_Tx CHECK (Individual_ID_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Joint_Owner_ID_Verified_Tx  CHECK (Joint_Owner_ID_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_POA_BO_Partner_ID_Verified_Tx  CHECK (POA_BO_Partner_ID_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Corporation_ID_Verified_Tx   CHECK (Corporation_ID_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Foreign_Bank_Certificate_Verified_Tx   CHECK (Foreign_Bank_Certificate_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Three_Year_Tax_Trust_Deed_Verified_Tx   CHECK (Three_Year_Tax_Trust_Deed_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Trust_Beneficiary_List_Verified_Tx   CHECK (Trust_Beneficiary_List_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_IRS_Letter_Verified_Tx CHECK (IRS_Letter_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Electronic_Delivery_Verified_Tx CHECK (Electronic_Delivery_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken','Missing'))
		,CONSTRAINT CK_Qualified_Purchaser_Verified_Tx CHECK (Qualified_Purchaser_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Name_Verified_Tx CHECK (Investor_Name_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Address_Verified_Tx CHECK (Investor_Address_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_DOB_Verified_Tx CHECK (Investor_DOB_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Signature_Verified_Tx CHECK (Investor_Signature_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Wire_Instructions_Verified_Tx CHECK (Investor_Wire_Instructions_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Exempt_Verified_Tx CHECK (Investor_Exempt_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken','Missing'))
		,CONSTRAINT CK_Investor_Tax_ID_Verified_Tx CHECK (Investor_Tax_ID_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Accredited_Verified_Tx CHECK (Investor_Accredited_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Subscription_Compliance_Verified_Tx CHECK (Investor_Subscription_Compliance_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Enhanced_Name_Verified_Tx CHECK (Investor_Enhanced_Name_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Investor_Wire_Info_Tx CHECK (Investor_Wire_Info_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_DOB_SSN_Verified_Tx CHECK (DOB_SSN_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Enhanced_Employee_Benefit_Verified_Tx CHECK (Enhanced_Employee_Benefit_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Entity_Trading_Verification_Tx CHECK (Entity_Trading_Verification_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Jurisdiction_Verified_Tx CHECK (Jurisdiction_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Legal_Entity_Verfied_Tx CHECK (Legal_Entity_Verfied_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Taxable_Year_Verified_Tx CHECK (Taxable_Year_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Taxable_Partner_Verified_Tx CHECK (Taxable_Partner_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken', 'Missing'))
		,CONSTRAINT CK_Enhanced_Trading_Verification_Tx CHECK (Enhanced_Trading_Verification_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Authorized_Signer_Verified_Tx CHECK (Authorized_Signer_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Authorized_Signer_Name_Addr_Verified_Tx CHECK (Authorized_Signer_Name_Addr_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Authorized_Signer_Info_Verified_Tx CHECK (Authorized_Signer_Info_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_OFAC_Screen_Investor_Name_Verified_Tx CHECK (OFAC_Screen_Investor_Name_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Authorized_Signature_Verified_Tx CHECK (Authorized_Signature_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Authorized_Name_Addr_Verified_Tx CHECK (Authorized_Name_Addr_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_BO_Partner_Name_Addr_Tx CHECK (BO_Partner_Name_Addr_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_BO_Partner_Info_Verified_Tx CHECK (BO_Partner_Info_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_POA_Name_Addr_Verified_Tx CHECK (POA_Name_Addr_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_NonEntity_Trading_Verification_Tx CHECK (NonEntity_Trading_Verification_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Subdoc_Received_Verified_Tx CHECK (Subdoc_Received_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Regulated_Institution_Verified_Tx CHECK (Regulated_Institution_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken','Not a Regulated Institution'))
		,CONSTRAINT CK_Supplemental_Data_Consistency_Verified_Tx CHECK (Supplemental_Data_Consistency_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Entity_Investment_Review_Verified_Tx CHECK (Entity_Investment_Review_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT CK_Partnership_Percent_Verified_Tx	CHECK (Partnership_Percent_Verified_Tx IN ('Y', 'N', 'NA', 'No Action Taken'))
		,CONSTRAINT DF__Investor_Transaction_Workflow_Status__Created_Usr_Id DEFAULT SYSTEM_USER FOR Created_Usr_Id
		,CONSTRAINT DF__Investor_Transaction_Workflow_Status__Created_Dt DEFAULT GETDATE() FOR Created_Dt
		,CONSTRAINT DF__Investor_Transaction_Workflow_Status__Lst_Chg_Usr_Id DEFAULT SYSTEM_USER FOR Lst_Chg_Usr_Id
		,CONSTRAINT DF__Investor_Transaction_Workflow_Status__Lst_Chg_Dt DEFAULT GETDATE() FOR Lst_Chg_Dt


	-- Validate if the table has been created.
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'Investor_Transaction_Workflow_Status'
			)
	BEGIN
		PRINT 'Table dbo.Investor_Transaction_Workflow_Status has been created.';
	END;
	ELSE
	BEGIN
		PRINT 'Failed to create Table dbo.Investor_Transaction_Workflow_Status_Info!!!!!!!';
	END;
END TRY

BEGIN CATCH
	DECLARE @error_Message VARCHAR(2100);
	DECLARE @error_Severity INT;
	DECLARE @error_State INT;

	SET @error_Message = Error_Message();
	SET @error_Severity = Error_Severity();
	SET @error_State = Error_State();

	RAISERROR (
			@error_Message
			,@error_Severity
			,@error_State
			);
END CATCH;

PRINT '';
PRINT 'End of TABLE script for Investor_Transaction_Workflow_Status';
PRINT '----------------------------------------';
