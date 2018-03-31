/*
-- http://sqlblog.com/blogs/alexander_kuznetsov/archive/2009/01/01/reproducing-deadlocks-involving-only-one-table.aspx
-- This takes 2 minutes to execute

--DO NOT RUN DURING LIVE PRESO
--THIS IS A PRE-DEMO SCRIPT
USE master
GO
DROP DATABASE DeadlockTests;
GO
CREATE DATABASE DeadlockTests;
GO
USE DeadlockTests;
GO
CREATE SCHEMA Data AUTHORIZATION dbo;
GO
--
-- Setting up a helper table with 1000 consecutive integer numbers
--
CREATE TABLE Data.Numbers(Number INT);
GO
DECLARE @i INT;
SET NOCOUNT ON;
SET @i=0;
WHILE(@i<1000) BEGIN
  INSERT Data.numbers(Number)VALUES(@i);
  SET @i=@i+1;
END;
GO

CREATE TABLE Data.Test(ID INT NOT NULL CONSTRAINT PK_Test PRIMARY KEY,
      i1 INT NOT NULL,
      i2 INT NOT NULL,
      toggle1 INT NOT NULL,
      toggle2 INT NOT NULL,
      filler CHAR(200));
GO
--
-- Assuming that there is a helper table Data.Numbers
-- which has at least 1000 rows
--
INSERT INTO Data.Test(ID, i1, i2, toggle1, toggle2, filler)
  SELECT n1.Number*1000 + n2.Number,
            n2.Number*1000 + n1.Number,
            1000000 - n2.Number*1000 - n1.Number,
            0,
            0,
            'qwerty'
  FROM Data.Numbers AS n1 CROSS JOIN Data.Numbers AS n2
  WHERE n1.Number<1000 AND n2.Number<1000;
GO
CREATE UNIQUE INDEX UNQ_Test_i1 ON Data.Test(i1);
GO
CREATE UNIQUE INDEX UNQ_Test_i2 ON Data.Test(i2);
GO
 */