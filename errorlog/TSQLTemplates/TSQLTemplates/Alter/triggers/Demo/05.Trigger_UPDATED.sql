USE TriggerDemo;
SET NOCOUNT ON;
GO

CREATE TABLE dbo.Table_UPDATED
(
  id INT, 
  name NVARCHAR(32)
);
GO
INSERT dbo.Table_UPDATED VALUES
(1,N'bob'),(2,N'frank'),(3,NULL);
GO

CREATE TRIGGER dbo.Table_UPDATED_Update
ON dbo.Table_UPDATED
FOR UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  IF UPDATE(name) OR COLUMNS_UPDATED() & 2 > 0
  BEGIN
    PRINT 'name was updated';
  END

  SELECT id,name FROM inserted WHERE UPDATE(name);
END
GO

UPDATE dbo.Table_UPDATED 
  SET name = N'bob' 
  WHERE id = 1; 
  -- not really updating anything; already bob

UPDATE dbo.Table_UPDATED 
  SET name = name; 
  -- not really updating anything

UPDATE dbo.Table_UPDATED 
  SET name += 
  CASE WHEN id = 1 THEN N'x' ELSE N'' END;
  -- only really updating one row

UPDATE dbo.Table_UPDATED 
  SET name = N'foo' WHERE name IS NULL;
  -- only updating one row

DROP TABLE dbo.Table_UPDATED;



/*
DROP TRIGGER dbo.Table_UPDATED_Update;
GO
CREATE TRIGGER dbo.Table_UPDATED_Update
ON dbo.Table_UPDATED
FOR UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @x VARCHAR(36) = NEWID();

  SELECT i.id, old_name = d.name, new_name = i.name
    FROM inserted AS i
	INNER JOIN deleted AS d
	ON i.id = d.id
	AND
	(
	  COALESCE(i.name,@x) <> COALESCE(d.name,@x)
	);
END
GO
*/