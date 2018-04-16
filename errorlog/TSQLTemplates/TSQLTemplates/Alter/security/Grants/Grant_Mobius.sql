USE NETIKIP
GO 
IF EXISTS ( SELECT
							1
						FROM
							sysusers u
						WHERE
							issqlrole = 1
							AND name = 'p_role_mobius' ) 
	BEGIN 



GRANT EXECUTE ON dbo.p_MDB_Get_User_Entitlement_Info  to p_role_mobius
GRANT SELECT ON cds.RelationshipType TO p_role_mobius
GRANT SELECT ON cds.RelatedContactSubType TO p_role_mobius
GRANT SELECT ON cds.FundInvestor TO p_role_mobius
GRANT SELECT ON cds.FundInvestorContact TO p_role_mobius
GRANT SELECT ON cds.Contact TO p_role_mobius
GRANT SELECT ON cds.InvestorContact TO p_role_mobius
GRANT SELECT ON cds.Investor TO p_role_mobius
GRANT SELECT ON cds.RelatedContactType TO p_role_mobius


 PRINT '>>>Granted permissions to p_role_mobius<<<'
	END 