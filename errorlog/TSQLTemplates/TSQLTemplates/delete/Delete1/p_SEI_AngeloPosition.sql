USE [NetikIP]
GO
/****** Object:  StoredProcedure [dbo].[p_SEI_AngeloPosition]    Script Date: 3/10/2014 3:06:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
  
/*                           
===================================================================================================                           
Name        : p_SEI_AngeloPosition                           
Author      : KAslam         
Date        : 09212012                     
Description : Process fetches the data of Position, Notionals and Transaction for Angelo Gordon.                               
                                  
===================================================================================================                           
Parameters :                
Parameter Name      I/O  Description            
---------------------------------------------------------------------------------------------------                       
@pi_acct_id          I  Account ID                     
@pi_as_of_tms        I  As of Date                     
@pi_inq_basis_num    I  Inquiry Basis Number                     
---------------------------------------------------------------------------------------------------                           
Returns  : Returns table                       
        
Table 1        
Name              Description            
---------------------------------------------------------------------------------------------------         
CUSIP_ISIN_Bank_Loan_#_Loan_X_ID               Cusip              
Item                                           Item Name             
Notl_$                                         Notionals            
Sec_Des             Secondary Description            
Purch_Price_Local                              Purchase Price            
Mkt_Price_Local                                Market Price            
Curr_PNL_in_USD                                Currency             
Coupon             Coupon            
FXD_FLT             Fixed/Flat            
Maturity            Maturity               
Spread                                         Spread            
[Over INDEX/BM]]                               Over Index            
CCY_USD_EUR_other                              Currency Code            
WAL              Wal            
Durn_FXD_Sprd_Durn_FLT                         Spread Fixed             
MDY                                            Market Yeild            
SP              Selling Price             
Fitch             Fitch            
Industry            Industry            
Country             Country            
Region             Region            
H_M_L             [H/M/L] Tags            
FAS_157_ASC_820_Hierarchy                      Hierarchy            
Coupon_Frequency          New Columns added      
Start_Date            New Columns added      
First_Coupon_Date          New Columns added      
Accrued_Interest          New Columns added      
Maturity_Type           New Columns added      
Recovery_Rate           New Columns added      
Debt_Type_cov_lite_LBO_1st_Lien_2nd_Lien_Unsecured      New Columns added      
Change_of_Control_Trigger                      New Columns added      
Issue_Size            New Columns added      
GP_Name             GP Name            
Market_Value_in_USD                            Market Value in USD Dollars            
Asset_Class                                    Asset class            
percent_of_Portfolio                           Percent Of Portfolio            
Custodian            Custodian            
Flag             Flag            
                     
Table 2       
Name             Description            
---------------------------------------------------------------------------------------------------                    
Notl_$             Notionals            
                     
Table 3                     
Name                                                  Description            
---------------------------------------------------------------------------------------------------      
[Notl (mm)]            Notionals            
                     
Table 4                     
Name                    Description         
---------------------------------------------------------------------------------------------------      
[Funding Amount]          Funding Amount            
ud_flt1             Ud_Flt1            
Date             Date            
               
Table 5                     
Name                                                   Description            
---------------------------------------------------------------------------------------------------      
summ             Sum            
                     
Table 6                     
Name                                                  Description            
---------------------------------------------------------------------------------------------------      
sum_ugl             Sum_UGL            
                     
                    
Source Tables: dbo.positionview, dbo.positionplview, dbo.ACCOUNTS_TOTAL_SEI                     
                     
Usage:    EXECUTE dbo.p_SEI_AngeloPosition '1164-1-00200', '2014-01-31 23:59:59.000',5                        
                     
History:                           
Name       Date         Description                           
-----------------------------------------------------------------------------------------------------------------------------------                           
MSohail    08/21/2012   First Version                        
KAslam     10/01/2012   Changed Data type of MAT_EXP_DTE, Case Statement and where clause, marked with --KAslam - 10/01/2012                     
KAslam     10/05/2012   Changed notl datatype in tbl variables and added CASE statement,  marked with --KAslam - 10/05/2012                   
Mchawla    10/05/2012   Hard code the value for July and August.                   
PPremkumar 11/06/2012   Added the Datatype fld02_ind,Added Case for UT_PRC_CMB_AMT,INC_PROJ_CMB_RTE,UD_TXT3,IVVALUES_UD_FLT1,marked with --PPremkumar - 11/06/2012                
PPremkumar 11/06/2012   Removed join on @tblCreated,Changed NAV_FLD8_RATE to ud_flt2 MTM As 0f Date --PPremkumar - 11/06/2012                
MChawla    2/14/2013    Added Quantity to the 'F' flag filter logic             
MSohail    3/06/2013    Added Sections for IRS and Forwards rows manipulation marked with -- MSohail 3/06/2013             
SPurcell   03/08/2013   removed nested select and created join          
KAslam     04/03/2013   New requirements as per JIRA tkt MDB-1346, marked with --KAslam 04032013           
KAslam     04/09/2013   Fix prod issue marked with--KAslam 04092013        
KAslam     04/09/2013   Fix prod issue for multple load of positions marked with --Kaslam 04092013_2        
KAslam     04/11/2013   Include month to date pnl  marked with --KAslam 04112013 - Include month to date pnl          
NKsingh    04/29/2013   Changed the logic for Quantity from Notl(mm) to Notl($) marked with -- NKsingh 04302013      
NKsingh    05/07/2013   Nine new columns added marked with -- NKsingh 05072013        
NKsingh    06/03/2013   updated the MTM field.Changes are made as per the Requirements from Jira tkt MDB 1462 marked with -- NKsingh 06032013        
KAslam     06/03/2013   Changed the logic for Coupon Frequency,Invested Cash,H/M/L or Lqd/Illiq Classif,udf override capability on 'purchprc' is added,      
                        updated the MTM field.Changes are made as per the Requirements from Jira tkt MDB 1462 marked with -- KAslam 06032013       
PPremkumar 06/13/2013   Changed the scalar SELECT in the Where Clause marked with -- ppremkumar 06132013        
RZKumar    06/21/2013   Funding amounts modified at the top of the report; MDB-1693      
RZKumar    07/01/2013   Changed Feilds to have value as N/A instead of NA,Added absolute for funding amt for MDB - 1693 marked with --RZKumar 07012013 -MDB 1693    
ppremkumar 08/16/2013   Changed for Point #2 (Suppress for those data does not have MV or Shares) in MDB -1883 marked with -- ppremkumar 16082013    
ppremkumar 09/12/2013   Added deal_Id column in tables as it required for populating IRS Feilds as per MDB - 2061 marked with -- ppremkumar 09122013    
ppremkumar 09/18/2013   Altered Condition for Over[Index/BM] and changed the asset class from ISS_FLD4_DESC to issue_cls2_nme marked with -- ppremkumar 09182013    
SMehrotra  12/12/2013   Changes related Curr PNL(in USD)2   -Marked with SMehrotra 12122013  
SMehrotra  01/07/2013   Logic change for Purch Price MDB-2875  --SMehrotra 01072013
VBANDI	   01/24/2014	changed join to deal_id instead of a identity column Tag --VBANDI 01242014
KAslam	   02/17/2014	Included two new columns from PositionView --KAslam 02172014
====================================================================================================================================                           
*/              
         
      
ALTER PROCEDURE [dbo].[p_SEI_AngeloPosition]
  (            
  @pi_acct_id        VARCHAR(12),             
  @pi_as_of_tms      DATETIME,             
  @pi_inq_basis_num  INT             
      )            
            
