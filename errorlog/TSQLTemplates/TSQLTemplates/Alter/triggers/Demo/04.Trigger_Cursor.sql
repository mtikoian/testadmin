USE TriggerDemo;
SET NOCOUNT ON;
GO

CREATE TABLE dbo.Table_Cursor
(
  id INT, 
  DateModified SMALLDATETIME
);
GO

CREATE TRIGGER dbo.Table_Cursor_Update -- cursor
ON dbo.Table_Cursor
FOR UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id INT;

  DECLARE c CURSOR LOCAL FAST_FORWARD
    FOR SELECT id FROM inserted;

  OPEN c;

  FETCH c INTO @id;

  WHILE @@FETCH_STATUS <> -1
  BEGIN
    UPDATE dbo.Table_Cursor
      SET DateModified = GETDATE() 
	  WHERE id = @id;

	FETCH c INTO @id;
  END

  CLOSE c;
  DEALLOCATE c;
END
GO
DROP TABLE dbo.Table_set
CREATE TABLE dbo.Table_Set
(id INT, DateModified SMALLDATETIME);
GO

CREATE TRIGGER dbo.Table_Set_Update -- set-based
ON dbo.Table_Set
FOR UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE t SET DateModified = GETDATE()
    FROM dbo.Table_Set AS t
	INNER JOIN inserted AS i
	ON t.id = i.id;
END
GO

INSERT dbo.Table_Cursor(id) 
  SELECT ROW_NUMBER() OVER (ORDER BY s1.[object_id])
  FROM sys.all_objects AS s1;

INSERT dbo.Table_Set(id) 
  SELECT ROW_NUMBER() OVER (ORDER BY s1.[object_id])
  FROM sys.all_objects AS s1;

DECLARE @d DATETIME2(7) = SYSDATETIME();

UPDATE dbo.Table_Cursor SET id = id / 1;

SELECT DATEDIFF(MILLISECOND, @d, SYSDATETIME());
SELECT @d = SYSDATETIME();

UPDATE dbo.Table_Set SET id = id / 1;

SELECT DATEDIFF(MILLISECOND, @d, SYSDATETIME());
GO

DROP TABLE dbo.Table_Cursor, dbo.Table_Set;