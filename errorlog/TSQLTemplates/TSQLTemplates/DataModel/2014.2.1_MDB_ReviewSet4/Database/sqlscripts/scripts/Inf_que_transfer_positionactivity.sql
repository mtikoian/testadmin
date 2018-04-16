USE NetikDP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
    
  
ALTER PROCEDURE dbo.Inf_que_transfer_positionactivity
 (          
   @batch_id    INT,           
   @record_id   NUMERIC(9) ,    
   @row_ins_ctr   INT OUTPUT,           
   @row_upd_ctr   INT OUTPUT,           
   @unmatch_acct_ctr  INT OUTPUT,           
   @task_ref_id   CHAR(16),           
   @event_ref_id   CHAR(16),           
   @systemTableUpdate CHAR(5) = 'TRUE'          
 )           
AS             
/*           
==================================================================================================           
Name    :  INF_que_transfer_positionactivity           
Author    :  KASLAM - 01/11/2012           
Description : - This procedure is developed to implement the new Informatica ETL workflow for Geneva fields which will            
       eventually replace the existing Netik Geneva Adapter.           
              - This procedure is a replica of the old procedure que_transfer_positionactivity            
                (originally devleoped by Netik London) with some modifications to meet the new requirements.           
              - Following are the changes made to the old stored Procedure ::           
              - Removed the @batchtarget_id and @work_unit_seq input paramters to the SP and           
                made the corresponding changes in the script.           
              - Removed the use of DP_T_PositionActivityTarget table.           
              - Replaced the execute statement for que_transfer_classif with INF_que_transfer_classif so as to           
                remove the input paramters @batchtarget_id and @work_unit_seq, in the SP que_transfer_classif.           
                   
===================================================================================================           
Parameters  :         
Parameter Name      I/O     Description    
--------------------------------------------------        
  @batch_id     I   Batch Id    
  @record_id          I         Record Id    
  @row_ins_ctr        O         Row Insert Counter    
  @row_upd_ctr        O         Row Update Counter    
  @unmatch_acct_ctr   O         Unmatched Acct Counter    
  @task_ref_id        I         Task Ref Id    
  @event_ref_id       I         Event Ref Id     
  @systemTableUpdate  I         System Table Update    
----------------------------------------------------------------           
Returns    :   Inserts Records into the Specified position_dg Data Ware house from the     
      Informatica Workflow           
                  
History:           
          
Name            Date         Description           
----------------------------------------------------------------------------           
Kashif A        01/11/2012  First Version           
Mohammad Sohail 07/18/2012  Added the filter for InvestmentInMaster          
Manish          12/03/2012  Added new fields    
MChawla   04/23/2013 Updated the table name      
vperala   08/05/2013 Temp table dropped after catch block;
SMehrotra 01/03/2013  -New columns added -MDB-2742 Marked with SMehrotra 01032013    
VBANDI	  01/22/2014   Set value to variable @THE_TIME_PART and initialize all variables before transaction Tag VBANDI 01222014
MChawla	  01/26/2014   Per Jira Ticket#MDB-3187 Tag MChawla 01262014
SMehrotra 01/27/2014 -MDB-3125  --Marked with SMehrotra 01272014 
MPadala   01/28/2014 - MDB3125 -- -- Mapped to WorkunitSeq as Lev3_Hire_num shld be used.  
VBANDI	  02/10/2014   Changed logic to update system table instead of loop Tag VBANDI 02102014
========================================================================================================              
*/           
      
BEGIN --Begin 1        
      
SET NOCOUNT ON         
SET XACT_ABORT ON;        
      
   DECLARE @ErrorMessage   NVARCHAR(4000);      
   DECLARE @ErrorSeverity  INT;      
   DECLARE @ErrorLine      INT;      
      
   DECLARE @Error          INT;     
    
DECLARE @org_id               CHAR(4),           
        @bk_id                CHAR(4),           
        @acct_id              CHAR(12),           
        @as_of_tms            DATETIME,           
        @adjst_tms            DATETIME,           
        @inq_basis_num        INT,           
        @alt_curr_cde         CHAR(3),           
        @alt_curr_nme         VARCHAR(40),           
        @crvl_cmpnt_id        CHAR(8),           
        @crvl_typ             CHAR(4),           
        @covl_cmpnt_id        CHAR(8),           
        @covl_typ             CHAR(4),           
        @id_ctxt_typ          CHAR(4),           
   @nls_cde              CHAR(8),           
        @qlty_rat_srce_typ    CHAR(8),           
        @valu_type            CHAR(4),           
        @cls_set_id           CHAR(8),           
        @acct_valval_alt_amt  FLOAT,           
        @acct_eqtval_alt_amt  FLOAT,           
        @acct_fival_alt_amt   FLOAT,           
        @acct_curbal_alt_amt  FLOAT,           
        @acct_nprval_alt_amt  FLOAT,           
        @acct_crvl_alt_amt    FLOAT,           
        @acct_ugl_alt_amt     FLOAT,           
        @acct_uglcur_alt_amt  FLOAT,           
        @acct_uglinv_alt_amt  FLOAT,           
        @acct_eai_alt_amt     FLOAT,           
        @acct_cureqv_alt_amt  FLOAT,           
        @acct_othrval_alt_amt FLOAT,           
        @acct_accrinc_alt_amt FLOAT,           
        @acct_totqty_amt      FLOAT,           
        @dg_count_num         INT,           
        @EQUITY_AC            VARCHAR(40),           
        @CASH_AC              VARCHAR(40),           
        @RECPAY_AC            VARCHAR(40),           
        @FWD_AC               VARCHAR(40),           
        @FIX_INC_AC           VARCHAR(40),           
        @BALANCE_AC           VARCHAR(40),           
        @CURR_EQUIV_AC        VARCHAR(40),           
        @THE_TIME_PART        CHAR(8),           
        @upd_at_opt           CHAR(1),           
        @running_ctr          INT,           
        @rec_num              INT,           
        @data_grp_ctl_num     INT,           
        @max_rec              INT,           
        @data_grp_ctl_num_ch  CHAR(10),           
        @rtn_msg              CHAR(255),           
        @datetime_now         DATETIME,           
        @ret_cde              INT,           
        @end_tms              DATETIME,           
        @end_adjst_tms        DATETIME,           
        @DESC_SRCE_TYP        CHAR(8),           
        @ISS_INCS_ID          CHAR(8),           
        @ISSR_INCS_ID         CHAR(8),           
        @START_TMS            DATETIME,           
        @START_ADJST_TMS      DATETIME,           
        @ACCT_COVL_ALT_AMT    FLOAT,           
        @data_grp_def_id      CHAR(8),    
  @at_instrct_id        VARCHAR(10)      
    DECLARE @msg   VARCHAR(200);  --SMehrotra 01032013   
	DECLARE @ReturnCode   INT;    --SMehrotra 01032013   
    DECLARE @dec017 FLOAT; -- MChawla	01262014
	DECLARE @dec018 FLOAT; -- MChawla	01262014
	DECLARE @dec019 FLOAT; -- MChawla	01262014
	/*VBANDI 02102014*/ 
	  DECLARE @sys_id CHAR(6);
   declare @updatecount INT
   SET @updatecount = 0;
