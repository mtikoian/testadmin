DECLARE @SQLCMD1 NVARCHAR(4000)
BEGIN TRY
  ; WITH TriggName(TrigName,SchemaName) AS (
  SELECT 
     sysobjects.name AS trigger_name 
    ,s.name AS table_schema 
  FROM sysobjects 
  INNER JOIN sys.tables t 
    ON sysobjects.parent_obj = t.object_id 

  INNER JOIN sys.schemas s 
    ON t.schema_id = s.schema_id 
  WHERE sysobjects.type = 'TR'  AND s.name IN('dbo','BISSEC','AGA'))
  SELECT @SQLCMD1 = COALESCE(@SQLCMD1  , '') +  ' DROP TRIGGER ' + SchemaName + '.' +  TrigName + ';' FROM TriggName;
  IF @@ROWCOUNT >0 
  BEGIN
    EXEC sp_ExecuteSQL @SQLCMD1;
    PRINT 'Triggers Dropped Successfully';
  END
  ELSE
    PRINT 'No Triggers Exist on database';    
END TRY
BEGIN CATCH
  PRINT 'Error Number:' + ltrim(str(ERROR_NUMBER()))
  PRINT 'Error :'+ ERROR_MESSAGE()
  RAISERROR ('',16,255)
END CATCH