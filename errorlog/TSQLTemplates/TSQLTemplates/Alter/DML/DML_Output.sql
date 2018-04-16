CREATE TABLE dbo.test21 (
	id INT
	,NAME VARCHAR(40)
	)

/****************************************Insert**************************************************************/
INSERT INTO test21 (
	Id
	,NAME
	)
OUTPUT INSERTED.*
VALUES (
	18
	,'Pie Cherries'
	);

/****************************************Update**************************************************************/
UPDATE test21
SET NAME = 'cherry'
OUTPUT DELETED.*
	,INSERTED.*
WHERE id = 18;

/****************************************Deleted**************************************************************/
DELETE
FROM dbo.test21
OUTPUT DELETED.*
WHERE NAME = 'cherry';

-- Create table variable to hold output from insert
DECLARE @INSERTED AS TABLE (
	Id INT
	,NAME VARCHAR(100)
	);

--INSERT with OUTPUT clause
INSERT INTO Fruit (
	NAME
	,Color
	)
OUTPUT INSERTED.Id
	,INSERTED.NAME
INTO @INSERTED
VALUES (
	'Bing Cherries'
	,'Purple'
	)
	,(
	'Oranges'
	,'Orange'
	);

-- view rows that where inserted
DECLARE @ProductPriceAudit TABLE (
	ID INT
	,BeforePrice DECIMAL(6, 2)
	,AfterPrice DECIMAL(6, 2)
	);

UPDATE Product
SET Price = 27.98
OUTPUT DELETED.ID
	,DELETED.Price
	,INSERTED.Price
INTO @ProductPriceAudit
WHERE ID = 1;

SELECT *
FROM @ProductPriceAudit;
