/***
================================================================================
 Name        : <View schema,,>.<View name,,>
 Author      : <Author name,,>
 Description : Drops view <View schema,,>.<View name,,>

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