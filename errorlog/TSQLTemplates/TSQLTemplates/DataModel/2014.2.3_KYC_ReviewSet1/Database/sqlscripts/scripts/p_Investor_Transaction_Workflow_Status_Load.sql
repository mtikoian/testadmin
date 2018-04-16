USE NetikIP;
GO

-- Drop stored procedure if it already exists
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.ROUTINES
		WHERE SPECIFIC_SCHEMA = N'dbo'
			AND SPECIFIC_NAME = N'p_Investor_Transaction_Workflow_Status_Load'
		)
BEGIN
	DROP PROCEDURE dbo.p_Investor_Transaction_Workflow_Status_Load;

	PRINT 'PROCEDURE dbo.p_Investor_Transaction_Workflow_Status_Load has been dropped.';
END;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER OFF;
GO

CREATE PROCEDURE dbo.p_Investor_Transaction_Workflow_Status_Load (
	@Transaction_Id VARCHAR(15)
	,@Client_Name VARCHAR(255)
	,@Document_File_Path VARCHAR(255)
	,@External_Investor_Id VARCHAR(12)
	,@Institution_Type_ID INT
	,@Transaction_Status_Cd varchar(50)
	,@Individual_Verification_Type_ID varchar(50)
	,@Joint_Owner_Verification_Type_ID varchar(50)
	,@POA_BO_Partner_Verification_Type_ID varchar(50)
	,@Corporation_Type_ID varchar(100)
	,@AML_Due_Dt DATETIME
	,@AML_outstanding_Days INT
	,@ERISA_Status VARCHAR(50)
	,@Indemnification_Letter_FL CHAR(2)
	,@W9_Document_FL CHAR(2)
	,@W8_Document_FL CHAR(2)
	,@Individual_ID_Verified_FL CHAR(2)
	,@Joint_Owner_ID_Verified_FL CHAR(2)
	,@POA_BO_Partner_ID_Verified_FL CHAR(2)
	,@Corporation_ID_Verified_FL CHAR(2)
	,@Foreign_Bank_Certificate_Verified_FL CHAR(2)
	,@Three_Year_Tax_Trust_Deed_Verified_FL CHAR(2)
	,@Trust_Beneficiary_List_Verified_FL CHAR(2)
	,@IRS_Letter_Verified_Verified_FL CHAR(2)
	,@Electronic_Delivery_Verified_FL CHAR(7)
	,@Qualified_Purchaser_Verified_FL CHAR(2)
	,@Investor_Name_Verified_FL CHAR(2)
	,@Investor_Address_Verified_FL CHAR(2)
	,@Investor_DOB_Verified_FL CHAR(2)
	,@Investor_Signature_Verified_FL CHAR(2)
	,@Investor_Wire_Instructions_Verified_FL CHAR(2)
	,@Investor_Exempt_Verified_FL CHAR(7)
	,@Investor_Tax_ID_Verified_FL CHAR(2)
	,@Investor_Accredited_Verified_FL CHAR(2)
	,@Investor_Subscription_Compliance_Verified_FL CHAR(2)
	,@Investor_Enhanced_Name_Verified_FL CHAR(2)
	,@Investor_Wire_Info_FL CHAR(2)
	,@DOB_SSN_Verified_FL CHAR(2)
	,@Enhanced_Employee_Benefit_Verified_FL CHAR(2)
	,@Enhanced_Regulated_Verification_FL CHAR(2)
	,@Jurisdiction_Verified_FL CHAR(2)
	,@Legal_Entity_Verfied_FL CHAR(2)
	,@Taxable_Year_Verified_FL CHAR(2)
	,@Taxable_Partner_Verified_FL CHAR(7)
	,@Enhanced_Trading_Verification_FL CHAR(2)
	,@Authorized_Signer_Verified_FL CHAR(2)
	,@Authorized_Signer_Name_Addr_Verified_FL CHAR(2)
	,@Authorized_Signer_Info_Verified_FL CHAR(2)
	,@OFAC_Screen_Investor_Name_Verified_FL CHAR(2)
	,@Authorized_Signature_Verified_FL CHAR(2)
	,@Authorized_Name_Addr_FL CHAR(2)
	,@BO_Partner_Name_Addr_FL CHAR(2)
	,@BO_Partner_Info_Verified_FL CHAR(2)
	,@POA_Name_Addr_FL CHAR(2)
	,@Security_Verification_FL CHAR(2)
	)
