IF EXISTS (
  SELECT  1
  FROM    sys.triggers tr JOIN sys.objects so
            ON tr.parent_id = so.object_id
          JOIN sys.schemas ss
            ON so.schema_id = ss.schema_id
  WHERE   tr.name = '<Trigger name,,>' AND
          ss.name = '<Table schema,,>')
BEGIN
  
  DROP TRIGGER <Table schema,,>.<Trigger name,,>;
  RAISERROR('Dropped trigger "%s" on "%s.%s".',10,1,'<Trigger name,,>','<Table schema,,>','<Table name,,>') WITH NOWAIT;

END
GO

/***
================================================================================
 Name        : <Table schema,,>.<Trigger name,,>
 Author      : <Author name,,>
 Description : <Description,,>

 Revision: $Rev$
 URL: $URL$
 Last Checked in: $Author$
===============================================================================

Revisions    :
--------------------------------------------------------------------------------
 Ini|   Date   | Description
--------------------------------------------------------------------------------

================================================================================
***/
CREATE TRIGGER <Table schema,,>.<Trigger name,,> ON <Table schema,,>.<Table name,,>
AS

-- Insert trigger code here

GO

IF EXISTS (
  SELECT  1
  FROM    sys.triggers
  WHERE   name = '<Trigger name,,>')
BEGIN
  
  EXEC sp_addextendedproperty @name = 'SVN Revision',
                              @value = '$Rev$',
                              @level0type = 'SCHEMA',
                              @level0name = '<Table schema,,>',
                              @level1type = 'TABLE',
                              @level1name = '<Table name,,>',
                              @level2type = 'TRIGGER',
                              @level2name = '<Trigger name,,>';
  EXEC sp_addextendedproperty @name = 'MS_Description',
                              @value = '<Description,,>',
                              @level0type = 'SCHEMA',
                              @level0name = '<Table schema,,>',
                              @level1type = 'TABLE',
                              @level1name = '<Table name,,>',
                              @level2type = 'TRIGGER',
                              @level2name = '<Trigger name,,>';
END
ELSE
  PRINT '<Trigger name,,> not created, please review log.'; 

