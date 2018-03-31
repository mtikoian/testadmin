USE AdventureWorks2014
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PersonContact')
    DROP TABLE PersonContact
GO

CREATE TABLE [dbo].[PersonContact](
	[PersonContactID] [int] NOT NULL IDENTITY(1,1),
	[NameStyle] [dbo].[NameStyle] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [varchar](50) NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Suffix] [varchar](50) NULL,
	[AdditionalContactInfo] [xml](CONTENT [Person].[AdditionalContactInfoSchemaCollection]) NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) 
GO

INSERT INTO [dbo].[PersonContact]
(NameStyle, Title, FirstName, MiddleName, LastName, Suffix, AdditionalContactInfo, rowguid, ModifiedDate)
SELECT NameStyle
    ,Title
    ,CAST(FirstName as varchar(50)) as FirstName
    ,CAST(MiddleName as varchar(50)) as MiddleName
    ,CAST(LastName as varchar(50)) as LastName
    ,CAST(Suffix as varchar(50)) as Suffix
    ,AdditionalContactInfo
    ,rowguid
    ,ModifiedDate 
FROM Person.Person
GO 5

CREATE CLUSTERED INDEX IX_PersonContact_ContactID ON PersonContact (PersonContactID)
GO

CREATE INDEX IX_PersonContact_FirstName ON PersonContact(FirstName)
GO
