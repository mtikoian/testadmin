USE NETIKIP
GO

-- Drop stored procedure if it already exists
IF EXISTS (	SELECT 1 
		    FROM 
				INFORMATION_SCHEMA.ROUTINES 
			WHERE 
				SPECIFIC_SCHEMA = N'dbo'
		    AND 
				SPECIFIC_NAME = N'p_SEI_NTK_FAYEZ_GetPerformance' 
)
BEGIN
     DROP PROCEDURE [dbo].[p_SEI_NTK_FAYEZ_GetPerformance];
     PRINT 'PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformance has been dropped.';
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformance 
(
	-- Add the parameters for the stored procedure here	
    @P_runPeriod VARCHAR(20)	
)
AS
BEGIN /*----Procedure Begin*/
SET NOCOUNT ON
/***
================================================================================
 Name        : dbo.[p_SEI_NTK_FAYEZ_GetPerformance]
 Author      : RZKUMAR
 Description : Get the performance data for FAYEZ according to the time period.
  
Parameters  : 

Name                     |I/O|         	Description
--------------------------------------------------------------------------------
@P_runPeriod				I				Time period to get the data

Procedure is used in the Netik CSAM application.

Returns		:  Table

Name						Type (length)		Description
--------------------------------------------------------------------------------
PORTFOLIO					VARCHAR(25)			Portfolio ID
SECTOR						VARCHAR(200)		Sector
START_DATE					DATETIME			Start date of data         
END_DATE					DATETIME			End date of data
TIME_PERIOD					VARCHAR(200)		Time perid of data
MARKET_VALUE				FLOAT				Market Value  
ACCRUED_INCOME				FLOAT				Accrued Income   
INCOME						FLOAT				Income
POSITIVE_FLOWS				FLOAT				Positive Flow   
NEGATIVE_FLOWS				FLOAT				Negative Flow       
UNIT_VALUE					FLOAT				Unit Value Return       
RATE_OF_RETURN				FLOAT				Rate of Return
 
Revisions    :
--------------------------------------------------------------------------------
 Ini		|   Date   	| Description
--------------------------------------------------------------------------------
RZKUMAR	    07/23/2013  First Version
RZKUMAR	    07/24/2013  Changes for the code review comments   Marked by --07242013
RZKUMAR	    07/25/2013  Changes for the code review comments   Marked by --07252013

================================================================================
Samples: 
EXECUTE dbo.p_SEI_NTK_FAYEZ_GetPerformance 'Previous 3 Months'

***/

DECLARE @D_TMS			DATETIME
DECLARE @D_TME			DATETIME
DECLARE @D_TMP			DATETIME

--07252013
DECLARE @P_WTD					VARCHAR(20)			--Time period Week to Day
DECLARE @P_MTD					VARCHAR(20)			--Time period Month to Day
DECLARE @P_QTD					VARCHAR(20)			--Time period Quarter to Day
DECLARE @P_YTD					VARCHAR(20)			--Time period Year to Day	
DECLARE @P_PreviousMonth		VARCHAR(20)			--Time period Previous Two Month	
DECLARE @P_Previous2Months		VARCHAR(20)			--Time period Previous Three Month
DECLARE @P_Previous3Months		VARCHAR(20)			--Time period Previous Month
DECLARE @P_OneDay				VARCHAR(20)			--Time period One Day
DECLARE @P_PORTFOLIONET			VARCHAR(20)			--PORTFOLIO NET 
DECLARE @P_TotalFundNet			VARCHAR(20)			--Total Fund Net

/*-------------------------Drop temp tables-------------------------------------------*/  --07252013
		IF OBJECT_ID('tempdb..#tblFlows') IS NOT NULL                        
		   DROP TABLE  #tblFlows

		IF OBJECT_ID('tempdb..#tblFlowsFnl') IS NOT NULL                           
			DROP TABLE  #tblFlowsFnl

		IF OBJECT_ID('tempdb..#tblFNLINDEX') IS NOT NULL                        	
			DROP TABLE  #tblFNLINDEX

		IF OBJECT_ID('tempdb..#tblPerfFinal') IS NOT NULL                        	
			DROP TABLE  #tblPerfFinal