AS    
BEGIN       
           
   SET NOCOUNT ON             
   SET FMTONLY OFF             
      
   DECLARE @StartDate             DATETIME;             
   DECLARE @EndDate               DATETIME;             
   DECLARE @PE_ACCTID             VARCHAR(12);             
   DECLARE @LedgerId19            INT;            
   DECLARE @LedgerId9999          INT;            
   DECLARE @ADJST_TMS             DATETIME;            
   DECLARE @CODESETTYPEID         INT;       
   DECLARE @cash                  VARCHAR(10);       
   DECLARE @CreditFa              VARCHAR(12);      
   DECLARE @CreditCo              VARCHAR(12);      
   DECLARE @forward               VARCHAR(12);      
   DECLARE @L                     VARCHAR(5);      
   DECLARE @S                     VARCHAR(5);    
   DECLARE @F                     VARCHAR(2);    -- ppremkumar 16082013    
   DECLARE @as_of      DATETIME;   -- KAslam 06032013      
   DECLARE @bk_idpe      VARCHAR(2);  -- ppremkumar 06132013      
   DECLARE @MAXadjstasof_tms      DATETIME;        
   DECLARE @MAXadjst_tms          DATETIME;      
   DECLARE @PortfolioPercentDENO  FLOAT;   -- RZKumar 06212013 -1693 Pt# 7      
   DECLARE @scripts5              VARCHAR(10);  -- RZKumar 06212013 -1693 Pt# C      
   DECLARE @TRDBRKRNMEcapital     VARCHAR(7);  -- RZKumar 06212013 -1693 Pt# A      
   DECLARE @TRNCDEcon             VARCHAR(3);  -- RZKumar 06212013 -1693 Pt# A      
   DECLARE @issue_cls1_nme        VARCHAR(8);  -- ppremkumar 16082013    
   DECLARE @errno      INT;     -- ppremkumar 16082013    
   DECLARE @errmsg      NVARCHAR(2100);   -- ppremkumar 16082013    
   DECLARE @errsev      INT;           -- ppremkumar 16082013    
   DECLARE @errstate              INT;        -- ppremkumar 16082013    
   DECLARE @issue_cls2_nme        VARCHAR(6);     -- ppremkumar 16082013    
   DECLARE @ISS_TYP               VARCHAR(6);        --ppremkumar 09122013    
    --All the following tables holds the data less than 200 rows            
             
    --Detail Positions and P&L data of Angelo Gordon                   
   DECLARE @tblReal TABLE             
      (             
       id                  INT IDENTITY (1,1) PRIMARY KEY CLUSTERED,             
       iss_id              NVARCHAR(100),   --KAslam 04032013        
       iss_id_original     NVARCHAR(100),   --KAslam 04032013   -Converted both fields to nvarchar to accomodate superscripts in excel        
       notl                VARCHAR(100),        
       notl_modified       VARCHAR(100),    --KAslam 04032013   -field to get unrounded value               
       iss_desc            VARCHAR(100),             
       purchprc            FLOAT,             
       mktprc              FLOAT,             
       currpnl             FLOAT,             
       inc_proj_cmb_rte    VARCHAR(100),             
       ud_txt1             VARCHAR(100),             
       mat_exp_dte         VARCHAR(25),             
       ivvalues_ud_flt3    VARCHAR(100),             
       ud_txt3             VARCHAR(100),             
       local_curr_cde      VARCHAR(100),             
       ivvalues_ud_flt1    VARCHAR(30),             
       ivvalues_ud_flt2    VARCHAR(30),             
       qual_rtg01_cde      VARCHAR(100),             
       qlty_rtg            VARCHAR(100),            
       fitch               VARCHAR(100),             
       industry            VARCHAR(100),             
       country             VARCHAR(100),             
       region              VARCHAR(100),             
       ud_txt2             VARCHAR(100),             
       hierar              VARCHAR(100),             
       gp_nme              VARCHAR(100),             
       valval_alt_cmb_amt  FLOAT,             
       issue_cls2_nme      VARCHAR(100),                  percpf              VARCHAR(100),             
       custodn_nme         VARCHAR(100),             
       flag                CHAR(1),             
       fld02_ind           CHAR(1),         --PPremkumar - 11/06/2012               
       iss_fld2_txt        VARCHAR(50),             
       tckr_sym_id         VARCHAR(20),             
       deal_nme            VARCHAR(40),             
       UD_TXT7      VARCHAR(100),    --Added below 9 new columns NKsingh 05072013     --RZKumar 06212013 -1693 Pt# B      
       UD_DTE1             VARCHAR(25),     --RZKumar 06212013 -1693 Pt# B      
       UD_DTE2             VARCHAR(25),     --RZKumar 06212013 -1693 Pt# B      
       UD_FLT6      VARCHAR(100),      
       UD_FLT7             VARCHAR(100),      
       UD_TXT8             VARCHAR(100),      
       UD_TXT9             VARCHAR(100),      
       UD_TXT10            VARCHAR(100),      
       UD_INT1             VARCHAR(100),    
    deal_Id      CHAR(16),   -- ppremkumar 09122013    
	BANK_NAME varchar(100),   --KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)
       )         
            
    --Tables for Cash Indicator               
    DECLARE @tblCreated TABLE             
      (             
       id                  INT IDENTITY (1,1) PRIMARY KEY CLUSTERED,             
       iss_id              VARCHAR(100),             
       notl                VARCHAR(100),    --KAslam - 10/05/2012         
       notl_modified       VARCHAR(100),    --KAslam 04032013   -field to get unrounded value                            
       iss_desc            VARCHAR(100),             
       purchprc            FLOAT,             
       mktprc              FLOAT,             
       currpnl             FLOAT,             
       inc_proj_cmb_rte    VARCHAR(100),             
       ud_txt1             VARCHAR(100),             
       mat_exp_dte         VARCHAR(25),             
       ivvalues_ud_flt3    VARCHAR(100),             
       ud_txt3             VARCHAR(100),             
       local_curr_cde      VARCHAR(100),             
       ivvalues_ud_flt1    VARCHAR(30),             
       ivvalues_ud_flt2    VARCHAR(30),             
       qual_rtg01_cde      VARCHAR(100),             
       qlty_rtg            VARCHAR(100),             
       fitch               VARCHAR(100),             
       industry            VARCHAR(100),             
       country             VARCHAR(100),             
       region              VARCHAR(100),             
       ud_txt2             VARCHAR(100),             
       hierar              VARCHAR(100),             
       gp_nme              VARCHAR(100),             
       valval_alt_cmb_amt  FLOAT,             
       issue_cls2_nme      VARCHAR(100),             
       percpf              VARCHAR(100),             
       custodn_nme         VARCHAR(100),             
       flag                CHAR(1),             
       fld02_ind           CHAR(1),            --PPremkumar - 11/06/2012                
       iss_fld2_txt        VARCHAR(50),             
       tckr_sym_id         VARCHAR(20),             
       deal_nme            VARCHAR(40),            
       UD_TXT7             VARCHAR(100),       --Added 9 new columns NKsingh 05072013             --RZKumar 06212013 -1693 Pt# B      
       UD_DTE1             VARCHAR(25),     --RZKumar 06212013 -1693 Pt# B      
       UD_DTE2             VARCHAR(25),        --RZKumar 06212013 -1693 Pt# B      
       UD_FLT6             VARCHAR(100),      
       UD_FLT7             VARCHAR(100),      
       UD_TXT8             VARCHAR(100),      
       UD_TXT9             VARCHAR(100),      
       UD_TXT10            VARCHAR(100),      
       UD_INT1             VARCHAR(100),       --RZKumar 06212013 -1693 Pt# B      
    deal_Id      CHAR(16),      --ppremkumar 09122013    
	BANK_NAME varchar(100),      --KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

       )         
            
    --Holds the data for Credit Facility             
    DECLARE @tblPartiallyFunded TABLE             
      (             
       id                  INT IDENTITY (1,1) PRIMARY KEY  CLUSTERED,             
       iss_id              NVARCHAR(100),      --KAslam 04032013             
       notl                VARCHAR(100),       --KAslam - 10/05/2012                             
       notl_modified   VARCHAR(100),       --KAslam 04032013 - field to get unrounded value        
       iss_desc            VARCHAR(100),             
       purchprc            FLOAT,             
       mktprc              FLOAT,             
       currpnl             FLOAT,             
       inc_proj_cmb_rte    VARCHAR(100),             
       ud_txt1             VARCHAR(100),             
       mat_exp_dte         VARCHAR(25),             
       ivvalues_ud_flt3    VARCHAR(100),             
       ud_txt3             VARCHAR(100),             
       local_curr_cde      VARCHAR(100),             
       ivvalues_ud_flt1    VARCHAR(30),             
       ivvalues_ud_flt2    VARCHAR(30),             
       qual_rtg01_cde      VARCHAR(100),             
       qlty_rtg            VARCHAR(100),             
       fitch               VARCHAR(100),             
       industry            VARCHAR(100),             
       country             VARCHAR(100),             
       region              VARCHAR(100),             
       ud_txt2             VARCHAR(100),             
       hierar              VARCHAR(100),             
       gp_nme              VARCHAR(100),             
       valval_alt_cmb_amt  FLOAT,             
       issue_cls2_nme      VARCHAR(100),             
       percpf              VARCHAR(100),             
       custodn_nme         VARCHAR(100),             
       flag                CHAR(1),             
       fld02_ind           CHAR(1),       --PPremkumar - 11/06/2012                
       iss_fld2_txt        VARCHAR(50),             
       tckr_sym_id         VARCHAR(20),             
       deal_nme            VARCHAR(40),             
       UD_TXT7      VARCHAR(100),  --Added 9 new columns NKsingh 05072013          --RZKumar 06212013 -1693 Pt# B      
       UD_DTE1             VARCHAR(25),   --RZKumar 06212013 -1693 Pt# B      
       UD_DTE2             VARCHAR(25),   --RZKumar 06212013 -1693 Pt# B      
       UD_FLT6             VARCHAR(100),      
       UD_FLT7             VARCHAR(100),      
       UD_TXT8             VARCHAR(100),      
       UD_TXT9             VARCHAR(100),      
       UD_TXT10            VARCHAR(100),      
       UD_INT1             VARCHAR(100),  --RZKumar 06212013 -1693 Pt# B     
    deal_Id      CHAR(16) ,   --ppremkumar 09122013    
	BANK_NAME varchar(100),	  --KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

       )      
            
    --Holds the data of position, P&L, Cas and credit Facility             
    DECLARE @tblAll TABLE             
      (             
       id                  INT IDENTITY (1,1) PRIMARY  KEY CLUSTERED,             
       iss_id              NVARCHAR(100),   --KAslam 04032013          
       iss_id_original     NVARCHAR(100),   --KAslam 04032013 -Converted both fields to nvarchar to accomodate superscripts in excel         
       notl                VARCHAR(100),         
       notl_modified       VARCHAR(100),    --KAslam 04032013 -field to get unrounded value          
       iss_desc            VARCHAR(100),             
       purchprc            FLOAT,             
       mktprc              FLOAT,             
       currpnl             FLOAT,             
       inc_proj_cmb_rte    VARCHAR(100),             
       ud_txt1             VARCHAR(100),             
       mat_exp_dte         VARCHAR(25),             
       ivvalues_ud_flt3    VARCHAR(100),             
       ud_txt3             VARCHAR(100),             
       local_curr_cde   VARCHAR(100),             
       ivvalues_ud_flt1    VARCHAR(30),             
       ivvalues_ud_flt2    VARCHAR(30),             
       qual_rtg01_cde      VARCHAR(100),             
       qlty_rtg            VARCHAR(100),             
       fitch               VARCHAR(100),             
       industry            VARCHAR(100),             
       country             VARCHAR(100),             
       region              VARCHAR(100),             
       ud_txt2             VARCHAR(100),             
       hierar              VARCHAR(100),             
       gp_nme              VARCHAR(100),             
       valval_alt_cmb_amt  FLOAT,             
       issue_cls2_nme      VARCHAR(100),             
       percpf              VARCHAR(100),             
       custodn_nme         VARCHAR(100),             
       flag                CHAR(1),             
       fld02_ind           CHAR(1),        --PPremkumar - 11/06/2012                
       iss_fld2_txt        VARCHAR(50),             
       tckr_sym_id         VARCHAR(20),             
       deal_nme            VARCHAR(40),             
       UD_TXT7             VARCHAR(100),   -- Added 9 new columns NKsingh 05072013               --RZKumar 06212013 -1693 Pt# B      
       UD_DTE1             VARCHAR(25),    --RZKumar 06212013 -1693 Pt# B      
       UD_DTE2             VARCHAR(25),    --RZKumar 06212013 -1693 Pt# B      
       UD_FLT6             VARCHAR(100),      
       UD_FLT7             VARCHAR(100),      
       UD_TXT8             VARCHAR(100),      
       UD_TXT9             VARCHAR(100),      
       UD_TXT10            VARCHAR(100),      
       UD_INT1             VARCHAR(100),    --RZKumar 06212013 -1693 Pt# B      
    deal_Id      CHAR(16)  , -- ppremkumar 09122013    
	BANK_NAME varchar(100),   --KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

       )         
            
 --Holds the data IRS  -- MSohail 3/06/2013            
 DECLARE @TEMPIRS TABLE            
     (            
      Id                 INT IDENTITY (1,1) PRIMARY KEY CLUSTERED,      
   deal_Id    CHAR(16),   -- ppremkumar 09122013    
      deal_nme           VARCHAR(40),               
      iss_fld2_txt       CHAR(8),            
      long_short_ind     CHAR(1),              
      inc_proj_cmb_rte   FLOAT,            
      MAT_EXP_DTE        VARCHAR(25),            
      FLD8_AMT           FLOAT,            
      UD_TXT3            VARCHAR(20),            
      UD_TXT1            VARCHAR(20),    
   deal_count   INT ,                                 -- ppremkumar 09122013                
	BANK_NAME varchar(100),							  --KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

     )         
           
    --Holds the data for Position Long             
    DECLARE @POSL TABLE             
      (             
       id                        INT IDENTITY (1,1) PRIMARY KEY CLUSTERED,             
       iss_id                    CHAR(16),             
       crvl_cmb_amt              VARCHAR(100),    --NOTL        
       crvl_cmb_amt_unrounded    VARCHAR(100),    --KAslam 04032013   -field to get unrounded value          
       deal_nme                  VARCHAR(40),             
       long_short_ind            CHAR(1),             
       crvl_perut_cmb_amt        FLOAT,             
       ut_prc_alt_cmb_amt        FLOAT,             
       ugl_alt_cmb_amt           FLOAT,             
       fld2_tms                  DATETIME,             
       local_curr_cde            CHAR(3),             
       currpnlPOSL               FLOAT ,      --RZKumar 06212013 -1693 Pt# 6     
    deal_Id            CHAR(16)   ,  --ppremkumar 09122013    
	BANK_NAME varchar(100),				--KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

      )             
        
    --Holds the data for Position Short             
    DECLARE @tblForward TABLE             
      (             
       id                  INT IDENTITY (1,1) PRIMARY KEY  CLUSTERED,             
       iss_id              VARCHAR(100),             
       notl                VARCHAR(100),            --KAslam - 10/05/2012                             
       iss_desc            VARCHAR(100),             
       purchprc            FLOAT,             
       mktprc              FLOAT,             
       currpnl             FLOAT,             
       inc_proj_cmb_rte    VARCHAR(100),             
       ud_txt1             VARCHAR(100),             
       mat_exp_dte         VARCHAR(25),             
       ivvalues_ud_flt3    VARCHAR(100),             
       ud_txt3             VARCHAR(100),             
       local_curr_cde      VARCHAR(100),             
       ivvalues_ud_flt1    VARCHAR(30),             
       ivvalues_ud_flt2    VARCHAR(30),             
       qual_rtg01_cde      VARCHAR(100),             
       qlty_rtg            VARCHAR(100),             
       fitch               VARCHAR(100),             
       industry            VARCHAR(100),             
       country             VARCHAR(100),             
       region              VARCHAR(100),             
       ud_txt2             VARCHAR(100),             
       hierar              VARCHAR(100),             
       gp_nme              VARCHAR(100),             
       valval_alt_cmb_amt  FLOAT,             
       issue_cls2_nme      VARCHAR(100),             
       percpf              VARCHAR(100),             
       custodn_nme         VARCHAR(100),             
       flag                CHAR(1),             
       fld02_ind           CHAR(1),         --PPremkumar - 11/06/2012                
       iss_fld2_txt        VARCHAR(50),             
       tckr_sym_id         VARCHAR(20),             
       deal_nme            VARCHAR(40),      
       UD_TXT7             VARCHAR(100),    -- Added 9 new columns NKsingh 05072013    --RZKumar 06212013 -1693 Pt# B      
       UD_DTE1             VARCHAR(25),     -- RZKumar 06212013 -1693 Pt# B      
       UD_DTE2             VARCHAR(25),     -- RZKumar 06212013 -1693 Pt# B      
       UD_FLT6             VARCHAR(100),      
       UD_FLT7             VARCHAR(100),      
       UD_TXT8             VARCHAR(100),      
       UD_TXT9             VARCHAR(100),      
       UD_TXT10            VARCHAR(100),      
       UD_INT1             VARCHAR(100),    --RZKumar 06212013 -1693 Pt# B      
    deal_Id      CHAR(16)  , -- ppremkumar 09122013     
	BANK_NAME varchar(100),		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

       )             
          
 --Holds the data for Position Short Prior  --KAslam 06032013 Pt#6             
    DECLARE @tblForwardPrior TABLE               
      (               
       id              INT IDENTITY (1,1) PRIMARY KEY  CLUSTERED,               
       iss_id          VARCHAR(100),               
       currpnl         FLOAT,               
       deal_nme        VARCHAR(40),    
    deal_Id     CHAR(16)  ,  -- ppremkumar 09122013    
	BANK_NAME varchar(100),			--KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

       )       
      
    --Holds the data for Position Long Prior  --RZKumar 06212013 -1693 Pt# 6               
    DECLARE @POSLPrior TABLE                 
      (                 
       id              INT IDENTITY (1,1) PRIMARY KEY  CLUSTERED,                 
       iss_id          VARCHAR(100),                 
       currpnlPOSL     FLOAT,           
       deal_nme        VARCHAR(40),    
    deal_Id     CHAR(16)  ,  -- ppremkumar 09122013    
	BANK_NAME varchar(100),			--KAslam 02172014
	MARKET_TRADE_TYPE_NAME varchar(100)

       )        
      
 --Holds the data for Position PL View            
    DECLARE @tblPositionPL TABLE            
      (            
       id               INT IDENTITY (1,1) PRIMARY KEY  CLUSTERED,             
       ACCT_ID          CHAR(12),             
       INSTR_ID         CHAR(16),             
       AS_OF_TMS        DATETIME,             
       INQ_BASIS_NUM    INT,             
       PL_MTD_ALT_AMT   FLOAT,             
       ADJST_TMS        DATETIME ,
	  BANK_NAME varchar(100),				--KAslam 02172014
	  MARKET_TRADE_TYPE_NAME varchar(100)
           
       )            
            
    --Holds the data for Credit Co iss_fld2_txt            
    DECLARE @tblReal_CreditCo TABLE             
      (            
       CreditCoid        INT IDENTITY (1,1) PRIMARY KEY  CLUSTERED,             
       ud_txt3           VARCHAR(100),             
       ud_txt1           VARCHAR(100),             
       iss_id            VARCHAR(100),               
       ivvalues_ud_flt3  VARCHAR(100),             
       inc_proj_cmb_rte  VARCHAR(100),             
       purchprc          FLOAT,            
       industry          VARCHAR(100)            
       )            
            
  --Holds the data for Credit FA iss_fld2_txt            
  DECLARE @tblReal_CreditFA TABLE             
      (            
       CreditFAID   INT IDENTITY (1,1) PRIMARY KEY  CLUSTERED,             
       ud_txt3    VARCHAR(100),             
       ud_txt1    VARCHAR(100),             
       iss_id    VARCHAR(100),               
       ivvalues_ud_flt3  VARCHAR(100),             
       inc_proj_cmb_rte  VARCHAR(100),             
       purchprc    FLOAT,            
       industry    VARCHAR(100),            
       country           VARCHAR(100),             
       region            VARCHAR(100),             
       tckr_sym_id       VARCHAR(20)            
       )            
        
  --Holds the Data from the  data of position, P&L, Cas and credit Facility @tblAll           
  DECLARE @AngeloPos_Tmp TABLE        
      (        
       Id                                         INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,        
       pos_id                                     NVARCHAR(200),        
       pos_id_1  NVARCHAR(200),        
       Item                                       BIGINT,        
       Notl_$                                     VARCHAR(100),                 --NKsingh 04302013 changed Notl (mm) to Notl ($)      
       notl_modified                              VARCHAR(100),        
       Notl_mm_modified         VARCHAR(100),        
       Curr_PNL_in_USD                            FLOAT,        
       iss_fld2_txt                               VARCHAR(50),        
       CUSIP_ISIN_Bank_Loan_#_Loan_X_ID           NVARCHAR(200),        
       Sec_Des                                    VARCHAR(100),        
       Purch_Price_Local                          FLOAT,        
       Mkt_Price_Local                            FLOAT,        
       Coupon                                     VARCHAR(100),        
       FXD_FLT                                    VARCHAR(100),        
       Maturity                                   VARCHAR(10),        
       Spread                                     FLOAT,        
       ud_txt3                                    VARCHAR(100),                                       
       CCY_USD_EUR_other                          VARCHAR(100),             
       WAL                                        VARCHAR(30),             
       Durn_FXD_Sprd_Durn_FLT                     VARCHAR(30),        
       MDY                                        VARCHAR(100),             
       SP                                         VARCHAR(100),                  
       Fitch                                      VARCHAR(100),             
       Industry                                   VARCHAR(100),             
       Country                                    VARCHAR(100),             
       Region                                     VARCHAR(100),             
       H_M_L_Lqd_Illiq_Classif                    VARCHAR(100),                    --KAslam 06032013 -1462 Pt#4         
       FAS_157_ASC_820_Hierarchy                  VARCHAR(100),          
       GP_Name                                    VARCHAR(100),              
       Market_Value_in_USD                        FLOAT,             
       Asset_Class          VARCHAR(100),             
       percent_of_Portfolio                       VARCHAR(100),             
       Custodian                                  VARCHAR(100),             
       flag                                       CHAR(1),      
       Coupon_Frequency         VARCHAR(100),                    -- Added 9 new columns NKsingh 05072013      
       Start_Date          VARCHAR(25),      
       First_Coupon_Date        VARCHAR(25),      
       Accrued_Interest                           VARCHAR(100),      
       Maturity_Type         VARCHAR(100),         
       Recovery_Rate         VARCHAR(100),      
       Debt_Type_cov_lite_LBO_1st_Lien_2nd_Lien_Unsecured   VARCHAR(100),      
       Change_of_Control_Trigger       VARCHAR(100),      
       Issue_Size           VARCHAR(100)      ,
		BANK_NAME varchar(100),				--KAslam 02172014
		MARKET_TRADE_TYPE_NAME varchar(100)

       )        
    
    
--Holds the Data from the  data of position, P&L, Cas and credit Facility @tblAll     
--All the following tables holds the data less than 200 rows            
  DECLARE @AngeloPos_Tmp1 TABLE        
      (        
       Unique_ID                                  INT IDENTITY(1,1),       
       pos_id                                     NVARCHAR(200),                  
       CUSIP_ISIN_Bank_Loan_#_Loan_X_ID           NVARCHAR(200),        
       PRIMARY KEY CLUSTERED (pos_id,Unique_ID)      
       )      
      
  DECLARE @AngeloPos_Tmp2 TABLE  -- ppremkumar 16082013    
 (    
  Unique_ID INT IDENTITY(1,1),    
  pos_id    NVARCHAR(200),    
  CUSIP   NVARCHAR(200),    
  PRIMARY KEY CLUSTERED (pos_id,Unique_ID)    
 )     
    
  DECLARE @AngeloPos_Tmp3 TABLE  -- ppremkumar 16082013    
 (    
  Unique_ID INT IDENTITY(1,1),    
  pos_id    NVARCHAR(200),    
  CUSIP   NVARCHAR(200),    
  PRIMARY KEY CLUSTERED (pos_id,Unique_ID)    
 )       
     
    
--Holds the Data from the  data of position, P&L, Cas and credit Facility @tblAll  -- ppremkumar 16082013       
 DECLARE @AngeloPos_Tmp4 TABLE        
   (        
     Unique_ID              INT IDENTITY(1,1),    
     Counter           INT,    
     pos_id                                     NVARCHAR(200),                 
     CUSIP_ISIN_Bank_Loan_#_Loan_X_ID           NVARCHAR(200),    
     PRIMARY KEY CLUSTERED (pos_id,Unique_ID)    
    )    
--Holds the Data from Tbale TRANEVENT_DG                                                      --RZKumar 07012013 -MDB 1693     
     DECLARE @Fund_Amt TABLE                                                                  --RZKumar 07012013 -MDB 1693     
       (    
         Unique_ID        INT IDENTITY(1,1),    
         FundingAmount    DECIMAL,    
         Date             VARCHAR(10),    
         PRIMARY KEY CLUSTERED (FundingAmount,Unique_ID)    
       )    
                     
    
       
            
  BEGIN TRY             
            
 SET @StartDate     = DATEADD(DAY, 0, DATEDIFF(d, 0, @pi_as_of_tms));             
 SET @EndDate       = DATEADD(ms, -3, DATEADD(DAY, 1, @StartDate));             
 SET @PE_ACCTID     = '1164-P000859';    -- Only for Angelo Gordon Accounts            
 SET @LedgerId19    = 19;     -- Ledger Id will be 19 for AG             
 SET @LedgerId9999  = 9999;     -- Ledger Id will be 9999 for AG            
 SET @CODESETTYPEID = 20;              
 SET @cash          = 'cash';       
 SET @CreditFa      = 'CreditFa';      
 SET @CreditCo      = 'CreditCo';      
 SET @forward       = 'forward';       
 SET @L             = 'L';      
 SET @S             = 'S';    
 SET @F             = 'F';      
 SET @bk_idpe  = 'pe'           --ppremkumar 06132013      
 SET @scripts5  = 'LX123224';    --RZKumar 06212013 -1693 Pt# C      
 SET @TRDBRKRNMEcapital = 'CAPITAL'  --RZKumar 06212013 -1693 Pt# A       
 SET @TRNCDEcon     = 'CON'    --RZKumar 06212013 -1693 Pt# A       
 SET @issue_cls1_nme = 'swap'     
 SET @issue_cls2_nme = 'IRS'      
 SET @ISS_TYP        = 'IRSWP'       --ppremkumar 09122013       
