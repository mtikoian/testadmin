IF EXISTS (
  SELECT  1
  FROM    INFORMATION_SCHEMA.ROUTINES
  WHERE   ROUTINE_NAME = 'f_BuildEnableDisableIndexCommand' AND
          ROUTINE_SCHEMA = 'dbo')
BEGIN
  
  DROP FUNCTION dbo.f_BuildEnableDisableIndexCommand;
  RAISERROR('Dropped function "%s.%s".',10,1,'dbo','f_BuildEnableDisableIndexCommand') WITH NOWAIT;

END
GO

/***
================================================================================
 Name        : f_BuildEnableDisableIndexCommand
 Author      : Josh Feierman
 Description : Dynamically builds a T-SQL command to enable or disable all nonclustered indexes on a given table.

 Revision: $Rev: 336 $
 URL: $URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_BuildEnableDisableIndexCommand.sql $
 Last Checked in: $Author: jfeierman $
===============================================================================
Parameters   : 

Name                  | I/O   | Description
--------------------------------------------------------------------------------
@i_Schema_Name        | I     | The schema name of the table to create the disable command for.
@i_Table_Name         | I     | The table name to create the disable command for. If passed as NULL 
                                will build commands for all tables in the specified schema.
@i_EnableDisable_Fl   | I     | Indicates if the command to enable or disable indexes should be built. 
                                'E' = Enable, 'D' = Disable.
@i_Exclude_Unique_Fl  | I     | Indicates if unique indexes should be ignored.
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
CREATE FUNCTION dbo.f_BuildEnableDisableIndexCommand
(
  @i_Schema_Name sysname,
  @i_Table_Name sysname,
  @i_EnableDisable_Fl char(1) = 'E',
  @i_Exclude_Unique_Fl bit = 0
)
RETURNS TABLE
AS
RETURN
(
    SELECT
      ssch.name as Schema_Nm,
      sobj.name as Table_Nm,
      sidx.name as Index_Nm,
      'ALTER INDEX ' 
        + quotename(sidx.name) 
        + ' ON ' 
        + quotename(ssch.name) 
        + '.' + quotename(sobj.name) 
        + ' '
        + case @i_EnableDisable_Fl
            when 'E' then 'REBUILD'
            when 'D' then 'DISABLE'
          end  AS Command_Tx
    FROM
      sys.schemas ssch join sys.objects sobj
        on ssch.schema_id = sobj.schema_id
           and ssch.name = @i_Schema_Name
           and (sobj.name = @i_Table_Name or @i_Table_Name is null)
      join sys.indexes sidx
        on sobj.object_id = sidx.object_id
           and sidx.is_primary_key = 0 -- exclude primary keys
           and sidx.is_unique = case when @i_Exclude_Unique_Fl = 1 then 0 else sidx.is_unique end -- exclude unique indexes
           and sidx.index_id > 1 -- exclude clustered index and heap
           and sidx.is_disabled = case @i_EnableDisable_Fl
                                    when 'E' then 1 -- only include disabled indexes when the "Enable" option is set
                                    when 'D' then 0 -- only include enabled indexes when the "Disable" option is set
                                  end
)

GO
IF EXISTS (
  SELECT  1
  FROM    INFORMATION_SCHEMA.ROUTINES
  WHERE   ROUTINE_NAME = 'f_BuildEnableDisableIndexCommand' AND
          ROUTINE_SCHEMA = 'dbo')
BEGIN
  
  EXEC sp_addextendedproperty @name         = 'SVN Revision',
                              @value        = '$Rev: 336 $',
                              @level0type   = 'SCHEMA',
                              @level0name   = 'dbo',
                              @level1type   = 'Function',
                              @level1name   = 'f_BuildEnableDisableIndexCommand';
  EXEC sp_addextendedproperty @name         = 'MS_Description',
                              @value        = 'Dynamically builds a T-SQL command to disable all nonclustered indexes on a given table.',
                              @level0type   = 'SCHEMA',
                              @level0name   = 'dbo',
                              @level1type   = 'Function',
                              @level1name   = 'f_BuildEnableDisableIndexCommand';

  -- Place any GRANT statements here

END 
ELSE
  PRINT 'dbo.f_BuildEnableDisableIndexCommand not created, please review log.'; 