--Table to store the portfolio performance data
--Tables holds the data less than 1000 rows					--07242013
DECLARE @tblPerf TABLE       
      ( 
	   Id							int identity(1,1),
	   acct_id						VARCHAR(25),
       key_descr					VARCHAR(200),
       rtn_typ_nme					VARCHAR(200), 
       sector						VARCHAR(200),
       start_dte					DATETIME,       
       end_dte						DATETIME,       
       ending_market_value_book     FLOAT,       
       end_acc_bk					FLOAT,       
       inc_earned					FLOAT,       
       UVR							FLOAT,
	   ROR							FLOAT
PRIMARY KEY (acct_id, key_descr, rtn_typ_nme,sector,Id)		--07252013
       )
--Table to store portfolio performance flow for each date
--07242013
CREATE TABLE #tblFlows       
      (
       Id							int identity(1,1),
       acct_id						VARCHAR(25),
       key_descr					VARCHAR(200),
       rtn_typ_nme					VARCHAR(200), 
       sector						VARCHAR(200),
       start_dte					DATETIME,       
       end_dte						DATETIME,
	   inc_earned					FLOAT, 
       CASH_FLW_BK					FLOAT,       
       POSITIVEFLOWS				FLOAT,       
       NEGATIVEFLOWS				FLOAT 
PRIMARY KEY (acct_id, key_descr, rtn_typ_nme, sector, start_dte, end_dte,Id)		--07252013    
       )
--Table to store portfolio performance flow for all the dates for each sector,account
--07242013
CREATE TABLE #tblFlowsFnl       
      (
	   Id							int identity(1,1),
       acct_id						VARCHAR(25),
       sector						VARCHAR(200),
	   inc_earned					FLOAT, 
       POSITIVEFLOWS				FLOAT,       
       NEGATIVEFLOWS				FLOAT 
PRIMARY KEY (acct_id, sector,Id)		--07252013      
       )
--Table for index level on the prior date
--Tables holds the data less than 1000 rows			--07242013 
DECLARE @tblStartINDEX TABLE       
      ( 
	   Id							int identity(1,1),		
       acct_id						VARCHAR(25),
       key_descr					VARCHAR(200),
       rtn_typ_nme					VARCHAR(200), 
       sector						VARCHAR(200),
       start_dte					DATETIME,       
       end_dte						DATETIME,       
       INDEX_LVL					FLOAT
PRIMARY KEY (acct_id, sector, end_dte,Id)				--07252013
       )
--Table for index level on the end date
--Tables holds the data less than 1000 rows			--07242013
DECLARE @tblEndINDEX TABLE       
      (
	   Id							int identity(1,1),      
       acct_id						VARCHAR(25),
       key_descr					VARCHAR(200),
       rtn_typ_nme					VARCHAR(200), 
       sector						VARCHAR(200),
       start_dte					DATETIME,       
       end_dte						DATETIME,       
       INDEX_LVL					FLOAT 
PRIMARY KEY (acct_id, sector, end_dte,Id)		--07252013 
       )
--Store the final index level, calculated on the basis of start and end index level- for each sector,account 
--07242013
CREATE TABLE #tblFNLINDEX       
      ( 
	   Id							int identity(1,1),         
       acct_id						VARCHAR(25),
	   sector						VARCHAR(200),
       INDEX_LVL					FLOAT 
PRIMARY KEY (acct_id, sector,Id)		--07252013
 
       )
--Table to store result set for performance and benchmark data
--07242013
CREATE TABLE #tblPerfFinal        
      (
	   Id							int identity(1,1),         
       PORTFOLIO					VARCHAR(25),
       SECTOR						VARCHAR(200),
       START_DATE					DATETIME,       
       END_DATE						DATETIME,
	   TIME_PERIOD					VARCHAR(200),
       MARKET_VALUE				    FLOAT,   
	   ACCRUED_INCOME				FLOAT,   
       INCOME						FLOAT,
	   POSITIVE_FLOWS				FLOAT,   
       NEGATIVE_FLOWS				FLOAT,       
       UNIT_VALUE					FLOAT,       
       RATE_OF_RETURN				FLOAT 
PRIMARY KEY (PORTFOLIO, SECTOR, TIME_PERIOD,Id)			--07252013 
       )
