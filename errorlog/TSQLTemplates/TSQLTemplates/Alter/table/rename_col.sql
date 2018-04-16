USE NetikDP
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/*      
==================================================================================================      
Name    : Alter_Table_inf_portfolio_performance_staging 
Author  : Mpadala  08/15/2013      
Description : This has been created for executing Alter Scripts for inf_portfolio_performance_staging table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
Mpadala     08/15/2013      Initial Version      
========================================================================================================      
*/
IF NOT EXISTS (
		SELECT 1
		FROM information_schema.columns
		WHERE table_name = 'inf_portfolio_performance_staging'
			AND column_name = 'mgmt_fee'
		)
BEGIN
	EXEC sp_rename 'inf_portfolio_performance_staging.mgmg_performance'
		,'mgmt_fee'
		,'COLUMN'

	PRINT 'Coulmn Renamed sucessfully in table [inf_portfolio_performance_staging]'
END
ELSE
	PRINT 'Unable to rename Coulmn in table [inf_portfolio_performance_staging]'
GO


