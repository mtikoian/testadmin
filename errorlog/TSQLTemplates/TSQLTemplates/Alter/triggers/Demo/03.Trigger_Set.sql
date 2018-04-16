USE TriggerDemo;
SET NOCOUNT ON;
GO

CREATE TABLE dbo.Table_Set
(id INT, DateModified SMALLDATETIME);
GO

CREATE TRIGGER dbo.Table_Set_Update
ON dbo.Table_Set
FOR UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE t SET DateModified = GETDATE()
    FROM dbo.Table_Set AS t
	INNER JOIN inserted AS i
	ON t.id = i.id;

/* or 
  UPDATE t SET DateModified = GETDATE()
    FROM dbo.Table_Set AS t
	WHERE EXISTS
	(
	  SELECT 1 FROM inserted WHERE id = t.id
	);
*/
END
GO

INSERT dbo.Table_Set(id) VALUES(2),(1),(3);
GO

SELECT id, DateModified FROM dbo.Table_Set;
GO

UPDATE dbo.Table_Set SET id = id/1;
GO

SELECT id, DateModified FROM dbo.Table_Set;
GO

DROP TABLE dbo.Table_Set;
GO