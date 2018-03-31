--iFTS sample code
/*---------------------------------------------------------------
-  Setup - Create base tables
----------------------------------------------------------------*/
CREATE TABLE [dbo].[Books](
	[Book_ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Author] [nvarchar](50) NOT NULL,
	[Contents] [varbinary](max) NULL,
	[ContentType] [varchar](10) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
GO
ALTER TABLE [dbo].[Books] ADD  CONSTRAINT [PK_Books] PRIMARY KEY CLUSTERED
(
	[Book_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Names](
	[ADDRESS1] [varchar](256) NULL,
	[ADDRESS2] [varchar](256) NULL,
	[ADDRESS3] [varchar](256) NULL,
	[CITY] [varchar](256) NULL,
	[COUNTRY_ID] [varchar](126) NULL,
	[COUNTY] [varchar](256) NULL,
	[CREATE_DATE] [datetime2](0) NULL,
	[FAX_NUMBER] [varchar](256) NULL,
	[NAME] [varchar](256) NULL,
	[NAM_ID] [varchar](126) NOT NULL,
	[STATE_ID] [varchar](30) NULL,
	[TELEPHONE] [varchar](256) NULL,
	[ZIP] [varchar](256) NULL,
 CONSTRAINT [PK_NAM] PRIMARY KEY CLUSTERED
([NAM_ID] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

CREATE TABLE [dbo].[Vendors](
	[Vendor_ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
 CONSTRAINT [PK_Vendors] PRIMARY KEY CLUSTERED
(
	[Vendor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


/*---------------------------------------------------------------
-  Basics - Catalogs & Indexes
----------------------------------------------------------------*/
--Create Catalog:
CREATE FULLTEXT CATALOG [iFTSExample] WITH ACCENT_SENSITIVITY = OFF
AS DEFAULT

--Create Full Text Index
CREATE FULLTEXT INDEX ON [dbo].Names(
[ADDRESS1] LANGUAGE [English],
[ADDRESS2] LANGUAGE [English],
[ADDRESS3] LANGUAGE [English],
[CITY] LANGUAGE [English],
[NAME] LANGUAGE [English],
[STATE_ID] LANGUAGE [English],
[ZIP] LANGUAGE [English],
[TELEPHONE] LANGUAGE [English])
KEY INDEX [PK_NAM] ON ([Names], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

CREATE FULLTEXT INDEX ON [dbo].[Books](
[Author] LANGUAGE [English],
[Contents] TYPE COLUMN [ContentType] LANGUAGE [English],
[Name] LANGUAGE [English])
KEY INDEX [PK_Books]ON ([iFTSExample], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

--List all FT indexes
SELECT * FROM sys.fulltext_indexes

/*---------------------------------------------------------------
-  Basics - Predicates & Functions
----------------------------------------------------------------*/
--Basic Predicate Queries
SELECT *
FROM [dbo].[Names]
WHERE CONTAINS(*,'Houston')

SELECT *
FROM [dbo].[Names]
WHERE FREETEXT(*,'Houston')

--ContainsTable Query on only 2 columns
SELECT *
FROM [dbo].[Names] n
INNER JOIN
	CONTAINSTABLE([dbo].[Names],(NAME,ADDRESS1),'Houston')
	ft ON ft.[KEY] = n.NAM_ID
ORDER BY RANK DESC

/*---------------------------------------------------------------
-  Tips - Stopwords
----------------------------------------------------------------*/
--List all stoplists
SELECT * FROM sys.fulltext_stoplists

--List all stopwords for english language
SELECT * FROM sys.fulltext_stopwords
WHERE language = 'English'

--Custom Stoplists:
CREATE FULLTEXT STOPLIST CustomStoplist FROM SYSTEM STOPLIST;
Go;
--Customize stoplist:
ALTER FULLTEXT STOPLIST CustomStoplist DROP 'can' LANGUAGE 'English';
Go;
--Set Stoplist for specific index:
ALTER FULLTEXT INDEX ON dbo.Names SET STOPLIST = CustomStoplist;
Go;

--Tokenize search string
--Default stoplist:
SELECT * FROM sys.dm_fts_parser (' "Houston can Build" ', 1033, 0, 0)
--Custom stoplist:
SELECT * FROM sys.dm_fts_parser (' "Houston can Build" ', 1033, 5, 0)

/*---------------------------------------------------------------
-  Tips - Thesaurus
----------------------------------------------------------------*/
--Reload thesaurus file
EXEC sys.sp_fulltext_load_thesaurus_file 1033;
--Thesaurus expansion example
SELECT * FROM sys.dm_fts_parser ('FORMSOF( THESAURUS, "Houston can Build") ', 1033, 5, 0)


/*---------------------------------------------------------------
-  Tips - Filters
----------------------------------------------------------------*/
--List loaded filters:
SELECT * FROM sys.fulltext_document_types

--Simple document search:
SELECT * FROM dbo.Books
WHERE CONTAINS(Contents,'SQL')

--Load OS filters:
EXEC sys.sp_fulltext_service 'load_os_resources',1;
GO
EXEC sys.sp_fulltext_service 'update_languages', NULL;
GO
EXEC sp_fulltext_service 'verify_signature', 0;

--Populate FTS Catalog:
ALTER FULLTEXT CATALOG [iFTSExample] REBUILD

/*---------------------------------------------------------------
-  Derived columns
----------------------------------------------------------------*/
--Contains with AND:
SELECT *
FROM [dbo].[Names]
WHERE CONTAINS((*),'Houston AND holdings AND McKinney')

--Add Derived column:
ALTER TABLE [dbo].[Names]
ADD AllText AS isnull([Address1],'')+' '
    +isnull([Address2],'')+' '
    +isnull([Address3],'')+' '
    +isnull([City],'')+' '
    +isnull([State_ID],'')+' '
    +isnull([Zip],'')+' '
    +isnull([Country_ID],'')+' '
    +isnull([Name],'')+' '
    +isnull([Telephone],'')
    PERSISTED NOT NULL,
	PERSISTED

ALTER FULLTEXT INDEX ON [dbo].[Names] ADD ([AllText])
GO

/*---------------------------------------------------------------
-  Indexed view
----------------------------------------------------------------*/
--Create the view
CREATE VIEW [dbo].[vName]
WITH SCHEMABINDING
AS
SELECT
	ADDRESS1
	,ADDRESS2
	,CITY
	,NAME
	,NAME_ID
	,STATE
	,COUNTRY
	,TELEPHONE
	,ZIP
	,AllText = ISNULL(ADDRESS1,'') + ' ' + ISNULL(ADDRESS2,'') + ' ' + ISNULL(CITY,'') + ' ' +
		ISNULL(NAME,'') + ' ' + ISNULL(STATE,'') + ' ' + ISNULL(COUNTRY,'') + ' ' +
		ISNULL(TELEPHONE,'') + ' ' + ISNULL(ZIP,'')
  FROM dbo.Names

--Add clustered index
CREATE UNIQUE CLUSTERED INDEX [vNAM_PK] ON [dbo].[vName]
       ([NAME_ID] ASC)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

--Create FT Index
CREATE FULLTEXT INDEX ON [dbo].[vName](
[ADDRESS1] LANGUAGE [English],
[ADDRESS2] LANGUAGE [English],
[CITY] LANGUAGE [English],
[NAME] LANGUAGE [English],
[STATE] LANGUAGE [English],
[STATE] LANGUAGE [English],
[ZIP] LANGUAGE [English],
[TELEPHONE] LANGUAGE [English],
[AllText] LANGUAGE [English])
KEY INDEX [vNAM_PK]  ON ([iFTSExample], FILEGROUP [PRIMARY])
WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)

--Select from view with multiple parameters
SELECT * --DISTINCT Facility_ID
FROM [dbo].vName
WHERE CONTAINS((*),'1401 AND QA AND TX')

/*-----------------------------------
- Cursor search
------------------------------------*/
DECLARE @vendor nvarchar(255)

DECLARE @matches TABLE (SrcName nvarchar(255), DestName_ID varchar(126), Rank smallint)

DECLARE VendorCursor CURSOR FOR
SELECT DISTINCT Name
FROM dbo.Vendors v
WHERE name IS NOT NULL

OPEN VendorCursor;

FETCH NEXT FROM VendorCursor INTO @vendor;

WHILE @@FETCH_STATUS = 0
BEGIN

	INSERT INTO @matches (SrcName, DestName_ID, Rank)
	SELECT Vendor, [KEY], RANK
		FROM (SELECT Vendor = @vendor, ft.[KEY], ft.RANK, RankMatch = ROW_NUMBER() OVER(PARTITION BY @vendor ORDER BY ft.RANK DESC)
		FROM FREETEXTTABLE(dbo.Names,(Name),@vendor) ft) ft WHERE RankMatch < 4 AND Rank > 40;

	FETCH NEXT FROM VendorCursor INTO @vendor

END

CLOSE VendorCursor;
DEALLOCATE VendorCursor;

SELECT * FROM @matches m
INNER JOIN dbo.Names n ON m.DestName_ID = n.NAM_ID