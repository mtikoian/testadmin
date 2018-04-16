USE [NetikIP]
GO

/****** Object:  StoredProcedure [cds].[p_Dealboard_Summary_Report]    Script Date: 3/5/2014 3:49:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [cds].[p_Dealboard_Summary_Report] (
	-- Add the parameters for the stored procedure here	
	@p_ClientId INT
	,@p_FundId VARCHAR(8000) = NULL
	,@p_InvestorId VARCHAR(8000) = NULL
	,@p_Start_Dt DATETIME
	,@p_End_Dt DATETIME
	,@inq_num INT = NULL
	,@qry_num INT = NULL
	,@pselect_txt VARCHAR(4000) = NULL
	,@porderby_txt VARCHAR(255) = NULL
	,@pfilter_txt VARCHAR(1000) = NULL
	,@pgroupby_txt VARCHAR(255) = NULL
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
EXEC cds.p_Dealboard_Summary_Report @p_ClientId = '1164'
	,@p_FundId = '123'
	,@p_InvestorId = '456'
	,@p_Start_Dt = '2013-12-01 23:59:59.000'
	,@p_End_Dt = '2014-03-04 23:59:59.000'
	,@pselect_txt = 'clientid'



*/
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT;-- Return code value for the stored procedure
	DECLARE @Comma CHAR(1);
	DECLARE @count INT;
	DECLARE @msg VARCHAR(2048);
	DECLARE @sql_txt1 NVARCHAR(MAX);
	DECLARE @filter_txt1 VARCHAR(1000);
	DECLARE @sort_txt1 VARCHAR(255);
	DECLARE @grp_txt1 VARCHAR(255);
	DECLARE @sql_txt2 NVARCHAR(MAX);

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

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tempinvestor', 'U') IS NOT NULL
		DROP TABLE #tempinvestor

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tranpending', 'U') IS NOT NULL
		DROP TABLE #tranpending

	CREATE TABLE #tempfund (Fundid VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED);

	CREATE TABLE #tempinvestor (InvestorId VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED);

	CREATE TABLE #tranpending (
		PendingTransactionId INT NOT NULL
		,PaymentAmount INT NOT NULL
		,PaymentDate DATETIME NOT NULL
		,Rownum INT NOT NULL
		)

	BEGIN TRY
		INSERT INTO #tranpending (
			PendingTransactionId
			,PaymentAmount
			,PaymentDate
			,RowNum
			)
		SELECT PendingTransactionId
			,PaymentAmount
			,PaymentDate
			,ROW_NUMBER() OVER (
				PARTITION BY PaymentDate ORDER BY PaymentDate DESC
				) AS RowNum
		FROM cds.PendingTransactionPayment

		IF (@p_FundId IS NOT NULL)
		BEGIN
			INSERT INTO #tempfund (fundid)
			SELECT DISTINCT item
			FROM dbo.f_DelimitedSplit8K(@p_FundId, @Comma)
		END;

		IF (@p_InvestorId IS NOT NULL)
		BEGIN
			INSERT INTO #tempinvestor (InvestorId)
			SELECT DISTINCT item
			FROM dbo.f_DelimitedSplit8K(@p_InvestorId, @Comma)
		END;

		--SELECT pendtran.FundId
		--	,pendtran.effectivedate
		--	,pendtran.ClientId
		--	,c.clientname
		--	,transtatustype.VALUE AS 'TransactionStatus'
		--	,pendtran.ExternalTransactionId
		--	,pendtran.PendingTransactionId
		--	,F.FundName
		--	,'' AS 'Class_ID'
		--	,'' AS 'Class_Name'
		--	,'' AS 'Series_ID'
		--	,'' AS 'Series_Name'
		--	,inv.ThirdPartyId AS 'External_Investor_ID'
		--	,inv.InvestorName AS 'Investor_Legal_Name'
		--	,Trantype.value AS 'Pending_Transaction_Type'
		--	--,acct_type.value AS 'Pending Transaction Type'
		--	,pendtran.TransfereeInvestorId
		--	,TransferInvestor.Investorname AS 'Investorname_Transferee'
		--	,pendtran.SwitchInFundId AS 'ClassID_SwitchIn'
		--	,F.FundName AS 'ClassName - Switch In'
		--	,SwitchInFundId AS 'Series ID - Switch In'
		--	--,pendtran.TransactionUnitTypeCode AS 'Series Name - Switch In'
		--	,tranunittype.value AS 'Series Name - Switch In'
		--	--,CommitmentAmount
		--	,'' AS 'NAV Date'
		--	,TransactionAmount AS 'Transaction Amount'
		--	,currtype.value AS 'Transaction Curency'
		--	--,pendtran.InvestmentTermTypeCode
		--	,TransactionUnitShareAmount AS 'Transaction Unit/Share Amount'
		--	,invtype.value AS 'Transaction Unit Type'
		--	,NotionalAmount AS ' Notional Amount'
		--	,'' AS NAV
		--	,'' AS 'Market Value'
		--	,EffectiveDate AS 'Pending Transaction Effective Date'
		--	,DocumentReceivedDate AS 'Pending Transaction Doc Received'
		--	,ProceedsReceivedDate AS 'Pending Transaction Proceeds Received'
		--	,ProceedsReleasedDate AS 'Release Proceeds to Operating Account'
		--	,tranpay1.PaymentAmount AS 'First Payment Amount'
		--	,tranpay2.PaymentAmount AS 'SecondAmount'
		--	,tranpay3.PaymentAmount AS 'thirdAmount'
		--	,tranpay4.PaymentAmount AS 'FourthAmount'
		--	,tranpay5.PaymentAmount AS 'fivthAmount'
		--	,tranpay6.PaymentAmount AS 'SixthAmount'
		--	,tranpay7.PaymentAmount AS 'SevenAmount'
		--	,tranpay8.PaymentAmount AS 'EightAmount'
		--	,tranpay9.PaymentAmount AS '9thAmount'
		--	,tranpay10.PaymentAmount AS '10thAmount'
		--	,tranpay.[FinalPaymentFlag] AS 'Final Payment Flag'
		--	,tranpay.PendingTransactionPaymentId
		--	,'' AS 'Subsequent Payment Amounts'
		--	,'' AS 'InterestEarned'
		--	,wfstatus.AML_Due_Dt AS 'AML Due Date'
		--	,wfstatus.AML_outstanding_Days AS '# of Days Outstanding (AML)'
		--	,wfstatus.Transaction_Id AS 'Workflow Status - Transaction Record'
		--	,wfstatus.Indemnification_Letter_FL AS 'Indemnification Letter on File'
		--	,insttype.value AS 'Inst/PCG'
		--	,'' AS 'Financial Advisor ID'
		--	,contact.ContactName AS 'Financial Advisor'
		--	,contact1.ContactName AS 'Broker'
		--	,contact2.ContactName AS 'Sub-Channel'
		--	,'' AS 'Account Number'
		--	,CASE 
		--		WHEN inv.ERISA = 1
		--			THEN 'Y'
		--		WHEN inv.ERISA = 0
		--			THEN 'N'
		--		ELSE NULL
		--		END AS 'ERISA Status'
		--	,FINRASTATUS.value AS 'FINRA Status (5130)'
		--	,CASE 
		--		WHEN inv.FINRA5131Indicator = 1
		--			THEN 'Y'
		--		WHEN inv.FINRA5131Indicator = 0
		--			THEN 'N'
		--		ELSE NULL
		--		END AS 'FINRA Status (5131)'
		--	,CASE 
		--		WHEN FINV.SideLetterArrangement = 1
		--			THEN 'Y'
		--		WHEN FINV.SideLetterArrangement = 0
		--			THEN 'N'
		--		ELSE NULL
		--		END AS 'Side Letter Arrangement'
		--	,distr.value AS 'Distribution_Election'
		--	,CASE 
		--		WHEN FINV.EmployeeEligible = 1
		--			THEN 'Y'
		--		WHEN FINV.EmployeeEligible = 0
		--			THEN 'N'
		--		ELSE NULL
		--		END AS EmployeeEligible
		--	,wfstatus.Document_File_Path AS Document_File_Path
		--	,wfstatus.Transaction_Id
		--	,wfstatus.Client_Name
		--	,wfstatus.Document_File_Path
		--	,wfstatus.External_Investor_Id
		--	,wfstatus.Institution_Type_ID
		--	--,wfstatus.Transaction_Status_Cd
		--	,wfstatus.Individual_Verification_Type_ID
		--	,wfstatus.Joint_Owner_Verification_Type_ID
		--	,wfstatus.POA_BO_Partner_Verification_Type_ID
		--	,wfstatus.Corporation_Type_ID
		--	,wfstatus.AML_Due_Dt
		--	,wfstatus.AML_outstanding_Days
		--	,wfstatus.ERISA_Status
		--	,wfstatus.Indemnification_Letter_FL
		--	,wfstatus.W9_Document_FL
		--	,wfstatus.W8_Document_FL
		--	,wfstatus.Individual_ID_Verified_FL
		--	,wfstatus.Joint_Owner_ID_Verified_FL
		--	,wfstatus.POA_BO_Partner_ID_Verified_FL
		--	,wfstatus.Corporation_ID_Verified_FL
		--	,wfstatus.Foreign_Bank_Certificate_Verified_FL
		--	,wfstatus.Three_Year_Tax_Trust_Deed_Verified_FL
		--	,wfstatus.Trust_Beneficiary_List_Verified_FL
		--	,wfstatus.IRS_Letter_Verified_Verified_FL
		--	,wfstatus.Electronic_Delivery_Verified_FL
		--	,wfstatus.Qualified_Purchaser_Verified_FL
		--	,wfstatus.Investor_Name_Verified_FL
		--	,wfstatus.Investor_Address_Verified_FL
		--	,wfstatus.Investor_DOB_Verified_FL
		--	,wfstatus.Investor_Signature_Verified_FL
		--	,wfstatus.Investor_Wire_Instructions_Verified_FL
		--	,wfstatus.Investor_Exempt_Verified_FL
		--	,wfstatus.Investor_Tax_ID_Verified_FL
		--	,wfstatus.Investor_Accredited_Verified_FL
		--	,wfstatus.Investor_Subscription_Compliance_Verified_FL
		--	,wfstatus.Investor_Enhanced_Name_Verified_FL
		--	,wfstatus.Investor_Wire_Info_FL
		--	,wfstatus.DOB_SSN_Verified_FL
		--	,wfstatus.Enhanced_Employee_Benefit_Verified_FL
		--	,wfstatus.Enhanced_Regulated_Verification_FL
		--	,wfstatus.Jurisdiction_Verified_FL
		--	,wfstatus.Legal_Entity_Verfied_FL
		--	,wfstatus.Taxable_Year_Verified_FL
		--	,wfstatus.Taxable_Partner_Verified_FL
		--	,wfstatus.Enhanced_Trading_Verification_FL
		--	,wfstatus.Authorized_Signer_Verified_FL
		--	,wfstatus.Authorized_Signer_Name_Addr_Verified_FL
		--	,wfstatus.Authorized_Signer_Info_Verified_FL
		--	,wfstatus.OFAC_Screen_Investor_Name_Verified_FL
		--	,wfstatus.Authorized_Signature_Verified_FL
		--	,wfstatus.Authorized_Name_Addr_FL
		--	,wfstatus.BO_Partner_Name_Addr_FL
		--	,wfstatus.BO_Partner_Info_Verified_FL
		--	,wfstatus.POA_Name_Addr_FL
		--	,wfstatus.Security_Verification_FL
		--	,CorpType.Corporation_Type_ID AS Expr1
		--	,CorpType.Corporation_Type_Name
		--	,TransStatus.Transaction_Status_Name AS Transaction_Status_Cd
		--	,verftype.Verification_Type_ID
		--	,verftype.Verification_Type_Name AS 'Individual_Verification_Type_Name'
		--	,verftype1.Verification_Type_Name AS 'Joint_Owner_Verification_Type'
		--	,verftype2.Verification_Type_Name AS 'POA_BO_Partner_Verification_Type'
		----,penidngpa
		--FROM cds.Client c
		--INNER JOIN cds.ClientFund CF ON c.ClientId = cf.ClientId
		--INNER JOIN cds.Fund F ON CF.FundId = F.FundId
		--INNER JOIN cds.FundInvestor FINV ON F.FundId = FINV.FundId
		--INNER JOIN cds.Investor Inv ON FINV.InvestorId = Inv.InvestorId
		--INNER JOIN cds.PendingTransaction pendtran ON c.ClientId = pendtran.ClientId
		--	AND F.FundId = pendtran.FundId
		--	AND inv.InvestorId = pendtran.InvestorId
		--LEFT OUTER JOIN dbo.Investor_Transaction_Workflow_Status wfstatus ON wfstatus.Transaction_Id = pendtran.WorkflowTransactionId
		--LEFT OUTER JOIN cds.TransactionType Trantype ON pendtran.TransactionTypeCode = Trantype.TransactionTypeCode
		--LEFT OUTER JOIN cds.AccountMaintenanceType acct_type ON acct_type.AccountMaintenanceTypeCode = pendtran.AccountMaintenanceTypeCode
		--LEFT OUTER JOIN cds.InvestmentTermType invtype ON invtype.InvestmentTermTypeCode = pendtran.InvestmentTermTypeCode
		--LEFT OUTER JOIN cds.Investor TransferInvestor ON TransferInvestor.InvestorId = pendtran.InvestorId
		--LEFT OUTER JOIN cds.ClientType CT ON pendtran.ClientTypeCode = CT.ClientTypeCode
		--LEFT OUTER JOIN cds.TransactionStatusType transtatustype ON transtatustype.TransactionStatusTypeCode = pendtran.TransactionStatusTypeCode
		--LEFT OUTER JOIN cds.TransactionUnitType tranunittype ON PendTran.TransactionUnitTypeCode = tranunittype.TransactionUnitTypeCode
		--LEFT OUTER JOIN cds.InstPCGType insttype ON pendtran.InstPCGTypeCode = insttype.InstPCGTypeCode
		--LEFT OUTER JOIN cds.CurrencyType currtype ON pendtran.CurrencyTypeCode = currtype.CurrencyTypeCode
		--LEFT OUTER JOIN cds.investorcontact invcontact ON invcontact.InvestorId = inv.InvestorId
		--	AND ContactSubTypeCode = 6
		--LEFT OUTER JOIN cds.contact contact ON contact.contactid = invcontact.contactid
		--LEFT OUTER JOIN cds.investorcontact invcontact2 ON invcontact2.InvestorId = inv.InvestorId
		--	AND invcontact2.ContactSubTypeCode = 8
		--LEFT OUTER JOIN cds.contact contact1 ON contact1.contactid = invcontact2.contactid
		--LEFT OUTER JOIN cds.investorcontact invcontact3 ON invcontact3.InvestorId = inv.InvestorId
		--	AND invcontact2.ContactSubTypeCode = 9
		--LEFT OUTER JOIN cds.contact contact2 ON contact2.contactid = invcontact3.contactid
		--LEFT OUTER JOIN cds.FINRAStatusType FINRASTATUS ON inv.FINRA5130StatusTypeCode = FINRASTATUS.[FINRAStatusTypeCode]
		--LEFT OUTER JOIN cds.DividendDistributionElectionType distr ON distr.DividendDistributionElectionTypeCode = finv.DividendDistributionElectionTypeCode
		--LEFT OUTER JOIN Corporation_Type CorpType ON wfstatus.Corporation_Type_ID = CorpType.Corporation_Type_ID
		--LEFT OUTER JOIN Transaction_Status TransStatus ON wfstatus.Transaction_Status_Cd = TransStatus.Transaction_Status_Cd
		--LEFT OUTER JOIN Verification_Type verftype ON wfstatus.Individual_Verification_Type_ID = verftype.Verification_Type_ID
		--LEFT OUTER JOIN Verification_Type verftype1 ON wfstatus.Joint_Owner_Verification_Type_ID = verftype1.Verification_Type_ID
		--LEFT OUTER JOIN Verification_Type verftype2 ON wfstatus.POA_BO_Partner_Verification_Type_ID = verftype2.Verification_Type_ID
		--LEFT OUTER JOIN cds.PendingTransactionPayment tranpay ON tranpay.PendingTransactionId = pendtran.PendingTransactionId
		--	AND FinalPaymentFlag = 1
		--LEFT OUTER JOIN #tranpending tranpay1 ON tranpay1.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay1.RowNum = 1
		--LEFT OUTER JOIN #tranpending tranpay2 ON tranpay2.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay2.RowNum = 2
		--LEFT OUTER JOIN #tranpending tranpay3 ON tranpay3.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay3.RowNum = 3
		--LEFT OUTER JOIN #tranpending tranpay4 ON tranpay4.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay4.RowNum = 4
		--LEFT OUTER JOIN #tranpending tranpay5 ON tranpay5.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay5.RowNum = 5
		--LEFT OUTER JOIN #tranpending tranpay6 ON tranpay6.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay6.RowNum = 6
		--LEFT OUTER JOIN #tranpending tranpay7 ON tranpay7.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay7.RowNum = 7
		--LEFT OUTER JOIN #tranpending tranpay8 ON tranpay8.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay8.RowNum = 8
		--LEFT OUTER JOIN #tranpending tranpay9 ON tranpay9.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay9.RowNum = 9
		--LEFT OUTER JOIN #tranpending tranpay10 ON tranpay10.PendingTransactionId = pendtran.PendingTransactionId
		--	AND tranpay10.RowNum = 10
		-- Override sql strings if sql string parameter has any value         
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
		--SELECT @sql_txt1

		SET @sql_txt1 = 'select  ' + @sql_txt1 + ' from dbo.KYCOnbaseview A ' + 
			'LEFT OUTER JOIN #tranpending tranpay1 ON tranpay1.PendingTransactionId = A.PendingTransactionId
