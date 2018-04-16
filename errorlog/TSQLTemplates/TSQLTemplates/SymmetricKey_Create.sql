/***
================================================================================
 Author      : <Author name,,>
 Description : Creates symmetric key <Symmetric key name,,>

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
if not exists (select 1 from sys.symmetric_keys where name = '<Symmetric key name,,>')
  create symmetric key <Symmetric key name,,> encryption by certificate <Encrypting certificate name,,>;