USE [NetikIP]
GO
/****** Object:  StoredProcedure [cds].[p_KYC_Dealboard_Report]    Script Date: 5/1/2014 5:19:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [cds].[p_KYC_Dealboard_Report] (
	-- Add the parameters for the stored procedure here	
	@p_ClientId VARCHAR(12)
	,@p_FundId VARCHAR(8000) = NULL
	,@p_InvestorId VARCHAR(8000) = NULL
	,@p_Start_Dt DATETIME
	,@p_End_Dt DATETIME
	,@inq_num INT = NULL
	,@qry_num INT = NULL
	,@pselect_txt VARCHAR(8000) = NULL
	,@porderby_txt VARCHAR(255) = NULL
	,@pfilter_txt VARCHAR(1000) = NULL
	,@pgroupby_txt VARCHAR(8000) = NULL
	)
AS
BEGIN /*----Procedure Begin*/
	/***          
================================================================================          
 Name        : cds.p_KYC_Onbase_Dealboard_Detail_Report           
 Author      : VBANDI   
 Date        : 03/14/2014    
 Description : 
===============================================================================          
 Parameters  :   
 Name				|I/O|   Description         
 ------------------------------------------------------------------------------      
 @p_ClientId		I		Client Id
 @p_FundId			I		Fund Id 
 @p_InvestorId		I		InvestorId
 @p_Start_Dt		I		Start Time stamp
 @p_End_Dt			I		End Time Stamp
 @inq_num			I       Inquiry number
 @qry_num			I       qry number
 @pselect_txt		I       select statement
 @porderby_txt		I       order by statement
 @pfilter_txt		I       Filter statement
 @pgroupby_txt		I       Group by 
--------------------------------------------------------------------------------          
 Returns      :                    
Name										Type (length)   Description      
Client ID									int				Client ID 
FundID										String			FundID
Investor ID									String			Investor ID
--------------------------------------------------------------------------------                    
 If record set is retuned give brief description of the fields being returned                    
 Return Value: Return code                    
     Success : 0(@error_number)                     
     Failure : Error number(@error_number)
--------------------------------------------------------------------------------     
Usage  :         
--Detail report 
EXEC cds.p_KYC_Dealboard_Report @p_ClientId = N'1164        '
	,@p_FundId = DEFAULT
	,@p_InvestorId = DEFAULT
	,@p_Start_Dt = '2014-01-01 00:00:00'
	,@p_End_Dt = '2014-03-17 23:59:59'
	,@inq_num = 14662
	,@qry_num = 14662
	,@pselect_txt = N' A.TransactionStatus, A.ExternalTransactionId, A.FundId, A.FundName, A.External_InvestorID, A.Investor_Legal_Name, A.Pending_Transaction_Type,sum(Transaction_Amount)'
	,@porderby_txt = DEFAULT
	,@pfilter_txt = DEFAULT
	,@pgroupby_txt = N'A.TransactionStatus, A.ExternalTransactionId, A.FundId, A.FundName, A.External_InvestorID, A.Investor_Legal_Name, A.Pending_Transaction_Type'
--Pending Transaction report
EXEC cds.p_KYC_Dealboard_Report @p_ClientId = N'1164        '
	,@p_FundId = DEFAULT
	,@p_InvestorId = DEFAULT
	,@p_Start_Dt = '2014-01-01 00:00:00'
	,@p_End_Dt = '2014-03-17 23:59:59'
	,@inq_num = 14660
	,@qry_num = 14660
	,@pselect_txt = 
	N'A.ClientId, A.clientname, A.FundId, A.FundName, A.External_InvestorID, A.Investor_Legal_Name, A.Indemnification_Letter_Tx, A.Transaction_Id, A.External_Investor_Id, A.W9_Document_Tx, A.W8_Document_Tx, A.Authorized_Signer_Verified_Tx, A.Individual_ID_Verified_Tx, A.Individual_Verification_Type_ID, A.Joint_Owner_ID_Verified_Tx, A.Joint_Owner_Verification_Type_ID, A.Joint_Owner_Verification_Type, A.POA_BO_Partner_ID_Verified_Tx, A.POA_BO_Partner_Verification_Type_ID, A.POA_BO_Partner_Verification_Type, A.Corporation_ID_Verified_Tx, A.Corporation_Type_Name, A.Foreign_Bank_Certificate_Verified_Tx, A.Three_Year_Tax_Trust_Deed_Verified_Tx, A.IRS_Letter_Verified_Tx, A.Trust_Beneficiary_List_Verified_Tx, A.Investor_Address_Verified_Tx, A.Investor_DOB_Verified_Tx, A.Investor_Signature_Verified_Tx, A.Investor_Wire_Instructions_Verified_Tx, A.ERISA_Status, A.Authorized_Signer_Verified_Tx, A.OFAC_Screen_Investor_Name_Verified_Tx, A.Investor_Tax_ID_Verified_Tx, A.Electronic_Delivery_Verified_Tx, A.Investor_Name_Verified_Tx, A.Qualified_Purchaser_Verified_Tx, A.Investor_Accredited_Verified_Tx, A.Investor_Subscription_Compliance_Verified_Tx, A.Investor_Enhanced_Name_Verified_Tx, A.DOB_SSN_Verified_Tx, A.Enhanced_Employee_Benefit_Verified_Tx, A.Entity_Trading_Verification_Tx, A.Jurisdiction_Verified_Tx, A.Legal_Entity_Verfied_Tx, A.Taxable_Year_Verified_Tx, A.Taxable_Partner_Verified_Tx, A.Investor_Exempt_Verified_Tx, A.Enhanced_Trading_Verification_Tx, A.Authorized_Signature_Verified_Tx, A.Authorized_Name_Addr_Verified_Tx, A.BO_Partner_Name_Addr_Verified_Tx, A.Investor_Wire_Info_Tx, A.POA_Name_Addr_Verified_Tx, A.Authorized_Signer_Info_Verified_Tx, A.BO_Partner_Info_Verified_Tx, A.NonEntity_Trading_Verification_Tx'
	,@porderby_txt = DEFAULT
	,@pfilter_txt = DEFAULT
	,@pgroupby_txt = DEFAULT
--EXEC cds.p_KYC_Dealboard_Report @p_ClientId = N'1164        '
	,@p_FundId = DEFAULT
	,@p_InvestorId = DEFAULT
	,@p_Start_Dt = '2014-01-01 00:00:00'
	,@p_End_Dt = '2014-03-27 23:59:59'
	,@inq_num = 14665
	,@qry_num = 14665
	,@pselect_txt = 
	N'A.ClientId, A.clientname, A.FundId, A.FundName, A.External_InvestorID, A.Investor_Legal_Name, A.Indemnification_Letter_Tx, A.Transaction_Id, A.External_Investor_Id, A.W9_Document_Tx, A.W8_Document_Tx, A.Authorized_Signer_Verified_Tx, A.Individual_ID_Verified_Tx, A.Individual_Verification_Type_ID, A.Joint_Owner_ID_Verified_Tx, A.Joint_Owner_Verification_Type_ID, A.Joint_Owner_Verification_Type, A.POA_BO_Partner_ID_Verified_Tx, A.POA_BO_Partner_Verification_Type_ID, A.POA_BO_Partner_Verification_Type, A.Corporation_ID_Verified_Tx, A.Corporation_Type_Name, A.Foreign_Bank_Certificate_Verified_Tx, A.Three_Year_Tax_Trust_Deed_Verified_Tx, A.IRS_Letter_Verified_Tx, A.Trust_Beneficiary_List_Verified_Tx, A.Investor_Address_Verified_Tx, A.Investor_DOB_Verified_Tx, A.Investor_Signature_Verified_Tx, A.Investor_Wire_Instructions_Verified_Tx, A.ERISA_Status, A.Authorized_Signer_Verified_Tx, A.OFAC_Screen_Investor_Name_Verified_Tx, A.Investor_Tax_ID_Verified_Tx, A.Electronic_Delivery_Verified_Tx, A.Investor_Name_Verified_Tx, A.Qualified_Purchaser_Verified_Tx, A.Investor_Accredited_Verified_Tx, A.Investor_Subscription_Compliance_Verified_Tx, A.Investor_Enhanced_Name_Verified_Tx, A.DOB_SSN_Verified_Tx, A.Enhanced_Employee_Benefit_Verified_Tx, A.Entity_Trading_Verification_Tx, A.Jurisdiction_Verified_Tx, A.Legal_Entity_Verfied_Tx, A.Taxable_Year_Verified_Tx, A.Taxable_Partner_Verified_Tx, A.Investor_Exempt_Verified_Tx, A.Enhanced_Trading_Verification_Tx, A.Authorized_Signature_Verified_Tx, A.Authorized_Name_Addr_Verified_Tx, A.BO_Partner_Name_Addr_Verified_Tx, A.Investor_Wire_Info_Tx, A.POA_Name_Addr_Verified_Tx, A.Authorized_Signer_Info_Verified_Tx, A.BO_Partner_Info_Verified_Tx, A.NonEntity_Trading_Verification_Tx'
	,@porderby_txt = DEFAULT
	,@pfilter_txt = DEFAULT
	,@pgroupby_txt = DEFAULT


History:    
Name			 Date				Description    
-------------------------------------------------------------------------------  
VBANDI			20140304			Initial Version
================================================================================    
*/
	SET NOCOUNT ON;

	DECLARE @ReturnCode INT;-- Return code value for the stored procedure
	DECLARE @Comma CHAR(1);
	DECLARE @msg VARCHAR(2048);
	DECLARE @sql_txt1 NVARCHAR(4000);
	DECLARE @filter_txt1 VARCHAR(1000);
	DECLARE @sort_txt1 VARCHAR(255);
	DECLARE @grp_txt1 VARCHAR(255);
	DECLARE @Paramdef NVARCHAR(4000);
	DECLARE @sqlselect VARCHAR(20);

	-- Initialize SQL variables
	SET @sql_txt1 = ' ';
	SET @sqlselect = ' ';
	SET @filter_txt1 = ' ';
	SET @sort_txt1 = ' ';
	SET @ReturnCode = 0;
	SET @Comma = ',';

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tempfund', 'U') IS NOT NULL
		DROP TABLE #tempfund;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tranpending', 'U') IS NOT NULL
		DROP TABLE #tranpending;

	/*Start VBANDI 04232014*/
	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#temp_positions', 'U') IS NOT NULL
		DROP TABLE #temp_positions;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#FundSourceSystemMapping', 'U') IS NOT NULL
		DROP TABLE #FundSourceSystemMapping;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#FundInvestorSourceSystemMapping', 'U') IS NOT NULL
		DROP TABLE #FundInvestorSourceSystemMapping;

	CREATE TABLE #FundSourceSystemMapping (
		FundSourceSystemMappingId INT NOT NULL
		,FundId CHAR(12) NOT NULL
		,SourceSystemFundId INT
		);

	CREATE CLUSTERED INDEX IDX_FundSourceSystemMapping ON #FundSourceSystemMapping (
		FundSourceSystemMappingId
		,FundId
		)

	CREATE TABLE #FundInvestorSourceSystemMapping (
		FundInvestorSourceSystemMappingId INT NOT NULL
		,InvestranId CHAR(12) NOT NULL
		,FundInvestorId INT
		,SourceSystemInvestorId INT --VBANDI 1111
		);

	CREATE CLUSTERED INDEX IDX_FundInvestorSourceSystemMapping ON #FundInvestorSourceSystemMapping (
		FundInvestorSourceSystemMappingId
		,InvestranId
		)

	CREATE TABLE #temp_positions (
		--   Rcd_Num INT identity(1,1) NOT NULL PRIMARY KEY CLUSTERED
		--,
		--Acct_id CHAR(12) NOT NULL
		--,ref_acct_id CHAR(12) NOT NULL

		SourceSystemInvestorId int --VBANDI 1111
		,NAV FLOAT
		,NAV_Date DATETIME
		,Market_value FLOAT
		,as_of_tms DATETIME
		,clientid CHAR(12)
		,investorid INT
		,Fundid INT
		);

	/*End VBANDI 04232014*/
	CREATE TABLE #tempfund (Fundid VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED);

	CREATE TABLE #tranpending (
		PendingTransactionPaymentId INT NOT NULL PRIMARY KEY CLUSTERED
		,PendingTransactionId INT NOT NULL
		,PaymentAmount INT NOT NULL
		,PaymentDate DATETIME NOT NULL
		,Rownum INT NOT NULL
		);

	BEGIN TRY
		IF (
				dbo.Fn_ntk_sqlsanitizer(@pselect_txt) = 1
				OR dbo.Fn_ntk_sqlsanitizer(@pfilter_txt) = 1
				OR dbo.Fn_ntk_sqlsanitizer(@pgroupby_txt) = 1
				OR dbo.Fn_ntk_sqlsanitizer(@porderby_txt) = 1
				)
		BEGIN
			PRINT 'SQL SCRIPT IS INJECTED';

			RETURN 16;
		END;

		INSERT INTO #tranpending (
			PendingTransactionPaymentId
			,PendingTransactionId
			,PaymentAmount
			,PaymentDate
			,RowNum
			)
		SELECT PendingTransactionPaymentId
			,PendingTransactionId
			,PaymentAmount
			,PaymentDate
			,ROW_NUMBER() OVER (
				PARTITION BY PendingTransactionId ORDER BY PaymentDate DESC
				) AS RowNum
		FROM cds.PendingTransactionPayment;

		/*Start VBANDI 04232014*/
		INSERT INTO #FundSourceSystemMapping (
			FundSourceSystemMappingId
			,FundId
			,SourceSystemFundId
			)
		SELECT fs.FundSourceSystemMappingId
			,CASE 
				WHEN fs.SourceSystemCode = 4
					THEN CAST(f.clientid AS CHAR(4)) + '-P' + REPLICATE('0', 6 - LEN(fs.SourceSystemFundId)) + fs.SourceSystemFundId
				ELSE CAST(f.clientid AS CHAR(4)) + '-' + REPLICATE('0', 7 - LEN(fs.SourceSystemFundId)) + fs.SourceSystemFundId
				END AS 'FundId'
			,fs.fundid AS SourceSystemFundId
		FROM cds.FundSourceSystemMapping fs
		INNER JOIN cds.fund f ON fs.fundid = f.fundid;

		INSERT INTO #FundInvestorSourceSystemMapping (
			FundInvestorSourceSystemMappingId
			,InvestranId
			,FundInvestorId
			,SourceSystemInvestorId--VBANDI 1111
			)
		SELECT finvs.FundInvestorSourceSystemMappingId
			,CASE 
				WHEN finvs.SourceSystemCode = 4
					THEN CAST(f.clientid AS CHAR(4)) + '-P' + REPLICATE('0', 6 - LEN(finvs.SourceSystemFundInvestorId)) + finvs.SourceSystemFundInvestorId
				ELSE CAST(f.clientid AS CHAR(4)) + '-' + REPLICATE('0', 7 - LEN(finvs.SourceSystemInvestorId)) + finvs.SourceSystemInvestorId
				END AS FundId
			,finvs.FundInvestorId
			,finvs.SourceSystemInvestorId--VBANDI 1111
		FROM cds.client c
		INNER JOIN cds.ClientFund CF ON c.ClientId = cf.ClientId
		INNER JOIN cds.Fund F ON CF.FundId = F.FundId
		INNER JOIN cds.FundType FT ON FT.FundTypeCode = F.FundTypeCode
		INNER JOIN cds.FundInvestor FINV ON F.FundId = FINV.FundId
		INNER JOIN cds.Investor Inv ON FINV.InvestorId = Inv.InvestorId
		INNER JOIN cds.FundInvestorSourceSystemMapping finvs ON finvs.FundInvestorId = FINV.FundInvestorId;

		WITH cte
		AS (
			SELECT pos.Acct_id
				,pos.ref_acct_id
				,pos.fld1_amt AS fld1_amt
				,pos.quantity AS quantity
				,pos.as_of_tms AS NAV_Date
				,pos.fld1_amt AS Market_Value
				,pos.as_of_tms AS as_of_tms
				,c.clientid
				,inv.investorid
				,f.fundid
				,ssi.SourceSystemInvestorId
				,ROW_NUMBER() OVER (
					PARTITION BY pos.acct_id
					,pos.ref_acct_id ORDER BY pos.as_of_tms ASC
					) AS RowNum
			FROM cds.Client c
			INNER JOIN cds.ClientFund CF ON c.ClientId = cf.ClientId
			INNER JOIN cds.Fund F ON CF.FundId = F.FundId
			INNER JOIN cds.FundInvestor FINV ON F.FundId = FINV.FundId
			INNER JOIN cds.Investor Inv ON FINV.InvestorId = Inv.InvestorId
			INNER JOIN cds.PendingTransaction pendtran ON c.ClientId = pendtran.ClientId
				AND F.FundId = pendtran.FundId
				AND inv.InvestorId = pendtran.InvestorId
			INNER JOIN #FundSourceSystemMapping ssf ON ssf.SourceSystemFundId = F.FundId
			INNER JOIN #FundInvestorSourceSystemMapping ssi ON ssi.FundInvestorId = FINV.FundInvestorId
			LEFT OUTER JOIN dbo.POSITION_DG pos ON pos.ACCT_ID = ssf.FundId
				AND pos.REF_ACCT_ID = ssi.InvestranId
			)
		INSERT INTO #temp_positions (
			--Acct_id  --VBANDI 11	
			--,ref_acct_id --VBANDI 11
			SourceSystemInvestorId  --VBANDI 11
			,NAV
			,NAV_Date
			,Market_value
			,as_of_tms
			,clientid
			,investorid
			,Fundid
			)
		SELECT SourceSystemInvestorId --VBANDI 1111
			--acct_id --VBANDI 1111
			--,ref_acct_id --VBANDI 1111
			,CASE 
				WHEN sum(quantity) = 0
					THEN 0
				ELSE round((sum(fld1_amt) / sum(quantity)), 4)
				END AS Nav
			,max(NAV_Date) AS NAV_Date
			,sum(market_value) AS Market_Value
			,max(as_of_tms) AS as_of_tms
			,clientid
			,investorid
			,Fundid
		FROM cte
		GROUP BY SourceSystemInvestorId
			,clientid
			,investorid
			,Fundid
			;

		--DELETE p
		--FROM #temp_positions p
		--WHERE EXISTS (
		--		SELECT 1
		--		FROM #temp_positions tp
		--		GROUP BY tp.acct_id
		--			,tp.ref_acct_id
		--		HAVING p.as_of_tms <> max(tp.as_of_tms)
		--			AND tp.acct_id = p.acct_id
		--			AND tp.ref_acct_id = p.ref_acct_id
		--		)

		/*End VBANDI 04232014*/
		IF (@p_FundId IS NOT NULL)
		BEGIN
			INSERT INTO #tempfund (fundid)
			SELECT DISTINCT item
			FROM dbo.f_DelimitedSplit8K(@p_FundId, @Comma);
		END;

		IF @inq_num IS NOT NULL
		BEGIN
			EXEC @ReturnCode = dbo.sp_Inquiry_BldSqlStrings @inq_num = @inq_num
				,@qry_num = @qry_num
				,@sql_text = @sql_txt1 OUTPUT
				,@filter_text = @filter_txt1 OUTPUT
				,@sort_text = @sort_txt1 OUTPUT
				,@groupby_text = @grp_txt1 OUTPUT;

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
				,@grp_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@pgroupby_txt)) = 0
						THEN ' '
					WHEN @pgroupby_txt IS NULL
						THEN ' '
					ELSE ' group by ' + rtrim(@pgroupby_txt)
					END;
		END;
		ELSE
		BEGIN
			SELECT @filter_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@filter_txt1)) = 0
						THEN ''
					WHEN @filter_txt1 IS NULL
						THEN ''
					ELSE ' and (' + rtrim(@filter_txt1) + ')'
					END;
		END;

		SET @sqlselect = CASE 
				WHEN DATALENGTH(rtrim(@pgroupby_txt)) > 0
					THEN 'select count(1) ,'
				ELSE 'select '
				END;
		--Note: We are using the dynamic query because the columns to select not fixed in advance. These can be changed dynamically from the interface.
		SET @sql_txt1 = @sqlselect + @sql_txt1 + ' from dbo.v_KYCOnbase A ' +
			--Start VBANDI 04232014
			'left outer JOIN #temp_positions tp ON a.fundvalue = tp.fundid  
	AND a.investorid = tp.investorid ' +
			--End VBANDI 04232014
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
						THEN ' INNER JOIN #tempfund tempfn ON tempfn.fund_id = a.fundid'
					ELSE ''
					END
				) + (
				CASE 
					WHEN (@p_InvestorId IS NOT NULL)
						THEN ' INNER JOIN #tempinvestor tiv  ON tiv.InvestorId = a.External_InvestorID'
					ELSE ''
					END
				) + ' where A.effectivedate between ''' + Convert(VARCHAR(10), @p_Start_Dt, 101) + ''' and ''' + Convert(VARCHAR(10), @p_End_Dt, 101) + '''' + ' and A.Clientid = ''' + @p_ClientId + '''' + @filter_txt1 + @grp_txt1;
		SET @paramdef = '@p_ClientId VARCHAR(12)
	,@p_FundId VARCHAR(8000)  
	,@p_InvestorId VARCHAR(8000)  
	,@p_Start_Dt DATETIME
	,@p_End_Dt DATETIME
	,@inq_num INT  
	,@qry_num INT  
	,@pselect_txt VARCHAR(8000)  
	,@porderby_txt VARCHAR(255)  
	,@pfilter_txt VARCHAR(1000)  
	,@pgroupby_txt VARCHAR(8000)';

		--SELECT @sql_txt1
		EXECUTE dbo.sp_executesql @sql_txt1
			,@paramdef
			,@p_ClientId
			,@p_FundId
			,@p_InvestorId
			,@p_Start_Dt
			,@p_End_Dt
			,@inq_num
			,@qry_num
			,@pselect_txt
			,@porderby_txt
			,@pfilter_txt
			,@pgroupby_txt;
	END TRY

	BEGIN CATCH
		SET @ReturnCode = ERROR_NUMBER();

		DECLARE @ERRMSG NVARCHAR(2100);
		DECLARE @ERRSEV INT;
		DECLARE @ERRSTATE INT;

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
		DROP TABLE #tempfund;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#tranpending', 'U') IS NOT NULL
		DROP TABLE #tranpending;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#temp_positions', 'U') IS NOT NULL
		DROP TABLE #temp_positions;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#FundSourceSystemMapping', 'U') IS NOT NULL
		DROP TABLE #FundSourceSystemMapping;

	/*-------------------------Drop temp tables-------------------------------------------*/
	IF OBJECT_ID('TempDB..#FundInvestorSourceSystemMapping', 'U') IS NOT NULL
		DROP TABLE #FundInvestorSourceSystemMapping;

	RETURN @ReturnCode;
END;
