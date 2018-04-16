

/*
Author:  LRhoads
Date: 2012.11.30
Purpose:  Grants on procs  to DAA UI, and other known apps:
*/

IF EXISTS ( SELECT
							*
						FROM
							sysusers u
						WHERE
							issqlrole = 1
							AND name = 'prole_DAA_Application' ) 
	BEGIN 
--DAA_UI
		GRANT EXEC ON BISSEC.GetEntitledIPs TO prole_DAA_Application
		GRANT EXEC ON BISSEC.ValidateIPEntitlement TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Add_ORGANIZATION TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Upd_ORGANIZATION TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Del_ORGANIZATION TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Get_ORGANIZATION TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Add_SECURED_USER TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Upd_SECURED_USER TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Del_SECURED_USER TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Get_SECURED_USER TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Add_USER_RULE TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Del_USER_RULE TO prole_DAA_Application
		GRANT EXEC ON BISSEC.GET_USER_RULES TO prole_DAA_Application
		GRANT EXEC ON BISSEC.SearchSecuredUsers TO prole_DAA_Application
		GRANT EXEC ON BISSEC.Upd_All_Access_Flag TO prole_DAA_Application
		GRANT EXEC ON BISSEC.GetQualificationColumnList TO prole_DAA_Application
		GRANT EXEC ON BISSEC.InsertUser TO prole_DAA_Application
		GRANT EXEC ON BISSEC.GetEntitledAccounts TO prole_DAA_Application
		GRANT EXEC ON BISSEC.SearchQualificationValues TO prole_DAA_Application
		GRANT EXEC ON BISSEC.ValidateAccountEntitlement TO prole_DAA_Application
		GRANT EXEC ON BISSEC.AuditEntry TO prole_DAA_Application
		GRANT EXEC ON BISSEC.PurgeAuditTrail TO prole_DAA_Application
     
    GRANT SELECT ON dbo.ACCOUNT TO prole_DAA_Application
    GRANT SELECT ON dbo.BANK_UNIT TO prole_DAA_Application
    GRANT SELECT ON dbo.BANK_UNIT_DETAIL TO prole_DAA_Application
    GRANT SELECT ON dbo.ADMINISTRATOR TO prole_DAA_Application
    GRANT SELECT ON dbo.BRANCH TO prole_DAA_Application
    GRANT SELECT ON dbo.ACCOUNTANT TO prole_DAA_Application
    GRANT SELECT ON dbo.SENIOR_ADMINISTRATOR TO prole_DAA_Application
    GRANT SELECT ON dbo.INVESTMENT_OFFICER TO prole_DAA_Application 
    GRANT SELECT ON dbo.ACCOUNT_TYPE TO prole_DAA_Application

    PRINT '>> Granted permissions to prole_DAA_Application '
	END 
 
--PAS

IF EXISTS ( SELECT
							*
						FROM
							sysusers u
						WHERE
							issqlrole = 1
							AND name = 'prole_PAS' ) 
	BEGIN
		GRANT EXEC ON BISSec.GetEntitledAccounts TO prole_PAS
		GRANT EXEC ON BISSec.GetEntitledIPs TO prole_PAS
		GRANT EXEC ON BISSec.ValidateAccountEntitlement TO prole_PAS
		GRANT EXEC ON BISSec.ValidateIPEntitlement TO prole_PAS
    
    PRINT '>> Granted permissions to prole_PAS '
	END 

--RAS
IF EXISTS ( SELECT
							*
						FROM
							sysusers u
						WHERE
							issqlrole = 1
							AND name = 'prole_RAS' ) 
	BEGIN
		GRANT EXEC ON BISSec.GetEntitledAccounts TO prole_RAS
		GRANT EXEC ON BISSec.GetEntitledIPs TO prole_RAS
		GRANT EXEC ON BISSec.ValidateAccountEntitlement TO prole_RAS
		GRANT EXEC ON BISSec.ValidateIPEntitlement TO prole_RAS
    
    PRINT '>> Granted permissions to prole_RAS '
	END 

IF EXISTS ( SELECT
							*
						FROM
							sysusers u
						WHERE
							issqlrole = 1
							AND name = 'prole_RAS_Application' ) 
	BEGIN
		GRANT EXEC ON BISSec.GetEntitledAccounts TO prole_RAS_Application
		GRANT EXEC ON BISSec.GetEntitledIPs TO prole_RAS_Application
		GRANT EXEC ON BISSec.ValidateAccountEntitlement TO prole_RAS_Application
		GRANT EXEC ON BISSec.ValidateIPEntitlement TO prole_RAS_Application
    
    PRINT '>> Granted permissions to prole_RAS_Application '
	END

     