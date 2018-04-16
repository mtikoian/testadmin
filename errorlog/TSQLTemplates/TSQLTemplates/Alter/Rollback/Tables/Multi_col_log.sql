USE NETIKDP
GO
/*      
==================================================================================================      
Name    : Alter_Table_DP_T_ACCOUNTACTIVITY  
Author  : VBANDI  08/16/2013      
Description : This has been created for executing Alter Scripts for DP_T_ACCOUNTACTIVITY table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
VBANDI     07/16/2013      Initial Version      
========================================================================================================      
*/ 


DECLARE @ErrorEncountered BIT

SET @ErrorEncountered = 0;

BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'DP_T_ACCOUNTACTIVITY'
			)
BEGIN
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'ACCT_CRVL_ALT_AMT')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN ACCT_CRVL_ALT_AMT 
		PRINT 'ACCT_CRVL_ALT_AMT column dropped from table DP_T_ACCOUNTACTIVITY'  
		END
		ELSE
		BEGIN
			PRINT 'Column ACCT_CRVL_ALT_AMT alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'ACCT_CURBAL_ALT_AMT')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN ACCT_CURBAL_ALT_AMT 

		PRINT 'ACCT_CURBAL_ALT_AMT column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column ACCT_CURBAL_ALT_AMT  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'ACCT_VALVAL_ALT_AMT')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN ACCT_VALVAL_ALT_AMT 

		PRINT 'ACCT_VALVAL_ALT_AMT column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column ACCT_VALVAL_ALT_AMT  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'ADJST_THRU_IND')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN ADJST_THRU_IND 

		PRINT 'ADJST_THRU_IND column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column ADJST_THRU_IND  alreday exists '
			SET @ErrorEncountered = 1
		END;

		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'AUA_IND')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN AUA_IND 
		
		PRINT 'AUA_IND column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column AUA_IND  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'AUM_IND')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN AUM_IND 

		PRINT 'AUM_IND column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column AUM_IND  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'AUM_INQ_IND')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN AUM_INQ_IND 

		PRINT 'AUM_INQ_IND column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column AUM_INQ_IND  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'BUSFLOW_IND')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN BUSFLOW_IND 
		PRINT 'BUSFLOW_IND column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column BUSFLOW_IND  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'DG_COUNT_NUM')
		BEGIN
			ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN DG_COUNT_NUM 
		PRINT 'DG_COUNT_NUM column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column DG_COUNT_NUM  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'DLD_CMPLTN_TMS')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN DLD_CMPLTN_TMS 
		PRINT 'DLD_CMPLTN_TMS column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column DLD_CMPLTN_TMS  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'FLD10_DESC')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN FLD10_DESC 
		PRINT 'FLD10_DESC column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column FLD10_DESC  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'FLD9_DESC')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN FLD9_DESC 
		PRINT 'FLD9_DESC column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column FLD9_DESC  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'FRST_ACTVTY_DTE')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN FRST_ACTVTY_DTE 
		PRINT 'FRST_ACTVTY_DTE column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column FRST_ACTVTY_DTE  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'INV_OBJ_TYP')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN INV_OBJ_TYP 
		PRINT 'INV_OBJ_TYP column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column INV_OBJ_TYP  alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'LST_ACTVTY_DTE')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN LST_ACTVTY_DTE 
		PRINT 'LST_ACTVTY_DTE column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column LST_ACTVTY_DTE  alreday exists '
			SET @ErrorEncountered = 1
		END;	
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'LST_ADJST_DTE')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN LST_ADJST_DTE 
		PRINT 'LST_ADJST_DTE column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column LST_ADJST_DTE  alreday exists '
			SET @ErrorEncountered = 1
		END;	
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'LST_BUSCLS_DTE')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN LST_BUSCLS_DTE 
		PRINT 'LST_BUSCLS_DTE column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column LST_BUSCLS_DTE  alreday exists '
			SET @ErrorEncountered = 1
		END;	

		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'MGMT_STYL_TYP')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN MGMT_STYL_TYP 
		PRINT 'MGMT_STYL_TYP column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column MGMT_STYL_TYP  alreday exists '
			SET @ErrorEncountered = 1
		END;	

		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'MODEL_ACCT_ID')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN MODEL_ACCT_ID 
		PRINT 'MODEL_ACCT_ID column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column MODEL_ACCT_ID alreday exists '
			SET @ErrorEncountered = 1
		END;	
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'ONBOOKS_IND')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN ONBOOKS_IND 
		PRINT 'ONBOOKS_IND column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column ONBOOKS_IND alreday exists '
			SET @ErrorEncountered = 1
		END;	
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'POLICY_SET_ID')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN POLICY_SET_ID 
		PRINT 'POLICY_SET_ID column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column POLICY_SET_ID alreday exists '
			SET @ErrorEncountered = 1
		END;

		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'RECON_DTE')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN RECON_DTE 
		PRINT 'RECON_DTE column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column RECON_DTE alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'RGSTR_CDE')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN RGSTR_CDE 
		PRINT 'RGSTR_CDE column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column RGSTR_CDE alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'TAX_IND')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN TAX_IND 
		PRINT 'TAX_IND column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column TAX_IND alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'USER_ID')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN USER_ID 
		PRINT 'USER_ID column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column USER_ID alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'Acct_Fld3_Amt')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN Acct_Fld3_Amt 
		PRINT 'Acct_Fld3_Amt column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column Acct_Fld3_Amt alreday exists '
			SET @ErrorEncountered = 1
		END;	

		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'Acct_Fld4_Amt')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN Acct_Fld4_Amt 
		PRINT 'Acct_Fld4_Amt column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column Acct_Fld4_Amt alreday exists '
			SET @ErrorEncountered = 1
		END;	
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'DP_T_ACCOUNTACTIVITY'
					AND column_name = 'Acct_Fld5_Amt')
		BEGIN
		ALTER TABLE NETIKDP.dbo.DP_T_ACCOUNTACTIVITY DROP COLUMN Acct_Fld5_Amt 
		PRINT 'Acct_Fld5_Amt column dropped from table DP_T_ACCOUNTACTIVITY' 
		END
		ELSE
		BEGIN
			PRINT 'Column Acct_Fld5_Amt alreday exists '
			SET @ErrorEncountered = 1
		END;	
		
--check for errors 
IF @ErrorEncountered = 1
BEGIN
	PRINT ' '
	PRINT ' '
	PRINT '**********************'
	PRINT 'ERROR OCCURRED'
END
ELSE
BEGIN
	PRINT ' '
	PRINT ' '
	PRINT '**********************'
	PRINT 'Columns dropped Successfully for table DP_T_ACCOUNTACTIVITY'
END
	END ELSE

BEGIN
	PRINT 'Some error occured while altering table DP_T_ACCOUNTACTIVITY!!!'
END END TRY

BEGIN CATCH
END CATCH