-- Replaced the Scalar Select in where Clause  -- ppremkumar 06132013            
SET @MAXadjst_tms = (SELECT MAX(adjst_tms)       
      FROM dbo.positionview --KAslam 04092013_2 - Added max to ignore duplicate         
      WHERE acct_id     = @pi_acct_id       
      AND inq_basis_num = @pi_inq_basis_num       
      AND as_of_tms     = @pi_as_of_tms)       
      
SET  @as_of = DATEADD(second,-1,DATEADD(dd, 0, DATEADD(mm,DATEDIFF(mm,0,@pi_as_of_tms),0)))  --'2013-02-28 23:59:59.000'        
      
SET @MAXadjstasof_tms = (SELECT MAX(adjst_tms)         
                         FROM  dbo.positionview --KAslam 04092013_2 - Added max to ignore duplicate           
                         WHERE acct_id       = @pi_acct_id         
                         AND inq_basis_num   = @pi_inq_basis_num         
                         AND as_of_tms       = @as_of)         
    
--RZKumar 06212013 -1693 Pt# 7      
SET @PortfolioPercentDENO = (SELECT SUM (VALVAL_CMB_AMT + FLD21_AMT)      
        FROM dbo.positionview      
        WHERE acct_id  = @PE_ACCTID      
        --AND inq_basis_num = @pi_inq_basis_num      
        AND AS_OF_TMS  = @pi_as_of_tms)         
      
     --Gets the Adjustment Date             
     SELECT @ADJST_TMS = MAX(adjst_tms)       
     FROM dbo.positionplview       
     WHERE acct_id   = @pi_acct_id       
     AND  as_of_tms  = @pi_as_of_tms       
     AND  inq_basis_num  = @pi_inq_basis_num       
     AND  issue_cls2_nme <> @cash        
          
     --Inserts the data from Position PL View             
     INSERT INTO @tblPositionPL       
          (      
           ACCT_ID,       
           INSTR_ID,       
           AS_OF_TMS,       
           INQ_BASIS_NUM,       
           PL_MTD_ALT_AMT,       
           ADJST_TMS      
           )       
     SELECT      
           acct_id,       
           instr_id,       
           as_of_tms,       
           inq_basis_num,       
           PL_MTD_ALT_AMT = SUM(pl_mtd_alt_amt),       
           adjst_tms       
     FROM dbo.positionplview       
     WHERE acct_id = @pi_acct_id       
  AND as_of_tms = @pi_as_of_tms       
     AND inq_basis_num = @pi_inq_basis_num       
     AND issue_cls2_nme <> @cash      
     AND adjst_tms = @ADJST_TMS       
     GROUP BY acct_id,       
     instr_id,       
    as_of_tms,       
              inq_basis_num,       
              adjst_tms         
            
     --Inserts Positions and P&L data of Angelo Gordon             
     INSERT INTO @tblReal       
          (      
           iss_id,       
           iss_id_original,   --KAslam 04032013               
           notl,       
           notl_modified,     --KAslam 04032013              
           iss_desc,       
           purchprc,       
           mktprc,       
           currpnl,       
           inc_proj_cmb_rte,       
           ud_txt1,       
           mat_exp_dte,       
           ivvalues_ud_flt3,       
           ud_txt3,       
           local_curr_cde,       
           ivvalues_ud_flt1,       
           ivvalues_ud_flt2,       
           qual_rtg01_cde,       
           qlty_rtg,       
           fitch,       
           industry,       
           country,       
           region,       
           ud_txt2,       
           hierar,       
           gp_nme,       
           valval_alt_cmb_amt,       
           issue_cls2_nme,       
           percpf,       
           custodn_nme,       
           flag,       
           fld02_ind,       
           iss_fld2_txt,       
           tckr_sym_id,       
           deal_nme,      
           UD_TXT7,  -- Added 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
           UD_DTE1,  --RZKumar 06212013 -1693 Pt# B        
           UD_DTE2,  --RZKumar 06212013 -1693 Pt# B        
           UD_FLT6,      
           UD_FLT7,      
           UD_TXT8,      
           UD_TXT9,      
           UD_TXT10,      
           UD_INT1,  --RZKumar 06212013 -1693 Pt# B        
     deal_Id  ,-- ppremkumar 09122013    
	BANK_NAME,	--KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014
           )       
     SELECT       
       iss_id = CASE       
                  WHEN p.ud_txt4 IS NOT NULL THEN p.ud_txt4     
                  ELSE p.iss_id     
                END,     
       iss_id_original = CASE     
                           WHEN p.ud_txt4 IS NOT NULL THEN p.ud_txt4     
                           ELSE p.iss_id     
                         END,     
       notl = CASE     
                WHEN P.iss_fld2_txt = @CreditFa THEN '0'     
                ELSE Cast(p.quantity AS DECIMAL(12, 2))     
              -- NKsingh 04302013               
              END,--in millions,                  
       notl_modified = CASE     
                         WHEN P.iss_fld2_txt = @CreditFa THEN '0'     
                         ELSE p.quantity -- NKsingh 04302013               
                       END,--in millions,          
       p.iss_desc,     
       ( CASE     
    WHEN p.ivvalues_ud_flt4  IS NOT NULL     
                  THEN p.ivvalues_ud_flt4  --KAslam 06032013 -1462 Pt#8      
             WHEN p.ud_flt3 IS NOT NULL       
                  THEN p.ud_flt3       
             WHEN ( RTRIM(LTRIM(p.issue_cls2_nme)) = 'Trade Claim - Equity' )       
                  THEN p.crvl_perut_cmb_amt --* 100     --KAslam 04032013              
             WHEN ( RTRIM(LTRIM(p.issue_cls2_nme)) IN ( 'Term Loan', 'Revolver' ) )       
                  THEN p.fld45_amt       --p.fld22_amt Commented based on MDB-2875  --SMehrotra 01072013
             ELSE ( CASE       
              WHEN p.quantity = 0 THEN 0       
              ELSE ( p.crvl_cmb_amt - p.fld5_amt ) / p.quantity / p.prc_mltplr_rte       
                 END )       
             END ),--For Purchase Price  -- PPremkumar - 11/06/2012                 
       UT_PRC_CMB_AMT = ( CASE       
                  WHEN ( RTRIM(LTRIM(p.issue_cls2_nme)) = 'Trade Claim - Equity' )       
                              THEN p.ut_prc_cmb_amt --* 100 --KAslam 04032013              
                            ELSE p.ut_prc_cmb_amt     
                          END ),     
       pl.pl_mtd_alt_amt,--Curr PNL(in USD)]                   
       p.inc_proj_cmb_rte,--Coupon   -- PPremkumar - 11/06/2012                  
       UD_TXT1= ( CASE     
                    WHEN p.varrte_ind = 0 THEN 'Fixed'     
                    WHEN p.issue_cls2_nme IN ( 'Term Loan', 'Revolver' )     
                         AND p.varrte_ind = 1     
                         AND p.iss_fld23_ind = 1 THEN 'Inverse Float'     
                    WHEN p.issue_cls2_nme IN ( 'Term Loan', 'Revolver' )     
            AND p.varrte_ind = 1     
                         AND Isnull(p.iss_fld23_ind, 0) = 0 THEN 'Float'     
                    WHEN p.varrte_ind = 1     
                         AND p.iss_fld23_ind = 1     
                         AND p.curr14_cde IS NOT NULL THEN 'Inverse Float'     
                    WHEN p.varrte_ind = 1     
                         AND Isnull(p.iss_fld23_ind, 0) = 0     
                         AND p.curr14_cde IS NOT NULL THEN 'Float'     
                    WHEN varrte_ind = 1     
                         AND iss_fld23_ind = 1     
                         AND curr14_cde IS NULL THEN 'Fixed'     
                    WHEN varrte_ind = 1     
                         AND Isnull(iss_fld23_ind, 0) = 0     
                         AND curr14_cde IS NULL THEN 'Fixed'     
                    ELSE ''     
                  END ),--FXD_FLT --Updated - 10/04/2012                      
       MAT_EXP_DTE = CASE     
                       WHEN p.iss_fld2_txt = @CreditCo THEN P.fld05_tms     
                       ELSE p.mat_exp_dte     
                     END,--KAslam - 10/05/2012                     
      sprd_rte = ( CASE     
                      WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )     
                            OR curr14_cde IS NOT NULL THEN sprd_rte     
                      ELSE 0     
                    END ), --Spread               
      UD_TXT3 = ( CASE       
                    WHEN RTRIM(curr14_cde) = 'US0001M-INDEX'       
                   AND iss_fld23_ind = 1 THEN '(-1) Libor'       
                    WHEN RTRIM(curr14_cde) = 'US0001M-INDEX'       
                   AND iss_fld23_ind = 0 THEN 'Libor'       
                    WHEN RTRIM(curr14_cde) = 'US0003M-INDEX'       
                   AND iss_fld23_ind = 1 THEN '(-1) Libor'       
                    WHEN RTRIM(curr14_cde) = 'US0003M-INDEX'       
                   AND iss_fld23_ind = 0 THEN 'Libor'       
                    WHEN RTRIM(curr14_cde) = 'US0006M-INDEX'       
                   AND iss_fld23_ind = 1 THEN '(-1) Libor'       
                    WHEN RTRIM(curr14_cde) = 'US0006M-INDEX'       
                   AND iss_fld23_ind = 0 THEN 'Libor'       
                    WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
                   AND iss_fld23_ind = 1 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
                   AND iss_fld23_ind = 0 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
                   AND iss_fld23_ind = 1 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
                   AND iss_fld23_ind = 0 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
                   AND iss_fld23_ind = 1 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
                   AND iss_fld23_ind = 0 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
                   AND iss_fld23_ind = 1 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
                   AND iss_fld23_ind = 0 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
                   AND iss_fld23_ind = 1 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
                   AND iss_fld23_ind = 0 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
                   AND iss_fld23_ind = 1 THEN ''       
                    WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
                   AND iss_fld23_ind = 0 THEN ''       
                    WHEN RIGHT(iss_fld2_desc, 1) = @L       
                   AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Libor'       
                    WHEN RIGHT(iss_fld2_desc, 1) = @L       
                   AND ISNULL(iss_fld23_ind, 0) = 1 THEN '(-1) Libor'       
                    WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
                   AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Prime'       
                    WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
                   AND ISNULL(iss_fld23_ind, 0) = 1 THEN '(-1) Prime'       
                    WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
                   AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Euribor'       
                    WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
                   AND ISNULL(iss_fld23_ind, 0) = 1 THEN '(-1) Euribor'       
                    ELSE ud_txt3       
                    END ),--PPremkumar - 11/06/2012                 
           p.local_curr_cde,       
           ivvalues_ud_flt1,       
           ivvalues_ud_flt2,       
           p.qual_rtg01_cde,       
           p.qlty_rtg,       
           '',       
           industry =( CASE    
		   WHEN p.ud_industry  IS NOT NULL     
                  THEN p.ud_industry     
           WHEN ( dbo.FNDW_SEI_GICSCODES(P.instr_id, 'SIN') ) <> 'SubIndustry Not Classified'       
                       THEN ( dbo.FNDW_SEI_GICSCODES(P.instr_id, 'SIN') )       
                 WHEN iss_fld15_txt IS NOT NULL THEN iss_fld15_txt       
                -- ELSE ud_industry       
                    END ),--Industry                
           p.lev_4_hier_nme,--Country              
           cr.external_value,       
           -- spurcell 03.08.2013 removed nested select             
           --(SELECT external_value              
           -- FROM   netikdp.dbo.dp_crossreference              
           -- WHERE  codeset_type_id = @CODESETTYPEID              
           --        AND internal_value = p.issue_loc1_cde),-- Region              
           ud_txt2 = ( CASE       
                 WHEN fld13_ind = 0 THEN 'Low Liquidity Position'       
                 WHEN fld13_ind = 1 THEN 'Medium Liquidity Position'       
                 WHEN fld13_ind = 2 THEN 'High Liquidity Position'       
                 ELSE ''       
                    END ),       
           ( CASE       
             WHEN ( RTRIM(LTRIM(p.fld01_ind)) ) = '' THEN p.fld01_ind       
             ELSE 'Level' + p.fld01_ind       
             END ),       
           'AG Centre Street GP LLC',       
           valval_alt_cmb_amt = CASE       
                    WHEN P.iss_fld2_txt = @CreditFa THEN 0       
                    ELSE p.valval_alt_cmb_amt       
                    END,--Market_Value_in_USD                
           p.issue_cls2_nme,                     -- ppremkumar 09182013    
           --- spurcell 03.08.2013  added join to remove nested select             
           --( p.valval_alt_cmb_amt / (SELECT Sum(p2.valval_alt_cmb_amt + p2.fld21_amt)              
           --                          FROM   dbo.positionview p2              
           --           WHERE  p2.acct_id = @PE_ACCTID --KAslam - 10/01/2012                      
           --                                 --Change to a Transformed Investran ID from p.nom_acct_id                       
           --                                 AND p.as_of_tms = p2.as_of_tms              
           --                          GROUP  BY acct_id) ),              
           p.valval_alt_cmb_amt / SUM(valval_alt_cmb_amt + fld21_amt)       
                OVER(       
                PARTITION BY p.acct_id, p.as_of_tms),       
           p.custodn_nme,       
           flag =( CASE       
             WHEN RTRIM(p.iss_fld2_txt) = @CreditCo       
               OR fld02_ind = 2       
                   THEN 'B'       
             ELSE ''       
                END ),       
           p.fld02_ind,    --PPremkumar - 11/06/2012                 
           P.iss_fld2_txt,       
           P.tckr_sym_id,       
           p.deal_nme,      
           p.UD_TXT7,     --Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B      
           p.UD_DTE1,     --RZKumar 06212013 -1693 Pt# B        
           p.UD_DTE2,     --RZKumar 06212013 -1693 Pt# B        
           p.UD_FLT6,      
           p.UD_FLT7,      
           p.UD_TXT8,      
           p.UD_TXT9,      
           p.UD_TXT10,      
           CAST(p.UD_INT1 AS DECIMAL(12, 2)), --RZKumar 06212013 -1693 Pt# B        
     p.deal_Id       , --ppremkumar 09122013    
	p.[Primary/Secondary] ,  --KAslam 02172014
	p.[Sole Lender/Syndicated]		--KAslam 02172014

          FROM  dbo.positionview p       
       --- spurcell 03.08.2013  added join to remove nested select             
    LEFT OUTER JOIN netikdp.dbo.dp_crossreference cr       
       ON cr.internal_value = p.issue_loc1_cde       
          AND cr.codeset_type_id = @CODESETTYPEID       
          LEFT OUTER JOIN @tblPositionPL AS pl       
       ON p.acct_id = pl.acct_id       
          AND p.instr_id = pl.instr_id       
          AND p.as_of_tms = pl.as_of_tms       
          AND p.inq_basis_num = pl.inq_basis_num       
    WHERE  p.acct_id = @pi_acct_id       
      -- spurcell 03.08.2013 added to remove nested select             
    AND p.as_of_tms = @pi_as_of_tms       
          AND p.adjst_tms = @MAXadjst_tms       -- ppremkumar 06132013      
          AND p.inq_basis_num = @pi_inq_basis_num       
          AND p.issue_cls2_nme <> @cash        
      
      
     INSERT INTO @tblCreated       
          (      
           iss_id,       
           notl,       
           notl_modified,    --KAslam 04032013              
           iss_desc,       
           purchprc,       
           mktprc,       
     currpnl,       
           inc_proj_cmb_rte,       
           ud_txt1,       
           mat_exp_dte,       
           ivvalues_ud_flt3,       
           ud_txt3,       
           local_curr_cde,       
           ivvalues_ud_flt1,       
           ivvalues_ud_flt2,       
           qual_rtg01_cde,       
           qlty_rtg,       
           fitch,       
           industry,       
           country,       
           region,       
           ud_txt2,       
           hierar,       
           gp_nme,       
           valval_alt_cmb_amt,       
           issue_cls2_nme,       
           percpf,       
           custodn_nme,       
           flag,       
           fld02_ind,       
           iss_fld2_txt,       
           tckr_sym_id,       
           deal_nme,      
           UD_TXT7,   -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
           UD_DTE1,   --RZKumar 06212013 -1693 Pt# B        
           UD_DTE2,   --RZKumar 06212013 -1693 Pt# B        
           UD_FLT6,      
           UD_FLT7,      
           UD_TXT8,      
           UD_TXT9,      
           UD_TXT10,      
           UD_INT1,         -- RZKumar 06212013 -1693 Pt# B        
   deal_Id   ,-- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014
           )       
    SELECT iss_id = CASE     
                  WHEN p.ud_txt4 IS NOT NULL THEN p.ud_txt4     
                  ELSE p.iss_id     
                END,     
       NULL,     
       NULL,     
       p.iss_desc,     
       ( CASE     
     WHEN p.ivvalues_ud_flt4  IS NOT NULL       
                   THEN p.ivvalues_ud_flt4    --KAslam 06032013 -1462 Pt#8       
     WHEN ud_flt3 IS NOT NULL       
                   THEN ud_flt3       
     WHEN ( RTRIM(LTRIM(issue_cls2_nme)) = 'Trade Claim - Equity' )       
                   THEN crvl_perut_cmb_amt --* 100     --KAslam 04032013              
     WHEN ( RTRIM(LTRIM(issue_cls2_nme)) IN ( 'Term Loan', 'Revolver' ) )       
        THEN p.fld45_amt       --p.fld22_amt Commented based on MDB-2875 --SMehrotra 01072013
        ELSE ( CASE       
      WHEN quantity = 0 THEN 0       
      ELSE ( crvl_cmb_amt - fld5_amt ) / quantity / prc_mltplr_rte       
      END )       
     END ),--For Purchase Price                  
   UT_PRC_CMB_AMT = ( CASE       
              WHEN ( RTRIM(LTRIM(p.issue_cls2_nme)) = 'Trade Claim - Equity' )       
                                    THEN p.ut_prc_cmb_amt  --* 100     --KAslam 04032013              
         ELSE p.ut_prc_cmb_amt       
                          END ),     
       NULL,--Curr_PNL_in_USD                   
       0,--Coupon               
       UD_TXT1= ( CASE     
                    WHEN varrte_ind = 0 THEN 'Fixed'     
                    WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )     
                         AND varrte_ind = 1     
                         AND iss_fld23_ind = 1 THEN 'Inverse Float'     
                    WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )     
                         AND varrte_ind = 1     
                         AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Float'     
                    WHEN varrte_ind = 1     
                         AND iss_fld23_ind = 1     
                         AND curr14_cde IS NOT NULL THEN 'Inverse Float'     
                    WHEN varrte_ind = 1     
          AND ISNULL(iss_fld23_ind, 0) = 0     
                         AND curr14_cde IS NOT NULL THEN 'Float'     
                    WHEN varrte_ind = 1     
                         AND ISNULL(iss_fld23_ind, 0) = 0     
                         AND curr14_cde IS NULL THEN 'Fixed'     
                    ELSE ''     
                  END ),--FXD_FLT --Updated - 10/04/2012                     
       MAT_EXP_DTE = CASE     
                       WHEN p.iss_fld2_txt = @CreditCo THEN P.fld05_tms     
                       ELSE p.mat_exp_dte     
                     END,--p.UD_DTE1   removed 2012-10-04                     
       SPRD_RTE =0, --Spread       
    
                   
   --For INDEX/BM                  
   UD_TXT3=( CASE       
        WHEN RTRIM(curr14_cde) = 'US0001M-INDEX'       
          AND iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RTRIM(curr14_cde) = 'US0001M-INDEX'       
          AND iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RTRIM(curr14_cde) = 'US0003M-INDEX'       
          AND iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RTRIM(curr14_cde) = 'US0003M-INDEX'       
          AND iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RTRIM(curr14_cde) = 'US0006M-INDEX'       
          AND iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RTRIM(curr14_cde) = 'US0006M-INDEX'       
          AND iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
     AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RIGHT(iss_fld2_desc, 1) = @L       
          AND iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RIGHT(iss_fld2_desc, 1) = @L      
          AND iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
          AND iss_fld23_ind = 0 THEN 'Prime'       
        WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
          AND iss_fld23_ind = 1 THEN '(-1) Prime'       
        WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
          AND iss_fld23_ind = 0 THEN 'Euribor'       
        WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
          AND iss_fld23_ind = 1 THEN '(-1) Euribor'       
        ELSE ud_txt3       
        END ),       
   p.local_curr_cde,       
   ivvalues_ud_flt1,  --PPremkumar - 11/06/2012                 
   ivvalues_ud_flt2,  --PPremkumar - 11/06/2012                 
   '',       
   '',       
   '',       
   industry =( CASE
   WHEN p.ud_industry  IS NOT NULL     
                  THEN p.ud_industry          
       WHEN ( dbo.FNDW_SEI_GICSCODES(P.instr_id, 'SIN') ) <>       
          'SubIndustry Not Classified'       
                                 THEN ( dbo.FNDW_SEI_GICSCODES(P.instr_id, 'SIN') )       
          WHEN iss_fld15_txt IS NOT NULL       
                                 THEN iss_fld15_txt       
      -- ELSE ud_industry       
       END ),--Industry                
   p.lev_4_hier_nme,--Country              
   cr.external_value,       
   -- spurcell 03.08.2013 removed nested select             
   --(SELECT external_value              
   -- FROM   netikdp.dbo.dp_crossreference              
   -- WHERE  codeset_type_id = @CODESETTYPEID               --        AND internal_value = p.issue_loc1_cde),--Region                
   ud_txt2 = ( CASE       
       WHEN fld13_ind = 0 THEN 'Low Liquidity Position'       
       WHEN fld13_ind = 1 THEN 'Medium Liquidity Position'       
       WHEN fld13_ind = 2 THEN 'High Liquidity Position'       
       ELSE ''       
       END ),--H_M_L              
      ( CASE       
       WHEN ( RTRIM(LTRIM(p.fld01_ind)) ) = '' THEN p.fld01_ind       
       ELSE 'Level' + p.fld01_ind       
          END ),       
   'AG Centre Street GP LLC',       
   0,       
   p.issue_cls2_nme,                     -- ppremkumar 09182013    
   0,--KAslam - 10/05/2012                    
   p.custodn_nme,       
   '',       
   p.fld02_ind,       
   P.iss_fld2_txt,       
   P.tckr_sym_id,       
      deal_nme,      
      p.UD_TXT7, -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B      
      p.UD_DTE1,  --RZKumar 06212013 -1693 Pt# B        
      p.UD_DTE2,  --RZKumar 06212013 -1693 Pt# B        
      p.UD_FLT6,      
      p.UD_FLT7,      
      p.UD_TXT8,      
      p.UD_TXT9,      
      p.UD_TXT10,      
      CAST(p.UD_INT1 AS DECIMAL(12, 2)),   --RZKumar 06212013 -1693 Pt# B        
   p.deal_Id  ,   -- ppremkumar 09122013    
	p.[Primary/Secondary] ,	--KAslam 02172014
	p.[Sole Lender/Syndicated]	--KAslam 02172014
    FROM  dbo.positionview p --PPremkumar -11/06/2012              
  -- spurcell 03.08.2013  added join to replace nested select             
    LEFT OUTER JOIN netikdp.dbo.dp_crossreference cr       
    ON cr.internal_value = p.issue_loc1_cde       
    AND cr.codeset_type_id = @CODESETTYPEID       
    WHERE p.acct_id = @pi_acct_id       
    AND p.as_of_tms = @pi_as_of_tms       
    AND p.adjst_tms = @MAXadjst_tms   -- ppremkumar 06132013      
    AND p.inq_basis_num  = @pi_inq_basis_num       
    AND p.issue_cls2_nme <> @cash         -- ppremkumar 09182013    
    AND fld02_ind = 2             
            
  --The following table contains the partially funded dummy records from Credit Facility to credit Contract              
  INSERT INTO @tblPartiallyFunded       
    (      
     iss_id,       
     notl,       
     notl_modified,  --KAslam 04032013              
     iss_desc,       
     purchprc,       
     mktprc,       
     currpnl,       
     inc_proj_cmb_rte,       
     ud_txt1,       
     mat_exp_dte,       
     ivvalues_ud_flt3,       
     ud_txt3,       
     local_curr_cde,       
     ivvalues_ud_flt1,       
     ivvalues_ud_flt2,       
     qual_rtg01_cde,       
     qlty_rtg,       
     fitch,       
     industry,       
     country,       
     region,       
     ud_txt2,       
     hierar,       
     gp_nme,       
     valval_alt_cmb_amt,       
     issue_cls2_nme,       
     percpf,       
     custodn_nme,       
     flag,       
     fld02_ind,       
     iss_fld2_txt,       
     tckr_sym_id,       
     deal_nme,      
     UD_TXT7,   -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
     UD_DTE1,   --RZKumar 06212013 -1693 Pt# B        
     UD_DTE2,   --RZKumar 06212013 -1693 Pt# B        
     UD_FLT6,      
     UD_FLT7,      
     UD_TXT8,      
     UD_TXT9,      
     UD_TXT10,      
     UD_INT1,     --RZKumar 06212013 -1693 Pt# B        
  deal_Id  , -- ppremkumar 09122013    
	BANK_NAME,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME		--KAslam 02172014
     )       
     SELECT iss_id = RTRIM(CASE       
         WHEN p.ud_txt4 IS NOT NULL THEN p.ud_txt4       
         ELSE p.iss_id       
         END),       
   CAST(p.quantity AS DECIMAL(12, 2)),   -- NKsingh 04302013          
   p.quantity,                  -- NKsingh 04302013        
   p.iss_desc,       
   ( CASE       
      WHEN p.ivvalues_ud_flt4  IS NOT NULL         
      THEN p.ivvalues_ud_flt4            --KAslam 06032013 -1462 Pt#8        
      WHEN ( RTRIM(LTRIM(issue_cls2_nme)) = 'Trade Claim - Equity' )       
      THEN crvl_perut_cmb_amt --* 100    --KAslam 04032013              
      WHEN ( RTRIM(LTRIM(issue_cls2_nme)) IN ( 'Term Loan', 'Revolver' ) )       
       THEN p.fld45_amt       --p.fld22_amt Commented based on MDB-2875 --SMehrotra 01072013
      ELSE ( CASE       
           WHEN quantity = 0 THEN 0       
        ELSE ( crvl_cmb_amt - fld5_amt ) / quantity / prc_mltplr_rte       
           END )       
      END ),--For Purchase Price                  
   UT_PRC_CMB_AMT = ( CASE       
         WHEN ( RTRIM(LTRIM(p.issue_cls2_nme)) =  'Trade Claim - Equity' )       
                                    THEN p.ut_prc_cmb_amt --* 100      --KAslam 04032013         
         ELSE p.ut_prc_cmb_amt       
            END ),       
   NULL,--Curr_PNL_in_USD                  
   0,   --Coupon              
   UD_TXT1= ( CASE       
           WHEN varrte_ind = 0 THEN 'Fixed'       
           WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )       
        AND varrte_ind = 1       
        AND iss_fld23_ind = 1 THEN 'Inverse Float'       
         WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )       
        AND varrte_ind = 1       
        AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Float'       
         WHEN varrte_ind = 1       
        AND iss_fld23_ind = 1       
           AND curr14_cde IS NOT NULL THEN 'Inverse Float'       
         WHEN varrte_ind = 1       
        AND ISNULL(iss_fld23_ind, 0) = 0       
        AND curr14_cde IS NOT NULL THEN 'Float'       
         WHEN varrte_ind = 1       
        AND ISNULL(iss_fld23_ind, 0) = 0       
        AND curr14_cde IS NULL THEN 'Fixed'       
         ELSE ''       
         END ),--FXD_FLT --Updated - 10/04/2012                    
   MAT_EXP_DTE = CASE       
         WHEN p.iss_fld2_txt = @CreditCo THEN P.fld05_tms       
         ELSE p.mat_exp_dte       
         END,--p.UD_DTE1   removed 2012-10-04                    
   SPRD_RTE =0,--Spread                    
   --For INDEX/BM                  
   UD_TXT3=( CASE       
        WHEN RTRIM(p.curr14_cde) = 'US0001M-INDEX'       
             AND p.iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RTRIM(p.curr14_cde) = 'US0001M-INDEX'       
          AND p.iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RTRIM(p.curr14_cde) = 'US0003M-INDEX'       
          AND p.iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RTRIM(curr14_cde) = 'US0003M-INDEX'       
             AND p.iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RTRIM(p.curr14_cde) = 'US0006M-INDEX'       
          AND p.iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RTRIM(p.curr14_cde) = 'US0006M-INDEX'       
          AND iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
             AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
          AND iss_fld23_ind = 1 THEN ''       
        WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
          AND iss_fld23_ind = 0 THEN ''       
        WHEN RIGHT(iss_fld2_desc, 1) = @L       
          AND iss_fld23_ind = 0 THEN 'Libor'       
        WHEN RIGHT(iss_fld2_desc, 1) = @L       
          AND iss_fld23_ind = 1 THEN '(-1) Libor'       
        WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
          AND iss_fld23_ind = 0 THEN 'Prime'       
        WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
          AND iss_fld23_ind = 1 THEN '(-1) Prime'       
        WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
          AND iss_fld23_ind = 0 THEN 'Euribor'       
        WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
          AND iss_fld23_ind = 1 THEN '(-1) Euribor'       
        ELSE ud_txt3       
        END ),       
   p.local_curr_cde,       
   p.ivvalues_ud_flt1,  --PPremkumar - 11/06/2012                 
   p.ivvalues_ud_flt2,  --PPremkumar - 11/06/2012                 
   '',       
   '',       
   '',       
   industry =( CASE 
	   WHEN p.ud_industry  IS NOT NULL     
                  THEN p.ud_industry       
       WHEN ( dbo.FNDW_SEI_GICSCODES(P.instr_id, 'SIN') ) <> 'SubIndustry Not Classified'       
                                THEN ( dbo.FNDW_SEI_GICSCODES(P.instr_id, 'SIN') )       
       WHEN iss_fld15_txt IS NOT NULL       
                                THEN iss_fld15_txt       
     --  ELSE ud_industry       
          END ),--Industry                
   p.lev_4_hier_nme,--Country              
   cr.external_value,       
   -- spurcell 03.08.2013 removed nested select             
   --(SELECT external_value              
   -- FROM   netikdp.dbo.dp_crossreference              
   -- WHERE  codeset_type_id = @CODESETTYPEID              
   --        AND internal_value = p.issue_loc1_cde),--Region                
   ud_txt2 = ( CASE       
         WHEN p.fld13_ind = 0 THEN 'Low Liquidity Position'       
         WHEN p.fld13_ind = 1 THEN 'Medium Liquidity Position'       
         WHEN p.fld13_ind = 2 THEN 'High Liquidity Position'       
         ELSE ''       
            END ),--H_M_L              
   ( CASE       
     WHEN ( RTRIM(LTRIM(p.fld01_ind)) ) = '' THEN p.fld01_ind       
     ELSE 'Level' + p.fld01_ind       
     END ),       
   'AG Centre Street GP LLC',       
   p.valval_alt_cmb_amt,       
   p.issue_cls2_nme,                                           -- ppremkumar 09182013    
   0,--KAslam - 10/05/2012                    
   p.custodn_nme,       
   'B',       
   p.fld02_ind,       
   iss_fld2_txt = @CreditCo,--P.iss_fld2_txt                
   P.tckr_sym_id,       
   p.deal_nme,      
   p.UD_TXT7,   -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B      
   p.UD_DTE1,   --RZKumar 06212013 -1693 Pt# B        
   p.UD_DTE2,   --RZKumar 06212013 -1693 Pt# B        
   p.UD_FLT6,      
   p.UD_FLT7,      
   p.UD_TXT8,      
   p.UD_TXT9,      
   p.UD_TXT10,      
   CAST(p.UD_INT1 AS DECIMAL(12, 2)),   --RZKumar 06212013 -1693 Pt# B        
   p.deal_Id ,         -- ppremkumar 09122013    
   p.[Primary/Secondary] ,		--KAslam 02172014
   p.[Sole Lender/Syndicated]		--KAslam 02172014
   FROM  dbo.positionview p --PPremkumar -11/06/2012              
   -- spurcell 03.08.2013 added join to remove nested select             
   LEFT OUTER JOIN netikdp.dbo.dp_crossreference cr    --- Sonia -- this table not in netikip and always refer to NetipDP      
   ON cr.internal_value = p.issue_loc1_cde       
   AND cr.codeset_type_id = @CODESETTYPEID       
   WHERE  p.acct_id = @pi_acct_id       
   -- spurcell 03.08.2013 added to remove nested select             
    AND  p.as_of_tms = @pi_as_of_tms       
    AND  p.adjst_tms = @MAXadjst_tms   -- ppremkumar 06132013      
    AND  p.inq_basis_num  = @pi_inq_basis_num       
    AND  p.issue_cls2_nme <> @cash                             -- ppremkumar 09182013    
    AND  fld02_ind        = 1       
    AND  P.iss_fld2_txt   = @CreditFa             
            
    --Updates Credit Contract from Credit Facility entries in Partially Funded Table              
    UPDATE @tblPartiallyFunded       
       SET tr.inc_proj_cmb_rte = cr.inc_proj_cmb_rte       
      FROM @tblPartiallyFunded tr       
      LEFT OUTER JOIN (SELECT ud_txt3,       
           ud_txt1,       
           ( CASE       
             WHEN CHARINDEX ('_', iss_id) > 1 THEN RTRIM(       
                  SUBSTRING(iss_id, 1,       
                  CHARINDEX('_', iss_id) - 1))       
             ELSE RTRIM(iss_id)       
             END ) AS iss_id,       
           ivvalues_ud_flt3,       
           inc_proj_cmb_rte,       
           purchprc,       
           industry       
         FROM @tblReal       
         WHERE iss_fld2_txt = @CreditFa) cr       
         ON ( CASE       
           WHEN CHARINDEX('_', tr.iss_id) > 1 THEN RTRIM(       
           SUBSTRING(tr.iss_id, 1, CHARINDEX('_', tr.iss_id) - 1       
           ))       
           ELSE RTRIM(tr.iss_id)       
         END ) = ( CASE       
            WHEN CHARINDEX('_', cr.iss_id) > 1 THEN       
            RTRIM(       
            SUBSTRING(cr.iss_id, 1,       
            CHARINDEX('_', cr.iss_id) - 1))       
            ELSE RTRIM(cr.iss_id)       
             END )       
  WHERE  tr.iss_fld2_txt = @CreditCo             
            
  -- Inserting Values into @tblReal_CreditCo             
  INSERT INTO @tblReal_CreditCo       
    (      
     ud_txt3,       
     ud_txt1,       
     iss_id,       
     ivvalues_ud_flt3,       
     inc_proj_cmb_rte,       
     purchprc,       
     industry      
    )       
   SELECT ud_txt3,       
          ud_txt1,       
       ( CASE       
         WHEN CHARINDEX('_', iss_id) > 1 THEN RTRIM(       
         SUBSTRING(iss_id, 1,       
         CHARINDEX('_', iss_id) - 1))       
         ELSE RTRIM(iss_id)       
       END ) AS iss_id,       
       ivvalues_ud_flt3,       
       inc_proj_cmb_rte,       
       purchprc,       
       industry       
   FROM   @tblReal       
   WHERE  iss_fld2_txt = @CreditCo       
      
  --Updates Credit Facility from Credit Contract entries in Real Table                
  UPDATE @tblReal       
  SET   tr.ud_txt3 = cr.ud_txt3,       
  tr.ud_txt1 = cr.ud_txt1,       
  tr.ivvalues_ud_flt3 = cr.ivvalues_ud_flt3,       
  tr.inc_proj_cmb_rte = cr.inc_proj_cmb_rte,       
  tr.purchprc = cr.purchprc       
  FROM  @tblReal tr       
        LEFT OUTER JOIN @tblReal_CreditCo cr       
       ON ( CASE       
           WHEN CHARINDEX('_', tr.iss_id) > 1 THEN RTRIM(       
           SUBSTRING(tr.iss_id, 1, CHARINDEX('_', tr.iss_id) - 1       
           ))       
           ELSE RTRIM(tr.iss_id)       
         END ) = ( CASE       
            WHEN CHARINDEX('_', cr.iss_id) > 1 THEN       
            RTRIM(       
            SUBSTRING(cr.iss_id, 1,       
            CHARINDEX('_', cr.iss_id)       
            - 1))       
            ELSE RTRIM(cr.iss_id)       
             END )       
    WHERE  tr.iss_fld2_txt = @CreditFa             
             
  -- Inserting Values into @tblReal_CreditFA             
  INSERT INTO @tblReal_CreditFA       
    (      
     ud_txt3,       
     ud_txt1,       
     iss_id,       
     ivvalues_ud_flt3,       
     inc_proj_cmb_rte,       
     purchprc,       
     industry,       
     country,       
     region,       
     tckr_sym_id      
    )       
  SELECT ud_txt3,       
      ud_txt1,       
      ( CASE       
       WHEN CHARINDEX('_', iss_id) > 1 THEN RTRIM(       
       SUBSTRING(iss_id, 1,       
       CHARINDEX('_', iss_id) - 1))       
       ELSE RTRIM(iss_id)       
       END ) AS iss_id,       
      ivvalues_ud_flt3,       
      inc_proj_cmb_rte,       
      purchprc,       
      industry,       
      country,       
      region,       
      tckr_sym_id       
  FROM   @tblReal       
  WHERE  iss_fld2_txt = @CreditFa        
            
  --Updates Contract from Facility                 
  UPDATE @tblReal       
  SET    tr.tckr_sym_id = cr.tckr_sym_id,       
   tr.industry = cr.industry,       
         tr.region = cr.region,       
         tr.country = CR.country       
  FROM   @tblReal tr       
         LEFT OUTER JOIN @tblReal_CreditFA cr       
        ON ( CASE       
           WHEN CHARINDEX('_', tr.iss_id) > 1 THEN RTRIM(       
           SUBSTRING(tr.iss_id, 1, CHARINDEX('_', tr.iss_id) - 1       
           ))       
           ELSE RTRIM(tr.iss_id)       
         END ) = ( CASE       
           WHEN CHARINDEX('_', cr.iss_id) > 1 THEN       
           RTRIM(       
           SUBSTRING(cr.iss_id, 1,       
           CHARINDEX('_', cr.iss_id)       
           - 1))       
         ELSE RTRIM(cr.iss_id)       
            END )       
  WHERE  tr.iss_fld2_txt = @CreditCo        
      
           
  --Update flag for Positions and P&L data              
  UPDATE @tblReal       
  SET    flag = 'F'       
  WHERE  iss_fld2_txt <> @CreditFa       
         AND valval_alt_cmb_amt + notl = 0        
           
  --Updates Contract from Facility                
  UPDATE @tblReal       
  --SET    tr.iss_id = cr.iss_id + NCHAR(0x00002074)       
    SET    tr.iss_id = cr.iss_id + NCHAR(0x00002074)+ ',' + NCHAR(0x2075)  --RZKumar 06212013 -1693 Pt# C        
   --KAslam 04032013    -- To accomodate superscript in the excel report.          
  -- This nchar value stands for a superscript of 4.         
  FROM  @tblReal tr       
     LEFT OUTER JOIN (SELECT ( CASE       
            WHEN CHARINDEX ('_', iss_id) > 1 THEN RTRIM(       
            SUBSTRING(iss_id, 1,       
            CHARINDEX('_', iss_id) - 1))       
            ELSE RTRIM(iss_id)       
          END ) AS iss_id      
       FROM   @tblPartiallyFunded       
       WHERE  iss_fld2_txt = @CreditCo) cr       
       ON ( CASE       
          WHEN CHARINDEX('_', tr.iss_id) > 1 THEN RTRIM(       
          SUBSTRING(tr.iss_id, 1, CHARINDEX('_', tr.iss_id) - 1       
          ))       
          ELSE RTRIM(tr.iss_id)       
        END ) = ( CASE       
           WHEN CHARINDEX('_', cr.iss_id) > 1 THEN       
           RTRIM(       
           SUBSTRING(cr.iss_id, 1,       
           CHARINDEX('_', cr.iss_id)       
           - 1))       
           ELSE RTRIM(cr.iss_id)       
            END )       
  WHERE  tr.iss_fld2_txt = @CreditCo       
     AND fld02_ind = 0       
     AND CR.iss_id IS NOT NULL            
            
