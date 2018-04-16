CREATE ROLE p_role_mobius AUTHORIZATION dbo

--ALTER AUTHORIZATION ON SCHEMA::cds TO p_role_cds

--GRANT SELECT ON dbo.CUST TO p_role_cds;

--GRANT SELECT ON dbo.GP_FUND TO p_role_cds;

CREATE ROLE u_role_mobius AUTHORIZATION dbo;

EXEC sp_addrolemember N'p_role_mobius', N'u_role_mobius'

EXEC sp_addrolemember 'u_role_mobius', 'MDBMobiusDEV'


grant execute on [dbo].[p_MDB_Get_User_Entitlement_Info]  to MDBMobiusDEV



GRANT EXECUTE ON [dbo].[sp_Holding_List_Dynamic] TO MDBMobiusDEV



GRANT SELECT ON cds.RelationshipType TO MDBMobiusDEV

GRANT SELECT ON cds.RelatedContactSubType TO MDBMobiusDEV
GRANT SELECT ON cds.FundInvestor TO MDBMobiusDEV

GRANT SELECT ON cds.FundInvestorContact TO MDBMobiusDEV

GRANT SELECT ON cds.Contact TO MDBMobiusDEV
GRANT SELECT ON cds.InvestorContact TO MDBMobiusDEV

GRANT SELECT ON cds.Investor TO MDBMobiusDEV



GRANT SELECT ON cds.RelatedContactType TO MDBMobiusDEV