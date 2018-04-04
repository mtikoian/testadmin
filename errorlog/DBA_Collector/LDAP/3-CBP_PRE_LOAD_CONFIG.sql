IF EXISTS (
		SELECT 1
		FROM information_schema.Tables
		WHERE Table_schema = 'dbo'
			AND Table_name = 'Users_helper'
		)
BEGIN
	DROP TABLE dbo.Users_helper

	PRINT 'Table dbo.Users_helper has been dropped.'
END
GO

CREATE TABLE [dbo].[Users_helper] (
	[CompanyId] [varchar](50) NULL
	,Userid_login varchar(150) NULL
	,LdapCompanyTypeAttribute VARCHAR(8000) NULL
	)



BULK INSERT dbo.Users_helper
FROM 'D:\Temp\Go_Live\LDAP\LDAP\CBP_Ldap.txt' WITH (
		KEEPNULLS
		,FIRSTROW = 2
		,FORMATFILE = 'D:\Temp\Go_Live\LDAP\LDAP\userHelper.xml'
		,ERRORFILE = 'D:\Temp\Go_Live\LDAP\LDAP\errorData.log'
		);
GO