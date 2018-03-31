
USE DeadlockTests;
GO
--
-- and the following script from another SSMS tab simultaneously:
--
DECLARE @i INT;
SET NOCOUNT ON;
SET @i=0;
WHILE (@i<10000) BEGIN
  UPDATE Data.Test
      SET toggle2 = toggle2 + 1
      WHERE i2 BETWEEN 998500 AND 999000;
  SET @i = @i + 1;
END;