AS
BEGIN
	/*            
==================================================================================================            
Name  : p_TranEvent_MDA_TrialBalance.sql            
Author  : Manish Chawla   - 02/26/2014            
Description : Process Fetches account information            
Process  needed to run using NETIK UI and same parameters are needed    
existing NETIK screen has functionality of selecting select, filter, order by and     
Dynamic SQL is used same purpose    
===================================================================================================            
Parameters :         
Name										|I/O|     Description       
@Transaction_Id								
@Client_Name
@External_Investor_Id
@Institution_Type_ID
@Transaction_Status_Cd
@Individual_Verification_Type_ID
@Joint_Owner_Verification_Type_ID
@POA_BO_Partner_Verification_Type_ID
@Corporation_Type_ID
@AML_Due_Dt
@AML_outstanding_Days
@ERISA_Status
@Indemnification_Letter_FL
@W9_Document_FL
@W8_Document_FL
@Individual_ID_Verified_FL
@Joint_Owner_ID_Verified_FL
@POA_BO_Partner_ID_Verified_FL
@Corporation_ID_Verified_FL
@Foreign_Bank_Certificate_Verified_FL
@Three_Year_Tax_Trust_Deed_Verified_FL
@Trust_Beneficiary_List_Verified_FL
@IRS_Letter_Verified_Verified_FL
@Electronic_Delivery_Verified_FL
@Qualified_Purchaser_Verified_FL
@Investor_Name_Verified_FL
@Investor_Address_Verified_FL
@Investor_DOB_Verified_FL
@Investor_Signature_Verified_FL
@Investor_Wire_Instructions_Verified_FL
@Investor_Exempt_Verified_FL
@Investor_Tax_ID_Verified_FL
@Investor_Accredited_Verified_FL
@Investor_Subscription_Compliance_Verified_FL
@Investor_Enhanced_Name_Verified_FL
@Investor_Wire_Info_FL
@DOB_SSN_Verified_FL
@Enhanced_Employee_Benefit_Verified_FL
@Enhanced_Regulated_Verification_FL
@Jurisdiction_Verified_FL
@Legal_Entity_Verfied_FL
@Taxable_Year_Verified_FL
@Taxable_Partner_Verified_FL
@Enhanced_Trading_Verification_FL
@Authorized_Signer_Verified_FL
@Authorized_Signer_Name_Addr_Verified_FL
@Authorized_Signer_Info_Verified_FL
@OFAC_Screen_Investor_Name_Verified_FL
@Authorized_Signature_Verified_FL
@Authorized_Name_Addr_FL
@BO_Partner_Name_Addr_FL
@BO_Partner_Info_Verified_FL
@POA_Name_Addr_FL
@Security_Verification_FL
----------------------------------------------------------------            
Returns  : Return table            
Usage  :     
   
EXEC 
            
Name        Date        Description            
---------- ---------- --------------------------------------------------------            
VBANDI     02262014      First Version            
========================================================================================================            
*/
	SET NOCOUNT ON;
	--Declarations
	DECLARE @errno INT;
	DECLARE @ERRSEVERITY INT;
	DECLARE @alias_Transaction_Id VARCHAR(15);
	DECLARE @alias_Client_Name VARCHAR(255);
	DECLARE @alias_External_Investor_Id VARCHAR(12);
	DECLARE @alias_Institution_Type_ID INT;
	DECLARE @alias_Transaction_Status_Cd INT;
	DECLARE @alias_Individual_Verification_Type_ID INT;
	DECLARE @alias_Joint_Owner_Verification_Type_ID INT;
	DECLARE @alias_POA_BO_Partner_Verification_Type_ID INT;
	DECLARE @alias_Corporation_Type_ID INT;
	DECLARE @alias_AML_Due_Dt DATETIME;
	DECLARE @alias_AML_outstanding_Days INT;
	DECLARE @alias_ERISA_Status VARCHAR(50);
	DECLARE @alias_Indemnification_Letter_FL CHAR(2);
	DECLARE @alias_W9_Document_FL CHAR(2);
	DECLARE @alias_W8_Document_FL CHAR(2);
	DECLARE @alias_Individual_ID_Verified_FL CHAR(2);
	DECLARE @alias_Joint_Owner_ID_Verified_FL CHAR(2);
	DECLARE @alias_POA_BO_Partner_ID_Verified_FL CHAR(2);
	DECLARE @alias_Corporation_ID_Verified_FL CHAR(2);
	DECLARE @alias_Foreign_Bank_Certificate_Verified_FL CHAR(2);
	DECLARE @alias_Three_Year_Tax_Trust_Deed_Verified_FL CHAR(2);
	DECLARE @alias_Trust_Beneficiary_List_Verified_FL CHAR(2);
	DECLARE @alias_IRS_Letter_Verified_Verified_FL CHAR(2);
	DECLARE @alias_Electronic_Delivery_Verified_FL CHAR(7);
	DECLARE @alias_Qualified_Purchaser_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Name_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Address_Verified_FL CHAR(2);
	DECLARE @alias_Investor_DOB_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Signature_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Wire_Instructions_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Exempt_Verified_FL CHAR(7);
	DECLARE @alias_Investor_Tax_ID_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Accredited_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Subscription_Compliance_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Enhanced_Name_Verified_FL CHAR(2);
	DECLARE @alias_Investor_Wire_Info_FL CHAR(2);
	DECLARE @alias_DOB_SSN_Verified_FL CHAR(2);
	DECLARE @alias_Enhanced_Employee_Benefit_Verified_FL CHAR(2);
	DECLARE @alias_Enhanced_Regulated_Verification_FL CHAR(2);
	DECLARE @alias_Jurisdiction_Verified_FL CHAR(2);
	DECLARE @alias_Legal_Entity_Verfied_FL CHAR(2);
	DECLARE @alias_Taxable_Year_Verified_FL CHAR(2);
	DECLARE @alias_Taxable_Partner_Verified_FL CHAR(7);
	DECLARE @alias_Enhanced_Trading_Verification_FL CHAR(2);
	DECLARE @alias_Authorized_Signer_Verified_FL CHAR(2);
	DECLARE @alias_Authorized_Signer_Name_Addr_Verified_FL CHAR(2);
	DECLARE @alias_Authorized_Signer_Info_Verified_FL CHAR(2);
	DECLARE @alias_OFAC_Screen_Investor_Name_Verified_FL CHAR(2);
	DECLARE @alias_Authorized_Signature_Verified_FL CHAR(2);
	DECLARE @alias_Authorized_Name_Addr_FL CHAR(2);
	DECLARE @alias_BO_Partner_Name_Addr_FL CHAR(2);
	DECLARE @alias_BO_Partner_Info_Verified_FL CHAR(2);
	DECLARE @alias_POA_Name_Addr_FL CHAR(2);
	DECLARE @alias_Security_Verification_FL CHAR(2);
	--Initialize variables
	SET @alias_Transaction_Id = @Transaction_Id;
	SET @alias_Client_Name = @Client_Name
	SET @alias_External_Investor_Id = @Client_Name
	SET @alias_Institution_Type_ID = @Institution_Type_ID
	SET @alias_AML_Due_Dt = @AML_Due_Dt
	SET @alias_AML_outstanding_Days = @AML_outstanding_Days
	SET @alias_ERISA_Status = @ERISA_Status
	SET @alias_Transaction_Status_Cd = CASE 
			WHEN ltrim(rtrim(@Transaction_Status_Cd)) = 'Pending SEI Review'
				THEN 1
			WHEN ltrim(Rtrim(@Transaction_Status_Cd)) = 'Initial Review Complete'
				THEN 2
			WHEN ltrim(Rtrim(@Transaction_Status_Cd)) = 'Ready for Money Movement'
				THEN 3
			WHEN ltrim(Rtrim(@Transaction_Status_Cd)) = 'AML/Enhance Review Complete - Pending SEI Peer Review'
				THEN 4
			WHEN ltrim(Rtrim(@Transaction_Status_Cd)) = 'Client Action Required'
				THEN 5
			WHEN ltrim(Rtrim(@Transaction_Status_Cd)) = 'Pending SEI Peer Review'
				THEN 6
			WHEN ltrim(Rtrim(@Transaction_Status_Cd)) = 'Complete'
				THEN 7
			END;
	SET @alias_Individual_Verification_Type_ID = CASE 
			WHEN ltrim(rtrim(@Individual_Verification_Type_ID)) = 'Driver s License'
				THEN 1
			WHEN ltrim(Rtrim(@Individual_Verification_Type_ID)) = 'Passport'
				THEN 2
			WHEN ltrim(Rtrim(@Individual_Verification_Type_ID)) = 'Government ID'
				THEN 3
			WHEN ltrim(Rtrim(@Individual_Verification_Type_ID)) = 'Birth Certificate'
				THEN 4
			WHEN ltrim(Rtrim(@Individual_Verification_Type_ID)) = 'Verified PA Compliance'
				THEN 5
			WHEN ltrim(Rtrim(@Individual_Verification_Type_ID)) = 'Other'
				THEN 6
			END;
	SET @alias_Joint_Owner_Verification_Type_ID = CASE 
			WHEN ltrim(rtrim(@Joint_Owner_Verification_Type_ID)) = 'Driver s License'
				THEN 1
			WHEN ltrim(Rtrim(@Joint_Owner_Verification_Type_ID)) = 'Passport'
				THEN 2
			WHEN ltrim(Rtrim(@Joint_Owner_Verification_Type_ID)) = 'Government ID'
				THEN 3
			WHEN ltrim(Rtrim(@Joint_Owner_Verification_Type_ID)) = 'Birth Certificate'
				THEN 4
			WHEN ltrim(Rtrim(@Joint_Owner_Verification_Type_ID)) = 'Verified PA Compliance'
				THEN 5
			WHEN ltrim(Rtrim(@Joint_Owner_Verification_Type_ID)) = 'Other'
				THEN 6
			END;
	SET @alias_POA_BO_Partner_Verification_Type_ID = CASE 
			WHEN ltrim(rtrim(@POA_BO_Partner_Verification_Type_ID)) = 'Driver''s License'
				THEN 1
			WHEN ltrim(Rtrim(@POA_BO_Partner_Verification_Type_ID)) = 'Passport'
				THEN 2
			WHEN ltrim(Rtrim(@POA_BO_Partner_Verification_Type_ID)) = 'Government ID'
				THEN 3
			WHEN ltrim(Rtrim(@POA_BO_Partner_Verification_Type_ID)) = 'Birth Certificate'
				THEN 4
			WHEN ltrim(Rtrim(@POA_BO_Partner_Verification_Type_ID)) = 'Verified PA Compliance'
				THEN 5
			WHEN ltrim(Rtrim(@POA_BO_Partner_Verification_Type_ID)) = 'Other'
				THEN 6
			END;
	SET @alias_Corporation_Type_ID = CASE 
			WHEN ltrim(rtrim(@Corporation_Type_ID)) = 'Partnership/Membership Agreement (US/NonUS)'
				THEN 1
			WHEN ltrim(Rtrim(@Corporation_Type_ID)) = 'Non-documentary (US)'
				THEN 2
			WHEN ltrim(Rtrim(@Corporation_Type_ID)) = 'Three Years of Financial Statements (NonUS)'
				THEN 3
			WHEN ltrim(Rtrim(@Corporation_Type_ID)) = 'AML/Enhanced Review Complete'
				THEN 4
			WHEN ltrim(Rtrim(@Corporation_Type_ID)) = 'Certificate of Good Standing (NonUS)'
				THEN 5
			WHEN ltrim(Rtrim(@Corporation_Type_ID)) = 'Banking Reference (NonUS)'
				THEN 6
			END;
	--SET @alias_Indemnification_Letter_FL = CASE 
	--		WHEN @Indemnification_Letter_FL = 'YES'
	--			THEN 1
	--		WHEN @Indemnification_Letter_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_W9_Document_FL = CASE 
	--		WHEN @W9_Document_FL = 'YES'
	--			THEN 1
	--		WHEN @W9_Document_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_W8_Document_FL = CASE 
	--		WHEN @W8_Document_FL = 'YES'
	--			THEN 1
	--		WHEN @W8_Document_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Individual_ID_Verified_FL = CASE 
	--		WHEN @Individual_ID_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Individual_ID_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Joint_Owner_ID_Verified_FL = CASE 
	--		WHEN @Joint_Owner_ID_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Joint_Owner_ID_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_POA_BO_Partner_ID_Verified_FL = CASE 
	--		WHEN @POA_BO_Partner_ID_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @POA_BO_Partner_ID_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Corporation_ID_Verified_FL = CASE 
	--		WHEN @Corporation_ID_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Corporation_ID_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Foreign_Bank_Certificate_Verified_FL = CASE 
	--		WHEN @Foreign_Bank_Certificate_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Foreign_Bank_Certificate_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Three_Year_Tax_Trust_Deed_Verified_FL = CASE 
	--		WHEN @Three_Year_Tax_Trust_Deed_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Three_Year_Tax_Trust_Deed_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Trust_Beneficiary_List_Verified_FL = CASE 
	--		WHEN @IRS_Letter_Verified_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @IRS_Letter_Verified_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_IRS_Letter_Verified_Verified_FL = CASE 
	--		WHEN @IRS_Letter_Verified_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @IRS_Letter_Verified_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Electronic_Delivery_Verified_FL = CASE 
	--		WHEN @Electronic_Delivery_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Electronic_Delivery_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Qualified_Purchaser_Verified_FL = CASE 
	--		WHEN @Qualified_Purchaser_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Qualified_Purchaser_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Name_Verified_FL = CASE 
	--		WHEN @Investor_Name_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Name_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Address_Verified_FL = CASE 
	--		WHEN @Investor_Address_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Address_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_DOB_Verified_FL = CASE 
	--		WHEN @Investor_DOB_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_DOB_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Signature_Verified_FL = CASE 
	--		WHEN @Investor_Signature_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Signature_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Wire_Instructions_Verified_FL = CASE 
	--		WHEN @Investor_Wire_Instructions_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Wire_Instructions_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Exempt_Verified_FL = CASE 
	--		WHEN @Investor_Exempt_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Exempt_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Tax_ID_Verified_FL = CASE 
	--		WHEN @Investor_Tax_ID_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Tax_ID_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Accredited_Verified_FL = CASE 
	--		WHEN @Investor_Accredited_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Accredited_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Subscription_Compliance_Verified_FL = CASE 
	--		WHEN @Investor_Subscription_Compliance_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Subscription_Compliance_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Enhanced_Name_Verified_FL = CASE 
	--		WHEN @Investor_Enhanced_Name_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Enhanced_Name_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Investor_Wire_Info_FL = CASE 
	--		WHEN @Investor_Wire_Info_FL = 'YES'
	--			THEN 1
	--		WHEN @Investor_Wire_Info_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_DOB_SSN_Verified_FL = CASE 
	--		WHEN @DOB_SSN_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @DOB_SSN_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Enhanced_Employee_Benefit_Verified_FL = CASE 
	--		WHEN @Enhanced_Employee_Benefit_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Enhanced_Employee_Benefit_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Enhanced_Regulated_Verification_FL = CASE 
	--		WHEN @Enhanced_Regulated_Verification_FL = 'YES'
	--			THEN 1
	--		WHEN @Enhanced_Regulated_Verification_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Jurisdiction_Verified_FL = CASE 
	--		WHEN @Jurisdiction_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Jurisdiction_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Legal_Entity_Verfied_FL = CASE 
	--		WHEN @Legal_Entity_Verfied_FL = 'YES'
	--			THEN 1
	--		WHEN @Legal_Entity_Verfied_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Taxable_Year_Verified_FL = CASE 
	--		WHEN @Taxable_Year_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Taxable_Year_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Taxable_Partner_Verified_FL = CASE 
	--		WHEN @Taxable_Partner_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Taxable_Partner_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Enhanced_Trading_Verification_FL = CASE 
	--		WHEN @Enhanced_Trading_Verification_FL = 'YES'
	--			THEN 1
	--		WHEN @Enhanced_Trading_Verification_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Authorized_Signer_Verified_FL = CASE 
	--		WHEN @Authorized_Signer_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Authorized_Signer_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Authorized_Signer_Name_Addr_Verified_FL = CASE 
	--		WHEN @Authorized_Signer_Name_Addr_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Authorized_Signer_Name_Addr_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Authorized_Signer_Info_Verified_FL = CASE 
	--		WHEN @Authorized_Signer_Info_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Authorized_Signer_Info_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_OFAC_Screen_Investor_Name_Verified_FL = CASE 
	--		WHEN @OFAC_Screen_Investor_Name_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @OFAC_Screen_Investor_Name_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Authorized_Signature_Verified_FL = CASE 
	--		WHEN @Authorized_Signature_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @Authorized_Signature_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Authorized_Name_Addr_FL = CASE 
	--		WHEN @Authorized_Name_Addr_FL = 'YES'
	--			THEN 1
	--		WHEN @Authorized_Name_Addr_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_BO_Partner_Name_Addr_FL = CASE 
	--		WHEN @BO_Partner_Info_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @BO_Partner_Info_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_BO_Partner_Info_Verified_FL = CASE 
	--		WHEN @BO_Partner_Info_Verified_FL = 'YES'
	--			THEN 1
	--		WHEN @BO_Partner_Info_Verified_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_POA_Name_Addr_FL = CASE 
	--		WHEN @POA_Name_Addr_FL = 'YES'
	--			THEN 1
	--		WHEN @POA_Name_Addr_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;
	--SET @alias_Security_Verification_FL = CASE 
	--		WHEN @Security_Verification_FL = 'YES'
	--			THEN 1
	--		WHEN @Security_Verification_FL = 'NO'
	--			THEN 0
	--		ELSE NULL
	--		END;

	BEGIN TRY
		IF NOT EXISTS (
				SELECT 1
				FROM dbo.Investor_Transaction_Workflow_Status
				WHERE Transaction_Id = @Transaction_Id
				)
		BEGIN
			INSERT INTO dbo.Investor_Transaction_Workflow_Status (
				Transaction_Id
				,Client_Name
				,Document_File_Path
				,External_Investor_Id
				,Institution_Type_ID
				,Transaction_Status_Cd
				,Individual_Verification_Type_ID
				,Joint_Owner_Verification_Type_ID
				,POA_BO_Partner_Verification_Type_ID
				,Corporation_Type_ID
				,AML_Due_Dt
				,AML_outstanding_Days
				,ERISA_Status
				,Indemnification_Letter_FL
				,W9_Document_FL
				,W8_Document_FL
				,Individual_ID_Verified_FL
				,Joint_Owner_ID_Verified_FL
				,POA_BO_Partner_ID_Verified_FL
				,Corporation_ID_Verified_FL
				,Foreign_Bank_Certificate_Verified_FL
				,Three_Year_Tax_Trust_Deed_Verified_FL
				,Trust_Beneficiary_List_Verified_FL
				,IRS_Letter_Verified_Verified_FL
				,Electronic_Delivery_Verified_FL
				,Qualified_Purchaser_Verified_FL
				,Investor_Name_Verified_FL
				,Investor_Address_Verified_FL
				,Investor_DOB_Verified_FL
				,Investor_Signature_Verified_FL
				,Investor_Wire_Instructions_Verified_FL
				,Investor_Exempt_Verified_FL
				,Investor_Tax_ID_Verified_FL
				,Investor_Accredited_Verified_FL
				,Investor_Subscription_Compliance_Verified_FL
				,Investor_Enhanced_Name_Verified_FL
				,Investor_Wire_Info_FL
				,DOB_SSN_Verified_FL
				,Enhanced_Employee_Benefit_Verified_FL
				,Enhanced_Regulated_Verification_FL
				,Jurisdiction_Verified_FL
				,Legal_Entity_Verfied_FL
				,Taxable_Year_Verified_FL
				,Taxable_Partner_Verified_FL
				,Enhanced_Trading_Verification_FL
				,Authorized_Signer_Verified_FL
				,Authorized_Signer_Name_Addr_Verified_FL
				,Authorized_Signer_Info_Verified_FL
				,OFAC_Screen_Investor_Name_Verified_FL
				,Authorized_Signature_Verified_FL
				,Authorized_Name_Addr_FL
				,BO_Partner_Name_Addr_FL
				,BO_Partner_Info_Verified_FL
				,POA_Name_Addr_FL
				,Security_Verification_FL
				)
			VALUES (
				@alias_Transaction_Id
				,@alias_Client_Name
				,@Document_File_Path
				,@alias_External_Investor_Id
				,@alias_Institution_Type_ID
				,@alias_Transaction_Status_Cd
				,@alias_Individual_Verification_Type_ID
				,@alias_Joint_Owner_Verification_Type_ID
				,@alias_POA_BO_Partner_Verification_Type_ID
				,@alias_Corporation_Type_ID
				,@alias_AML_Due_Dt
				,@alias_AML_outstanding_Days
				,@alias_ERISA_Status
				,@Indemnification_Letter_FL
				,@W9_Document_FL
				,@W8_Document_FL
				,@Individual_ID_Verified_FL
				,@Joint_Owner_ID_Verified_FL
				,@POA_BO_Partner_ID_Verified_FL
				,@Corporation_ID_Verified_FL
				,@Foreign_Bank_Certificate_Verified_FL
				,@Three_Year_Tax_Trust_Deed_Verified_FL
				,@Trust_Beneficiary_List_Verified_FL
				,@IRS_Letter_Verified_Verified_FL
				,@Electronic_Delivery_Verified_FL
				,@Qualified_Purchaser_Verified_FL
				,@Investor_Name_Verified_FL
				,@Investor_Address_Verified_FL
				,@Investor_DOB_Verified_FL
				,@Investor_Signature_Verified_FL
				,@Investor_Wire_Instructions_Verified_FL
				,@Investor_Exempt_Verified_FL
				,@Investor_Tax_ID_Verified_FL
				,@Investor_Accredited_Verified_FL
				,@Investor_Subscription_Compliance_Verified_FL
				,@Investor_Enhanced_Name_Verified_FL
				,@Investor_Wire_Info_FL
				,@DOB_SSN_Verified_FL
				,@Enhanced_Employee_Benefit_Verified_FL
				,@Enhanced_Regulated_Verification_FL
				,@Jurisdiction_Verified_FL
				,@Legal_Entity_Verfied_FL
				,@Taxable_Year_Verified_FL
				,@Taxable_Partner_Verified_FL
				,@Enhanced_Trading_Verification_FL
				,@Authorized_Signer_Verified_FL
				,@Authorized_Signer_Name_Addr_Verified_FL
				,@Authorized_Signer_Info_Verified_FL
				,@OFAC_Screen_Investor_Name_Verified_FL
				,@Authorized_Signature_Verified_FL
				,@Authorized_Name_Addr_FL
				,@BO_Partner_Name_Addr_FL
				,@BO_Partner_Info_Verified_FL
				,@POA_Name_Addr_FL
				,@Security_Verification_FL
				)
		END
		ELSE
		BEGIN
			UPDATE dbo.Investor_Transaction_Workflow_Status
			SET
				Client_Name = @alias_Client_Name
				,Document_File_Path = @Document_File_Path
				,External_Investor_Id = @alias_External_Investor_Id
				,Institution_Type_ID = @alias_Institution_Type_ID
				,Transaction_Status_Cd = @alias_Transaction_Status_Cd
				,Individual_Verification_Type_ID = @alias_Individual_Verification_Type_ID
				,Joint_Owner_Verification_Type_ID = @alias_Joint_Owner_Verification_Type_ID
				,POA_BO_Partner_Verification_Type_ID = @alias_POA_BO_Partner_Verification_Type_ID
				,Corporation_Type_ID = @alias_Corporation_Type_ID
				,AML_Due_Dt = @alias_AML_Due_Dt
				,AML_outstanding_Days = @alias_AML_outstanding_Days
				,ERISA_Status = @alias_ERISA_Status
				,Indemnification_Letter_FL = @Indemnification_Letter_FL
				,W9_Document_FL = @W9_Document_FL
				,W8_Document_FL = @W8_Document_FL
				,Individual_ID_Verified_FL = @Individual_ID_Verified_FL
				,Joint_Owner_ID_Verified_FL = @Joint_Owner_ID_Verified_FL
				,POA_BO_Partner_ID_Verified_FL = @POA_BO_Partner_ID_Verified_FL
				,Corporation_ID_Verified_FL = @Corporation_ID_Verified_FL
				,Foreign_Bank_Certificate_Verified_FL = @Foreign_Bank_Certificate_Verified_FL
				,Three_Year_Tax_Trust_Deed_Verified_FL = @Three_Year_Tax_Trust_Deed_Verified_FL
				,Trust_Beneficiary_List_Verified_FL = @Trust_Beneficiary_List_Verified_FL
				,IRS_Letter_Verified_Verified_FL = @IRS_Letter_Verified_Verified_FL
				,Electronic_Delivery_Verified_FL = @Electronic_Delivery_Verified_FL
				,Qualified_Purchaser_Verified_FL = @Qualified_Purchaser_Verified_FL
				,Investor_Name_Verified_FL = @Investor_Name_Verified_FL
				,Investor_Address_Verified_FL = @Investor_Address_Verified_FL
				,Investor_DOB_Verified_FL = @Investor_DOB_Verified_FL
				,Investor_Signature_Verified_FL = @Investor_Signature_Verified_FL
				,Investor_Wire_Instructions_Verified_FL = @Investor_Wire_Instructions_Verified_FL
				,Investor_Exempt_Verified_FL = @Investor_Exempt_Verified_FL
				,Investor_Tax_ID_Verified_FL = @Investor_Tax_ID_Verified_FL
				,Investor_Accredited_Verified_FL = @Investor_Accredited_Verified_FL
				,Investor_Subscription_Compliance_Verified_FL = @Investor_Subscription_Compliance_Verified_FL
				,Investor_Enhanced_Name_Verified_FL = @Investor_Enhanced_Name_Verified_FL
				,Investor_Wire_Info_FL = @Investor_Wire_Info_FL
				,DOB_SSN_Verified_FL = @DOB_SSN_Verified_FL
				,Enhanced_Employee_Benefit_Verified_FL = @Enhanced_Employee_Benefit_Verified_FL
				,Enhanced_Regulated_Verification_FL = @Enhanced_Regulated_Verification_FL
				,Jurisdiction_Verified_FL = @Jurisdiction_Verified_FL
				,Legal_Entity_Verfied_FL = @Legal_Entity_Verfied_FL
				,Taxable_Year_Verified_FL = @Taxable_Year_Verified_FL
				,Taxable_Partner_Verified_FL = @Taxable_Partner_Verified_FL
				,Enhanced_Trading_Verification_FL = @Enhanced_Trading_Verification_FL
				,Authorized_Signer_Verified_FL = @Authorized_Signer_Verified_FL
				,Authorized_Signer_Name_Addr_Verified_FL = @Authorized_Signer_Name_Addr_Verified_FL
				,Authorized_Signer_Info_Verified_FL = @Authorized_Signer_Info_Verified_FL
				,OFAC_Screen_Investor_Name_Verified_FL = @OFAC_Screen_Investor_Name_Verified_FL
				,Authorized_Signature_Verified_FL = @Authorized_Signature_Verified_FL
				,Authorized_Name_Addr_FL = @Authorized_Name_Addr_FL
				,BO_Partner_Name_Addr_FL = @BO_Partner_Name_Addr_FL
				,BO_Partner_Info_Verified_FL = @BO_Partner_Info_Verified_FL
				,POA_Name_Addr_FL = @POA_Name_Addr_FL
				,Security_Verification_FL = @Security_Verification_FL
			WHERE Transaction_Id = @Transaction_Id;
		END;
	END TRY

	BEGIN CATCH
		IF Xact_state() <> 0
			ROLLBACK TRANSACTION

		DECLARE @ERRMSG NVARCHAR(2048);
		DECLARE @ErrorState INT;

		SET @errno = ERROR_NUMBER();
		SET @ERRMSG = Error_message();
		SET @ERRSEVERITY = Error_severity();
		SET @ErrorState = ERROR_STATE()

		RAISERROR (
				@ERRMSG
				,@ERRSEVERITY
				,@ErrorState
				)
	END CATCH;

	RETURN @errno;
END;/*----Procedure End*/
GO

-- Validate if procedure has been Altered.
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.ROUTINES
		WHERE SPECIFIC_SCHEMA = N'dbo'
			AND SPECIFIC_NAME = N'p_Investor_Transaction_Workflow_Status_Load'
		)
BEGIN
	PRINT 'PROCEDURE dbo.p_Investor_Transaction_Workflow_Status_Load has been created.';
END;
ELSE
BEGIN
	PRINT 'PROCEDURE dbo.p_Investor_Transaction_Workflow_Status_Load has NOT been created.';
END;
GO

--GRANT EXECUTE
--	ON p_Investor_Transaction_Workflow_Status_Load
--	TO OnbaseQA;
--GO


