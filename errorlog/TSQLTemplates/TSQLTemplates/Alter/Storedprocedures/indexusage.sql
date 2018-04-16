USE NetikIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

IF  EXISTS 
	(
		SELECT 1 
		FROM   information_schema.routines 
		WHERE  routine_type = 'PROCEDURE' 
			   AND routine_schema = 'dbo' 
			   AND routine_name = 'p_SEI_NTK_ProjectedIncomeReportExport'  
	)
	BEGIN
		DROP PROCEDURE dbo.p_SEI_NTK_ProjectedIncomeReportExport
		PRINT 'PROCEDURE dbo.p_SEI_NTK_ProjectedIncomeReportExport has been dropped.'
	END
GO 


/*          
==================================================================================================          
Name        : p_SEI_NTK_ProjectedIncomeReportExport         
Author      : NBhatia   
Date        : 07/29/2013          
Description : Fetching the projected income report data for export to CSV               
===================================================================================================          
Parameters   :          
Name              |I/O|   Description      
---------------------------------------------------------------------------------------------------          
@START_DATE		    I     START DATE
@END_DATE		    I     END DATE    
@ACCT_ID		    I     ACCOUNT ID         
---------------------------------------------------------------------------------------------------      
Returns  :  Table          
          
Name			Type (length)    Description          
---------------------------------------------------------------------------------------------------      
id				INT				Row ID
Curr_Date		NVARCHAR(15)    Currrent Date
local_curr_cde  NVARCHAR(15)    Local Currency Code
trn_desc		NVARCHAR(50)    Transaction Decription
amnt			DECIMAL(18,2)   Amount
beg_balance		DECIMAL(18,2)   Begining Balance
as_of_tms		DATETIME        As of Date
netcash			DECIMAL(18,2)   Net Cash
endbalance		DECIMAL(18,2)   End Balance
sortorder		INT	            Sort Order
  
---------------------------------------------------------------------------------------------------      
       
Usage  : EXECUTE dbo.p_SEI_NTK_ProjectedIncomeReportExport '2012-11-14','2012-11-24','1083-3-00588' 
		 EXECUTE dbo.p_SEI_NTK_ProjectedIncomeReportExport '2012-11-11','2012-11-24','1083-3-00588' 
		 EXECUTE dbo.p_SEI_NTK_ProjectedIncomeReportExport_bckup '2012-11-11','2012-11-24','1083-3-00588' 
         EXECUTE dbo.p_SEI_NTK_ProjectedIncomeReportExport '2012-11-11 23:59:59.000','2012-11-28 23:59:59.000','1061-3-10001'       

History:                    
Name      Date         Description          
----------------------------------------------------------------------------------------------------          
NBhatia   07/29/2013   Initial Version          
====================================================================================================          
*/						
CREATE PROCEDURE dbo.p_SEI_NTK_ProjectedIncomeReportExport   
		(        
			@START_DATE	DATETIME, 
			@END_DATE	DATETIME,    	
			@ACCT_ID	VARCHAR(15)      
		)           