and tranpay1.RowNum = 1
LEFT OUTER JOIN #tranpending  tranpay2 ON tranpay2.PendingTransactionId = A.PendingTransactionId
and tranpay2.RowNum = 2
LEFT OUTER JOIN #tranpending  tranpay3 ON tranpay3.PendingTransactionId = A.PendingTransactionId
and tranpay3.RowNum = 3
LEFT OUTER JOIN #tranpending tranpay4 ON tranpay4.PendingTransactionId = A.PendingTransactionId
and tranpay4.RowNum = 4
LEFT OUTER JOIN #tranpending  tranpay5 ON tranpay5.PendingTransactionId = A.PendingTransactionId
and tranpay5.RowNum = 5
LEFT OUTER JOIN #tranpending  tranpay6 ON tranpay6.PendingTransactionId = A.PendingTransactionId
and tranpay6.RowNum = 6
LEFT OUTER JOIN #tranpending  tranpay7 ON tranpay7.PendingTransactionId = A.PendingTransactionId
and tranpay7.RowNum = 7
LEFT OUTER JOIN #tranpending tranpay8 ON tranpay8.PendingTransactionId = A.PendingTransactionId
and tranpay8.RowNum = 8
LEFT OUTER JOIN #tranpending  tranpay9 ON tranpay9.PendingTransactionId = A.PendingTransactionId
and tranpay9.RowNum = 9
LEFT OUTER JOIN #tranpending  tranpay10 ON tranpay10.PendingTransactionId = A.PendingTransactionId
and tranpay10.RowNum = 10
' 
			+ (
				CASE 
					WHEN (@p_FundId IS NOT NULL)
						THEN ' INNER JOIN #tempfund tempfn ON tempfn.fundid = a.fundid'
					ELSE ''
					END
				) + (
				CASE 
					WHEN (@p_InvestorId IS NOT NULL)
						THEN ' INNER JOIN #tempinvestor tiv  ON tiv.InvestorId = a.External_InvestorID'
					ELSE ''
					END
				) + ' where A.effectivedate between ''' + Convert(VARCHAR(10), @p_Start_Dt, 101) + ''' and ''' + Convert(VARCHAR(10), @p_End_Dt, 101) + '''' + @filter_txt1

		-- +@grp_txt1 + @sort_txt1
		--SELECT @sql_txt1

		EXECUTE sp_executesql @sql_txt1
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

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tempfund', 'U') IS NOT NULL
		DROP TABLE #tempfund

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tempinvestor', 'U') IS NOT NULL
		DROP TABLE #tempinvestor

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tranpending', 'U') IS NOT NULL
		DROP TABLE #tranpending

	RETURN @ReturnCode;
END;

GO


