USE DeadlockTests;
GO
--
-- Run the following script from one SSMS tab:
--
DECLARE @i INT;
SET NOCOUNT ON;
SET @i=0;
WHILE (@i<10000) BEGIN
  UPDATE Data.Test
      SET toggle1 = toggle1 + 1
      WHERE i1 BETWEEN 1000 AND 1500;
  SET @i = @i + 1;
END;