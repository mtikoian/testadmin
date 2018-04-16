/***
================================================================================
 Name        : <Schema name,,>
 Author      : <Author name,,>
 Description : Creates schema <Schema name,,>

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
CREATE SCHEMA <Schema name,,> AUTHORIZATION <Schema OWNER,,>;
GO

IF EXISTS (
  SELECT  1
  FROM    sys.schemas
  WHERE   name = '<Schema name,,>')
BEGIN
  
  EXEC sp_addextendedproperty @name = 'SVN Revision',
                              @value = '$Rev$',
                              @level0type = 'SCHEMA',
                              @level0name = '<Schema name,,>';
  EXEC sp_addextendedproperty @name = 'MS_Description',
                              @value = '<Description,,>',
                              @level0type = 'SCHEMA',
                              @level0name = '<Schema name,,>';

  -- Place any GRANT statements here

END
ELSE
  PRINT '<Schema name,,> not created, please review log.'; 

