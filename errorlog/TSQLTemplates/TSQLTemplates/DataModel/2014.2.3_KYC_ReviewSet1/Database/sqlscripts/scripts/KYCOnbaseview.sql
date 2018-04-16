USE [NetikIP]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[KYCOnbaseview]
as 

SELECT 
	pendtran.FundId   as FundId
	,pendtran.effectivedate as effectivedate
	,pendtran.ClientId   as ClientId
	,c.clientname as clientname
	,transtatustype.VALUE AS 'TransactionStatus'
	,pendtran.ExternalTransactionId as ExternalTransactionId 
	,pendtran.PendingTransactionId   as PendingTransactionId
	,F.FundName   as FundName
	,'' AS 'Class_ID'
	,'' AS 'Class_Name'
	,'' AS 'Series_ID'
	,'' AS 'Series_Name'
	,inv.ThirdPartyId AS 'External_InvestorID'
	,inv.InvestorName AS 'Investor_Legal_Name'
	,Trantype.value AS 'Pending_Transaction_Type'
	,pendtran.TransfereeInvestorId as TransfereeInvestorId
	,TransferInvestor.Investorname AS 'Investorname_Transferee'
	,pendtran.SwitchInFundId AS 'ClassID_SwitchIn'
	,F.FundName AS 'ClassName_Switch_In'
	,SwitchInFundId AS 'Series_ID_SwitchIn'
	--,pendtran.TransactionUnitTypeCode AS 'Series Name - Switch In'
	,tranunittype.value AS 'SeriesName_SwitchIn'
	--,CommitmentAmount
	,'' AS 'NAV_Date'
	,TransactionAmount AS 'Transaction_Amount'
	,currtype.value AS 'Transaction_Curency'
	--,pendtran.InvestmentTermTypeCode
	,TransactionUnitShareAmount AS 'Transaction_UnitShare_Amount'
	,invtype.value AS 'Transaction_Unit_Type'
	,NotionalAmount AS ' Notional_Amount'
	,'' AS NAV
	,'' AS 'Market_Value'
	,EffectiveDate AS 'Pending_Transaction_Effective_Date'
	,DocumentReceivedDate AS 'Pending_Transaction_Doc_Received'
	,ProceedsReceivedDate AS 'Pending_Transaction_Proceeds_Received'
	,ProceedsReleasedDate AS 'Release_Proceeds_Operating_Account'
	--,tranpay1.PaymentAmount AS 'First_Payment_Amount'
	--,tranpay2.PaymentAmount as 'Second_Payment_Amount'
	--,tranpay3.PaymentAmount as 'Third  Payment Amount'
	--,tranpay4.PaymentAmount as 'Fourth Payment Amount'
	--,tranpay5.PaymentAmount as 'Fifth Payment Amount'
	--,tranpay6.PaymentAmount as 'Sixth Payment Amount'
	--,tranpay7.PaymentAmount as 'Seventh Payment Amount'
	--,tranpay8.PaymentAmount as 'Eigth  Payment Amount'
	--,tranpay9.PaymentAmount as 'Ninth Payment Amountt'
	--,tranpay10.PaymentAmount as 'Tenth Payment Amount'
	--,tranpay1.PaymentDate AS 'Date Proceeds Wired to Investor - 1st Payment'
	--,tranpay2.PaymentDate as 'Date Proceeds Wired to Investor - 2nd Payment'
	--,tranpay3.PaymentDate as 'Date Proceeds Wired to Investor - 3rd Payment'
	--,tranpay4.PaymentDate as 'Date Proceeds Wired to Investor - 4th Payment'
	--,tranpay5.PaymentDate as 'Date Proceeds Wired to Investor - 5th Payment'
	--,tranpay6.PaymentDate as 'Date Proceeds Wired to Investor - 6th Payment'
	--,tranpay7.PaymentDate as 'Date Proceeds Wired to Investor - 7th Payment'
	--,tranpay8.PaymentDate as 'Date Proceeds Wired to Investor - 8th Payment'
	--,tranpay9.PaymentDate as 'Date Proceeds Wired to Investor - 9th Payment'
	--,tranpay10.PaymentDate as 'Date Proceeds Wired to Investor - 10th Payment'
	,tranpay.FinalPaymentFlag AS 'Final_Payment_Flag'
	,tranpay.PendingTransactionPaymentId  as 'PendingTransactionPaymentId'
	,'' AS 'Subsequent_Payment_Amounts'
	,'' AS 'InterestEarned'
	,wfstatus.AML_Due_Dt AS 'AML_Due_Date'
	,wfstatus.AML_outstanding_Days As 'Onbase_AML_outstanding_Days'
	,wfstatus.Transaction_Id AS 'Workflow_Transaction_Record'
	,wfstatus.Indemnification_Letter_FL AS 'Indemnification_Letter'
	,insttype.value AS 'Inst_PCG'
	
	,invcontact.FinancialAdvisorId AS 'Financial_Advisor_ID'
	,contact.ContactName AS 'Financial_Advisor'
	,contact1.ContactName AS 'Broker'
	,contact2.ContactName AS 'Sub_Channel'
	,invcontact.FinancialAdvisorAccountNumber AS 'Account_Number'
	,CASE 
		WHEN inv.ERISA = 1
			THEN 'Y'
		WHEN inv.ERISA = 0
			THEN 'N'
		ELSE NULL
		END AS 'ERISA_Status'
	,FINRASTATUS.value AS 'FINRA_Status_5130'
	,CASE 
		WHEN inv.FINRA5131Indicator = 1
			THEN 'Y'
		WHEN inv.FINRA5131Indicator = 0
			THEN 'N'
		ELSE NULL
		END AS 'FINRA_Status_5131'
	,CASE 
		WHEN FINV.SideLetterArrangement = 1
			THEN 'Y'
		WHEN FINV.SideLetterArrangement = 0
			THEN 'N'
		ELSE NULL
		END AS 'Side_Letter_Arrangement'
	,distr.value AS 'Distribution_Election'
	,CASE 
		WHEN FINV.EmployeeEligible = 1
			THEN 'Y'
		WHEN FINV.EmployeeEligible = 0
			THEN 'N'
		ELSE NULL
		END AS EmployeeEligible
	,wfstatus.Document_File_Path AS Document_File_Path
	,wfstatus.Transaction_Id
	,wfstatus.Client_Name
	,wfstatus.External_Investor_Id
	,wfstatus.Institution_Type_ID
	--,wfstatus.Transaction_Status_Cd
	,wfstatus.Individual_Verification_Type_ID
	,wfstatus.Joint_Owner_Verification_Type_ID
	,wfstatus.POA_BO_Partner_Verification_Type_ID
	,wfstatus.Corporation_Type_ID
	,wfstatus.AML_Due_Dt
	,wfstatus.AML_outstanding_Days
	,wfstatus.ERISA_Status as 'Onbase_ERISA_Status'
	,wfstatus.Indemnification_Letter_FL
	,wfstatus.W9_Document_FL
	,wfstatus.W8_Document_FL
	,wfstatus.Individual_ID_Verified_FL
	,wfstatus.Joint_Owner_ID_Verified_FL
	,wfstatus.POA_BO_Partner_ID_Verified_FL
	,wfstatus.Corporation_ID_Verified_FL
	,wfstatus.Foreign_Bank_Certificate_Verified_FL
	,wfstatus.Three_Year_Tax_Trust_Deed_Verified_FL
	,wfstatus.Trust_Beneficiary_List_Verified_FL
	,wfstatus.IRS_Letter_Verified_Verified_FL
	,wfstatus.Electronic_Delivery_Verified_FL
	,wfstatus.Qualified_Purchaser_Verified_FL
	,wfstatus.Investor_Name_Verified_FL
	,wfstatus.Investor_Address_Verified_FL
	,wfstatus.Investor_DOB_Verified_FL
	,wfstatus.Investor_Signature_Verified_FL
	,wfstatus.Investor_Wire_Instructions_Verified_FL
	,wfstatus.Investor_Exempt_Verified_FL
	,wfstatus.Investor_Tax_ID_Verified_FL
	,wfstatus.Investor_Accredited_Verified_FL
	,wfstatus.Investor_Subscription_Compliance_Verified_FL
	,wfstatus.Investor_Enhanced_Name_Verified_FL
	,wfstatus.Investor_Wire_Info_FL
	,wfstatus.DOB_SSN_Verified_FL
	,wfstatus.Enhanced_Employee_Benefit_Verified_FL
	,wfstatus.Enhanced_Regulated_Verification_FL
	,wfstatus.Jurisdiction_Verified_FL
	,wfstatus.Legal_Entity_Verfied_FL
	,wfstatus.Taxable_Year_Verified_FL
	,wfstatus.Taxable_Partner_Verified_FL
	,wfstatus.Enhanced_Trading_Verification_FL
	,wfstatus.Authorized_Signer_Verified_FL
	,wfstatus.Authorized_Signer_Name_Addr_Verified_FL
	,wfstatus.Authorized_Signer_Info_Verified_FL
	,wfstatus.OFAC_Screen_Investor_Name_Verified_FL
	,wfstatus.Authorized_Signature_Verified_FL
	,wfstatus.Authorized_Name_Addr_FL
	,wfstatus.BO_Partner_Name_Addr_FL
	,wfstatus.BO_Partner_Info_Verified_FL
	,wfstatus.POA_Name_Addr_FL
	,wfstatus.Security_Verification_FL
	,CorpType.Corporation_Type_ID as Corporation_TypeID
	,CorpType.Corporation_Type_Name
	,TransStatus.Transaction_Status_Name as Transaction_Status_Cd
	,verftype.Verification_Type_ID 
	,verftype.Verification_Type_Name as 'Individual_Verification_Type_Name'
	,verftype1.Verification_Type_Name AS 'Joint_Owner_Verification_Type'
	,verftype2.Verification_Type_Name AS 'POA_BO_Partner_Verification_Type'
