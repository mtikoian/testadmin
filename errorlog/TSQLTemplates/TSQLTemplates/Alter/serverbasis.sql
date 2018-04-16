USE NETIKIP;
GO

DECLARE @Error INTEGER;
DECLARE @servername VARCHAR(50);

SET @servername = (
		SELECT @@servername
		)

--SELECT @servername
BEGIN TRY
	BEGIN TRANSACTION

	IF (@servername = 'SEINTKQADB01')
	BEGIN
		UPDATE qry_def
		SET qry_nme = 
			'A.TransactionStatus, A.ExternalTransactionId, A.FundId, A.FundName, A.Class_ID, A.Class_Name, A.Series_ID, A.Series_Name, A.External_InvestorID, A.Investor_Legal_Name, A.Pending_Transaction_Type, A.TransfereeInvestorId, A.Investorname_Transferee, A.ClassID_SwitchIn, A.ClassName_Switch_In, A.Series_ID_SwitchIn, A.SeriesName_SwitchIn, tp.NAV_Date as Nav_Date, A.Transaction_Amount, A.Transaction_Curency, A.Transaction_UnitShare_Amount, A.Transaction_Unit_Type, A.Account_Maintenance_Type, A.newinvestorname, A.Notional_Amount, tp.NAV as Nav, tp.Market_Value as Market_Value, A.Pending_Transaction_Effective_Date, A.Pending_Transaction_Doc_Received, A.Pending_Transaction_Proceeds_Received, A.Release_Proceeds_Operating_Account, tranpay1.PaymentDate AS PaymentDate1, tranpay1.PaymentAmount AS PaymentAmount1, tranpay2.PaymentDate AS PaymentDate2, tranpay2.PaymentAmount AS PaymentAmount2, tranpay3.PaymentDate AS PaymentDate3, tranpay3.PaymentAmount AS PaymentAmount3, A.Subsequent_Payment_Amounts, A.Date_Sub_Payment, A.Final_Payment_Flag, A.InterestEarned, A.AML_Due_Date, A.Onbase_AML_outstanding_Days, A.Workflow_Transaction_Record, A.Inst_PCG, A.Financial_Advisor_ID, A.Financial_Advisor, A.Broker, A.Sub_Channel'
		WHERE inq_num = 15112

		UPDATE qry_def
		SET qry_nme = 
			' A.TransactionStatus, A.ExternalTransactionId, A.FundId, A.FundName, A.Class_ID, A.Class_Name, A.Series_ID, A.Series_Name, A.External_InvestorID, A.Investor_Legal_Name, A.Pending_Transaction_Type, A.TransfereeInvestorId, A.Investorname_Transferee, A.ClassID_SwitchIn, A.ClassName_Switch_In, A.Series_ID_SwitchIn, A.SeriesName_SwitchIn, tp.NAV_Date as NAV_Date , A.Transaction_Amount, A.Transaction_Curency, A.Transaction_UnitShare_Amount, A.Transaction_Unit_Type, A.Account_Maintenance_Type, A.newinvestorname, A.Notional_Amount, tp.NAV as Nav, tp.Market_Value as Market_Value, A.Pending_Transaction_Effective_Date, A.Pending_Transaction_Doc_Received, A.Pending_Transaction_Proceeds_Received, A.Release_Proceeds_Operating_Account, tranpay1.PaymentDate AS PaymentDate1, tranpay1.PaymentAmount AS PaymentAmount1, tranpay2.PaymentDate AS PaymentDate2, tranpay2.PaymentAmount AS PaymentAmount2, tranpay3.PaymentDate AS PaymentDate3, tranpay3.PaymentAmount AS PaymentAmount3, A.Subsequent_Payment_Amounts, A.Date_Sub_Payment, A.Final_Payment_Flag, A.InterestEarned, A.AML_Due_Date, A.Onbase_AML_outstanding_Days, A.Workflow_Transaction_Record, A.Inst_PCG, A.Financial_Advisor_ID, A.Financial_Advisor, A.Broker, A.Sub_Channel'
		WHERE inq_num = 15115

		UPDATE qry_def
		SET qry_nme = 
			' A.TransactionStatus, A.ExternalTransactionId, A.PendingTransactionId, A.FundId, A.FundName, A.Class_ID, A.Class_Name, A.Series_ID, A.Series_Name, A.External_InvestorID, A.Investor_Legal_Name, A.Pending_Transaction_Type, A.TransfereeInvestorId, A.Investorname_Transferee, A.ClassID_SwitchIn, A.ClassName_Switch_In, A.Series_ID_SwitchIn, A.SeriesName_SwitchIn, tp.NAV_Date as NAV_Date, A.Transaction_Amount, A.Transaction_Curency, A.Transaction_UnitShare_Amount, A.Transaction_Unit_Type, A.Account_Maintenance_Type, A.newinvestorname, A.Notional_Amount, tp.NAV as Nav, tp.Market_Value as Market_Value, A.Pending_Transaction_Effective_Date, A.Pending_Transaction_Doc_Received, A.Pending_Transaction_Proceeds_Received, A.Release_Proceeds_Operating_Account, tranpay1.PaymentDate AS PaymentDate1, tranpay1.PaymentAmount AS PaymentAmount1, tranpay2.PaymentDate AS PaymentDate2, tranpay2.PaymentAmount AS PaymentAmount2, tranpay3.PaymentDate AS PaymentDate3, tranpay3.PaymentAmount AS PaymentAmount3, A.Subsequent_Payment_Amounts, A.Date_Sub_Payment, A.Final_Payment_Flag, A.InterestEarned, A.AML_Due_Date, A.Onbase_AML_outstanding_Days, A.Workflow_Transaction_Record, A.Inst_PCG, A.Financial_Advisor_ID, A.Financial_Advisor, A.Broker, A.Sub_Channel'
		WHERE inq_num = 15183

		PRINT 'Scripts executed successfully on QA'
	END
	ELSE IF (@servername = 'SEIGWPIPDB01-B')
	BEGIN
		UPDATE qry_def
		SET qry_nme = 
			'A.TransactionStatus,A.ExternalTransactionId,A.PendingTransactionId,A.FundId,A.FundName,A.Class_ID,A.Class_Name,A.Series_ID,A.Series_Name,A.External_InvestorID,A.Investor_Legal_Name,A.Pending_Transaction_Type,A.TransfereeInvestorId,A.Investorname_Transferee,A.ClassID_SwitchIn,A.ClassName_Switch_In,A.Series_ID_SwitchIn,A.SeriesName_SwitchIn,tp.NAV_Date as Nav_Date,A.Transaction_Amount,A.Transaction_Curency,A.Transaction_UnitShare_Amount,A.Transaction_Unit_Type,A.Account_Maintenance_Type,A.newinvestorname,A.Notional_Amount,tp.NAV as Nav,tp.Market_Value as Market_Value,A.Pending_Transaction_Effective_Date,A.Pending_Transaction_Doc_Received,A.Pending_Transaction_Proceeds_Received,A.Release_Proceeds_Operating_Account,tranpay1.PaymentDate AS PaymentDate1,tranpay1.PaymentAmount AS PaymentAmount1,tranpay2.PaymentDate AS PaymentDate2,tranpay2.PaymentAmount AS PaymentAmount2,tranpay3.PaymentDate AS PaymentDate3,tranpay3.PaymentAmount AS PaymentAmount3,A.Subsequent_Payment_Amounts,A.Date_Sub_Payment,A.Final_Payment_Flag,A.InterestEarned,A.AML_Due_Date,A.Onbase_AML_outstanding_Days,A.Workflow_Transaction_Record,A.Inst_PCG,A.Financial_Advisor_ID,A.Financial_Advisor,A.Broker,A.Sub_Channel'
		WHERE inq_num = 15196

		UPDATE qry_def
		SET qry_nme = ' A.TransactionStatus, A.ExternalTransactionId, A.FundId, A.FundName, A.External_InvestorID, A.Investor_Legal_Name, A.Pending_Transaction_Type,sum(Transaction_Amount)'
		WHERE inq_num = 15197

		UPDATE qry_def
		SET qry_nme = 'A.TransactionStatus, A.ExternalTransactionId, A.FundId, A.FundName, A.External_InvestorID, A.Investor_Legal_Name, A.Pending_Transaction_Type,sum(Transaction_Amount)'
		WHERE inq_num = 15519

		PRINT 'Scripts executed successfully on PROD'
	END
	ELSE
	BEGIN
		PRINT 'Scripts cannot be executed on this server!!!!!!!!!!!!!!!'
	END

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION

	DECLARE @error_message VARCHAR(2100);
	DECLARE @error_severity INT;
	DECLARE @error_state INT;

	SET @error_message = Error_message();
	SET @error_severity = Error_severity();
	SET @error_state = Error_state();

	PRINT 'ERROR:while updating records in fld_def';

	RAISERROR (
			@error_message
			,@error_severity
			,@error_state
			);
END CATCH;
GO


