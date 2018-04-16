USE NetikIP
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/*          
==================================================================================================          
Name  :   p_mdb_CPO_GetRatesOfReturns          
Author  : Hmohan   - 12/24/2013          
Description : Get Rates Of Returns from Dashboard of CPOPQR.    
              
===================================================================================================          
Parameters   :          
 Name                |I/O|   Description          
-------------------------------------------------------------------------------    
 @CustID               I     Cust Id                
-------------------------------------------------------------------------------          
Returns  :  Table          
          
Name                Type (length)     Description          
--------------------------------------------------------------------------------          
TMS                  DateTime         DAte Time    
NetROR               Decimal          Rate of Return    
ROR_count            Decimal          Rate of Return     
--------------------------------------------------------------------------------          
          
Usage  :  EXECUTE dbo.p_mdb_CPO_GetRatesOfReturns '1021' , '2'      
       
History:          
      
Name        Date      Description          
---------- ---------- --------------------------------------------------------          
Hmohan    12/24/2013   First Version       
Hmohan    12/26/2013   Update for performance issue, Mark with  --HMohan12262013     
Hmohan    12/27/2013   Commented Code  for Polulating Dates now using Dimension_Date Table  --HMohan12272013     
VBANDI   12/27/2013   Modified as per SME comments --VBANDI 12272013    
Mchawla   01/03/2014   Added modified Date format "ALT_TMS"(as per business) -- Mchawla 01032014    
SChoudhary 01/06/2014  Added Fund name as per the ticket MDB-3077 -- Marked with -- SChoudhary  01062014
SChoudhary 01/15/2014  Modified the SP to work for different Regulatory Reporting applications -- SChoudhary 01152014
========================================================================================================          
*/
ALTER PROCEDURE [dbo].[p_mdb_CPO_GetRatesOfReturns] (@CustID VARCHAR(12), @ProjectID CHAR(1))
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @ErrorMessage NVARCHAR(2048)
	DECLARE @ErrorSeverity INT
	DECLARE @ERRSTATE INT
	DECLARE @ErrorNumber INT;
	-- DECLARE @Year_FirstDay      DATETIME  --HMohan12272013     
	-- DECLARE @LastQuarterEndDate DATETIME  --HMohan12272013     
	DECLARE @PREF_ISSUE_ID_CTXT VARCHAR(5)
	DECLARE @inq_basis_num INT
	DECLARE @Curr_Year INT --HMohan12272013     
	DECLARE @Curr_Qtr INT --HMohan12272013     
	DECLARE @DTMAX AS DATETIME -- Mchawla 01032014    
	DECLARE @DTMIN AS DATETIME -- Mchawla 01032014    
		--These Table holds the data less than 1000 rows always.    
		--Table to store the NetROR (AVG_PE_RATIO) from NAVView    
	DECLARE @RORTable TABLE (
		ROR_ID INT IDENTITY(1, 1) PRIMARY KEY NONCLUSTERED -- SChoudhary  01062014
		,MthEndDt DATETIME --VBANDI 12272013    -- SChoudhary  01062014
		,NetROR FLOAT ---Net Rate of Return --VBANDI 12272013    
		,NetRORCount INT --Count of ROR     --VBANDI 12272013
		,ReportingFundName VARCHAR(max) -- Name of the Fund -- SChoudhary 01062014    
		UNIQUE CLUSTERED (
			ROR_ID
			,MthEndDt
			)
		) -- SChoudhary  01062014
		--Table to hold all months end dates, will have less than 1000 records    
	DECLARE @DateTable TABLE (QtrEndTMS DATETIME PRIMARY KEY CLUSTERED)

	SET @ErrorNumber = 0;
	SET @PREF_ISSUE_ID_CTXT = 'FND'
	SET @inq_basis_num = 5

	BEGIN TRY
		/*========== START ================ FOR POPULATING ALL END DATES FROM YEAR TO LAST QUARTER=======================*/
		SET @Curr_Year = DATEPART(YY, GETDATE()) --HMohan12272013     
		SET @Curr_Qtr = DATEPART(QQ, GETDATE()) --HMohan12272013      

		----- Code Block For First Quarter -- to show result from last year --- --HMohan12272013    
		IF (@Curr_Qtr = 1)
		BEGIN
			SET @Curr_Qtr = 5
			SET @Curr_Year = @Curr_Year - 1
		END

		-----------------End show result for last year---------------    
		--HMohan12272013  Starts    
		-- FIRST DAY OF YEAR            
		--          
		--    SET @Year_FirstDay = DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)             
		--            
		-----Last Day Of Prior Quarter            
		--          
		--    SET @LastQuarterEndDate = Dateadd(ms,-3,Dateadd(qq, Datediff(qq,0,GetDate()), 0))         
		--            
		--SET @LastQuarterEndDate = dateadd(m,1,@LastQuarterEndDate);            
		--WITH AllDates            
		--AS            
		--(            
		--      SELECT cast(cast(year(@Year_FirstDay) AS VARCHAR(4))+'-'+right(100+month(@Year_FirstDay),2)+'-01' AS DATETIME) DateRange            
		--       UNION all            
		--      SELECT dateadd(m,1,DateRange)            
		--        FROM AllDates            
		--       WHERE dateadd(m,1,DateRange)<=dateadd(m,1,@LastQuarterEndDate)            
		--)            
		--INSERT INTO @DateTable            
		--            (QtrEndTMS)            
		--     SELECT dateadd(ss , -1,dateadd( dd,datediff( dd,0,dateadd(d,-1,DateRange)),1)) DateRange            
		--       FROM AllDates     
		--      WHERE dateadd(d,-1,DateRange) between @Year_FirstDay and @LastQuarterEndDate    
		--HMohan12272013  END       
		INSERT INTO @DateTable --HMohan12272013    
			(QtrEndTMS)
		SELECT DATEADD(ss, - 1, DATEADD(dd, 1, End_of_Month_Dt)) QtrEndTMS
		FROM dbo.Dimension_Date -- we need date formate as '2013-01-31 23:59:59.000'    
		WHERE calendar_year = @Curr_Year
			AND Calendar_Quarter < @Curr_Qtr
		GROUP BY End_of_Month_Dt
			/*========== END ================ FOR POPULATING ALL END DATES FROM YEAR TO LAST QUARTER=======================*/
			;

		WITH AvailableFunds (
			Cust_ID
			,SEIFormPFDesc
			,FundID
			,FundAccounts
			,ReportingFundName -- SChoudhary  01062014
			)
		AS (
			SELECT FM.Cust_ID
				,FM.SEIFormPFDesc
				,DM.FundID
				,DM.PortfolioAccountID
				,FM.ReportingFundName -- SChoudhary  01062014
			FROM dbo.FormPFFundMaintenance FM
			LEFT JOIN dbo.FormPFDataMapping DM ON FM.ID = DM.FundID
			WHERE FM.Cust_Id = @CustID
			AND(
				(@ProjectID = 1 and  FM.ISFORMPF =  1) -- SChoudhary 01152014
				or 
				(@ProjectID = 2 and FM.ISCPOPQR = 1) -- SChoudhary 01152014
				or  
				(@ProjectID = 3 and FM.ISAIFMD = 1) -- SChoudhary 01152014
			)
			GROUP BY FM.SEIFormPFDesc
				,FM.Cust_ID
				,DM.FundID
				,DM.PortfolioAccountID
				,FM.ReportingFundName -- SChoudhary  01062014
			)
		--SELECT convert(varchar(11),GP.AS_OF_TMS,101) as TMS,          
		--(SUM(AVG_PE_RATIO) * 100) NetROR,SUM(AVG_PE_RATIO),count(AVG_PE_RATIO) AS ROR_count           
		--from AvailableFunds AF             
		--INNER JOIN NAVView GP ON GP.FUND_ID=AF.FundAccounts             
		--inner join @DateTable DT ON           
		--convert(varchar(11),GP.AS_OF_TMS,101)=convert(varchar(11),DT.QtrEndTMS ,101)            
		--where inq_basis_num = 5 and PREF_ISSUE_ID_CTXT = 'FND'            
		--GROUP BY convert(varchar(11),GP.AS_OF_TMS,101)      
		INSERT INTO @RORTable (
			MthEndDt --VBANDI 12272013    
			,NetROR --VBANDI 12272013    
			,NetRORCount --VBANDI 12272013
			,ReportingFundName -- SChoudhary 01062014    
			)
		SELECT convert(VARCHAR(11), GP.AS_OF_TMS, 101) AS TMS
			,(SUM(AVG_PE_RATIO) * 100) AS NetROR
			,COUNT(AVG_PE_RATIO) AS ROR_count
			,AF.ReportingFundName -- SChoudhary  01062014
		FROM AvailableFunds AF
		INNER JOIN dbo.NAVView GP ON GP.FUND_ID = AF.FundAccounts
		INNER JOIN @DateTable DT ON convert(VARCHAR(11), DT.QtrEndTMS, 101) = convert(VARCHAR(11), GP.AS_OF_TMS, 101) --HMohan12262013                       
		WHERE inq_basis_num = @inq_basis_num
			AND PREF_ISSUE_ID_CTXT = @PREF_ISSUE_ID_CTXT
		GROUP BY convert(VARCHAR(11), GP.AS_OF_TMS, 101)
			,AF.ReportingFundName -- SChoudhary  01062014 

		SELECT @DTMAX = CONVERT(VARCHAR(11), MAX(MTHENDDT), 101)
			,@DTMIN = CONVERT(VARCHAR(11), MIN(MTHENDDT), 101)
		FROM @RORTable -- Mchawla 01032014    

		SELECT CASE 
				WHEN convert(VARCHAR(11), DT.QtrEndTMS, 101) = @dtMax
					THEN RIGHT(CONVERT(VARCHAR(11), DT.QTRENDTMS, 6), 6)
				WHEN convert(VARCHAR(11), DT.QtrEndTMS, 101) = @dtMin
					THEN RIGHT(CONVERT(VARCHAR(11), DT.QTRENDTMS, 6), 6)
				ELSE LEFT(RIGHT(CONVERT(VARCHAR(11), DT.QTRENDTMS, 6), 6), 3)
				END AS ALT_TMS
			,-- Mchawla 01032014      
			convert(VARCHAR(11), DT.QtrEndTMS, 101) AS TMS
			,isnull(RR.NetROR, 0) AS NetROR --VBANDI 12272013    
			,isnull(RR.NetRORCount, 0) AS ROR_count --VBANDI 12272013
			,ReportingFundName AS RFN -- SChoudhary  01062014  
		FROM @DateTable DT
		LEFT JOIN @RORTable RR ON convert(VARCHAR(11), DT.QtrEndTMS, 101) = convert(VARCHAR(11), RR.MthEndDt, 101) --VBANDI 12272013   
		WHERE ReportingFundName IS NOT NULL -- SChoudhary  01062014
	END TRY

	BEGIN CATCH
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ERRSTATE = Error_state()

		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,@ERRSTATE
				)
	END CATCH

	-- Return code    
	RETURN @ErrorNumber
END
GO

-- Validate if procedure has been Altered.
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.ROUTINES
		WHERE SPECIFIC_SCHEMA = N'dbo'
			AND SPECIFIC_NAME = N'p_mdb_CPO_GetRatesOfReturns'
		)
BEGIN
	PRINT 'PROCEDURE dbo.p_mdb_CPO_GetRatesOfReturns has been Altered.';
END;
ELSE
BEGIN
	PRINT 'PROCEDURE dbo.p_mdb_CPO_GetRatesOfReturns has NOT been Altered.'
END;
GO