--added for JIRA 1883 starts    
UPDATE @tblReal       
  SET    tr.iss_id = cr.iss_id + NCHAR(0x00002074)     
  --KAslam 04032013    -- To accomodate superscript in the excel report.          
  -- This nchar value stands for a superscript of 4.         
 FROM  @tblReal tr       
     LEFT OUTER JOIN (SELECT ( CASE       
            WHEN CHARINDEX ('_', iss_id) > 1 THEN RTRIM( SUBSTRING(iss_id, 1,CHARINDEX('_', iss_id) - 1))       
            ELSE RTRIM(iss_id)       
          END ) AS iss_id       
       FROM   @tblPartiallyFunded    
WHERE  iss_fld2_txt = @CreditCo and local_curr_cde = 'GBP') cr       
       ON ( CASE       
          WHEN CHARINDEX('_', tr.iss_id_original) > 1 THEN RTRIM(SUBSTRING(tr.iss_id_original, 1, CHARINDEX('_', tr.iss_id_original) - 1))       
          ELSE RTRIM(tr.iss_id_original)       
        END ) = ( CASE       
           WHEN CHARINDEX('_', cr.iss_id) > 1 THEN RTRIM(SUBSTRING(cr.iss_id, 1, CHARINDEX('_', cr.iss_id) - 1))       
           ELSE RTRIM(cr.iss_id)       
            END )       
  WHERE  tr.iss_fld2_txt = @CreditCo       
         AND fld02_ind = 0       
         AND CR.iss_id IS NOT NULL     
    
