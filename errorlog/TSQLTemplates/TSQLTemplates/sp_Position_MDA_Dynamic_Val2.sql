
 DECLARE     @acct_id CHAR(12)
	,@bk_id CHAR(4)
	,@org_id CHAR(4)
	,@inq_basis_num INT = 1
	,@start_tms DATETIME = NULL
	,@start_adjst_tms DATETIME = NULL
	,@end_tms DATETIME = NULL
	,@end_adjst_tms DATETIME = NULL
	,@cls_set_id CHAR(8) = 'DIM'
	,@date_typ_num INT = 1
	,@adjust_ind INT = 0
	,@inq_num INT = 1
	,@qry_num INT = 1
	,@pselect_txt VARCHAR(4000) = NULL
	,@porderby_txt VARCHAR(1000) = NULL
	,@pfilter_txt VARCHAR(1000) = NULL
	,@pgroupby_txt VARCHAR(1000) = NULL
	,@row_limit INT = 0
	,@val_curr_cde CHAR(3) = NULL

	--<acct_id></acct_id><bk_id></bk_id><org_id>GUSR</org_id><inq_basis_num>1</inq_basis_num><start_tms></start_tms><start_adjst_tms></start_adjst_tms><end_tms></end_tms><end_adjst_tms></end_adjst_tms><cls_set_id></cls_set_id><date_typ_num>1</date_typ_num><adjust_ind>0</adjust_ind><inq_num>17892</inq_num><qry_num>17892</qry_num><pselect_txt></pselect_txt><porderby_txt></porderby_txt><pfilter_txt></pfilter_txt><pgroupby_txt></pgroupby_txt><row_limit>0</row_limit><val_curr_cde></val_curr_cde>
SET  @acct_id  = 'WHVALLIPC'
set @bk_id  = 'GUSR'
set @org_id= 'GUSR'
set @inq_basis_num  = 1
set @start_tms   = '2014-10-27 23:59:59'
 
set @end_tms   = '2014-10-27 23:59:59'
 
set @cls_set_id   = 'NAM-P'
set @date_typ_num  = 1
set @adjust_ind   = 0
set @inq_num   = 17892
set @qry_num   = 17892
set @pselect_txt   = NULL
set @porderby_txt   = NULL
set @pfilter_txt   = NULL
set @pgroupby_txt  = NULL
set @row_limit   = 0
 
/*
* Copyright: This information constitutes the exclusive property of SEI
* Investments Company, and constitutes the confidential and proprietary
* information of SEI Investments Company.  The information shall not be
* used or disclosed for any purpose without the written consent of SEI 
* Investments Company.       
================================================================================                        
*** vendor supplied proc                     
==============================================================================  */
/*****************************************************************************                          
** Procedure Name: sp_Position_MDA_Dynamic_Val2                          
** File Name     : sp_Position_MDA_Dynamic_Val2.sql                          
** Author        : BTM                                   
** Date          : 04/15/2002                          
** Synopsis      : Based on sp_Position_MDA_Dynamic.                          
**               : Functionally extended to support Citibank's Fund Accounting                          
**               : requirements.                          
**               :                          
** Chg History   : SS 05/16/02  - @val_curr_cde is changed to nullable type                           
**               : BTM 05/21/02 - Allow for Multiple Currency Codes in Group Accounts                          
**               :                when computing %Mkt Ratio.                          
**   : MP  7/11/02   Locking hint specified                          
**          : SZ 05/01/03 change suser_sname() to dbo.fndw_appuser()                          
**   : SZ 06/12/03 append FMT_END_TMS for custom date                          
**   : MP 09/17/03 row_limit added for standardization                          
**   : SZ 11/19/04 Fix for inner join column filter problem                          
**   : SZ 06/07/05 start_tms should not append FMT_END_TMS                          
**  BR 20060605 (Optimization)                          
**    Store dbo.fndw~appuser() function result to variable for later comparisons                          
**    Replace User<Views> with <Views>                          
--               : SS 01/11/07 Fix for data selection when multiple classification sets present                          
--               : SS 07/16/07 Removed class set id filter on DG Control record selection to eliminate anamoly                          
--                       data selection when multiple class dg records are stored in CLASSIF_DG.  This change requires                          
--                       that DG Control class set id will no longer be used for any selection.  Additional classification records                          
--                       should be loaded only through 'Class DG Loader' and not as 2nd set of positions.                    
--MC  07212011 Added Accrued Interest Column.              
--MC  12282011 UPDATED THE LOGIC FOR GROUP ACCOUNT FORMULAS       
--MChawla   04292013 Replaced the select statment for Tracking Report  - added error handling    
--MChawla   02282014 Per Jira Ticket MDB-3548 Formatted entire procedure per SEI standards 
--VBANDI	03262014 usage of sp_executesql expects parameter of type nvarchar Tag-- VBANDI 03262014
--Mchawla	04112014 Per Jira Ticket#MDB-4148 Tag:Mchawla	04112014
--Mchawla	09032014 Per Jira Ticket#MDB-5572 remvoed old tags and comments Tag:Mchawla	09032014
--VBANDI  09052014 Removed nolock table hints and added indexes Tag --VBANDI 09052014
--vperala   09192014 Removed count(*) and added sum(1) to fix MDB-5479;
					 Added fully qualified name; --vperala 09192014
--MChawla	09252014	Per Jira Ticket#5572
--Mchawla	10132014	Per Jira Ticket# MDB-5479
          
*****************************************************************************/

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ErrSeverity INT;
DECLARE @ReturnCode INT;
DECLARE @errno INT;
DECLARE @msg VARCHAR(200);
DECLARE @DATA_GRP_DEF_ID CHAR(8);
DECLARE @USER_ID CHAR(4);
DECLARE @codeset_type_id SMALLINT;
DECLARE @from_prc_curr_cde CHAR(3)
	,@prc_curr_cde CHAR(3)
	,@prc_tms DATETIME
	,@prc_typ CHAR(8)
	,@prc_exch_mnem CHAR(8)
	,@prc_srce_typ CHAR(8)
	,@prcng_meth_typ CHAR(8)
	,@prc_valid_typ CHAR(8)
	,@sys_pref_ccy_cde CHAR(3);
DECLARE @l_debug_flag INT; -- 0 = Do Not Print Debug Messages                          
	
DECLARE
	@cnt_check VARCHAR(40);
DECLARE @AppUser CHAR(8);
DECLARE @acct_type CHAR(1)
	,@valid_ind INT
	,@tmp_start_tms DATETIME
	,@tmp_end_tms DATETIME
	,@max_inq_basis INT
	,@alt_curr_cde CHAR(3)
	,@curr_cde CHAR(3)
	,@curr_ctr INT;
