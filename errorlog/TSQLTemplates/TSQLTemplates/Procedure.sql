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

/***
================================================================================
 Name        : <Procedure name,,>
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

Column Name   | Data Type       | Source Procedure        | Description

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
CREATE PROCEDURE <Procedure schema,,>.<Procedure name,,>

AS

DECLARE @error_number INT;
DECLARE @error_message INT;
DECLARE @error_severity TINYINT;

-- Initialize variables here --
SET @error_number = 0;

-- Create any temporary tables here --

BEGIN TRY

  -- Place main code here

END TRY
BEGIN CATCH

  SET @error_number = ERROR_NUMBER();
  SET @error_message = ERROR_MESSAGE();
  SET @error_severity = ERROR_SEVERITY();

  RAISERROR(@error_message,@error_severity,1);

END CATCH

RETURN @error_number;
GO

IF EXISTS (
  SELECT  1
  FROM    INFORMATION_SCHEMA.ROUTINES
  WHERE   ROUTINE_NAME = '<Procedure name,,>' AND
          ROUTINE_SCHEMA = '<Procedure schema,,>')
BEGIN
  
  EXEC sp_addextendedproperty @name = 'SVN Revision',
                              @value = '$Rev$',
                              @level0type = 'SCHEMA',
                              @level0name = '<Procedure schema,,>',
                              @level1type = 'PROCEDURE',
                              @level1name = '<Procedure name,,>';
  EXEC sp_addextendedproperty @name = 'MS_Description',
                              @value = '<Description,,>',
                              @level0type = 'SCHEMA',
                              @level0name = '<Procedure schema,,>',
                              @level1type = 'Procedure',
                              @level1name = '<Procedure name,,>';
  
  -- Place any GRANT statements for permissions here
END
ELSE
  PRINT '<Procedure schema,,>.<Procedure name,,> not created, please review log.'; 
