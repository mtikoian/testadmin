USE CorruptDemoDB;

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#names') IS NOT NULL
BEGIN

	DROP TABLE #names;

END

DECLARE @firstnamectr INT = 1;
DECLARE @lastnamectr INT = 1;
DECLARE @firstname VARCHAR(100);
DECLARE @lastname VARCHAR(100);
DECLARE @loopcount INT = 1;
DECLARE @areacode INT;
DECLARE @prefix INT;
DECLARE @lastfour INT;
DECLARE @phonenumber VARCHAR(12);


CREATE TABLE #names
(firstname VARCHAR(100)
,lastname VARCHAR(100))

WHILE @loopcount <= 100
BEGIN

	WHILE @lastnamectr <= 100
	BEGIN

		SELECT @lastname = lastname
		FROM LastName
		WHERE LastNameID = @lastnamectr;

		SELECT @Firstname = Firstname
		FROM FirstName
		WHERE FirstNameID = @Firstnamectr;

		--RIGHT('0' + RTRIM((estimated_completion_time/1000)%3600/60), 2)

		SELECT @prefix = ROUND(RAND() * 1000,0), @areacode = ROUND(RAND() * 1000,0), @lastfour = ROUND(RAND() * 10000,0);

		SELECT @phonenumber = RIGHT('00' + CAST(@areacode AS VARCHAR),3) + '-' + RIGHT('00' + CAST(@prefix AS VARCHAR),3) + '-' + RIGHT('0' + CAST(@lastfour AS VARCHAR), 4);

		INSERT INTO CorruptData
		SELECT UPPER(@firstname), @lastname, @phonenumber;

		SELECT @lastnamectr += 1;

		SELECT @firstnamectr += 1;

		IF @firstnamectr = 100
		BEGIN

			SELECT @firstnamectr = 1;

		END

	END

--PRINT @lastnamectr;
--PRINT @loopcount;

SELECT @lastnamectr = 1, @firstnamectr = 1, @loopcount += 1;

END

SELECT * FROM CorruptData;