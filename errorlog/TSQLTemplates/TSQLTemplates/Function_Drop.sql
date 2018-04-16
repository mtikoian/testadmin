/***
================================================================================
 Name        : <Function name,,>
 Author      : <Author name,,>
 Description : Drops function <Function schema,,>.<Function name,,>

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
  FROM    INFORMATION_SCHEMA.ROUTINES
  WHERE   ROUTINE_NAME = '<Function name,,>' AND
          ROUTINE_SCHEMA = '<Function schema,,>')
BEGIN
  
  DROP FUNCTION <Function schema,,>.<Function name,,>;
  RAISERROR('Dropped function "%s.%s".',10,1,'<Function schema,,>','<Function name,,>') WITH NOWAIT;

END
GO