FROM cds.Client c 
INNER JOIN cds.ClientFund CF ON c.ClientId = cf.ClientId
INNER JOIN cds.Fund F ON CF.FundId = F.FundId
INNER JOIN cds.FundInvestor FINV ON F.FundId = FINV.FundId
INNER JOIN cds.Investor Inv ON FINV.InvestorId = Inv.InvestorId
INNER JOIN cds.PendingTransaction pendtran ON c.ClientId = pendtran.ClientId
	AND F.FundId = pendtran.FundId
	AND inv.InvestorId = pendtran.InvestorId
LEFT OUTER JOIN dbo.Investor_Transaction_Workflow_Status wfstatus ON wfstatus.Transaction_Id = pendtran.WorkflowTransactionId
LEFT OUTER JOIN cds.TransactionType Trantype ON pendtran.TransactionTypeCode = Trantype.TransactionTypeCode
LEFT OUTER JOIN cds.AccountMaintenanceType acct_type ON acct_type.AccountMaintenanceTypeCode = pendtran.AccountMaintenanceTypeCode
LEFT OUTER JOIN cds.InvestmentTermType invtype ON invtype.InvestmentTermTypeCode = pendtran.InvestmentTermTypeCode
LEFT OUTER JOIN cds.Investor TransferInvestor ON TransferInvestor.InvestorId = pendtran.InvestorId
LEFT OUTER JOIN cds.ClientType CT ON pendtran.ClientTypeCode = CT.ClientTypeCode
LEFT OUTER JOIN cds.TransactionStatusType transtatustype ON transtatustype.TransactionStatusTypeCode = pendtran.TransactionStatusTypeCode
LEFT OUTER JOIN cds.TransactionUnitType tranunittype ON PendTran.TransactionUnitTypeCode = tranunittype.TransactionUnitTypeCode
LEFT OUTER JOIN cds.InstPCGType insttype ON pendtran.InstPCGTypeCode = insttype.InstPCGTypeCode
LEFT OUTER JOIN cds.CurrencyType currtype ON pendtran.CurrencyTypeCode = currtype.CurrencyTypeCode
LEFT OUTER JOIN cds.investorcontact invcontact ON invcontact.InvestorId = inv.InvestorId
	AND ContactSubTypeCode = 6