AS
BEGIN           
    
    SET NOCOUNT ON           
    SET FMTONLY OFF     

	--DECLARE  @END_DATE	       DATETIME
	DECLARE  @ldgr_id		       CHAR(4)
	DECLARE  @inq_basis_num        INT
	DECLARE  @endbalance0	       INT
	DECLARE  @StartDatetmstmp      DATETIME
	DECLARE  @EndDatetmstmp		   DATETIME
	DECLARE  @MaxAdjst_tms		   DATETIME
	DECLARE  @Sum_prcd_cmb_amt     INT				
	DECLARE  @lev3_hier_Purchase   VARCHAR(9)
	DECLARE  @lev3_hier_Sales      VARCHAR(5)
	DECLARE  @lev3_hier_Income     VARCHAR(6)	
	DECLARE  @No_of_days           INT
    DECLARE  @errno				   INT           
    DECLARE  @errmsg			   NVARCHAR(2100)           
    DECLARE  @errsev			   INT           
    DECLARE  @errstate			   INT 
    DECLARE  @Max_No_of_days       INT 
    DECLARE  @Datetmstmp           DATETIME 

	-- Check whether the temp table Exists
	IF OBJECT_ID('tempdb..#InitTranDet') IS NOT NULL                 
			DROP TABLE #InitTranDet 
	IF OBJECT_ID('tempdb..#Netcash') IS NOT NULL                 
			DROP TABLE #Netcash 
	IF OBJECT_ID('tempdb..#TranDetails') IS NOT NULL                 
			DROP TABLE #TranDetails 
	IF OBJECT_ID('tempdb..#DuplRows') IS NOT NULL                 
			DROP TABLE #DuplRows
	IF OBJECT_ID('tempdb..#min_ids') IS NOT NULL                 
			DROP TABLE #min_ids
	IF OBJECT_ID('tempdb..#DistinctTranDetails') IS NOT NULL                 
			DROP TABLE #DistinctTranDetails
	IF OBJECT_ID('tempdb..#FinalDisplayTranDetails') IS NOT NULL                 
			DROP TABLE #FinalDisplayTranDetails
	IF OBJECT_ID('tempdb..#Max_Last_Bal') IS NOT NULL                 
			DROP TABLE #Max_Last_Bal
	IF OBJECT_ID('tempdb..#Max_id_local_curr_cde') IS NOT NULL                 
			DROP TABLE #Max_id_local_curr_cde
	IF OBJECT_ID('tempdb..#min_id_vals') IS NOT NULL                 
			DROP TABLE #min_id_vals

	-- Temp table to get the Initial Transaction determined
	CREATE TABLE #InitTranDet
	(
		id				INT IDENTITY(1,1),
		Curr_Date		VARCHAR(10),
		local_curr_cde  NVARCHAR(15),
		trn_desc	    NVARCHAR(20),           
		amnt			DECIMAL(18,2),
		beg_balance		DECIMAL(18,2),
		as_of_tms		DATETIME,	
		endbalance		DECIMAL(18,2),
		PRIMARY KEY    (id,Curr_Date,local_curr_cde) 
	)
--	CREATE INDEX IX_InitTranDet ON #InitTranDet (Curr_Date,local_curr_cde) INCLUDE(ID)


	-- Temp table to get the Net Cash Transacted
	CREATE TABLE #Netcash
	(
		id			    INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
		Curr_Date		VARCHAR(10),
		local_curr_cde	NVARCHAR(15),
		netcash			DECIMAL(18,2)
	)
	CREATE INDEX IX_Netcash ON #Netcash (Curr_Date,local_curr_cde) INCLUDE(ID)

-- Temp table to get the Net Cash Transacted
	CREATE TABLE #TranDetails
	(
		id				INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
		Curr_Date		VARCHAR(10),
		local_curr_cde	NVARCHAR(15),
		trn_desc	    NVARCHAR(50),              
		amnt			DECIMAL(18,2),
		beg_balance		DECIMAL(18,2),
		as_of_tms		DATETIME,
		netcash			DECIMAL(18,2),
		endbalance		DECIMAL(18,2),
		sortorder		INT
	)
	CREATE INDEX IX_TranDetails ON #TranDetails (Curr_Date,local_curr_cde) INCLUDE(ID)
	
-- Temp table to get the Duplicated rows of Transaction
	CREATE TABLE #DuplRows
	(
      --id_dup              INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,    
        id                  INT PRIMARY KEY CLUSTERED,    
		Curr_Date	        VARCHAR(10),
		local_curr_cde      NVARCHAR(15),
		beg_balance         DECIMAL(18,2),
		netcash             DECIMAL(18,2),  
		endbalance	        DECIMAL(18,2)
	)
	

-- Temp table to get the Minimum ID on the Transacted Date
	CREATE TABLE #min_ids
	(
      --id_minids       INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,    
        id				INT PRIMARY KEY CLUSTERED,    
		Curr_Date		VARCHAR(10),
		local_curr_cde	NVARCHAR(15),
		beg_balance     DECIMAL(18,2),
		netcash			DECIMAL(18,2),
		endbalance		DECIMAL(18,2)
	)

