SET STATISTICS IO ON
GO

DECLARE @FirstName nvarchar(100)
SET @FirstName = 'Abhijit'

SELECT * FROM PersonContact
WHERE FirstName = @FirstName
GO

DECLARE @FirstName nvarchar(100)
SET @FirstName = 'Abhijit'

SELECT * FROM PersonContact
WHERE FirstName = @FirstName

