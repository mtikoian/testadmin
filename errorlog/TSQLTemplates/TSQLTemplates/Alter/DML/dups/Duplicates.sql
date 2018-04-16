         ;with cte_acct_totals as (
         select  max(t.at_num) as max_at,
         t.acct_id,
         t.inq_basis_num,
         t.end_tms
         from dbo.ACCT_TOTALS t
            join  dbo.ACCT_TOTALS  n
            on t.acct_id = n.acct_id 
            and t.inq_basis_num = n.inq_basis_num
            and t.end_tms = n.end_tms
         group by t.acct_id,
         t.inq_basis_num,
         t.end_tms
         ) --delete dups
         delete top (@commitrecordat) dbo.ACCT_TOTALS
         from dbo.ACCT_TOTALS t
            join  cte_acct_totals n
            on t.acct_id = n.acct_id 
            and t.inq_basis_num = n.inq_basis_num
            and t.end_tms = n.end_tms
            and t.AT_NUM <> max_at 
            
            --find duplicates  


select INSTR_ID, ACCT_ID , count(*)

from ISSUE_CLASSIF_SEI
group by INSTR_ID, ACCT_ID
having count(*) > 1
---
;with cte
as (select  *
,ROW_NUMBER() over (partition by INSTR_ID, ACCT_ID order by INSTR_ID, ACCT_ID) Row_Num
from  dbo.test22 )

select * from cte where row_num >=2
--remove dups
delete from a from 
(select INSTR_ID, ACCT_ID
,ROW_NUMBER() over (partition by INSTR_ID, ACCT_ID order by INSTR_ID, ACCT_ID) Row_Num
from  dbo.ISSUE_CLASSIF_SEI )a

where a.row_num >1

--simple, it requires utilizing the GROUP BY clause and counting the number of recurrences. 
--For example, lets take a customers table. Within the customers table, we want to find all the records where 
--the customers FirstNames are the same. We also want to find which FirstNames are the same and count them.
--First off, let’s get a count of how many customers share the same first name:

SELECT FirstName
    ,DuplicateCount = COUNT(1)
FROM SalesLT.Customer
GROUP BY FirstName
HAVING COUNT(1) > 1  -- more than one value
ORDER BY COUNT(1) DESC -- sort by most duplicates



--This method can also be expanded to include multiple columns, like FirstName and LastName. 
--In order to expand the criteria, we simply add the columns to the select list and the group by clause.

SELECT FirstName
    ,LastName
    ,DuplicateCount = COUNT(1)
FROM SalesLT.Customer
GROUP BY 
    FirstName
    ,LastName
HAVING COUNT(1) > 1  -- more than one value
ORDER BY COUNT(1) DESC -- sort by most duplicates
--so now that we have found the duplicate items, 
--how do we join that back on the main table so we can see the entire record? 
--There are two methods that may perform differently depending on your result set so in this case 
--I will include them both. Only the EXISTS method however can be used for multiple columns.

-- *********************************
-- * Find duplicates using IN
-- *********************************
SELECT *
FROM SalesLT.Customer
WHERE FirstName IN
(
    SELECT FirstName
    FROM SalesLT.Customer
    GROUP BY 
        FirstName
    HAVING COUNT(1) > 1  -- more than one value
)
ORDER BY FirstName

-- *********************************
-- * Find duplicates using EXISTS
-- *********************************
SELECT * 
FROM SalesLT.Customer c1
WHERE EXISTS
(
    SELECT 1
    FROM SalesLT.Customer
    WHERE FirstName = c1.FirstName
    GROUP BY 
        FirstName
    HAVING COUNT(1) > 1  -- more than one value
)
ORDER BY FirstName
--Now what if you want to check to see if there are duplicates for an entire row without 
--having to do a group by you ask? In other words, how do I find the records where the entire row is a duplicate. 
--Yes, there is a way. To do this, we utilize a very handy function named CHECKSUM. Checksum returns a numerical value representing 
--a single “hash” which is unique (mostly) for a multitude of values. The advantage of this method over the group by 
--is that it is much faster.

SELECT *
FROM (
    SELECT 
        CustomerID
        ,ChkSum = 
        CHECKSUM
        (
            FirstName,
            LastName
            -- specify the rest of the columns
        )
    FROM SalesLT.Customer sc
) t1
JOIN 
(
    SELECT 
        CustomerID
        ,ChkSum = 
        CHECKSUM
        (
            FirstName,
            LastName
            -- specify the rest of the columns
        )
    FROM SalesLT.Customer
) t2
ON t1.CustomerID != t2.CustomerID
AND t1.ChkSum = t2.ChkSum



--dups-----------


select a.* 
from tranevent_dg a
join 
(
	select DISTINCT 
	ACCT_ID,
	STRTGY_ID,
	ISS_ID,
	EV_CDE,
	TRN_CDE,
	TRN_CL_CDE,
	RVSNG_ATEV_ID,
	RVSL_CREATED_TMS,
	ACTG_TRN_ID,
	CUSTODN_ID,
	INQ_BASIS_NUM,
	TRN_DESC,
	LEV_10_HIER_NME,
	trd_ex_eff_tms,
	bk_id,
	count(1) cnt,
	max(rcd_num) as rcd_num
	from dbo.tranevent_dg  with(nolock)
	where 
		bk_id = 'HF' and 
		lst_chg_tms>='2000-01-01 00:00:00.000' and
		acct_id like '1022-3-%' 
	group by 
		ACCT_ID,
		STRTGY_ID,
		ISS_ID,
		EV_CDE,
		TRN_CDE,
		TRN_CL_CDE,
		RVSNG_ATEV_ID,
		RVSL_CREATED_TMS,
		ACTG_TRN_ID,
		CUSTODN_ID,
		INQ_BASIS_NUM,
		TRN_DESC,
		LEV_10_HIER_NME,
		trd_ex_eff_tms,
		bk_id
	having count(1)>1
) tbl
on a.acct_id = tbl.acct_id
AND a.bk_id = tbl.bk_id

and a.rcd_num <> tbl.rcd_num

and isnull(a.strtgy_id,'') = isnull(tbl.strtgy_id,'')
and a.iss_id = tbl.iss_id	
and a.ev_cde = tbl.ev_cde	
and a.TRN_CDE = tbl.TRN_CDE	
and a.trn_cl_cde = tbl.trn_cl_cde	
and a.rvsng_atev_id = tbl.rvsng_atev_id	
AND ISNULL(a.RVSL_CREATED_TMS,'01/01/1900') = ISNULL(tbl.RVSL_CREATED_TMS,'01/01/1900') 
and a.actg_trn_id = tbl.actg_trn_id	
and a.custodn_id = tbl.custodn_id	
and a.inq_basis_num = tbl.inq_basis_num		
and a.trn_desc = tbl.trn_desc	
and a.lev_10_hier_nme = tbl.lev_10_hier_nme	
and a.trd_ex_eff_tms = tbl.trd_ex_eff_tms	
WHERE 
	A.lst_chg_tms>='2000-01-01 00:00:00.000'
