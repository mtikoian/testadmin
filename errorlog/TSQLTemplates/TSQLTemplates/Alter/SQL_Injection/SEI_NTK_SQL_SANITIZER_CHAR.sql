USE [NetikIP]
GO
IF  EXISTS 
	(
		SELECT * 
		FROM dbo.sysobjects 
		WHERE 
			id = OBJECT_ID(N'[dbo].[SEI_NTK_SQL_SANITIZER_CHAR]') AND 
			OBJECTPROPERTY(id, N'IsTable') = 1
	)
	BEGIN
		DROP TABLE [dbo].[SEI_NTK_SQL_SANITIZER_CHAR]
		PRINT 'Table [dbo].[SEI_NTK_SQL_SANITIZER_CHAR] has been dropped.'
	END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SEI_NTK_SQL_SANITIZER_CHAR](
	[INJCHARIND] [int] IDENTITY(1,1) NOT NULL,
	[INJCHAR] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF


-- Validate if the table has been created.
IF  EXISTS 
	(
		SELECT * 
		FROM dbo.sysobjects 
		WHERE 
			id = OBJECT_ID(N'[dbo].[SEI_NTK_SQL_SANITIZER_CHAR]') AND 
			OBJECTPROPERTY(id, N'IsTable') = 1
	)
	BEGIN
		PRINT 'Table  [dbo].[SEI_NTK_SQL_SANITIZER_CHAR] has been created.'
	END
ELSE
	BEGIN
		PRINT 'Table  [dbo].[SEI_NTK_SQL_SANITIZER_CHAR] has not been CREATED.'
	END
GO