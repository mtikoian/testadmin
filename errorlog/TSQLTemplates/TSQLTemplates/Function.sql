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

/***
================================================================================
 Name        : <Function name,,>
 Author      : <Author name,,>
 Description : <Description,,>

 Revision: $Rev$
 URL: $URL$
 Last Checked in: $Author$
===============================================================================
Parameters   : 

Name                  | I/O   | Description

--------------------------------------------------------------------------------
Result Set:

Column Name   | Data Type       | Source Table        | Description

--------------------------------------------------------------------------------
If record set is retuned give brief description of the fields being returned

Return Value: Return code
     Success : 0
     Failure : Error number and Description

Revisions    :
--------------------------------------------------------------------------------
 Ini|   Date   | Description
--------------------------------------------------------------------------------

================================================================================
***/
CREATE FUNCTION <Function schema,,>.<Function name,,>

AS


GO
IF EXISTS (
  SELECT  1
  FROM    INFORMATION_SCHEMA.ROUTINES
  WHERE   ROUTINE_NAME = '<Function name,,>' AND
          ROUTINE_SCHEMA = '<Function schema,,>')
BEGIN
  
  EXEC sp_addextendedproperty @name         = 'SVN Revision',
                              @value        = '$Rev$',
                              @level0type   = 'SCHEMA',
                              @level0name   = '<Function schema,,>',
                              @level1type   = 'Function',
                              @level1name   = '<Function name,,>';
  EXEC sp_addextendedproperty @name         = 'MS_Description',
                              @value        = '<Description,,>',
                              @level0type   = 'SCHEMA',
                              @level0name   = '<Function schema,,>',
                              @level1type   = 'Function',
                              @level1name   = '<Function name,,>';

  -- Place any GRANT statements here

END 
ELSE
  PRINT '<Function schema,,>.<Function name,,> not created, please review log.'; 
