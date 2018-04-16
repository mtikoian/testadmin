USE NETIKIP
GO
IF EXISTS
   (SELECT 1 FROM INFORMATION_SCHEMA.VIEWS
    WHERE table_schema = N'$(BIS_SECURITY_SCHEMA)' and table_name = N'vw_UserRules')
   BEGIN
      DROP VIEW $(BIS_SECURITY_SCHEMA).vw_UserRules;
      PRINT 'VIEW $(BIS_SECURITY_SCHEMA).vw_UserRules has been dropped.';
   END;
GO
/*           
======================================================================================================           
Name    : UDFPositionView           
Author  : MChawla  11/10/2010  
Application : UDF          
Description : Retrieves Portfolio Position information alonw with Issue, Classification,   
              Account and Account Out Source Extension                        
=======================================================================================================           
-------------------------------------------------------------------------------------------------------           
Returns  :  Recordset           
           
History:           
Name  Date   Description           
--------------------------------------------------------------------------------------------------------           
Manish  03/09/2011  Added Inq basis check       
Sumit M  01/03/2012  Added new columns from position_dg and classif_dg table     
hmohan      06/27/2013   Added new columns from issue_dg -- HMohan 06272013  
========================================================================================================           
*/
CREATE VIEW dbo.UDFPositionView
	WITH SCHEMABINDING
AS
SELECT p.rcd_num
	,p.acct_id
	,act.acct_nme
	,act.ext_acct_id
	,p.iss_id
	,i.iss_nme
	,i.tckr_sym_id
	,p.instr_id
	,p.as_of_tms
	,p.inq_basis_num
	,p.prc_valid_typ
	,p.ref_acct_id
	,p.ref_acct_nme
	,p.busunit_cust_nme
	,p.bk_id
	,i.issue_cls3_nme
	,p.asset_class_mnem
	,i.issue_cls1_nme
	,i.issue_cls2_nme
	,c.lev_3_hier_nme
	,c.lev_4_hier_nme
	,i.iss_cl_nme
	,i.issuer_id
	,i.ANNOUNCE_SRC_NME AS I_ANNOUNCE_SRC_NME
	,-- HMohan 06272013  
	i.AGNT2_NME AS I_AGNT2_NME -- HMohan 06272013  
FROM dbo.position_dg AS p
INNER JOIN dbo.issue_dg AS i ON p.instr_id = i.instr_id
INNER JOIN dbo.classif_dg AS c ON p.pos_id = c.pos_id
INNER JOIN dbo.ivw_acct AS act ON p.org_id = act.org_id
	AND p.bk_id = act.bk_id
	AND p.acct_id = act.acct_id
GO

IF NOT EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.VIEWS
		WHERE TABLE_NAME = 'UDFPositionView'
		)
BEGIN
	PRINT 'Failed to create VIEW UDFPositionView '
END
ELSE
BEGIN
	PRINT 'VIEW UDFPositionView Created successfully '
END
GO
