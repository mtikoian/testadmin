Select <column name>
From ...
Where Try_Convert(float, <column name>) Is Null And <column name> Is Not Null;

/*

select * from fld_in_qry where entity_num=1 and fld_bus_nme like '%ITD%' 
select * from fld_in_qry where entity_num= 10202 and fld_bus_nme like '%ITD%' 


select * from qry_def

select * from inq_def where inq_num=12836
SELECT 
				CASE
					WHEN CHARINDEX('X',acct_id) > 0 THEN LTRIM(RTRIM(STUFF(acct_id,CHARINDEX('X',acct_id),1,'')))
				ELSE
					LTRIM(RTRIM(acct_id))
				END
				AS acct_id
			,acct_cls_dte
		FROM dbo.dp_pi_u_accountactivity
		WHERE   acct_id LIKE 'x%'


		select * from dw_function_item 

		where fn_nme like 'deposit%'
		and FN_STD_USR_IND = 'S'



		select * from inq_def where inq_num= 6020

			select * from qry_def where QRY_NUM= 6020


			select * from dw_function_item 

		where fn_nme like 'deposit%'
		and FN_STD_USR_IND = 'S'

		slect * from inq_def where inq_num= 7561

			select * from qry_def where QRY_NUM= 7561

*/
EXEC sp_setappuser 'ndev01'

EXEC sp_Position_List_Dynamic_Val2 'WHVAUM'
	,'USER'
	,'USER'
	,1
	,DEFAULT
	,DEFAULT
	,DEFAULT
	,DEFAULT
	,'NAM-P   '
	,1
	,0
	,5132
	,5132
	,'A.ACCT_ID, A.ISS_NME, A.PREF_ISS_ID, A.PREF_ID_CTXT_TYP, A.TCKR_SYM_ID, A.LONG_SHORT_IND, A.QUANTITY, A.UT_PRC_ALT_CMB_AMT, A.VALVAL_ALT_CMB_AMT, A.CRVL_ALT_CMB_AMT, A.ASSET_CLASS_MNEM, A.ISSUE_CLS2_NME, A.LEV_3_HIER_NME, A.LEV_4_HIER_NME, A.ISS_CL_NME, A.ISSUE_CLS3_NME, A.MAT_EXP_DTE, A.INC_PROJ_CMB_RTE, (VALVAL_ALT_CMB_AMT/nullif(DG.ACCT_VALVAL_ALT_AMT,0))'
	,'A.PREF_ISS_ID Asc'
	,DEFAULT
	,DEFAULT
	,0
	,DEFAULT


