IF EXISTS (
  SELECT  1
  FROM    INFORMATION_SCHEMA.TABLES
  WHERE   TABLE_NAME = '<View name,,>' AND
          TABLE_SCHEMA = '<View schema,,>')
BEGIN
  
  DROP VIEW <View schema,,>.<View name,,>;
  RAISERROR('Dropped table "%s.%s".',10,1,'<View schema,,>','<View name,,>') WITH NOWAIT;

END
GO

/***
================================================================================
 Name        : <View schema,,>.<View name,,>
 Author      : <Author name,,>
 Description : <Description,,>

 Revision: $Rev$
 URL: $URL$
 Last Checked in: $Author$
===============================================================================

Result Set:
-------------------------------------------------------------------------------
Name                | Source Table          | Description
-------------------------------------------------------------------------------

Revisions    :
--------------------------------------------------------------------------------
 Ini|   Date   | Description
--------------------------------------------------------------------------------

================================================================================
***/
CREATE VIEW <View schema,,>.<View name,,>
AS

-- Insert view code here

GO

IF EXISTS (
  SELECT  1
  FROM    INFORMATION_SCHEMA.TABLES
  WHERE   TABLE_NAME = '<View name,,>' AND
          TABLE_SCHEMA = '<View schema,,>')
BEGIN
  
  EXEC sp_addextendedproperty @name = 'SVN Revision',
                              @value = '$Rev$',
                              @level0type = 'SCHEMA',
                              @level0name = '<View schema,,>',
                              @level1type = 'VIEW',
                              @level1name = '<View name,,>';
  EXEC sp_addextendedproperty @name = 'MS_Description',
                              @value = '<Description,,>',
                              @level0type = 'SCHEMA',
                              @level0name = '<View schema,,>',
                              @level1type = 'VIEW',
                              @level1name = '<View name,,>';

  -- Place any GRANT statements here

END
ELSE
  PRINT '<View schema,,>.<View name,,> not created, please review log.'; 

