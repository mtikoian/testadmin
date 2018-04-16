USE NetikIP
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



/*=================================================================*/
-- Object Name : UserSysAcctView     -- File Name:
-- Author      :                     -- Date:		
-- Edit History: aj	07/22/97 adjusted for lower case
--		 jin	12/17/98 Changed the view to add additional 
--				columns for sec. lending
--             : SS 09/24/01 SQL 2000 Changes
--             : SS 11/13/02 Changed view columns syntax 
--		(From '=' to 'AS' to support Data Model compare)
--	           : SZ 05/01/03 change suser_sname() to dbo.fndw_appuser()
--             : SS 05/31/06 Replaced fndw_appuser() with the view
--
/*=================================================================*/

Alter view dbo.UserSysAcctView  
as     
select 	act.USER_ID AS ACCT_USER_ID, 
	act.ORG_ID, 
	act.BK_ID, 
	act.ACCT_ID, 
	dbo.fndw_appuser() AS USER_ID, 
	act.ACCT_NME, 
	act.ACCT_GRP_TYP,
	act.ACCT_DESC,
	act.ACCT_MNEM,
	act.MGR_CUST_ID,
    act.COL_ACCT_ID,
	act.COL_BK_ID,
    act.COL_ORG_ID
FROM dbo.IVW_ACCT act  
  JOIN dbo.PERMISSION prm ON (act.ACCT_ID = prm.ACCT_ID  
                    and act.BK_ID   = prm.BK_ID
                    and act.ORG_ID  = prm.ORG_ID
                    and act.USER_ID = 'HOST')
  JOIN dbo.IVW_USER usr ON (usr.USER_CLS_ID = prm.USER_CLS_ID)  
  JOIN dbo.DW_AppUserView cu ON (usr.USER_ID = cu.APP_USER_ID)  


GO


-- Validate if view has been created. 
IF  EXISTS 
	(
		SELECT 1
		FROM   information_schema.views 
		WHERE  Table_schema = 'dbo' 
			   AND Table_name = 'UserSysAcctView'  
	)
	BEGIN
      PRINT 'VIEW dbo.UserSysAcctView has been Altered.' 
  END 
ELSE 
  BEGIN 
      PRINT 'VIEW dbo.UserSysAcctView has NOT been Altered.' 
  END 
GO   

