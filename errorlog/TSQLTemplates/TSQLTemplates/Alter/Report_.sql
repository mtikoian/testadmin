USE netikip
GO

SET STATISTICS IO ON

DECLARE @acct_id CHAR(12)
	,@bk_id CHAR(4)
	,@org_id CHAR(4)
	,@inq_basis_num INT
	,@start_tms DATETIME
	,@start_adjst_tms DATETIME
	,@end_tms DATETIME
	,@end_adjst_tms DATETIME
	,@cls_set_id CHAR(8)
	,@date_typ_num INT
	,@adjust_ind INT
	,@inq_num INT
	,@qry_num INT
	,@pselect_txt VARCHAR(4000)
	,@porderby_txt VARCHAR(255)
	,@pfilter_txt VARCHAR(1000)
	,@pgroupby_txt VARCHAR(255)
	,@row_limit INT
	,@val_curr_cde CHAR(3)

--exec p_Dynamic_WHV_Summary
-- 'WHVALL      ','GUSR','GUSR',5,'2014-05-31 23:59:59',default,'2014-05-31 23:59:59',default,'NAM-P   ',5,0,16895,16895,'A.ProgramName, A.StrategyName, A.Channel, sum(NewAccounts), sum(NewAccountMarketValue), sum(TerminatedAccounts), sum(TerminatedAccount
--sMarketValue), sum(Inflows), sum(InflowsMarketValue), sum(Outflows), sum(OutflowsMarketValue), sum(NetCapitalChange)','A.ProgramName Asc, A.StrategyName Asc, A.Channel Asc',default,'A.ProgramName, A.StrategyName, A.Channel',0,default
SET @acct_id = 'WHVALLIPC'
SET @bk_id = 'GUSR'
SET @org_id = 'GUSR'
SET @inq_basis_num = 5
SET @start_tms = '2014-05-31 23:59:59'
SET @start_adjst_tms = NULL
SET @end_tms = '2014-05-31 23:59:59'
SET @end_adjst_tms = NULL
SET @cls_set_id = 'NAM-P'
SET @date_typ_num = 5
SET @adjust_ind = 0
SET @inq_num = 15272
SET @qry_num = 15272
SET @pselect_txt = 'A.ProgramName, A.StrategyName, A.Channel, sum(NewAccounts), sum(NewAccountMarketValue), sum(TerminatedAccounts), sum(TerminatedAccountsMarketValue), sum(Inflows), sum(InflowsMarketValue), sum(Outflows), sum(OutflowsMarketValue), sum(NetCapitalChange)'
SET @porderby_txt = 'A.ProgramName Asc, A.StrategyName Asc, A.Channel Asc'
SET @pfilter_txt = NULL
SET @pgroupby_txt = 'A.ProgramName, A.StrategyName, A.Channel'
SET @row_limit = 0
SET @val_curr_cde = NULL

DECLARE @app_user_id CHAR(8);
DECLARE @acct_type CHAR(1);
DECLARE @Valid INT;
DECLARE @errno INT;
DECLARE @msg VARCHAR(200);
DECLARE @ReturnCode INTEGER;
DECLARE @USER_ID CHAR(4);
DECLARE @BK_ID_SMA CHAR(4);
DECLARE @BK_ID_UMA CHAR(4);
DECLARE @BK_ID_IPC CHAR(4);
DECLARE @End_SMA_Date DATETIME;
DECLARE @End_Date_check DATETIME;
DECLARE @End_Date_format1 DATETIME;
DECLARE @End_SMA_Dt_StartofMonth DATETIME;
DECLARE @DefaultDt DATETIME;

/*-------------------------Drop temp tables-------------------------------------------*/
IF OBJECT_ID('tempdb..#tempacct') IS NOT NULL
	DROP TABLE #tempacct;

IF OBJECT_ID('tempdb..#tempacctdate') IS NOT NULL
	DROP TABLE #tempacctdate;

SET @DefaultDt = '01/01/1900';
SET @End_Date_format1 = dateadd(day, datediff(day, 0, @end_tms) + 0, 0);
SET @End_Date_check = dateadd(second, - 1, dateadd(day, datediff(day, - 1, @end_tms), 0));--convert(VARCHAR(25), @end_tms, 121);
SET @End_SMA_Date = @End_Date_format1;
SET @End_SMA_Dt_StartofMonth = DATEADD(m, DATEDIFF(m, 0, @end_tms), 0);
SET @BK_ID_SMA = 'SMA';--Book ID SMA
SET @BK_ID_UMA = 'UMA';--Book ID UMA
SET @BK_ID_IPC = 'HF';--Book ID Hedge Funds
SET @USER_ID = 'HOST';-- session id
SET @errno = 0;
SET @acct_id = LTRIM(RTRIM(@acct_id));