DECLARE @getCondition VARCHAR(8000);
DECLARE @originator_id CHAR(6);
DECLARE
	
	@sql_txt1 NVARCHAR(4000)
	,@filter_txt1 VARCHAR(1000)
	,@sort_txt1 VARCHAR(1000)
	,@grp_txt1 VARCHAR(1000);           
	
	DECLARE @GRAND_TOTAL FLOAT;  
	DECLARE @PARAMDEF NVARCHAR(40); 
	DECLARE @Iss_type CHAR(3);
	DECLARE @SQL_TXT2  nvarchar(4000);

	SET @Iss_type = 'FND';
	SET @PARAMDEF = '@GRAND_TOTAL FLOAT'; 

/*-------------------------Drop temp tables-------------------------------------------*/
    
IF OBJECT_ID('tempdb..#IVWTemp2') IS NOT NULL
	DROP TABLE #IVWTemp2;

IF OBJECT_ID('tempdb..#IVWEndTms') IS NOT NULL
	DROP TABLE #IVWEndTms;

IF OBJECT_ID('tempdb..#IVWTemp') IS NOT NULL
	DROP TABLE #IVWTemp;

IF OBJECT_ID('tempdb..#IVWTemp4') IS NOT NULL
	DROP TABLE #IVWTemp4;

IF OBJECT_ID('tempdb..#FXRate') IS NOT NULL
	DROP TABLE #FXRate;
IF OBJECT_ID('tempdb..#templedger') IS NOT NULL 
    drop table #templedger;


    	CREATE TABLE #templedger(
	templedger int identity (1,1) not null primary key
	,ACCT_ID char(12),
	 BK_ID char(2),
	 ORG_ID char(3), 
	 INQ_BASIS_NUM int,
	 AS_OF_TMS datetime,
	 LDGR_NME varchar(150)  

	)
	CREATE INDEX templedger_ldger ON  #templedger (LDGR_NME)  
/*-------------------------Create temp tables-------------------------------------------*/
CREATE TABLE #IVWTemp2 (
	ACCT_ID CHAR(12)
	,BK_ID CHAR(4)
	,ORG_ID CHAR(4)
	,END_TMS DATETIME
	,END_ADJST_TMS DATETIME PRIMARY KEY (
		acct_id
		,bk_id
		,org_id
		,end_tms
		,end_adjst_tms
		)
	);

CREATE TABLE #IVWEndTms (
	ACCT_ID CHAR(12)
	,BK_ID CHAR(4)
	,ORG_ID CHAR(4)
	,END_TMS DATETIME
	,INQ_BASIS_NUM INT
	,CLS_SET_ID CHAR(8) PRIMARY KEY (
		acct_id
		,bk_id
		,org_id
		,end_tms
		,inq_basis_num
		,cls_set_id
		)
	);

CREATE TABLE #IVWTemp (
	ACCT_ID CHAR(12) NULL
	,BK_ID CHAR(4) NULL
	,ORG_ID CHAR(4) NULL
	,INQ_BASIS_NUM INT NULL
	,CLS_SET_ID CHAR(10) NULL
	,DATA_GRP_CTL_NUM INT PRIMARY KEY
	,END_TMS DATETIME NULL
	,END_ADJST_TMS DATETIME NULL
	,A_ACCT_VALVAL_ALT_AMT FLOAT NULL
	,A_ACCT_EQTVAL_ALT_AMT FLOAT NULL
	,A_ACCT_FIVAL_ALT_AMT FLOAT NULL
	,A_ACCT_CURBAL_ALT_AMT FLOAT NULL
	,A_ACCT_NPRVAL_ALT_AMT FLOAT NULL
	,A_ACCT_CRVL_ALT_AMT FLOAT NULL
	,A_ACCT_COVL_ALT_AMT FLOAT NULL
	,A_ACCT_UGL_ALT_AMT FLOAT NULL
	,A_ACCT_UGLCUR_ALT_AMT FLOAT NULL
	,A_ACCT_UGLINV_ALT_AMT FLOAT NULL
	,A_ACCT_EAI_ALT_AMT FLOAT NULL
	,A_ACCT_ACCRINC_ALT_AMT FLOAT NULL
	);
	
CREATE TABLE #IVWTemp4 (
    ivwtemp4_ID INT IDENTITY(1, 1) NOT NULL
	,END_TMS DATETIME NOT NULL
	,ACCT_ID VARCHAR(12) NULL
	,ACCT_VALVAL_ALT_AMT FLOAT NULL
	,ACCT_EQTVAL_ALT_AMT FLOAT NULL
	,ACCT_FIVAL_ALT_AMT FLOAT NULL
	,ACCT_CURBAL_ALT_AMT FLOAT NULL
	,ACCT_NPRVAL_ALT_AMT FLOAT NULL
	,ACCT_CRVL_ALT_AMT FLOAT NULL
	,ACCT_COVL_ALT_AMT FLOAT NULL
	,ACCT_UGL_ALT_AMT FLOAT NULL
	,ACCT_UGLCUR_ALT_AMT FLOAT NULL
	,ACCT_UGLINV_ALT_AMT FLOAT NULL
	,ACCT_EAI_ALT_AMT FLOAT NULL
	,ACCT_VALVAL_ALT2_AMT FLOAT NULL
	,ACCT_EQTVAL_ALT2_AMT FLOAT NULL
	,ACCT_FIVAL_ALT2_AMT FLOAT NULL
	,ACCT_CURBAL_ALT2_AMT FLOAT NULL
	,ACCT_NPRVAL_ALT2_AMT FLOAT NULL
	,ACCT_CRVL_ALT2_AMT FLOAT NULL
	,ACCT_COVL_ALT2_AMT FLOAT NULL
	,ACCT_UGL_ALT2_AMT FLOAT NULL
	,ACCT_UGLCUR_ALT2_AMT FLOAT NULL
	,ACCT_UGLINV_ALT2_AMT FLOAT NULL
	,ACCT_EAI_ALT2_AMT FLOAT NULL
	,ACCT_ACCRINC_ALT2_AMT FLOAT NULL
	,ACCT_ACCRINC_ALT_AMT FLOAT NULL
	PRIMARY KEY (
			ivwtemp4_ID
			,end_tms
			)
	);
	
CREATE TABLE #FXRate (
	FXRate_ID INT IDENTITY(1, 1) NOT NULL
	,ISS_PRC_NUM NUMERIC(12, 0) NULL
	,INSTR_ID CHAR(16) NOT NULL
	,PRC_TMS DATETIME NULL
	,PRC_TYP CHAR(8) NULL
	,PRC_SRCE_TYP CHAR(8) NULL
	,PRCNG_METH_TYP CHAR(8) NULL
	,PRC_EXCH_MNEM CHAR(8) NULL
	,FROM_PRC_CURR_CDE CHAR(3) NULL
	,PRC_CURR_CDE CHAR(3) NULL
	,PRC_QUOTE_AMT FLOAT NULL
	,PRC_LO_AMT FLOAT NULL
	,PRC_HI_AMT FLOAT NULL
	,PRC_VALID_TYP CHAR(8) NULL
	,TRD_VOL_AMT FLOAT NULL
	,SPLT_ADJ_RTE FLOAT NULL
	,X_RATE_SCALE_RTE FLOAT NULL
	,PRC_MLTPLR_RTE FLOAT NULL
	,FX_DM_TYP CHAR(8) NULL
	,DLD_CMPLTN_TMS DATETIME NULL
	,ADJ_FX_RATE FLOAT NULL
	,ADJ_FX_RATE1 FLOAT NULL
	,ADJ_FX_RATE2 FLOAT NULL PRIMARY KEY (
		FXRate_ID
		,INSTR_ID
		)
	);