--Table for prior date price for each benchmark to calculate the index level
--Tables holds the data less than 1000 rows				--07242013
DECLARE @tblStartPRICE TABLE       
      (
	   Id							int identity(1,1),         
       benchmark_id					VARCHAR(25),
       benchmark_name				VARCHAR(200),
       date							DATETIME, 
       price						FLOAT
PRIMARY KEY (benchmark_id, date,Id)				--07252013 
       )
--Table for end date price for each benchmark to calculate the index level
--Tables holds the data less than 1000 rows		--07242013 
DECLARE @tblEndPRICE TABLE       
      (
	    Id							int identity(1,1),         
		benchmark_id				VARCHAR(25),
		benchmark_name				VARCHAR(200),
		date						DATETIME, 
		price						FLOAT 
PRIMARY KEY (benchmark_id, date,Id)				--07252013  
       )
--Store the final price calculated on prior date price and end date price
--Tables holds the data less than 1000 rows		--07242013 
DECLARE @tblFNLPRICE TABLE       
      (  
	    Id							int identity(1,1),         
		benchmark_id				VARCHAR(25),
		benchmark_name				VARCHAR(200),
		StartDate					DATETIME,
		EndDate						DATETIME,  
		price						FLOAT
PRIMARY KEY (benchmark_id,Id)						--07252013
       )

BEGIN TRY

--07252013
SET @P_WTD	= 'WTD'
SET @P_MTD	= 'MTD'
SET @P_QTD	= 'QTD'
SET @P_YTD	= 'YTD'
SET @P_PreviousMonth	= 'Previous Month'
SET @P_Previous2Months	= 'Previous 2 Months'
SET @P_Previous3Months	= 'Previous 3 Months'
SET @P_OneDay			= 'One Day'
SET	@P_PORTFOLIONET		= 'PORTFOLIO NET'
SET @P_TotalFundNet		= 'Total Fund Net'


