USE TriggerDemo;
SET NOCOUNT ON;
GO

DROP TABLE dbo.Table_Singleton;

CREATE TABLE dbo.Table_Singleton
(
  id INT, 
  DateModified SMALLDATETIME
);
GO
--CREATE CLUSTERED INDEX x ON dbo.Table_Singleton(id DESC);
GO

CREATE TRIGGER dbo.Table_Singleton_Update
ON dbo.Table_Singleton
FOR UPDATE
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @id INT;

  SELECT @id = id FROM inserted;

  UPDATE dbo.Table_Singleton 
    SET DateModified = GETDATE() 
	WHERE id = @id;
END
GO

INSERT dbo.Table_Singleton(id) VALUES(2),(1),(3);
GO

CREATE TRIGGER dbo.what
ON dbo.Table_Singleton
INSTEAD OF UPDATE
AS
AS
  SELECT 1;
SELECT id, DateModified FROM dbo.Table_Singleton;
GO

UPDATE dbo.Table_Singleton SET id = id/1;
GO

SELECT id, DateModified FROM dbo.Table_Singleton;
GO

DROP TABLE dbo.Table_Singleton;
GO