SET @l_debug_flag = 0;
SET @errno = 0;
SET @ErrSeverity = 0;
SET @DATA_GRP_DEF_ID = 'POSITION';-- type of data
SET @sql_txt1 = ' ';
SET @filter_txt1 = ' ';
SET @sort_txt1 = ' ';
SET @grp_txt1 = ' ';
SET @getCondition = '';
SET @USER_ID = 'HOST';-- session id  
SET @prc_typ = 'SPOT';
SET @prc_exch_mnem = 'CURRENCY';
SET @prc_srce_typ = 'REUTERS';
SET @prcng_meth_typ = 'CURRENCY';
SET @prc_valid_typ = 'NOAUDIT';
SET @sys_pref_ccy_cde = 'CHF';
SET @originator_id = 'GENEVA'; -- Originator id 
SET @codeset_type_id = 11;

BEGIN TRY   

	--CHECKING FOR SQL INJECTION     
	IF (
			dbo.Fn_ntk_sqlsanitizer(@pselect_txt) = 1
			OR dbo.Fn_ntk_sqlsanitizer(@pfilter_txt) = 1
			OR dbo.Fn_ntk_sqlsanitizer(@pgroupby_txt) = 1
			OR dbo.Fn_ntk_sqlsanitizer(@porderby_txt) = 1
			)
	BEGIN
		PRINT 'SQL SCRIPT IS INJECTED';

		SELECT 'injetced '
			--GOTO ERR   -- keeps style of other          
	END;

	SELECT @pselect_txt = REPLACE(@pselect_txt, '(dbo.fndw_GET_MARKETVALUE(A.ACCT_ID,A.AS_OF_TMS,A.INQ_BASIS_NUM))', '@Grand_total' ); --MChawla	09252014

	
	--For Long                       
	SELECT @pselect_txt = REPLACE(@pselect_txt, 'sum(((1 + (( sum(case when LONG_SHORT_IND = ''L'' then valval_alt_cmb_amt else 0 end) -sum(VALVAL_ALT_CMB_AMT))/ nullif(sum(VALVAL_ALT_CMB_AMT),0))))*100)', '((1 + (( sum(case when LONG_SHORT_IND = ''L'' then
 valval_alt_cmb_amt else 0 end) -sum(VALVAL_ALT_CMB_AMT))/ nullif(sum(VALVAL_ALT_CMB_AMT),0))))*100');

	--For Short                       
	SELECT @pselect_txt = REPLACE(@pselect_txt, 'sum(((1 + (( sum(case when LONG_SHORT_IND = ''S'' then valval_alt_cmb_amt else 0 end) -sum(VALVAL_ALT_CMB_AMT))/ nullif(sum(VALVAL_ALT_CMB_AMT),0))))*100)', '((1 + (( sum(case when LONG_SHORT_IND = ''S'' then 
valval_alt_cmb_amt else 0 end) -sum(VALVAL_ALT_CMB_AMT))/ nullif(sum(VALVAL_ALT_CMB_AMT),0))))*100');

	--For Cash                       
	SELECT @pselect_txt = REPLACE(@pselect_txt, 'sum(((1 + (( sum(case when ldgr_nme is not null then valval_alt_cmb_amt else 0 end) -sum(VALVAL_ALT_CMB_AMT))/ nullif(sum(VALVAL_ALT_CMB_AMT),0))))*100)', '((1 + (( sum(case when ldgr_nme is not null then valv
al_alt_cmb_amt else 0 end) -sum(VALVAL_ALT_CMB_AMT))/ nullif(sum(VALVAL_ALT_CMB_AMT),0))))*100');

	--For Track Record Report                       
	SELECT @pselect_txt = REPLACE(@pselect_txt, 'sum((case when cast(A.fld11_ind as float) = 0 then 0 else sum(cast(A.fld09_ind as decimal))/sum(cast(A.fld11_ind as decimal)) end))', '((case when sum(cast(A.fld11_ind as float)) = 0 then 0 else sum(cast(A.fld
09_ind as decimal))/sum(cast(A.fld11_ind as decimal)) end))');

	SELECT @pselect_txt = REPLACE(@pselect_txt, 'sum(((cast(A.fld09_ind as decimal)) / case when sum(cast(A.fld11_ind as decimal)) > avg(A.acctud_flt1) then avg(A.acctud_flt1) else sum(cast(A.fld11_ind as decimal)) end))', '(case when sum(cast(A.fld11_ind as
 decimal)) = 0 then 0 when avg(A.acctud_flt1) = 0 then 0  else sum(cast(A.fld09_ind as decimal))/ 
      (case when sum(cast(A.fld11_ind as decimal)) > avg(A.acctud_flt1) then avg(A.acctud_flt1) else sum(cast(A.fld11_ind as decimal)) end) end)');

	SET @pselect_txt = REPLACE(@pselect_txt,'A.ISSUER_TCKR','(LEFT(A.TCKR_SYM_ID, charindex('' '', A.TCKR_SYM_ID) - 1))');  
	SET @pgroupby_txt = REPLACE(@pgroupby_txt,'A.ISSUER_TCKR','(LEFT(A.TCKR_SYM_ID, charindex('' '', A.TCKR_SYM_ID) - 1))');
	SET @porderby_txt = REPLACE(@porderby_txt,'A.ISSUER_TCKR','(LEFT(A.TCKR_SYM_ID, charindex('' '', A.TCKR_SYM_ID) - 1))'); 
	
	
	
	--Check if is a valid account                              
	EXEC @ReturnCode = dbo.sp_UserAccount @ACCT_ID = @acct_id
		,@ORG_ID = @org_id
		,@BK_ID = @bk_id
		,@Valid = @Valid_ind OUTPUT;


		
	IF @ReturnCode <> 0
	BEGIN
		SET @msg = 'Unable to check Account information ReturnCode=' + CAST(@errno AS VARCHAR(12));

		RAISERROR (
				@msg
				,16
				,1
				);
	END;
	
	
	
	IF @Valid_ind = 0
		SELECT 'return o'

		
			
	-- Store function result to a variable so the function does not                           
	--   need to be re-evaluated (to optimize queries)                          
	SET @AppUser = dbo.fndw_appuser();

	
	
	--Check what type of account I= individual G= Group                           
	SELECT @acct_type = ACCT_GRP_TYP
		,@alt_curr_cde = ALT_CURR_CDE
	FROM dbo.IVW_ACCT
	WHERE (
			USER_ID = @USER_ID
			OR USER_ID = @AppUser
			)
		AND ACCT_ID = @acct_id
		AND BK_ID = @bk_id
		AND ORG_ID = @org_id;

	IF @acct_type IS NULL
		SELECT 'acct_type'

	-- Except for Custom Date type find out the dates to be used for selection                           
	IF @date_typ_num NOT IN (
			6
			,12
			,13
			,14
			)
	BEGIN
		EXEC @ReturnCode = dbo.sp_DateType_GetDates @ACCT_ID = @acct_id
			,@BK_ID = @bk_id
			,@ORG_ID = @org_id
			,@acct_type = @acct_type
			,@inq_basis_num = @inq_basis_num
			,@cls_set_id = @cls_set_id
			,@date_typ_num = @date_typ_num
			,@data_grp_def_id = @DATA_GRP_DEF_ID
			,@date_1 = @tmp_start_tms OUTPUT
			,@date_2 = @tmp_end_tms OUTPUT;

		IF @ReturnCode <> 0
		BEGIN
			SET @msg = 'Unable to Return dates for a given date type number ReturnCode=' + CAST(@errno AS VARCHAR(12));

			RAISERROR (
					@msg
					,16
					,1
					);
		END;

		SET @start_tms = @tmp_start_tms;
		SET @end_tms = @tmp_end_tms;
	END;
	ELSE -- Custom Date                          
	BEGIN
		IF @end_tms IS NOT NULL
			SELECT @end_tms = convert(CHAR(11), @end_tms, 101) + FMT_END_TMS
			FROM dbo.system;
	END;


	-- Log Usage Statistics                           
	-- Perform Alternate Currency Evaluation - Populate the #FXRate table with                          
	-- Currency Conversion Rates Between the Account CCY and the Valuation CCY.                          
	-- For Group Accounts, There Will Be One Row in the Table for each Distinct                          
	-- CCY in the Participant Accounts.                          
	-- Set Parameter Values for Exchange Rate Lookup                          
	SET @prc_tms = @end_tms;

	-- If Valuation Currency is Not Passed, Use the Account Reference Currency                          
	-- as the Validation Currency                          
	IF @val_curr_cde IS NULL
		OR @val_curr_cde = ''
	BEGIN
		IF @acct_type = 'I'
			SET @val_curr_cde = @alt_curr_cde;

		-- For a Group Account, If the Reference Currency is Not the Same for All                          
		-- Members, Use 'USD' as the Valuation Currency                          
		IF @acct_type = 'G'
			OR @acct_type = 'U'
		BEGIN
			SELECT @curr_ctr = count(DISTINCT ALT_CURR_CDE)
				,@curr_cde = Max(ALT_CURR_CDE)
			FROM dbo.IVW_ACCT A
			INNER JOIN dbo.AcctGroupView AGV ON AGV.ACCT_ID = A.ACCT_ID
				AND AGV.BK_ID = A.BK_ID
				AND AGV.ORG_ID = A.ORG_ID
			WHERE AGV.GRP_ACCT_ID = @acct_id
				AND AGV.GRP_BK_ID = @bk_id
				AND AGV.GRP_ORG_ID = @org_id;

			IF @curr_ctr = 1
				SET @val_curr_cde = @curr_cde;
			ELSE
				SET @val_curr_cde = 'USD';
		END;
	END;

                     
	EXEC @ReturnCode = dbo.Sp_fxrate_select @acct_id = @acct_id
		,@bk_id = @bk_id
		,@org_id = @org_id
		,@from_prc_curr_cde = @from_prc_curr_cde
		,@prc_curr_cde = @prc_curr_cde
		,@prc_tms = @prc_tms
		,@prc_typ = @prc_typ
		,@prc_exch_mnem = @prc_exch_mnem
		,@prc_srce_typ = @prc_srce_typ
		,@prcng_meth_typ = @prcng_meth_typ
		,@prc_valid_typ = @prc_valid_typ
		,@val_ccy_cde = @val_curr_cde
		,@sys_pref_ccy_cde = @sys_pref_ccy_cde;

	IF (@ReturnCode <> 0)
	BEGIN
		SET @msg = 'Unable to Return dates for a given date type number ReturnCode=' + cast(@returncode AS VARCHAR(12));

		RAISERROR (
				@msg
				,16
				,1
				);
	END;

	IF @acct_type = 'I'
	BEGIN
		SET @max_inq_basis = @inq_basis_num; -- set default value                          

		IF @inq_basis_num = 0
		BEGIN
			SELECT @max_inq_basis = Max(DG.INQ_BASIS_NUM)
			FROM dbo.DG_CONTROL DG 
			WHERE DG.ACCT_ID = @acct_id
				AND DG.BK_ID = @bk_id
				AND DG.ORG_ID = @org_id
				AND DG.END_TMS = @end_tms
				AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID;
		END;

		IF @date_typ_num IN (
				12
				,13
				,14
				)
		BEGIN
			IF @date_typ_num = 12
			BEGIN
				INSERT INTO #IVWEndTms (
					ACCT_ID
					,BK_ID
					,ORG_ID
					,END_TMS
					,INQ_BASIS_NUM
					,CLS_SET_ID
					)
				SELECT DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,max(DG.END_TMS)
					,INQ_BASIS_NUM
					,CLS_SET_ID
				FROM dbo.DG_CONTROL DG
				WHERE DG.ACCT_ID = @ACCT_ID
					AND DG.BK_ID = @bk_id
					AND DG.ORG_ID = @org_id
					AND DG.INQ_BASIS_NUM = @INQ_BASIS_NUM
					AND DG.END_TMS <= @end_tms
					AND DG.END_TMS >= @start_tms
					AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
				GROUP BY DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,INQ_BASIS_NUM
					,CLS_SET_ID
					,datepart(yy, DG.end_tms)
					,datepart(mm, DG.end_tms);
			END;
			ELSE IF @date_typ_num = 13
			BEGIN
				INSERT INTO #IVWEndTms (
					ACCT_ID
					,BK_ID
					,ORG_ID
					,END_TMS
					,INQ_BASIS_NUM
					,CLS_SET_ID
					)
				SELECT DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,max(DG.END_TMS)
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
				FROM dbo.DG_CONTROL DG
				WHERE DG.ACCT_ID = @ACCT_ID
					AND DG.BK_ID = @bk_id
					AND DG.ORG_ID = @org_id
					AND DG.INQ_BASIS_NUM = @INQ_BASIS_NUM
					AND DG.END_TMS <= @end_tms
					AND DG.END_TMS >= @start_tms
					AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
				GROUP BY DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
					,datepart(yy, end_tms)
					,datepart(qq, end_tms);
			END;
			ELSE IF @date_typ_num = 14
			BEGIN
				INSERT INTO #IVWEndTms (
					ACCT_ID
					,BK_ID
					,ORG_ID
					,END_TMS
					,INQ_BASIS_NUM
					,CLS_SET_ID
					)
				SELECT DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,max(DG.END_TMS)
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
				FROM dbo.DG_CONTROL DG
				WHERE DG.ACCT_ID = @ACCT_ID
					AND DG.BK_ID = @bk_id
					AND DG.ORG_ID = @org_id
					AND DG.INQ_BASIS_NUM = @INQ_BASIS_NUM
					AND DG.END_TMS <= @end_tms
					AND DG.END_TMS >= @start_tms
					AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
				GROUP BY DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
					,datepart(yy, end_tms);
			END;
		END;
		ELSE
		BEGIN
			INSERT INTO #IVWEndTms (
				ACCT_ID
				,BK_ID
				,ORG_ID
				,END_TMS
				,INQ_BASIS_NUM
				,CLS_SET_ID
				)
			SELECT DG.ACCT_ID
				,DG.BK_ID
				,DG.ORG_ID
				,DG.END_TMS
				,DG.INQ_BASIS_NUM
				,DG.CLS_SET_ID
			FROM dbo.DG_CONTROL DG
			WHERE DG.ACCT_ID = @ACCT_ID
				AND DG.BK_ID = @bk_id
				AND DG.ORG_ID = @org_id
				AND DG.INQ_BASIS_NUM = @INQ_BASIS_NUM
				AND DG.END_TMS = @end_tms
				AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
			GROUP BY DG.ACCT_ID
				,DG.BK_ID
				,DG.ORG_ID
				,DG.END_TMS
				,DG.INQ_BASIS_NUM
				,DG.CLS_SET_ID;
		END;

		INSERT INTO #IVWTemp2 (
			ACCT_ID
			,BK_ID
			,ORG_ID
			,END_TMS
			,END_ADJST_TMS
			)
		SELECT d.ACCT_ID
			,d.BK_ID
			,d.ORG_ID
			,d.END_TMS
			,CASE @Adjust_ind
				WHEN 0
					THEN max(d.END_ADJST_TMS) --'MOST RECENT'                          
				WHEN 1
					THEN min(d.END_ADJST_TMS) --'EARLIEST'                             
				WHEN 2
					THEN @end_adjst_tms
				END AS END_ADJST_TMS
		FROM dbo.DG_CONTROL d
		INNER JOIN #IVWEndTms ET ON d.ACCT_ID = ET.ACCT_ID
			AND d.BK_ID = ET.bk_id
			AND d.ORG_ID = ET.org_id
			AND d.INQ_BASIS_NUM = ET.INQ_BASIS_NUM
			AND d.END_TMS = ET.end_tms
		WHERE d.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
		GROUP BY d.ACCT_ID
			,d.BK_ID
			,d.ORG_ID
			,d.END_TMS;
	END;
	ELSE
	BEGIN
		IF @date_typ_num IN (
				12
				,13
				,14
				)
		BEGIN
			IF @date_typ_num = 12
			BEGIN
				INSERT INTO #IVWEndTms (
					ACCT_ID
					,BK_ID
					,ORG_ID
					,END_TMS
					,INQ_BASIS_NUM
					,CLS_SET_ID
					)
				SELECT DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,max(DG.END_TMS)
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
				FROM dbo.DG_CONTROL DG
				INNER JOIN dbo.AcctGroupView AGV ON DG.ACCT_ID = AGV.ACCT_ID
					AND DG.BK_ID = AGV.BK_ID
					AND DG.ORG_ID = AGV.ORG_ID
				WHERE AGV.GRP_ACCT_ID = @ACCT_ID
					AND AGV.GRP_BK_ID = @bk_id
					AND AGV.GRP_ORG_ID = @org_id
					AND DG.INQ_BASIS_NUM = @inq_basis_num
					AND DG.END_TMS <= @end_tms
					AND DG.END_TMS >= @start_tms
					AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
				GROUP BY DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
					,datepart(yy, DG.end_tms)
					,datepart(mm, DG.end_tms);
			END;
			ELSE IF @date_typ_num = 13
			BEGIN
				INSERT INTO #IVWEndTms (
					ACCT_ID
					,BK_ID
					,ORG_ID
					,END_TMS
					,INQ_BASIS_NUM
					,CLS_SET_ID
					)
				SELECT DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,max(DG.END_TMS)
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
				FROM dbo.DG_CONTROL DG
				INNER JOIN dbo.AcctGroupView AGV ON DG.ACCT_ID = AGV.ACCT_ID
					AND DG.BK_ID = AGV.BK_ID
					AND DG.ORG_ID = AGV.ORG_ID
				WHERE AGV.GRP_ACCT_ID = @ACCT_ID
					AND AGV.GRP_BK_ID = @bk_id
					AND AGV.GRP_ORG_ID = @org_id
					AND DG.INQ_BASIS_NUM = @inq_basis_num
					AND DG.END_TMS <= @end_tms
					AND DG.END_TMS >= @start_tms
					AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
				GROUP BY DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
					,datepart(yy, DG.end_tms)
					,datepart(qq, DG.end_tms);
			END;
			ELSE IF @date_typ_num = 14
			BEGIN
				INSERT INTO #IVWEndTms (
					ACCT_ID
					,BK_ID
					,ORG_ID
					,END_TMS
					,INQ_BASIS_NUM
					,CLS_SET_ID
					)
				SELECT DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,max(DG.END_TMS)
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
				FROM dbo.DG_CONTROL DG
				INNER JOIN dbo.AcctGroupView AGV ON DG.ACCT_ID = AGV.ACCT_ID
					AND DG.BK_ID = AGV.BK_ID
					AND DG.ORG_ID = AGV.ORG_ID
				WHERE AGV.GRP_ACCT_ID = @ACCT_ID
					AND AGV.GRP_BK_ID = @bk_id
					AND AGV.GRP_ORG_ID = @org_id
					AND DG.INQ_BASIS_NUM = @inq_basis_num
					AND DG.END_TMS <= @end_tms
					AND DG.END_TMS >= @start_tms
					AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
				GROUP BY DG.ACCT_ID
					,DG.BK_ID
					,DG.ORG_ID
					,DG.INQ_BASIS_NUM
					,DG.CLS_SET_ID
					,datepart(yy, DG.end_tms);
			END;
		END;
		ELSE
		BEGIN
			INSERT INTO #IVWEndTms (
				ACCT_ID
				,BK_ID
				,ORG_ID
				,END_TMS
				,INQ_BASIS_NUM
				,CLS_SET_ID
				)
			SELECT DG.ACCT_ID
				,DG.BK_ID
				,DG.ORG_ID
				,DG.END_TMS
				,DG.INQ_BASIS_NUM
				,DG.CLS_SET_ID
			FROM dbo.DG_CONTROL DG
			INNER JOIN dbo.AcctGroupView AGV ON DG.ACCT_ID = AGV.ACCT_ID
				AND DG.BK_ID = AGV.BK_ID
				AND DG.ORG_ID = AGV.ORG_ID
			WHERE AGV.GRP_ACCT_ID = @ACCT_ID
				AND AGV.GRP_BK_ID = @bk_id
				AND AGV.GRP_ORG_ID = @org_id
				AND DG.INQ_BASIS_NUM = @inq_basis_num
				AND DG.END_TMS = @end_tms
				AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
			GROUP BY DG.ACCT_ID
				,DG.BK_ID
				,DG.ORG_ID
				,DG.END_TMS
				,DG.INQ_BASIS_NUM
				,DG.CLS_SET_ID;
		END;

		INSERT INTO #IVWTemp2 (
			ACCT_ID
			,BK_ID
			,ORG_ID
			,END_TMS
			,END_ADJST_TMS
			)
		SELECT DG.ACCT_ID
			,DG.BK_ID
			,DG.ORG_ID
			,DG.END_TMS
			,CASE @Adjust_ind
				WHEN 0
					THEN Max(DG.END_ADJST_TMS)
				WHEN 1
					THEN Min(DG.END_ADJST_TMS)
				WHEN 2
					THEN @end_adjst_tms
				END AS END_ADJST_TMS
		FROM dbo.DG_CONTROL DG
		INNER JOIN #IVWEndTms ET ON DG.ACCT_ID = ET.ACCT_ID
			AND DG.BK_ID = ET.BK_ID
			AND DG.ORG_ID = ET.ORG_ID
			AND DG.INQ_BASIS_NUM = ET.inq_basis_num
			AND DG.END_TMS = ET.end_tms
		WHERE DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID
		GROUP BY DG.ACCT_ID
			,DG.BK_ID
			,DG.ORG_ID
			,DG.END_TMS;
	END;

	INSERT INTO #IVWTemp (
		ACCT_ID
		,BK_ID
		,ORG_ID
		,INQ_BASIS_NUM
		,CLS_SET_ID
		,DATA_GRP_CTL_NUM
		,END_TMS
		,END_ADJST_TMS
		,A_ACCT_VALVAL_ALT_AMT
		,A_ACCT_EQTVAL_ALT_AMT
		,A_ACCT_FIVAL_ALT_AMT
		,A_ACCT_CURBAL_ALT_AMT
		,A_ACCT_NPRVAL_ALT_AMT
		,A_ACCT_CRVL_ALT_AMT
		,A_ACCT_COVL_ALT_AMT
		,A_ACCT_UGL_ALT_AMT
		,A_ACCT_UGLCUR_ALT_AMT
		,A_ACCT_UGLINV_ALT_AMT
		,A_ACCT_EAI_ALT_AMT
		,A_ACCT_ACCRINC_ALT_AMT
		)
	SELECT DG.ACCT_ID
		,DG.BK_ID
		,DG.ORG_ID
		,DG.INQ_BASIS_NUM
		,@cls_set_id AS CLS_SET_ID
		,DG.DATA_GRP_CTL_NUM
		,DG.END_TMS
		,T.END_ADJST_TMS
		,DG.ACCT_VALVAL_ALT_AMT
		,DG.ACCT_EQTVAL_ALT_AMT
		,DG.ACCT_FIVAL_ALT_AMT
		,DG.ACCT_CURBAL_ALT_AMT
		,DG.ACCT_NPRVAL_ALT_AMT
		,DG.ACCT_CRVL_ALT_AMT
		,DG.ACCT_COVL_ALT_AMT
		,DG.ACCT_UGL_ALT_AMT
		,DG.ACCT_UGLCUR_ALT_AMT
		,DG.ACCT_UGLINV_ALT_AMT
		,DG.ACCT_EAI_ALT_AMT
		,DG.ACCT_ACCRINC_ALT_AMT                 
	FROM dbo.DG_CONTROL DG --VBANDI 09052014
	INNER JOIN #IVWTemp2 T ON DG.ACCT_ID = T.ACCT_ID
		AND DG.BK_ID = T.BK_ID
		AND DG.ORG_ID = T.ORG_ID
		AND DG.END_TMS = T.END_TMS
		AND DG.END_ADJST_TMS = T.END_ADJST_TMS
	WHERE DG.INQ_BASIS_NUM = @inq_basis_num
		AND DG.DATA_GRP_DEF_ID = @DATA_GRP_DEF_ID;

	INSERT INTO #IVWTemp4 (
		END_TMS
		,ACCT_ID
		,ACCT_VALVAL_ALT_AMT
		,ACCT_EQTVAL_ALT_AMT
		,ACCT_FIVAL_ALT_AMT
		,ACCT_CURBAL_ALT_AMT
		,ACCT_NPRVAL_ALT_AMT
		,ACCT_CRVL_ALT_AMT
		,ACCT_COVL_ALT_AMT
		,ACCT_UGL_ALT_AMT
		,ACCT_UGLCUR_ALT_AMT
		,ACCT_UGLINV_ALT_AMT
		,ACCT_EAI_ALT_AMT
		,ACCT_VALVAL_ALT2_AMT
		,ACCT_EQTVAL_ALT2_AMT
		,ACCT_FIVAL_ALT2_AMT
		,ACCT_CURBAL_ALT2_AMT
		,ACCT_NPRVAL_ALT2_AMT
		,ACCT_CRVL_ALT2_AMT
		,ACCT_COVL_ALT2_AMT
		,ACCT_UGL_ALT2_AMT
		,ACCT_UGLCUR_ALT2_AMT
		,ACCT_UGLINV_ALT2_AMT
		,ACCT_EAI_ALT2_AMT
		,ACCT_ACCRINC_ALT2_AMT
		,ACCT_ACCRINC_ALT_AMT
		)
	SELECT DG.END_TMS
		,DG.ACCT_ID
		,sum(DG.ACCT_VALVAL_ALT_AMT)
		,sum(DG.ACCT_EQTVAL_ALT_AMT)
		,sum(DG.ACCT_FIVAL_ALT_AMT)
		,sum(DG.ACCT_CURBAL_ALT_AMT)
		,sum(DG.ACCT_NPRVAL_ALT_AMT)
		,sum(DG.ACCT_CRVL_ALT_AMT)
		,sum(DG.ACCT_COVL_ALT_AMT)
		,sum(DG.ACCT_UGL_ALT_AMT)
		,sum(DG.ACCT_UGLCUR_ALT_AMT)
		,sum(DG.ACCT_UGLINV_ALT_AMT)
		,sum(DG.ACCT_EAI_ALT_AMT)
		,sum(DG.ACCT_VALVAL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_EQTVAL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_FIVAL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_CURBAL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_NPRVAL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_CRVL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_COVL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_UGL_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_UGLCUR_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_UGLINV_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_EAI_ALT_AMT * X.ADJ_FX_RATE)
		,sum(DG.ACCT_ACCRINC_ALT_AMT)
		,sum(DG.ACCT_ACCRINC_ALT_AMT * X.ADJ_FX_RATE)                  
	FROM dbo.DG_CONTROL DG 
	INNER JOIN #IVWTemp T ON DG.DATA_GRP_CTL_NUM = T.DATA_GRP_CTL_NUM
	INNER JOIN dbo.IVW_ACCT A ON DG.ACCT_ID = A.ACCT_ID
		AND DG.BK_ID = A.BK_ID
		AND DG.ORG_ID = A.ORG_ID
	INNER JOIN #FXRate X ON A.ALT_CURR_CDE = X.INSTR_ID
	GROUP BY DG.ACCT_ID
		,DG.END_TMS;        

	IF @l_debug_flag = 1
	BEGIN
		PRINT 'Table #IVWTemp:';

		SELECT ACCT_ID
			,BK_ID
			,ORG_ID
			,INQ_BASIS_NUM
			,CLS_SET_ID
			,DATA_GRP_CTL_NUM
			,END_TMS
			,END_ADJST_TMS
			,A_ACCT_VALVAL_ALT_AMT
			,A_ACCT_EQTVAL_ALT_AMT
			,A_ACCT_FIVAL_ALT_AMT
			,A_ACCT_CURBAL_ALT_AMT
			,A_ACCT_NPRVAL_ALT_AMT
			,A_ACCT_CRVL_ALT_AMT
			,A_ACCT_COVL_ALT_AMT
			,A_ACCT_UGL_ALT_AMT
			,A_ACCT_UGLCUR_ALT_AMT
			,A_ACCT_UGLINV_ALT_AMT
			,A_ACCT_EAI_ALT_AMT
			,A_ACCT_ACCRINC_ALT_AMT
		FROM #IVWTemp;

		PRINT 'Table #IVWTemp4:';

		SELECT END_TMS
			,ACCT_ID
			,ACCT_VALVAL_ALT_AMT
			,ACCT_EQTVAL_ALT_AMT
			,ACCT_FIVAL_ALT_AMT
			,ACCT_CURBAL_ALT_AMT
			,ACCT_NPRVAL_ALT_AMT
			,ACCT_CRVL_ALT_AMT
			,ACCT_COVL_ALT_AMT
			,ACCT_UGL_ALT_AMT
			,ACCT_UGLCUR_ALT_AMT
			,ACCT_UGLINV_ALT_AMT
			,ACCT_EAI_ALT_AMT
			,ACCT_VALVAL_ALT2_AMT
			,ACCT_EQTVAL_ALT2_AMT
			,ACCT_FIVAL_ALT2_AMT
			,ACCT_CURBAL_ALT2_AMT
			,ACCT_NPRVAL_ALT2_AMT
			,ACCT_CRVL_ALT2_AMT
			,ACCT_COVL_ALT2_AMT
			,ACCT_UGL_ALT2_AMT
			,ACCT_UGLCUR_ALT2_AMT
			,ACCT_UGLINV_ALT2_AMT
			,ACCT_EAI_ALT2_AMT
			,ACCT_ACCRINC_ALT2_AMT
			,ACCT_ACCRINC_ALT_AMT
		FROM #IVWTemp4;
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

	
	-- If input parameters @pselect_txt, @pfilter_txt, @porderby_txt, and @pgroupby_txt                            
	--     are not null then use those values in the query.  Filter is an exception                          
	--     Filter is added to the query in addition to the inquiry filter defintion                           
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

	IF EXISTS (
			SELECT 1
			FROM dbo.DP_CrossReference
			WHERE codeset_type_id = @codeset_type_id
				AND originator_id = @originator_id
				AND External_Value2 = rtrim(@acct_id)
			)
	BEGIN
		DECLARE @getCrossRef VARCHAR(8000);

		DECLARE @val CURSOR;SET @val = CURSOR
		FOR
		SELECT ' and not ( A.LEV_10_HIER_NME = ''' + rtrim(Internal_Value2) + ''') ' AS val
		FROM dbo.DP_CrossReference
		WHERE codeset_type_id = @codeset_type_id
			AND originator_id = @originator_id
			AND External_Value2 = rtrim(@acct_id);

		OPEN @val;

		FETCH NEXT
		FROM @val
		INTO @getCrossRef;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @getCondition = ''
				SET @getCondition = @getCrossRef;
			ELSE
				SET @getCondition = @getCondition + @getCrossRef;

			FETCH NEXT
			FROM @val
			INTO @getCrossRef;
		END;

		CLOSE @val;

		DEALLOCATE @val;
	END;

	If charindex ( '@GRAND_TOTAL',@sql_txt1 ) >1  --Mchawla	10132014
	BEGIN

		SELECT  @GRAND_TOTAL = SUM(p.VALVAL_CMB_AMT) 
		FROM   
		 #IVWTEMP T
		Join 
		dbo.POSITION_DG AS p   ON                
			p.DATA_GRP_CTL_NUM = T.DATA_GRP_CTL_NUM  
			--and p.ACCT_ID = T.ACCT_ID --Mchawla	10132014
				INNER JOIN dbo.ISSUE_DG AS I                   
				ON P.INSTR_ID = I.INSTR_ID 
		AND (I.ISS_TYP <> @Iss_type); 
	End
	

	-- Position Selection SQL Building    
	SELECT @cnt_check = substring(@sql_txt1, 1, 8);

	IF @cnt_check <> 'count(*)'
		SELECT @sql_txt1 = 'SUM(1), ' + @sql_txt1;

	IF substring(reverse(@sql_txt1), 1, 8) <> ')*(tnuoc'
		SELECT @sql_txt1 = @sql_txt1 + ' ,SUM(1)';
    
	/*Start Mchawla	10132014*/
	
	If charindex ( 'LDGR_NME',@filter_txt1 ) >1 
	BEGIN
	SELECT @SQL_TXT2 = 'SELECT A.ACCT_ID,A.BK_ID,A.ORG_ID , A.INQ_BASIS_NUM,A.AS_OF_TMS, A.LDGR_NME' +(
			CASE 
				WHEN (@acct_type = 'I')
					THEN ' from PositionView A with (nolock) ' + ' join #IVWTemp T on (A.DATA_GRP_CTL_NUM = T.DATA_GRP_CTL_NUM) ' +
					                     
						' join #IVWTemp4 DG on (DG.ACCT_ID = T.ACCT_ID) ' +           
						' left outer join #FXRate X on (A.ALT_CURR_CDE = X.FROM_PRC_CURR_CDE) ' + ' where A.ACCT_ID = ''' + rtrim(@acct_id) + '''' + ' and A.BK_ID   = ''' + rtrim(@bk_id) + '''' + ' and A.ORG_ID  = ''' + rtrim(@org_id) + ''''
				WHEN (
						@acct_type = 'G'
						OR @acct_type = 'U'
						)
					THEN ' from PositionView A with (nolock) ' + ' join #IVWTemp T on (A.DATA_GRP_CTL_NUM = T.DATA_GRP_CTL_NUM) ' +
					                  
						' join #IVWTemp4 DG on (DG.ACCT_ID = T.ACCT_ID) ' +           
						' left outer join #FXRate X on (A.ALT_CURR_CDE = X.FROM_PRC_CURR_CDE) ' + ' where A.ACCT_ID = T.ACCT_ID                          
						  and A.BK_ID = T.BK_ID                          
						  and A.ORG_ID = T.ORG_ID                          
						  and A.INQ_BASIS_NUM = T.INQ_BASIS_NUM                          
						  and A.AS_OF_TMS = T.END_TMS '
				END
			) + ' and A.CLS_SET_ID = T.CLS_SET_ID ' +@getCondition  ;
			insert into #templedger

	exec sp_executesql @SQL_TXT2
		SELECT @filter_txt1 = REPLACE(@filter_txt1, 'A.LDGR_NME', 'lg.LDGR_NME' ); 
	SELECT @sql_txt1 = REPLACE(@sql_txt1, 'A.LDGR_NME', 'lg.LDGR_NME' ); 
	SELECT @grp_txt1 = REPLACE(@grp_txt1, 'A.LDGR_NME', 'lg.LDGR_NME' ); 
	SELECT @sort_txt1 = REPLACE(@sort_txt1, 'A.LDGR_NME', 'lg.LDGR_NME' ); 
	END
	 /*End Mchawla	10132014*/

	SELECT @sql_txt1 = 'select ' + (
			CASE charindex('SUM(1)', @sql_txt1) 
				WHEN 0
					THEN 'SUM(1), ' 
				ELSE ''
				END
			) + @sql_txt1 +
		-- From clause                          
		(
			CASE 
				WHEN (@acct_type = 'I')
					THEN ' from PositionView A with (nolock) ' + ' join #IVWTemp T on (A.DATA_GRP_CTL_NUM = T.DATA_GRP_CTL_NUM) ' +
					                     
						' join #IVWTemp4 DG on (DG.ACCT_ID = T.ACCT_ID) ' +           
						' left outer join #FXRate X on (A.ALT_CURR_CDE = X.FROM_PRC_CURR_CDE) ' 
						+ Case when (charindex ( 'lg.LDGR_NME',@filter_txt1 ) >1 )   --Start Mchawla	10132014
							then ' left outer join  #templedger  lg
							on lg.acct_id = a.acct_id
							  and A.BK_ID = lg.BK_ID                          
										  and A.ORG_ID = lg.ORG_ID                          
										  and A.INQ_BASIS_NUM = lg.INQ_BASIS_NUM                          
										  and A.AS_OF_TMS = lg.AS_OF_TMS'
							else '' 
							end --End Mchawla	10132014
						
						+ ' where A.ACCT_ID = ''' + rtrim(@acct_id) + '''' + ' and A.BK_ID   = ''' + rtrim(@bk_id) + '''' + ' and A.ORG_ID  = ''' + rtrim(@org_id) + ''''
				WHEN (
						@acct_type = 'G'
						OR @acct_type = 'U'
						)
					THEN ' from PositionView A with (nolock) ' + ' join #IVWTemp T on (A.DATA_GRP_CTL_NUM = T.DATA_GRP_CTL_NUM) ' +
					                  
						' join #IVWTemp4 DG on (DG.ACCT_ID = T.ACCT_ID) ' +           
						' left outer join #FXRate X on (A.ALT_CURR_CDE = X.FROM_PRC_CURR_CDE) ' 
						+ Case when (charindex ( 'lg.LDGR_NME',@filter_txt1 ) >1 )   --Start Mchawla	10132014
							then ' left outer join  #templedger  lg
							on lg.acct_id = a.acct_id
							  and A.BK_ID = lg.BK_ID                          
										  and A.ORG_ID = lg.ORG_ID                          
										  and A.INQ_BASIS_NUM = lg.INQ_BASIS_NUM                          
										  and A.AS_OF_TMS = lg.AS_OF_TMS'
							else '' 
							end --End Mchawla	10132014
						+ ' where A.ACCT_ID = T.ACCT_ID                          
						  and A.BK_ID = T.BK_ID                          
						  and A.ORG_ID = T.ORG_ID                          
						  and A.INQ_BASIS_NUM = T.INQ_BASIS_NUM                          
						  and A.AS_OF_TMS = T.END_TMS '
				END
			) + ' and A.CLS_SET_ID = T.CLS_SET_ID ' + @getCondition + @filter_txt1 + @grp_txt1 + @sort_txt1;

	print @sql_txt1                         
	
	EXECUTE dbo.sp_executesql @sql_txt1,@paramdef,@Grand_total;

	
END TRY


BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION;
	IF OBJECT_ID('tempdb..#IVWTemp2') IS NOT NULL
		DROP TABLE #IVWTemp2;

	IF OBJECT_ID('tempdb..#IVWEndTms') IS NOT NULL
		DROP TABLE #IVWEndTms;

	IF OBJECT_ID('tempdb..#IVWTemp') IS NOT NULL
		DROP TABLE #IVWTemp;

	IF OBJECT_ID('tempdb..#IVWTemp4') IS NOT NULL
		DROP TABLE #IVWTemp4;

	IF OBJECT_ID('tempdb..#FXRate') IS NOT NULL
		DROP TABLE #FXRate;

	DECLARE @ERRMSG NVARCHAR(3000);
	DECLARE @ERRSTATE INT;

	SET @errno = ERROR_NUMBER();
	SET @ERRMSG = Error_message();
	SET @ERRSEVERITY = Error_severity();
	SET @ERRSTATE = ERROR_STATE();

	RAISERROR (
			@ERRMSG
			,@ERRSEVERITY
			,@ERRSTATE
			);
END CATCH;

IF OBJECT_ID('tempdb..#IVWTemp2') IS NOT NULL
	DROP TABLE #IVWTemp2;

IF OBJECT_ID('tempdb..#IVWEndTms') IS NOT NULL
	DROP TABLE #IVWEndTms;

IF OBJECT_ID('tempdb..#IVWTemp') IS NOT NULL
	DROP TABLE #IVWTemp;

IF OBJECT_ID('tempdb..#IVWTemp4') IS NOT NULL
	DROP TABLE #IVWTemp4;

IF OBJECT_ID('tempdb..#FXRate') IS NOT NULL
	DROP TABLE #FXRate;


