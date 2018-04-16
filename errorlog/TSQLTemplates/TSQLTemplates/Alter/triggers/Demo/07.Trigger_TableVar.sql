USE TriggerDemo;
SET NOCOUNT ON;
GO

CREATE TABLE dbo.Table_TableVar(id INT);
CREATE TABLE dbo.TableInsertFailureLog(id INT, dt DATETIME);
GO

CREATE TRIGGER dbo.Table_TableVar_Insert
ON dbo.Table_TableVar
FOR INSERT
AS
BEGIN
  SET NOCOUNT ON;