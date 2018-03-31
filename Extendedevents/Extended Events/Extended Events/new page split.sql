USE AdventureWorks2012
GO

IF OBJECT_ID('dbo.Financials') IS NOT NULL
	DROP TABLE dbo.Financials
GO

CREATE TABLE dbo.Financials
(
RowID int identity
,CreateDate varchar(10)
,OrderDate varchar(10)
,ReviewDate varchar(10)
,ReferenceDate varchar(10)
,UpdateDate varchar(10)
,DennysBirthday varchar(10)
,RockstarBirthday varchar(10)
,DataChickBirthday varchar(10)
,FillerData char(2500)
,CONSTRAINT PK_Financials PRIMARY KEY CLUSTERED (RowID)
);

WITH
L0   AS(SELECT 1 AS C UNION ALL SELECT 1 AS O), -- 2 rows
L1   AS(SELECT 1 AS C FROM L0 AS A CROSS JOIN L0 AS B), -- 4 rows
L2   AS(SELECT 1 AS C FROM L1 AS A CROSS JOIN L1 AS B), -- 16 rows
L3   AS(SELECT 1 AS C FROM L2 AS A CROSS JOIN L2 AS B), -- 256 rows
L4   AS(SELECT 1 AS C FROM L3 AS A CROSS JOIN L3 AS B), -- 65,536 rows
L5   AS(SELECT 1 AS C FROM L4 AS A CROSS JOIN L4 AS B), -- 4,294,967,296 rows
Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS N FROM L5)
INSERT INTO dbo.Financials
(CreateDate, OrderDate, ReviewDate, ReferenceDate, UpdateDate, DennysBirthday, RockstarBirthday, DataChickBirthday)
SELECT TOP 1000000
'20120101' CreateDate 
,'20120101' OrderDate 
,'20120101' ReviewDate 
,'20120101' ReferenceDate 
,'20120101' UpdateDate 
,'20120101' DennysBirthday 
,'20120101' RockstarBirthday 
,'20120101' DataChickBirthday 
FROM Nums;

--SELECT * FROM dbo.Financials
