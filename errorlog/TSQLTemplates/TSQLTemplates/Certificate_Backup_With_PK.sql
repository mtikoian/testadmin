/***
================================================================================
 Author      : <Author name,,>
 Name        : <Certificate name,,>
 Description : Backs up a certificate for restoration in another database. This
               includes the private key, which is necessary if the certificate is 
               used for counter-signing or signing code in the other database.

               Required SQLCMD variables:

               Cert_Backup_Path - the path at which to save the backup file of the certificate
               Cert_PrivateKey_Backup_Path - the path at which to save the private key backup file
               Cert_PrivateKey_Encryption_Password - the password used to encrypt the private key.
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
  backup certificate <Certificate name,,> to file = '$(Cert_Backup_Path)'
    with private key 
    (
      file = '$(Cert_PrivateKey_Backup_Path)',
      encryption by password = '$(Cert_PrivateKey_Encryption_Password)'
    )
else
  raiserror('Certificate <Certificate name,,> does not exist.',16,1);