-- Temp table to get the distinct transactions done on the Current date
	CREATE TABLE #DistinctTranDetails
	(
		id		       INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
		Curr_Date      VARCHAR(10),
		local_curr_cde NVARCHAR(15),
		trn_desc       NVARCHAR(50),                
		amnt		   DECIMAL(18,2),
		beg_balance	   DECIMAL(18,2),
		as_of_tms	   DATETIME,
		netcash		   DECIMAL(18,2),
		endbalance	   DECIMAL(18,2),
		sortorder	   INT
	)
	CREATE INDEX IX_DistinctTranDetails  ON #DistinctTranDetails (Curr_Date,local_curr_cde) INCLUDE(ID)
	

-- Temp table to get the Final Display details of transactions done
	CREATE TABLE #FinalDisplayTranDetails
	(
		id				INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
		Curr_Date		VARCHAR(10),
		local_curr_cde  NVARCHAR(15),
		trn_desc        NVARCHAR(50),               
		amnt			DECIMAL(18,2),
		beg_balance		DECIMAL(18,2),
		as_of_tms		DATETIME,
		netcash			DECIMAL(18,2),
		endbalance		DECIMAL(18,2),
		sortorder		INT
	) 
	CREATE INDEX IX_FinalDisplayTranDetails ON #FinalDisplayTranDetails (Curr_Date,local_curr_cde) INCLUDE(ID)

-- Temp table to get the Max Last Balance based on the ID
	CREATE TABLE #Max_Last_Bal
	(
    --  id_MaxLBal      INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,    
        id              INT PRIMARY KEY CLUSTERED,    
		Max_Last_Bal    DECIMAL(18,2),
		local_curr_cde  NVARCHAR(15)
	)

-- Temp table to get the Max ID based on the Currency Code
	CREATE TABLE #Max_id_local_curr_cde
	(
        --id_LocCrBal   INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,    
        id              INT PRIMARY KEY CLUSTERED,    
		local_curr_cde  NVARCHAR(15)
	)

-- Temp table to get the min ID details of transactions done
	CREATE TABLE #min_id_vals
	(
		id				INT IDENTITY(1,1) PRIMARY KEY NONCLUSTERED,
		Curr_Date		VARCHAR(10),
		local_curr_cde  NVARCHAR(15),
		trn_desc        NVARCHAR(50),             
		amnt			DECIMAL(18,2),
		beg_balance		DECIMAL(18,2),
		as_of_tms		DATETIME,
		netcash			DECIMAL(18,2),
		endbalance		DECIMAL(18,2),
		sortorder		INT		
	)
   CREATE INDEX IX_min_id_vals ON #min_id_vals (Curr_Date,local_curr_cde) INCLUDE(ID)