SET @sys_id = 'system'
if object_id('tempdb..#tempsystem') is not null
drop table #tempsystem
if object_id('tempdb..#tkey') is not null
drop table #tkey
	/*** Create temp table #tempsystem ***/  

		create table #tempsystem (dg_control_id int not null primary key) 
          
		  /*VBANDI 02102014*/ 
      /*** Create temp table ***/           
      CREATE TABLE #tkey           
     (           
        rec_num              INT IDENTITY (1,1) PRIMARY KEY CLUSTERED,           
        org_id               CHAR(4) NULL,           
        bk_id                CHAR(4) NULL,           
        acct_id              CHAR(12) NULL,           
        as_of_tms            DATETIME NULL,           
        adjst_tms            DATETIME NULL,           
        inq_basis_num        INT NULL,           
        alt_curr_cde         CHAR(3) NULL,           
        alt_curr_nme         VARCHAR(40) NULL,           
        crvl_cmpnt_id        CHAR(8) NULL,           
        crvl_typ             CHAR(4) NULL,           
        id_ctxt_typ          CHAR(8) NULL,           
        nls_cde              CHAR(8) NULL,           
        qlty_rat_srce_typ    CHAR(8) NULL,           
        valu_typ             CHAR(4) NULL,           
        cls_set_id           CHAR(8) NULL,           
        acct_valval_alt_amt  FLOAT NULL,           
        acct_eqtval_alt_amt  FLOAT NULL,           
        acct_fival_alt_amt   FLOAT NULL,           
        acct_curbal_alt_amt  FLOAT NULL,           
        acct_nprval_alt_amt  FLOAT NULL,           
        acct_crvl_alt_amt    FLOAT NULL,           
        acct_ugl_alt_amt     FLOAT NULL,           
        acct_uglcur_alt_amt  FLOAT NULL,           
        acct_uglinv_alt_amt  FLOAT NULL,           
        acct_eai_alt_amt     FLOAT NULL,           
        acct_cureqv_alt_amt  FLOAT NULL,           
        acct_othrval_alt_amt FLOAT NULL,           
        acct_accrinc_alt_amt FLOAT NULL,           
        acct_totqty_amt      FLOAT NULL,           
        dg_count_num         INT   NULL,        
		dec017				 FLOAT NULL,-- MChawla	01262014
        dec018				 FLOAT NULL,-- MChawla	01262014
        dec019				 FLOAT NULL -- MChawla	01262014
     )         
     
    
 DECLARE @ldgr_nmeINVM  VARCHAR(18)    
 DECLARE @data_grp_def_idPOS VARCHAR(8)    
 DECLARE @upd_at_optY  CHAR(1)    
 DECLARE @CurrFlag           INT    
 DECLARE @Status             VARCHAR(10)    
 DECLARE @nlscde             VARCHAR(5)    
 DECLARE @Tms                VARCHAR(15)     
 DECLARE @dldStatus          VARCHAR(2)    
            
   BEGIN TRY      
       
 SET @upd_at_optY = 'Y'       
 SET @ldgr_nmeINVM =  'InvestmentInMaster'    
 SET @data_grp_def_idPOS = 'POSITION'    
 SET @CurrFlag =1    
 SET @Status = 'SUCCESS'    
 SET @at_instrct_id = 'ACTMKTVAL'     
 SET @nlscde = 'ENG'                   
 SET @Tms = '00:00:00.000'    
 SET @dldStatus = 'C'    
 /*Start VBANDI 01222014*/
       -- This flag is to be set to 'Y' if ACCT_TOTALS table has to be updated with             
      --    Market value summary information             
      --    If this is set to 'N' then no update will take place.             
      SET @upd_at_opt = @upd_at_optY           
          
     /*** Asset Class used by IVW.              
     ** Compute the Market Values for the various asset class.             
     ** NEED TO FIND OUT ABOUT THE UPPER CASE/LOWER CASE HERE             
     */           
      /*STATIC variables*/           
	SET @EQUITY_AC = 'EQUITY' -- "Equities"             
	SET @CASH_AC = 'CASH'
	SET @RECPAY_AC = 'REC/PAY' -- Rec/Pay             
	SET @FWD_AC = 'OTHER' -- used for forwards             
	SET @FIX_INC_AC = 'FIXED INC'
	SET @BALANCE_AC = 'BALANCE' -- "BALANCE"              
	SET @CURR_EQUIV_AC = 'CURR EQUIV'
	--SELECT @THE_TIME_PART = fmt_end_tms           
	--FROM   dbo.dw_system           
	SET @DESC_SRCE_TYP = 'N/A'
	SET @ISS_INCS_ID = NULL
	SET @ISSR_INCS_ID = NULL
	SET @START_TMS = NULL
	SET @START_ADJST_TMS = NULL
	SET @ACCT_COVL_ALT_AMT = 0
	SET @THE_TIME_PART = '23:59:59'-- this value represents time part identfier 

 /*End VBANDI 01222014*/
      BEGIN TRANSACTION  
	  /*VBANDI 02102014*/           
	   insert into #tempsystem
		(dg_control_id) select DG_CTL_NUM_CT
		FROM dbo.DW_SYSTEM
		WHERE sys_id = @sys_id
		/*VBANDI 02102014*/ 
      /*              
      ** Place data in a work table - extract from the que_position table             
      */           
    INSERT INTO #tkey     
    (org_id,     
     bk_id,     
     acct_id,     
     as_of_tms,     
     adjst_tms,     
     inq_basis_num,     
     alt_curr_cde,     
     alt_curr_nme,     
     crvl_cmpnt_id,     
     crvl_typ,     
     id_ctxt_typ,     
     nls_cde,     
     qlty_rat_srce_typ,     
     valu_typ,     
     cls_set_id,     
     acct_valval_alt_amt,     
     acct_eqtval_alt_amt,     
     acct_fival_alt_amt,     
     acct_curbal_alt_amt,     
     acct_nprval_alt_amt,     
     acct_crvl_alt_amt,     
     acct_ugl_alt_amt,     
     acct_uglcur_alt_amt,     
     acct_uglinv_alt_amt,     
     acct_eai_alt_amt,     
     acct_cureqv_alt_amt,     
     acct_othrval_alt_amt,     
     acct_accrinc_alt_amt,     
     acct_totqty_amt,     
     dg_count_num,
     dec017,-- MChawla	01262014
     dec018,-- MChawla	01262014
     dec019-- MChawla	01262014
     )     
   SELECT org_id,     
       bk_id,     
       acct_id,     
       as_of_tms,     
       adjst_tms,     
       inq_basis_num,     
       alt_curr_cde = MAX(alt_curr_cde),     
       -- NOT NULL Non-aggregate column that is the same for all columns in aggregate.               
       alt_curr_nme = NULLIF(MAX (ISNULL(alt_curr_nme, '')), ''),     
       -- Nullable Non-aggregate column that is the same for all columns in aggregate.               
       crvl_cmpnt_id = NULLIF(MAX (ISNULL(crvl_cmpnt_id, '')), ''),     
       crvl_typ = NULLIF(MAX (ISNULL(crvl_typ, '')), ''),     
       id_ctxt_typ = NULLIF(Max (Isnull(id_ctxt_typ, '')), ''),     
       nls_cde = NULLIF(Max (Isnull(nls_cde, '')), ''),     
       qlty_rat_srce_typ = NULLIF(Max (Isnull(qlty_rat_srce_typ, '')), ''),     
       valu_typ = NULLIF(Max (Isnull(valu_typ, '')), ''),     
       cls_set_id = NULLIF(Max (Isnull(cls_set_id, '')), ''),     
       acct_valval_alt_amt = Sum(valval_alt_cmb_amt),     
       acct_eqtval_alt_amt = Sum(CASE asset_class_mnem     
              WHEN @EQUITY_AC THEN valval_alt_cmb_amt     
              ELSE 0     
            END),     
       acct_fival_alt_amt = Sum(CASE asset_class_mnem     
             WHEN @FIX_INC_AC THEN valval_alt_cmb_amt     
             ELSE 0     
           END),     
       acct_curbal_alt_amt = Sum(CASE asset_class_mnem     
              WHEN @CASH_AC THEN valval_alt_cmb_amt     
              WHEN @BALANCE_AC THEN valval_alt_cmb_amt     
              ELSE 0     
            END),     
       acct_nprval_alt_amt = Sum(CASE asset_class_mnem     
              WHEN @RECPAY_AC THEN valval_alt_cmb_amt     
              ELSE 0     
            END),     
       acct_crvl_alt_amt = Sum(Isnull (crvl_alt_cmb_amt, 0.00)),     
       acct_ugl_alt_amt = Sum(Isnull (ugl_cmb_amt, 0.00)),     
       acct_uglcur_alt_amt = Sum(Isnull (uglcur_alt_cmb_amt, 0.00)),     
       acct_uglinv_alt_amt = Sum(Isnull (uglinv_alt_cmb_amt, 0.00)),     
       acct_eai_alt_amt = Sum(Isnull (eai_amt, 0.00)),     
       acct_cureqv_alt_amt = Sum(CASE asset_class_mnem     
              WHEN @CURR_EQUIV_AC THEN valval_alt_cmb_amt     
              ELSE 0     
            END),     
       acct_othrval_alt_amt = Sum(CASE asset_class_mnem     
            WHEN @FWD_AC THEN valval_alt_cmb_amt     
            ELSE 0     
             END),     
       acct_accrinc_alt_amt = Sum(accrinc_alt_cmb_amt),     
       acct_totqty_amt = Sum(quantity),     
       dg_count_num = Count(1),
        SUM(Sys_curr_unit_prc* Quantity ),-- MChawla	01262014
       SUM(Sys_curr_accrued_income_amt),-- MChawla	01262014
       SUM(Sys_curr_Unrealized_GL_amt + Revalued_unrealized_gl_amt)     -- MChawla	01262014
       /*MChawla,04/23/2013 -Updated the table name    */  
       --FROM   dbo.inf_dp_t_positionactivity act  
   FROM   dbo.dp_t_positionactivity act     
   WHERE  act.batchid = @batch_id -- added KA 11152011             
       --     INNER JOIN DP_T_PositionActivityTarget ActTarget  -- no need             
       --           ON  ActTarget.ActivityId = Act.Id   -- no need             
       --           AND ActTarget.BatchId = @batch_id  -- no need             
       --    AND ActTarget.BatchTargetId = @batchtarget_id  -- no need             
       --    AND ActTarget.WorkUnitSeq = @work_unit_seq   -- no need             
       --           AND ActTarget.IsValid = 1   -- no need             
       AND ISNULL(Act.ldgr_nme, '') <> @ldgr_nmeINVM     
   GROUP  BY org_id,     
       bk_id,     
       acct_id,     
       as_of_tms,     
       adjst_tms,     
       inq_basis_num            
          
    /* Initialize values */           
    SET @running_ctr = 0           
    SET @unmatch_acct_ctr = 0           
    SET @row_ins_ctr = 0           
    SET @row_upd_ctr = 0           
    SET @rec_num = 1          
             
      
              
      /* Select MAX_rec from #TKey */           
      SELECT @max_rec = MAX(rec_num)           
      FROM   #tkey           
          
      /*Now use records in TKEY to maintain DG_CONTROL and as units of work for the transfer from que_position to POSITION_DG*/           
      WHILE @rec_num <= @max_rec           
     BEGIN/*    TKEY Loop*/  --Begin 2 
	 /*VBANDI 02102014*/ 
	 set @updatecount = (select count(1) FROM    DW_DG_CONTROL dg
	  inner join #TKey tk
	  on  dg.org_id  =  tk.org_id 
        and   dg.bk_id   = tk.bk_id
        and   dg.acct_id = tk.acct_id
        and   dg.end_tms = tk.as_of_tms
        and   dg.end_adjst_tms = tk.adjst_tms
        and   dg.inq_basis_num = tk.inq_basis_num
        and   dg.DATA_GRP_DEF_ID = 'POSITION')

		--select @updatecount
		UPDATE dbo.DW_SYSTEM
		SET DG_CTL_NUM_CT = DG_CTL_NUM_CT + @max_rec - @updatecount
		WHERE sys_id = @sys_id      
		/*VBANDI 02102014*/          
      SELECT @org_id = org_id,           
          @bk_id = bk_id,           
          @acct_id = acct_id,           
          @as_of_tms = CONVERT(DATETIME, CONVERT(CHAR(10), as_of_tms,101)+  ' ' + ISNULL(@THE_TIME_PART, @Tms)),           
          @adjst_tms = adjst_tms,           
          @inq_basis_num = inq_basis_num,           
          @alt_curr_cde = alt_curr_cde,           
          @alt_curr_nme = alt_curr_nme,           
          @crvl_typ = ISNULL(crvl_typ, @DESC_SRCE_TYP),           
          @crvl_cmpnt_id = ISNULL(crvl_cmpnt_id, @DESC_SRCE_TYP),           
          @id_ctxt_typ = id_ctxt_typ,           
          @nls_cde = nls_cde,           
          @qlty_rat_srce_typ = qlty_rat_srce_typ,           
          @valu_type = valu_typ,           
          @cls_set_id = cls_set_id,           
          @acct_valval_alt_amt = acct_valval_alt_amt,           
          @acct_eqtval_alt_amt = acct_eqtval_alt_amt,           
          @acct_fival_alt_amt = acct_fival_alt_amt,           
          @acct_curbal_alt_amt = acct_curbal_alt_amt,           
          @acct_nprval_alt_amt = acct_nprval_alt_amt,           
       @acct_crvl_alt_amt = acct_crvl_alt_amt,           
          @acct_ugl_alt_amt = acct_ugl_alt_amt,           
          @acct_uglcur_alt_amt = acct_uglcur_alt_amt,           
          @acct_uglinv_alt_amt = acct_uglinv_alt_amt,           
          @acct_eai_alt_amt = acct_eai_alt_amt,           
          @acct_cureqv_alt_amt = acct_cureqv_alt_amt,           
          @acct_othrval_alt_amt = acct_othrval_alt_amt,           
          @acct_accrinc_alt_amt = acct_accrinc_alt_amt,           
          @acct_totqty_amt = acct_totqty_amt,           
          @dg_count_num = dg_count_num,           
          @covl_typ = @crvl_typ,           
          @covl_cmpnt_id = @crvl_cmpnt_id,           
          @nls_cde = ISNULL(@nls_cde, @nlscde),           
          @end_tms = as_of_tms,           
          @end_adjst_tms = adjst_tms,     
		  @dec017 = dec017,-- MChawla	01262014
          @dec018 = dec018,	-- MChawla	01262014
		  @dec019 = dec019	-- MChawla	01262014      
      FROM   #tkey           
      WHERE  rec_num = @rec_num           
              IF @@ROWCOUNT = 0           
        BEGIN  --Begin 3          
         BREAK           
        END  -- End 3          
          
      SET @datetime_now = CURRENT_TIMESTAMP           
          
      SET @data_grp_ctl_num = NULL           
      SET @data_grp_ctl_num_ch = NULL           
          
      SELECT @data_grp_ctl_num = data_grp_ctl_num,           
             @data_grp_ctl_num_ch = CAST(data_grp_ctl_num AS CHAR(10))           
      FROM   dbo.dw_dg_control           
      WHERE  org_id = @org_id           
          AND bk_id = @bk_id           
          AND acct_id = @acct_id           
          AND end_tms = @as_of_tms           
          AND end_adjst_tms = @adjst_tms           
          AND inq_basis_num = @inq_basis_num           
          AND data_grp_def_id = @data_grp_def_idPOS           
          
      IF @data_grp_ctl_num IS NULL           
        BEGIN /*      Create New dg_control record*/  --Begin 4  
		/*VBANDI 02102014*/     
             --Start    SMehrotra 01032013 
   --      EXEC @ReturnCode = dbo.Que_get_dg_control_num @data_grp_ctl_num OUTPUT

			--IF (@ReturnCode <> 0)
			--BEGIN
			--	SET @msg = 'Unable to get group control num ' + cast(@returncode AS VARCHAR(12));

			--	RAISERROR (
			--			@msg
			--			,16
			--			,1
			--			);
			--END;
			update #tempsystem
			set dg_control_id = dg_control_id + 1 
			

		set @data_grp_ctl_num = (select dg_control_id from #tempsystem);
			/*VBANDI 02102014*/
          --End SMehrotra 01032013 
         SET @data_grp_ctl_num_ch = CAST(@data_grp_ctl_num AS CHAR(10))           
          --Start    SMehrotra 01032013 
          EXEC @ReturnCode = dbo.Que_dg_control_ins           
        @data_grp_def_id = @data_grp_def_idPOS,           
        @data_grp_ctl_num = @data_grp_ctl_num,           
        @extr_ctl_id = @data_grp_ctl_num_ch,           
        @data_grp_ctl_id = @data_grp_ctl_num_ch,           
        @org_id = @org_id,           
        @bk_id = @bk_id,           
        @acct_id = @acct_id,           
        @alt_curr_cde = @alt_curr_cde,           
        @crvl_typ = @crvl_typ,           
        @crvl_cmpnt_id = @crvl_cmpnt_id,           
        @covl_typ = @covl_typ,           
        @covl_cmpnt_id = @covl_cmpnt_id,           
        @desc_srce_typ = @DESC_SRCE_TYP,           
        @iss_incs_id = @ISS_INCS_ID,           
        @issr_incs_id = @ISSR_INCS_ID,           
        @valu_typ = @valu_type,           
        @qlty_rat_srce_typ = @qlty_rat_srce_typ,           
        @nls_cde = @nls_cde,           
        @start_tms = @START_TMS,           
        @start_adjst_tms = @START_ADJST_TMS,           
        @end_tms = @as_of_tms,           
        @end_adjst_tms = @adjst_tms,           
        @cls_set_id = @cls_set_id,           
        @inq_basis_num = @inq_basis_num,           
        @acct_valval_alt_amt = @acct_valval_alt_amt,           
        @acct_eqtval_alt_amt = @acct_eqtval_alt_amt,           
        @acct_fival_alt_amt = @acct_fival_alt_amt,           
        @acct_curbal_alt_amt = @acct_curbal_alt_amt,           
        @acct_nprval_alt_amt = @acct_nprval_alt_amt,           
        @acct_crvl_alt_amt = @acct_crvl_alt_amt,           
        @acct_covl_alt_amt = @ACCT_COVL_ALT_AMT,           
        @acct_ugl_alt_amt = @acct_ugl_alt_amt,           
        @acct_uglcur_alt_amt = @acct_uglcur_alt_amt,           
        @acct_uglinv_alt_amt = @acct_uglinv_alt_amt,           
        @acct_eai_alt_amt = @acct_eai_alt_amt,           
        @acct_cureqv_alt_amt = @acct_cureqv_alt_amt,           
 @acct_othrval_alt_amt = @acct_othrval_alt_amt,           
        @acct_accrinc_alt_amt = @acct_accrinc_alt_amt,           
        @acct_totqty_amt = @acct_totqty_amt,           
        @dg_count_num = @dg_count_num,           
        @created_tms = @datetime_now,           
        @dld_cmpltn_tms = @datetime_now,           
        @dld_status_ind = @dldStatus,           
        @valn_audit_status=NULL,           
        @restate_ind=NULL,           
        @batch_id=@batch_id --  Added By Manish, 04222010    

		IF (@ReturnCode <> 0)
			BEGIN
				SET @msg = 'Unable to insert records in dg_control ' + cast(@returncode AS VARCHAR(12));

				RAISERROR (
						@msg
						,16
						,1
						);
			END;
		--End SMehrotra 01032013          
        END /*END - Create New dg_control record*/ --End 4          
      ELSE           
        BEGIN  --Begin 5          
         /*      Delete any existing position records and update DGCONTROL with latest totals*/           
         SET @rtn_msg = 'Positions for data group control num ' +  CONVERT(CHAR(50), @data_grp_ctl_num) +     
         ' exist .This data group control num will be deleted. DGCLNum: ' +  CONVERT(CHAR(10), @data_grp_ctl_num)     --SMehrotra 01032013        
          
         PRINT @rtn_msg           
          
         DELETE netikip.dbo.position_dg           
  WHERE  data_grp_ctl_num = @data_grp_ctl_num           
          
         SET @row_upd_ctr = @row_upd_ctr + @@ROWCOUNT           
          
         UPDATE dbo.dw_dg_control           
         SET    acct_valval_alt_amt = @acct_valval_alt_amt,           
          acct_eqtval_alt_amt = @acct_eqtval_alt_amt,           
          acct_fival_alt_amt = @acct_fival_alt_amt,           
          acct_curbal_alt_amt = @acct_curbal_alt_amt,           
          acct_nprval_alt_amt = @acct_nprval_alt_amt,           
          acct_crvl_alt_amt = @acct_crvl_alt_amt,           
          acct_covl_alt_amt = @ACCT_COVL_ALT_AMT,           
          acct_ugl_alt_amt = @acct_ugl_alt_amt,           
          acct_uglcur_alt_amt = @acct_uglcur_alt_amt,           
          acct_uglinv_alt_amt = @acct_uglinv_alt_amt,           
          acct_eai_alt_amt = @acct_eai_alt_amt,           
          acct_cureqv_alt_amt = @acct_cureqv_alt_amt,           
          acct_othrval_alt_amt = @acct_othrval_alt_amt,           
          acct_accrinc_alt_amt = @acct_accrinc_alt_amt,           
          acct_totqty_amt = @acct_totqty_amt,           
          dg_count_num = @dg_count_num,           
          dld_cmpltn_tms = @datetime_now,           
          batch_id = @batch_id --  Added By Manish, 04222010             
         WHERE  data_grp_ctl_num = @data_grp_ctl_num           
        END /*END    Delete any existing position records*/ --End 5          
      /*** Insert all position for that business key ***/           
      INSERT INTO netikip.dbo.position_dg           
         (rcd_id,           
          acct_id,           
          adjst_tms,           
          alt_curr_cde,           
          alt_curr_nme,           
          as_of_tms,           
          bk_id,           
          crvl_cmb_amt,           
          crvl_alt_cmb_amt,           
          crvl_cmpnt_id,           
          crvl_typ,           
          crvl_perut_cmb_amt,           
          curr_yld_cmb_rte,           
          data_grp_ctl_num,           
          deal_id,           
          dur_rte,           
          eai_amt,           
          eai_alt_amt,           
          fx_alt_cmb_rte,           
          id_ctxt_typ,           
          inc_proj_cmb_rte,           
          instr_id,           
          inq_basis_num,           
          iss_id,           
          iss_rate_txt,           
          asset_class_mnem,           
          ldgr_id,           
          ldgr_nme,           
          ldgr_typ,           
          local_curr_cde,           
          local_curr_nme,           
          long_short_ind,           
          nls_cde,           
          org_id,           
          orig_quantity,           
          pos_id,           
          prc_tms,           
          prc_exch_mnem,           
          prc_srce_typ,           
          prc_valid_typ,           
          prin_inc_ind,           
          putcall_tms,           
          qlty_rat_srce_typ,           
          qlty_rat_typ,           
          quantity,           
          ref_acct_id,           
          shr_out_qty,           
          trm_to_mat_rte,           
          ut_prc_cmb_amt,           
          ut_prc_alt_cmb_amt,           
          uglcur_alt_cmb_amt,           
          ugl_cmb_amt,           
          ugl_alt_cmb_amt,           
          uglinv_alt_cmb_amt,           
          fld1_amt,           
          fld2_amt,           
          fld3_amt,           
          fld4_amt,           
          fld5_amt,           
          fld6_amt,           
          fld7_amt,           
          fld8_amt,           
          fld1_rte,           
          fld2_rte,           
          fld3_rte,           
          fld4_rte,           
          fld1_tms,           
          fld2_tms,           
          fld1_txt,           
          fld2_txt,           
          valu_typ,           
          valval_cmb_amt,           
          valval_alt_cmb_amt,           
          yld_to_mat_rte,           
          yield_calc_dte,           
          enc_ind,           
          aimr_disc_ind,           
          org_crvl_amt,           
          org_crvl_alt_amt,           
          src_sys_id,           
          fld1_qty,         
          fld2_qty,           
          fld3_txt,           
          fld4_txt,           
          fld1_nme,           
          fld2_nme,           
          fld1_desc,           
          fld2_desc,           
          deal_nme,           
          ref_acct_nme,           
          custodn_id,           
          custodn_nme,           
          strtgy_id,           
          strtgy_nme,           
          busunit_cust_id,           
          busunit_cust_nme,           
          sub_busunit_cust_id,           
          sub_busunit_cust_nme,           
          accrinc_cmb_amt,           
          accrinc_alt_cmb_amt,           
          div_adj_rte,           
          rte_basis,           
          rte_cmb_amt,           
          sprd_rte,           
          fld5_rte,           
          fld6_rte,           
          fld7_rte,           
          fld8_rte,           
          fld9_rte,           
          fld10_rte,           
          fld11_rte,           
          fld12_rte,           
          fld9_amt,           
          fld10_amt,           
          fld11_amt,           
          fld12_amt,           
          fld13_amt,           
          fld14_amt,           
          fld15_amt,           
          fld16_amt,           
          fld17_amt,           
          fld18_amt,           
          fld19_amt,           
          fld20_amt,           
          fld21_amt,           
          fld22_amt,           
          fld23_amt,           
          fld24_amt,           
          fld25_amt,           
          fld26_amt,           
          fld27_amt,           
          fld28_amt,           
          fld29_amt,           
          fld30_amt,           
          fld31_amt,           
          fld32_amt,           
          fld33_amt,           
          fld34_amt,           
          fld35_amt,           
          fld36_amt,           
          fld37_amt,           
          fld38_amt,           
          fld39_amt,           
          fld40_amt,           
          curr01_cde,           
          curr02_cde,           
          curr03_cde,           
          curr04_cde,           
          curr05_cde,           
          curr06_cde,           
          curr07_cde,           
          curr08_cde,           
          curr09_cde,           
          curr10_cde,           
          curr11_cde,           
          curr12_cde,           
          curr13_cde,           
          curr14_cde,           
          fld01_ind,           
          fld02_ind,           
          fld03_ind,           
          fld04_ind,           
          fld05_ind,           
          fld06_ind,           
          fld07_ind,           
          fld08_ind,     
          fld09_ind,           
          fld10_ind,                     
          fld11_ind,           
          fld12_ind,           
          fld13_ind,           
          fld14_ind,           
          fld03_tms,           
          fld04_tms,           
          lst_chg_tms,           
          lst_chg_usr_id,           
          batch_id,        
          FLD05_TMS,        
          FLD06_TMS,        
          FLD07_TMS,        
          FLD08_TMS,        
          FLD09_TMS,        
          FLD10_TMS,        
          fld41_amt,        
          fld42_amt,        
          fld43_amt,        
          fld44_amt,        
          fld45_amt,        
          fld46_amt,        
          fld47_amt,        
          fld48_amt,        
          fld49_amt,        
          fld50_amt,        
          fld3_desc,        
          fld4_desc,        
          fld5_desc,        
          fld6_desc,        
          fld7_desc,        
          fld8_desc,        
          fld9_desc,        
          fld10_desc,        
          fld11_desc,        
          fld12_desc,        
          fld13_desc,
		  --Start SMehrotra 01032013    --
		  Base_To_System_FX_Rt,
		  System_Currency_Id,
		  Original_Sys_Curr_Unit_Prc,
		  Original_Local_Curr_Unit_Prc,
		  Sys_Curr_Unit_Prc,
		  Sys_Curr_Amortized_Cost_Amt,
		  Sys_Curr_Amortization_Amt,
		  Sys_Curr_Accrued_Income_Amt,
		  Sys_Curr_Unrealized_GL_Amt,
		  Revalued_Unrealized_GL_Amt
		 --End SMehrotra 01032013    --            
          ,lev_3_hier_num )  --SMehrotra 01272014  -- 01282014 Mpadala MApped to WorkunitSeq as Lev3_Hire_num shld be used.
      SELECT DISTINCT ISNULL(rcd_id, @DESC_SRCE_TYP),           
          acct_id,           
          adjst_tms,           
          alt_curr_cde,           
          alt_curr_nme,           
          as_of_tms,           
          bk_id,           
          crvl_cmb_amt,           
          crvl_alt_cmb_amt,           
          crvl_cmpnt_id,           
          crvl_typ,           
          crvl_perut_cmb_amt,           
          curr_yld_cmb_rte,           
          @data_grp_ctl_num,           
          deal_id,           
          dur_rte,           
          eai_amt,           
          eai_alt_amt,           
          fx_alt_cmb_rte,           
          id_ctxt_typ,           
          inc_proj_cmb_rte,           
          instr_id,           
          inq_basis_num,           
          iss_id,           
          iss_rate_txt,           
          asset_class_mnem,           
          ldgr_id,           
          ldgr_nme,           
          ldgr_typ,           
          local_curr_cde,           
          local_curr_nme,           
          long_short_ind,           
          nls_cde,           
          org_id,           
          orig_quantity,           
          pos_id,           
          prc_tms,           
          prc_exch_mnem,           
          prc_srce_typ,           
          prc_valid_typ,           
          prin_inc_ind,           
          putcall_tms,           
          qlty_rat_srce_typ,           
          qlty_rat_typ,           
          quantity,           
          ref_acct_id,           
          shr_out_qty,           
          trm_to_mat_rte,           
          ut_prc_cmb_amt,           
          ut_prc_alt_cmb_amt,           
          uglcur_alt_cmb_amt,           
          ugl_cmb_amt,           
          ugl_alt_cmb_amt,           
          uglinv_alt_cmb_amt,           
          fld1_amt,           
          fld2_amt,           
          fld3_amt,           
          fld4_amt,           
          fld5_amt,           
          fld6_amt,           
          fld7_amt,           
          fld8_amt,           
          fld1_rte,           
          fld2_rte,           
          fld3_rte,           
          fld4_rte,           
          fld1_tms,           
          fld2_tms,           
          fld1_txt,           
          fld2_txt,           
          valu_typ,           
          valval_cmb_amt,           
          valval_alt_cmb_amt,           
          yld_to_mat_rte,           
          yield_calc_dte,           
          enc_ind,           
          aimr_disc_ind,           
          org_crvl_amt,           
          org_crvl_alt_amt,           
          src_sys_id,           
          fld1_qty,           
          fld2_qty,           
          fld3_txt,           
          fld4_txt,           
          fld1_nme,           
          fld2_nme,           
          fld1_desc,     
          fld2_desc,           
          deal_nme,           
          ref_acct_nme,           
          custodn_id,           
          custodn_nme,           
          strtgy_id,           
          strtgy_nme,           
          busunit_cust_id,           
          busunit_cust_nme           
          /*busunit_cust_nme -- changed (to lev_1_hier_nme) by Shash 08/18/2009*/,           
          sub_busunit_cust_id,           
          sub_busunit_cust_nme           
          /*sub_busunit_cust_nme -- changed (to lev_2_hier_nme) by Shash 08/18/2009*/,           
          accrinc_cmb_amt,           
          accrinc_alt_cmb_amt,           
          div_adj_rte,           
          rte_basis,           
          rte_cmb_amt,           
          sprd_rte,           
          fld5_rte,           
          fld6_rte,           
          fld7_rte,           
          fld8_rte,           
          fld9_rte,           
          fld10_rte,           
          fld11_rte,           
          fld12_rte,           
          fld9_amt,           
          fld10_amt,           
          fld11_amt,           
          fld12_amt,           
          fld13_amt,           
          fld14_amt,           
          fld15_amt,           
          fld16_amt,           
          fld17_amt,           
          fld18_amt,           
          fld19_amt,           
          fld20_amt,           
          fld21_amt,           
          fld22_amt,           
          fld23_amt,           
          fld24_amt,           
          fld25_amt,           
          fld26_amt,           
          fld27_amt,           
          fld28_amt,           
          fld29_amt,           
          fld30_amt,           
          fld31_amt,           
          fld32_amt,           
          fld33_amt,           
          fld34_amt,           
         fld35_amt,           
          fld36_amt,           
          fld37_amt,           
          fld38_amt,           
          fld39_amt,           
          fld40_amt,           
          curr01_cde,           
          curr02_cde,           
          curr03_cde,           
          curr04_cde,           
          curr05_cde,           
          curr06_cde,           
          curr07_cde,           
          curr08_cde,           
          curr09_cde,           
          curr10_cde,           
          curr11_cde,           
          curr12_cde,           
          curr13_cde,           
          curr14_cde,           
          fld01_ind,           
          fld02_ind,           
          fld03_ind,           
          fld04_ind,           
          fld05_ind,           
          fld06_ind,           
          fld07_ind,           
          fld08_ind,           
          fld09_ind,           
          fld10_ind,           
          fld11_ind,           
          fld12_ind,           
          fld13_ind,           
          fld14_ind,           
          fld03_tms,           
          fld04_tms,           
          CURRENT_TIMESTAMP ,           
          src_sys_id,           
          qa.batchid,        
         qa.FLD05_TMS,        
         qa.FLD06_TMS,        
         qa.FLD07_TMS,        
         qa.FLD08_TMS,        
         qa.FLD09_TMS,        
         qa.FLD10_TMS,        
         qa.fld41_amt,        
         qa.fld42_amt,        
         qa.fld43_amt,        
         qa.fld44_amt,        
         qa.fld45_amt,        
         qa.fld46_amt,        
         qa.fld47_amt,        
         qa.fld48_amt,        
         qa.fld49_amt,        
         qa.fld50_amt,        
         qa.fld3_desc,        
         qa.fld4_desc,        
         qa.fld5_desc,        
         qa.fld6_desc,        
         qa.fld7_desc,        
         qa.fld8_desc,        
         qa.fld9_desc,        
         qa.fld10_desc,        
         qa.fld11_desc,        
         qa.fld12_desc,        
         qa.fld13_desc,
		/*MChawla,04/23/2013 -Updated the table name    */  		 
		--Start SMehrotra 01032013    --
		 qa.Base_To_System_FX_Rt,
		 qa.System_Currency_Id,
		 qa.Original_Sys_Curr_Unit_Prc,
		 qa.Original_Local_Curr_Unit_Prc,
		 qa.Sys_Curr_Unit_Prc,
		 qa.Sys_Curr_Amortized_Cost_Amt,
		 qa.Sys_Curr_Amortization_Amt,
		 qa.Sys_Curr_Accrued_Income_Amt,
		 qa.Sys_Curr_Unrealized_GL_Amt,
		 qa.Revalued_Unrealized_GL_Amt            
        --End SMehrotra 01032013    -- 
		,qa.WorkUnitSeq   --SMehrotra 01272014  -- 01282014 Mpadala MApped to WorkunitSeq as Lev3_Hire_num shld be used. 
         --FROM   dbo.dp_t_positionactivity qa              
      FROM   dbo.dp_t_positionactivity qa           
      --             INNER JOIN DP_T_PositionActivityTarget qt             
      --                     ON  qt.ActivityId = qa.Id             
      --                     AND qt.BatchId = @batch_id             
      --                     AND qt.BatchTargetId = @batchtarget_id             
      --                AND qt.WorkUnitSeq = @work_unit_seq             
      WHERE  qa.batchid = @batch_id           
          AND org_id = @org_id           
          AND bk_id = @bk_id           
          AND acct_id = @acct_id           
          AND as_of_tms = @end_tms           
          AND adjst_tms = @end_adjst_tms           
          AND inq_basis_num = @inq_basis_num           
          AND ISNULL(qa.ldgr_nme,'') <> @ldgr_nmeINVM          
          
      SET @row_ins_ctr = @row_ins_ctr + @dg_count_num             
      IF @upd_at_opt = @upd_at_optY           
        BEGIN /*    Now Update ACCT_TOTALS table */  --Begin 6       
                 
         EXECUTE @ret_cde = dbo.Que_at_mrktval_update           
        @at_instruct_id = @at_instrct_id,           
        @acct_id = @acct_id,           
        @bk_id = @bk_id,           
        @org_id = @org_id,           
        @start_tms = @START_TMS,           
        @start_adjust_tms = @START_ADJST_TMS,           
        @end_tms = @as_of_tms,           
        @end_adjust_tms = @adjst_tms,           
        @inq_basis_num = @inq_basis_num,           
        @cls_set_id = @cls_set_id,           
        @lst_chg_tms = @datetime_now,           
        @batch_num = @CurrFlag,           
        @dec001_val = @acct_valval_alt_amt,           
        @dec002_val = @acct_eqtval_alt_amt,           
        @dec003_val = @acct_fival_alt_amt,           
        @dec004_val = @acct_curbal_alt_amt,           
        @dec005_val = @acct_nprval_alt_amt,           
        @dec006_val = @acct_crvl_alt_amt,           
        @dec007_val = @ACCT_COVL_ALT_AMT,           
        @dec008_val = @acct_ugl_alt_amt,           
        @dec009_val = @acct_uglcur_alt_amt,           
        @dec010_val = @acct_uglinv_alt_amt,           
        @dec011_val = @acct_eai_alt_amt,           
        @dec012_val = @dg_count_num,           
        @dec013_val = @acct_cureqv_alt_amt,           
        @dec014_val = @acct_othrval_alt_amt,           
        @dec015_val = @acct_accrinc_alt_amt,           
        @dec016_val = @acct_totqty_amt,         
		@dec017_val = @dec017,-- MChawla	01262014
        @dec018_val = @dec018,-- MChawla	01262014
        @dec019_val = @dec019 -- MChawla	01262014  
          
         IF @ret_cde <> 0           
         BEGIN  --Begin 7          
          SET @rtn_msg =           
              'Error in updating Account Totals table.  Update on ' +           
              @acct_id +           
               ',' + @bk_id           
              + ',' + @org_id + ',' + CONVERT(CHAR(20), @end_tms, 121           
                    )           
              +           
               ' is ignored'           
          
          PRINT @rtn_msg           
         END --End 7          
        END /*END Now Update ACCT_TOTALS table */ -- End 6       
        -- spurcell 03/06/2013 proc exec not needed by mchawla         
        --EXEC @ret_cde = Que_acct_stat_upd           
        -- @data_grp_def_id = 'POSITION',           
        -- @data_grp_ctl_num = @data_grp_ctl_num,           
        -- @extr_ctl_id = @data_grp_ctl_num_ch,           
        -- @data_grp_ctl_id = @data_grp_ctl_num_ch,           
        -- @org_id = @org_id,           
        -- @bk_id = @bk_id,           
        -- @acct_id = @acct_id,           
        -- @alt_curr_cde = @alt_curr_cde,           
        -- @crvl_typ = @crvl_typ,           
        -- @crvl_cmpnt_id = @crvl_cmpnt_id,           
        -- @covl_typ = @covl_typ,           
        -- @covl_cmpnt_id = @covl_cmpnt_id,           
        -- @desc_srce_typ = @desc_srce_typ,           
        -- @iss_incs_id = @iss_incs_id,           
        -- @issr_incs_id = @issr_incs_id,           
        -- @valu_typ = @valu_type,           
       -- @qlty_rat_srce_typ = @qlty_rat_srce_typ,           
        -- @nls_cde = @nls_cde,           
        -- @end_tms = @as_of_tms,           
        -- @end_adjst_tms = @adjst_tms,           
        -- @Start_tms = @START_TMS,           
        -- @Start_adjst_tms = @START_ADJST_TMS,           
        -- @cls_set_id = @cls_set_id,           
        -- @inq_basis_num = @inq_basis_num,           
        -- @acct_valval_alt_amt = @acct_valval_alt_amt,           
        -- @acct_eqtval_alt_amt = @acct_eqtval_alt_amt,           
        -- @acct_fival_alt_amt = @acct_fival_alt_amt,           
        -- @acct_curbal_alt_amt = @acct_curbal_alt_amt,           
        -- @acct_nprval_alt_amt = @acct_nprval_alt_amt,           
        -- @acct_crvl_alt_amt = @acct_crvl_alt_amt,           
        -- @acct_covl_alt_amt = @acct_covl_alt_amt,           
        -- @acct_ugl_alt_amt = @acct_ugl_alt_amt,           
        -- @acct_uglcur_alt_amt = @acct_uglcur_alt_amt,           
        -- @acct_uglinv_alt_amt = @acct_uglinv_alt_amt,           
        -- @acct_eai_alt_amt = @acct_eai_alt_amt,           
        -- @dg_count_num = @dg_count_num,           
        -- @created_tms = @datetime_now,           
        -- @dld_cmpltn_tms = @datetime_now,           
        -- @dld_status_ind = 'C',           
        -- @acct_cureqv_alt_amt = @acct_cureqv_alt_amt           
          
      IF @ret_cde <> 0           
        BEGIN  --Begin 8           
         SET @rtn_msg =           
          'Error in updating Account Stats table.  Update on '           
          +           
          @acct_id + ','           
           + @bk_id +           
                ',' + @org_id + ',' +           
           CONVERT(CHAR(20), @end_tms, 121) +           
          ' is ignored'           
          
         PRINT @rtn_msg           
        END -- End 8          
          
      SET @running_ctr = @running_ctr + @dg_count_num           
          
      SET @rec_num = @rec_num + 1           
     END/*END TKEY LOOP*/ -- End 2          
      /*** Insert Classification Set data for this account */           
      PRINT 'Loading classification records...'           
          --Start SMehrotra 01032013 
      EXEC @ReturnCode = dbo.Inf_que_transfer_classif @batch_id = @batch_id

			IF (@ReturnCode <> 0)
			BEGIN
				SET @msg = 'Unable to get batch id from dbo.Inf_que_transfer_classif ' + cast(@returncode AS VARCHAR(12));

				RAISERROR (
						@msg
						,16
						,1
						);
			END;
 
          --End SMehrotra 01032013 
      -- , @batchtarget_id = @batchtarget_id, @work_unit_seq = @work_unit_seq  -- no need           
      PRINT 'Classification load completed... '           
          
      /*             
      ** Update the system table with the correct date             
      ** This has now moved to a new stored procedure, here for backward compatability             
      */           
      IF @systemTableUpdate = 'true'           
     BEGIN  --Begin 9          
      --exec que_upd_system_tms @data_grp_def_id ='POSITION' --changed Shash Patel 07/06/2009             
      PRINT 'System table being updated '           
     END  -- End 9          
          
        --Start SMehrotra 01032013   
      UPDATE dbo.INF_FILE_BATCHID           
      SET    End_TMS = CURRENT_TIMESTAMP,           
             Current_Flag = @CurrFlag,           
             Status = @Status,          
             IPCount = @row_ins_ctr,           
			 Error_Flag = CASE           
            WHEN (SELECT TOP 1 1           
            FROM   dbo.INF_DP_Log          
            WHERE  batchid = @BATCH_ID) = 1 THEN 1           
            ELSE 0           
          END           
      WHERE  BATCH_ID = @BATCH_ID;    
	  --End SMehrotra 01032013        
     /*Informatica ETL END_TMS and ERROR_Flag update */           
          
 IF @@TRANCOUNT > 0  
  COMMIT TRANSACTION;         
           
  END TRY       
        
  BEGIN CATCH                    
   
 --vperala   08/05/2013 Start  
 IF @@TRANCOUNT > 0   
  ROLLBACK TRANSACTION;  
        
    -- Test whether the transaction is uncommittable.  
    IF (XACT_STATE()) = -1  
    BEGIN  
        PRINT 'The transaction is in an uncommittable state.' +  
              ' Rolling back transaction.'  
  ROLLBACK TRANSACTION;  
    END  
      
    -- Test whether the transaction is active and valid.  
    IF (XACT_STATE()) = 1  
    BEGIN  
        PRINT 'The transaction is committable.' +  ' Committing transaction.'  
        COMMIT TRANSACTION;     
    END  
    --vperala   08/05/2013 End   
                   
    SET @ErrorMessage  = Error_message()      
    SET @ErrorSeverity = Error_severity()      
    SET @ErrorLine     = error_line();      
      
    SET @ErrorMessage = 'Error on line ' + CAST(@ErrorLine as varchar(10)) + ' - ' + @ErrorMessage      
        
    PRINT 'ERROR: severe error in Inf_que_transfer_positionactivity'      
        
    RAISERROR(@ErrorMessage,@ErrorSeverity,1)     
       
                   
    END CATCH       
      
    --vperala   08/05/2013 Start  
    IF OBJECT_ID('tempdb..#tkey') IS NOT NULL          
  DROP TABLE #tkey;   
 --vperala   08/05/2013 End   
END -- End 1       
