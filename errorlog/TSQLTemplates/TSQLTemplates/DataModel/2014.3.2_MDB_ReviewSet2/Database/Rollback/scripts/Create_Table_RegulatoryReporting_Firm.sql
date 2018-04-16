USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS 
	(
		SELECT 1 
		FROM   information_schema.Tables 
		WHERE  Table_schema   = 'dbo' 
			   AND Table_name = 'RegulatoryReporting_Firm'  
	)
	BEGIN
		DROP Table dbo.RegulatoryReporting_Firm
		PRINT 'Table dbo.RegulatoryReporting_Firm has been dropped.'
	END
GO

































 