--added for JIRA 1883 ends    
    
      --This section is to incorporate Forward changes --MSOhail -03/06/2013             
            
     --Inserts Forward Long position data.             
  INSERT INTO @POSL       
    (      
     iss_id,       
     crvl_cmb_amt,       
     crvl_cmb_amt_unrounded,--KAslam 04032013              
     deal_nme,       
     long_short_ind,       
     crvl_perut_cmb_amt,       
     ut_prc_alt_cmb_amt,       
     ugl_alt_cmb_amt,       
     fld2_tms,       
     local_curr_cde,      
     currpnlPOSL,  --RZKumar 06212013 -1693 Pt# 6      
  deal_Id , -- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME		--KAslam 02172014

    )       
  SELECT iss_id,       
      --CAST(ROUND(CONVERT(BIGINT, crvl_cmb_amt) / 1000000.0, 2) AS DECIMAL(10, 2))     --KAslam 04092013 - Changed INT to BIGINT         
      CAST(crvl_cmb_amt AS DECIMAL(14, 2)) CRVL_CMB_AMT,     -- NKsingh 04302013          
      CONVERT(BIGINT, crvl_cmb_amt) / 1000000.0,            --KAslam 04032013 --KAslam 04092013 - Changed INT to BIGINT         
      deal_nme,       
      long_short_ind,       
      crvl_perut_cmb_amt,       
      ut_prc_alt_cmb_amt,       
      ugl_alt_cmb_amt,       
      fld2_tms,       
      local_curr_cde,       
      ugl_alt_cmb_amt,  --RZKumar 06212013 -1693 Pt# B       
   deal_Id ,  -- ppremkumar 09122013    
	[Primary/Secondary] ,		--KAslam 02172014
	[Sole Lender/Syndicated]	--KAslam 02172014
  FROM   dbo.positionview       
  WHERE  acct_id = @pi_acct_id       
      AND as_of_tms = @pi_as_of_tms       
      AND adjst_tms = @MAXadjst_tms  -- ppremkumar 06132013      
      AND inq_basis_num  = @pi_inq_basis_num       
      AND issue_cls1_nme = @forward       
      AND long_short_ind = @L      
  ORDER  BY deal_nme,       
            crvl_perut_cmb_amt DESC,       
   crvl_alt_cmb_amt   DESC        
      
  --Inserts Forward Short position data.             
  INSERT INTO @tblForward       
          (      
          iss_id,       
          notl,       
          iss_desc,       
          purchprc,       
          mktprc,       
          currpnl,       
          inc_proj_cmb_rte,       
          ud_txt1,       
          mat_exp_dte,       
          ivvalues_ud_flt3,       
          ud_txt3,       
          local_curr_cde,       
          ivvalues_ud_flt1,       
          ivvalues_ud_flt2,       
          qual_rtg01_cde,       
          qlty_rtg,       
          fitch,       
          industry,       
          country,       
          region,      
          ud_txt2,       
          hierar,       
          gp_nme,       
          valval_alt_cmb_amt,       
         issue_cls2_nme,       
          percpf,       
          custodn_nme,       
          flag,       
          fld02_ind,       
          iss_fld2_txt,       
          tckr_sym_id,       
          deal_nme,      
          UD_TXT7,  -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
          UD_DTE1,  --RZKumar 06212013 -1693 Pt# B       
          UD_DTE2,  --RZKumar 06212013 -1693 Pt# B       
          UD_FLT6,      
          UD_FLT7,      
          UD_TXT8,      
          UD_TXT9,      
          UD_TXT10,      
          UD_INT1,    --RZKumar 06212013 -1693 Pt# B       
    deal_Id  , -- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME		--KAslam 02172014
       )       
     SELECT       
       iss_id = CASE       
       WHEN PS.ud_txt4 IS NOT NULL THEN PS.ud_txt4       
       ELSE PS.iss_id       
       END,--CUSIP/ISIN/Bank Loan #/Loan X ID              
       NULL,--Notl (mm)              
       PS.deal_nme,--Sec_Des1              
       CASE         
   WHEN PS.ivvalues_ud_flt4  IS NOT NULL THEN PS.ivvalues_ud_flt4    --KAslam 06032013 -1462 Pt#8        
   ELSE PS.crvl_perut_cmb_amt--For Purchase Price                    
   END,             
       PS.ut_prc_alt_cmb_amt mktprc,--Mkt Price (Local)              
       --PL.PL_MTD_ALT_AMT,       
       PS.ugl_alt_cmb_amt,--Curr_PNL_in_USD         --KAslam 04112013 - Include month to date pnl           
       0,--Coupon              
       UD_TXT1 = ( CASE       
      WHEN varrte_ind = 0 THEN 'Fixed'       
      WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )       
        AND varrte_ind = 1       
        AND iss_fld23_ind = 1 THEN 'Inverse Float'       
      WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )       
        AND varrte_ind = 1       
        AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Float'       
      WHEN varrte_ind = 1       
        AND iss_fld23_ind = 1       
        AND curr14_cde IS NOT NULL THEN 'Inverse Float'       
      WHEN varrte_ind = 1       
        AND ISNULL(iss_fld23_ind, 0) = 0       
        AND curr14_cde IS NOT NULL THEN 'Float'       
      WHEN varrte_ind = 1       
        AND ISNULL(iss_fld23_ind, 0) = 0       
        AND curr14_cde IS NULL THEN 'Fixed'       
      ELSE ''       
      END ), --FXD_FLT --Updated - 10/04/2012                    
   PS.fld2_tms,  --Maturity                  
   SPRD_RTE =0,  --Spread                    
   --For INDEX/BM                  
   ud_txt3,           --Over [INDEX/BM]              
   PS.local_curr_cde, --CCY (USD/EUR/other)              
   ivvalues_ud_flt1,  --WAL                 
   ivvalues_ud_flt2,  --Durn (FXD)/Sprd Durn (FLT)                
   '', --MDY              
   '', --SP              
   '', --Fitch              
   industry =( CASE 
      WHEN ps.ud_industry  IS NOT NULL     
                  THEN ps.ud_industry       
        WHEN PS.iss_fld2_txt = 'ForwardC' THEN 'N/A'   --RZKumar 06212013 -1693   --RZKumar 07012013 -MDB 1693      
                   END ),--Industry                
   PS.lev_4_hier_nme,--Country              
   cr.external_value,       
   -- spurcell 03.08.2013  removed nested select              
   --(SELECT external_value              
   -- FROM   netikdp.dbo.dp_crossreference              
   -- WHERE  codeset_type_id = @CODESETTYPEID              
   --        AND internal_value = PS.issue_loc1_cde),--Region                
   ud_txt2 = ( CASE       
        WHEN fld13_ind = 0 THEN 'Low Liquidity Position'       
        WHEN fld13_ind = 1 THEN 'Medium Liquidity Position'       
        WHEN fld13_ind = 2 THEN 'High Liquidity Position'       
       ELSE ''       
           END ),  --H_M_L              
   ( CASE       
      WHEN ( RTRIM(LTRIM(PS.fld01_ind)) ) = '' THEN PS.fld01_ind       
      ELSE 'Level' + PS.fld01_ind       
      END ),-- FAS 157/ASC 820 Hierarchy              
   'AG Centre Street GP LLC',--GP Name              
   PS.ugl_alt_cmb_amt,--Market Value(in USD)              
   PS.issue_cls2_nme,--Asset Class                           -- ppremkumar 09182013    
   --0,--percent_of_Portfolio                     
   PS.valval_alt_cmb_amt / SUM(valval_alt_cmb_amt + fld21_amt)    --KAslam 06032013 -1462 Pt#7        
   OVER( PARTITION BY PS.acct_id, PS.as_of_tms),        
   PS.custodn_nme,--Custodian               
   '',       
   PS.fld02_ind,       
   PS.iss_fld2_txt,       
   PS.tckr_sym_id,       
      deal_nme,      
      PS.UD_TXT7,  -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B      
      PS.UD_DTE1,  --RZKumar 06212013 -1693 Pt# B       
      PS.UD_DTE2,  --RZKumar 06212013 -1693 Pt# B       
      CAST (PS.UD_FLT6 AS DECIMAL(12,4)),      
      CAST (PS.UD_FLT7 AS DECIMAL(12,4)),      
      PS.UD_TXT8,      
      PS.UD_TXT9,      
      PS.UD_TXT10,      
      CAST(PS.UD_INT1 AS DECIMAL(12, 2)),  --RZKumar 06212013 -1693 Pt# B       
   PS.deal_Id  , -- ppremkumar 09122013    
	PS.[Primary/Secondary] ,		--KAslam 02172014
	PS.[Sole Lender/Syndicated]		--KAslam 02172014
   FROM  dbo.positionview AS PS       
     LEFT OUTER JOIN @tblPositionPL AS pl       
     --KAslam 04112013 - To include month to date pnl instead of ugl_alt         
     ON PS.acct_id = pl.acct_id       
     AND PS.instr_id = pl.instr_id       
     AND PS.as_of_tms = pl.as_of_tms       
     AND PS.inq_basis_num = pl.inq_basis_num       
     -- spurcell 03.08.2013 added join to remove nested select             
     LEFT OUTER JOIN netikdp.dbo.dp_crossreference cr       
     ON cr.internal_value = PS.issue_loc1_cde       
     AND cr.codeset_type_id = @CODESETTYPEID       
     WHERE  PS.acct_id = @pi_acct_id       
  -- spurcell 03.08.2013 added to remove nested select             
     AND PS.as_of_tms = @pi_as_of_tms       
     AND PS.adjst_tms = @MAXadjst_tms  -- ppremkumar 06132013      
  AND PS.inq_basis_num  = @pi_inq_basis_num       
     AND PS.issue_cls1_nme = @forward       
     AND PS.long_short_ind = @S       
 ORDER  BY PS.deal_nme, PS.deal_Id, -- ppremkumar 09122013    
           crvl_perut_cmb_amt DESC,       
     crvl_alt_cmb_amt   DESC              
    --End of the section of Forward changes             
       
 --KAslam  06032013 - 1462 Pt#6 - starting        
          
