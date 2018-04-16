/***
================================================================================
 Author      : <Author name,,>
 Name        : <Certificate name,,>
 Description : Restores a certificate from a file. This includes the private key, 
               which is necessary if the certificate is used for counter-signing 
               or signing code in the other database.

               Required SQLCMD variables:

               Cert_Backup_Path - the path at which the backup file of the certificate resides
               Cert_PrivateKey_Backup_Path - the path at which the private key backup file resides
               Cert_PrivateKey_Encryption_Password - the password used to decrypt the private key.
                This is required when restoring the private key.

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
  drop certificate <Certificate name,,>;

create certificate <Certificate name,,> from file = '$(Cert_Backup_Path)'
  with private key 
  (
    file = '$(Cert_PrivateKey_Backup_Path)',
    decryption by password = '$(Cert_PrivateKey_Encryption_Password)'
  );
