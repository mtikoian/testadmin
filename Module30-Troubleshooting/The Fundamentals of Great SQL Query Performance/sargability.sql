
-- Demo #1 -- Sargability and Seek/Scan behavior

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE LastName LIKE '%Wood%'

GO

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE LastName LIKE 'Wood%' 
	OR LastName LIKE 'Markwood%' 
	OR LastName LIKE 'Sherwood%' 
	OR LastName LIKE 'Underwood%'

GO

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE ISNULL(LastName, 'n/a') LIKE 'Wood%' 
	OR LastName LIKE 'Markwood%' 
	OR LastName LIKE 'Sherwood%' 
	OR LastName LIKE 'Underwood%'

GO

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE COALESCE(LastName, 'n/a') LIKE 'Wood%' 
	OR LastName LIKE 'Markwood%' 
	OR LastName LIKE 'Sherwood%' 
	OR LastName LIKE 'Underwood%'

GO

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE CASE WHEN LastName IS NULL THEN 'n/a' ELSE LastName END LIKE 'Wood%' 
	OR LastName LIKE 'Markwood%' 
	OR LastName LIKE 'Sherwood%' 
	OR LastName LIKE 'Underwood%'

GO

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE MiddleName LIKE 'Wood%' 
	OR LastName LIKE 'Markwood%' 
	OR LastName LIKE 'Sherwood%' 
	OR LastName LIKE 'Underwood%'

GO

SELECT NationalIDNumber, BusinessEntityID
FROM HumanResources.Employee
WHERE NationalIDNumber = 8066363

GO

SELECT NationalIDNumber, BusinessEntityID
FROM HumanResources.Employee
WHERE NationalIDNumber = '8066363'

GO

SELECT NationalIDNumber, BusinessEntityID
FROM HumanResources.Employee
WHERE NationalIDNumber = N'8066363'

GO

-- Demo #2 -- NOT operations and sargability

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE LastName NOT LIKE 'Wood%' 
--	AND LastName NOT LIKE 'Markwood%' 
	AND LastName NOT LIKE 'Sherwood%' 
	AND LastName NOT LIKE 'Underwood%'
	AND LastName LIKE 'Mark%'

GO

-- Demo #3 -- Sargability and AND/OR behavior

SELECT LastName, FirstName, MiddleName
FROM Person.Person
WHERE LastName LIKE 'Ander%' 
	AND MiddleName = 'S'

GO

SELECT LastName, FirstName, MiddleName 
FROM Person.Person 
WHERE LastName LIKE 'Ander%' 
	OR MiddleName = 'S'

GO

-- multi-filtering (http://www.sql-server-pro.com/or-condition-performance.html)

SET NOCOUNT ON

--DROP TABLE #or_test

CREATE TABLE #or_test 
(
	id int IDENTITY PRIMARY KEY CLUSTERED, 
	col1 int, 
	col2 int
)
GO

INSERT INTO #or_test (col1, col2)
SELECT CONVERT(int, RAND() * 1000000), CONVERT(int, RAND() * 1000000)
GO 1000000

CREATE INDEX idx_or_test_col1 on #or_test (col1)
GO

CREATE INDEX idx_or_test_col2 on #or_test (col2)
GO

-- DROP PROCEDURE #test1
CREATE PROCEDURE #test1
    @id int = 0,
    @col1 int = 0,
    @col2 int = 0
AS
BEGIN
    SET NOCOUNT ON

    SELECT id, col1, col2
    FROM #or_test
    WHERE (id = @id or @id = 0)
    AND (col1 = @col1 or @col1 = 0)
    AND (col2 = @col2 or @col2 = 0)
END
GO

EXEC #test1 @id = 400000
GO

SELECT id, col1, col2
FROM #or_test
WHERE id = 400000


