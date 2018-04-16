select  a. *
FROM dbo.ISSUE_IVCLASSIF_SEI a
JOIN (
	SELECT ACCT_ID
		,INSTR_ID
		,REF_ACCT_ID
		,count(1) cnt
		,max(iss_cl_sei_num) AS iss_cl_sei_num
	FROM dbo.ISSUE_IVCLASSIF_SEI WITH (NOLOCK)
	GROUP BY ACCT_ID
		,INSTR_ID
		,REF_ACCT_ID
	HAVING count(1) > 1
	) tbl ON a.acct_id = tbl.acct_id
	AND a.INSTR_ID = tbl.INSTR_ID
	AND a.REF_ACCT_ID = tbl.REF_ACCT_ID
	AND a.iss_cl_sei_num <> tbl.iss_cl_sei_num




delete  a 
FROM dbo.ACCOUNTS_CLASSIFICATION_SEI a
JOIN (
SELECT ACCT_ID
	,count(1) cnt
,max(id) AS id
FROM dbo.ACCOUNTS_CLASSIFICATION_SEI WITH (NOLOCK)
GROUP BY ACCT_ID
	HAVING count(1) > 1
	) tbl ON a.acct_id = tbl.acct_id
	
	AND a.id <> tbl.id


DELETE A
	from dbo.ACCT_TOTALS a
	join 
	(
			 select  
			  T.ORG_ID,
			  T.BK_ID,
			  T.ACCT_ID,
			  T.AT_INSTRUCT_ID,
			  T.END_TMS,
			  T.END_ADJUST_TMS,
			  T.INQ_BASIS_NUM,
			  max(at_num) as max_at_num,
			  count(1) as cnt
			 FROM dbo.ACCT_TOTALS t
			 group by  
			  T.ORG_ID,
			  T.BK_ID,
			  T.ACCT_ID,
			  T.AT_INSTRUCT_ID,
			  T.END_TMS,
			  T.END_ADJUST_TMS,
			  T.INQ_BASIS_NUM
			  having  count(1) > 1
	)tbl
	 on
 			  tbl.ORG_ID = a.ORG_ID
			  and tbl.BK_ID = a.BK_ID
			  and tbl.ACCT_ID = a.ACCT_ID
			  and tbl.AT_INSTRUCT_ID = a.AT_INSTRUCT_ID
			  and tbl.END_TMS = a.END_TMS
			  and tbl.END_ADJUST_TMS = a.END_ADJUST_TMS
			  and tbl.INQ_BASIS_NUM = a.INQ_BASIS_NUM 
			  and tbl.max_at_num <> a.at_num