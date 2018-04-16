USE TriggerDemo;
SET NOCOUNT ON;
GO

CREATE TABLE dbo.Table_Merge(id INT);
GO
INSERT dbo.Table_Merge VALUES(1),(4);
GO

CREATE TRIGGER dbo.Table_Merge_ALL
 ON dbo.Table_Merge
 FOR INSERT, UPDATE, DELETE
AS
BEGIN
  DECLARE @r VARCHAR(11) = @@ROWCOUNT, 
    @c VARCHAR(11);
  
  IF EXISTS (SELECT 1 FROM inserted) 
    AND NOT EXISTS (SELECT 1 FROM deleted)
  BEGIN
    SELECT @c = COUNT(*) FROM inserted;
    PRINT 'INSERT from all - ' + @r 
	  + ' (but really ' + @c + ')';
  END
  IF EXISTS (SELECT 1 FROM inserted) 
    AND EXISTS (SELECT 1 FROM deleted)
  BEGIN
    SELECT @c = COUNT(*) FROM inserted;
    PRINT 'UPDATE from all - ' + @r 
	  + ' (but really ' + @c + ')';
  END
  IF NOT EXISTS (SELECT 1 FROM inserted) 
    AND EXISTS (SELECT 1 FROM deleted)
  BEGIN
    SELECT @c = COUNT(*) FROM deleted;
    PRINT 'DELETE from all - ' + @r 
	  + ' (but really ' + @c + ')';
  END
END
GO

CREATE TRIGGER dbo.Table_Merge_INSERTOnly
 ON dbo.Table_Merge
 FOR INSERT
AS
BEGIN
  DECLARE @r VARCHAR(11) = @@ROWCOUNT, 
   @c VARCHAR(11);
  SELECT @c = COUNT(*) FROM inserted;
  PRINT 'INSERT from single - ' + @r
      + ' (but really ' + @c + ')';
END
GO

MERGE dbo.Table_Merge WITH (HOLDLOCK) AS [Target]
USING (VALUES(1),(2),(3)) AS [Source](id)
ON [Target].id = [Source].id
WHEN MATCHED THEN UPDATE SET [Target].id = [Source].id
WHEN NOT MATCHED THEN INSERT(id) VALUES([Source].id)
WHEN NOT MATCHED BY SOURCE THEN DELETE;
GO

DROP TABLE dbo.Table_Merge;