INSERT INTO @tblForwardPrior         
    (        
     iss_id,         
     currpnl,         
     deal_nme,    
  deal_Id  ,           -- ppremkumar 09122013    
	BANK_NAME ,			--KAslam 02172014
	MARKET_TRADE_TYPE_NAME		--KAslam 02172014
    )         
  SELECT iss_id = CASE         
                  WHEN PS.ud_txt4 IS NOT NULL THEN PS.ud_txt4         
                  ELSE PS.iss_id         
                  END,         --CUSIP/ISIN/Bank Loan #/Loan X ID                
         --PS.deal_nme,--Sec_Des1                
         --PL.PL_MTD_ALT_AMT,         
         PS.ugl_alt_cmb_amt,   --[Curr PNL(in USD)]         --KAslam 04112013 - Include month to date pnl             
         deal_nme,    
   deal_Id ,   -- ppremkumar 09122013    
	PS.[Primary/Secondary] ,			--KAslam 02172014
	PS.[Sole Lender/Syndicated]			--KAslam 02172014
  FROM   dbo.positionview AS PS         
  LEFT OUTER JOIN @tblPositionPL AS pl         
   --KAslam 04112013 - To include month to date pnl instead of ugl_alt           
    ON PS.acct_id       = pl.acct_id         
   AND PS.instr_id      = pl.instr_id         
   AND PS.as_of_tms     = pl.as_of_tms         
   AND PS.inq_basis_num = pl.inq_basis_num         
   -- spurcell 03.08.2013 added join to remove nested select               
   LEFT OUTER JOIN netikdp.dbo.dp_crossreference cr         
     ON cr.internal_value = PS.issue_loc1_cde         
    AND cr.codeset_type_id = @CODESETTYPEID         
  WHERE  PS.acct_id = @pi_acct_id         
      -- spurcell 03.08.2013 added to remove nested select               
      AND PS.as_of_tms = @as_of         
      AND PS.adjst_tms = @MAXadjstasof_tms      -- ppremkumar 06132013      
      AND PS.inq_basis_num  = @pi_inq_basis_num         
      AND PS.issue_cls1_nme = @forward         
      AND PS.long_short_ind = @S         
  ORDER  BY PS.deal_nme,         
            crvl_perut_cmb_amt DESC,         
            crvl_alt_cmb_amt   DESC         
      
-- Added the below logic by --RZKumar 06212013 -1693 Pt# 6      
INSERT INTO @POSLPrior           
    (          
     iss_id,           
     currpnlPOSL,           
     deal_nme,    
     deal_Id , -- ppremkumar 09122013    
	BANK_NAME , --KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014

    )           
  SELECT iss_id = CASE           
                  WHEN PS.ud_txt4 IS NOT NULL THEN PS.ud_txt4           
                  ELSE PS.iss_id           
                  END,      
         PS.ugl_alt_cmb_amt,      
         deal_nme,    
   deal_Id ,  -- ppremkumar 09122013    
	PS.[Primary/Secondary] ,	--KAslam 02172014
	PS.[Sole Lender/Syndicated] --KAslam 02172014
  FROM   dbo.positionview AS PS          
   LEFT OUTER JOIN @tblPositionPL AS pl           
    ON PS.acct_id       = pl.acct_id           
   AND PS.instr_id      = pl.instr_id           
   AND PS.as_of_tms     = pl.as_of_tms           
   AND PS.inq_basis_num = pl.inq_basis_num           
   LEFT OUTER JOIN netikdp.dbo.dp_crossreference cr           
     ON cr.internal_value = PS.issue_loc1_cde           
   AND cr.codeset_type_id = @CODESETTYPEID           
  WHERE  PS.acct_id = @pi_acct_id               
      AND PS.as_of_tms = @as_of           
      AND PS.adjst_tms = @MAXadjstasof_tms        
      AND PS.inq_basis_num  = @pi_inq_basis_num           
      AND PS.issue_cls1_nme = @forward           
      AND PS.long_short_ind = @L           
  ORDER  BY PS.deal_nme,           
            crvl_perut_cmb_amt DESC,           
            crvl_alt_cmb_amt  DESC       
  --      select * from @tblForwardPrior
		--select * from @tblForward
  UPDATE t2        
  SET t2.currpnl =  t2.currpnl - t1.currpnl        
  --select t2.currpnl - t1.currpnl, t2.iss_id        
  FROM @tblForwardPrior t1        
    INNER JOIN @tblForward t2       
            ON
			 t1.iss_id   = t2.iss_id         
           AND 
		   t1.deal_id = t2.deal_id  -- SMehrotra 12122013  - Data filtering criteria changed from Deal_nme to Deal_id             
  --    select * from @POSLPrior
		--select * from @POSL
 --RZKumar 06212013 -1693 Pt# 6      
 UPDATE t2          
    SET t2.currpnlPOSL =  t2.currpnlPOSL - t1.currpnlPOSL          
  --select t2.currpnl - t1.currpnl, t2.iss_id          
   FROM @POSLPrior t1          
    INNER JOIN @POSL t2         
            ON 
			t1.iss_id   = t2.iss_id    
		and 	 t1.deal_id = t2.deal_id 
			
			--t1.iss_id   = t2.iss_id           
   --        AND t1.deal_nme = t2.deal_nme      
      
 --Inserts the consolidated data             
 INSERT INTO @tblAll       
      (      
      iss_id,       
      iss_id_original,   --KAslam 04032013              
      notl,       
      notl_modified,     --KAslam 04032013              
      iss_desc,       
      purchprc,       
      mktprc,       
      currpnl,       
      inc_proj_cmb_rte,       
      ud_txt1,       
      mat_exp_dte,       
      ivvalues_ud_flt3,       
      ud_txt3,       
      local_curr_cde,       
      ivvalues_ud_flt1,       
      ivvalues_ud_flt2,       
      qual_rtg01_cde,       
      qlty_rtg,       
      fitch,       
      industry,       
      country,       
      region,       
      ud_txt2,       
      hierar,       
      gp_nme,       
      valval_alt_cmb_amt,       
      issue_cls2_nme,       
      percpf,       
      custodn_nme,       
      flag,       
      fld02_ind,       
      iss_fld2_txt,       
      tckr_sym_id,       
      deal_nme,      
      UD_TXT7,  -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
      UD_DTE1,  --RZKumar 06212013 -1693 Pt# B       
      UD_DTE2,  --RZKumar 06212013 -1693 Pt# B       
      UD_FLT6,      
      UD_FLT7,      
      UD_TXT8,      
      UD_TXT9,      
      UD_TXT10,      
      UD_INT1,    --RZKumar 06212013 -1693 Pt# B       
   deal_Id , -- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014
  )       
 SELECT       
      iss_id,       
      iss_id,         --KAslam 04032013             
      notl,       
      notl_modified,  --KAslam 04032013              
      iss_desc,       
      purchprc,       
      mktprc,       
      currpnl,       
      inc_proj_cmb_rte,       
      ud_txt1,       
      mat_exp_dte,       
      ivvalues_ud_flt3,       
      ud_txt3,       
      local_curr_cde,       
      ivvalues_ud_flt1,       
      ivvalues_ud_flt2,       
      qual_rtg01_cde,       
      qlty_rtg,       
      fitch,       
      industry,       
      country,       
      region,       
      ud_txt2,       
      hierar,       
      gp_nme,       
      valval_alt_cmb_amt,       
      issue_cls2_nme,       
      percpf,       
      custodn_nme,       
      flag,       
      fld02_ind,       
      iss_fld2_txt,       
      tckr_sym_id,       
      deal_nme,      
      UD_TXT7,  -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
      UD_DTE1,  --RZKumar 06212013 -1693 Pt# B       
      UD_DTE2,  --RZKumar 06212013 -1693 Pt# B       
      UD_FLT6,      
      UD_FLT7,      
      UD_TXT8,      
      UD_TXT9,      
      UD_TXT10,      
      UD_INT1,    --RZKumar 06212013 -1693 Pt# B     
   deal_Id , -- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014

 FROM @tblCreated       
 UNION ALL       
 SELECT       
   iss_id,       
      iss_id_original,  --KAslam 04032013              
      notl,       
      notl_modified,    --KAslam 04032013             
      iss_desc,       
      purchprc,       
      mktprc,       
      currpnl,       
      inc_proj_cmb_rte,       
      ud_txt1,       
      mat_exp_dte,       
      ivvalues_ud_flt3,       
      ud_txt3,       
      local_curr_cde,       
      ivvalues_ud_flt1,       
      ivvalues_ud_flt2,       
      qual_rtg01_cde,       
      qlty_rtg,       
      fitch,       
      industry,       
      country,       
      region,       
      ud_txt2,       
      hierar,       
      gp_nme,       
      valval_alt_cmb_amt,       
      issue_cls2_nme,       
      percpf,       
      custodn_nme,       
      flag,       
      fld02_ind,       
      iss_fld2_txt,       
      tckr_sym_id,       
      deal_nme,      
      UD_TXT7,   -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
      UD_DTE1,   --RZKumar 06212013 -1693 Pt# B       
      UD_DTE2,   --RZKumar 06212013 -1693 Pt# B       
      UD_FLT6,      
      UD_FLT7,      
      UD_TXT8,      
      UD_TXT9,      
      UD_TXT10,      
      UD_INT1,     --RZKumar 06212013 -1693 Pt# B       
   deal_Id  ,  -- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014
 FROM @tblReal       
 WHERE ( notl <> ''       
      OR notl <> '0'       
      OR notl <> NULL )       
      AND ( iss_fld2_txt <> @CreditFa      
      OR iss_fld2_txt <> @CreditCo )       
 UNION ALL       
 SELECT       
  iss_id,       
  iss_id,         --KAslam 04032013              
  notl,       
  notl_modified,  --KAslam 04032013          
  iss_desc,       
  purchprc,       
  mktprc,       
  currpnl,       
  inc_proj_cmb_rte,       
  ud_txt1,       
  mat_exp_dte,       
  ivvalues_ud_flt3,       
  ud_txt3,       
    local_curr_cde,       
    ivvalues_ud_flt1,       
    ivvalues_ud_flt2,       
    qual_rtg01_cde,       
    qlty_rtg,       
    fitch,       
    industry,       
    country,       
    region,       
    ud_txt2,       
    hierar,       
    gp_nme,       
    valval_alt_cmb_amt,       
    issue_cls2_nme,       
    percpf,       
    custodn_nme,       
    flag,       
    fld02_ind,       
    iss_fld2_txt,       
    tckr_sym_id,       
    deal_nme,      
    UD_TXT7,   -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
    UD_DTE1,   --RZKumar 06212013 -1693 Pt# B       
    UD_DTE2,   --RZKumar 06212013 -1693 Pt# B       
    UD_FLT6,      
    UD_FLT7,      
    UD_TXT8,      
    UD_TXT9,      
    UD_TXT10,      
    UD_INT1,     --RZKumar 06212013 -1693 Pt# B       
    deal_Id,  -- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014
 FROM  @tblPartiallyFunded           
              
  DELETE ta       
  FROM  @tblAll TA       
        JOIN @POSL PL       
  ON ta.deal_nme = PL.deal_nme        
              
 --Changes for Forward --MSOhail -03/06/2013              
 INSERT INTO @tblAll       
     (      
      iss_id,       
      iss_id_original,  --KAslam 04032013              
      notl,       
      notl_modified,    --KAslam 04032013             
      iss_desc,       
      purchprc,       
      mktprc,       
      currpnl,       
      inc_proj_cmb_rte,       
      ud_txt1,       
      mat_exp_dte,       
      ivvalues_ud_flt3,       
      ud_txt3,       
      local_curr_cde,       
      ivvalues_ud_flt1,       
      ivvalues_ud_flt2,       
      qual_rtg01_cde,       
      qlty_rtg,       
      fitch,       
      industry,       
      country,       
      region,       
      ud_txt2,       
      hierar,       
      gp_nme,       
      valval_alt_cmb_amt,       
      issue_cls2_nme,       
      percpf,       
      custodn_nme,       
      flag,       
      fld02_ind,       
      iss_fld2_txt,       
      tckr_sym_id,       
      deal_nme,      
      UD_TXT7,   -- Added below 9 new columns NKsingh 05072013 --RZKumar 06212013 -1693 Pt# B        
      UD_DTE1,   --RZKumar 06212013 -1693 Pt# B       
      UD_DTE2,   --RZKumar 06212013 -1693 Pt# B       
      UD_FLT6,      
      UD_FLT7,      
      UD_TXT8,      
      UD_TXT9,      
      UD_TXT10,      
      UD_INT1,     --RZKumar 06212013 -1693 Pt# B       
   deal_Id   , -- ppremkumar 09122013    
	BANK_NAME ,		--KAslam 02172014
	MARKET_TRADE_TYPE_NAME	--KAslam 02172014
    )       
   SELECT       
  PS.iss_id,       
  PS.iss_id,               --KAslam 04032013             
  crvl_cmb_amt,       
  crvl_cmb_amt_unrounded,  --KAslam 04032013              
  PL.deal_nme,       
  purchprc,       
  mktprc,       
   CASE         
 WHEN currpnl IS NULL THEN currpnlPOSL      
 WHEN currpnl = 0  THEN currpnlPOSL             
  ELSE currpnl                    
   END AS currpnl,    --RZKumar 06212013 -1693 Pt# 6       
   inc_proj_cmb_rte,       
   ud_txt1,       
   PL.fld2_tms,       
   ivvalues_ud_flt3,       
   ud_txt3,       
   PL.local_curr_cde,       
   ivvalues_ud_flt1,       
   ivvalues_ud_flt2,       
   qual_rtg01_cde,       
   qlty_rtg,       
   fitch,       
   industry,       
   country,       
   region,       
   ud_txt2,       
   hierar,       
   gp_nme,       
   CASE          
  WHEN valval_alt_cmb_amt IS NULL THEN ugl_alt_cmb_amt      
  WHEN valval_alt_cmb_amt = 0  THEN ugl_alt_cmb_amt             
  ELSE valval_alt_cmb_amt                    
   END AS valval_alt_cmb_amt, --RZKumar 06212013 -1693 Pt# 6       
   issue_cls2_nme,       
   percpf,       
   custodn_nme,       
   flag,       
   fld02_ind,       
   iss_fld2_txt,       
   tckr_sym_id,       
   ps.deal_nme,      
   UD_TXT7,  -- Added below 9 new columns NKsingh 05072013   --RZKumar 06212013 -1693      
   UD_DTE1,  --RZKumar 06212013 -1693 Pt# B       
   UD_DTE2,  --RZKumar 06212013 -1693 Pt# B       
   UD_FLT6,      
   UD_FLT7,      
   UD_TXT8,      
   UD_TXT9,      
   UD_TXT10,      
   UD_INT1,   --RZKumar 06212013 -1693 Pt# B       
   PS.deal_Id, -- ppremkumar 09122013    
   PS.BANK_NAME ,		--KAslam 02172014
   PS.MARKET_TRADE_TYPE_NAME		--KAslam 02172014
 FROM @tblForward PS       
     JOIN @POSL PL       
 ON PS.iss_desc = PL.deal_nme       
  -- AND PS.id = PL.id      --VBANDI 01242014
     AND PS.deal_id = PL.deal_id		--VBANDI 01242014
  --End change for forward          
      
         
  --Changes for IRS --MSohail -03/06/2013              
 INSERT INTO @TEMPIRS       
      (      
    deal_Id,  -- ppremkumar 09122013    
       deal_nme,       
       iss_fld2_txt,       
       long_short_ind,       
       inc_proj_cmb_rte,       
       mat_exp_dte,       
       fld8_amt,       
       ud_txt3,       
       ud_txt1   ,   
	   BANK_NAME ,		--KAslam 02172014
	   MARKET_TRADE_TYPE_NAME	--KAslam 02172014
      )       
  SELECT deal_Id,  -- ppremkumar 09122013    
   deal_nme,       
      iss_fld2_txt,       
      long_short_ind,       
      inc_proj_cmb_rte,       
      mat_exp_dte,/*Maturity*/       
      fld8_amt,/*Market Value*/       
      UD_TXT3 = ( CASE       
         WHEN RTRIM(curr14_cde) = 'US0001M-INDEX'       
        AND iss_fld23_ind = 1 THEN '(-1) Libor'       
         WHEN RTRIM(curr14_cde) = 'US0001M-INDEX'       
        AND iss_fld23_ind = 0 THEN 'Libor'       
         WHEN RTRIM(curr14_cde) = 'US0003M-INDEX'       
        AND iss_fld23_ind = 1 THEN '(-1) Libor'       
         WHEN RTRIM(curr14_cde) = 'US0003M-INDEX'       
        AND ISNULL(iss_fld23_ind,0) = 0 THEN 'Libor' -- ppremkumar 09182013    
         WHEN RTRIM(curr14_cde) = 'US0006M-INDEX'       
        AND iss_fld23_ind = 1 THEN '(-1) Libor'       
         WHEN RTRIM(curr14_cde) = 'US0006M-INDEX'       
        AND iss_fld23_ind = 0 THEN 'Libor'       
         WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
        AND iss_fld23_ind = 1 THEN ''       
         WHEN RTRIM(curr14_cde) = 'EUR001M-INDEX'       
        AND iss_fld23_ind = 0 THEN ''       
         WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
        AND iss_fld23_ind = 1 THEN ''       
         WHEN RTRIM(curr14_cde) = 'EUR003M-INDEX'       
        AND iss_fld23_ind = 0 THEN ''       
         WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
        AND iss_fld23_ind = 1 THEN ''       
         WHEN RTRIM(curr14_cde) = 'EUR006M-INDEX'       
        AND iss_fld23_ind = 0 THEN ''       
         WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
        AND iss_fld23_ind = 1 THEN ''       
         WHEN RTRIM(curr14_cde) = 'BP0001M-INDEX'       
        AND iss_fld23_ind = 0 THEN ''       
         WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
        AND iss_fld23_ind = 1 THEN ''       
         WHEN RTRIM(curr14_cde) = 'BP0003M-INDEX'       
        AND iss_fld23_ind = 0 THEN ''       
         WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
        AND iss_fld23_ind = 1 THEN ''       
         WHEN RTRIM(curr14_cde) = 'BP0006M-INDEX'       
        AND iss_fld23_ind = 0 THEN ''       
         WHEN RIGHT(iss_fld2_desc, 1) = @L       
        AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Libor'       
         WHEN RIGHT(iss_fld2_desc, 1) = @L       
        AND ISNULL(iss_fld23_ind, 0) = 1 THEN '(-1) Libor'       
         WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
        AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Prime'       
         WHEN RIGHT(iss_fld2_desc, 1) IN ( 'P', 'R' )       
        AND ISNULL(iss_fld23_ind, 0) = 1 THEN '(-1) Prime'       
         WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
        AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Euribor'       
         WHEN RIGHT(iss_fld2_desc, 1) = 'E'       
        AND ISNULL(iss_fld23_ind, 0) = 1 THEN '(-1) Euribor'       
         ELSE ud_txt3       
        END ),/*OverIndex*/       
      UD_TXT1= ( CASE       
       WHEN varrte_ind = 0 THEN 'Fixed'       
       WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )       
         AND varrte_ind = 1       
         AND iss_fld23_ind = 1 THEN 'Inverse Float'       
       WHEN issue_cls2_nme IN ( 'Term Loan', 'Revolver' )       
         AND varrte_ind = 1       
         AND ISNULL(iss_fld23_ind, 0) = 0 THEN 'Float'       
       WHEN varrte_ind = 1       
         AND iss_fld23_ind = 1       
         AND curr14_cde IS NOT NULL THEN 'Inverse Float'       
       WHEN varrte_ind = 1       
         AND ISNULL(iss_fld23_ind, 0) = 0       
         AND curr14_cde IS NOT NULL THEN 'Float'       
       WHEN varrte_ind = 1       
         AND iss_fld23_ind = 1       
         AND curr14_cde IS NULL THEN 'Fixed'       
       WHEN varrte_ind = 1       
         AND ISNULL(iss_fld23_ind, 0) = 0       
         AND curr14_cde IS NULL THEN 'Fixed'       
       ELSE ''       
        END ),
	[Primary/Secondary] ,		--KAslam 02172014
	[Sole Lender/Syndicated]	--KAslam 02172014   
  FROM  dbo.positionview       
  WHERE  acct_id = @pi_acct_id       
      AND as_of_tms = @pi_as_of_tms       
      AND adjst_tms = @MAXadjst_tms            -- ppremkumar 06132013      
      AND inq_basis_num = @pi_inq_basis_num       
   AND ISS_TYP = @ISS_TYP                --ppremkumar 09122013    