BEGIN TRY    
	
	--SET @END_DATE      = @START_DATE+7  
	 SET @Max_No_of_days = 31  
	 SET @No_of_days =  DATEDIFF(D,@Start_date,@End_date)  
	   
	 If (@No_of_days>@Max_No_of_days)  
	 BEGIN  
		 Set @End_date = @Start_date+@Max_No_of_days    
		 Set @No_of_days = @Max_No_of_days    
	 END  

	SET @ldgr_id       = 9998
	SET @inq_basis_num = 1
	SET @endbalance0   = 0

	SET @StartDatetmstmp    = DATEADD(DD, DATEDIFF(D,0,@Start_Date),0)
	SET @EndDatetmstmp      = DATEADD(DD, DATEDIFF(D,0,@End_Date)+1,0)
    SET @Datetmstmp         = DATEADD(DD, DATEDIFF(D,0,@StartDatetmstmp-1),0)
 	SET @Sum_prcd_cmb_amt   = 0				 
	SET @lev3_hier_Purchase = 'Purchases'
	SET @lev3_hier_Sales    = 'Sales'
	SET @lev3_hier_Income   = 'Income' 

	SELECT @MaxAdjst_tms = MAX(adjst_tms) 
	FROM dbo.positionview 
	WHERE acct_id       = @Acct_ID
	  AND inq_basis_num = @inq_basis_num
      AND DATEADD(DD, DATEDIFF(D,0,as_of_tms),0) = @Datetmstmp   

	--  Inserting all the Initial transaction Details in the Specified Period
	INSERT INTO #InitTranDet 
            (Curr_Date, 
             local_curr_cde, 
             trn_desc,                        
             amnt, 
             beg_balance, 
             as_of_tms, 
             endbalance) 
	SELECT Curr_Date,
		   --CONVERT(VARCHAR(10), Curr_Date, 101)      AS Curr_Date, 
		   td.local_curr_cde, 
		   td1.trn_desc,                      
		   td1.amnt, 
		   ISNULL(tbl_beg_balance.beg_balance, 0) AS beg_balance, 
		   tbl_beg_balance.as_of_tms, 
		   @endbalance0 
	--FROM   dbo.fn_NTK_Projincome_currdate(@START_DATE,@No_of_days) AS tbldates 
	FROM
	(
		SELECT DISTINCT Date_Format_mm_dd_yyyy	 as Curr_Date			
		FROM dbo.Dimension_Date DDt
		WHERE 
			DDt.Dimension_Dt between @START_DATE and DATEADD(dd, @No_of_days, @START_DATE)
			
	)tbldates
		   CROSS JOIN (SELECT DISTINCT local_curr_cde 
					   FROM   dbo.traneventview 
					   WHERE  acct_id = @Acct_ID 
							  AND inq_basis_num = @inq_basis_num 
							  AND cntrct_pay_tms BETWEEN 
								  @StartDatetmstmp AND @EndDatetmstmp 
					   GROUP  BY local_curr_cde, 
								 cntrct_pay_tms, 
								 trn_desc                                     	
					   HAVING SUM(prcd_cmb_amt) <> @Sum_prcd_cmb_amt) AS td   		
		   LEFT OUTER JOIN (SELECT local_curr_cde, 
								   trn_desc,                                  	
								   cntrct_pay_tms, 
								   SUM(prcd_cmb_amt) AS amnt			
							FROM   dbo.traneventview 
							WHERE  acct_id = @Acct_ID 
								   AND inq_basis_num = @inq_basis_num 
								   AND cntrct_pay_tms BETWEEN 
									   @StartDatetmstmp AND @EndDatetmstmp 
							GROUP  BY local_curr_cde, 
									  cntrct_pay_tms, 
									  trn_desc                              
							HAVING SUM(prcd_cmb_amt) <> @Sum_prcd_cmb_amt)	  	
						   AS td1 
						ON td.local_curr_cde = td1.local_curr_cde 
						   AND tbldates.Curr_Date = 
							   CONVERT(VARCHAR(10), td1.cntrct_pay_tms, 101) 
		   LEFT OUTER JOIN (SELECT local_curr_cde, 
								   adjst_tms, 
								   SUM(valval_alt_cmb_amt) AS beg_balance, 
								   as_of_tms 
							FROM   dbo.positionview 
							WHERE  acct_id = @Acct_ID 
								   AND inq_basis_num = @inq_basis_num             
								   AND DATEADD(DD, DATEDIFF(D,0,as_of_tms),0) = @Datetmstmp
								   AND ldgr_id = @ldgr_id 
								   AND adjst_tms = @MaxAdjst_tms 
							GROUP  BY acct_id, 
									  local_curr_cde, 
									  adjst_tms, 
									  as_of_tms)AS tbl_beg_balance 
						ON td.local_curr_cde = tbl_beg_balance.local_curr_cde 
						   AND tbldates.Curr_Date = CONVERT(VARCHAR(10),CAST(tbl_beg_balance.as_of_tms AS DATETIME)+ 1, 101) 
						ORDER  BY td.local_curr_cde, 
								  tbldates.curr_date, 
								  td1.trn_desc                          						


	--  Inserting all the Net Cash Details in the Specified Period
	INSERT INTO #Netcash
	(
		Curr_Date,
		local_curr_cde,
		netcash
	)
	SELECT CONVERT(VARCHAR(10),CAST(curr_date AS DATETIME),101) AS curr_date,
		   local_curr_cde,
		   SUM(ISNULL(amnt,0)) AS netcash 
	FROM #InitTranDet
	GROUP BY local_curr_cde,CONVERT(VARCHAR(10),CAST(curr_date AS DATETIME),101)

	--  Inserting all the transaction Details in the Specified Period
	INSERT INTO #TranDetails 
	(
		Curr_Date,
		local_curr_cde,
		trn_desc,                                
		amnt,
		beg_balance,
		as_of_tms,
		netcash,
		endbalance,
		sortorder
	)
	SELECT 
		T1.curr_date,
		T1.local_curr_cde,
		T1.trn_desc,                              
		T1.amnt,
		T1.beg_balance,
		T1.as_of_tms,
		T2.netcash,
		T1.endbalance AS endbalance,
		CASE T1.trn_desc                          
				WHEN @lev3_hier_Purchase THEN 1
				WHEN @lev3_hier_Sales    THEN 2
				WHEN @lev3_hier_Income   THEN 3
				ELSE 4
		END AS 'sortorder'
	FROM #InitTranDet T1 
	LEFT OUTER JOIN #Netcash T2 
			ON T1.curr_date = T2.curr_date 
			AND T1.local_curr_cde = T2.local_curr_cde
	ORDER BY T1.local_curr_cde,
			 T1.curr_date,
			 T1.sortorder,
			 T1.trn_desc                         

	-- The Block of Code is used to finding the duplicated rows having the same Date,Currency Code Netcash , Beginning & Ending Balance
	UPDATE #TranDetails
	SET endbalance=beg_balance+netcash ;
	WITH DuplicateCount 
	AS 
	(
		SELECT row_number() OVER(PARTITION BY Curr_Date,local_curr_cde,beg_balance,netcash,endbalance 
		ORDER BY sortorder )
		AS 'Row_no',
		Curr_Date,
		local_curr_cde,
		beg_balance,
		netcash,
		endbalance
		FROM #TranDetails
	)
	INSERT INTO #DuplRows
	(
		id,				
		Curr_Date,
		local_curr_cde,  
		beg_balance,     
		netcash,         
		endbalance		
	)

	SELECT DISTINCT t2.id, 
				t2.Curr_Date, 
				t2.local_curr_cde, 
				t2.beg_balance, 
				t2.netcash, 
				t2.endbalance 
	FROM   DuplicateCount AS d 
		   INNER JOIN #TranDetails AS t2 
				   ON t2.Curr_Date = d.Curr_Date 
					  AND t2.local_curr_cde = d.local_curr_cde 
					  AND t2.beg_balance = d.beg_balance 
					  AND t2.netcash = d.netcash 
					  AND t2.endbalance = d.endbalance 
	WHERE  d.row_no > 1  

	-- The Block of Code is used to pick up the minimum ID among the duplicated rows having the same Date,Currency Code Netcash , Beginning & Ending Balance
	INSERT INTO #min_ids
	(
		id,
		Curr_Date,		
		local_curr_cde,	
		beg_balance,     
		netcash,			
		endbalance		
	)
	SELECT 
		MIN(id) AS 'id',
		Curr_Date,
		local_curr_cde,
		beg_balance,
		netcash,
		endbalance
	FROM #DuplRows 
	GROUP BY Curr_Date,
			 local_curr_cde,
			 beg_balance,
			 netcash,
			 endbalance

	DELETE FROM #DuplRows 
	FROM #DuplRows AS du 
	INNER JOIN #min_ids  AS mi ON du.id=mi.id 

	-- The Block of Code is used to picks up the Distinct rows which does not have Duplicate Entries
	INSERT INTO #DistinctTranDetails 
	(
		Curr_Date,
		local_curr_cde,
		trn_desc,                              
		amnt,
		beg_balance,
		as_of_tms,
		netcash,
		endbalance,
		sortorder
	)
	SELECT 
		tr.Curr_Date,
		tr.local_curr_cde,
		tr.trn_desc,                           
		tr.amnt, 
		tr.beg_balance,
		tr.as_of_tms,
		tr.netcash,
		tr.endbalance,
		tr.sortorder
	FROM #TranDetails AS tr
	LEFT OUTER JOIN #DuplRows AS du 
		ON tr.id=du.id
	WHERE du.id IS NULL

	-- This Block picks up the maximum last Balance
	INSERT INTO #Max_Last_Bal 
				(id, 
				 Max_Last_Bal, 
				 local_curr_cde) 
	SELECT t1.id              AS 'id', 
		   SUM(t2.endbalance) AS 'Max_Last_Bal', 
		   t1.local_curr_cde 
	FROM   #DistinctTranDetails AS t1 
		   INNER JOIN #DistinctTranDetails AS t2 
				   ON t1.id > t2.id 
					  AND t1.local_curr_cde = t2.local_curr_cde 
	GROUP  BY t1.id, 
			  t1.local_curr_cde, 
			  t1.curr_date  

	--	Upadtes the Beginning & End Balance from the Distinct Transaction Details
	UPDATE t2 
	SET    t2.endbalance = mlb.Max_Last_Bal 
	FROM   #DistinctTranDetails AS t2 
		   INNER JOIN #Max_Last_Bal AS mlb 
				   ON t2.id = mlb.id - 1 
					  AND t2.local_curr_cde = mlb.local_curr_cde  


	UPDATE t2 
	SET    t2.beg_balance = t2.beg_balance + t1.endbalance 
	FROM   #DistinctTranDetails AS t1 
		   INNER JOIN #DistinctTranDetails AS t2 
				   ON t2.id = (( t1.id + 1 )) 
					  AND t1.local_curr_cde = t2.local_curr_cde  

	-- Picks up the Maximum Id from the Distinct Transaction Details based on Local Currency
	INSERT INTO #Max_id_local_curr_cde 
	(
		id,
		local_curr_cde
	)
	SELECT MAX(id) AS 'id', 
		   local_curr_cde
	FROM  #DistinctTranDetails
	GROUP BY local_curr_cde

	-- Updating End Balance as the Summation of Beginning Balance & Net Cash
	UPDATE t2 
	SET    endbalance = beg_balance + netcash 
	FROM   #DistinctTranDetails AS t2 
		   INNER JOIN #Max_id_local_curr_cde AS mlb 
				   ON t2.id = mlb.id 
					  AND t2.local_curr_cde = mlb.local_curr_cde  
	
	INSERT INTO #DistinctTranDetails 
	(
		Curr_Date,
		local_curr_cde,
		trn_desc,                             
		amnt,
		beg_balance,
		as_of_tms,
		netcash,
		endbalance,
		sortorder
	)
	SELECT 
		tr.Curr_Date,
		tr.local_curr_cde,
		tr.trn_desc,                          
		tr.amnt,
		tr.beg_balance,
		tr.as_of_tms,
		tr.netcash,
		tr.endbalance,
		tr.sortorder
	FROM #TranDetails AS tr
	INNER JOIN #DuplRows AS du 
				ON tr.id=du.id

	-- Accumulate the Final Transacted Details Based on Transacted Date, Currency and Hierarchy name
	INSERT INTO #FinalDisplayTranDetails
	(
		Curr_Date,
		local_curr_cde,
		trn_desc,                               
		amnt,
		beg_balance,
		as_of_tms,
		netcash,
		endbalance,
		sortorder
	)
	SELECT 
		Curr_Date,
		local_curr_cde,
		trn_desc,                                
		amnt,
		beg_balance,
		as_of_tms,
		netcash,
		endbalance,
		sortorder 
	FROM 
	#DistinctTranDetails 
	ORDER BY Curr_Date,
			 local_curr_cde,
			 sortorder,
             trn_desc                            	


	INSERT INTO #min_id_vals
	(
		Curr_Date,		
		local_curr_cde,  
		trn_desc,									
		amnt,			
		beg_balance,		
		as_of_tms,		
		netcash,			
		endbalance,		
		sortorder		
	)
	SELECT 
		fdt.Curr_Date,
		fdt.local_curr_cde,
		fdt.trn_desc,								
		fdt.amnt,
		fdt.beg_balance,
		fdt.as_of_tms,
		fdt.netcash,
		fdt.endbalance,
		fdt.sortorder 
	FROM	#FinalDisplayTranDetails AS fdt
	INNER JOIN #min_ids	AS mi 
			  ON mi.id=fdt.id

	--	Updation of the Beginning Balance,End Balance,Netcash for the Duplicated rows
	UPDATE #FinalDisplayTranDetails 
	SET    beg_balance = m.endbalance, 
		   netcash = m.netcash, 
		   endbalance = m.endbalance 
	FROM   #min_id_vals AS m 
		   INNER JOIN #FinalDisplayTranDetails AS t 
				   ON t.Curr_Date = m.Curr_Date 
					  AND t.local_curr_cde = m.local_curr_cde 
					  AND m.netcash = t.netcash 
		   INNER JOIN #DuplRows AS du 
				   ON du.id = t.id  

	 SELECT   
		 --id,   
	       
		 local_curr_cde as Currency,  
		 Curr_Date,    
		 beg_balance as Beg_Balance,   
		 trn_desc as Trn_Desc,                
		 amnt as Amount,            
		 CASE   
		WHEN amnt IS NULL THEN NULL   
		ELSE netcash   
		 END AS Net_Cashflow_For_Day,   
		 endbalance as End_Balance        
	 FROM   #FinalDisplayTranDetails   
	 ORDER  BY local_curr_cde,   
		 curr_date,   
		 sortorder 
 
