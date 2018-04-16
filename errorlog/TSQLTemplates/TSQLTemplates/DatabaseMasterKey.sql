/***
================================================================================
 Author      : <Author name,,>
 Description : Creates database master key for database <database name,,>

 Required variables:
 ====================
 DatabaseMasterKeyPassword - the password to create the database master key with

 Revision: $Rev: 189 $
 URL: $URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Templates/Table.sql $
 Last Checked in: $Author: jfeierman $
===============================================================================

Revisions    :
--------------------------------------------------------------------------------
 Ini|   Date   | Description
--------------------------------------------------------------------------------

================================================================================
***/
if not exists (select 1 from sys.symmetric_keys where name = '##MS_DatabaseMasterKey##')
  create master key encryption by password = '$(DatabaseMasterKeyPassword)';