--      AND issue_cls1_nme = @issue_cls1_nme   -- ppremkumar 16082013    
  ORDER  BY deal_nme,       
            iss_fld2_txt     DESC,       
            crvl_alt_cmb_amt DESC      
    
-- Added to count the Deal_ID                         --ppremkumar 09122013         
  ;WITH Count_Deal AS            
    (       
   SELECT deal_Id, count(deal_Id) OVER (PARTITION BY deal_Id) AS deal_count      -- ppremkumar 09122013     
   FROM @TEMPIRS     
 )    
    
  UPDATE @TEMPIRS       
  SET deal_count = CUT.deal_count    
  FROM @TEMPIRS TA       
       JOIN Count_Deal CUT       
    ON TA.deal_Id = CUT.deal_Id       -- ppremkumar 09122013       
    
--select '@TEMPIRS',* from @TEMPIRS    
--    
--select '@tblAll',* from @tblAll    
    
    
-- In the below CTE all the partitions are done priorly based on deal_nme but chnaged to deal_Id     
-- Also added condition based on deal count -- ppremkumar 09122013             
   ;WITH Coupon_ud_txt AS            
    (            
     SELECT deal_Id,        -- ppremkumar 09122013        
   deal_nme,             
            CASE WHEN ISS_FLD2_TXT='SwapInve' AND deal_count > 2 THEN             --ppremkumar 09122013        
                 CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind= @L             
              THEN CAST (inc_proj_cmb_rte AS DECIMAL(10,4)) ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(20) )   --KAslam 04032013      -- ppremkumar 09122013       
                  +'/'+            
                 CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind=@S            
              THEN CAST (inc_proj_cmb_rte AS DECIMAL(10,4)) ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(20))    --KAslam 04032013        -- ppremkumar 09122013       
    WHEN ISS_FLD2_TXT='SwapInve' AND deal_count <= 2 THEN                                                               --ppremkumar 09122013    
      CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind=@S THEN CAST (inc_proj_cmb_rte AS DECIMAL(10,4)) ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(20))  -- ppremkumar 09122013    
                 ELSE NULL END  AS 'Coupon' ,     
           
            CASE WHEN ISS_FLD2_TXT='SwapInve' AND deal_count > 2                      --ppremkumar 09122013    
    THEN CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind = @L            
              THEN UD_TXT1 ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(20) )       -- ppremkumar 09122013        
                 +'/'+            
                 CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind=@S            
              THEN UD_TXT1 ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(20) )       -- ppremkumar 09122013     
   WHEN ISS_FLD2_TXT='SwapInve'  AND deal_count <= 2 THEN                --ppremkumar 09122013    
      CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind=@S THEN UD_TXT1 ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(20) )        -- ppremkumar 09122013    
                 ELSE NULL END AS 'ud_txt1' ,    
            
            CASE WHEN ISS_FLD2_TXT='SwapInve' AND deal_count > 2                        --ppremkumar 09122013    
    THEN CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind= @L            
              THEN MAT_EXP_DTE ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(25))         -- ppremkumar 09122013     
   WHEN ISS_FLD2_TXT='SwapInve' AND deal_count <= 2 THEN                      --ppremkumar 09122013    
       CAST( MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind= @S THEN MAT_EXP_DTE ELSE NULL END) OVER (PARTITION BY deal_Id) AS VARCHAR(25)) -- ppremkumar 09122013    
   ELSE NULL            
                 END AS MAT_EXP_DTE  ,    
             
            SUM(FLD8_AMT) OVER (PARTITION BY deal_Id) AS FLD8_AMT,                               -- ppremkumar 09122013     
         
            CASE WHEN ISS_FLD2_TXT='SwapInve' AND deal_count > 2 THEN MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind=@L          --ppremkumar 09122013        
              THEN UD_TXT3 ELSE NULL END) OVER (PARTITION BY deal_Id)                            -- ppremkumar 09122013     
    WHEN ISS_FLD2_TXT='SwapInve' AND deal_count <= 2  THEN MAX(CASE WHEN iss_fld2_txt = 'Bond' and long_short_ind=@S       --ppremkumar 09122013        -- ppremkumar 09122013    
     THEN UD_TXT3 ELSE NULL END) OVER (PARTITION BY deal_Id)                             -- ppremkumar 09122013     
   ELSE NULL END AS UD_TXT3                                
     FROM @TEMPIRS            
     )            
            
  --Update table based on the manipulation of Common type expression.             
  UPDATE @tblAll       
  SET inc_proj_cmb_rte = CUT.coupon,       
      ud_txt1 = CUT.ud_txt1,       
      valval_alt_cmb_amt = CUT.FLD8_AMT,       
      mat_exp_dte = CUT.MAT_EXP_DTE,       
      UD_TXT3 = CUT.UD_TXT3       
  FROM @tblAll TA       
       JOIN coupon_ud_txt CUT       
    ON TA.deal_Id = CUT.deal_Id   -- ppremkumar 09122013    
      
  -- End of the IRS Change --MSohail -03/06/2013        
           
  --For all Credit Facility positions, Notl (mm), Coupon, FXD/FLT, Spread, Over [INDEX/BM] should always be blank/NULL              
  UPDATE @tblAll       
  SET notl = NULL,       
      inc_proj_cmb_rte = NULL,       
      ud_txt1 = NULL,       
      ivvalues_ud_flt3 = NULL,       
      ud_txt3 = NULL       
WHERE iss_fld2_txt = @CreditFa        
      
  --For WAL and Durn (FXD)/Sprd Durn (FLT), If blank display NA for these columns              
  UPDATE @tblAll       
  SET ivvalues_ud_flt1 = CASE       
              WHEN ivvalues_ud_flt1 IS NULL THEN 'N/A'    --RZKumar 07012013 -MDB 1693      
         ELSE ivvalues_ud_flt1       
          END,       
ivvalues_ud_flt2 = CASE       
                 WHEN ivvalues_ud_flt2 IS NULL THEN 'N/A'    --RZKumar 07012013 -MDB 1693      
         ELSE ivvalues_ud_flt2       
          END        
      
    --For MDY and SP, If blank display NA for this column, except for credit contracts, they should always be blank/NULL             
    UPDATE @tblAll             
    SET qual_rtg01_cde = CASE WHEN ( qual_rtg01_cde IS NULL OR qual_rtg01_cde = '' )             
                AND iss_fld2_txt <> @CreditCo THEN 'N/A'        --RZKumar 07012013 -MDB 1693      
         ELSE qual_rtg01_cde END,             
         qlty_rtg = CASE WHEN ( qlty_rtg IS NULL OR qlty_rtg = '' )             
                   AND iss_fld2_txt <> @CreditCo THEN 'N/A'        --RZKumar 07012013 -MDB 1693      
               ELSE qlty_rtg END             
            
  --For IRS Industry will always be N/A                
  UPDATE @tblAll       
   SET   industry = 'N/A'                    --RZKumar 07012013 -MDB 1693      
  WHERE  issue_cls2_nme = @issue_cls2_nme    -- ppremkumar 16082013    
           
          
 INSERT INTO @AngeloPos_Tmp       
  (      
  pos_id,       
  pos_id_1,       
  Item,       
  Notl_$,                   -- NKsingh 04302013                      
  notl_modified,       
  Notl_mm_modified,       
  Curr_PNL_in_USD,       
  iss_fld2_txt,       
  CUSIP_ISIN_Bank_Loan_#_Loan_X_ID,       
  Sec_Des,       
  Purch_Price_Local,       
  Mkt_Price_Local,       
  Coupon,       
  FXD_FLT,       
  Maturity,       
  Spread,       
  ud_txt3,       
  CCY_USD_EUR_other,       
  WAL,       
  Durn_FXD_Sprd_Durn_FLT,       
  MDY,       
  SP,       
  Fitch,       
  Industry,       
  Country,       
  Region,       
  H_M_L_Lqd_Illiq_Classif,   --KAslam 06032013 -1462 Pt#4 ,       
  FAS_157_ASC_820_Hierarchy,       
  GP_Name,       
  Market_Value_in_USD,       
  Asset_Class,       
  percent_of_Portfolio,       
  Custodian,       
  flag,      
  Coupon_Frequency,        -- Added 9 new columns NKsingh 05072013      
  Start_Date,      
  First_Coupon_Date,      
  Accrued_Interest,      
  Maturity_Type,      
  Recovery_Rate,      
  Debt_Type_cov_lite_LBO_1st_Lien_2nd_Lien_Unsecured,      
  Change_of_Control_Trigger,          
  Issue_Size  ,
  BANK_NAME ,		--KAslam 02172014
  MARKET_TRADE_TYPE_NAME		--KAslam 02172014       
  )       
  SELECT pos_id = CASE       
        WHEN fld02_ind = 2       
        OR ( fld02_ind = 1       
        AND iss_fld2_txt = @CreditCo ) THEN ( CASE       
                   WHEN       
        CHARINDEX('_', iss_id) > 1 THEN RTRIM(SUBSTRING(iss_id, 1,       
        CHARINDEX('_', iss_id) - 1))       
          ELSE       
        RTRIM(iss_id)       
                   END )       
        ELSE ( CASE       
           WHEN CHARINDEX('_', iss_id) > 1       
           AND iss_fld2_txt = @CreditCo THEN RTRIM(       
           SUBSTRING(iss_id, 1,       
           CHARINDEX('_', iss_id) - 1))       
           ELSE RTRIM(iss_id)       
         END )       
      END,       
       pos_id_1 = CASE       
       WHEN fld02_ind = 2       
          OR ( fld02_ind = 1       
          AND iss_fld2_txt = @CreditCo ) THEN ( CASE       
                    WHEN       
       CHARINDEX('_', iss_id_original) > 1 THEN RTRIM(       
       SUBSTRING(iss_id_original,       
       1, CHARINDEX('_',       
          iss_id_original) - 1))       
       ELSE       
       RTRIM(iss_id_original)       
                     END )       
       ELSE ( CASE       
          WHEN CHARINDEX('_', iss_id_original) > 1       
          AND iss_fld2_txt = @CreditCo THEN RTRIM(       
          SUBSTRING(iss_id_original, 1,       
          CHARINDEX('_', iss_id_original) - 1))       
          ELSE RTRIM(iss_id_original)       
           END )       
        END,       
       ROW_NUMBER()       
      OVER (       
       ORDER BY issue_cls2_nme, iss_id, flag) AS Item,       
       CASE       
     WHEN notl = '0'       
       AND iss_fld2_txt <> @CreditFa THEN '0.00'       
     WHEN notl = '0'       
       AND iss_fld2_txt = @CreditFa THEN NULL       
     ELSE notl       
       END                                        AS Notl_$,   -- NKsingh 04302013       
       notl_modified                              'notl_modified',       
       CASE       
     WHEN notl_modified = '0'       
       AND iss_fld2_txt <> @CreditFa THEN '0.00'       
     WHEN notl_modified = '0'       
       AND iss_fld2_txt = @CreditFa THEN NULL       
     ELSE notl_modified       
       END                                        AS Notl_mm_modified,       
       currpnl                                    AS Curr_PNL_in_USD,       
       iss_fld2_txt,       
       CASE       
     WHEN fld02_ind = 2       
        OR ( fld02_ind = 1       
        AND iss_fld2_txt = @CreditCo ) THEN ( CASE       
                  WHEN       
     CHARINDEX('_', iss_id) > 1 THEN RTRIM(SUBSTRING(iss_id, 1,       
                CHARINDEX('_', iss_id) - 1))       
                  ELSE RTRIM(iss_id)       
                  END ) + --NCHAR(179) --RZKumar 06212013 -1693 Pt# C       
                 (CASE       
                  WHEN       
                  iss_id = @scripts5 THEN NCHAR(179)+ ','+ NCHAR(0x2075)        
                  ELSE       
                  NCHAR(179)       
                   END)     --RZKumar 06212013 -1693 Pt# C      
                   --END ) + NCHAR(179)       
     ELSE ( CASE       
        WHEN CHARINDEX('_', iss_id) > 1       
        AND iss_fld2_txt = @CreditCo THEN RTRIM(       
        SUBSTRING(iss_id, 1,       
        CHARINDEX('_', iss_id) - 1))       
        WHEN CHARINDEX('_', iss_id) > 1       
        AND iss_fld2_txt = 'SwapInve' THEN RTRIM(iss_desc)       
        --KAslam 04032013         
        ELSE RTRIM(iss_id)       
      END )       
       END                                              
         AS   CUSIP_ISIN_Bank_Loan_#_Loan_X_ID,         
         iss_desc                                   AS Sec_Des,       
         purchprc                                   AS Purch_Price_Local,       
         mktprc                                     AS Mkt_Price_Local,       
         inc_proj_cmb_rte                           AS Coupon,       
         ud_txt1                                    AS FXD_FLT,       
         CASE       
         WHEN mat_exp_dte IS NULL THEN 'N/A'       
         ELSE CONVERT(VARCHAR(10), CONVERT(DATETIME, mat_exp_dte), 101)       
         END                                        AS Maturity,       
         ROUND(ivvalues_ud_flt3, 4)                 AS Spread,       
         ud_txt3,       
         local_curr_cde                             AS CCY_USD_EUR_other,       
         ivvalues_ud_flt1                           AS WAL,       
         ivvalues_ud_flt2                           AS Durn_FXD_Sprd_Durn_FLT,       
         qual_rtg01_cde                             AS MDY,       
         qlty_rtg                                   AS SP,       
         fitch                                      AS Fitch,       
         industry                                   AS Industry,       
         country                                    AS Country,       
         region                                     AS Region,       
         ud_txt2                                    AS H_M_L_Lqd_Illiq_Classif,    --KAslam 06032013      
         hierar                                     AS FAS_157_ASC_820_Hierarchy,       
         gp_nme                                     AS GP_Name,       
         valval_alt_cmb_amt                         AS Market_Value_in_USD,       
         issue_cls2_nme                             AS Asset_Class,       
         valval_alt_cmb_amt/@PortfolioPercentDENO   AS percent_of_Portfolio,       --RZKumar 06212013 -1693 Pt# 7      
         custodn_nme                                AS Custodian,       
         flag,      
      
         CASE WHEN UD_TXT7 IS NULL THEN 'N/A'                                     --RZKumar 06212013 -1693 Pt# B      
            --     WHEN ISS_FLD4_TXT = '1'    THEN 'Annual'                       --KAslam 06032013 --Pt#1  - 1462       
            --   WHEN ISS_FLD4_TXT = '3'    THEN 'Quarterly'      
            --     WHEN ISS_FLD4_TXT = '6'    THEN 'Semi-Annual'      
            --     WHEN ISS_FLD4_TXT = '12'   THEN 'Monthly'      
                 ELSE UD_TXT7       
         END           AS Coupon_Frequency,                                 -- Added below 9 new columns NKsingh 05072013       
      
         CASE WHEN UD_DTE1 IS NULL THEN 'N/A'                                --RZKumar 06212013 -1693 Pt# B      
                 ELSE CONVERT(VARCHAR(10), CONVERT(DATETIME, UD_DTE1), 101)         
            END           AS Start_Date,      
         
         CASE WHEN UD_DTE2 IS NULL THEN 'N/A'                                --RZKumar 06212013 -1693 Pt# B      
                 ELSE CONVERT(VARCHAR(10), CONVERT(DATETIME, UD_DTE2), 101)         
         END           AS First_Coupon_Date,      
         
         CASE WHEN UD_FLT6 IS NULL THEN 'N/A'         
                 ELSE CONVERT(VARCHAR,(CAST (UD_FLT6 AS DECIMAL(12,4))))         
         END          AS Accrued_Interest,      
      
         CASE WHEN UD_TXT8 IS NULL THEN 'N/A'         
                 ELSE CONVERT(VARCHAR,(UD_TXT8))      
         END          AS Maturity_Type,      
      
          CASE WHEN UD_FLT7 IS NULL THEN 'N/A'         
                 ELSE CONVERT(VARCHAR,(CAST (UD_FLT7 AS DECIMAL(12,4))))         
         END          AS Recovery_Rate,      
      
         CASE WHEN UD_TXT9 IS NULL THEN 'N/A'         
                 ELSE UD_TXT9 END     AS  Debt_Type_cov_lite_LBO_1st_Lien_2nd_Lien_Unsecured,      
      
         CASE WHEN UD_TXT10 IS NULL THEN 'N/A'         
            --   WHEN UD_TXT10 = 'Y' THEN 'Yes'           --KAslam 06032013 --Pt#1  - 1462       
            --      WHEN UD_TXT10 = 'N' THEN 'No'      
                 ELSE CONVERT(VARCHAR,(UD_TXT10))      
         END          AS Change_of_Control_Trigger,      
         
         CASE WHEN UD_INT1 IS NULL THEN 'N/A'             --RZKumar 06212013 -1693 Pt# B      
                 ELSE CONVERT(VARCHAR,CAST(UD_INT1 AS MONEY),1)      
         END                AS Issue_Size ,
		BANK_NAME ,			--KAslam 02172014
		MARKET_TRADE_TYPE_NAME		--KAslam 02172014
     
        
        FROM   @tblAll         
        WHERE  flag <> @F    -- ppremkumar 16082013    
        ORDER  BY issue_cls2_nme,         
                  iss_id,         
                  flag       
    
