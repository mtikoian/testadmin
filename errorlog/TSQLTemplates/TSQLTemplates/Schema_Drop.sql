/***
================================================================================
 Name        : <Schema name,,>
 Author      : <Author name,,>
 Description : Drops schema <Schema name,,>

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
  FROM    sys.schemas
  WHERE   name = '<Schema name,,>')
BEGIN
  
  DROP SCHEMA <Schema name,,>;
  RAISERROR('Dropped schema "%s".',10,1,'<Schema name,,>') WITH NOWAIT;

END
GO