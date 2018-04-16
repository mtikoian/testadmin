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
if exists (select 1 from sys.symmetric_keys where name = '<Symmetric key name,,>')
  drop symmetric key <Symmetric key name,,>;