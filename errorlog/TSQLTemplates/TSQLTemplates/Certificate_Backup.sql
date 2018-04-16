/***
================================================================================
 Author      : <Author name,,>
 Name        : <Certificate name,,>
 Description : Backs up a certificate for restoration in another database.

               Required SQLCMD variables:

               Cert_Backup_Path - the path at which to save the backup file of the certificate




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
  backup certificate <Certificate name,,> to file = '$(Cert_Backup_Path)';
else
  raiserror('Certificate <Certificate name,,> does not exist.',16,1);