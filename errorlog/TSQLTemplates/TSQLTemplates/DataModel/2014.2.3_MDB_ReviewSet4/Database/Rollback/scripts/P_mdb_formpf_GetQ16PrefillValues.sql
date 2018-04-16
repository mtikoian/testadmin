USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER procedure dbo.P_mdb_formpf_GetQ16PrefillValues
(
	@FundName VARCHAR(200),            
	@End_Date DATETIME    
)
AS


/***          
================================================================================          
 Name        : P_mdb_formpf_GetQ16PrefillValues          
 Author      : Schoudhary - 01/31/2013        
 Description : This procedure gets the Question 16 Prefill information for FormPF.           
===============================================================================          
 Parameters   :          
 Name					|I/O|  Description        
   @FundName			  I    Fund Name 
   @End_Date		  	  I    Period End Date   
--------------------------------------------------------------------------------                
 If record set is retuned give brief description of the fields being returned          
 Returns      :          
   Name						Type (length)		Description          
   VALVAL_ALT_CMB_AMT			18				Market Value
   LevelIndicator				15				Level Indicator
   LedgerType					40				Ledger Type		

--------------------------------------------------------------------------------   
 Return Value: Return code          
     Success : 0          
     Failure : @@ERROR          
                   Error number and Description          
 Revisions    :          
--------------------------------------------------------------------------------          
 Ini		|   Date		| Description          
--------------------------------------------------------------------------------          
Schoudhary     01/31/2013     Initial Version  
PPremkumar     02/11/2013     Added @TotalInvestor Calculation marked with -- ppremkumar 02112013
Schoudhary     02/13/2013     Removed implicit casting in where clause for @End_Date as per SEI standards
KAslam		   02/14/2013	  Removed nested select. replaced with joins 
							  - marked with --KAslam 02142013
--------------------------------------------------------------------------------          
Test Script  :    

--EXECUTE P_mdb_formpf_GetQ16PrefillValues 'Hedge Fund 3,Hedge Fund 2','2012-05-31'   
         
================================================================================          
***/ 

BEGIN

    SET nocount ON 
    SET fmtonly OFF 

	DECLARE @TotalInvestor Float					-- ppremkumar 02112013
	DECLARE @tempFundName TABLE (FundName  VARCHAR(200))		--KAslam 02142013


	BEGIN TRY 

		set @End_Date = @End_Date + ' 23:59:59.000' -- SC 02132013

		INSERT @tempFundName (FundName)								--KAslam 02142013
			SELECT  items     
			  FROM dbo.AccountSplit(@FundName,',')

		-- TotalInvestor Calculation -- ppremkumar 02112013
		SELECT @TotalInvestor = Sum(ipv.valval_cmb_amt) 
		FROM   dbo.investorpositionview ipv							--KAslam 02142013
			INNER JOIN dbo.formpfdatamapping dm ON ipv.acct_id = dm.portfolioaccountid
			INNER JOIN dbo.formpffundmaintenance fm ON dm.seiformpfdesc = fm.seiformpfdesc
			INNER JOIN @tempFundName tfn ON fm.reportingfundname = tfn.FundName
		WHERE  ipv.as_of_tms = @End_Date 
			   AND ipv.inq_basis_num = 3 
		GROUP  BY ipv.inq_basis_num 

		SELECT Sum(ipv.valval_cmb_amt) / @TotalInvestor AS '%Owned', 
		   ipv.inv_bene_owner_type 
		FROM   dbo.investorpositionview ipv							--KAslam 02142013
			INNER JOIN dbo.formpfdatamapping dm ON ipv.acct_id = dm.portfolioaccountid
			INNER JOIN dbo.formpffundmaintenance fm ON dm.seiformpfdesc = fm.seiformpfdesc
			INNER JOIN @tempFundName tfn ON fm.reportingfundname = tfn.FundName 
		WHERE  ipv.as_of_tms = @End_Date 
			   AND ipv.inq_basis_num = 3 
		GROUP  BY ipv.inq_basis_num, 
				  ipv.inv_bene_owner_type, 
				  ipv.as_of_tms 
	END TRY 

	BEGIN CATCH 
		DECLARE @errno    INT, 
				@errmsg   NVARCHAR(2048), 
				@errsev   INT, 
				@errstate INT; 

		SELECT @errno = Error_number(), 
			   @errmsg = 'Error in dbo.P_mdb_formpf_GetQ16PrefillValues' + Error_message(), 
			   @errsev = Error_severity(), 
			   @errstate = Error_state(); 

		RAISERROR(@errmsg,@errsev,@errstate); 
	END CATCH  

END

GO

-- Validate if procedure has been created.

IF  EXISTS 
	(
		SELECT 1 
		FROM   information_schema.routines 
		WHERE  routine_type = 'PROCEDURE' 
			   AND routine_schema = 'dbo' 
			   AND routine_name = 'P_mdb_formpf_GetQ16PrefillValues'  
	)
	BEGIN
		PRINT 'PROCEDURE dbo.P_mdb_formpf_GetQ16PrefillValues has been created.'
	END
ELSE
	BEGIN
		PRINT 'PROCEDURE dbo.P_mdb_formpf_GetQ16PrefillValues has NOT been created.'
	END
GO 