END TRY          
          
      BEGIN CATCH

			 SET @errno    = Error_number()           
             SET @errmsg   = 'Error in dbo.p_SEI_NTK_ProjectedIncomeReportExport: '           
                             + Error_message()           
             SET @errsev   = Error_severity()           
             SET @errstate = Error_state();           
          
          RAISERROR(@errmsg,@errsev,@errstate);           
     
      END CATCH   

	IF OBJECT_ID('tempdb..#InitTranDet') IS NOT NULL                 
			DROP TABLE #InitTranDet 
	IF OBJECT_ID('tempdb..#Netcash') IS NOT NULL                 
			DROP TABLE #Netcash 
	IF OBJECT_ID('tempdb..#TranDetails') IS NOT NULL                 
			DROP TABLE #TranDetails 
	IF OBJECT_ID('tempdb..#DuplRows') IS NOT NULL                 
			DROP TABLE #DuplRows
	IF OBJECT_ID('tempdb..#min_ids') IS NOT NULL                 
			DROP TABLE #min_ids
	IF OBJECT_ID('tempdb..#DistinctTranDetails') IS NOT NULL                 
			DROP TABLE #DistinctTranDetails
	IF OBJECT_ID('tempdb..#FinalDisplayTranDetails') IS NOT NULL                 
			DROP TABLE #FinalDisplayTranDetails
	IF OBJECT_ID('tempdb..#Max_Last_Bal') IS NOT NULL                 
			DROP TABLE #Max_Last_Bal
	IF OBJECT_ID('tempdb..#Max_id_local_curr_cde') IS NOT NULL                 
			DROP TABLE #Max_id_local_curr_cde
	IF OBJECT_ID('tempdb..#min_id_vals') IS NOT NULL                 
			DROP TABLE #min_id_vals
        
  END

GO
GRANT EXECUTE ON dbo.p_SEI_NTK_ProjectedIncomeReportExport TO NETIKAPP_USER
GO

-- Validate if procedure has been created.
IF  EXISTS 
	(
		SELECT 1 
		FROM   information_schema.routines 
		WHERE  routine_type = 'PROCEDURE' 
			   AND routine_schema = 'dbo' 
			   AND routine_name = 'p_SEI_NTK_ProjectedIncomeReportExport'  
	)
	BEGIN
		PRINT 'PROCEDURE dbo.p_SEI_NTK_ProjectedIncomeReportExport has been created.'
	END
ELSE
	BEGIN
		PRINT 'PROCEDURE dbo.p_SEI_NTK_ProjectedIncomeReportExport has NOT been created.'
	END
GO 
  
  