--Set the prior date according to the time period 
SET @D_TMP = CASE WHEN @P_runPeriod=@P_WTD THEN CONVERT(VARCHAR(10), DATEADD(dd, ((DATEDIFF(dd, '19000105',DATEADD(D, -7, getdate()) + 7) - 1) / 7) * 7, '19000105'),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_MTD THEN CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(m,DATEDIFF(m,0,getdate()),0)),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_QTD THEN CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(qq,DATEDIFF(qq,0,getdate()),0)),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_YTD THEN CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)),121) + ' 23:59:59:000'
 					WHEN @P_runPeriod=@P_PreviousMonth THEN CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(month, DATEDIFF(month, 0, getdate())-1, 0)), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_Previous2Months THEN CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(month, DATEDIFF(month, 0, getdate())-2, 0)), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_Previous3Months THEN CONVERT(VARCHAR(10), DATEADD(D, -1, DATEADD(month, DATEDIFF(month, 0, getdate())-3, 0)), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_OneDay THEN CONVERT(VARCHAR(10),DATEADD(D, -2, getdate()),121) + ' 23:59:59:000'
			END
--Set the start date according to the time period
SET @D_TMS = CASE WHEN @P_runPeriod=@P_WTD THEN CONVERT(VARCHAR(10),DATEADD(dd,1,DATEADD(dd, ((DATEDIFF(dd, '19000105',DATEADD(D, -7, getdate()) + 7) - 1) / 7) * 7, '19000105')),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_MTD THEN CONVERT(VARCHAR(10), DATEADD(m,DATEDIFF(m,0,getdate()),0),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_QTD THEN CONVERT(VARCHAR(10), DATEADD(qq,DATEDIFF(qq,0,getdate()),0),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_YTD THEN CONVERT(VARCHAR(10), DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0),121) + ' 23:59:59:000'
 					WHEN @P_runPeriod=@P_PreviousMonth THEN CONVERT(VARCHAR(10), DATEADD(month, DATEDIFF(month, 0, getdate())-1, 0), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_Previous2Months THEN CONVERT(VARCHAR(10), DATEADD(month, DATEDIFF(month, 0, getdate())-2, 0), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_Previous3Months THEN CONVERT(VARCHAR(10), DATEADD(month, DATEDIFF(month, 0, getdate())-3, 0), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_OneDay THEN CONVERT(VARCHAR(10), DATEADD(dd,-1,getdate()),121) + ' 23:59:59:000'
			END
--Set the end date according to the time period
SET @D_TME = CASE WHEN @P_runPeriod=@P_WTD THEN CONVERT(VARCHAR(10), DATEADD(dd,-1,getdate()),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_MTD THEN CONVERT(VARCHAR(10), DATEADD(dd,-1,getdate()),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_QTD THEN CONVERT(VARCHAR(10), DATEADD(dd,-1,getdate()),121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_YTD THEN CONVERT(VARCHAR(10), DATEADD(dd,-1,getdate()),121) + ' 23:59:59:000'
 					WHEN @P_runPeriod=@P_PreviousMonth THEN CONVERT(VARCHAR(10),	DATEADD(MONTH, DATEDIFF(MONTH, -1, getdate())-1, -1), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_Previous2Months THEN CONVERT(VARCHAR(10),	DATEADD(MONTH, DATEDIFF(MONTH, -1, getdate())-2, -1), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_Previous3Months THEN CONVERT(VARCHAR(10),	DATEADD(MONTH, DATEDIFF(MONTH, -1, getdate())-3, -1), 121) + ' 23:59:59:000'
					WHEN @P_runPeriod=@P_OneDay THEN CONVERT(VARCHAR(10), DATEADD(dd,-1,getdate()),121) + ' 23:59:59:000'
			END

INSERT INTO @tblPerf       
  (       
   acct_id,
   key_descr,
   rtn_typ_nme, 
   sector,
   start_dte,       
   end_dte,       
   ending_market_value_book ,       
   end_acc_bk,       
   inc_earned,       
   UVR,
   ROR   
   )
SELECT
	acct_id ,
	KEY_DESCR,
	RTN_TYP_NME,
	CASE WHEN RTN_TYP_NME = @P_PORTFOLIONET THEN @P_TotalFundNet 
		ELSE KEY_DESCR END  AS 'SECTOR' ,
	START_DTE,	
	END_DTE,
	ending_market_value_book,	
	end_acc_bk,
	inc_earned,
	CASE	WHEN @P_runPeriod=@P_MTD		THEN  (MTD/100)+1
			WHEN @P_runPeriod=@P_QTD		THEN  (QTD/100)+1
			WHEN @P_runPeriod=@P_YTD		THEN  (YTD/100)+1
			WHEN @P_runPeriod=@P_OneDay	THEN  (ONE_DAY/100)+1
			ELSE 0 END,
	CASE	WHEN @P_runPeriod=@P_MTD		THEN  MTD
			WHEN @P_runPeriod=@P_QTD		THEN  QTD
			WHEN @P_runPeriod=@P_YTD		THEN  YTD
			WHEN @P_runPeriod=@P_OneDay	THEN  ONE_DAY
			ELSE 0 END
FROM dbo.PORTFOLIO_PERFORMANCE 
WHERE END_DTE = @D_TME
ORDER BY acct_id

INSERT INTO #tblFlows			--07242013       
	  (       
	   acct_id,
	   key_descr,
	   rtn_typ_nme, 
	   sector,
	   start_dte,       
	   end_dte,
	   inc_earned,       
	   CASH_FLW_BK,       
	   POSITIVEFLOWS,       
	   NEGATIVEFLOWS      
	   )
SELECT 
	ACCT_ID,
	KEY_DESCR,
	RTN_TYP_NME,
	CASE WHEN RTN_TYP_NME = @P_PORTFOLIONET THEN @P_TotalFundNet ELSE KEY_DESCR END  AS 'SECTOR',
	START_DTE ,	
	END_DTE ,
	inc_earned,
	CASH_FLW_BK,
	CASE WHEN CASH_FLW_BK > 0 THEN CASH_FLW_BK ELSE 0 END  AS 'POSITIVEFLOWS',       
	CASE WHEN CASH_FLW_BK < 0 THEN CASH_FLW_BK ELSE 0 END AS 'NEGATIVEFLOWS' 
FROM dbo.PORTFOLIO_PERFORMANCE 
WHERE END_DTE >=  @D_TMS and  END_DTE <= @D_TME
ORDER BY ACCT_ID

INSERT INTO #tblFlowsFnl		--07242013       
	  (       
	   acct_id,
	   sector,
	   inc_earned,
	   POSITIVEFLOWS,       
	   NEGATIVEFLOWS      
	   )
SELECT 
	ACCT_ID, 
	SECTOR,
	SUM(inc_earned) AS	'inc_earned',  
	SUM(POSITIVEFLOWS) AS 'POSITIVEFLOWS', 
	SUM(NEGATIVEFLOWS) AS 'NEGATIVEFLOWS'
FROM #tblFlows				--07242013
GROUP BY ACCT_ID,SECTOR
ORDER BY ACCT_ID

IF (@P_runPeriod<>@P_OneDay AND @P_runPeriod<>@P_MTD AND @P_runPeriod<>@P_QTD AND @P_runPeriod<>@P_YTD)
BEGIN
INSERT INTO @tblStartINDEX       
	  (       
	   acct_id,
	   key_descr,
	   rtn_typ_nme, 
	   sector,
	   start_dte,       
	   end_dte,       
	   INDEX_LVL  
	   )
SELECT 
	ACCT_ID,
	KEY_DESCR,
	RTN_TYP_NME,
	CASE WHEN RTN_TYP_NME = @P_PORTFOLIONET THEN @P_TotalFundNet ELSE KEY_DESCR END  AS 'SECTOR',
	START_DTE,
	END_DTE,
	INDEX_LVL
FROM dbo.PORTFOLIO_PERFORMANCE
WHERE end_dte =@D_TMP
ORDER BY ACCT_ID

INSERT INTO @tblEndINDEX        
	  (       
	   acct_id,
	   key_descr,
	   rtn_typ_nme, 
	   sector,
	   start_dte,       
	   end_dte,       
	   INDEX_LVL  
	   )
SELECT 
	ACCT_ID,
	KEY_DESCR,
	RTN_TYP_NME,
	CASE WHEN RTN_TYP_NME = @P_PORTFOLIONET THEN @P_TotalFundNet ELSE KEY_DESCR END  AS 'SECTOR',
	START_DTE,
	END_DTE,
	INDEX_LVL
FROM dbo.PORTFOLIO_PERFORMANCE
WHERE end_dte =@D_TME
ORDER BY ACCT_ID

INSERT INTO #tblFNLINDEX       
	  (       
	   acct_id,
	   sector,
	   INDEX_LVL  
	   )
SELECT 
	sd.ACCT_ID, 
	sd.SECTOR, 
	CASE WHEN (ed.INDEX_LVL IS NULL OR sd.INDEX_LVL IS NULL) THEN 0
		ELSE ((ed.INDEX_LVL/CASE WHEN sd.INDEX_LVL = 0 THEN 1 ELSE sd.INDEX_LVL END ) - 1) * 100 END AS INDEX_LVL 
FROM @tblStartINDEX sd
INNER JOIN @tblEndINDEX ed ON sd.acct_id = ed.acct_id and sd.sector = ed.sector
ORDER BY sd.acct_id

INSERT INTO @tblStartPRICE       
	  (       
		benchmark_id,
		benchmark_name,
		date, 
		price 
	   )
SELECT       
	 BENCHMARK_ID ,      
	 BENCHMARK_NAME ,      
	 DATE ,      
	 PRICE
   FROM DBO.PORTFOLIO_BENCHMARK WHERE     
   BENCHMARK_ID IN ('BM_SP500_G','BM_RUS1000G_G','BM_MSCWORLD_N','BM_BARUSGOVCREDBD_T','BM_BARUSAGGBD_T')     
   AND DATE = @D_TMP

INSERT INTO @tblENDPRICE       
	  (       
		benchmark_id,
		benchmark_name,
		date, 
		price 
	   )
SELECT       
	 BENCHMARK_ID ,      
	 BENCHMARK_NAME ,      
	 DATE,      
	 PRICE
   FROM DBO.PORTFOLIO_BENCHMARK WHERE     
   BENCHMARK_ID IN ('BM_SP500_G','BM_RUS1000G_G','BM_MSCWORLD_N','BM_BARUSGOVCREDBD_T','BM_BARUSAGGBD_T')     
   AND DATE = @D_TME

INSERT INTO @tblFNLPRICE       
	  (       
		benchmark_id,
		benchmark_name,
		StartDate, 
		EndDate,
		price 
	   )
SELECT       
	 sp.BENCHMARK_ID,      
	 sp.BENCHMARK_NAME,      
	 sp.DATE,
	 ep.DATE,      
	 CASE WHEN (ep.PRICE IS NULL OR sp.PRICE IS NULL) THEN 0
		ELSE ((ep.PRICE/CASE WHEN sp.PRICE = 0 THEN 1 ELSE sp.PRICE END ) - 1) * 100 END AS PRICE 
   FROM @tblStartPRICE sp 
   INNER JOIN @tblENDPRICE ep
   ON sp.BENCHMARK_ID=ep.BENCHMARK_ID AND sp.BENCHMARK_NAME=ep.BENCHMARK_NAME

INSERT INTO #tblPerfFinal			--07242013     
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
SELECT 
	per.acct_id,
	per.sector,
	@D_TMS,       
	@D_TME,
	@P_runPeriod,       
	ending_market_value_book,       
	end_acc_bk,       
	flw.inc_earned,       
	flw.POSITIVEFLOWS,
	flw.NEGATIVEFLOWS,
	(indxFnl.INDEX_LVL/100)+1,
	indxFnl.INDEX_LVL
FROM @tblPerf per
INNER JOIN  #tblFlowsFnl flw				--07242013
ON per.acct_id=flw.acct_id and  per.sector=flw.sector
LEFT OUTER JOIN #tblFNLINDEX indxFnl		--07242013
ON per.acct_id=indxFnl.acct_id and per.sector=indxFnl.sector

INNER JOIN dbo.ACCOUNTS_CLASSIFICATION_SEI accCL
ON per.acct_id=accCL.acct_id
WHERE SUBSTRING(per.acct_id ,1 ,4) IN ('1193','1260','1272')
AND accCL.ud_txt10 = '1'

ORDER BY per.acct_id, per.sector

INSERT INTO #tblPerfFinal			--07242013       
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
SELECT
		ben.BENCHMARK_ID,      
		ben.BENCHMARK_NAME,      
		@D_TMS,
		@D_TME,
		@P_runPeriod,   
		NULL,      
		NULL,      
		NULL,      
		NULL,       
		NULL,       
		(fp.Price/100)+1,
		fp.Price      
FROM dbo.PORTFOLIO_BENCHMARK ben 
LEFT OUTER JOIN @tblFNLPRICE fp ON ben.BENCHMARK_ID=fp.BENCHMARK_ID AND ben.BENCHMARK_NAME=fp.BENCHMARK_NAME 
WHERE  ben.BENCHMARK_ID IN ('BM_SP500_G','BM_RUS1000G_G','BM_MSCWORLD_N','BM_BARUSGOVCREDBD_T','BM_BARUSAGGBD_T') AND ben.Date = @D_TME

END
ELSE
BEGIN

INSERT INTO #tblPerfFinal			--07242013      
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
SELECT 
	per.acct_id,
	per.sector,
	@D_TMS,       
	@D_TME,
	@P_runPeriod,       
	ending_market_value_book,       
	end_acc_bk,       
	flw.inc_earned,       
	flw.POSITIVEFLOWS,
	flw.NEGATIVEFLOWS,
	per.UVR,
	per.ROR
FROM @tblPerf per
INNER JOIN  #tblFlowsFnl flw			--07242013
ON per.acct_id=flw.acct_id and  per.sector=flw.sector

INNER JOIN dbo.ACCOUNTS_CLASSIFICATION_SEI accCL
ON per.acct_id = accCL.acct_id
WHERE SUBSTRING(per.acct_id ,1 ,4) IN ('1193','1260','1272')
AND accCL.ud_txt10 = '1'

ORDER BY per.acct_id, per.sector

INSERT INTO #tblPerfFinal			--07242013      
	  (       
	   PORTFOLIO,
	   sector,
	   START_DATE,       
	   END_DATE,
	   TIME_PERIOD,
	   MARKET_VALUE,   
	   ACCRUED_INCOME,   
	   INCOME,
	   POSITIVE_FLOWS,   
	   NEGATIVE_FLOWS,       
	   UNIT_VALUE,       
	   RATE_OF_RETURN       
	   )
SELECT
		ben.BENCHMARK_ID,      
		ben.BENCHMARK_NAME,      
		@D_TMS,
		@D_TME,
		@P_runPeriod,   
		NULL,      
		NULL,      
		NULL,      
		NULL,       
		NULL,       
		CASE	WHEN @P_runPeriod = @P_MTD		THEN  (MTD/100)+1
				WHEN @P_runPeriod = @P_QTD		THEN  (QTD/100)+1
				WHEN @P_runPeriod = @P_YTD		THEN  (YTD/100)+1
				WHEN @P_runPeriod = @P_OneDay	THEN  (ONE_DAY/100)+1
				ELSE 0 END ,
		CASE	WHEN @P_runPeriod = @P_MTD		THEN  MTD
				WHEN @P_runPeriod = @P_QTD		THEN  QTD
				WHEN @P_runPeriod = @P_YTD		THEN  YTD
				WHEN @P_runPeriod = @P_OneDay		THEN  ONE_DAY
				ELSE 0 END      
FROM dbo.PORTFOLIO_BENCHMARK ben 
WHERE  ben.BENCHMARK_ID IN ('BM_SP500_G','BM_RUS1000G_G','BM_MSCWORLD_N','BM_BARUSGOVCREDBD_T','BM_BARUSAGGBD_T') AND ben.Date = @D_TME

END

SELECT PORTFOLIO,
       SECTOR,
       START_DATE,       
       END_DATE,
	   TIME_PERIOD,
		ROUND(CAST (MARKET_VALUE AS DECIMAL(18,2)),2) AS MARKET_VALUE,
		ROUND(CAST (ACCRUED_INCOME AS DECIMAL(18,2)),2) AS ACCRUED_INCOME,
		ROUND(CAST (INCOME AS DECIMAL(18,2)),2) AS INCOME,
		ROUND(CAST (POSITIVE_FLOWS AS DECIMAL(18,2)),2) AS POSITIVE_FLOWS,
		ROUND(CAST (NEGATIVE_FLOWS AS DECIMAL(18,2)),2) AS NEGATIVE_FLOWS,
       ROUND(CAST (UNIT_VALUE AS DECIMAL(18,5)),5) AS UNIT_VALUE, 
       ROUND(CAST (RATE_OF_RETURN AS DECIMAL(18,5)),5) AS RATE_OF_RETURN

FROM #tblPerfFinal			--07242013 
ORDER BY PORTFOLIO, TIME_PERIOD, sector

DROP TABLE #tblFlows				--07242013
DROP TABLE #tblFlowsFnl
DROP TABLE #tblFNLINDEX 
DROP TABLE #tblPerfFinal 

END TRY 

BEGIN CATCH 
    DECLARE @errno    INT, 
            @errmsg   VARCHAR(2100), 
            @errsev   INT, 
            @errstate INT; 

    SET @errno = Error_number() 
    SET @errmsg = 'Error in dbo.p_SEI_NTK_FAYEZ_GetPerformance: ' 
                     + Error_message() 
    SET @errsev = Error_severity() 
    SET @errstate = Error_state(); 

    RAISERROR(@errmsg,@errsev,1); 
END CATCH


/*-------------------------Drop temp tables-------------------------------------------*/		--07252013
		IF OBJECT_ID('tempdb..#tblFlows') IS NOT NULL                        
		   DROP TABLE  #tblFlows

		IF OBJECT_ID('tempdb..#tblFlowsFnl') IS NOT NULL                           
			DROP TABLE  #tblFlowsFnl

		IF OBJECT_ID('tempdb..#tblFNLINDEX') IS NOT NULL                        	
			DROP TABLE  #tblFNLINDEX

		IF OBJECT_ID('tempdb..#tblPerfFinal') IS NOT NULL                        	
			DROP TABLE  #tblPerfFinal

END;/*----Procedure End*/
GO

-- Validate if procedure has been created.
IF EXISTS (	SELECT 1 
		    FROM 
				INFORMATION_SCHEMA.ROUTINES 
			WHERE 
				SPECIFIC_SCHEMA = N'dbo'
		    AND 
				SPECIFIC_NAME = N'p_SEI_NTK_FAYEZ_GetPerformance' 
)
BEGIN
     PRINT 'PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformance has been created.';
END;
ELSE
BEGIN
    PRINT 'PROCEDURE dbo.p_SEI_NTK_FAYEZ_GetPerformance has NOT been created.'
END;
GO

GRANT EXECUTE ON dbo.p_SEI_NTK_FAYEZ_GetPerformance TO netikapp_user
GO 
