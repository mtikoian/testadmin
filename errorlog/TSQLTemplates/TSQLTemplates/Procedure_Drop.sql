/***
================================================================================
 Name        : <Procedure name,,>
 Author      : <Author name,,>
 Description : Drops procedure <Procedure schema,,>.<Procedure name,,>

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
  WHERE   ROUTINE_NAME = '<Procedure name,,>' AND
          ROUTINE_SCHEMA = '<Procedure schema,,>')
BEGIN
  
  DROP PROCEDURE <Procedure schema,,>.<Procedure name,,>;
  RAISERROR('Dropped procedure "%s.%s".',10,1,'<Procedure schema,,>','<Procedure name,,>') WITH NOWAIT;

END
GO
