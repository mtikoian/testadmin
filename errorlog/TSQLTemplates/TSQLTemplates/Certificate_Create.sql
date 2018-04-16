/***
================================================================================
 Author      : <Author name,,>
 Name        : <Certificate name,,>
 Description : Creates a certificate encrypted by the database master key

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
if exists (select 1 from sys.certificates where name = '<Certificate name,,>')
  drop certificate [<Certificate name,,>];

create certificate [<Certificate name,,>] with subject = '<Certificate subject,,>';