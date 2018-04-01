USE CorruptDemoDB;

/****** Object:  Table [dbo].[CorruptData]    Script Date: 1/6/2015 7:24:15 PM ******/

IF OBJECT_ID('CorruptData') IS NOT NULL
BEGIN

	DROP TABLE [dbo].[CorruptData];

END


CREATE TABLE CorruptData
(IDNumber INT IDENTITY (1,1)
,FirstName NVARCHAR(100)
,LastName NVARCHAR(100)
,PhoneNumber CHAR(12))

USE [CorruptDemoDB]

GO

CREATE UNIQUE CLUSTERED INDEX [IX_CorruptDate_IDNumber] ON [dbo].[CorruptData]
(
	[IDNumber] ASC,
	[PhoneNumber]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

GO