--SET @app_user_id = dbo.fndw_appuser();
CREATE TABLE #tempacct (acct_id VARCHAR(20) NOT NULL PRIMARY KEY CLUSTERED);

CREATE TABLE #tempacctdate (
	ACCT_ID VARCHAR(12) NOT NULL PRIMARY KEY CLUSTERED
	,END_ADJUST_TMS DATETIME
	,PRIOR_DAY_ACCT_CLS_DTE DATETIME
	,INQ_BASIS_NUM INT
	,TERMINATEDACCTCOUNTS INT
	,NEWACCOUNTS INT
	);

--Check what type of account I= individual G= Group                             
SELECT @acct_type = ACCT_GRP_TYP
FROM dbo.IVW_ACCT
WHERE (
		USER_ID = @USER_ID
		OR USER_ID = @app_user_id
		)
	AND ACCT_ID = @ACCT_ID
	AND BK_ID = @bk_id
	AND ORG_ID = @org_id;

SELECT @acct_type

IF (
		@acct_type = 'U'
		OR @acct_type = 'G'
		) -- U represents normal accounts and G indicates group accounts
BEGIN
	INSERT INTO #tempacct (acct_id)
	--SELECT DISTINCT acct_id
	--FROM dbo.AcctGroupView AGV
	--WHERE AGV.GRP_ACCT_ID = @acct_id;
	SELECT DISTINCT acct_id
	FROM (
		SELECT GRP_ORG_ID = acp.ORG_ID
			,GRP_BK_ID = acp.BK_ID
			,GRP_ACCT_ID = acp.ACCT_ID
			,GRP_USER_ID = acp.USER_ID
			,ORG_ID = acp.PART_ORG_ID
			,BK_ID = acp.PART_BK_ID
			,ACCT_ID = acp.PART_ACCT_ID
			,USER_ID = acp.PART_USER_ID
			,ACCT_NME = usr2.ACCT_NME
			,ACCT_TYP = usr2.ACCT_GRP_TYP
			,START_TMS = START_TMS
			,END_TMS = END_TMS
		FROM IVW_ACGP acp
		INNER JOIN (
			SELECT
				-- Account Information
				ACCT_USER_ID = a.USER_ID
				,USER_ID = dwUser.APP_USER_ID
				,a.ORG_ID
				,a.BK_ID
				,a.ACCT_ID
				,a.ACCT_CLS_DTE
				,a.ACCT_CLS_REAS_TYP
				,a.ACCT_OPEN_DTE
				,a.ACCT_OPEN_REAS_TYP
				,a.ACCT_STAT_TYP
				,a.CROSS_REF_ID
				,a.FISCAL_YR_END_TYP
				,ACT_INSTR_ID = a.INSTR_ID
				,a.PLNE_PRODLN_ID
				,a.PLNE_ORG_ID
				,a.PLNE_NME
				,a.RESP_DTE
				,a.TERMIN_DTE
				,a.NAME_SORT_KEY_TXT
				,a.ACCT_NME
				,a.ACCT_DESC
				,a.ACCT_MNEM
				,a.ACCT_GRP_OID
				,a.SUBDIV_ID
				,a.ACCT_GRP_TYP
				,a.GRP_PURP
				,a.MGR_CUST_ID
				,a.INQ_BASIS_NUM
				,a.INVEST_CLS_SET_ID
				,a.TRANS_CLS_SET_ID
				,a.ALT_CURR_CDE
				,a.NLS_CDE
				,a.CUST_ID
				,a.LEV_SRVC_MNEM
				,a.ACCT_REST_IND_TYP
				,a.MRGN_DLQNCY_IND
				,a.DPSTRY_AFRM_TYP
				,a.THPTY_AFRM_INST_ID
				,ACT_LST_CHG_TMS = a.LST_CHG_TMS
				,ACT_LST_CHG_USR_ID = a.LST_CHG_USR_ID
				,ACT_FLD1_TXT = a.FLD1_TXT
				,ACT_FLD2_TXT = a.FLD2_TXT
				,ACT_FLD3_TXT = a.FLD3_TXT
				,ACT_FLD4_TXT = a.FLD4_TXT
				,ACT_FLD5_TXT = a.FLD5_TXT
				,ACT_FLD6_TXT = a.FLD6_TXT
				,ACT_FLD7_TXT = a.FLD7_TXT
				,ACT_FLD8_TXT = a.FLD8_TXT
				,ACT_FLD1_DESC = a.FLD1_DESC
				,ACT_FLD2_DESC = a.FLD2_DESC
				,ACT_FLD3_DESC = a.FLD3_DESC
				,ACT_FLD4_DESC = a.FLD4_DESC
				,ACT_FLD1_TMS = a.FLD1_TMS
				,ACT_FLD2_TMS = a.FLD2_TMS
				,ACT_FLD3_TMS = a.FLD3_TMS
				,ACT_FLD4_TMS = a.FLD4_TMS
				,a.CUST1_ID
				,a.CUST2_ID
				,a.CUST3_ID
				,a.CUST4_ID
				,a.PERF_MEAS_IND
				,a.WEB_ID
				,a.ACCT_BUS_TYP
				,a.REF_ACCT_ID
				,a.ACCT_BUS_TYP_NME
				,a.COL_ACCT_ID
				,a.COL_BK_ID
				,a.COL_ORG_ID
				,a.DISCLOSURE_NME
				,a.LDG_SRV_IND
				,a.PROXY_HDLG_NME
				,a.PROXY_PWR_NME
				,a.SRC_SYS_ID
				,a.DLD_CMPLTN_TMS
				,
				-- 10/23/00 Added Account Level Total Fields
				a.LST_BUSCLS_DTE
				,a.LST_ADJST_DTE
				,a.ACCT_VALVAL_ALT_AMT
				,a.ACCT_CRVL_ALT_AMT
				,a.ACCT_CURBAL_ALT_AMT
				,a.ACCT_FLD1_AMT
				,a.ACCT_FLD2_AMT
				,a.DG_COUNT_NUM
				,a.EXT_ACCT_ID
				,a.CUSTODN_CUST_ID
				,ACT_INVMGR_CUST_ID = a.INVMGR_CUST_ID
			FROM IVW_USER u
			JOIN PERMISSION p ON (u.USER_CLS_ID = p.USER_CLS_ID)
			-- AND u.USER_ID = dbo.fndw_appuser())
			JOIN (
				SELECT *
				FROM DW_CURRENT_USER
				WHERE process_id = 71
				) dwUser ON u.USER_ID = 'TSUmcha1'
			JOIN IVW_ACCT a ON (
					a.ACCT_ID = p.ACCT_ID
					AND a.BK_ID = p.BK_ID
					AND a.ORG_ID = p.ORG_ID
					AND a.USER_ID = 'HOST'
					)
			) usr2 ON (
				acp.USER_ID = 'HOST'
				OR acp.USER_ID = 'TSUmcha1'
				)
			AND acp.PART_ACCT_ID = usr2.ACCT_ID
			AND acp.PART_BK_ID = usr2.BK_ID
			AND acp.PART_ORG_ID = usr2.ORG_ID
		WHERE acp.ACCT_ID = 'WHVALLIPC'
		) a
