USE AdventureWorks2012;
--If there is no master key, create one now. 
IF NOT EXISTS 
    (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
    CREATE MASTER KEY ENCRYPTION BY 
    PASSWORD = '23987hxJKL95QYV4369#ghf0%lekjg5k3fd117r$$#1946kcj$n44ncjhdlj'
GO

CREATE CERTIFICATE Sales09
   WITH SUBJECT = 'Customer Credit Card Numbers';
GO

CREATE SYMMETRIC KEY CreditCards_Key11
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE Sales09;
GO

-- Create a column in which to store the encrypted data.
ALTER TABLE Sales.CreditCard 
    ADD CardNumber_Encrypted varbinary(128); 
GO

-- Open the symmetric key with which to encrypt the data.
OPEN SYMMETRIC KEY CreditCards_Key11
   DECRYPTION BY CERTIFICATE Sales09;

-- Encrypt the value in column CardNumber using the
-- symmetric key CreditCards_Key11.
-- Save the result in column CardNumber_Encrypted.  
UPDATE Sales.CreditCard
SET CardNumber_Encrypted = EncryptByKey(Key_GUID('CreditCards_Key11')
    , CardNumber, 1, HashBytes('SHA1', CONVERT( varbinary
    , CreditCardID)));
GO

-- Verify the encryption.
-- First, open the symmetric key with which to decrypt the data.

OPEN SYMMETRIC KEY CreditCards_Key11
   DECRYPTION BY CERTIFICATE Sales09;
GO

-- Now list the original card number, the encrypted card number,
-- and the decrypted ciphertext. If the decryption worked,
-- the original number will match the decrypted number.

SELECT CardNumber, CardNumber_Encrypted 
    AS 'Encrypted card number', CONVERT(nvarchar,
    DecryptByKey(CardNumber_Encrypted, 1 , 
    HashBytes('SHA1', CONVERT(varbinary, CreditCardID))))
    AS 'Decrypted card number' FROM Sales.CreditCard;
GO