-- Logic to Suppress for those data does not have MV or Shares -- ppremkumar 16082013    
Insert into @AngeloPos_Tmp1    -- ppremkumar 16082013    
(    
  pos_id                                   
 ,CUSIP_ISIN_Bank_Loan_#_Loan_X_ID                  
)    
SELECT     
 pos_id ,CUSIP_ISIN_Bank_Loan_#_Loan_X_ID         
FROM @AngeloPos_Tmp tr WHERE Notl_$ is NULL and  Market_Value_in_USD = 0     
    
INSERT INTO @AngeloPos_Tmp2    -- ppremkumar 16082013    
(    
 pos_id,    
 CUSIP    
)    
SELECT pos_id,CUSIP_ISIN_Bank_Loan_#_Loan_X_ID    
FROM @AngeloPos_Tmp tr WHERE Notl_$ IS NOT NULL and  Market_Value_in_USD <> 0     
    
INSERT INTO @AngeloPos_Tmp3    -- ppremkumar 16082013    
(    
 pos_id,    
 CUSIP    
)    
SELECT t1.pos_id,t1.CUSIP_ISIN_Bank_Loan_#_Loan_X_ID from @AngeloPos_Tmp1 t1    
INNER JOIN @AngeloPos_Tmp2 t2 ON  t1.pos_id = t2.pos_id    
    
INSERT INTO @AngeloPos_Tmp4   -- ppremkumar 16082013    
(    
   Counter    
  ,pos_id                                                       
 ,CUSIP_ISIN_Bank_Loan_#_Loan_X_ID                 
)    
SELECT    
 COUNT(1) OVER(PARTITION BY pos_id)    
,pos_id                                                
,CUSIP_ISIN_Bank_Loan_#_Loan_X_ID         
FROM @AngeloPos_Tmp1 t2 WHERE t2.pos_id not in (SELECT pos_id FROM @AngeloPos_Tmp3 )    
    
  --final output      -- Alias name included -- ppremkumar 16082013    
SELECT           
  t2.CUSIP_ISIN_Bank_Loan_#_Loan_X_ID AS [CUSIP/ISIN/Bank Loan #/Loan X ID],          
  t2.Item,         
  CONVERT(VARCHAR(100),CAST(t2.Notl_$ AS MONEY),1) AS [Notl ($)],   --NKsingh 05062013        
  t2.Sec_Des,             
  t2.Purch_Price_Local AS [Purch Price (Local)],             
  t2.Mkt_Price_Local   AS [Mkt Price (Local)],             
  CASE         
     WHEN t2.Curr_PNL_in_USD IS NULL THEN (notl_modified*(SELECT TOP 1 Curr_PNL_in_USD        
                FROM @AngeloPos_Tmp         
                WHERE pos_id_1 = t2.pos_id_1         
                AND iss_fld2_txt=@CreditFa))/      
                                                          (SELECT CASE       
                                                                   WHEN SUM(CONVERT(FLOAT, notl_modified)) =0 --KAslam 04092013 - Applied case to avoid divide by zero        
                THEN 1        
                 ELSE SUM(CONVERT(FLOAT, notl_modified))        
                END         
               FROM @AngeloPos_Tmp        
               GROUP BY pos_id_1        
                  HAVING pos_id_1 = t2.pos_id_1)        
  WHEN t2.iss_fld2_txt = @CreditFa THEN NULL        
  ELSE t2.Curr_PNL_in_USD         
  END AS [Curr PNL(in USD)],  --[Curr PNL(in USD)] ,            
  CASE         
  WHEN ISNUMERIC(t2.Coupon) = 1 THEN CAST(CAST (t2.Coupon AS DECIMAL(10,4)) AS VARCHAR(100))        
  ELSE  t2.Coupon         
  END 'Coupon',         
  t2.FXD_FLT AS [FXD/FLT],             
  t2.Maturity,             
  t2.Spread,             
  t2.ud_txt3 AS 'Over [INDEX/BM]',             
  t2.CCY_USD_EUR_other AS [CCY (USD/EUR/other)],             
  t2.WAL,             
  t2.Durn_FXD_Sprd_Durn_FLT AS [Durn (FXD)/Sprd Durn (FLT)],            
  t2.MDY,             
  t2.SP,             
  t2.Fitch,             
  t2.Industry,             
  t2.Country,             
  t2.Region,                    
  t2.FAS_157_ASC_820_Hierarchy AS [FAS 157/ASC 820 Hierarchy],      -- NKsingh 04302013 inter change the position of fields [FAS 157/ASC 820 Hierarchy] & [H/M/L]      
  t2.H_M_L_Lqd_Illiq_Classif   AS [H/M/L or Lqd/Illiq Classif],     --KAslam 06032013 -1462 Pt#4       
  t2.Coupon_Frequency          AS [Coupon Frequency],    -- Added below 9 new columns NKsingh 05072013      
  t2.Start_Date                AS [Start Date],      
  t2.First_Coupon_Date         AS [First Coupon Date],      
  t2.Accrued_Interest          AS [Accrued Interest],      
  t2.Maturity_Type             AS [Maturity Type],       
  t2.Recovery_Rate             AS [Recovery Rate],      
  t2.Debt_Type_cov_lite_LBO_1st_Lien_2nd_Lien_Unsecured AS [Debt Type (cov lite, LBO, 1st Lien, 2nd Lien, Unsecured)],      
  t2.Change_of_Control_Trigger                          AS [Change of Control Trigger],      
  t2.Issue_Size                AS [Issue Size],
  t2.BANK_NAME				   AS [Primary/Secondary],			--KAslam 02172014
  t2.MARKET_TRADE_TYPE_NAME	   AS [Sole Lender/Syndicated],		--KAslam 02172014                 
  t2.GP_Name                   AS [GP Name],   
  t2.Market_Value_in_USD       AS [Market Value(in USD)],             
  t2.Asset_Class               AS [Asset Class],             
  t2.percent_of_Portfolio      AS [% of Portfolio],             
  t2.Custodian,             
  t2.flag             
 FROM  @AngeloPos_Tmp t2   --Left Outer join @AngeloPos_Tmp4 t4 on  t4.pos_id = t2.pos_id    
WHERE t2.pos_id not in (SELECT t4.pos_id FROM @AngeloPos_Tmp4 t4 WHERE t4.Counter = 1) -- ppremkumar 16082013    
            
  --Detail Positions and P&L                      
  --Total Notional           
            
 SELECT CONVERT(VARCHAR(100),CAST( SUM(CONVERT(DECIMAL(13, 4), notl)) AS MONEY),1) AS 'Notl ($)'  -- NKsingh 05062013 change mm to $       
 FROM   @tblAll --KAslam - 10/05/2012         
               
  --Invested Cash                 --KAslam 06032013 --1462 Pt#2 - Commented the logic.        
--  SELECT SUM(p.valval_alt_cmb_amt / 1000000) AS 'Notl (mm)'       
--  FROM   dbo.positionview p       
--  WHERE  p.acct_id = @pi_acct_id       
--      AND p.as_of_tms = @pi_as_of_tms       
--      AND p.adjst_tms = (SELECT MAX(adjst_tms)   --KAslam 04092013_2 - Added max to ignore duplicate        
--          FROM   dbo.positionview                  
--          WHERE  acct_id = @pi_acct_id       
--           AND inq_basis_num = @pi_inq_basis_num       
--           AND as_of_tms = @pi_as_of_tms)       
--      AND p.inq_basis_num = @pi_inq_basis_num       
--      AND ( p.ldgr_id = @LedgerId19       
--   OR p.ldgr_id = @LedgerId9999 )       
--  GROUP  BY issue_cls1_nme             
            
 SELECT DIV_DIST_SHS AS 'Notl (mm)'     --KAslam 06032013 --1462 Pt#2 -       
   FROM dbo.navview          
  WHERE bk_id = @bk_idpe         
    AND acct_id = @PE_ACCTID          
    AND as_of_tms = @pi_as_of_tms          
    AND inq_basis_num = @pi_inq_basis_num      
      
      --Data for Transactions section                     
      --Funding Amount            
   --Commented the logic, to implement the new logic for JIRA #1693 pt# A --RZKumar 06212013 -1693 Pt# A       
--      SELECT 'Funding Amount'             
--             + CAST(Row_number() OVER (ORDER BY end_tms) AS VARCHAR(100)),             
--             '',             
--             ud_flt1,             
--             CONVERT(CHAR(10), end_tms, 101) 'Date'             
--      FROM   dbo.accounts_total_sei             
--      WHERE  acct_id = @PE_ACCTID             
--         AND end_tms < @pi_as_of_tms             
--         AND ud_flt1 IS NOT NULL             
--      ORDER BY convert(datetime, end_tms,1)    --KAslam 06032013 --1462  Pt#3 -           
      
--implemented the new logic for JIRA #1693 pt# A --RZKumar 06212013 -1693 Pt# A       
    
  INSERT INTO @Fund_Amt                                   --RZKumar 07012013 -MDB 1693      
    (      
      FundingAmount,    
      Date     
     )    
  SELECT ABS (SUM(FLD3_CMB_AMT)) AS FundingAmount,       --RZKumar 07012013 -MDB 1693      
        CONVERT(CHAR(10), EFF_POST_TMS, 101) AS Date      
  FROM dbo.TRANEVENT_DG      
  WHERE ACCT_ID = @PE_ACCTID       
     AND TRD_BRKR_NME = @TRDBRKRNMEcapital      
     AND TRN_CDE = @TRNCDEcon      
  GROUP BY EFF_POST_TMS      
  ORDER BY CONVERT(DATETIME, EFF_POST_TMS,1)     
    
  SELECT 'Funding Amount' + CAST(Row_number() OVER (ORDER BY EFF_POST_TMS) AS VARCHAR(100)),  --NKsingh 06142013 -1693 pt# A      
     '',      
     ABS (SUM(FLD3_CMB_AMT)) 'Funding Amount',           --RZKumar 07012013 -MDB 1693      
     CONVERT(CHAR(10), EFF_POST_TMS, 101) 'Date'     
  FROM dbo.TRANEVENT_DG      
  WHERE ACCT_ID = @PE_ACCTID       
     AND TRD_BRKR_NME = @TRDBRKRNMEcapital      
     AND TRN_CDE = @TRNCDEcon      
  GROUP BY EFF_POST_TMS      
  ORDER BY CONVERT(DATETIME, EFF_POST_TMS,1)     
    
--select '#temp231',* from #temp231       
    
SELECT sum(abs(FundingAmount)) AS summ FROM @Fund_Amt    --RZKumar 07012013 -MDB 1693      
            
      --Sum of Transactions                     
      -- Total Funded Amount                   
--      SELECT SUM(ABS(ud_flt1)) 'summ'             
--      FROM   dbo.accounts_total_sei             
--      WHERE  acct_id = @PE_ACCTID             
--         AND end_tms < @pi_as_of_tms             
            
      --MTM As 0f Date                   
      --PPremkumar -11/06/2012          --NKsingh 06142013 commented for JIRA #1693      
--      SELECT ( SUM(valval_cmb_amt) - SUM(fld16_amt) ) 'summ'             
--      FROM   dbo.positionview             
--      WHERE  acct_id = @PE_ACCTID             
--         AND as_of_tms = @pi_as_of_tms             
--         AND adjst_tms = @MAXadjst_tms           -- ppremkumar 06132013      
--         AND inq_basis_num = @pi_inq_basis_num             
--      GROUP  BY acct_id       
      
   SELECT SUM (prior_tot_net_assts_val) AS MTM -- NKsingh 06032013 Added for pt# 9 of ticket 1462           --ppremkumar 09122013    
   FROM dbo.NAVVIEW                 
   WHERE acct_id = @PE_ACCTID      
   AND AS_OF_TMS = @pi_as_of_tms       
            
  END TRY             
            
  BEGIN CATCH             
         
         SET  @errno    =  Error_number()             
         SET  @errmsg   = 'Error in dbo.p_SEI_AngeloPosition : '+ Error_message()             
         SET  @errsev   =  Error_severity()             
         SET  @errstate =  Error_state()             
            
      RAISERROR(@errmsg,@errsev,@errstate);             
  END CATCH         
END    