END
ELSE
BEGIN
	INSERT INTO #tempacct (acct_id)
	SELECT @acct_id
END

INSERT INTO #tempacctdate (
	ACCT_ID
	,END_ADJUST_TMS
	,PRIOR_DAY_ACCT_CLS_DTE
	,INQ_BASIS_NUM
	,TERMINATEDACCTCOUNTS
	,NEWACCOUNTS
	)
SELECT AT.acct_id
	,MAX(AT.end_adjust_tms)
	,dateadd(second, - 1, dateadd(day, datediff(day, - 1, DATEADD(d, - 1, MAX(A.IPCTERMINATIONDATE))), 0))
	,1
	,1
	,0
FROM dbo.ACCT_TOTALS AT
INNER JOIN #tempacct TEMP ON TEMP.acct_id = AT.acct_id
	AND AT.inq_basis_num = @inq_basis_num
	AND AT.BK_ID IN (
		@BK_ID_SMA
		,@BK_ID_UMA
		,@BK_ID_IPC
		)
LEFT JOIN dbo.VW_SEI_ACCOUNTCHARACTERISTICSNETIK A ON AT.ACCT_ID = A.IPCSLEEVESEIACCOUNTNO
WHERE A.IPCPortfolioStatus = 'Closed'
	AND A.IPCTERMINATIONDATE BETWEEN @End_SMA_Dt_StartofMonth
		AND @End_Date_format1
GROUP BY AT.acct_id
	,A.IPCPortfolioStatus

UNION ALL