LEFT OUTER JOIN cds.contact contact ON contact.contactid = invcontact.contactid
LEFT OUTER JOIN cds.investorcontact invcontact2 ON invcontact2.InvestorId = inv.InvestorId
	AND invcontact2.ContactSubTypeCode = 8
LEFT OUTER JOIN cds.contact contact1 ON contact1.contactid = invcontact2.contactid
LEFT OUTER JOIN cds.investorcontact invcontact3 ON invcontact3.InvestorId = inv.InvestorId
	AND invcontact2.ContactSubTypeCode = 9
LEFT OUTER JOIN cds.contact contact2 ON contact2.contactid = invcontact3.contactid
LEFT OUTER JOIN cds.FINRAStatusType FINRASTATUS ON inv.FINRA5130StatusTypeCode = FINRASTATUS.[FINRAStatusTypeCode]
LEFT OUTER JOIN cds.DividendDistributionElectionType distr ON distr.DividendDistributionElectionTypeCode = finv.DividendDistributionElectionTypeCode
LEFT OUTER JOIN Corporation_Type CorpType ON wfstatus.Corporation_Type_ID = CorpType.Corporation_Type_ID
LEFT OUTER JOIN Transaction_Status TransStatus ON wfstatus.Transaction_Status_Cd = TransStatus.Transaction_Status_Cd
LEFT OUTER JOIN Verification_Type verftype ON wfstatus.Individual_Verification_Type_ID = verftype.Verification_Type_ID
LEFT OUTER JOIN Verification_Type verftype1 ON wfstatus.Joint_Owner_Verification_Type_ID = verftype1.Verification_Type_ID
LEFT OUTER JOIN Verification_Type verftype2 ON wfstatus.POA_BO_Partner_Verification_Type_ID = verftype2.Verification_Type_ID
LEFT OUTER JOIN cds.PendingTransactionPayment tranpay ON tranpay.PendingTransactionId = pendtran.PendingTransactionId
and FinalPaymentFlag = 1



GO


