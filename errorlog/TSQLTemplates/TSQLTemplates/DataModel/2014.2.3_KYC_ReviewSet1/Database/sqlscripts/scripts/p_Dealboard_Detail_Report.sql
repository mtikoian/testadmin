USE [NetikIP]
GO

/****** Object:  StoredProcedure [cds].[p_Dealboard_Detail_Report]    Script Date: 3/5/2014 3:49:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [cds].[p_Dealboard_Detail_Report] (
	-- Add the parameters for the stored procedure here	
	@p_ClientId VARCHAR(12)
	,@p_FundId VARCHAR(8000) = NULL
	--,@p_InvestorId VARCHAR(8000) = NULL
	,@p_Start_Dt DATETIME
	,@p_End_Dt DATETIME
	,@inq_num INT = NULL
	,@qry_num INT = NULL
	,@pselect_txt VARCHAR(4000) = NULL
	,@porderby_txt VARCHAR(255) = NULL
	,@pfilter_txt VARCHAR(1000) = NULL
	,@pgroupby_txt VARCHAR(255) = NULL
	,@app_usr_id CHAR(8) = NULL
	)
AS
BEGIN
	/*----Procedure Begin*/
	/***          
================================================================================          
 Name        : cds.p_KYC_Onbase_Dealboard_Detail_Report           
 Author      : VBANDI   
 Date        : 03/04/2014    
 Description : 
===============================================================================          
 Parameters  :   
 Name				|I/O|   Description         
 ------------------------------------------------------------------------------      
 @p_ClientId		I		Client Id
 @p_FundId			I		Fund Id 
 @p_Start_Dt		I		Start Time stamp
 @p_End_Dt			I		End Time Stamp

--------------------------------------------------------------------------------          
 Returns      :                    
Name										Type (length)   Description      
Client ID									int				Client ID Note:As of now no clientId so using static value 1164
FundID										String			FundID
Investor ID									String			Investor ID
--------------------------------------------------------------------------------                    
 If record set is retuned give brief description of the fields being returned                    
 Return Value: Return code                    
     Success : 0(@error_number)                     
     Failure : Error number(@error_number)
--------------------------------------------------------------------------------     
Usage  :         
TEST SCRIPT :	

History:    
Name			 Date				Description    
-------------------------------------------------------------------------------  
VBANDI			20140304			Initial Version
================================================================================    
EXEC cds.p_Dealboard_Detail_Report @p_ClientId = '1164'
	,@p_FundId = '123'
	--,@p_InvestorId = null
	,@p_Start_Dt = '2013-12-01 23:59:59.000'
	,@p_End_Dt = '2014-03-04 23:59:59.000'
	,@inq_num = 14660
	,@qry_num = 14660
	--,@pselect_txt = 'clientid'



*/
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT;-- Return code value for the stored procedure
	DECLARE @Comma CHAR(1);
	DECLARE @count INT;
	DECLARE @msg VARCHAR(2048);
	DECLARE @fld_nme VARCHAR(255);
	DECLARE @sql_txt1 NVARCHAR(MAX);
	DECLARE @filter_txt1 VARCHAR(1000);
	DECLARE @sort_txt1 VARCHAR(255);
	DECLARE @grp_txt1 VARCHAR(255);
	DECLARE @sql_txt2 NVARCHAR(MAX);
	DECLARE @RETURN_INQOUTPUT INT;

	SET @sql_txt1 = ' ';
	SET @sql_txt2 = ' ';
	SET @filter_txt1 = ' ';
	SET @sort_txt1 = ' ';
	-- Initialize SQL variables
	SET @ReturnCode = 0;
	SET @Comma = ',';
	SET @count = 0;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tempfund', 'U') IS NOT NULL
		DROP TABLE #tempfund

	CREATE TABLE #tempfund (Fundid VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED);

	BEGIN TRY
		IF (
				dbo.Fn_ntk_sqlsanitizer(@pselect_txt) = 1
				OR dbo.Fn_ntk_sqlsanitizer(@pfilter_txt) = 1
				OR dbo.Fn_ntk_sqlsanitizer(@pgroupby_txt) = 1
				OR dbo.Fn_ntk_sqlsanitizer(@porderby_txt) = 1
				)
		BEGIN
			PRINT 'SQL SCRIPT IS INJECTED'

			RETURN 16
		END

		IF (@p_FundId IS NOT NULL)
		BEGIN
			INSERT INTO #tempfund (fundid)
			SELECT DISTINCT item
			FROM dbo.f_DelimitedSplit8K(@p_FundId, @Comma)
		END;

		--EXEC @ReturnCode = dbo.p_MDB_HasReportAccess @app_usr_id = @app_usr_id
		--	,@inq_num = @inq_num
		--	,@RETURN_INQNUM = @RETURN_INQOUTPUT OUTPUT

		--IF @ReturnCode <> 0
		--BEGIN
		--	SET @msg = 'Unable to return build string parameters ReturnCode=' + CAST(@ReturnCode AS VARCHAR(12));

		--	RAISERROR (
		--			@msg
		--			,16
		--			,1
		--			);
		--END;

		--IF (@RETURN_INQOUTPUT IS NULL)
		--BEGIN
		--	RETURN 16
		--END

		IF @inq_num IS NOT NULL
		BEGIN
			EXEC @ReturnCode = dbo.sp_Inquiry_BldSqlStrings @inq_num = @inq_num
				,@qry_num = @qry_num
				,@sql_text = @sql_txt1 OUTPUT
				,@filter_text = @filter_txt1 OUTPUT
				,@sort_text = @sort_txt1 OUTPUT
				,@groupby_text = @grp_txt1 OUTPUT

			IF @ReturnCode <> 0
			BEGIN
				SET @msg = 'Unable to return build string parameters ReturnCode=' + CAST(@ReturnCode AS VARCHAR(12));

				RAISERROR (
						@msg
						,16
						,1
						);
			END;
		END;

		-- Override sql strings if sql string parameter has any value                    
		IF (
				DATALENGTH(rtrim(@pselect_txt)) > 0
				OR @pselect_txt IS NOT NULL
				)
		BEGIN
			SELECT @sql_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@pselect_txt)) = 0
						THEN @sql_txt1
					WHEN @pselect_txt IS NULL
						THEN @sql_txt1
					ELSE rtrim(@pselect_txt)
					END
				,@filter_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@pfilter_txt)) = 0
						THEN ' '
					WHEN @pfilter_txt IS NULL
						THEN ' '
					ELSE ' and (' + rtrim(@pfilter_txt) + ')'
					END
				,@sort_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@porderby_txt)) = 0
						THEN ' '
					WHEN @porderby_txt IS NULL
						THEN ' '
					ELSE ' order by ' + rtrim(@porderby_txt)
					END
		END
		ELSE
		BEGIN
			SELECT @filter_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@filter_txt1)) = 0
						THEN ''
					WHEN @filter_txt1 IS NULL
						THEN ''
					ELSE ' and (' + rtrim(@filter_txt1) + ')'
					END
		END

		--SELECT @sql_txt1 = 'select A.ClientId, ' + @sql_txt1 +     
		--                       + CASE WHEN(@p_FundId IS NOT NULL) then                      
		--              ' from kyc_onbase A ' +                                       
		--             ' LEFT OUTER JOIN #tempfund tempfn ON tempfn.fundid = pendtran.fundid' 
		--    end) +    
		-- select @sql_txt1
		SET @sql_txt1 = 'select  ' + @sql_txt1 + ' from dbo.kyconbaseview A ' + (
				CASE 
					WHEN (@p_FundId IS NOT NULL)
						THEN ' LEFT OUTER JOIN #tempfund tempfn ON tempfn.fundid = a.fundid'
					ELSE ''
					END
				) + ' where A.effectivedate between ''' + Convert(VARCHAR(10), @p_Start_Dt, 101) + ''' and ''' + Convert(VARCHAR(10), @p_End_Dt, 101) + '''' + ' and A.Clientid = ''' + @p_ClientId + '''' + @filter_txt1

		-- +@grp_txt1 + @sort_txt1
		--SELECT @sql_txt1

		EXECUTE sp_executesql @sql_txt1
			--SELECT pendtran.ClientId AS 'Client ID'
			--	,c.clientname
			--	,pendtran.FundId AS 'Fund ID'
			--	,F.FundName AS 'Fund Name'
			--	,inv.ThirdPartyId AS 'External Investor ID'
			--	,inv.InvestorName AS 'Investor Legal Name'
			--	,wfstatus.Indemnification_Letter_FL AS 'Indemnification Letter on File'
			--	,wfstatus.Transaction_Id AS 'Transaction Number'
			--	,wfstatus.Client_Name AS 'Client Name'
			--	,wfstatus.External_Investor_Id AS 'External Investor ID'
			--	,wfstatus.W9_Document_FL AS 'W-9 Document'
			--	,wfstatus.W8_Document_FL AS 'W-8 Document'
			--	,wfstatus.Authorized_Signer_Verified_FL AS 'Authorized Signers List'
			--	,wfstatus.Individual_ID_Verified_FL AS 'Individual ID'
			--	,wfstatus.Individual_Verification_Type_ID
			--	,verftype.Verification_Type_Name AS 'Individual ID Type'
			--	,wfstatus.Joint_Owner_ID_Verified_FL AS 'Joint Owner ID'
			--	,wfstatus.Joint_Owner_Verification_Type_ID
			--	,verftype1.Verification_Type_Name AS 'Joint Owner ID Type'
			--	,wfstatus.POA_BO_Partner_ID_Verified_FL AS 'POA/BO Partner ID'
			--	,wfstatus.POA_BO_Partner_Verification_Type_ID
			--	,verftype2.Verification_Type_Name AS 'POA/BO Partner ID Type'
			--	,wfstatus.Corporation_ID_Verified_FL AS 'Corporation ID'
			--	,CorpType.Corporation_Type_Name AS 'Corporation ID Type'
			--	,wfstatus.Foreign_Bank_Certificate_Verified_FL AS 'Foreign Bank Certificate'
			--	,wfstatus.Three_Year_Tax_Trust_Deed_Verified_FL AS '3yr Tax-Trust Deed'
			--	,wfstatus.IRS_Letter_Verified_Verified_FL AS 'IRS Letter'
			--	,wfstatus.Trust_Beneficiary_List_Verified_FL AS 'Trust Beneficiary List'
			--	,wfstatus.Investor_Address_Verified_FL AS 'Investor Address Verified'
			--	,wfstatus.Investor_DOB_Verified_FL AS 'Investor DOB Verified'
			--	,wfstatus.Investor_Signature_Verified_FL AS 'Investor Signature Verified'
			--	,wfstatus.Investor_Wire_Instructions_Verified_FL AS 'Investor Wire Instructions Verified'
			--	,wfstatus.ERISA_Status AS 'ERISA Status'
			--	,wfstatus.Authorized_Signer_Verified_FL AS 'Authorized Signature Verified'
			--	,wfstatus.OFAC_Screen_Investor_Name_Verified_FL AS 'OFAC Screen - Investor Name'
			--	,wfstatus.Investor_Tax_ID_Verified_FL AS 'Investor Tax ID Verified'
			--	,wfstatus.Electronic_Delivery_Verified_FL AS 'Electronic Delivery Verified'
			--	,wfstatus.Investor_Name_Verified_FL AS 'Investor Name Verified'
			--	,wfstatus.Qualified_Purchaser_Verified_FL AS 'Qualified Purchaser Verified'
			--	,wfstatus.Investor_Accredited_Verified_FL AS 'Accredited Investor Verified'
			--	,wfstatus.Investor_Subscription_Compliance_Verified_FL AS 'Subscription Compliance Verified by Investor'
			--	,wfstatus.Investor_Enhanced_Name_Verified_FL AS 'Enhanced Investor Name Verified '
			--	,wfstatus.DOB_SSN_Verified_FL AS 'DOB/SSN Verified'
			--	,wfstatus.Enhanced_Employee_Benefit_Verified_FL AS 'Enhanced Employee Benefit Verified'
			--	,wfstatus.Enhanced_Regulated_Verification_FL AS 'Enhanced Regulated Verification'
			--	,wfstatus.Jurisdiction_Verified_FL AS 'Jurisdiction Verified'
			--	,wfstatus.Legal_Entity_Verfied_FL AS 'Legal Entity Verfied'
			--	,wfstatus.Taxable_Year_Verified_FL AS 'Taxable Year Verified'
			--	,wfstatus.Taxable_Partner_Verified_FL AS 'Taxable Partner Verified'
			--	,wfstatus.Investor_Exempt_Verified_FL AS 'Investor Exempt Verified'
			--	,wfstatus.Enhanced_Trading_Verification_FL AS 'Enhanced Trading Verification (Y) '
			--	,wfstatus.Authorized_Signature_Verified_FL AS 'OFAC Screen - Authorized Signer'
			--	,wfstatus.Authorized_Name_Addr_FL AS 'OFAC Screen - AS Name and Address'
			--	,wfstatus.BO_Partner_Name_Addr_FL AS 'OFAC Screen - BO Partner Name and Address'
			--	,wfstatus.Investor_Wire_Info_FL AS 'OFAC Screen - Investor Wire Inst'
			--	,wfstatus.POA_Name_Addr_FL AS 'OFAC Screen - POA Name and Address'
			--	,wfstatus.Authorized_Signer_Info_Verified_FL AS 'Authorized Signer Info Verified'
			--	,wfstatus.BO_Partner_Info_Verified_FL AS 'BO Partner Info Verified'
			--	,wfstatus.Enhanced_Trading_Verification_FL AS 'Enhanced Trading Verification (N)'
			--FROM cds.Client c
			--INNER JOIN cds.ClientFund CF ON c.ClientId = cf.ClientId
			--INNER JOIN cds.Fund F ON CF.FundId = F.FundId
			--INNER JOIN cds.FundInvestor FINV ON F.FundId = FINV.FundId
			--INNER JOIN cds.Investor Inv ON FINV.InvestorId = Inv.InvestorId
			--INNER JOIN cds.PendingTransaction pendtran ON c.ClientId = pendtran.ClientId
			--	AND F.FundId = pendtran.FundId
			--	AND inv.InvestorId = pendtran.InvestorId
			--	AND pendtran.EffectiveDate BETWEEN @p_Start_Dt
			--		AND @P_End_Dt
			--LEFT OUTER JOIN dbo.Investor_Transaction_Workflow_Status wfstatus ON wfstatus.Transaction_Id = pendtran.WorkflowTransactionId
			--LEFT OUTER JOIN cds.TransactionType Trantype ON pendtran.TransactionTypeCode = Trantype.TransactionTypeCode
			--LEFT OUTER JOIN cds.AccountMaintenanceType acct_type ON acct_type.AccountMaintenanceTypeCode = pendtran.AccountMaintenanceTypeCode
			--LEFT OUTER JOIN cds.InvestmentTermType invtype ON invtype.InvestmentTermTypeCode = pendtran.InvestmentTermTypeCode
			--LEFT OUTER JOIN cds.PendingTransactionPayment tranpay ON tranpay.PendingTransactionId = pendtran.PendingTransactionId
			--LEFT OUTER JOIN cds.Investor TransferInvestor ON TransferInvestor.InvestorId = pendtran.InvestorId
			----LEFT OUTER JOIN cds.ClientType CT ON pendtran.ClientTypeCode = CT.ClientTypeCode
			----LEFT OUTER JOIN cds.TransactionStatusType transtatustype ON transtatustype.TransactionStatusTypeCode = pendtran.TransactionStatusTypeCode
			----LEFT OUTER JOIN cds.TransactionUnitType tranunittype ON PendTran.TransactionUnitTypeCode = tranunittype.TransactionUnitTypeCode
			----LEFT OUTER JOIN cds.InstPCGType insttype ON pendtran.InstPCGTypeCode = insttype.InstPCGTypeCode
			----LEFT OUTER JOIN cds.CurrencyType currtype ON pendtran.CurrencyTypeCode = currtype.CurrencyTypeCode
			----LEFT OUTER JOIN cds.investorcontact invcontact ON invcontact.InvestorId = inv.InvestorId
			----	AND ContactSubTypeCode = 6
			----LEFT OUTER JOIN cds.contact contact ON contact.contactid = invcontact.contactid
			----LEFT OUTER JOIN cds.investorcontact invcontact2 ON invcontact2.InvestorId = inv.InvestorId
			----	AND invcontact2.ContactSubTypeCode = 8
			----LEFT OUTER JOIN cds.contact contact1 ON contact1.contactid = invcontact2.contactid
			----LEFT OUTER JOIN cds.investorcontact invcontact3 ON invcontact3.InvestorId = inv.InvestorId
			----	AND invcontact2.ContactSubTypeCode = 9
			----LEFT OUTER JOIN cds.contact contact2 ON contact2.contactid = invcontact3.contactid
			----LEFT OUTER JOIN cds.FINRAStatusType FINRASTATUS ON inv.FINRA5130StatusTypeCode = FINRASTATUS.FINRAStatusTypeCode
			----LEFT OUTER JOIN cds.DividendDistributionElectionType distr ON distr.DividendDistributionElectionTypeCode = finv.DividendDistributionElectionTypeCode
			--LEFT OUTER JOIN Corporation_Type CorpType ON wfstatus.Corporation_Type_ID = CorpType.Corporation_Type_ID
			--LEFT OUTER JOIN Transaction_Status TransStatus ON wfstatus.Transaction_Status_Cd = TransStatus.Transaction_Status_Cd
			--LEFT OUTER JOIN Verification_Type verftype ON wfstatus.Individual_Verification_Type_ID = verftype.Verification_Type_ID
			--LEFT OUTER JOIN Verification_Type verftype1 ON wfstatus.Joint_Owner_Verification_Type_ID = verftype1.Verification_Type_ID
			--LEFT OUTER JOIN Verification_Type verftype2 ON wfstatus.POA_BO_Partner_Verification_Type_ID = verftype2.Verification_Type_ID
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER()

		DECLARE @ERRMSG NVARCHAR(2100)
			,@ERRSEV INT
			,@ERRSTATE INT;

		SET @ERRMSG = ERROR_MESSAGE();
		SET @ERRSEV = ERROR_SEVERITY();
		SET @ERRSTATE = ERROR_STATE();

		RAISERROR (
				@ERRMSG
				,@ERRSEV
				,@ERRSTATE
				);
	END CATCH;

	--Start VBANDI 01302014
	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tempfund', 'U') IS NOT NULL
		DROP TABLE #tempfund

	RETURN @ReturnCode;
END;


GO