SELECT AT.acct_id
	,MAX(AT.end_adjust_tms)
	,dateadd(second, - 1, dateadd(day, datediff(day, - 1, @End_Date_format1), 0))
	,@inq_basis_num
	,0
	,1
FROM dbo.ACCT_TOTALS AT
INNER JOIN #tempacct TEMP ON TEMP.acct_id = AT.acct_id
	AND AT.inq_basis_num = @inq_basis_num
	AND AT.BK_ID IN (
		@BK_ID_SMA
		,@BK_ID_UMA
		,@BK_ID_IPC
		)
LEFT JOIN dbo.VW_SEI_ACCOUNTCHARACTERISTICSNETIK A ON AT.ACCT_ID = A.IPCSLEEVESEIACCOUNTNO
WHERE A.IPCPortfolioStatus = 'Open'
	AND A.IPCAccountInceptionDate BETWEEN @End_SMA_Dt_StartofMonth
		AND @End_Date_format1
GROUP BY AT.acct_id
	,A.IPCPortfolioStatus;

SELECT *
FROM #tempacctdate

SELECT '1'
	,M.ProgramName
	,M.StrategyName
	,M.Channel
	,sum(M.NewAccounts)
	,sum(M.NewAccountMarketValue)
	,sum(M.TerminatedAccounts)
	,sum(M.TerminatedAccountsMarketValue)
	,sum(M.Inflows)
	,sum(M.InflowsMarketValue)
	,sum(M.Outflows)
	,sum(M.OutflowsMarketValue)
	,sum(M.NetCapitalChange)
FROM (
	SELECT A.ProgramName
		,A.StrategyName
		,A.Channel
		,sum(tmpact.NewAccounts) AS NewAccounts
		,sum(A.NewAccountMarketValue) AS NewAccountMarketValue
		,sum(tmpact.TERMINATEDACCTCOUNTS) AS TerminatedAccounts
		,sum(A.TerminatedAccountsMarketValue) AS TerminatedAccountsMarketValue
		,sum(A.Inflows) AS Inflows
		,sum(A.InflowsMarketValue) AS InflowsMarketValue
		,sum(A.Outflows) AS Outflows
		,sum(A.OutflowsMarketValue) AS OutflowsMarketValue
		,sum(A.NetCapitalChange) AS NetCapitalChange
	FROM #tempacctdate tmpact
	INNER JOIN dbo.v_whv_acctview A ON A.acct_id = tmpact.acct_id
		AND A.end_tms = tmpact.PRIOR_DAY_ACCT_CLS_DTE
		AND A.inq_basis_num = tmpact.inq_basis_num
		AND A.BK_ID IN (
			@BK_ID_SMA
			,@BK_ID_UMA
			,@BK_ID_IPC
			)
	GROUP BY A.ProgramName
		,A.StrategyName
		,A.Channel
	
	UNION ALL
	
	SELECT A.ProgramName
		,A.StrategyName
		,A.Channel
		,0 AS NewAccounts
		,0 AS NewAccountMarketValue
		,0 AS TerminatedAccounts
		,0 AS TerminatedAccountsMarketValue
		,sum(A.Inflows) AS Inflows
		,sum(A.InflowsMarketValue) AS InflowsMarketValue
		,sum(A.Outflows) AS Outflows
		,sum(A.OutflowsMarketValue) AS OutflowsMarketValue
		,sum(A.NetCapitalChange) AS NetCapitalChange
	FROM #tempacct tmpact
	INNER JOIN dbo.v_whv_acctview_IPC A ON a.acct_id = tmpact.acct_id
		AND A.BK_ID IN (
			@BK_ID_SMA
			,@BK_ID_UMA
			,@BK_ID_IPC
			)
		AND A.inq_basis_num = @inq_basis_num
		AND A.ORG_ID = 'SEI'
		-- and (A.CLS_SET_ID = 'NAM-P'   
		--or isnull(A.CLS_SET_ID,1) =1 )
		AND A.TRD_EX_EFF_TMS BETWEEN @End_SMA_Dt_StartofMonth
			AND @End_Date_check
	GROUP BY A.ProgramName
		,A.StrategyName
		,A.Channel
	) AS M
GROUP BY ProgramName
	,StrategyName
	,Channel
ORDER BY ProgramName ASC
	,StrategyName ASC
	,Channel ASC;
	--select @End_SMA_Dt_StartofMonth
	--select DATEADD(ms, - 3, DATEADD(DAY, 1, PRIOR_DAY_ACCT_CLS_DTE))   ,* from #tempacctdate
	--select * from #tempacct
